module Decoder (
    input clk,
    input rst,
    input [11:0] one_bit_err_in_data,
    input one_bit_err_in_valid,
    output reg [7:0] out_plaintext,
    output reg out_plaintext_valid
);

// 0-255 counter
reg [7:0] offset_counter, next_offset_counter;

// in_data_len
reg [7:0] in_data_len, next_in_data_len;
parameter MAX_INPUT_LEN = 8'd255;

// state
parameter INIT = 3'd0;
parameter GET_DATA = 3'd1;
parameter FIX_DATA = 3'd2;
parameter DECRYPT = 3'd3;
parameter OUTPUT_DATA = 3'd4;
reg [2:0] state, next_state;

// c
reg [3:0] c;

// tmp
reg [11:0] tmp;

// fix_data_save
reg [11:0] fix_data_save[255:0], next_fix_data_save[255:0];

// output_data_save
reg [11:0] output_data_save[255:0], next_output_data_save[255:0];

// output
reg [7:0] next_out_data;
reg next_out_valid;

integer i;

always @(posedge clk) begin
    if (rst) 
        state <= INIT;
    else
        state <= next_state;
end

always @* begin 
    case(state)
        INIT: begin
            if (one_bit_err_in_valid)
                next_state = GET_DATA;
            else
                next_state = INIT;
        end
        GET_DATA: begin
            if (!one_bit_err_in_valid && in_data_len != 0)
                next_state = FIX_DATA;
            else 
                next_state = GET_DATA;
        end
        FIX_DATA: begin
            if (offset_counter == in_data_len)
                next_state = DECRYPT;
            else 
                next_state = FIX_DATA;
        end
        DECRYPT: begin
            if (offset_counter == in_data_len)
                next_state = OUTPUT_DATA;
            else 
                next_state = DECRYPT;
        end
        OUTPUT_DATA: begin
            if (offset_counter == in_data_len)
                next_state = INIT;
            else 
                next_state = OUTPUT_DATA;
        end
        default:
            next_state = INIT;
    endcase
end

always @(posedge clk) begin
    if (rst)
        offset_counter <= 0;
    else 
        offset_counter <= next_offset_counter;
end

always @* begin
    case(state)
        INIT : begin
            if (one_bit_err_in_valid) 
                next_offset_counter = 1;
            else 
                next_offset_counter = 0;
        end
        GET_DATA : begin
            if (!one_bit_err_in_valid && in_data_len != 0) 
                next_offset_counter = 0;
            else 
                next_offset_counter = offset_counter + 1;
        end
        FIX_DATA : begin
            if (offset_counter == in_data_len) 
                next_offset_counter = 0;
            else 
                next_offset_counter = offset_counter + 1;
        end
        DECRYPT : begin
            if (offset_counter == in_data_len) 
                next_offset_counter = 0;
            else 
                next_offset_counter = offset_counter + 1;
        end
        OUTPUT_DATA : begin
            if (offset_counter == in_data_len) 
                next_offset_counter = 0;
            else 
                next_offset_counter = offset_counter + 1;
        end
        default : 
            next_offset_counter = 0;
    endcase
end

always @(posedge clk) begin
    if (rst) 
        in_data_len <= 0;
    else 
        in_data_len <= next_in_data_len;
end

always @(*) begin
    case(state)
        INIT : begin
            if (one_bit_err_in_valid) 
                next_in_data_len = 1;
            else 
                next_in_data_len = 0;
        end
        GET_DATA : begin
            if (!one_bit_err_in_valid && in_data_len != 0) 
                next_in_data_len = in_data_len;
            else
                next_in_data_len = in_data_len + 1;
        end
        default :
            next_in_data_len = in_data_len;
    endcase
end

always @(posedge clk) begin
    if (rst)
        for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1) begin
            fix_data_save[i] <= 0;
        end
    else 
        for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1) begin
            fix_data_save[i] <= next_fix_data_save[i];
        end
end

