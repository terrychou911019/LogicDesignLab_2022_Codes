`timescale 1ns/1ps
/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////

module vga_controller (
    input wire pclk, reset,
    output wire hsync, vsync, valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );

    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;

    parameter HD = 640;
    parameter HF = 16;
    parameter HS = 96;
    parameter HB = 48;
    parameter HT = 800; 
    parameter VD = 480;
    parameter VF = 10;
    parameter VS = 2;
    parameter VB = 33;
    parameter VT = 525;
    parameter hsync_default = 1'b1;
    parameter vsync_default = 1'b1;

    always @(posedge pclk)
        if (reset)
            pixel_cnt <= 0;
        else
            if (pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
            else
                pixel_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            hsync_i <= hsync_default;
        else
            if ((pixel_cnt >= (HD + HF - 1)) && (pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 

    always @(posedge pclk)
        if (reset)
            line_cnt <= 0;
        else
            if (pixel_cnt == (HT -1))
                if (line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            vsync_i <= vsync_default; 
        else if ((line_cnt >= (VD + VF - 1)) && (line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;

endmodule

module lab7_2(
    input clk,
    input rst,
    input up,
    input down,
    input left,
    input right,
    input hint,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output pass
    );
    // debounce
    wire db_rst;
    debounce db1 (.clk(clk), .pb(rst), .pb_debounced(db_rst));
    wire db_up;
    debounce db2 (.clk(clk), .pb(up), .pb_debounced(db_up));
    wire db_down;
    debounce db3 (.clk(clk), .pb(down), .pb_debounced(db_down));
    wire db_left;
    debounce db4 (.clk(clk), .pb(left), .pb_debounced(db_left));
    wire db_right;
    debounce db5 (.clk(clk), .pb(right), .pb_debounced(db_right));
    
    // one pulse
    wire op_rst;
	OnePulse op1 (.clock(clk_22), .signal(db_rst), .signal_single_pulse(op_rst));
	wire op_up;
	OnePulse op2 (.clock(clk_22), .signal(db_up), .signal_single_pulse(op_up));
	wire op_down;
	OnePulse op3 (.clock(clk_22), .signal(db_down), .signal_single_pulse(op_down));
	wire op_left;
	OnePulse op4 (.clock(clk_22), .signal(db_left), .signal_single_pulse(op_left));
	wire op_right;
	OnePulse op5 (.clock(clk_22), .signal(db_right), .signal_single_pulse(op_right));
	
	wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    
    wire [11:0] pixel;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt; //480
    
    assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;

    clock_divider clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22)
    ); 
 
    blk_mem_gen_0 blk_mem_gen_0_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel)
    ); 

    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
    
    // state
    parameter INIT = 3'd0;
    parameter GAME = 3'd1;
    parameter END = 3'd2;
    reg [2:0] state, next_state;
    
    // puzzle
    reg [0:63] puzzle, next_puzzle;
    
    // ans
    reg [0:63] ans;
    
    // search
    reg [3:0] search;
    
    // row, col
    reg [3:0] row, col;
    
    // pixel_addr
    reg [16:0] pixel_addr, next_pixel_addr;
    
    always @(posedge clk_22, posedge op_rst)
    begin
        if (op_rst)
            puzzle <= {4'd1, 4'd2, 4'd3, 4'd7,
                       4'd0, 4'd5, 4'd6, 4'd11, 
                       4'd4, 4'd9, 4'd15, 4'd10, 
                       4'd8, 4'd12, 4'd13, 4'd14};
        else
            puzzle <= next_puzzle;
    end
    
    always @*
    begin
        if (hint || pass)
            next_puzzle = puzzle;
        else
        begin
            if (op_up)
            begin
                if (4'd15 == puzzle[48:51] || 4'd15 == puzzle[52:55] || 4'd15 == puzzle[56:59] || 4'd15 == puzzle[60:63])
                    next_puzzle = puzzle;
                else
                begin
                    if (4'd15 == puzzle[0:3])
                    begin
                        next_puzzle[0:3] = puzzle[16:19];
                        next_puzzle[16:19] = 4'd15;
                        next_puzzle[4:15] = puzzle[4:15];
                        next_puzzle[20:63] = puzzle[20:63];
                    end
                    else if (4'd15 == puzzle[4:7])
                    begin
                        next_puzzle[4:7] = puzzle[20:23];
                        next_puzzle[20:23] = 4'd15;
                        next_puzzle[0:3] = puzzle[0:3];
                        next_puzzle[8:19] = puzzle[8:19];
                        next_puzzle[24:63] = puzzle[24:63];
                    end
                    else if (4'd15 == puzzle[8:11])
                    begin
                        next_puzzle[8:11] = puzzle[24:27];
                        next_puzzle[24:27] = 4'd15;
                        next_puzzle[0:7] = puzzle[0:7];
                        next_puzzle[12:23] = puzzle[12:23];
                        next_puzzle[28:63] = puzzle[28:63];
                    end
                    else if (4'd15 == puzzle[12:15])
                    begin
                        next_puzzle[12:15] = puzzle[28:31];
                        next_puzzle[28:31] = 4'd15;
                        next_puzzle[0:11] = puzzle[0:11];
                        next_puzzle[16:27] = puzzle[16:27];
                        next_puzzle[32:63] = puzzle[32:63];
                    end
                    else if (4'd15 == puzzle[16:19])
                    begin
                        next_puzzle[16:19] = puzzle[32:35];
                        next_puzzle[32:35] = 4'd15;
                        next_puzzle[0:15] = puzzle[0:15];
                        next_puzzle[20:31] = puzzle[20:31];
                        next_puzzle[36:63] = puzzle[36:63];
                    end
                    else if (4'd15 == puzzle[20:23])
                    begin
                        next_puzzle[20:23] = puzzle[36:39];
                        next_puzzle[36:39] = 4'd15;
                        next_puzzle[0:19] = puzzle[0:19];
                        next_puzzle[24:35] = puzzle[24:35];
                        next_puzzle[40:63] = puzzle[40:63];
                    end
                    else if (4'd15 == puzzle[24:27])
                    begin
                        next_puzzle[24:27] = puzzle[40:43];
                        next_puzzle[40:43] = 4'd15;
                        next_puzzle[0:23] = puzzle[0:23];
                        next_puzzle[28:39] = puzzle[28:39];
                        next_puzzle[44:63] = puzzle[44:63];
                    end
                    else if (4'd15 == puzzle[28:31])
                    begin
                        next_puzzle[28:31] = puzzle[44:47];
                        next_puzzle[44:47] = 4'd15;
                        next_puzzle[0:27] = puzzle[0:27];
                        next_puzzle[32:43] = puzzle[32:43];
                        next_puzzle[48:63] = puzzle[48:63];
                    end
                    else if (4'd15 == puzzle[32:35])
                    begin
                        next_puzzle[32:35] = puzzle[48:51];
                        next_puzzle[48:51] = 4'd15;
                        next_puzzle[0:31] = puzzle[0:31];
                        next_puzzle[36:47] = puzzle[36:47];
                        next_puzzle[52:63] = puzzle[52:63];
                    end
                    else if (4'd15 == puzzle[36:39])
                    begin
                        next_puzzle[36:39] = puzzle[52:55];
                        next_puzzle[52:55] = 4'd15;
                        next_puzzle[0:35] = puzzle[0:35];
                        next_puzzle[40:51] = puzzle[40:51];
                        next_puzzle[56:63] = puzzle[56:63];
                    end
                    else if (4'd15 == puzzle[40:43])
                    begin
                        next_puzzle[40:43] = puzzle[56:59];
                        next_puzzle[56:59] = 4'd15;
                        next_puzzle[0:39] = puzzle[0:39];
                        next_puzzle[44:55] = puzzle[44:55];
                        next_puzzle[60:63] = puzzle[60:63];
                    end
                    else if (4'd15 == puzzle[44:47])
                    begin
                        next_puzzle[44:47] = puzzle[60:63];
                        next_puzzle[60:63] = 4'd15;
                        next_puzzle[0:43] = puzzle[0:43];
                        next_puzzle[48:59] = puzzle[48:59];
                    end
                end
            end
            else if (op_down)
            begin
                if (4'd15 == puzzle[0:3] || 4'd15 == puzzle[4:7] || 4'd15 == puzzle[8:11] || 4'd15 == puzzle[12:15])
                    next_puzzle = puzzle;
                else
                begin
                    if (4'd15 == puzzle[48:51])
                    begin
                        next_puzzle[48:51] = puzzle[32:35];
                        next_puzzle[32:35] = 4'd15;
                        next_puzzle[0:31] = puzzle[0:31];
                        next_puzzle[36:47] = puzzle[36:47];
                        next_puzzle[52:63] = puzzle[52:63];
                    end
                    else if (4'd15 == puzzle[52:55])
                    begin
                        next_puzzle[52:55] = puzzle[36:39];
                        next_puzzle[36:39] = 4'd15;
                        next_puzzle[0:35] = puzzle[0:35];
                        next_puzzle[40:51] = puzzle[40:51];
                        next_puzzle[56:63] = puzzle[56:63];
                    end
                    else if (4'd15 == puzzle[56:59])
                    begin
                        next_puzzle[56:59] = puzzle[40:43];
                        next_puzzle[40:43] = 4'd15;
                        next_puzzle[0:39] = puzzle[0:39];
                        next_puzzle[44:55] = puzzle[44:55];
                        next_puzzle[60:63] = puzzle[60:63];
                    end
                    else if (4'd15 == puzzle[60:63])
                    begin
                        next_puzzle[60:63] = puzzle[44:47];
                        next_puzzle[44:47] = 4'd15;
                        next_puzzle[0:43] = puzzle[0:43];
                        next_puzzle[48:59] = puzzle[48:59];
                    end
                    else if (4'd15 == puzzle[16:19])
                    begin
                        next_puzzle[16:19] = puzzle[0:3];
                        next_puzzle[0:3] = 4'd15;
                        next_puzzle[4:15] = puzzle[4:15];
                        next_puzzle[20:63] = puzzle[20:63];
                    end
                    else if (4'd15 == puzzle[20:23])
                    begin
                        next_puzzle[20:23] = puzzle[4:7];
                        next_puzzle[4:7] = 4'd15;
                        next_puzzle[0:3] = puzzle[0:3];
                        next_puzzle[8:19] = puzzle[8:19];
                        next_puzzle[24:63] = puzzle[24:63];
                    end
                    else if (4'd15 == puzzle[24:27])
                    begin
                        next_puzzle[24:27] = puzzle[8:11];
                        next_puzzle[8:11] = 4'd15;
                        next_puzzle[0:7] = puzzle[0:7];
                        next_puzzle[12:23] = puzzle[12:23];
                        next_puzzle[28:63] = puzzle[28:63];
                    end
                    else if (4'd15 == puzzle[28:31])
                    begin
                        next_puzzle[28:31] = puzzle[12:15];
                        next_puzzle[12:15] = 4'd15;
                        next_puzzle[0:11] = puzzle[0:11];
                        next_puzzle[16:27] = puzzle[16:27];
                        next_puzzle[32:63] = puzzle[32:63];
                    end
                    else if (4'd15 == puzzle[32:35])
                    begin
                        next_puzzle[32:35] = puzzle[16:19];
                        next_puzzle[16:19] = 4'd15;
                        next_puzzle[0:15] = puzzle[0:15];
                        next_puzzle[20:31] = next_puzzle[20:31];
                        next_puzzle[36:63] = puzzle[36:63];
                    end
                    else if (4'd15 == puzzle[36:39])
                    begin
                        next_puzzle[36:39] = puzzle[20:23];
                        next_puzzle[20:23] = 4'd15;
                        next_puzzle[0:19] = puzzle[0:19];
                        next_puzzle[24:35] = puzzle[24:35];
                        next_puzzle[40:63] = puzzle[40:63];
                    end
                    else if (4'd15 == puzzle[40:43])
                    begin
                        next_puzzle[40:43] = puzzle[24:27];
                        next_puzzle[24:27] = 4'd15;
                        next_puzzle[0:23] = puzzle[0:23];
                        next_puzzle[28:39] = puzzle[28:39];
                        next_puzzle[44:63] = puzzle[44:63];
                    end
                    else if (4'd15 == puzzle[44:47])
                    begin
                        next_puzzle[44:47] = puzzle[28:31];
                        next_puzzle[28:31] = 4'd15;
                        next_puzzle[0:27] = puzzle[0:27];
                        next_puzzle[32:43] = puzzle[32:43];
                        next_puzzle[48:63] = puzzle[48:63];
                    end
                end
            end
            else if (op_left)      
            begin
                if (4'd15 == puzzle[12:15] || 4'd15 == puzzle[28:31] || 4'd15 == puzzle[44:47] || 4'd15 == puzzle[60:63])
                    next_puzzle = puzzle;
                 else
                 begin
                    if (4'd15 == puzzle[0:3])
                    begin
                        next_puzzle[0:3] = puzzle[4:7];
                        next_puzzle[4:7] = 4'd15;
                        next_puzzle[8:63] = puzzle[8:63];
                    end
                    else if (4'd15 == puzzle[4:7])
                    begin
                        next_puzzle[4:7] = puzzle[8:11];
                        next_puzzle[8:11] = 4'd15;
                        next_puzzle[0:3] = puzzle[0:3];
                        next_puzzle[12:63] = puzzle[12:63];
                    end
                    else if (4'd15 == puzzle[8:11])
                    begin
                        next_puzzle[8:11] = puzzle[12:15];
                        next_puzzle[12:15] = 4'd15;
                        next_puzzle[0:7] = puzzle[0:7];
                        next_puzzle[16:63] = puzzle[16:63];
                    end
                    else if (4'd15 == puzzle[16:19])
                    begin
                        next_puzzle[16:19] = puzzle[20:23];
                        next_puzzle[20:23] = 4'd15;
                        next_puzzle[0:15] = puzzle[0:15];
                        next_puzzle[24:63] = puzzle[24:63];
                    end
                    else if (4'd15 == puzzle[20:23])
                    begin
                        next_puzzle[20:23] = puzzle[24:27];
                        next_puzzle[24:27] = 4'd15;
                        next_puzzle[0:19] = puzzle[0:19];
                        next_puzzle[28:63] = puzzle[28:63];
                    end
                    else if (4'd15 == puzzle[24:27])
                    begin
                        next_puzzle[24:27] = puzzle[28:31];
                        next_puzzle[28:31] = 4'd15;
                        next_puzzle[0:23] = puzzle[0:23];
                        next_puzzle[32:63] = puzzle[32:63];
                    end
                    else if (4'd15 == puzzle[32:35])
                    begin
                        next_puzzle[32:35] = puzzle[36:39];
                        next_puzzle[36:39] = 4'd15;
                        next_puzzle[0:31] = puzzle[0:31];
                        next_puzzle[40:63] = puzzle[40:63];
                    end
                    else if (4'd15 == puzzle[36:39])
                    begin
                        next_puzzle[36:39] = puzzle[40:43];
                        next_puzzle[40:43] = 4'd15;
                        next_puzzle[0:35] = puzzle[0:35];
                        next_puzzle[44:63] = puzzle[44:63];
                    end
                    else if (4'd15 == puzzle[40:43])
                    begin
                        next_puzzle[40:43] = puzzle[44:47];
                        next_puzzle[44:47] = 4'd15;
                        next_puzzle[0:39] = puzzle[0:39];
                        next_puzzle[48:63] = puzzle[48:63];
                    end
                    else if (4'd15 == puzzle[48:51])
                    begin
                        next_puzzle[48:51] = puzzle[52:55];
                        next_puzzle[52:55] = 4'd15;
                        next_puzzle[0:47] = puzzle[0:47];
                        next_puzzle[56:63] = puzzle[56:63];
                    end
                    else if (4'd15 == puzzle[52:55])
                    begin
                        next_puzzle[52:55] = puzzle[56:59];
                        next_puzzle[56:59] = 4'd15;
                        next_puzzle[0:51] = puzzle[0:51];
                        next_puzzle[60:63] = puzzle[60:63];
                    end
                    else if (4'd15 == puzzle[56:59])
                    begin
                        next_puzzle[56:59] = puzzle[60:63];
                        next_puzzle[60:63] = 4'd15;
                        next_puzzle[0:55] = puzzle[0:55];
                    end
                 end
            end
            else if (op_right)
            begin
                if (4'd15 == puzzle[0:3] || 4'd15 == puzzle[16:19] || 4'd15 == puzzle[32:35] || 4'd15 == puzzle[48:51])
                    next_puzzle = puzzle;
                 else
                 begin
                    if (4'd15 == puzzle[12:15])
                    begin
                        next_puzzle[12:15] = puzzle[8:11];
                        next_puzzle[8:11] = 4'd15;
                        next_puzzle[0:7] = puzzle[0:7];
                        next_puzzle[16:63] = puzzle[16:63];
                    end
                    else if (4'd15 == puzzle[4:7])
                    begin
                        next_puzzle[4:7] = puzzle[0:3];
                        next_puzzle[0:3] = 4'd15;
                        next_puzzle[8:63] = puzzle[8:63];
                    end
                    else if (4'd15 == puzzle[8:11])
                    begin
                        next_puzzle[8:11] = puzzle[4:7];
                        next_puzzle[4:7] = 4'd15;
                        next_puzzle[0:3] = puzzle[0:3];
                        next_puzzle[12:63] = puzzle[12:63];
                    end
                    else if (4'd15 == puzzle[28:31])
                    begin
                        next_puzzle[28:31] = puzzle[24:27];
                        next_puzzle[24:27] = 4'd15;
                        next_puzzle[0:23] = puzzle[0:23];
                        next_puzzle[32:63] = puzzle[32:63];
                    end
                    else if (4'd15 == puzzle[20:23])
                    begin
                        next_puzzle[20:23] = puzzle[16:19];
                        next_puzzle[16:19] = 4'd15;
                        next_puzzle[0:15] = puzzle[0:15];
                        next_puzzle[24:63] = puzzle[24:63];
                    end
                    else if (4'd15 == puzzle[24:27])
                    begin
                        next_puzzle[24:27] = puzzle[20:23];
                        next_puzzle[20:23] = 4'd15;
                        next_puzzle[0:19] = puzzle[0:19];
                        next_puzzle[28:63] = puzzle[28:63];
                    end
                    else if (4'd15 == puzzle[44:47])
                    begin
                        next_puzzle[44:47] = puzzle[40:43];
                        next_puzzle[40:43] = 4'd15;
                        next_puzzle[0:39] = puzzle[0:39];
                        next_puzzle[48:63] = puzzle[48:63];
                    end
                    else if (4'd15 == puzzle[36:39])
                    begin
                        next_puzzle[36:39] = puzzle[32:35];
                        next_puzzle[32:35] = 4'd15;
                        next_puzzle[0:31] = puzzle[0:31];
                        next_puzzle[40:63] = puzzle[40:63];
                    end
                    else if (4'd15 == puzzle[40:43])
                    begin
                        next_puzzle[40:43] = puzzle[36:39];
                        next_puzzle[36:39] = 4'd15;
                        next_puzzle[0:35] = puzzle[0:35];
                        next_puzzle[44:63] = puzzle[44:63];
                    end
                    else if (4'd15 == puzzle[60:63])
                    begin
                        next_puzzle[60:63] = puzzle[56:59];
                        next_puzzle[56:59] = 4'd15;
                        next_puzzle[0:55] = puzzle[0:55];
                    end
                    else if (4'd15 == puzzle[52:55])
                    begin
                        next_puzzle[52:55] = puzzle[48:51];
                        next_puzzle[48:51] = 4'd15;
                        next_puzzle[0:47] = puzzle[0:47];
                        next_puzzle[56:63] = puzzle[56:63];
                    end
                    else if (4'd15 == puzzle[56:59])
                    begin
                        next_puzzle[56:59] = puzzle[52:55];
                        next_puzzle[52:55] = 4'd15;
                        next_puzzle[0:51] = puzzle[0:51];
                        next_puzzle[60:63] = puzzle[60:63];
                    end
                 end
            end
            else
                next_puzzle = puzzle;
        end
    end
    
    always @*
    begin
        ans <= {4'd0, 4'd1, 4'd2, 4'd3,
                4'd4, 4'd5, 4'd6, 4'd7, 
                4'd8, 4'd9, 4'd10, 4'd11, 
                4'd12, 4'd13, 4'd14, 4'd15};
    end
    
    assign pass = (puzzle == ans) ? 1 : 0;
    
    always @*
    begin
        if (0 <= h_cnt && h_cnt <= 159 && 0 <= v_cnt && v_cnt <= 119)
            search = puzzle[0:3];
        else if (160 <= h_cnt && h_cnt <= 319 && 0 <= v_cnt && v_cnt <= 119)
            search = puzzle[4:7];
        else if (320 <= h_cnt && h_cnt <= 479 && 0 <= v_cnt && v_cnt <= 119)
            search = puzzle[8:11];
        else if (480 <= h_cnt && h_cnt <= 639 && 0 <= v_cnt && v_cnt <= 119)
            search = puzzle[12:15];
        else if (0 <= h_cnt && h_cnt <= 159 && 120 <= v_cnt && v_cnt <= 239)
            search = puzzle[16:19];
        else if (160 <= h_cnt && h_cnt <= 319 && 120 <= v_cnt && v_cnt <= 239)
            search = puzzle[20:23];
        else if (320 <= h_cnt && h_cnt <= 479 && 120 <= v_cnt && v_cnt <= 239)
            search = puzzle[24:27];
        else if (480 <= h_cnt && h_cnt <= 639 && 120 <= v_cnt && v_cnt <= 239)
            search = puzzle[28:31];
        else if (0 <= h_cnt && h_cnt <= 159 && 240 <= v_cnt && v_cnt <= 359)
            search = puzzle[32:35];
        else if (160 <= h_cnt && h_cnt <= 319 && 240 <= v_cnt && v_cnt <= 359)
            search = puzzle[36:39];
        else if (320 <= h_cnt && h_cnt <= 479 && 240 <= v_cnt && v_cnt <= 359)
            search = puzzle[40:43];
        else if (480 <= h_cnt && h_cnt <= 639 && 240 <= v_cnt && v_cnt <= 359)
            search = puzzle[44:47];
        else if (0 <= h_cnt && h_cnt <= 159 && 360 <= v_cnt && v_cnt <= 479)
            search = puzzle[48:51];
        else if (160 <= h_cnt && h_cnt <= 319 && 360 <= v_cnt && v_cnt <= 479)
            search = puzzle[52:55];
        else if (320 <= h_cnt && h_cnt <= 479 && 360 <= v_cnt && v_cnt <= 479)
            search = puzzle[56:59];
        else if (480 <= h_cnt && h_cnt <= 639 && 360 <= v_cnt && v_cnt <= 479)
            search = puzzle[60:63];
    end
    
    always @*
    begin
        row = (search) / 4;
        col = (search) % 4;
    end
    
    always @*
    begin
        if (!hint)
        begin
            if (search == 4'd15)
                pixel_addr = 1;
            else
                pixel_addr = ((160 * col + h_cnt % 160) >> 1) + 320 * ((120 * row + v_cnt % 120) >> 1);
        end
        else
        begin
            if (480 <= h_cnt && h_cnt <= 639 && 360 <= v_cnt && v_cnt <= 479)
                pixel_addr = 1;
            else
                pixel_addr = (h_cnt >> 1) + 320 * (v_cnt >> 1);
        end
    end
    
endmodule