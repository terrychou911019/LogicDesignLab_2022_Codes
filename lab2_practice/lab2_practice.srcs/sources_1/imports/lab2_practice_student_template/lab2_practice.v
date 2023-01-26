module Lab2_PRACTICE (
    input clk,
    input rst,
    input [7:0] in_data,
    input in_valid,
    output reg [7:0] out_data,
    output reg out_valid
);
// 0-63 counter
reg [5:0] offset_counter, next_offset_counter;

// in_data_len
reg [5:0] in_data_len, next_in_data_len;
parameter MAX_INPUT_LEN = 6'd63;

// state
parameter INIT = 3'd0;
parameter GET_DATA = 3'd1;
parameter CALCULATE_DATA = 3'd2;
parameter OUTPUT_DATA = 3'd3;
reg [2:0] state, next_state;

// output_data_save
reg [7:0] output_data_save[63:0], next_output_data_save[63:0];



integer i;

// output
reg [7:0] next_out_data;
reg next_out_valid;

always @(posedge clk) begin
    if (rst) begin
        state <= INIT;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state)
        INIT : begin
            if (in_valid) begin
                next_state = GET_DATA;
            end
            else begin
                next_state = INIT;
            end
        end
        GET_DATA : begin
            if (!in_valid && in_data_len != 0) begin
                next_state = CALCULATE_DATA;
            end
            else begin
                next_state = GET_DATA;
            end
        end
        CALCULATE_DATA : begin
            if (offset_counter == in_data_len) begin
                next_state = OUTPUT_DATA;
            end
            else begin
                next_state = CALCULATE_DATA;
            end
        end
        OUTPUT_DATA : begin
            if (offset_counter == in_data_len) begin
                next_state = INIT;
            end
            else begin
                next_state = OUTPUT_DATA;
            end
        end
        default : begin
            next_state = INIT;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        offset_counter <= 0;
    end
    else begin
        offset_counter <= next_offset_counter;
    end
end

always @(*) begin
    case(state)
        INIT : begin
            if (in_valid) begin
                next_offset_counter = 1; // ?
            end
            else begin
                next_offset_counter = 0;
            end
        end
        GET_DATA : begin
            if (!in_valid && in_data_len != 0) begin
                next_offset_counter = 0;
            end
            else begin
                next_offset_counter = offset_counter + 1;
            end
        end
        CALCULATE_DATA : begin
            if (offset_counter == in_data_len) begin
                next_offset_counter = 0;
            end
            else begin
                next_offset_counter = offset_counter + 1;
            end
        end
        OUTPUT_DATA : begin
            if (offset_counter == in_data_len) begin
                next_offset_counter = 0;
            end
            else begin
                next_offset_counter = offset_counter + 1;
            end
        end
        default : begin
            next_offset_counter = 0;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        in_data_len <= 0;
    end
    else begin
        in_data_len <= next_in_data_len;
    end
end

always @(*) begin
    case(state)
        INIT : begin
            if (in_valid) begin
                next_in_data_len = 1; // ?
            end
            else begin
                next_in_data_len = 0;
            end
        end
        GET_DATA : begin
            if (!in_valid && in_data_len != 0) begin
                next_in_data_len = in_data_len;
            end
            else begin
                next_in_data_len = in_data_len + 1;
            end
        end
        default : begin
            next_in_data_len = in_data_len;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        for (i=0; i<=MAX_INPUT_LEN; i=i+1) begin
            output_data_save[i] <= 0;
        end
    end
    else begin
        for (i=0; i<=MAX_INPUT_LEN; i=i+1) begin
            output_data_save[i] <= next_output_data_save[i];
        end
    end
end

always @(*) begin
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
        CALCULATE_DATA : begin
            for (i=0; i<=MAX_INPUT_LEN; i=i+1) begin
                next_output_data_save[i] = output_data_save[i];
            end

            if (offset_counter != in_data_len) begin

                // + 1
                next_output_data_save[offset_counter] = output_data_save[offset_counter] + 1;

                // select
                case({next_output_data_save[offset_counter][7], next_output_data_save[offset_counter][0]})
                    2'b00 : begin
                        next_output_data_save[offset_counter] = 8'd0;
                    end
                    2'b11 : begin
                        next_output_data_save[offset_counter] = 8'b11111111;
                    end
                    default : begin
                        next_output_data_save[offset_counter] = next_output_data_save[offset_counter];
                    end
                endcase

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
