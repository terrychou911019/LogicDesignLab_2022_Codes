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

module lab3_1
(
    input clk,
    input rst,
    input en,
    input speed,
    output reg [15:0] led
);
    integer i;
    
    // counter
    reg [3:0] counter, next_counter;

    // next_led
    reg [15:0] next_led;
    
    // clk divided by 24 & 27
    wire clk24, clk27;
    reg myclk;
    clock_divider #(.n(24)) clkDivBy24(.clk(clk), .clk_div(clk24));
    clock_divider #(.n(27)) clkDivBy27(.clk(clk), .clk_div(clk27));
    
    always @* 
    begin
        if (speed == 1)
            myclk = clk27;
        else if (speed == 0)
            myclk = clk24;
    end
    
    always @(posedge myclk or posedge rst) // sequetional
    begin
        if (rst)
            counter <= 4'b1111;
        else 
            counter <= next_counter;
    end
    
    always @* // combinational
    begin
        if (counter == 4'b0000)
            next_counter = 4'b1111;
        else if (en == 1)
            next_counter = counter - 1;
        else 
            next_counter = counter;
    end
    
    always @(posedge myclk or posedge rst)
    begin
        if (rst)
        begin
            led[15] <= 1;
            for (i = 0 ; i < 15 ; i = i + 1)
                led[i] <= 0;
        end
        else if (en == 1)
        begin
            if (counter < 15 && counter >= 0)
            begin
                led[counter + 1] <= next_led[counter + 1];
                led[counter] <= next_led[counter];
            end
            else if (counter == 4'b1111)
            begin
                led[15] <= 1;
                led[0] <= 0;
            end
        end
        else 
        begin
            led[counter] <= next_led[counter];
        end
    end

    always @*
    begin
        if (en == 1)
        begin
            if (counter < 15 && counter >= 0)
            begin
                next_led[counter + 1] = 0;
                next_led[counter] = 1;
            end
        end
        else 
        begin
            next_led[counter] = led[counter];
        end
    end
endmodule
