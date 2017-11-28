module ALU_Control
(
	funct_i,
	ALUOp_i,
	ALUCtrl_o
);

input			[5:0]	funct_i;
input			[1:0]	ALUOp_i;
output			[2:0]	ALUCtrl_o;

reg				[2:0]	tmp;
assign ALUCtrl_o = tmp;

always @(*) begin
	if (ALUOp_i == 2'b01)
		tmp = 3'd2;
	
	else
		case (funct_i)
			6'b100100:	tmp = 3'd0;
			6'b100101:	tmp = 3'd1;
			6'b100000:	tmp = 3'd2;
			6'b100010:	tmp = 3'd3;
			6'b011000:	tmp = 3'd4;
		endcase

end

endmodule

