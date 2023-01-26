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
                        if (rd + 1 == 250)
                            next_rd = 0;
                        else 
                            next_rd = rd + 1;
                    else
                        if (rd + 1 == 250 && count == 1)
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