always @* begin
    case(state)
        INIT: begin
            for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1) begin
                next_fix_data_save[i] = fix_data_save[i];
            end
            if (one_bit_err_in_valid) begin
                next_fix_data_save[0] = one_bit_err_in_data;
            end
        end
        GET_DATA: begin
            for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1) begin
                next_fix_data_save[i] = fix_data_save[i];
            end
            if (one_bit_err_in_valid) begin
                next_fix_data_save[offset_counter] = one_bit_err_in_data;
            end
        end
        FIX_DATA: begin
            for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
                next_fix_data_save[i] = fix_data_save[i];
            if (offset_counter != in_data_len) begin
                tmp = fix_data_save[offset_counter];
                c[0] = tmp[0] ^ tmp[2] ^ tmp[4] ^ tmp[6] ^ tmp[8] ^ tmp[10];
                c[1] = tmp[1] ^ tmp[2] ^ tmp[5] ^ tmp[6] ^ tmp[9] ^ tmp[10];
                c[2] = tmp[3] ^ tmp[4] ^ tmp[5] ^ tmp[6] ^ tmp[11];
                c[3] = tmp[7] ^ tmp[8] ^ tmp[9] ^ tmp[10] ^ tmp[11];
                case({c[0], c[1], c[2], c[3]})
                    4'b1100:
                        tmp[2] = !tmp[2];
                    4'b1010:
                        tmp[4] = !tmp[4];
                    4'b0110:
                       tmp[5] = !tmp[5];
                    4'b1110:
                        tmp[6] = !tmp[6];
                    4'b1001:
                        tmp[8] = !tmp[8];
                    4'b0101:
                        tmp[9] = !tmp[9];
                    4'b1101:
                        tmp[10] = !tmp[10];
                    4'b0011:
                        tmp[11] = !tmp[11];
                    4'b1000:
                        tmp[0] = !tmp[0];
                    4'b0100:
                        tmp[1] = !tmp[1];
                    4'b0010:
                        tmp[3] = !tmp[3];
                    4'b0001:
                        tmp[7] = !tmp[7];
                    default:
                       tmp = tmp;
                endcase
        
                output_data_save[offset_counter][11:8] = 4'b0000;
                output_data_save[offset_counter][0] = tmp[2];
                output_data_save[offset_counter][1] = tmp[4];
                output_data_save[offset_counter][2] = tmp[5];
                output_data_save[offset_counter][3] = tmp[6];
                output_data_save[offset_counter][4] = tmp[8];
                output_data_save[offset_counter][5] = tmp[9];
                output_data_save[offset_counter][6] = tmp[10];
                output_data_save[offset_counter][7] = tmp[11];
            end
        end
        default:
            for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
                next_fix_data_save[i] = fix_data_save[i];
    endcase
end

always @(posedge clk) begin
    if (rst)
        for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
            output_data_save[i] <= 0;
    else 
        for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
            output_data_save[i] <= next_output_data_save[i];
end

always @* begin
    case(state)
        INIT : begin
            for (i=0; i<=MAX_INPUT_LEN; i=i+1) begin
                next_output_data_save[i] = output_data_save[i];
            end
            if (one_bit_err_in_valid) begin // ?
                next_output_data_save[0] = one_bit_err_in_data;
            end
        end
        GET_DATA : begin
            for (i=0; i<=MAX_INPUT_LEN; i=i+1) begin
                next_output_data_save[i] = output_data_save[i];
            end
            if (one_bit_err_in_valid) begin // ?
                next_output_data_save[offset_counter] = one_bit_err_in_data;
            end
        end
        DECRYPT : begin
            for (i=0; i<=MAX_INPUT_LEN; i=i+1) begin
                next_output_data_save[i] = output_data_save[i];
            end

            if (offset_counter != in_data_len) begin
                if (offset_counter <= 127)
                    next_output_data_save[offset_counter] = next_output_data_save[offset_counter] - offset_counter;
                else 
                    next_output_data_save[offset_counter] = next_output_data_save[offset_counter] - offset_counter + 128;
            end
            
        end
        default : begin
            for (i=0; i<=MAX_INPUT_LEN; i=i+1) begin
                next_output_data_save[i] = output_data_save[i];
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        out_plaintext <= 0;
        out_plaintext_valid <= 0;
    end
    else begin
        out_plaintext <= next_out_data;
        out_plaintext_valid <= next_out_valid;
    end
end

always @(*) begin
    case(state)
        OUTPUT_DATA : begin
            if (offset_counter != in_data_len) begin
                next_out_valid = 1;
                next_out_data = output_data_save[offset_counter][7:0];
            end
            else begin
                next_out_valid = 0;
                next_out_data = 0;
            end
        end
        default : begin
            next_out_data = 0;
            next_out_valid = 0;
        end
    endcase
end

endmodule