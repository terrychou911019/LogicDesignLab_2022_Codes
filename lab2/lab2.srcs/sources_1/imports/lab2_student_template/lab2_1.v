module Encoder (
    input clk,
    input rst,
    input [7:0] in_data,
    input in_valid,
    output reg [11:0] out_data,
    output reg out_valid
);

// 0-255 counter
reg [7:0] offset_counter, next_offset_counter;

// in_data_len
reg [7:0] in_data_len, next_in_data_len;
parameter MAX_INPUT_LEN = 8'd255;

// state
parameter INIT = 3'd0;
parameter GET_DATA = 3'd1;
parameter ENCRYPT = 3'd2;
parameter ERROR_CODE = 3'd3;
parameter OUTPUT_DATA = 3'd4;
reg [2:0] state, next_state;

// encrypted
reg [7:0] tmp;

// encrypt
reg [7:0] encrypted_data_save[255:0], next_encrypted_data_save[255:0];

// output_data_save
reg [11:0] output_data_save[255:0], next_output_data_save[255:0];

// output
reg [11:0] next_out_data;
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
            if (in_valid)
                next_state = GET_DATA;
            else
                next_state = INIT;
        end
        GET_DATA: begin
            if (!in_valid && in_data_len != 0)
                next_state = ENCRYPT;
            else 
                next_state = GET_DATA;
        end
        ENCRYPT: begin
            if (offset_counter == in_data_len)
                next_state = ERROR_CODE;
            else 
                next_state = ENCRYPT;
        end
        ERROR_CODE: begin
            if (offset_counter == in_data_len)
                next_state = OUTPUT_DATA;
            else 
                next_state = ERROR_CODE;
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
            if (in_valid) 
                next_offset_counter = 1;
            else 
                next_offset_counter = 0;
        end
        GET_DATA : begin
            if (!in_valid && in_data_len != 0) 
                next_offset_counter = 0;
            else 
                next_offset_counter = offset_counter + 1;
        end
        ENCRYPT : begin
            if (offset_counter == in_data_len) 
                next_offset_counter = 0;
            else 
                next_offset_counter = offset_counter + 1;
        end
        ERROR_CODE : begin
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
            if (in_valid) 
                next_in_data_len = 1;
            else 
                next_in_data_len = 0;
        end
        GET_DATA : begin
            if (!in_valid && in_data_len != 0) 
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
        for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
            encrypted_data_save[i] <= 0;
    else 
        for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
            encrypted_data_save[i] <= next_encrypted_data_save[i];
end

always @* begin
    case(state)
        INIT: begin
            for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
                next_encrypted_data_save[i] = encrypted_data_save[i];
            if (in_valid)
                next_encrypted_data_save[0] = in_data;
        end
        GET_DATA: begin
            for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
                next_encrypted_data_save[i] = encrypted_data_save[i];
            if (in_valid) // ?
                next_encrypted_data_save[offset_counter] = in_data;
        end
        ENCRYPT: begin
            for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
                next_encrypted_data_save[i] = encrypted_data_save[i];
            if (offset_counter != in_data_len) begin
                if (offset_counter <= 127)
                    next_encrypted_data_save[offset_counter] = encrypted_data_save[offset_counter] + offset_counter; 
                else 
                    next_encrypted_data_save[offset_counter] = encrypted_data_save[offset_counter] + offset_counter - 128; 
            end
        end
        default:
            for (i = 0 ; i <= MAX_INPUT_LEN ; i = i + 1)
                next_encrypted_data_save[i] = encrypted_data_save[i];
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
            if (in_valid) begin // ?
                next_output_data_save[0] = in_data;
            end
        end
        GET_DATA : begin
            for (i=0; i<=MAX_INPUT_LEN; i=i+1) begin
                next_output_data_save[i] = output_data_save[i];
            end
            if (in_valid) begin // ?
                next_output_data_save[offset_counter] = in_data;
            end
        end
        ERROR_CODE : begin
            for (i=0; i<=MAX_INPUT_LEN; i=i+1) begin
                next_output_data_save[i] = output_data_save[i];
            end

            if (offset_counter != in_data_len) begin
                next_output_data_save[offset_counter][11] = encrypted_data_save[offset_counter][7];
                next_output_data_save[offset_counter][10] = encrypted_data_save[offset_counter][6];
                next_output_data_save[offset_counter][9] = encrypted_data_save[offset_counter][5];
                next_output_data_save[offset_counter][8] = encrypted_data_save[offset_counter][4];
                next_output_data_save[offset_counter][6] = encrypted_data_save[offset_counter][3];
                next_output_data_save[offset_counter][5] = encrypted_data_save[offset_counter][2];
                next_output_data_save[offset_counter][4] = encrypted_data_save[offset_counter][1];
                next_output_data_save[offset_counter][2] = encrypted_data_save[offset_counter][0];
                next_output_data_save[offset_counter][0] = next_output_data_save[offset_counter][2] ^ next_output_data_save[offset_counter][4] ^ 
                                                           next_output_data_save[offset_counter][6] ^ next_output_data_save[offset_counter][8] ^ next_output_data_save[offset_counter][10];
                next_output_data_save[offset_counter][1] = next_output_data_save[offset_counter][2] ^ next_output_data_save[offset_counter][5] ^ 
                                                           next_output_data_save[offset_counter][6] ^ next_output_data_save[offset_counter][9] ^ next_output_data_save[offset_counter][10];
                next_output_data_save[offset_counter][3] = next_output_data_save[offset_counter][4] ^ next_output_data_save[offset_counter][5] ^ 
                                                           next_output_data_save[offset_counter][6] ^ next_output_data_save[offset_counter][11];
                next_output_data_save[offset_counter][7] = next_output_data_save[offset_counter][8] ^ next_output_data_save[offset_counter][9] ^ 
                                                           next_output_data_save[offset_counter][10] ^ next_output_data_save[offset_counter][11];
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
        out_data <= 0;
        out_valid <= 0;
    end
    else begin
        out_data <= next_out_data;
        out_valid <= next_out_valid;
    end
end

always @(*) begin
    case(state)
        OUTPUT_DATA : begin
            if (offset_counter != in_data_len) begin
                next_out_valid = 1;
                next_out_data = output_data_save[offset_counter];
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