module tracker_sensor(clk, reset, left_track, right_track, mid_track, state);
    input clk;
    input reset;
    input left_track, right_track, mid_track; // black -> 0, white -> 1
    output reg [2:0] state; 

    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output state to change your action.
    
    // state
    parameter STOP = 3'd0;
    parameter FORWARD = 3'd1;
    parameter BACKWARD = 3'd2;
    parameter TURN_LEFT = 3'd3;
    parameter TURN_RIGHT = 3'd4;
    reg [2:0] next_state;
    
    always @(posedge clk, posedge reset)
    begin
        if (reset)
            state <= STOP;
        else
            state <= next_state;
    end
    
    always @*
    begin
        if (!mid_track)
        begin
            next_state = FORWARD;
        end
        else
        begin
            if (!left_track && right_track)
                next_state = TURN_LEFT;
            else if (!right_track && left_track)
                next_state = TURN_RIGHT;
            else
                next_state = state;
        end
    end
    
endmodule
