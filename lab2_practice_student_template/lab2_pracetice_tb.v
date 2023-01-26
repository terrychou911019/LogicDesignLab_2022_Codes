`timescale 1ns/100ps
	  		  	
`define CYCLE_TIME 20.0
module Lab2_PRACTICE_PATTERN(
    // input
    out_data,
    out_valid,
    // output
    clk,
    rst,
    in_data,
    in_valid
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg clk;
output reg rst;
output reg [7:0] in_data;
output reg in_valid;

input [7:0] out_data;
input out_valid;
//================================================================
// parameters & integer
//================================================================
integer PATNUM = 10;
integer seed;
integer total_latency;
integer patcount;
integer i,j;
//================================================================
// wire & registers 
//================================================================
reg [7:0] in_data_save[63:0];
reg [7:0] in_data_golden[63:0];
reg [7:0] in_data_len;
reg [7:0] out_data_len;
//================================================================
// clock
//================================================================
real	CYCLE = `CYCLE_TIME;
always	#(CYCLE/2.0) clk = ~clk;
initial	clk = 0;
integer  a;
//================================================================
// initial
//================================================================
initial begin

    in_data = 8'dx;
    in_valid = 0;
	rst = 0;
    
	reset_task;

	total_latency = 0;
	seed = 32;
    @(negedge clk);

	for(patcount = 0; patcount < PATNUM; patcount = patcount + 1)
	begin		
		gen_lab2_practice_data;
		gen_lab2_practice_golden;
		check_lab2_practice_ans;

        $display ("         lab2_practice  Pass Pattern NO. %d          ", patcount);

		repeat(2 + {$random(seed)} % 8) @(negedge clk);
	end
    
	display_pass;
    
    repeat(3) @(negedge clk);
    $finish;
end

always @(*) begin
    if (in_valid === 1 && out_valid === 1) begin
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  output_valid should not be high when in_valid is high                                      ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	    $finish ;
    end
end

always @(posedge clk) begin
    total_latency = total_latency + 1;
    if (total_latency >= 10000) begin
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                             Simulation cycle limit reach                                                  ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	    $finish ;
    end

end

//================================================================
// task
//================================================================
task reset_task ; begin
    @(negedge clk);
    rst = 1;
    @(negedge clk);
    rst = 0;
    repeat(2) @(negedge clk);
	if((out_data !== 0 || out_valid !== 0)) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	    $finish ;
	end
end endtask

task gen_lab2_practice_data; begin
    in_data_len = 10 + {$random(seed)} % 53; // 10 ~ 64
    for (i=0; i<in_data_len; i=i+1) begin
        in_data = i;
        in_data_save[i] = in_data;
        in_valid = 1;
        @(negedge clk);
    end
    in_data = 8'dx;
    in_valid = 1'b0;
end endtask


task gen_lab2_practice_golden; begin
    for (i=0; i<in_data_len; i=i+1) begin
        in_data_golden[i] = in_data_save[i] + 1;
        case({in_data_golden[i][7], in_data_golden[i][0]})
            2'b00 : begin
                in_data_golden[i] = 8'd0;
            end
            2'b11 : begin
                in_data_golden[i] = 8'b11111111;
            end
            default : begin
                in_data_golden[i] = in_data_golden[i];
            end
        endcase
    end 
end endtask

task check_lab2_practice_ans; begin
    
    while(out_valid !== 1) begin
        @(negedge clk);
    end

    for (i=0; i<in_data_len; i=i+1) begin
        if (out_valid === 0) begin
            display_fail;
            $display ("-------------------------------------------------------------------");
            $display("                       PATTERN NO.%4d Word index NO.%8d 	     ",patcount, i);
            $display ("                            out_valid end early           ");
            $display ("-------------------------------------------------------------------");
            #(100);
            $finish ;
        end
        if(out_data !== in_data_golden[i])
        begin
            display_fail;
            $display ("-------------------------------------------------------------------");
            $display("                       PATTERN NO.%4d Word index NO.%8d 	     ",patcount, i);
            $display ("             answer should be : %11d , your answer is : %11d           ", in_data_golden[i], out_data);
            $display ("-------------------------------------------------------------------");
            #(100);
            $finish ;
        end
        @(negedge clk);
    end
    if (out_valid !== 0) begin
        display_fail;
        $display ("-------------------------------------------------------------------");
        $display("                                PATTERN NO.%4d	     ",patcount);
        $display ("                            out_valid didn't end                  ");
        $display ("-------------------------------------------------------------------");
        #(100);
        $finish ;
    end
end
endtask

task display_fail;
begin
    $display("======   lab2_practice  Error    ========");
    $display("\n");
end
endtask

task display_pass;
begin
    $display("=================   lab2_practice  Your colleagues used the information defeating the enemy.    ==============================");
    $display("\n");
end
endtask

endmodule


module Lab2_PRACTICE_TESTBED; 

//Connection wires
wire [7:0] in_data;
wire clk;
wire rst;
wire [7:0] out_data; 
wire in_valid, out_valid;

initial begin
  `ifdef RTL
    $dumpfile("DUT.vcd");
    $dumpvars("+all");
  `endif
end

Lab2_PRACTICE My_practice(
.clk(clk),
.rst(rst),
.in_data(in_data),
.in_valid(in_valid),
.out_data(out_data),
.out_valid(out_valid)
);

Lab2_PRACTICE_PATTERN My_PATTERN(
.clk(clk),
.rst(rst),
.in_data(in_data),
.in_valid(in_valid),
.out_data(out_data),
.out_valid(out_valid)
);
 
endmodule
