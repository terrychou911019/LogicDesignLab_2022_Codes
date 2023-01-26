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