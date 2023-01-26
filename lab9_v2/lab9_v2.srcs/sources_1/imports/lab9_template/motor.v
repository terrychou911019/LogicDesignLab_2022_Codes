// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module motor(
    input clk,
    input rst,
    input [1:0] mode,
    input [2:0] state,
    output [1:0] pwm,
    output reg [1:0] r_IN,
    output reg [1:0] l_IN
);

    reg [9:0]next_left_motor, next_right_motor;
    reg [9:0]left_motor, right_motor;
    wire left_pwm, right_pwm;

    motor_pwm m0(clk, rst, left_motor, left_pwm);
    motor_pwm m1(clk, rst, right_motor, right_pwm);

    assign pwm = {left_pwm,right_pwm};

    // TODO: trace the rest of motor.v and control the speed and direction of the two motors
    // state
    parameter STOP = 3'd0;
    parameter FORWARD = 3'd1;
    parameter BACKWARD = 3'd2;
    parameter TURN_LEFT = 3'd3;
    parameter TURN_RIGHT = 3'd4;
    
    // some parameter
    parameter NORMAL_SPEED = 10'd780;
    parameter SLOWER_SPEED = 10'd780;
    parameter FASTER_SPEED = 10'd780;
    
    reg [1:0] next_r_IN, next_l_IN;
    
    always @(posedge clk, posedge rst)
    begin
        if (rst)
            left_motor <= 0;
        else
            left_motor <= next_left_motor;
    end
    
    always @*
    begin
        case (state)
            STOP:
                next_left_motor = 0;
            FORWARD:
                next_left_motor = NORMAL_SPEED;
            BACKWARD:
                next_left_motor = NORMAL_SPEED;
            TURN_LEFT:
                next_left_motor = SLOWER_SPEED;
            TURN_RIGHT:
                next_left_motor = NORMAL_SPEED;
        endcase
    end
    
    always @(posedge clk, posedge rst)
    begin
        if (rst)
            right_motor <= 0;
        else
            right_motor <= next_right_motor;
    end
    
    always @*
    begin
        case (state)
            STOP:
                next_right_motor = 0;
            FORWARD:
                next_right_motor = NORMAL_SPEED;
            BACKWARD:
                next_right_motor = NORMAL_SPEED;
            TURN_LEFT:
                next_right_motor = NORMAL_SPEED;
            TURN_RIGHT:
                next_right_motor = SLOWER_SPEED;
        endcase
    end
    
    always @(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            r_IN <= 0;
            l_IN <= 0;
        end
        else
        begin
            r_IN <= next_r_IN;
            l_IN <= next_l_IN;
        end
    end
    
    always @*
    begin
        case (state)   
            STOP:
            begin
                next_r_IN = 2'b00;
                next_l_IN = 2'b00;
            end
            FORWARD:
            begin
                next_r_IN = 2'b10;
                next_l_IN = 2'b10;
            end
            BACKWARD:
            begin
                next_r_IN = 2'b10;
                next_l_IN = 2'b10;
            end
            TURN_LEFT:
            begin
                next_r_IN = 2'b10;
                next_l_IN = 2'b10;
            end
            TURN_RIGHT:
            begin
                next_r_IN = 2'b10;
                next_l_IN = 2'b10;
            end
            default:begin
                 next_r_IN = 2'b10;
                next_l_IN = 2'b10;
            end
        endcase
    end
    
endmodule

module motor_pwm (
    input clk,
    input reset,
    input [9:0]duty,
	output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1)
    );

endmodule

//generte PWM by input frequency & duty cycle
module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);
    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
    
    reg [2:0] cnt, next_cnt;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            // TODO: set <PWM> accordingly
            if (count < count_duty)
                PWM <= 1;
            else
                PWM <= 0;
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule

