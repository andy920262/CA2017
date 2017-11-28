module Control
(
    Op_i,
    RegDst_o,
    ALUOp_o,
    ALUSrc_o, 
    RegWrite_o
);

input		[5:0]	Op_i;
output		[1:0]	ALUOp_o;
output				RegDst_o, ALUSrc_o, RegWrite_o;

reg			[4:0]	tmp;
assign {ALUOp_o, RegDst_o, ALUSrc_o, RegWrite_o} = tmp;


always @(*) begin
	case (Op_i)
		6'b000000: begin // r-type
			tmp[4:3] = 2'b00;
			tmp[2] = 1'b1;
			tmp[1] = 1'b0;
			tmp[0] = 1'b1;
		end
		6'b001000: begin // addi
			tmp[4:3] = 2'b01;
			tmp[2] = 1'b0;
			tmp[1] = 1'b1;
			tmp[0] = 1'b1;
		end
	endcase
end


endmodule
