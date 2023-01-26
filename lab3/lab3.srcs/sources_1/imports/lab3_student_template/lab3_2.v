module clock_divider #(parameter n = 25) (
    input clk,
    output clk_div
);
    reg [n - 1 : 0] num = 0;
    wire [n - 1 : 0] next_num;
    always @(posedge clk)
    begin
        num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n - 1];
endmodule

module lab3_2
(
    input clk,
    input rst,
    input en,
    input speed,
    input freeze,
    output wire [15:0] led
);    
    // state 
    parameter INIT = 3'd0;
    parameter RACE = 3'd1;
    parameter CAR_FINISH = 3'd2;
    parameter CAR_END_GAME = 3'd3;
    parameter MOR_FINISH = 3'd4;
    parameter MOR_END_GAME = 3'd5;
    reg [2:0] state, next_state;
    
    // clk divided by 24 & 27
    wire clk24, clk27;
    wire car_clk;
    clock_divider #(.n(24)) clkDivBy24 (.clk(clk), .clk_div(clk24));
    clock_divider #(.n(27)) clkDivBy27 (.clk(clk), .clk_div(clk27));
    
    // car_position
    reg [15:0] car_position, next_car_position;
    
    // mor_position
    reg [15:0] mor_position, next_mor_position;
    
    // car_score
    reg [1:0] car_score, next_car_score;
    
    // mor_score
    reg [1:0] mor_score, next_mor_score;
    
    // turbo_counter
    reg [2:0] turbo_counter, next_turbo_counter;
   
    integer i;
    
    // assign 
    assign led[15] = car_score[1];
    assign led[14] = car_score[0];
    assign led[13] = car_position[13] || mor_position[13];
    assign led[12] = car_position[12] || mor_position[12];
    assign led[11] = car_position[11] || mor_position[11];
    assign led[10] = car_position[10] || mor_position[10];
    assign led[9] = car_position[9] || mor_position[9];
    assign led[8] = car_position[8] || mor_position[8];
    assign led[7] = car_position[7] || mor_position[7];
    assign led[6] = car_position[6] || mor_position[6];
    assign led[5] = car_position[5] || mor_position[5];
    assign led[4] = car_position[4] || mor_position[4];
    assign led[3] = car_position[3] || mor_position[3];
    assign led[2] = car_position[2] || mor_position[2];
    assign led[1] = mor_score[1];
    assign led[0] = mor_score[0];
    
    assign car_clk = (state == RACE && speed == 1 && turbo_counter < 3'd5) ? clk24 : clk27;
    
    always @(posedge clk27 or posedge rst)
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
            begin 
                next_state = RACE;
            end
            RACE:
            begin
                if (car_score != 2'b11 && car_position[2] == 1 && mor_position[2] != 1)
                    next_state = CAR_FINISH;
                else if (car_score == 2'b11 && car_position[2] == 1 && mor_position[2] != 1)
                    next_state = CAR_END_GAME;
                else if (mor_score != 2'b11 && mor_position[2] == 1)
                    next_state = MOR_FINISH;
                else if (mor_score == 2'b11 && mor_position[2] == 1)
                    next_state = MOR_END_GAME;
                else 
                    next_state = RACE;
            end
            CAR_FINISH:
                next_state = RACE;
            CAR_END_GAME:
                next_state = INIT;
            MOR_FINISH:
                next_state = RACE;
            MOR_END_GAME:
                next_state = INIT;
        endcase
    end
    
    always @(posedge car_clk or posedge rst)
    begin
        if (rst)
        begin
            car_position[13:12] <= 2'b11;
            for (i = 2 ; i <= 11 ; i = i + 1)
                car_position[i] <= 0;
        end
        else 
            car_position <= next_car_position;
    end
    
    always @*
    begin
        if (en)
        begin
            case(state)
                INIT:
                begin
                    next_car_position[13:12] = 2'b11;
                    for (i = 2 ; i <= 11 ; i = i + 1)
                        next_car_position[i] = 0;
                    //if (car_position[13:12] == 2'b11 && mor_position[10] == 1)
                      //  next_car_position = car_position;
                end
                RACE:
                begin   
                    if (car_position[2] == 1 || mor_position[2] == 1)
                        next_car_position = car_position;
                    else
                        next_car_position = car_position >> 1;
                end
                CAR_FINISH:
                begin
                    next_car_position[13:12] = 2'b11;
                    for (i = 2 ; i <= 11 ; i = i + 1)
                        next_car_position[i] = 0;
                end
                MOR_FINISH:
                begin
                    next_car_position[13:12] = 2'b11;
                    for (i = 2 ; i <= 11 ; i = i + 1)
                        next_car_position[i] = 0;
                end
                CAR_END_GAME:
                begin
                    for (i = 2 ; i <= 13 ; i = i + 1)
                        next_car_position[i] = 1;
                end
                default:
                    next_car_position = car_position;
            endcase
        end
        else 
            next_car_position = car_position;
    end
    
    always @(posedge clk27 or posedge rst)
    begin
        if (rst)
            car_score <= 2'b00;
        else 
            car_score <= next_car_score;
    end
    
    always @*
    begin
        if (en)
        begin
            case(state)
                INIT:
                begin
                    next_car_score = 2'b00;
                end
                CAR_FINISH:
                begin
                    //if (car_position[3:2] == 2'b11 && mor_position[2] != 1)
                        next_car_score = car_score + 2'b01;
                end
                CAR_END_GAME:
                begin
                    next_car_score = 2'b11;
                end
                MOR_END_GAME:
                begin
                    next_car_score = 2'b00;
                end
                default:
                    next_car_score = car_score;
            endcase
        end
        else 
            next_car_score = car_score;
    end
    
    always @(posedge clk27 or posedge rst)
    begin
        if (rst)
        begin
            mor_position[10] <= 1;
            for (i = 11 ; i <= 13 ; i = i + 1)
                mor_position[i] <= 0;
            for (i = 2 ; i <= 9 ; i = i + 1)
                mor_position[i] <= 0;
        end
        else 
            mor_position <= next_mor_position;
    end
    
    always @*
    begin
        if (en)
        begin
            case(state)
                INIT:
                begin
                    next_mor_position[10] = 1;
                    for (i = 11 ; i <= 13 ; i = i + 1)
                        next_mor_position[i] = 0;
                    for (i = 2 ; i <= 9 ; i = i + 1)
                        next_mor_position[i] = 0;
                    //if (car_position[13:12] == 2'b11 && mor_position[10] == 1)
                      //  next_mor_position = mor_position;
                end
                RACE:
                begin
                    if (freeze || mor_position[2] == 1 || car_position[2] == 1)
                        next_mor_position = mor_position;
                    else
                        next_mor_position = mor_position >> 1;
                end
                CAR_FINISH:
                begin
                    next_mor_position[10] = 1;
                    for (i = 11 ; i <= 13 ; i = i + 1)
                        next_mor_position[i] = 0;
                    for (i = 2 ; i <= 9 ; i = i + 1)
                        next_mor_position[i] = 0;
                end
                MOR_FINISH:
                begin
                    next_mor_position[10] = 1;
                    for (i = 11 ; i <= 13 ; i = i + 1)
                        next_mor_position[i] = 0;
                    for (i = 2 ; i <= 9 ; i = i + 1)
                        next_mor_position[i] = 0;
                end
                MOR_END_GAME:
                begin
                    for (i = 2 ; i <= 13 ; i = i + 1)
                        next_mor_position[i] = 1;
                end
                default:
                    next_mor_position = mor_position;
            endcase
        end
        else 
            next_mor_position = mor_position;
    end
    
    always @(posedge clk27 or posedge rst)
    begin
        if (rst)
            mor_score <= 2'b00;
        else 
            mor_score <= next_mor_score;
    end
    
    always @* 
    begin
        if (en)
        begin
            case(state)
                INIT:
                begin
                    next_mor_score = 2'b00;
                end
                MOR_FINISH:
                begin
                    //if (mor_position[2] == 1)
                        next_mor_score = mor_score + 2'b01;
                end
                CAR_END_GAME:
                begin
                    next_mor_score = 2'b00;
                end
                MOR_END_GAME:
                begin
                    next_mor_score = 2'b11;
                end
                default:
                    next_mor_score = mor_score;
            endcase
        end
        else
            next_mor_score = mor_score;
    end
    
    always @(posedge clk24 or posedge rst)
    begin
        if (rst)
            turbo_counter <= 0;
        else 
            turbo_counter <= next_turbo_counter;
    end
    
    always @*
    begin
        if (en)
        begin
            case(state)
                INIT:
                begin
                    next_turbo_counter = 0;
                end
                RACE:
                begin
                    if (speed == 1 && turbo_counter < 3'd5)
                        next_turbo_counter = turbo_counter + 1;
                    else if (speed == 0 && turbo_counter != 0)
                       next_turbo_counter = 3'd5;
                    else 
                        next_turbo_counter = turbo_counter;
                end
                CAR_FINISH:
                begin
                    next_turbo_counter = 0;
                end
                MOR_FINISH:
                begin
                    next_turbo_counter = 0;
                end
                default:
                    next_turbo_counter = 0;
            endcase
        end
        else
            next_turbo_counter = turbo_counter;
    end
endmodule