module clkDivTo1 (
    input wire clk,
    output reg clk_div
);
    reg [27:0] counter = 28'd0;
    parameter DIVISOR = 100000000;
    
    always @(posedge clk)
    begin
        
        if (counter >= (DIVISOR - 1))
            counter <= 28'd0;
        else
            counter <= counter + 28'd1;
        clk_div <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
    end
endmodule

module clkDivTo1000 (
    input wire clk,
    output reg clk_div
);
    reg [27:0] counter = 28'd0;
    parameter DIVISOR = 100000;
    
    always @(posedge clk)
    begin
        
        if (counter >= (DIVISOR - 1))
            counter <= 28'd0;
        else
            counter <= counter + 28'd1;
        clk_div <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
    end
endmodule

module lab6(
	input wire clk,
	input wire rst,
	input wire start,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	output reg [15:0] LED,
	output reg [3:0] DIGIT,
	output reg [6:0] DISPLAY
	);
	
	// 1Hz clk
	wire clk1Hz;
    clkDivTo1 c1 (.clk(clk), .clk_div(clk1Hz));
    
    // 1000Hz clk
    wire clk1000Hz;
    clkDivTo1000 c1000 (.clk(clk), .clk_div(clk1000Hz));
	
	// debounce
	wire db_rst;
    debounce db1 (.clk(clk), .pb(rst), .pb_debounced(db_rst));
    wire db_start;
	debounce db2 (.clk(clk), .pb(start), .pb_debounced(db_start));
	
	// one_pulse
	wire op_rst;
	OnePulse op1 (.clock(clk1000Hz), .signal(db_rst), .signal_single_pulse(op_rst));
	wire op_start;
	OnePulse op2 (.clock(clk1000Hz), .signal(db_start), .signal_single_pulse(op_start));
	
	// state
	parameter INIT = 3'd0;
	parameter GAME = 3'd1;
	parameter FINAL = 3'd2;
	reg [2:0] state, next_state;
	
	// counter
	reg [9:0] counter, next_counter;
	
	// large_counter
	reg [27:0] large_counter, next_large_counter;
	
	// BCD
	reg [3:0] BCD3, BCD2, BCD1, BCD0, next_BCD3, next_BCD2, next_BCD1, next_BCD0;
	
	// value
	reg [3:0] value;
	
	// next_LED
	reg [15:0] next_LED;
	
	// lose
	reg lose, next_lose;
	
	// win 
	reg win, next_win;
	
	// pressed
	reg pressed, next_pressed;
	
	// pressed2
	reg pressed2, next_pressed2;
	
	    parameter [8:0] KEY_CODES [0:19] = {
		9'b0_0100_0101,	// 0 => 45
		9'b0_0001_0110,	// 1 => 16
		9'b0_0001_1110,	// 2 => 1E
		9'b0_0010_0110,	// 3 => 26
		9'b0_0010_0101,	// 4 => 25
		9'b0_0010_1110,	// 5 => 2E
		9'b0_0011_0110,	// 6 => 36
		9'b0_0011_1101,	// 7 => 3D
		9'b0_0011_1110,	// 8 => 3E
		9'b0_0100_0110,	// 9 => 46
		
		9'b0_0111_0000, // right_0 => 70
		9'b0_0110_1001, // right_1 => 69
		9'b0_0111_0010, // right_2 => 72
		9'b0_0111_1010, // right_3 => 7A
		9'b0_0110_1011, // right_4 => 6B
		9'b0_0111_0011, // right_5 => 73
		9'b0_0111_0100, // right_6 => 74
		9'b0_0110_1100, // right_7 => 6C
		9'b0_0111_0101, // right_8 => 75
		9'b0_0111_1101  // right_9 => 7D
	};
    
    wire [511:0] key_down;
	wire [8:0] last_change;
	wire been_ready;
	
    KeyboardDecoder key_de (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(op_rst),
		.clk(clk)
	);
	
	always @(posedge clk1000Hz, posedge op_rst)
	begin
	   if (op_rst)
	       state <= INIT;
	   else 
	       state <= next_state;
	end
	
	always @*
	begin
	   case(state)
	       INIT:
	       begin
	           if (op_start)
	               next_state = GAME;
	           else
	               next_state = INIT;
	       end
	       GAME:
	       begin
	           if ((BCD3 == 0 && BCD2 == 0 && !lose) || (BCD1 == 1 && BCD0 == 0))
	               next_state = FINAL;
	           else
	               next_state = GAME;
	       end
	       FINAL:
	       begin
	           if (op_start)
	               next_state = GAME;
	           else
	               next_state = FINAL;
	       end
	       default:
	           next_state = INIT; 
	   endcase
	end
	
	always @(posedge clk1000Hz, posedge op_rst)
	begin
	   if (op_rst)
	       counter <= 0;
	   else
	       counter <= next_counter;
	end
	
	always @*
	begin
	    case(state)
	        GAME:
	        begin
                if (counter == 10'd1000)
                    next_counter = 0;
                else
                    next_counter = counter + 1;
            end
            default:
                next_counter = 0;   
	    endcase
	end

	always @(posedge clk1000Hz, posedge op_rst)
	begin
	   if (op_rst)
	       lose <= 0;
	   else
	       lose <= next_lose;
	end
	
	always @*
	begin
	   case(state)
	       INIT:
	           next_lose = 0;
	       GAME:
	       begin
	           if (BCD3 == 0 && BCD2 == 0)
	               next_lose = 1;
	           else
	               next_lose = 0;
	       end
	       default:
	           next_lose = lose;
	   endcase
	end
	
	always @(posedge clk1000Hz, posedge op_rst)
	begin
	   if (op_rst)
	       win <= 0;
	   else
	       win <= next_win;
	end
	
	always @*
	begin
	   case(state)
	       GAME:
	       begin
	           if (BCD1 == 1 && BCD0 == 0)
	               next_win = 1;
	           else
	               next_win = 0;
	       end
	       default:
	           next_win = win;
	   endcase
	end
	
	always @(posedge clk, posedge op_rst)
	begin
	   if (op_rst)
	       pressed <= 0;
	   else
	       pressed <= next_pressed;
	end
	
	always @*
	begin
	    case(state)
	        GAME:
	        begin
	            if (key_down[KEY_CODES[1]] || key_down[KEY_CODES[2]] || key_down[KEY_CODES[3]] ||
	                key_down[KEY_CODES[4]] || key_down[KEY_CODES[5]] || key_down[KEY_CODES[6]] ||
	                key_down[KEY_CODES[7]] || key_down[KEY_CODES[8]] || key_down[KEY_CODES[9]])
                    next_pressed = 1;
                else 
                    next_pressed = 0;
	        end
	        default:
	            next_pressed = pressed;
	    endcase
	end
	
	always @(posedge clk1000Hz, posedge op_rst)
	begin
	   if (op_rst)
	       pressed2 <= 0;
	   else
	       pressed2 <= next_pressed2;
	end
	
	always @*
	begin
	    case(state)
	        GAME:
	        begin
	            if (key_down[KEY_CODES[1]] || key_down[KEY_CODES[2]] || key_down[KEY_CODES[3]] ||
	                key_down[KEY_CODES[4]] || key_down[KEY_CODES[5]] || key_down[KEY_CODES[6]] ||
	                key_down[KEY_CODES[7]] || key_down[KEY_CODES[8]] || key_down[KEY_CODES[9]])
                    next_pressed2 = 1;
                else 
                    next_pressed2 = 0;
	        end
	        default:
	            next_pressed2 = pressed2;
	    endcase
	end
	
	always @(posedge clk1000Hz, posedge op_rst)
	begin
	   if (op_rst)
	   begin
	       BCD3 = 4'd10;
	       BCD2 = 4'd10;
	   end
	   else
	   begin
	       BCD3 = next_BCD3;
	       BCD2 = next_BCD2;
	   end
	end
	
	always @*
	begin
	   case(state)
	       INIT:
	       begin
	           next_BCD3 = 4'd10;
	           next_BCD2 = 4'd10;
	       end
	       GAME:
	       begin 
	           if (BCD3 == 4'd10 && BCD2 == 4'd10)
	           begin
	               next_BCD3 = 4'd3;
	               next_BCD2 = 4'd0;
	           end 
	           else if (win)
	           begin
	               next_BCD3 = 4'd3;
	               next_BCD2 = 4'd0;
	           end
	           else if (lose)
	           begin
	               next_BCD3 = 4'd3;
	               next_BCD2 = 4'd0;
	           end
	           else
	           begin
                   if (BCD2 == 4'd0 && counter == 10'd1000)
                   begin
                       next_BCD2 = 4'd9;
                       if (BCD3 == 4'd0 && counter == 10'd1000)
                           next_BCD3 = 4'd9;
                       else if (counter == 10'd1000)
                           next_BCD3 = BCD3 - 1;
                       else 
                           next_BCD3 = BCD3;
                   end                    
                   else if (counter == 10'd1000)
                   begin
                       next_BCD2 = BCD2 - 1;
                       next_BCD3 = BCD3;
                   end  
                   else
                   begin
                       next_BCD2 = BCD2;
                       next_BCD3 = BCD3;
                   end                              
	           end
	       end
	       FINAL:
	       begin
	           if (BCD1 == 4'd12 && BCD0 == 4'd13) // win
	           begin
	               next_BCD3 = 4'd10;
	               next_BCD2 = 4'd11;
	           end
	           else //lose
	           begin
	               next_BCD3 = 4'd0;
	               next_BCD2 = 4'd0;
	           end
	       end
	   endcase
	end
    
    always @(posedge clk, posedge op_rst)
    begin
        if (op_rst)
        begin
            BCD1 <= 4'd10;
            BCD0 <= 4'd10;
        end
        else
        begin
            BCD1 <= next_BCD1;
            BCD0 <= next_BCD0;
        end
    end
    
    always @*
    begin
        case(state)
            INIT:
            begin
                next_BCD1 = 4'd10;
	            next_BCD0 = 4'd10;
            end
            GAME:
            begin
                if (BCD1 == 4'd10 && BCD0 == 4'd10)
                begin
                    next_BCD1 = 4'd0;
	                next_BCD0 = 4'd0;
                end
                else if (win)
                begin
                    next_BCD1 = 4'd0;
	                next_BCD0 = 4'd0;
                end
                else if (lose)
	            begin
	                next_BCD1 = 4'd0;
	                next_BCD0 = 4'd0;
	            end
                else
                begin
                    if (been_ready && ((LED[15] && key_down[last_change] && last_change == KEY_CODES[1]) ||
                                       (LED[14] && key_down[last_change] && last_change == KEY_CODES[2]) ||
                                       (LED[13] && key_down[last_change] && last_change == KEY_CODES[3]) ||
                                       (LED[12] && key_down[last_change] && last_change == KEY_CODES[4]) ||
                                       (LED[11] && key_down[last_change] && last_change == KEY_CODES[5]) ||
                                       (LED[10] && key_down[last_change] && last_change == KEY_CODES[6]) ||
                                       (LED[9] && key_down[last_change] && last_change == KEY_CODES[7]) ||
                                       (LED[8] && key_down[last_change] && last_change == KEY_CODES[8]) ||
                                       (LED[7] && key_down[last_change] && last_change == KEY_CODES[9])) && !pressed)
                    begin
                        if (BCD0 == 4'd9)
                        begin
                            next_BCD0 = 0;
                            if (BCD1 == 4'd9)
                                next_BCD1 = 0;
                            else
                                next_BCD1 = BCD1 + 1;
                        end
                        else
                        begin
                            next_BCD0 = BCD0 + 1;
                            next_BCD1 = BCD1;
                        end
                    end
                    else
                    begin
                        next_BCD1 = BCD1;
                        next_BCD0 = BCD0;
                    end
                end
            end
            FINAL:
            begin
                if (BCD1 == 1 && BCD0 == 0) // win
                begin
                    next_BCD1 = 4'd12;
	                next_BCD0 = 4'd13;
	            end
	            else // lose
	            begin 
	                next_BCD1 = BCD1;
	                next_BCD0 = BCD0;
	            end
            end
        endcase
    end
    
    always @(posedge clk1000Hz, posedge op_rst)
    begin
        if (op_rst)
            LED[15:0] <= 0;
        else
            LED[15:0] <= next_LED[15:0];
    end

    always @*
    begin
        case(state)
            INIT:
            begin
                next_LED[15:0] = 0;
            end
            GAME:
            begin
                if (LED == 0)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15:7] = 9'b110010101;
                end
                else if (win)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15:7] = 9'b110010101;
                end
                else if (lose)
	            begin
	                next_LED[6:0] = 0;
	                next_LED[15:7] = 9'b110010101;
	            end
	            else if (counter == 10'd1000)
                begin      
                    next_LED[6:0] = 0;
                    next_LED[14:7] = LED[15:8];
                    next_LED[15] = LED[8] ^ LED[7];
                end                      
                else if (LED[15] && key_down[last_change] && last_change == KEY_CODES[1] && !pressed2)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15] = 0;
                    next_LED[14:7] = LED[14:7];
                end 
                else if (LED[14] && key_down[last_change] && last_change == KEY_CODES[2] && !pressed2)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15] = LED[15];
                    next_LED[14] = 0;
                    next_LED[13:7] = LED[13:7];
                end
                else if (LED[13] && key_down[last_change] && last_change == KEY_CODES[3] && !pressed2)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15:14] = LED[15:14];
                    next_LED[13] = 0;
                    next_LED[12:7] = LED[12:7];
                end
                else if (LED[12] && key_down[last_change] && last_change == KEY_CODES[4] && !pressed2)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15:13] = LED[15:13];
                    next_LED[12] = 0;
                    next_LED[11:7] = LED[11:7];
                end
                else if (LED[11] && key_down[last_change] && last_change == KEY_CODES[5] && !pressed2)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15:12] = LED[15:12];
                    next_LED[11] = 0;
                    next_LED[10:7] = LED[10:7];
                end
                else if (LED[10] && key_down[last_change] && last_change == KEY_CODES[6] && !pressed2)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15:11] = LED[15:11];
                    next_LED[10] = 0;
                    next_LED[9:7] = LED[9:7];
                end
                else if (LED[9] && key_down[last_change] && last_change == KEY_CODES[7] && !pressed2)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15:10] = LED[15:10];
                    next_LED[9] = 0;
                    next_LED[8:7] = LED[8:7];
                end
                else if (LED[8] && key_down[last_change] && last_change == KEY_CODES[8] && !pressed2)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15:9] = LED[15:9];
                    next_LED[8] = 0;
                    next_LED[7] = LED[7];
                end
                else if (LED[7] && key_down[last_change] && last_change == KEY_CODES[9] && !pressed2)
                begin
                    next_LED[6:0] = 0;
                    next_LED[15:8] = LED[15:8];
                    next_LED[7] = 0;
                end
                else
                    next_LED = LED; 
            end
            FINAL:
            begin
                next_LED[15:0] = 16'b1111_1111_1111_1111;
            end
        endcase
    end
    
    always @(posedge clk1000Hz)
    begin
        case(DIGIT)
            4'b1110:
            begin
                value = BCD1;
                DIGIT = 4'b1101;
            end
            4'b1101:
            begin
                value = BCD2;
                DIGIT = 4'b1011;
            end
            4'b1011:
            begin
                value = BCD3;
                DIGIT = 4'b0111;
            end
            4'b0111:
            begin
                value = BCD0;
                DIGIT = 4'b1110;
            end
            default:
            begin
                value = BCD0;
                DIGIT = 4'b1110;
            end
        endcase
    end
    
    always @*
    begin
        case(value)
            4'd0:
                DISPLAY = 7'b100_0000;
            4'd1:
                DISPLAY = 7'b111_1001;
            4'd2:
                DISPLAY = 7'b010_0100;
            4'd3:
                DISPLAY = 7'b011_0000;
            4'd4:
                DISPLAY = 7'b001_1001;
            4'd5:
                DISPLAY = 7'b001_0010;
            4'd6:
                DISPLAY = 7'b000_0010;
            4'd7:
                DISPLAY = 7'b111_1000;
            4'd8:
                DISPLAY = 7'b000_0000;
            4'd9:
                DISPLAY = 7'b001_0000;
            4'd10: // initial
                DISPLAY = 7'b011_1111;
            4'd11: // w
                DISPLAY = 7'b110_0010;
            4'd12: // i
                DISPLAY = 7'b100_1111;
            4'd13: // n
                DISPLAY = 7'b100_1000;
            default:
                DISPLAY = 7'b111_1111;
        endcase
    end
	
endmodule
