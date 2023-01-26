module clock_divider(clk, clk_div);   
    parameter n = 26;     
    input clk;   
    output clk_div;   
    
    reg [n-1:0] num;
    wire [n-1:0] next_num;
    
    always@(posedge clk)begin
    	num<=next_num;
    end
    
    assign next_num = num +1;
    assign clk_div = num[n-1];
    
endmodule

module my_clock_divider #(
    parameter DIVISOR = 28'd2
)(
    input clock_in,
    output reg clock_out
);

reg [27:0] counter = 28'd0;

always @(posedge clock_in) begin
    counter <= counter + 28'd1;
    if(counter >= (DIVISOR-1)) begin
        counter <= 28'd0;
    end
    clock_out <= (counter < DIVISOR/2) ? 1'b1 : 1'b0;
end

endmodule