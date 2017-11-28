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
	case (ALUOp_i)
		2'b01:
			tmp = 3'd2;
		2'b00: // R-type
			case (funct_i)
				6'b100100:	tmp = 3'd0; // and
				6'b100101:	tmp = 3'd1; // or
				6'b100000:	tmp = 3'd2; // plus
				6'b100010:	tmp = 3'd3; // minus
				6'b011000:	tmp = 3'd4; // multiply
			endcase
		2'b10: // beq
			tmp = 3'd3
	endcase
end

endmodule

