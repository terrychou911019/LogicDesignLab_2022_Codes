`timescale 1ns/100ps
module lab1_1 (
    input wire [3:0] request,
    output reg [3:0] grant
); 
    /* Note that grant can be either reg or wire.
    * e.g.,		output reg [3:0] grant
    * or 		output wire [3:0] grant
    * It depends on how you design your module. */
    // add your design here 
    always @* begin
        if (request[3] == 1)
            grant = 4'b1000;
        else if (request[2] == 1)
            grant = 4'b0100;
        else if (request[1] == 1)
            grant = 4'b0010;
        else if (request[0] == 1)
            grant = 4'b0001;
        else 
            grant = 4'b0000;
    end
endmodule

module lab1_2 (
    input wire [5:0] source_0,
    input wire [5:0] source_1,
    input wire [5:0] source_2,
    input wire [5:0] source_3,
    output reg [3:0] result
); 
    /* Note that result can be either reg or wire. 
    * It depends on how you design your module. */
    // add your design here 
    wire [3:0] s;
    wire [3:0] g;
    assign s[3] = source_3[5] | source_3[4];
    assign s[2] = source_2[5] | source_2[4];
    assign s[1] = source_1[5] | source_1[4];
    assign s[0] = source_0[5] | source_0[4];
    lab1_1 a(.request(s), .grant(g));
    always @* begin
        case(g) 
            4'b1000: 
                case(source_3[5:4])
                    2'b01:
                        result = source_3[3:0] & 4'b1010;
                    2'b10:
                        result = source_3[3:0] + 4'd3;
                    2'b11:
                        result = source_3[3:0] << 2;
                    default:
                        result = 4'b0000;
                endcase   
            4'b0100:
                case(source_2[5:4])
                        2'b01:
                            result = source_2[3:0] & 4'b1010;
                        2'b10:
                            result = source_2[3:0] + 4'd3;
                        2'b11:
                            result = source_2[3:0] << 2;
                        default:
                            result = 4'b0000;
                 endcase           
            4'b0010:
                case(source_1[5:4])
                    2'b01:
                        result = source_1[3:0] & 4'b1010;
                    2'b10:
                        result = source_1[3:0] + 4'd3;
                    2'b11:
                        result = source_1[3:0] << 2;
                    default:
                        result = 4'b0000;
                 endcase       
            4'b0001:
                case(source_0[5:4])
                    2'b01:
                        result = source_0[3:0] & 4'b1010;
                    2'b10:
                        result = source_0[3:0] + 4'd3;
                    2'b11:
                        result = source_0[3:0] << 2;
                    default:
                        result = 4'b0000;
                endcase        
            default: result = 4'b0000;
        endcase
    end
endmodule
