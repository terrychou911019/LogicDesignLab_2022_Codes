// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module motor(
    input clk,
    input rst,
    input [1:0]mode,
    input [15:0] sw,
    output [1:0]pwm,
    output reg [1:0]r_IN,
    output reg [1:0]l_IN
);

parameter STRAIGHT = 2'd0;
parameter TURN_LEFT = 2'd1;
parameter TURN_RIGHT = 2'd2;
parameter STOP = 2'd3;

parameter R_STOP = 2'b00;
parameter R_FORWARD = 2'b01;
parameter R_BACKWARD = 2'b10;

parameter L_STOP = 2'b00;
parameter L_FORWARD = 2'b10;
parameter L_BACKWARD = 2'b01;

reg [1:0] next_r_IN;
reg [1:0] next_l_IN;

//reg [9:0]next_left_motor, next_right_motor;
reg [9:0] left_motor = 10'd725, right_motor = 10'd700; // low battery
reg [9:0] next_left_motor, next_right_motor;
wire left_pwm, right_pwm;

motor_pwm m0(clk, rst, left_motor, left_pwm);
motor_pwm m1(clk, rst, right_motor, right_pwm);

assign pwm = {left_pwm,right_pwm};

always @(posedge clk, posedge rst)
begin
    if (rst)
    begin
        left_motor <= 10'd725;
        right_motor <= 10'd700;
    end
    else
    begin
        left_motor <= next_left_motor;
        right_motor <= next_right_motor;
    end
end

always @*
begin
    if (sw[0])
    begin
        if(mode == STRAIGHT) begin
            next_left_motor = 10'd740;
            next_right_motor = 10'd715;
        end
        else begin
            next_left_motor = 10'd732;
            next_right_motor = 10'd707;
        end
    end
    else if (sw[1])
    begin
        if(mode == STRAIGHT) begin
            next_left_motor = 10'd740;
            next_right_motor = 10'd715;
        end
        else begin
            next_left_motor = 10'd734;
            next_right_motor = 10'd709;
        end
    end
    else if (sw[2])
    begin
        if(mode == STRAIGHT) begin
            next_left_motor = 10'd740;
            next_right_motor = 10'd715;
        end
        else begin
            next_left_motor = 10'd736;
            next_right_motor = 10'd711;
        end
    end
    else if (sw[3])
    begin
        if(mode == STRAIGHT) begin
            next_left_motor = 10'd745;
            next_right_motor = 10'd705;
        end
        else if (mode == TURN_LEFT)
        begin
            next_left_motor = 10'd740;
            next_right_motor = 10'd705;
        end
        else begin
            next_left_motor = 10'd745;
            next_right_motor = 10'd700;
        end
    end
    else if (sw[4])
    begin
        next_left_motor = 10'd740;
        next_right_motor = 10'd715;
    end
    else if (sw[5])
    begin
        next_left_motor = 10'd750;
        next_right_motor = 10'd725;
    end
    else if (sw[6])
    begin
        next_left_motor = 10'd760;
        next_right_motor = 10'd735;
    end
    else if (sw[7])
    begin
        next_left_motor = 10'd770;
        next_right_motor = 10'd745;
    end
    else if (sw[8])
    begin
        next_left_motor = 10'd780;
        next_right_motor = 10'd755;
    end
    else if (sw[9])
    begin
        next_left_motor = 10'd790;
        next_right_motor = 10'd765;
    end
    else if (sw[10])
    begin
        next_left_motor = 10'd800;
        next_right_motor = 10'd775;
    end
    else if (sw[11])
    begin
        next_left_motor = 10'd810;
        next_right_motor = 10'd785;
    end
    else if (sw[12])
    begin
        next_left_motor = 10'd820;
        next_right_motor = 10'd795;
    end
    else if (sw[13])
    begin
        next_left_motor = 10'd830;
        next_right_motor = 10'd805;
    end
    else if (sw[14])
    begin
        next_left_motor = 10'd840;
        next_right_motor = 10'd815;
    end
    else if (sw[15])
    begin
        next_left_motor = 10'd850;
        next_right_motor = 10'd835;
    end
    else
    begin
        next_left_motor = 10'd0;
        next_right_motor = 10'd0;
    end
end

// TODO: trace the rest of motor.v and control the speed and direction of the two motors

always @(posedge clk) begin
    if(rst) begin
        r_IN <= R_FORWARD;
        l_IN <= L_FORWARD;
    end
    else begin
        r_IN <= next_r_IN;
        l_IN <= next_l_IN;
    end
end

always @* begin
    case(mode)
        STRAIGHT : begin
            next_r_IN = R_FORWARD;
            next_l_IN = L_FORWARD;
        end
        TURN_LEFT : begin
            next_r_IN = R_FORWARD;
            next_l_IN = L_BACKWARD;
        end
        TURN_RIGHT : begin
            next_r_IN = R_BACKWARD;
            next_l_IN = L_FORWARD;
        end
        STOP : begin
            next_r_IN = R_STOP;
            next_l_IN = L_STOP;
        end
        default : begin
            next_r_IN = R_FORWARD;
            next_l_IN = L_FORWARD;
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
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            // TODO: set <PWM> accordingly
            PWM <= (count < count_duty);
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule

