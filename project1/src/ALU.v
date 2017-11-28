module ALU
(
	data1_i,
	data2_i,
	ALUCtrl_i,
	data_o,
	Zero_o
);

input		[31:0]		data1_i, data2_i;
input		[2:0]		ALUCtrl_i;
output		[31:0]		data_o;
output					Zero_o;

reg			[31:0]		tmp;
reg						zero_tmp;
assign data_o = tmp;
assign Zero_o = zero_tmp;

always @(*) begin
	case (ALUCtrl_i)
		3'd0:	tmp = data1_i & data2_i;
		3'd1:	tmp = data1_i | data2_i;
		3'd2:	tmp = data1_i + data2_i;
		3'd3:	tmp = data1_i - data2_i;
		3'd4:	tmp = data1_i * data2_i;
	endcase
	zero_tmp = (tmp == 32'd0);
end

endmodule
