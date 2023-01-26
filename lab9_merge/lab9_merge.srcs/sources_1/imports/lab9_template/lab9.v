module Lab9(
    input clk,
    input rst,
    input echo,
    input left_track,
    input right_track,
    input mid_track,
    input [15:0] sw,
    output trig,
    output IN1,
    output IN2,
    output IN3, 
    output IN4,
    output left_pwm,
    output right_pwm,
    output [15:0] led
    // You may modify or add more input/ouput yourself.
);
// We have connected the motor and sonic_top modules in the template file for you.
// TODO: control the motors with the information you get from ultrasonic sensor and 3-way track sensor.
parameter STOP = 2'd3;

wire [1:0] state;
wire [19:0] distance;
wire [1:0] mode = (distance <= 20'd30) ? STOP : state;

motor A(
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .sw(sw),
    .pwm({left_pwm, right_pwm}),
    .l_IN({IN1, IN2}),
    .r_IN({IN3, IN4})
);

sonic_top B(
    .clk(clk), 
    .rst(rst), 
    .Echo(echo), 
    .Trig(trig),
    .distance(distance)
);

tracker_sensor ts1 (
    .clk(clk),
    .reset(rst),
    .left_track(left_track),
    .right_track(right_track),
    .mid_track(mid_track),
    .state(state),
    .LED(led)
);

endmodule

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
        next_left_motor = 10'd700;
        next_right_motor = 10'd665;
    end
    else if (sw[1])
    begin
        next_left_motor = 10'd710;
        next_right_motor = 10'd675;
    end
    else if (sw[2])
    begin
        next_left_motor = 10'd720;
        next_right_motor = 10'd695;
    end
    else if (sw[3])
    begin
        next_left_motor = 10'd730;
        next_right_motor = 10'd705;
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

// sonic_top is the module to interface with sonic sensors
// clk = 100MHz
// <Trig> and <Echo> should connect to the sensor
// <distance> is the output distance in cm
module sonic_top(clk, rst, Echo, Trig, distance);
	input clk, rst, Echo;
	output Trig;
    output [19:0] distance;

	wire[19:0] dis;
    wire clk1M;
	wire clk_2_17;

    assign distance = dis;

    div clk1(clk ,clk1M);
	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
	PosCounter u2(.clk(clk1M), .rst(rst), .echo(Echo), .distance_count(dis));
 
endmodule

module PosCounter(clk, rst, echo, distance_count); 
    input clk, rst, echo;
    output[19:0] distance_count;

    parameter S0 = 2'b00;
    parameter S1 = 2'b01; 
    parameter S2 = 2'b10;
    
    wire start, finish;
    reg[1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg[19:0] count, distance_register;
    wire[19:0] distance_count; 

    always@(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 0;
            echo_reg2 <= 0;
            count <= 0;
            distance_register  <= 0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;   
            echo_reg2 <= echo_reg1; 
            case(curr_state)
                S0:begin
                    if (start) curr_state <= next_state; //S1
                    else count <= 0;
                end
                S1:begin
                    if (finish) curr_state <= next_state; //S2
                    else count <= count + 1;
                end
                S2:begin
                    distance_register <= count;
                    count <= 0;
                    curr_state <= next_state; //S0
                end
            endcase
        end
    end

    always @(*) begin
        case(curr_state)
            S0:next_state = S1;
            S1:next_state = S2;
            S2:next_state = S0;
            default:next_state = S0;
        endcase
    end

    assign start = echo_reg1 & ~echo_reg2;  
    assign finish = ~echo_reg1 & echo_reg2;

    // TODO: trace the code and calculate the distance, output it to <distance_count>
    // 1 count -> 1e-6 second
    // count * 1e-6 * 0.5 * 340
    // count / 1000000 / 2 * 34000(cm) -> count / 1000 * 17 -> mul first
    assign distance_count = distance_register * 20'd17 / 20'd1000;
    
endmodule

// send trigger signal to sensor
module TrigSignal(clk, rst, trig);
    input clk, rst;
    output trig;

    reg trig, next_trig;
    reg[23:0] count, next_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            trig <= 0;
        end
        else begin
            count <= next_count;
            trig <= next_trig;
        end
    end

    // count 10us to set <trig> high and wait for 100ms, then set <trig> back to low
    always @(*) begin
        next_trig = (count < 24'd1000);
        next_count = count + 1;
        // TODO: set <next_trig> and <next_count> to let the sensor work properly
        if(count >= 24'd9999999) begin
            next_count = 24'd0;
        end
    end
endmodule

// clock divider for T = 1us clock
module div(clk ,out_clk);
    input clk;
    output out_clk;
    reg out_clk;
    reg [6:0]cnt;
    
    always @(posedge clk) begin   
        if(cnt < 7'd50) begin
            cnt <= cnt + 1'b1;
            out_clk <= 1'b1;
        end 
        else if(cnt < 7'd100) begin
	        cnt <= cnt + 1'b1;
	        out_clk <= 1'b0;
        end
        else if(cnt == 7'd100) begin
            cnt <= 0;
            out_clk <= 1'b1;
        end
    end
endmodule

module tracker_sensor(clk, reset, left_track, right_track, mid_track, state, LED);
    input clk;
    input reset;
    input left_track, right_track, mid_track;
    output reg [1:0] state;
    output [15:0] LED;

// TODO: Receive three tracks and make your own policy.
// Hint: You can use output state to change your action.
parameter HIGH = 1'b1;
parameter LOW = 1'b0;

parameter STRAIGHT = 2'd0;
parameter TURN_LEFT = 2'd1;
parameter TURN_RIGHT = 2'd2;

assign LED[15:11] = state == TURN_LEFT ? 5'b1_1111 : 5'b0_0000;
assign LED[10:5] = state == STRAIGHT ? 6'b11_1111 : 6'b00_0000;
assign LED[4:0] = state == TURN_RIGHT ? 5'b1_1111 : 5'b0_0000;

reg [1:0] next_state;

always @(posedge clk) begin
    if(reset) begin
        state <= STRAIGHT;
    end
    else begin
        state <= next_state;
    end
end

// {LOW, LOW, LOW}, {LOW, HIGH, LOW}, {HIGH, HIGH, HIGH}
always @* begin
    case({left_track, mid_track, right_track})
        {HIGH, LOW, HIGH} : begin
            next_state = STRAIGHT;
        end
        {LOW, HIGH, HIGH}, {LOW, LOW, HIGH} : begin
            next_state = TURN_LEFT;
        end
        {HIGH, HIGH, LOW}, {HIGH, LOW, LOW} : begin
            next_state = TURN_RIGHT;
        end
        default : begin
            next_state = STRAIGHT;
        end
    endcase
end

endmodule
