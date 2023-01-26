module clkDiv10 (
    input wire clk,
    output reg clk_div
);
    reg [27:0] counter = 28'd0;
    parameter DIVISOR = 10000000;
    
    always @(posedge clk)
    begin   
        counter <= counter + 28'd1;
        if (counter >= (DIVISOR - 1))
            counter <= 28'd0;
        clk_div <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
    end
endmodule

module lab4_1 ( 
    input wire clk,
    input wire rst,
    input wire start,
    input wire direction,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY,
   //output reg max,
   // output reg min,
    output wire [15:0] led
); 

assign led = {BCD3, BCD2, BCD1, BCD0};

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
    
    // one_pulse
    wire op_start;
    one_pulse op1 (.clk(clk1000Hz), .pb_in(db_start), .pb_out(op_start));
    wire op_direction;
    one_pulse op2 (.clk(clk1000Hz), .pb_in(db_direction), .pb_out(op_direction));
    
    // state
    parameter INIT = 3'd0;
    parameter STOP = 3'd1;
    parameter COUNT = 3'd2;
    reg [2:0] state = 0, next_state = 0;
    
    // BCD
    reg [3:0] BCD3 = 4'd5, BCD2 = 4'd4, BCD1 = 4'd3, BCD0 = 4'd2, next_BCD3, next_BCD2, next_BCD1, next_BCD0;
    
    //  value
    reg [3:0] value;
    
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
                next_BCD3 = 4'd10;
                next_BCD2 = 4'd0;
                next_BCD1 = 4'd5;
                next_BCD0 = 4'd0;
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
            4'd0:  DISPLAY = 7'b100_0000;
            4'd1:  DISPLAY = 7'b111_1001;
            4'd2:  DISPLAY = 7'b010_0100;
            4'd3:  DISPLAY = 7'b011_0000;
            4'd4:  DISPLAY = 7'b001_1001;
            4'd5:  DISPLAY = 7'b001_0010;
            4'd6:  DISPLAY = 7'b000_0010;
            4'd7:  DISPLAY = 7'b111_1000;
            4'd8:  DISPLAY = 7'b000_0000;
            4'd9:  DISPLAY = 7'b001_0000;
            4'd10: DISPLAY = 7'b011_1111;
            4'd11: DISPLAY = 7'b101_1100;
            4'd12: DISPLAY = 7'b110_0011;
            default:  DISPLAY = 7'b111_1111;
        endcase
    end
endmodule 
