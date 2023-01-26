module Lab9(
    input clk,
    input rst,
    input echo,
    input left_track,
    input right_track,
    input mid_track,
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
    wire [2:0] state;
    
    // state
    parameter STOP = 3'd0;
    parameter FORWARD = 3'd1;
    parameter BACKWARD = 3'd2;
    parameter TURN_LEFT = 3'd3;
    parameter TURN_RIGHT = 3'd4;
    assign led[15] = state == STOP;
    assign led[14] = state == FORWARD;
    assign led[13] = state == BACKWARD;
    assign led[12] = state == TURN_LEFT;
    assign led[11] = state == TURN_RIGHT;
    
    motor A(
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .state(state),
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
    
    tracker_sensor C(
        .clk(clk),
        .reset(rst),
        .left_track(left_track),
        .right_track(right_track),
        .mid_track(mid_track),
        .state(state)
    );
        
endmodule