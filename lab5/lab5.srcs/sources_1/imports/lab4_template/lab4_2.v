module lab5 ( 
    input wire clk,
    input wire rst,
    input wire BTNR, // OK
    input wire BTNU, // +
    input wire BTND, // -
    input wire BTNL, // cancel
    output reg [15:0] LED,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY
 ); 
    wire clk20;
    clock_divider #(.n(20)) cd2 (.clk(clk), .clk_div(clk20));
    
    wire clk17;
    clock_divider #(.n(17)) cd3 (.clk(clk), .clk_div(clk17));

    // debounce
    wire db_rst;
    debounce db1 (.clk(clk), .pb(rst), .pb_debounced(db_rst));
    wire db_BTNR;
    debounce db2 (.clk(clk), .pb(BTNR), .pb_debounced(db_BTNR));
    wire db_BTNU;
    debounce db3 (.clk(clk), .pb(BTNU), .pb_debounced(db_BTNU));
    wire db_BTND;
    debounce db4 (.clk(clk), .pb(BTND), .pb_debounced(db_BTND));
    wire db_BTNL;
    debounce db5 (.clk(clk), .pb(BTNL), .pb_debounced(db_BTNL));
    
    // one_pulse
    wire op_rst;
    one_pulse op1 (.clk(clk20), .pb_in(db_rst), .pb_out(op_rst));
    wire op_BTNR;
    one_pulse op2 (.clk(clk20), .pb_in(db_BTNR), .pb_out(op_BTNR));
    wire op_BTNU;
    one_pulse op3 (.clk(clk20), .pb_in(db_BTNU), .pb_out(op_BTNU));
    wire op_BTND;
    one_pulse op4 (.clk(clk20), .pb_in(db_BTND), .pb_out(op_BTND));
    wire op_BTNL;
    one_pulse op5 (.clk(clk20), .pb_in(db_BTNL), .pb_out(op_BTNL));
    
    // state
    parameter IDLE = 3'd0;
    parameter SET_ANSWER = 3'd1;
    parameter GUESS = 3'd2;
    parameter WRONG = 3'd3;
    parameter CORRECT = 3'd4;
    reg [2:0] state, next_state;
    
    //  ans
    reg [15:0] ans, next_ans;
    
    // guess
    reg [15:0] guess, next_guess;
    
    // value
    reg [3:0] value;
    
    // num
    reg [3:0] num0, num1, num2, num3, next_num0, next_num1, next_num2, next_num3;
    
    // counter 
    reg [9:0] counter, next_counter;
    
    // next_LED
    reg [15:0] next_LED;
    
    // A, b
    reg [3:0] A, b, next_A, next_b;
    
    always @(posedge clk20, posedge op_rst)
    begin
        if (op_rst)
            state <= 0;
        else 
            state <= next_state;
    end
    
    always @*
    begin
        case(state)
            IDLE:
            begin
                if (op_BTNR) // OK
                    next_state = SET_ANSWER;
                else
                    next_state = IDLE;
            end
            SET_ANSWER:
            begin
                if (LED[8] && op_BTNR)
                    next_state = GUESS;
                else if (op_BTNL)
                    next_state = IDLE;
                else
                    next_state = SET_ANSWER;
            end
            GUESS:
            begin
                if (LED[4] && op_BTNR && ans != guess)
                    next_state = WRONG;
                else if (LED[4] && op_BTNR && ans == guess)
                    next_state = CORRECT;
                else if (op_BTNL)
                    next_state = IDLE;
                else
                    next_state = GUESS;
            end
            WRONG:
            begin
                if (op_BTNR)
                    next_state = GUESS;
                else if (op_BTNL)
                    next_state = IDLE;
                else
                    next_state = WRONG;
            end
            CORRECT:
            begin
                if (counter == 10'd640)
                    next_state = IDLE;
                else
                    next_state = CORRECT;
            end
            default:
                next_state = state;
        endcase
    end
    
    always @(posedge clk20, posedge op_rst)
    begin
        if (op_rst)
        begin
            LED[15:12] <= 4'b1111;
            LED[11:0] <= 0;
        end
        else
            LED <= next_LED;
    end
    
    always @*
    begin
        case(state)
            IDLE:
            begin
                next_LED[15:12] = 4'b1111;
                next_LED[11:0] = 0;
            end
            SET_ANSWER:
            begin
                if (LED[15:12] == 4'b1111)
                begin
                    next_LED[15:12] = 0;
                    next_LED[11] = 1;
                    next_LED[10:0] = 0;
                end
                else if (LED[11] && op_BTNR)
                begin
                    next_LED[15:11] = 0;
                    next_LED[10] = 1;
                    next_LED[9:0] = 0;
                end
                else if (LED[10] && op_BTNR)
                begin
                    next_LED[15:10] = 0;
                    next_LED[9] = 1;
                    next_LED[8:0] = 0;
                end
                else if (LED[9] && op_BTNR)
                begin
                    next_LED[15:9] = 0;
                    next_LED[8] = 1;
                    next_LED[7:0] = 0;
                end
                else
                    next_LED = LED;
            end
            GUESS:
            begin
                if ((LED[8] == 1 && LED[15:9] == 0 && LED[7:0] == 0) || (LED[3:0] == 4'b1111))
                begin
                    next_LED[15:8] = 0;
                    next_LED[7] = 1;
                    next_LED[6:0] = 0;
                end
                else if (LED[7] && op_BTNR)
                begin
                    next_LED[15:7] = 0;
                    next_LED[6] = 1;
                    next_LED[5:0] = 0;
                end
                else if (LED[6] && op_BTNR)
                begin
                    next_LED[15:6] = 0;
                    next_LED[5] = 1;
                    next_LED[4:0] = 0;
                end
                else if (LED[5] && op_BTNR)
                begin
                    next_LED[15:5] = 0;
                    next_LED[4] = 1;
                    next_LED[3:0] = 0;
                end
                else
                    next_LED = LED;
            end
            WRONG:
            begin
                next_LED[3:0] = 4'b1111;
                next_LED[15:4] = 0;
            end
            CORRECT:
            begin
                //next_LED = 16'b1111111111111111;
                if ((counter / 128) % 2 == 0)
                    next_LED = 16'b1111111111111111;
                else
                    next_LED = 0; 
            end
            default:
                next_LED = LED;
        endcase
    end
    
    always @(posedge clk20, posedge op_rst)
    begin
        if (op_rst)
        begin
            num0 <= 4'd10;
            num1 <= 4'd10;
            num2 <= 4'd10;
            num3 <= 4'd10;
        end
        else 
        begin
            num0 <= next_num0;
            num1 <= next_num1;
            num2 <= next_num2;
            num3 <= next_num3;
        end
    end
    
    always @*
    begin
        case (state)
            IDLE:
            begin
                next_num0 = 4'd10;
                next_num1 = 4'd10;
                next_num2 = 4'd10;
                next_num3 = 4'd10;
            end
            SET_ANSWER:
            begin
                if (num0 == 4'd10 && num1 == 4'd10 && num2 == 4'd10 && num3 == 4'd10)
                begin
                    next_num0 = 4'd0;
                    next_num1 = 4'd0;
                    next_num2 = 4'd0;
                    next_num3 = 4'd0;
                end
                else
                begin
                    if (op_BTNU)
                    begin
                        if (LED[11])
                        begin
                            if (num3 == 4'd9)
                                next_num3 = num3;
                            else
                            begin
                                next_num3 = num3 + 4'd1;
                                next_num2 = num2;
                                next_num1 = num1;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[10])
                        begin
                            if (num2 == 4'd9)
                                next_num2 = num2;
                            else
                            begin
                                next_num2 = num2 + 4'd1;
                                next_num3 = num3;
                                next_num1 = num1;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[9])
                        begin
                            if (num1 == 4'd9)
                                next_num1 = num1;
                            else
                            begin
                                next_num1 = num1 + 4'd1;
                                next_num3 = num3;
                                next_num2 = num2;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[8])
                        begin
                            if (num0 == 4'd9)
                                next_num0 = num0;
                            else
                            begin
                                next_num0 = num0 + 4'd1;
                                next_num3 = num3;
                                next_num2 = num2;
                                next_num1 = num1;
                            end
                        end
                        else
                        begin
                            next_num0 = num0;
                            next_num1 = num1;
                            next_num2 = num2;
                            next_num3 = num3;
                        end
                    end
                    else if (op_BTND)
                    begin
                        if (LED[11])
                        begin
                            if (num3 == 4'd0)
                                next_num3 = num3;
                            else
                            begin
                                next_num3 = num3 - 4'd1;
                                next_num2 = num2;
                                next_num1 = num1;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[10])
                        begin
                            if (num2 == 4'd0)
                                next_num2 = num2;
                            else
                            begin
                                next_num2 = num2 - 4'd1;
                                next_num3 = num3;
                                next_num1 = num1;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[9])
                        begin
                            if (num1 == 4'd0)
                                next_num1 = num1;
                            else
                            begin
                                next_num1 = num1 - 4'd1;
                                next_num3 = num3;
                                next_num2 = num2;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[8])
                        begin
                            if (num0 == 4'd0)
                                next_num0 = num0;
                            else
                            begin
                                next_num0 = num0 - 4'd1;
                                next_num3 = num3;
                                next_num2 = num2;
                                next_num1 = num1;
                            end
                        end
                        else
                        begin
                            next_num0 = num0;
                            next_num1 = num1;
                            next_num2 = num2;
                            next_num3 = num3;
                        end
                    end
                    else
                    begin
                        next_num0 = num0;
                        next_num1 = num1;
                        next_num2 = num2;
                        next_num3 = num3;
                    end
                end
            end
            GUESS:
            begin
               if (LED[8] || LED[3:0] == 4'b1111)
               begin
                    next_num0 = 4'd0;
                    next_num1 = 4'd0;
                    next_num2 = 4'd0;
                    next_num3 = 4'd0;
                end
                else
                begin
                    if (op_BTNU)
                    begin
                        if (LED[7])
                        begin
                            if (num3 == 4'd9)
                                next_num3 = num3;
                            else
                            begin
                                next_num3 = num3 + 1;
                                next_num2 = num2;
                                next_num1 = num1;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[6])
                        begin
                            if (num2 == 4'd9)
                                next_num2 = num2;
                            else
                            begin
                                next_num2 = num2 + 1;
                                next_num3 = num3;
                                next_num1 = num1;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[5])
                        begin
                            if (num1 == 4'd9)
                                next_num1 = num1;
                            else
                            begin
                                next_num1 = num1 + 1;
                                next_num3 = num3;
                                next_num2 = num2;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[4])
                        begin
                            if (num0 == 4'd9)
                                next_num0 = num0;
                            else
                            begin
                                next_num0 = num0 + 1;
                                next_num3 = num3;
                                next_num2 = num2;
                                next_num1 = num1;
                            end
                        end
                        else
                        begin
                            next_num0 = num0;
                            next_num1 = num1;
                            next_num2 = num2;
                            next_num3 = num3;
                        end
                    end
                    else if (op_BTND)
                    begin
                        if (LED[7])
                        begin
                            if (num3 == 4'd0)
                                next_num3 = num3;
                            else
                            begin
                                next_num3 = num3 - 1;
                                next_num2 = num2;
                                next_num1 = num1;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[6])
                        begin
                            if (num2 == 4'd0)
                                next_num2 = num2;
                            else
                            begin
                                next_num2 = num2 - 1;
                                next_num3 = num3;
                                next_num1 = num1;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[5])
                        begin
                            if (num1 == 4'd0)
                                next_num1 = num1;
                            else
                            begin
                                next_num1 = num1 - 1;
                                next_num3 = num3;
                                next_num2 = num2;
                                next_num0 = num0;
                            end
                        end
                        else if (LED[4])
                        begin
                            if (num0 == 4'd0)
                                next_num0 = num0;
                            else
                            begin
                                next_num0 = num0 - 1;
                                next_num3 = num3;
                                next_num2 = num2;
                                next_num1 = num1;
                            end
                        end
                        else
                        begin
                            next_num0 = num0;
                            next_num1 = num1;
                            next_num2 = num2;
                            next_num3 = num3;
                        end
                    end
                    else
                    begin
                        next_num0 = num0;
                        next_num1 = num1;
                        next_num2 = num2;
                        next_num3 = num3;
                    end
                end
            end
            WRONG:
            begin
                next_num0 = 4'd12;
                next_num1 = b;
                next_num2 = 4'd11;
                next_num3 = A;
            end
            CORRECT:
            begin
                next_num0 = 4'd12;
                next_num1 = 4'd0;
                next_num2 = 4'd11;
                next_num3 = 4'd4;
            end
            default:
            begin
                next_num0 = num0;
                next_num1 = num1;
                next_num2 = num2;
                next_num3 = num3;
            end
        endcase
    end
    
    always @(posedge clk20, posedge op_rst)
    begin
        if (op_rst)
            ans <= 0;
        else
            ans <= next_ans;
    end
    
    always @*
    begin
        case(state)
            SET_ANSWER:
            begin
                next_ans[15:12] = num3;
                next_ans[11:8] = num2;
                next_ans[7:4] = num1;
                next_ans[3:0] = num0;
            end
            default:
                next_ans = ans;
        endcase
    end
    
    always @(posedge clk20, posedge op_rst)
    begin
        if (op_rst)
            guess <= 0;
        else
            guess <= next_guess;
    end
    
    
    always @*
    begin
        case(state)
            GUESS:
            begin
                next_guess[15:12] = num3;
                next_guess[11:8] = num2;
                next_guess[7:4] = num1;
                next_guess[3:0] = num0;
            end
            default:
                next_guess = guess;
        endcase
    end
    
    always @(posedge clk20, posedge op_rst)
    begin
        if (op_rst)
            counter <= 0;
        else 
            counter <= next_counter;
    end
    
    always @*
    begin
        case(state)
            CORRECT:
            begin
                if (counter == 10'd640)
                    next_counter = counter;
                else
                    next_counter = counter + 1;
            end
            default:
                next_counter = 0;
        endcase
    end
    
    always @(posedge clk20, posedge op_rst)
    begin
        if (op_rst)
            A <= 0;
        else 
            A <= next_A;
    end
    
    always @*
    begin
        case(state)
            GUESS:
            begin
                if (ans[15:12] == guess[15:12] && ans[11:8] == guess[11:8] && ans[7:4] == guess[7:4] && ans[3:0] == guess[3:0])
                    next_A = 4;
                else if ((ans[15:12] != guess[15:12] && ans[11:8] == guess[11:8] && ans[7:4] == guess[7:4] && ans[3:0] == guess[3:0]) ||
                         (ans[15:12] == guess[15:12] && ans[11:8] != guess[11:8] && ans[7:4] == guess[7:4] && ans[3:0] == guess[3:0]) ||
                         (ans[15:12] == guess[15:12] && ans[11:8] == guess[11:8] && ans[7:4] != guess[7:4] && ans[3:0] == guess[3:0]) ||
                         (ans[15:12] == guess[15:12] && ans[11:8] == guess[11:8] && ans[7:4] == guess[7:4] && ans[3:0] != guess[3:0]))
                    next_A = 3;
                else if ((ans[15:12] != guess[15:12] && ans[11:8] != guess[11:8] && ans[7:4] == guess[7:4] && ans[3:0] == guess[3:0]) ||
                         (ans[15:12] != guess[15:12] && ans[11:8] == guess[11:8] && ans[7:4] != guess[7:4] && ans[3:0] == guess[3:0]) ||
                         (ans[15:12] != guess[15:12] && ans[11:8] == guess[11:8] && ans[7:4] == guess[7:4] && ans[3:0] != guess[3:0]) ||
                         (ans[15:12] == guess[15:12] && ans[11:8] != guess[11:8] && ans[7:4] != guess[7:4] && ans[3:0] == guess[3:0]) ||
                         (ans[15:12] == guess[15:12] && ans[11:8] != guess[11:8] && ans[7:4] == guess[7:4] && ans[3:0] != guess[3:0]) ||
                         (ans[15:12] == guess[15:12] && ans[11:8] == guess[11:8] && ans[7:4] != guess[7:4] && ans[3:0] != guess[3:0]))
                    next_A = 2;
                else if ((ans[15:12] != guess[15:12] && ans[11:8] != guess[11:8] && ans[7:4] != guess[7:4] && ans[3:0] == guess[3:0]) ||
                         (ans[15:12] == guess[15:12] && ans[11:8] != guess[11:8] && ans[7:4] != guess[7:4] && ans[3:0] != guess[3:0]) ||
                         (ans[15:12] != guess[15:12] && ans[11:8] == guess[11:8] && ans[7:4] != guess[7:4] && ans[3:0] != guess[3:0]) ||
                         (ans[15:12] != guess[15:12] && ans[11:8] != guess[11:8] && ans[7:4] == guess[7:4] && ans[3:0] != guess[3:0]))
                    next_A = 1;
                else 
                    next_A = 0;
            end
            WRONG:
                next_A = A;
            default:
                next_A = 0;
        endcase       
    end
    
    always @(posedge clk20, posedge op_rst)
    begin
        if (op_rst)
            b <= 0;
        else 
            b <= next_b;
    end
    
    always @*
    begin
        case(state)
            GUESS:
            begin
                if (((ans[15:12] != guess[15:12]) && 
                     (guess[15:12] == ans[11:8] || guess[15:12] == ans[7:4] || guess[15:12] == ans[3:0])) && 
                    ((ans[11:8] != guess[11:8]) &&
                     (guess[11:8] == ans[15:12] || guess[11:8] == ans[7:4] || guess[11:8] == ans[3:0])) && 
                    ((ans[7:4] != guess[7:4]) &&
                     (guess[7:4] == ans[15:12] || guess[7:4] == ans[11:8] || guess[7:4] == ans[3:0])) && 
                    ((ans[3:0] != guess[3:0]) && 
                     (guess[3:0] == ans[15:12] || guess[3:0] == ans[11:8] || guess[3:0] == ans[7:4])))
                    next_b = 4;     
                else if (((guess[15:12] == ans[11:8] || guess[15:12] == ans[7:4] || guess[15:12] == ans[3:0]) && 
                     (guess[11:8] == ans[15:12] || guess[11:8] == ans[7:4] || guess[11:8] == ans[3:0]) &&
                     (guess[7:4] == ans[15:12] || guess[7:4] == ans[11:8] || guess[7:4] == ans[3:0])) ||
                    ((guess[15:12] == ans[11:8] || guess[15:12] == ans[7:4] || guess[15:12] == ans[3:0]) && 
                     (guess[11:8] == ans[15:12] || guess[11:8] == ans[7:4] || guess[11:8] == ans[3:0]) &&
                     (guess[3:0] == ans[15:12] || guess[3:0] == ans[11:8] || guess[3:0] == ans[7:4])) ||
                    ((guess[15:12] == ans[11:8] || guess[15:12] == ans[7:4] || guess[15:12] == ans[3:0]) && 
                     (guess[7:4] == ans[15:12] || guess[7:4] == ans[11:8] || guess[7:4] == ans[3:0]) &&
                     (guess[3:0] == ans[15:12] || guess[3:0] == ans[11:8] || guess[3:0] == ans[7:4])) ||
                    ((guess[11:8] == ans[15:12] || guess[11:8] == ans[7:4] || guess[11:8] == ans[3:0]) && 
                     (guess[7:4] == ans[15:12] || guess[7:4] == ans[11:8] || guess[7:4] == ans[3:0]) &&
                     (guess[3:0] == ans[15:12] || guess[3:0] == ans[11:8] || guess[3:0] == ans[7:4])))
                    next_b = 3;
                else if (((guess[15:12] == ans[11:8] || guess[15:12] == ans[7:4] || guess[15:12] == ans[3:0]) && 
                     (guess[11:8] == ans[15:12] || guess[11:8] == ans[7:4] || guess[11:8] == ans[3:0])) || 
                    ((guess[15:12] == ans[11:8] || guess[15:12] == ans[7:4] || guess[15:12] == ans[3:0]) && 
                     (guess[7:4] == ans[15:12] || guess[7:4] == ans[11:8] || guess[7:4] == ans[3:0])) ||
                    ((guess[15:12] == ans[11:8] || guess[15:12] == ans[7:4] || guess[15:12] == ans[3:0]) && 
                     (guess[3:0] == ans[15:12] || guess[3:0] == ans[11:8] || guess[3:0] == ans[7:4])) ||
                    ((guess[11:8] == ans[15:12] || guess[11:8] == ans[7:4] || guess[11:8] == ans[3:0]) && 
                     (guess[7:4] == ans[15:12] || guess[7:4] == ans[11:8] || guess[7:4] == ans[3:0])) ||
                    ((guess[11:8] == ans[15:12] || guess[11:8] == ans[7:4] || guess[11:8] == ans[3:0]) && 
                     (guess[3:0] == ans[15:12] || guess[3:0] == ans[11:8] || guess[3:0] == ans[7:4])) ||
                    ((guess[7:4] == ans[15:12] || guess[7:4] == ans[11:8] || guess[7:4] == ans[3:0]) && 
                     (guess[3:0] == ans[15:12] || guess[3:0] == ans[11:8] || guess[3:0] == ans[7:4])))
                    next_b = 2;   
                else if ((guess[15:12] == ans[11:8] || guess[15:12] == ans[7:4] || guess[15:12] == ans[3:0]) ||
                    (guess[11:8] == ans[15:12] || guess[11:8] == ans[7:4] || guess[11:8] == ans[3:0]) ||
                    (guess[7:4] == ans[15:12] || guess[7:4] == ans[11:8] || guess[7:4] == ans[3:0]) ||
                    (guess[3:0] == ans[15:12] || guess[3:0] == ans[11:8] || guess[3:0] == ans[7:4])) 
                    next_b = 1;
                else 
                    next_b = 0; 
            end
            WRONG:
                next_b = b;
            default:
                next_b = 0;
        endcase       
    end
    
    always @(posedge clk17)
    begin
        case(DIGIT)
            4'b1110:
            begin
                value = num1;
                DIGIT = 4'b1101;
            end
            4'b1101:
            begin
                value = num2;
                DIGIT = 4'b1011;
            end
            4'b1011:
            begin
                value = num3;
                DIGIT = 4'b0111;
            end
            4'b0111:
            begin
                value = num0;
                DIGIT = 4'b1110;
            end
            default:
            begin
                value = num0;
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
            4'd10: //  idle
                DISPLAY = 7'b011_1111;
            4'd11: // A
                DISPLAY = 7'b000_1000;
            4'd12: // b
                DISPLAY = 7'b000_0011;
            default:
                DISPLAY = 7'b111_1111;
        endcase
    end
    
endmodule
