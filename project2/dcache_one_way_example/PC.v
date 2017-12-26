module PC
(
	clk_i,
    rst_i,
	start_i,
	stall_i,
	hazard_i,
	pc_i,
	pc_o
);

// Interface
input				clk_i;
input				rst_i;
input				start_i;
input				stall_i;
input				hazard_i;
input	[31:0]		pc_i;
output	[31:0]		pc_o;

// Signals
reg		[31:0]		pc_o;

always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i) begin
        pc_o <= 32'b0;
    end
    else begin
    	if(stall_i) begin
    	end
    	else if(start_i && !hazard_i)
			pc_o <= pc_i;
    	else
    		pc_o <= pc_o;
    end
end

endmodule
