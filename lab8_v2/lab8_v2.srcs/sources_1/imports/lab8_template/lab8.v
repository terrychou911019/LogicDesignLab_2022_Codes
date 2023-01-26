`define silence   32'd50000000
`define sil   32'd50000000 // silence
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

module note_gen(
    clk, // clock from crystal
    rst, // active high reset
    volume, 
    note_div_left, // div for note generation
    note_div_right,
    audio_left,
    audio_right
);

    // I/O declaration
    input clk; // clock from crystal
    input rst; // active low reset
    input [2:0] volume;
    input [21:0] note_div_left, note_div_right; // div for note generation
    output [15:0] audio_left, audio_right;

    // Declare internal signals
    reg [21:0] clk_cnt_next, clk_cnt;
    reg [21:0] clk_cnt_next_2, clk_cnt_2;
    reg b_clk, b_clk_next;
    reg c_clk, c_clk_next;

    // Note frequency generation
    // clk_cnt, clk_cnt_2, b_clk, c_clk
    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            begin
                clk_cnt <= 22'd0;
                clk_cnt_2 <= 22'd0;
                b_clk <= 1'b0;
                c_clk <= 1'b0;
            end
        else
            begin
                clk_cnt <= clk_cnt_next;
                clk_cnt_2 <= clk_cnt_next_2;
                b_clk <= b_clk_next;
                c_clk <= c_clk_next;
            end
    
    // clk_cnt_next, b_clk_next
    always @*
        if (clk_cnt == note_div_left)
            begin
                clk_cnt_next = 22'd0;
                b_clk_next = ~b_clk;
            end
        else
            begin
                clk_cnt_next = clk_cnt + 1'b1;
                b_clk_next = b_clk;
            end

    // clk_cnt_next_2, c_clk_next
    always @*
        if (clk_cnt_2 == note_div_right)
            begin
                clk_cnt_next_2 = 22'd0;
                c_clk_next = ~c_clk;
            end
        else
            begin
                clk_cnt_next_2 = clk_cnt_2 + 1'b1;
                c_clk_next = c_clk;
            end

    // Assign the amplitude of the note
    // Volume is controlled here  
    assign audio_left = (note_div_left == 22'd1) ? 16'h0000 : 
                                (b_clk == 1'b0) ? (volume == 0) ? 0 : 16'hE000 - (volume - 3) * 16'h900 : 
                                (volume == 0) ? 0 : 16'h2000 + (volume - 3) * 16'h900;
    assign audio_right = (note_div_right == 22'd1) ? 16'h0000 : 
                                (c_clk == 1'b0) ? (volume == 0) ? 0 : 16'hE000 - (volume - 3) * 16'h900 : 
                                (volume == 0) ? 0 : 16'h2000 + (volume - 3) * 16'h900;                    
    
    
endmodule

module player_control (
	input clk, 
	input reset, 
	input _play, 
	input _slow, 
	input _mode, 
	input _music,
	input [511:0] key_down,
	input [8:0] last_change,
	input key_valid,
	output reg [11:0] ibeat,
	output reg [11:0] rd,
	output reg [2:0] press
);
	parameter LEN = 4095;
    reg [11:0] next_ibeat;
    reg [2:0] count, next_count;
    
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
    
    always @(posedge clk, posedge reset)
    begin
        if (reset)
            count <= 0;
        else 
            count <= next_count;
    end
    
    always @*
    begin
        if (count == 1)
            next_count = 0;
        else
            next_count = count + 1;
    end
    
	always @(posedge clk, posedge reset) begin
		if (reset) begin
			ibeat <= 0;
		end else begin
            ibeat <= next_ibeat;
		end
	end

    always @* 
    begin
        if (_mode) // DEMONSTRATON mode
        begin
            if (!_music) // preset
                if (_play)
                begin
                    if (!_slow)
                        if (ibeat + 1 == LEN)
                            next_ibeat = 0;
                        else 
                            next_ibeat = ibeat + 1;
                    else
                        if (ibeat + 1 == LEN && count == 1)
                            next_ibeat = 0;
                        else if (count == 1)
                            next_ibeat = ibeat + 1;
                        else
                            next_ibeat = ibeat;
                end
                else
                    next_ibeat = ibeat;
            else
                next_ibeat = 0;
        end
        else // PLAY mode
            next_ibeat = ibeat; 
    end
    
    reg [11:0] next_rd;
    
    always @(posedge clk, posedge reset)
    begin
        if (reset)
            rd <= 0;
        else
            rd <= next_rd;
    end
    
    always @*
    begin
        if (_mode) // DEMONSTRATON mode
        begin
            if (_music) // record
                if (_play)
                begin
                    if (!_slow)
                        if (rd + 1 == 239)
                            next_rd = 0;
                        else 
                            next_rd = rd + 1;
                    else
                        if (rd + 1 == 239 && count == 1)
                            next_rd = 0;
                        else if (count == 1)
                            next_rd = rd + 1;
                        else
                            next_rd = rd;
                end
                else
                    next_rd = rd;
            else
                next_rd = 0;
        end
        else // PLAY mode
            next_rd = rd; 
    end
    
    reg [2:0] next_press;
    
    always @(posedge clk, posedge reset)
    begin
        if (reset)
            press <= 0;
        else
            press <= next_press;
    end
    
    always @*
    begin
        if (key_down[last_change])
            case (last_change)
                KEY_CODES[0]:
                    next_press = 3'd1;
                KEY_CODES[1]:
                    next_press = 3'd2;
                KEY_CODES[2]:
                    next_press = 3'd3;
                KEY_CODES[3]:
                    next_press = 3'd4;
                KEY_CODES[4]:
                    next_press = 3'd5;
                KEY_CODES[5]:
                    next_press = 3'd6;
                KEY_CODES[6]:
                    next_press = 3'd7;
                default:
                    next_press = 3'd0;
            endcase
        else
            next_press = 3'd0;
    end
    
endmodule


module music_example (
    input clk,
    input rst,
	input [11:0] ibeatNum,
	input [11:0] rdNum,
	input [2:0] pressNum,
	input en,
	input _play,
	input _music,
	input recording,
	input [511:0] key_down,
	input [8:0] last_change,
	input key_valid,
	output reg [31:0] toneL,
    output reg [31:0] toneR
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
 
    reg [31:0] cnt, next_cnt;
    
    always @(posedge clk, posedge rst)
    begin
        if (rst)
            cnt <= 0;
        else
            cnt <= next_cnt;
    end
    
    always @*
    begin
        if (cnt == 32'd1000000000) 
            next_cnt = 0;
        else if (recording)
            next_cnt = cnt + 1;
        else
            next_cnt = 0;
    end

    // record
    reg [31:0] record [0:255];
    reg [31:0] next_record [0:255];
    
    integer i;
    
    always @(posedge clk, posedge rst)
    begin
        if (rst)
            for (i = 0; i < 256; i = i + 1)
                record[i] <= `sil;
        else
            for (i = 0; i < 256; i = i + 1)
                record[i] <= next_record[i];      
    end 
    
    always @*
    begin
        for (i = 0; i < 256; i = i + 1)
            next_record[i] = record[i];
        if (recording)
        begin
            if (key_down[last_change])//4194304
                case (last_change)
                    KEY_CODES[0]:
                        next_record[cnt / 4194304] = `c;
                    KEY_CODES[1]:
                        next_record[cnt / 4194304] = `d;
                    KEY_CODES[2]:
                        next_record[cnt / 4194304] = `e;
                    KEY_CODES[3]:
                        next_record[cnt / 4194304] = `f;
                    KEY_CODES[4]:
                        next_record[cnt / 4194304] = `g;
                    KEY_CODES[5]:
                        next_record[cnt / 4194304] = `a;
                    KEY_CODES[6]:
                        next_record[cnt / 4194304] = `b;
                    default:
                        next_record[cnt / 4194304] = `sil;
                endcase
            else
                next_record[cnt / 4194304] = `sil;               
        end   
    end
    
    always @* begin
        if(en == 1) begin // DEMONSTRATION mode
            if (_music) // record
            begin
                if (_play)
                    toneR = record[rdNum];
                else
                    toneR = `sil;
            end
            else // preset
                if (_play)
                    case(ibeatNum)
                        12'd0: toneR = `hg;	    12'd1: toneR = `hg;
                        12'd2: toneR = `hg;	    12'd3: toneR = `hg;
                        12'd4: toneR = `hg;	    12'd5: toneR = `hg;
                        12'd6: toneR = `hg;	    12'd7: toneR = `hg;
                        
                        12'd8: toneR = `he;	    12'd9: toneR = `he;
                        12'd10: toneR = `he;	12'd11: toneR = `he;
                        12'd12: toneR = `he;	12'd13: toneR = `he;
                        12'd14: toneR = `he;	12'd15: toneR = `sil;
                        
                        12'd16: toneR = `he;	12'd17: toneR = `he;
                        12'd18: toneR = `he;	12'd19: toneR = `he;
                        12'd20: toneR = `he;	12'd21: toneR = `he;
                        12'd22: toneR = `he;	12'd23: toneR = `he;
                        
                        12'd24: toneR = `he;	12'd25: toneR = `he;
                        12'd26: toneR = `he;	12'd27: toneR = `he;
                        12'd28: toneR = `he;	12'd29: toneR = `he;
                        12'd30: toneR = `he;	12'd31: toneR = `he;
                        
                        12'd32: toneR = `hf;	12'd33: toneR = `hf;
                        12'd34: toneR = `hf;	12'd35: toneR = `hf;
                        12'd36: toneR = `hf;	12'd37: toneR = `hf;
                        12'd38: toneR = `hf;	12'd39: toneR = `hf;
                        
                        12'd40: toneR = `hd;	12'd41: toneR = `hd;
                        12'd42: toneR = `hd;	12'd43: toneR = `hd;
                        12'd44: toneR = `hd;	12'd45: toneR = `hd;
                        12'd46: toneR = `hd;	12'd47: toneR = `sil;
                        
                        12'd48: toneR = `hd;	12'd49: toneR = `hd;
                        12'd50: toneR = `hd;	12'd51: toneR = `hd;
                        12'd52: toneR = `hd;	12'd53: toneR = `hd;
                        12'd54: toneR = `hd;	12'd55: toneR = `hd;
                        
                        12'd56: toneR = `hd;	12'd57: toneR = `hd;
                        12'd58: toneR = `hd;	12'd59: toneR = `hd;
                        12'd60: toneR = `hd;	12'd61: toneR = `hd;
                        12'd62: toneR = `hd;	12'd63: toneR = `hd;
                        
                        12'd64: toneR = `hc;	12'd65: toneR = `hc;
                        12'd66: toneR = `hc;	12'd67: toneR = `hc;
                        12'd68: toneR = `hc;	12'd69: toneR = `hc;
                        12'd70: toneR = `hc;	12'd71: toneR = `hc;
                        
                        12'd72: toneR = `hd;	12'd73: toneR = `hd;
                        12'd74: toneR = `hd;	12'd75: toneR = `hd;
                        12'd76: toneR = `hd;	12'd77: toneR = `hd;
                        12'd78: toneR = `hd;	12'd79: toneR = `hd;
                        
                        12'd80: toneR = `he;	12'd81: toneR = `he;
                        12'd82: toneR = `he;	12'd83: toneR = `he;
                        12'd84: toneR = `he;	12'd85: toneR = `he;
                        12'd86: toneR = `he;	12'd87: toneR = `he;
                        
                        12'd88: toneR = `hf;	12'd89: toneR = `hf;
                        12'd90: toneR = `hf;	12'd91: toneR = `hf;
                        12'd92: toneR = `hf;	12'd93: toneR = `hf;
                        12'd94: toneR = `hf;	12'd95: toneR = `hf;
                        
                        12'd96: toneR = `hg;	12'd97: toneR = `hg;
                        12'd98: toneR = `hg;	12'd99: toneR = `hg;
                        12'd100: toneR = `hg;	12'd101: toneR = `hg;
                        12'd102: toneR = `hg;	12'd103: toneR = `sil;
                        
                        12'd104: toneR = `hg;	12'd105: toneR = `hg;
                        12'd106: toneR = `hg;	12'd107: toneR = `hg;
                        12'd108: toneR = `hg;	12'd109: toneR = `hg;
                        12'd110: toneR = `hg;	12'd111: toneR = `sil;
                        
                        12'd112: toneR = `hg;	12'd113: toneR = `hg;
                        12'd114: toneR = `hg;	12'd115: toneR = `hg;
                        12'd116: toneR = `hg;	12'd117: toneR = `hg;
                        12'd118: toneR = `hg;	12'd119: toneR = `hg;
                        
                        12'd120: toneR = `hg;	12'd121: toneR = `hg;
                        12'd122: toneR = `hg;	12'd123: toneR = `hg;
                        12'd124: toneR = `hg;	12'd125: toneR = `hg;
                        12'd126: toneR = `hg;	12'd127: toneR = `hg;
                        
                        12'd128: toneR = `hg;	12'd129: toneR = `hg;
                        12'd130: toneR = `hg;	12'd131: toneR = `hg;
                        12'd132: toneR = `hg;	12'd133: toneR = `hg;
                        12'd134: toneR = `hg;	12'd135: toneR = `hg;
                        
                        12'd136: toneR = `he;	12'd137: toneR = `he;
                        12'd138: toneR = `he;	12'd139: toneR = `he;
                        12'd140: toneR = `he;	12'd141: toneR = `he;
                        12'd142: toneR = `he;	12'd143: toneR = `sil;
                        
                        12'd144: toneR = `he;	12'd145: toneR = `he;
                        12'd146: toneR = `he;	12'd147: toneR = `he;
                        12'd148: toneR = `he;	12'd149: toneR = `he;
                        12'd150: toneR = `he;	12'd151: toneR = `he;
                        
                        12'd152: toneR = `he;	12'd153: toneR = `he;
                        12'd154: toneR = `he;	12'd155: toneR = `he;
                        12'd156: toneR = `he;	12'd157: toneR = `he;
                        12'd158: toneR = `he;	12'd159: toneR = `he;
                        
                        12'd160: toneR = `hf;	12'd161: toneR = `hf;
                        12'd162: toneR = `hf;	12'd163: toneR = `hf;
                        12'd164: toneR = `hf;	12'd165: toneR = `hf;
                        12'd166: toneR = `hf;	12'd167: toneR = `hf;
                        
                        12'd168: toneR = `hd;	12'd169: toneR = `hd;
                        12'd170: toneR = `hd;	12'd171: toneR = `hd;
                        12'd172: toneR = `hd;	12'd173: toneR = `hd;
                        12'd174: toneR = `hd;	12'd175: toneR = `sil;
                        
                        12'd176: toneR = `hd;	12'd177: toneR = `hd;
                        12'd178: toneR = `hd;	12'd179: toneR = `hd;
                        12'd180: toneR = `hd;	12'd181: toneR = `hd;
                        12'd182: toneR = `hd;	12'd183: toneR = `hd;
                        
                        12'd184: toneR = `hd;	12'd185: toneR = `hd;
                        12'd186: toneR = `hd;	12'd187: toneR = `hd;
                        12'd188: toneR = `hd;	12'd189: toneR = `hd;
                        12'd190: toneR = `hd;	12'd191: toneR = `hd;
                        
                        12'd192: toneR = `hc;	12'd193: toneR = `hc;
                        12'd194: toneR = `hc;	12'd195: toneR = `hc;
                        12'd196: toneR = `hc;	12'd197: toneR = `hc;
                        12'd198: toneR = `hc;	12'd199: toneR = `hc;
                        
                        12'd200: toneR = `he;	12'd201: toneR = `he;
                        12'd202: toneR = `he;	12'd203: toneR = `he;
                        12'd204: toneR = `he;	12'd205: toneR = `he;
                        12'd206: toneR = `he;	12'd207: toneR = `he;
                        
                        12'd208: toneR = `hg;	12'd209: toneR = `hg;
                        12'd210: toneR = `hg;	12'd211: toneR = `hg;
                        12'd212: toneR = `hg;	12'd213: toneR = `hg;
                        12'd214: toneR = `hg;	12'd215: toneR = `sil;
                        
                        12'd216: toneR = `hg;	12'd217: toneR = `hg;
                        12'd218: toneR = `hg;	12'd219: toneR = `hg;
                        12'd220: toneR = `hg;	12'd221: toneR = `hg;
                        12'd222: toneR = `hg;	12'd223: toneR = `hg;
                        
                        12'd224: toneR = `he;	12'd225: toneR = `he;
                        12'd226: toneR = `he;	12'd227: toneR = `he;
                        12'd228: toneR = `he;	12'd229: toneR = `he;
                        12'd230: toneR = `he;	12'd231: toneR = `sil;
                        
                        12'd232: toneR = `he;	12'd233: toneR = `he;
                        12'd234: toneR = `he;	12'd235: toneR = `he;
                        12'd236: toneR = `he;	12'd237: toneR = `he;
                        12'd238: toneR = `he;	12'd239: toneR = `sil;
                        
                        12'd240: toneR = `he;	12'd241: toneR = `he;
                        12'd242: toneR = `he;	12'd243: toneR = `he;
                        12'd244: toneR = `he;	12'd245: toneR = `he;
                        12'd246: toneR = `he;	12'd247: toneR = `he;
                        
                        12'd248: toneR = `he;	12'd249: toneR = `he;
                        12'd250: toneR = `he;	12'd251: toneR = `he;
                        12'd252: toneR = `he;	12'd253: toneR = `he;
                        12'd254: toneR = `he;	12'd255: toneR = `he;
                        
                        12'd256: toneR = `hd;	12'd257: toneR = `hd;
                        12'd258: toneR = `hd;	12'd259: toneR = `hd;
                        12'd260: toneR = `hd;	12'd261: toneR = `hd;
                        12'd262: toneR = `hd;	12'd263: toneR = `sil;
                        
                        12'd264: toneR = `hd;	12'd265: toneR = `hd;
                        12'd266: toneR = `hd;	12'd267: toneR = `hd;
                        12'd268: toneR = `hd;	12'd269: toneR = `hd;
                        12'd270: toneR = `hd;	12'd271: toneR = `sil;
                        
                        12'd272: toneR = `hd;	12'd273: toneR = `hd;
                        12'd274: toneR = `hd;	12'd275: toneR = `hd;
                        12'd276: toneR = `hd;	12'd277: toneR = `hd;
                        12'd278: toneR = `hd;	12'd279: toneR = `sil;
                        
                        12'd280: toneR = `hd;	12'd281: toneR = `hd;
                        12'd282: toneR = `hd;	12'd283: toneR = `hd;
                        12'd284: toneR = `hd;	12'd285: toneR = `hd;
                        12'd286: toneR = `hd;	12'd287: toneR = `sil;
                        
                        12'd288: toneR = `hd;	12'd289: toneR = `hd;
                        12'd290: toneR = `hd;	12'd291: toneR = `hd;
                        12'd292: toneR = `hd;	12'd293: toneR = `hd;
                        12'd294: toneR = `hd;	12'd295: toneR = `hd;
                        
                        12'd296: toneR = `he;	12'd297: toneR = `he;
                        12'd298: toneR = `he;	12'd299: toneR = `he;
                        12'd300: toneR = `he;	12'd301: toneR = `he;
                        12'd302: toneR = `he;	12'd303: toneR = `he;
                        
                        12'd304: toneR = `hf;	12'd305: toneR = `hf;
                        12'd306: toneR = `hf;	12'd307: toneR = `hf;
                        12'd308: toneR = `hf;	12'd309: toneR = `hf;
                        12'd310: toneR = `hf;	12'd311: toneR = `hf;
                        
                        12'd312: toneR = `hf;	12'd313: toneR = `hf;
                        12'd314: toneR = `hf;	12'd315: toneR = `hf;
                        12'd316: toneR = `hf;	12'd317: toneR = `hf;
                        12'd318: toneR = `hf;	12'd319: toneR = `hf;
                        
                        12'd320: toneR = `he;	12'd321: toneR = `he;
                        12'd322: toneR = `he;	12'd323: toneR = `he;
                        12'd324: toneR = `he;	12'd325: toneR = `he;
                        12'd326: toneR = `he;	12'd327: toneR = `sil;
                        
                        12'd328: toneR = `he;	12'd329: toneR = `he;
                        12'd330: toneR = `he;	12'd331: toneR = `he;
                        12'd332: toneR = `he;	12'd333: toneR = `he;
                        12'd334: toneR = `he;	12'd335: toneR = `sil;
                        
                        12'd336: toneR = `he;	12'd337: toneR = `he;
                        12'd338: toneR = `he;	12'd339: toneR = `he;
                        12'd340: toneR = `he;	12'd341: toneR = `he;
                        12'd342: toneR = `he;	12'd343: toneR = `sil;
                        
                        12'd344: toneR = `he;	12'd345: toneR = `he;
                        12'd346: toneR = `he;	12'd347: toneR = `he;
                        12'd348: toneR = `he;	12'd349: toneR = `he;
                        12'd350: toneR = `he;	12'd351: toneR = `sil;
                        
                        12'd352: toneR = `he;	12'd353: toneR = `he;
                        12'd354: toneR = `he;	12'd355: toneR = `he;
                        12'd356: toneR = `he;	12'd357: toneR = `he;
                        12'd358: toneR = `he;	12'd359: toneR = `he;
                        
                        12'd360: toneR = `hf;	12'd361: toneR = `hf;
                        12'd362: toneR = `hf;	12'd363: toneR = `hf;
                        12'd364: toneR = `hf;	12'd365: toneR = `hf;
                        12'd366: toneR = `hf;	12'd367: toneR = `hf;
                        
                        12'd368: toneR = `hg;	12'd369: toneR = `hg;
                        12'd370: toneR = `hg;	12'd371: toneR = `hg;
                        12'd372: toneR = `hg;	12'd373: toneR = `hg;
                        12'd374: toneR = `hg;	12'd375: toneR = `hg;
                        
                        12'd376: toneR = `hg;	12'd377: toneR = `hg;
                        12'd378: toneR = `hg;	12'd379: toneR = `hg;
                        12'd380: toneR = `hg;	12'd381: toneR = `hg;
                        12'd382: toneR = `hg;	12'd383: toneR = `hg;
                    
                        12'd384: toneR = `hg;	12'd385: toneR = `hg;
                        12'd386: toneR = `hg;	12'd387: toneR = `hg;
                        12'd388: toneR = `hg;	12'd389: toneR = `hg;
                        12'd390: toneR = `hg;	12'd391: toneR = `hg;
                        
                        12'd392: toneR = `he;	12'd393: toneR = `he;
                        12'd394: toneR = `he;	12'd395: toneR = `he;
                        12'd396: toneR = `he;	12'd397: toneR = `he;
                        12'd398: toneR = `he;	12'd399: toneR = `sil;
                        
                        12'd400: toneR = `he;	12'd401: toneR = `he;
                        12'd402: toneR = `he;	12'd403: toneR = `he;
                        12'd404: toneR = `he;	12'd405: toneR = `he;
                        12'd406: toneR = `he;	12'd407: toneR = `he;
                        
                        12'd408: toneR = `he;	12'd409: toneR = `he;
                        12'd410: toneR = `he;	12'd411: toneR = `he;
                        12'd412: toneR = `he;	12'd413: toneR = `he;
                        12'd414: toneR = `he;	12'd415: toneR = `he;
                        
                        12'd416: toneR = `hf;	12'd417: toneR = `hf;
                        12'd418: toneR = `hf;	12'd419: toneR = `hf;
                        12'd420: toneR = `hf;	12'd421: toneR = `hf;
                        12'd422: toneR = `hf;	12'd423: toneR = `hf;
                        
                        12'd424: toneR = `hd;	12'd425: toneR = `hd;
                        12'd426: toneR = `hd;	12'd427: toneR = `hd;
                        12'd428: toneR = `hd;	12'd429: toneR = `hd;
                        12'd430: toneR = `hd;	12'd431: toneR = `sil;
                        
                        12'd432: toneR = `hd;	12'd433: toneR = `hd;
                        12'd434: toneR = `hd;	12'd435: toneR = `hd;
                        12'd436: toneR = `hd;	12'd437: toneR = `hd;
                        12'd438: toneR = `hd;	12'd439: toneR = `hd;
                        
                        12'd440: toneR = `hd;	12'd441: toneR = `hd;
                        12'd442: toneR = `hd;	12'd443: toneR = `hd;
                        12'd444: toneR = `hd;	12'd445: toneR = `hd;
                        12'd446: toneR = `hd;	12'd447: toneR = `hd;
                        
                        12'd448: toneR = `hc;	12'd449: toneR = `hc;
                        12'd450: toneR = `hc;	12'd451: toneR = `hc;
                        12'd452: toneR = `hc;	12'd453: toneR = `hc;
                        12'd454: toneR = `hc;	12'd455: toneR = `hc;
                        
                        12'd456: toneR = `he;	12'd457: toneR = `he;
                        12'd458: toneR = `he;	12'd459: toneR = `he;
                        12'd460: toneR = `he;	12'd461: toneR = `he;
                        12'd462: toneR = `he;	12'd463: toneR = `he;
                        
                        12'd464: toneR = `hg;	12'd465: toneR = `hg;
                        12'd466: toneR = `hg;	12'd467: toneR = `hg;
                        12'd468: toneR = `hg;	12'd469: toneR = `hg;
                        12'd470: toneR = `hg;	12'd471: toneR = `sil;
                        
                        12'd472: toneR = `hg;	12'd473: toneR = `hg;
                        12'd474: toneR = `hg;	12'd475: toneR = `hg;
                        12'd476: toneR = `hg;	12'd477: toneR = `hg;
                        12'd478: toneR = `hg;	12'd479: toneR = `hg;
                        
                        12'd480: toneR = `hc;	12'd481: toneR = `hc;
                        12'd482: toneR = `hc;	12'd483: toneR = `hc;
                        12'd484: toneR = `hc;	12'd485: toneR = `hc;
                        12'd486: toneR = `hc;	12'd487: toneR = `hc;
                        
                        12'd488: toneR = `hc;	12'd489: toneR = `hc;
                        12'd490: toneR = `hc;	12'd491: toneR = `hc;
                        12'd492: toneR = `hc;	12'd493: toneR = `hc;
                        12'd494: toneR = `hc;	12'd495: toneR = `hc;
                        
                        12'd496: toneR = `hc;	12'd497: toneR = `hc;
                        12'd498: toneR = `hc;	12'd499: toneR = `hc;
                        12'd500: toneR = `hc;	12'd501: toneR = `hc;
                        12'd502: toneR = `hc;	12'd503: toneR = `hc;
                    
                        12'd504: toneR = `hc;	12'd505: toneR = `hc;
                        12'd506: toneR = `hc;	12'd507: toneR = `hc;
                        12'd508: toneR = `hc;	12'd509: toneR = `hc;
                        12'd510: toneR = `hc;	12'd511: toneR = `hc;
                        default: toneR = `sil;
                    endcase
                else
                    toneR = `sil;
        end else begin // PLAY mode
            case (pressNum)
                3'd0: toneR = `sil;
                3'd1: toneR = `c;
                3'd2: toneR = `d;
                3'd3: toneR = `e;
                3'd4: toneR = `f;
                3'd5: toneR = `g;
                3'd6: toneR = `a;
                3'd7: toneR = `b;
                default: toneR = `sil;
            endcase
        end
    end

    always @(*) begin
        if(en == 1)begin
            if (_music)
            begin
                if (_play)
                    toneL = record[rdNum];
                else
                    toneL = `sil;
            end
            else
                if (_play)
                    case(ibeatNum)
                        12'd0: toneL = `hc;	    12'd1: toneL = `hc;
                        12'd2: toneL = `hc;	    12'd3: toneL = `hc;
                        12'd4: toneL = `hc;	    12'd5: toneL = `hc;
                        12'd6: toneL = `hc;	    12'd7: toneL = `hc;
                        
                        12'd8: toneL = `hc;	    12'd9: toneL = `hc;
                        12'd10: toneL = `hc;	12'd11: toneL = `hc;
                        12'd12: toneL = `hc;	12'd13: toneL = `hc;
                        12'd14: toneL = `hc;	12'd15: toneL = `hc;
                        
                        12'd16: toneL = `hc;	12'd17: toneL = `hc;
                        12'd18: toneL = `hc;	12'd19: toneL = `hc;
                        12'd20: toneL = `hc;	12'd21: toneL = `hc;
                        12'd22: toneL = `hc;	12'd23: toneL = `hc;
                        
                        12'd24: toneL = `hc;	12'd25: toneL = `hc;
                        12'd26: toneL = `hc;	12'd27: toneL = `hc;
                        12'd28: toneL = `hc;	12'd29: toneL = `hc;
                        12'd30: toneL = `hc;	12'd31: toneL = `hc;
                        
                        12'd32: toneL = `g;	    12'd33: toneL = `g;
                        12'd34: toneL = `g;	    12'd35: toneL = `g;
                        12'd36: toneL = `g;	    12'd37: toneL = `g;
                        12'd38: toneL = `g;	    12'd39: toneL = `g;
                        
                        12'd40: toneL = `g; 	12'd41: toneL = `g;
                        12'd42: toneL = `g;	    12'd43: toneL = `g;
                        12'd44: toneL = `g;	    12'd45: toneL = `g;
                        12'd46: toneL = `g;	    12'd47: toneL = `g;
                        
                        12'd48: toneL = `b;	    12'd49: toneL = `b;
                        12'd50: toneL = `b;	    12'd51: toneL = `b;
                        12'd52: toneL = `b;	    12'd53: toneL = `b;
                        12'd54: toneL = `b;	    12'd55: toneL = `b;
                        
                        12'd56: toneL = `b;	    12'd57: toneL = `b;
                        12'd58: toneL = `b;	    12'd59: toneL = `b;
                        12'd60: toneL = `b;	    12'd61: toneL = `b;
                        12'd62: toneL = `b;	    12'd63: toneL = `b;
                        
                        12'd64: toneL = `hc;	12'd65: toneL = `hc;
                        12'd66: toneL = `hc;	12'd67: toneL = `hc;
                        12'd68: toneL = `hc;	12'd69: toneL = `hc;
                        12'd70: toneL = `hc;	12'd71: toneL = `hc;
                        
                        12'd72: toneL = `hc;	12'd73: toneL = `hc;
                        12'd74: toneL = `hc;	12'd75: toneL = `hc;
                        12'd76: toneL = `hc;	12'd77: toneL = `hc;
                        12'd78: toneL = `hc;	12'd79: toneL = `hc;
                        
                        12'd80: toneL = `hc;	12'd81: toneL = `hc;
                        12'd82: toneL = `hc;	12'd83: toneL = `hc;
                        12'd84: toneL = `hc;	12'd85: toneL = `hc;
                        12'd86: toneL = `hc;	12'd87: toneL = `hc;
                        
                        12'd88: toneL = `hc;	12'd89: toneL = `hc;
                        12'd90: toneL = `hc;	12'd91: toneL = `hc;
                        12'd92: toneL = `hc;	12'd93: toneL = `hc;
                        12'd94: toneL = `hc;	12'd95: toneL = `hc;
                        
                        12'd96: toneL = `g;	    12'd97: toneL = `g;
                        12'd98: toneL = `g;	    12'd99: toneL = `g;
                        12'd100: toneL = `g;	12'd101: toneL = `g;
                        12'd102: toneL = `g;	12'd103: toneL = `g;
                        
                        12'd104: toneL = `g;	12'd105: toneL = `g;
                        12'd106: toneL = `g;	12'd107: toneL = `g;
                        12'd108: toneL = `g;	12'd109: toneL = `g;
                        12'd110: toneL = `g;	12'd111: toneL = `g;
                        
                        12'd112: toneL = `b;	12'd113: toneL = `b;
                        12'd114: toneL = `b;	12'd115: toneL = `b;
                        12'd116: toneL = `b;	12'd117: toneL = `b;
                        12'd118: toneL = `b;	12'd119: toneL = `b;
                        
                        12'd120: toneL = `b;	12'd121: toneL = `b;
                        12'd122: toneL = `b;	12'd123: toneL = `b;
                        12'd124: toneL = `b;	12'd125: toneL = `b;
                        12'd126: toneL = `b;	12'd127: toneL = `b;
                        
                        12'd128: toneL = `hc;	12'd129: toneL = `hc;
                        12'd130: toneL = `hc;	12'd131: toneL = `hc;
                        12'd132: toneL = `hc;	12'd133: toneL = `hc;
                        12'd134: toneL = `hc;	12'd135: toneL = `hc;
                        
                        12'd136: toneL = `hc;	12'd137: toneL = `hc;
                        12'd138: toneL = `hc;	12'd139: toneL = `hc;
                        12'd140: toneL = `hc;	12'd141: toneL = `hc;
                        12'd142: toneL = `hc;	12'd143: toneL = `hc;
                        
                        12'd144: toneL = `hc;	12'd145: toneL = `hc;
                        12'd146: toneL = `hc;	12'd147: toneL = `hc;
                        12'd148: toneL = `hc;	12'd149: toneL = `hc;
                        12'd150: toneL = `hc;	12'd151: toneL = `hc;
                        
                        12'd152: toneL = `hc;	12'd153: toneL = `hc;
                        12'd154: toneL = `hc;	12'd155: toneL = `hc;
                        12'd156: toneL = `hc;	12'd157: toneL = `hc;
                        12'd158: toneL = `hc;	12'd159: toneL = `hc;
                        
                        12'd160: toneL = `g;	12'd161: toneL = `g;
                        12'd162: toneL = `g;	12'd163: toneL = `g;
                        12'd164: toneL = `g;	12'd165: toneL = `g;
                        12'd166: toneL = `g;	12'd167: toneL = `g;
                        
                        12'd168: toneL = `g;	12'd169: toneL = `g;
                        12'd170: toneL = `g;	12'd171: toneL = `g;
                        12'd172: toneL = `g;	12'd173: toneL = `g;
                        12'd174: toneL = `g;	12'd175: toneL = `g;
                        
                        12'd176: toneL = `b;	12'd177: toneL = `b;
                        12'd178: toneL = `b;	12'd179: toneL = `b;
                        12'd180: toneL = `b;	12'd181: toneL = `b;
                        12'd182: toneL = `b;	12'd183: toneL = `b;
                        
                        12'd184: toneL = `b;	12'd185: toneL = `b;
                        12'd186: toneL = `b;	12'd187: toneL = `b;
                        12'd188: toneL = `b;	12'd189: toneL = `b;
                        12'd190: toneL = `b;	12'd191: toneL = `b;
                        
                        12'd192: toneL = `hc;	12'd193: toneL = `hc;
                        12'd194: toneL = `hc;	12'd195: toneL = `hc;
                        12'd196: toneL = `hc;	12'd197: toneL = `hc;
                        12'd198: toneL = `hc;	12'd199: toneL = `hc;
                        
                        12'd200: toneL = `hc;	12'd201: toneL = `hc;
                        12'd202: toneL = `hc;	12'd203: toneL = `hc;
                        12'd204: toneL = `hc;	12'd205: toneL = `hc;
                        12'd206: toneL = `hc;	12'd207: toneL = `hc;
                        
                        12'd208: toneL = `g;	12'd209: toneL = `g;
                        12'd210: toneL = `g;	12'd211: toneL = `g;
                        12'd212: toneL = `g;	12'd213: toneL = `g;
                        12'd214: toneL = `g;	12'd215: toneL = `g;
                        
                        12'd216: toneL = `g;	12'd217: toneL = `g;
                        12'd218: toneL = `g;	12'd219: toneL = `g;
                        12'd220: toneL = `g;	12'd221: toneL = `g;
                        12'd222: toneL = `g;	12'd223: toneL = `g;
                        
                        12'd224: toneL = `e;	12'd225: toneL = `e;
                        12'd226: toneL = `e;	12'd227: toneL = `e;
                        12'd228: toneL = `e;	12'd229: toneL = `e;
                        12'd230: toneL = `e;	12'd231: toneL = `e;
                        
                        12'd232: toneL = `e;	12'd233: toneL = `e;
                        12'd234: toneL = `e;	12'd235: toneL = `e;
                        12'd236: toneL = `e;	12'd237: toneL = `e;
                        12'd238: toneL = `e;	12'd239: toneL = `e;
                        
                        12'd240: toneL = `c;	12'd241: toneL = `c;
                        12'd242: toneL = `c;	12'd243: toneL = `c;
                        12'd244: toneL = `c;	12'd245: toneL = `c;
                        12'd246: toneL = `c;	12'd247: toneL = `c;
                        
                        12'd248: toneL = `c;	12'd249: toneL = `c;
                        12'd250: toneL = `c;	12'd251: toneL = `c;
                        12'd252: toneL = `c;	12'd253: toneL = `c;
                        12'd254: toneL = `c;	12'd255: toneL = `c;
                        
                        12'd256: toneL = `g;	12'd257: toneL = `g;
                        12'd258: toneL = `g;	12'd259: toneL = `g;
                        12'd260: toneL = `g;	12'd261: toneL = `g;
                        12'd262: toneL = `g;	12'd263: toneL = `g;
                        
                        12'd264: toneL = `g;	12'd265: toneL = `g;
                        12'd266: toneL = `g;	12'd267: toneL = `g;
                        12'd268: toneL = `g;	12'd269: toneL = `g;
                        12'd270: toneL = `g;	12'd271: toneL = `g;
                        
                        12'd272: toneL = `g;	12'd273: toneL = `g;
                        12'd274: toneL = `g;	12'd275: toneL = `g;
                        12'd276: toneL = `g;	12'd277: toneL = `g;
                        12'd278: toneL = `g;	12'd279: toneL = `g;
                        
                        12'd280: toneL = `g;	12'd281: toneL = `g;
                        12'd282: toneL = `g;	12'd283: toneL = `g;
                        12'd284: toneL = `g;	12'd285: toneL = `g;
                        12'd286: toneL = `g;	12'd287: toneL = `g;
                        
                        12'd288: toneL = `f;	12'd289: toneL = `f;
                        12'd290: toneL = `f;	12'd291: toneL = `f;
                        12'd292: toneL = `f;	12'd293: toneL = `f;
                        12'd294: toneL = `f;	12'd295: toneL = `f;
                        
                        12'd296: toneL = `f;	12'd297: toneL = `f;
                        12'd298: toneL = `f;	12'd299: toneL = `f;
                        12'd300: toneL = `f;	12'd301: toneL = `f;
                        12'd302: toneL = `f;	12'd303: toneL = `f;
                        
                        12'd304: toneL = `d;	12'd305: toneL = `d;
                        12'd306: toneL = `d;	12'd307: toneL = `d;
                        12'd308: toneL = `d;	12'd309: toneL = `d;
                        12'd310: toneL = `d;	12'd311: toneL = `d;
                        
                        12'd312: toneL = `d;	12'd313: toneL = `d;
                        12'd314: toneL = `d;	12'd315: toneL = `d;
                        12'd316: toneL = `d;	12'd317: toneL = `d;
                        12'd318: toneL = `d;	12'd319: toneL = `d;
                        
                        12'd320: toneL = `c;	12'd321: toneL = `c;
                        12'd322: toneL = `c;	12'd323: toneL = `c;
                        12'd324: toneL = `c;	12'd325: toneL = `c;
                        12'd326: toneL = `c;	12'd327: toneL = `c;
                        
                        12'd328: toneL = `c;	12'd329: toneL = `c;
                        12'd330: toneL = `c;	12'd331: toneL = `c;
                        12'd332: toneL = `c;	12'd333: toneL = `c;
                        12'd334: toneL = `c;	12'd335: toneL = `c;
                        
                        12'd336: toneL = `c;	12'd337: toneL = `c;
                        12'd338: toneL = `c;	12'd339: toneL = `c;
                        12'd340: toneL = `c;	12'd341: toneL = `c;
                        12'd342: toneL = `c;	12'd343: toneL = `c;
                        
                        12'd344: toneL = `c;	12'd345: toneL = `c;
                        12'd346: toneL = `c;	12'd347: toneL = `c;
                        12'd348: toneL = `c;	12'd349: toneL = `c;
                        12'd350: toneL = `c;	12'd351: toneL = `c;
                        
                        12'd352: toneL = `g;	12'd353: toneL = `g;
                        12'd354: toneL = `g;	12'd355: toneL = `g;
                        12'd356: toneL = `g;	12'd357: toneL = `g;
                        12'd358: toneL = `g;	12'd359: toneL = `g;
                        
                        12'd360: toneL = `g;	12'd361: toneL = `g;
                        12'd362: toneL = `g;	12'd363: toneL = `g;
                        12'd364: toneL = `g;	12'd365: toneL = `g;
                        12'd366: toneL = `g;	12'd367: toneL = `g;
                        
                        12'd368: toneL = `b;	12'd369: toneL = `b;
                        12'd370: toneL = `b;	12'd371: toneL = `b;
                        12'd372: toneL = `b;	12'd373: toneL = `b;
                        12'd374: toneL = `b;	12'd375: toneL = `b;
                        
                        12'd376: toneL = `b;	12'd377: toneL = `b;
                        12'd378: toneL = `b;	12'd379: toneL = `b;
                        12'd380: toneL = `b;	12'd381: toneL = `b;
                        12'd382: toneL = `b;	12'd383: toneL = `b;
                        
                        12'd384: toneL = `hc;	12'd385: toneL = `hc;
                        12'd386: toneL = `hc;	12'd387: toneL = `hc;
                        12'd388: toneL = `hc;	12'd389: toneL = `hc;
                        12'd390: toneL = `hc;	12'd391: toneL = `hc;
                        
                        12'd392: toneL = `hc;	12'd393: toneL = `hc;
                        12'd394: toneL = `hc;	12'd395: toneL = `hc;
                        12'd396: toneL = `hc;	12'd397: toneL = `hc;
                        12'd398: toneL = `hc;	12'd399: toneL = `hc;
                        
                        12'd400: toneL = `hc;	12'd401: toneL = `hc;
                        12'd402: toneL = `hc;	12'd403: toneL = `hc;
                        12'd404: toneL = `hc;	12'd405: toneL = `hc;
                        12'd406: toneL = `hc;	12'd407: toneL = `hc;
                        
                        12'd408: toneL = `hc;	12'd409: toneL = `hc;
                        12'd410: toneL = `hc;	12'd411: toneL = `hc;
                        12'd412: toneL = `hc;	12'd413: toneL = `hc;
                        12'd414: toneL = `hc;	12'd415: toneL = `hc;
                        
                        12'd416: toneL = `g;	12'd417: toneL = `g;
                        12'd418: toneL = `g;	12'd419: toneL = `g;
                        12'd420: toneL = `g;	12'd421: toneL = `g;
                        12'd422: toneL = `g;	12'd423: toneL = `g;
                    
                        12'd424: toneL = `g;	12'd425: toneL = `g;
                        12'd426: toneL = `g;	12'd427: toneL = `g;
                        12'd428: toneL = `g;	12'd429: toneL = `g;
                        12'd430: toneL = `g;	12'd431: toneL = `g;
                        
                        12'd432: toneL = `b;	12'd433: toneL = `b;
                        12'd434: toneL = `b;	12'd435: toneL = `b;
                        12'd436: toneL = `b;	12'd437: toneL = `b;
                        12'd438: toneL = `b;	12'd439: toneL = `b;
                        
                        12'd440: toneL = `b;	12'd441: toneL = `b;
                        12'd442: toneL = `b;	12'd443: toneL = `b;
                        12'd444: toneL = `b;	12'd445: toneL = `b;
                        12'd446: toneL = `b;	12'd447: toneL = `b;
                        
                        12'd448: toneL = `hc;	12'd449: toneL = `hc;
                        12'd450: toneL = `hc;	12'd451: toneL = `hc;
                        12'd452: toneL = `hc;	12'd453: toneL = `hc;
                        12'd454: toneL = `hc;	12'd455: toneL = `hc;
                        
                        12'd456: toneL = `hc;	12'd457: toneL = `hc;
                        12'd458: toneL = `hc;	12'd459: toneL = `hc;
                        12'd460: toneL = `hc;	12'd461: toneL = `hc;
                        12'd462: toneL = `hc;	12'd463: toneL = `hc;
                    
                        12'd464: toneL = `g;	12'd465: toneL = `g;
                        12'd466: toneL = `g;	12'd467: toneL = `g;
                        12'd468: toneL = `g;	12'd469: toneL = `g;
                        12'd470: toneL = `g;	12'd471: toneL = `g;
                        
                        12'd472: toneL = `g;	12'd473: toneL = `g;
                        12'd474: toneL = `g;	12'd475: toneL = `g;
                        12'd476: toneL = `g;	12'd477: toneL = `g;
                        12'd478: toneL = `g;	12'd479: toneL = `g;
                        
                        12'd480: toneL = `c;	12'd481: toneL = `c;
                        12'd482: toneL = `c;	12'd483: toneL = `c;
                        12'd484: toneL = `c;	12'd485: toneL = `c;
                        12'd486: toneL = `c;	12'd487: toneL = `c;
                        
                        12'd488: toneL = `c;	12'd489: toneL = `c;
                        12'd490: toneL = `c;	12'd491: toneL = `c;
                        12'd492: toneL = `c;	12'd493: toneL = `c;
                        12'd494: toneL = `c;	12'd495: toneL = `c;
                        
                        12'd496: toneL = `c;	12'd497: toneL = `c;
                        12'd498: toneL = `c;	12'd499: toneL = `c;
                        12'd500: toneL = `c;	12'd501: toneL = `c;
                        12'd502: toneL = `c;	12'd503: toneL = `c;
                        
                        12'd504: toneL = `c;	12'd505: toneL = `c;
                        12'd506: toneL = `c;	12'd507: toneL = `c;
                        12'd508: toneL = `c;	12'd509: toneL = `c;
                        12'd510: toneL = `c;	12'd511: toneL = `c;
                        default : toneL = `sil;
                    endcase
                else
                    toneL = `sil;
        end
        else begin
            case (pressNum)
                3'd0: toneL = `sil;
                3'd1: toneL = `c;
                3'd2: toneL = `d;
                3'd3: toneL = `e;
                3'd4: toneL = `f;
                3'd5: toneL = `g;
                3'd6: toneL = `a;
                3'd7: toneL = `b;
                default: toneL = `sil;
            endcase
        end
    end
endmodule

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
    player_control #(.LEN(512)) playerCtrl_00 ( 
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
