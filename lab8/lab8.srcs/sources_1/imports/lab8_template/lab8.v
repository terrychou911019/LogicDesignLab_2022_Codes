`define silence   32'd50000000
`define c   32'd262   
`define d   32'd294
`define e   32'd330
`define f   32'd349
`define g   32'd392   
`define a   32'd440
`define b   32'd494
`define hc  32'd524   // C4
`define hd  32'd588   // D4
`define he  32'd660   // E4
`define hf  32'd698   // F4
`define hg  32'd784   // G4

module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit, 
	input wire [15:0] nums, // four 4-bits BCD number
	input wire rst,
	input wire clk  // Input 100Mhz clock
);
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		clk_divider <= 15'b0;
    	end else begin
    		clk_divider <= clk_divider + 15'b1;
    	end
    end
    
    always @ (posedge clk_divider[15], posedge rst) begin
    	if (rst) begin
    		display_num <= 4'b0000;
    		digit <= 4'b1111;
    	end else begin
    		case (digit)
    			4'b1110 : begin
    					display_num <= nums[7:4];
    					digit <= 4'b1101;
    				end
    			4'b1101 : begin
						display_num <= nums[11:8];
						digit <= 4'b1011;
					end
    			4'b1011 : begin
						display_num <= nums[15:12];
						digit <= 4'b0111;
					end
    			4'b0111 : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end
    			default : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end				
    		endcase
    	end
    end
    
    always @ (*) begin
    	case (display_num)
			4'd0: display = 7'b0100111;   // c
			4'd1: display = 7'b0100001;   // d
			4'd2: display = 7'b0000110;   // E
			4'd3: display = 7'b0001110;   // F
			4'd4: display = 7'b1000010;   // g
			4'd5: display = 7'b0100000;   // a
			4'd6: display = 7'b0000011;   // b
			4'd10: display = 7'b0111111;   // -
			default : display = 7'b1111111;
    	endcase
    end   
endmodule

module lab8(
    clk,        // clock from crystal
    rst,        // BTNC: active high reset
    _play,      // SW0: Play/Pause
    _mute,      // SW1: Mute
    _slow,      // SW2: Slow
    _music,     // SW3: Music
    _mode,      // SW15: Mode
    _volUP,     // BTNU: Vol up
    _volDOWN,   // BTND: Vol down
    _higherOCT, // BTNR: Oct higher
    _lowerOCT,  // BTNL: Oct lower
    PS2_DATA,   // Keyboard I/O
    PS2_CLK,    // Keyboard I/O
    _led,       // LED: [15:13] octave & [4:0] volume
    audio_mclk, // master clock
    audio_lrck, // left-right clock
    audio_sck,  // serial clock
    audio_sdin, // serial audio data input
    DISPLAY,    // 7-seg
    DIGIT       // 7-seg
);

    // I/O declaration
    input clk; 
    input rst; 
    input _play, _mute, _slow, _music, _mode; 
    input _volUP, _volDOWN, _higherOCT, _lowerOCT; 
    inout PS2_DATA; 
	inout PS2_CLK; 
    output wire [15:0] _led; 
    output wire audio_mclk; 
    output wire audio_lrck; 
    output wire audio_sck; 
    output wire audio_sdin; 
    output wire [6:0] DISPLAY; 
    output wire [3:0] DIGIT; 
    
    // Internal Signal
    wire [15:0] audio_in_left, audio_in_right;

    wire [11:0] ibeatNum;               // Beat counter
    wire [11:0] rdNum;
    wire [2:0] pressNum;
    wire [31:0] freqL, freqR;           // Raw frequency, produced by music module
    wire [21:0] freq_outL, freq_outR;    // Processed frequency, adapted to the clock rate of Basys3

    // clkDiv22
    wire clkDiv22;
    clock_divider #(.n(22)) clock_22(.clk(clk), .clk_div(clkDiv22));    // for keyboard and audio
    
    reg [31:0] cnt, next_cnt;
    
    always @(posedge clk, posedge op_rst)
    begin
        if (op_rst)
            cnt <= 0;
        else
            cnt <= next_cnt;
    end
    
    always @*
    begin
        if (!_mode) // PLAY mode
            if (cnt == 32'd1000000000) 
                next_cnt = 0;
            else if (key_down[KEY_CODES[7]] || _led[5])
                next_cnt = cnt + 1;
            else
                next_cnt = cnt;
        else 
            next_cnt = 0;
    end
 
    // Player Control
    // [in]  reset, clock, _play, _slow, _music, and _mode
    // [out] beat number   
    player_control #(.LEN(128)) playerCtrl_00 ( 
        .clk(clkDiv22),
        .reset(op_rst),
        ._play(_play),
        ._slow(_slow), 
        ._mode(_mode),
        ._music(_music),
        .key_down(key_down),
	    .last_change(last_change),
	    .key_valid(key_valid),
        .ibeat(ibeatNum),
        .rd(rdNum),
        .press(pressNum)
    );

    // Music module
    // [in]  beat number and en
    // [out] left & right raw frequency
    music_example music_00 (
        .clk(clk), 
        .rst(op_rst),
        .ibeatNum(ibeatNum),
        .rdNum(rdNum),
        .pressNum(pressNum),
        .en(_mode),
        ._play(_play),
        ._music(_music),
        .recording(_led[5]),
        .key_down(key_down),
	    .last_change(last_change),
	    .key_valid(key_valid),
        .toneL(freqL),
        .toneR(freqR)
    );

    // freq_outL, freq_outR
    // Note gen makes no sound, if freq_out = 50000000 / `silence = 1
    assign freq_outL = ({_led[15], _led[14], _led[13]} == 3'b100) ? 50000000 / (freqL >> 2) : 
                       ({_led[15], _led[14], _led[13]} == 3'b001) ? 50000000 / (freqL << 2) :
                       50000000 / freqL;
    assign freq_outR = ({_led[15], _led[14], _led[13]} == 3'b100) ? 50000000 / (freqR >> 2) : 
                       ({_led[15], _led[14], _led[13]} == 3'b001) ? 50000000 / (freqR << 2) :
                       50000000 / freqR;

    // Note generation
    // [in]  processed frequency
    // [out] audio wave signal (using square wave here)
    reg [2:0] vol, next_vol;
    
    always @(posedge clk, posedge op_rst)
    begin
        if (op_rst)
            vol <= 3'd3;
        else   
            vol <= next_vol;
    end
    
    always @*
    begin
        if ({_led[4], _led[3], _led[2], _led[1], _led[0]} == 5'b11111)
            next_vol = 3'd5;
        else if ({_led[4], _led[3], _led[2], _led[1], _led[0]} == 5'b01111)
            next_vol = 3'd4;
        else if ({_led[4], _led[3], _led[2], _led[1], _led[0]} == 5'b00111)
            next_vol = 3'd3;
        else if ({_led[4], _led[3], _led[2], _led[1], _led[0]} == 5'b00011)
            next_vol = 3'd2;
        else if ({_led[4], _led[3], _led[2], _led[1], _led[0]} == 5'b00001)
            next_vol = 3'd1;
        else if ({_led[4], _led[3], _led[2], _led[1], _led[0]} == 5'b00000)
            next_vol = 3'd0;
        else
            next_vol = vol;
    end
    
    note_gen noteGen_00(
        .clk(clk), 
        .rst(op_rst), 
        .volume(vol),
        .note_div_left(freq_outL), 
        .note_div_right(freq_outR), 
        .audio_left(audio_in_left),     // left sound audio
        .audio_right(audio_in_right)    // right sound audio
    );

    // Speaker controller
    speaker_control sc(
        .clk(clk), 
        .rst(op_rst), 
        .audio_in_left(audio_in_left),      // left channel audio data input
        .audio_in_right(audio_in_right),    // right channel audio data input
        .audio_mclk(audio_mclk),            // master clock
        .audio_lrck(audio_lrck),            // left-right clock
        .audio_sck(audio_sck),              // serial clock
        .audio_sdin(audio_sdin)             // serial audio data input
    );
    
    // debounce & one pulse
    wire db_rst, db_volUP, db_volDOWN, db_higherOCT, db_lowerOCT; 
    wire op_rst, op_volUP, op_volDOWN, op_higherOCT, op_lowerOCT; 
    
    debounce db1 (.pb_debounced(db_rst), .pb(rst), .clk(clk));
    debounce db2 (.pb_debounced(db_volUP), .pb(_volUP), .clk(clk));
    debounce db3 (.pb_debounced(db_volDOWN), .pb(_volDOWN), .clk(clk));
    debounce db4 (.pb_debounced(db_higherOCT), .pb(_higherOCT), .clk(clk));
    debounce db5 (.pb_debounced(db_lowerOCT), .pb(_lowerOCT), .clk(clk));
    
    onepulse op1 (.signal(db_rst), .clk(clk), .op(op_rst));
    onepulse op2 (.signal(db_volUP), .clk(clk), .op(op_volUP));
    onepulse op3 (.signal(db_volDOWN), .clk(clk), .op(op_volDOWN));
    onepulse op4 (.signal(db_higherOCT), .clk(clk), .op(op_higherOCT));
    onepulse op5 (.signal(db_lowerOCT), .clk(clk), .op(op_lowerOCT));
    
    // keyboard
    wire [511:0] key_down;
    wire [8:0] last_change;
    wire key_valid;
    
    KeyboardDecoder kb (
	   .rst(rst),
	   .clk(clk),
	   .PS2_DATA(PS2_DATA),
	   .PS2_CLK(PS2_CLK),
	   .key_down(key_down),
	   .last_change(last_change),
	   .key_valid(key_valid)
    );
    
    parameter [8:0] KEY_CODES [0:7] = {
        9'b0_0001_1100, // A => 1C
        9'b0_00011_011, // S => 1B
        9'b0_0010_0011, // D => 23
        9'b0_0010_1011, // F => 2B
        9'b0_0011_0100, // G => 34
        9'b0_0011_0011, // H => 33
        9'b0_0011_1011, // J => 3B
        9'b0_0010_1101  // R => 2D
    };
    
    // 7-segment
    reg [15:0] nums, next_nums;
    
    SevenSegment(
        .display(DISPLAY),
        .digit(DIGIT), 
        .nums(nums), // four 4-bits BCD number
        .rst(op_rst),
        .clk(clk)  // Input 100Mhz clock
    );
    
    always  @(posedge clk, posedge op_rst)
    begin
        if (op_rst)
            nums <= {4'd10, 4'd10, 4'd10, 4'd10};
        else
            nums <= next_nums;
    end
    
    always @*
    begin
        if (freqR == `silence)     
            next_nums = {4'd10, 4'd10, 4'd10, 4'd10};
        else if (freqR == `c || freqR == `hc)
            next_nums = {4'd10, 4'd10, 4'd10, 4'd0};
        else if (freqR == `d || freqR == `hd)
            next_nums = {4'd10, 4'd10, 4'd10, 4'd1};
        else if (freqR == `e || freqR == `he)
            next_nums = {4'd10, 4'd10, 4'd10, 4'd2};
        else if (freqR == `f || freqR == `hf)
            next_nums = {4'd10, 4'd10, 4'd10, 4'd3};
        else if (freqR == `g || freqR == `hg)
            next_nums = {4'd10, 4'd10, 4'd10, 4'd4};
        else if (freqR == `a)
            next_nums = {4'd10, 4'd10, 4'd10, 4'd5};
        else if (freqR == `b)
            next_nums = {4'd10, 4'd10, 4'd10, 4'd6};
        else 
            next_nums = {4'd10, 4'd10, 4'd10, 4'd10};
    end
    
    // led 
    reg [4:0] vol_led, next_vol_led;
    reg [2:0] oct_led, next_oct_led;
    
    assign _led[15:13] = oct_led;
    assign _led[12:6] = 0;
    assign _led[5] = (cnt != 0) ? 1 : 0;
    assign _led[4:0] = _mute ? 5'b00000: vol_led;
    
    always @(posedge clk, posedge op_rst)
    begin
        if (op_rst)
            vol_led <= 5'b00111;
        else
            vol_led <= next_vol_led;
    end
    
    always @*
    begin
        if (op_volUP)
        begin
            if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b11111)
                next_vol_led = 5'b11111;
            else if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b01111)
                next_vol_led = 5'b11111;
            else if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b00111)
                next_vol_led = 5'b01111;
            else if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b00011)
                next_vol_led = 5'b00111;
            else if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b00001)
                next_vol_led = 5'b00011;
            else
                next_vol_led = vol_led;
        end
        else if (op_volDOWN)
        begin
            if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b11111)
                next_vol_led = 5'b01111;
            else if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b01111)
                next_vol_led = 5'b00111;
            else if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b00111)
                next_vol_led = 5'b00011;
            else if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b00011)
                next_vol_led = 5'b00001;
            else if ({vol_led[4], vol_led[3], vol_led[2], vol_led[1], vol_led[0]} == 5'b00001)
                next_vol_led = 5'b00001;
            else
                next_vol_led = vol_led;
        end 
        else
            next_vol_led = vol_led;
    end

    always @(posedge clk, posedge op_rst)
    begin
        if (op_rst)
            oct_led <= 3'b010;
        else
            oct_led <= next_oct_led;
    end
    
    always @*
    begin
        if (op_higherOCT)
        begin
            if (oct_led == 3'b100)
                next_oct_led = 3'b010;
            else if (oct_led == 3'b010)
                next_oct_led = 3'b001;
            else if (oct_led == 3'b001)
                next_oct_led = 3'b001;
            else
                next_oct_led = oct_led;
        end
        else if (op_lowerOCT)
        begin
            if (oct_led == 3'b100)
                next_oct_led = 3'b100;
            else if (oct_led == 3'b010)
                next_oct_led = 3'b100;
            else if (oct_led == 3'b001)
                next_oct_led = 3'b010;
            else
                next_oct_led = oct_led;       
        end
        else
            next_oct_led = oct_led;
    end
    
endmodule
