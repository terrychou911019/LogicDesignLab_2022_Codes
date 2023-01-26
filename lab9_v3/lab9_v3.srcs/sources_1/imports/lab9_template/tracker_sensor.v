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
        {LOW, LOW, LOW} : begin
            next_state = state;
        end
        default : begin
            next_state = STRAIGHT;
        end
    endcase
end

endmodule
