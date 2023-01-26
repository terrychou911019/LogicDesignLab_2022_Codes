module clkDiv10 (
    input wire clk,
    output reg clk_div
);
    reg [27:0] counter = 28'd0;
    parameter DIVISOR = 10000000;
    
    always @(posedge clk)
    begin
        
        if (counter >= (DIVISOR - 1))
            counter <= 28'd0;
        else
            counter <= counter + 28'd1;
        clk_div <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
    end
endmodule

module lab4_2 ( 
    input wire clk,
    input wire rst,
    input wire start,
    input wire direction,
    input wire increase,
    input wire decrease,
    input wire select,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY,
    output reg max,
    output reg min,
    output reg d2,
    output reg d1,
    output reg d0
 ); 

    // 1000Hz clock
    wire clk1000Hz;
    clock_divider #(.n(17)) c1000 (.clk(clk), .clk_div(clk1000Hz));
    
    // 10Hz clock
    wire clk10Hz;
    clkDiv10 c10 (.clk(clk), .clk_div(clk10Hz));
    
    // debounce
    wire db_start;
    debounce db1 (.clk(clk), .pb(start), .pb_debounced(db_start));
    wire db_direction;
    debounce db2 (.clk(clk), .pb(direction), .pb_debounced(db_direction));
    wire db_increase;
    debounce db3 (.clk(clk), .pb(increase), .pb_debounced(db_increase));
    wire db_decrease;
    debounce db4 (.clk(clk), .pb(decrease), .pb_debounced(db_decrease));
    wire db_select;
    debounce db5 (.clk(clk), .pb(select), .pb_debounced(db_select));
    
    // one_pulse
    wire op_start;
    one_pulse op1 (.clk(clk1000Hz), .pb_in(db_start), .pb_out(op_start));
    wire op_direction;
    one_pulse op2 (.clk(clk1000Hz), .pb_in(db_direction), .pb_out(op_direction));
    wire op_increase;
    one_pulse op3 (.clk(clk10Hz), .pb_in(db_increase), .pb_out(op_increase));
    wire op_decrease;
    one_pulse op4 (.clk(clk10Hz), .pb_in(db_decrease), .pb_out(op_decrease));
    wire op_select;
    one_pulse op5 (.clk(clk1000Hz), .pb_in(db_select), .pb_out(op_select));
    
    // state
    parameter INIT = 3'd0;
    parameter STOP = 3'd1;
    parameter COUNT = 3'd2;
    reg [2:0] state = 0, next_state = 0;
    
    // current direction
    reg dir, next_dir; // 1 for up, 0 for down
    
    // BCD
    reg [3:0] BCD3, BCD2, BCD1, BCD0, next_BCD3, next_BCD2, next_BCD1, next_BCD0;
    
    //  value
    reg [3:0] value;
    
    // max, min
    reg next_max, next_min;
    
    always @(posedge clk1000Hz, posedge rst)
    begin
        if (rst)
            state <= 0;
        else 
            state <= next_state;
    end
    
    always @*
    begin
        case(state)
            INIT:
                if (op_start)
                    next_state = STOP;
                else 
                    next_state = INIT;
            STOP:
                if (op_start)
                    next_state = COUNT;
                else
                    next_state = STOP;
            COUNT:
               if (op_start)
                   next_state = STOP;
               else
                   next_state = COUNT;
            default:
                next_state = state;
        endcase
    end
    
    always @(posedge clk1000Hz, posedge rst)
    begin
        if (rst)
            dir <= 1;
        else 
            dir <= next_dir;
    end
    
    always @*
    begin
        case(state)
            INIT:
                next_dir = 1;
            COUNT:
                if (op_direction)
                    next_dir = ~dir;
                else 
                    next_dir = dir;
            default:
                next_dir = dir;
        endcase
    end
    
    always@(posedge clk10Hz, posedge rst)
    begin
        if (rst)
        begin
            BCD3 <= 4'd10;
            BCD2 <= 4'd10;
            BCD1 <= 4'd10;
            BCD0 <= 4'd10;
        end
        else 
        begin
            BCD3 <= next_BCD3;
            BCD2 <= next_BCD2;
            BCD1 <= next_BCD1;
            BCD0 <= next_BCD0;
        end
    end
    
    always @*
    begin
        case(state)
            INIT:
            begin
                next_BCD3 = 4'd10;
                next_BCD2 = 4'd10;
                next_BCD1 = 4'd10;
                next_BCD0 = 4'd10;
            end
            STOP:
            begin 
                if (BCD3 == 4'd10 && BCD2 == 4'd10 && BCD1 == 4'd10 && BCD0 == 4'd10)
                begin
                    next_BCD3 = 4'd10;
                    next_BCD2 = 4'd0;
                    next_BCD1 = 4'd5;
                    next_BCD0 = 4'd0;
                end
                else
                begin
                    if (op_increase)
                    begin
                        if (d0)
                        begin
                            next_BCD1 = BCD1;
                            next_BCD2 = BCD2;
                            if (BCD0 == 4'd9)
                                next_BCD0 = 4'd0;
                            else
                                next_BCD0 = BCD0 + 1;
                        end
                        else if (d1)
                        begin
                            next_BCD2 = BCD2;
                            next_BCD0 = BCD0;
                            if (BCD1 == 4'd9)
                                next_BCD1 = 4'd0;
                            else
                                next_BCD1 = BCD1 + 1;
                        end
                        else if (d2)
                        begin
                            next_BCD1 = BCD1;
                            next_BCD0 = BCD0;
                            if (BCD2 == 4'd9)
                                next_BCD2 = 4'd0;
                            else
                                next_BCD2 = BCD2 + 1;
                        end
                    end
                    else if (op_decrease)
                    begin
                        if (d0)
                        begin
                            next_BCD1 = BCD1;
                            next_BCD2 = BCD2;
                            if (BCD0 == 4'd0)
                                next_BCD0 = 4'd9;
                            else
                                next_BCD0 = BCD0 - 1;
                        end
                        else if (d1)
                        begin   
                            next_BCD0 = BCD0;
                            next_BCD2 = BCD2;
                            if (BCD1 == 4'd0)
                                next_BCD1 = 4'd9;
                            else
                                next_BCD1 = BCD1 - 1;
                        end
                        else if (d2)
                        begin
                            next_BCD1 = BCD1;
                            next_BCD0 = BCD0;
                            if (BCD2 == 4'd0)
                                next_BCD2 = 4'd9;
                            else
                                next_BCD2 = BCD2 - 1;
                        end
                    end
                    else
                    begin
                        next_BCD0 = BCD0;
                        next_BCD1 = BCD1;
                        next_BCD2 = BCD2;
                        if (direction && dir)
                        begin
                            next_BCD3 = 4'd11;
                        end
                        else if (direction && !dir)
                        begin
                            next_BCD3 = 4'd12;
                        end
                        else
                            next_BCD3 = 4'd10;
                    end
                end
            end
            COUNT:
            begin
                if (dir && BCD2 == 4'd9 && BCD1 == 4'd9 && BCD0 == 4'd9)
                begin
                    next_BCD3 = 4'd11;
                    next_BCD2 = BCD2;
                    next_BCD1 = BCD1;
                    next_BCD0 = BCD0;
                end
                else if (!dir && BCD2 == 4'd0 && BCD1 == 4'd0 && BCD0 == 4'd0)
                begin
                    next_BCD3 = 4'd12;
                    next_BCD2 = BCD2;
                    next_BCD1 = BCD1;
                    next_BCD0 = BCD0;
                end
                else
                begin
                    if (dir)
                    begin
                        next_BCD3 = 4'd11;
                        if (BCD0 == 4'd9)
                        begin
                            next_BCD0 = 4'd0;
                            if (BCD1 == 4'd9)
                            begin
                                next_BCD1 = 4'd0;
                                if (BCD2 == 4'd9)
                                begin
                                    next_BCD2 = 4'd0; 
                                end
                                else 
                                begin
                                    next_BCD2 = BCD2 + 1;
                                end
                            end
                            else 
                            begin
                                next_BCD1 = BCD1 + 1;
                                next_BCD2 = BCD2;
                            end
                        end
                        else
                        begin
                            next_BCD0 = BCD0 + 1;
                            next_BCD1 = BCD1;
                            next_BCD2 = BCD2;
                        end
                    end
                    else 
                    begin
                        next_BCD3 = 4'd12;
                        if (BCD0 == 4'd0)
                        begin
                            next_BCD0 = 4'd9;
                            if (BCD1 == 4'd0)
                            begin
                                next_BCD1 = 4'd9;
                                if (BCD2 == 4'd0)
                                begin
                                    next_BCD2 = 4'd9; 
                                end
                                else 
                                begin
                                    next_BCD2 = BCD2 - 1;
                                end
                            end
                            else 
                            begin
                                next_BCD1 = BCD1 - 1;
                                next_BCD2 = BCD2;
                            end
                        end
                        else
                        begin
                            next_BCD0 = BCD0 - 1;
                            next_BCD1 = BCD1;
                            next_BCD2 = BCD2;
                        end
                    end
                end
            end  
            default:
            begin
                next_BCD0 = BCD0;
                next_BCD1 = BCD1;
                next_BCD2 = BCD2;
                next_BCD3 = BCD3;
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
            4'd11: // up
                DISPLAY = 7'b101_1100;
            4'd12: // down
                DISPLAY = 7'b110_0011;
            default:
                DISPLAY = 7'b111_1111;
        endcase
    end
    
    always @(posedge clk1000Hz, posedge rst)
    begin
        if (rst)
        begin
            max <= 0;
        end
        else 
        begin
            max <= next_max;
        end
    end
    
    always @*
    begin
        case(state)
        INIT:
        begin
            next_max = 0;  
        end
        STOP:
        begin
            if (BCD2 == 4'd9 && BCD1 == 4'd9 && BCD0 == 4'd9)
                next_max = 1;
            else 
                next_max = 0;
        end
        COUNT:
        begin
            if (BCD2 == 4'd9 && BCD1 == 4'd9 && BCD0 == 4'd9)
                next_max = 1;
            else 
                next_max = 0;
        end
        endcase
    end
    
    always @(posedge clk1000Hz, posedge rst)
    begin
        if (rst)
        begin
            min <= 0;
        end
        else 
        begin
            min <= next_min;
        end
    end
    
    always @*
    begin
        case(state)
        INIT:
        begin
            next_min = 0;  
        end
        STOP:
        begin
            if (BCD2 == 4'd0 && BCD1 == 4'd0 && BCD0 == 4'd0)
                next_min = 1;
            else 
                next_min = 0;
        end
        COUNT:
        begin
            if (BCD2 == 4'd0 && BCD1 == 4'd0 && BCD0 == 4'd0)
                next_min = 1;
            else 
                next_min = 0;
        end
        endcase
    end
    
    reg next_d2, next_d1, next_d0;
    
    always @(posedge clk1000Hz, posedge rst)
    begin
        if (rst)
        begin
            d2 <= 0;
            d1 <= 0;
            d0 <= 0;
        end
        else
        begin
            d2 <= next_d2;
            d1 <= next_d1;
            d0 <= next_d0;
        end
    end
    
    always @*
    begin
        case(state)
            STOP:
            begin
                if (!d2 && !d1 && !d0)
                begin
                    next_d2 = 0;
                    next_d1 = 0;
                    next_d0 = 1;
                end
                else
                begin
                    if (d0 && op_select)
                    begin
                        next_d0 = 0;
                        next_d1 = 1;
                        next_d2 = 0;
                    end
                    else if (d1 && op_select)
                    begin
                        next_d0 = 0;
                        next_d1 = 0;
                        next_d2 = 1;
                    end
                    else if (d2 && op_select)
                    begin
                        next_d0 = 1;
                        next_d1 = 0;
                        next_d2 = 0;
                    end
                    else
                    begin
                        next_d0 = d0;
                        next_d1 = d1;
                        next_d2 = d2;
                    end
                end
            end
            default:
            begin
                next_d2 = 0;
                next_d1 = 0;
                next_d0 = 0;
            end
        endcase
    end
    
endmodule
