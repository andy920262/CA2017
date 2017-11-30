module Control
(
    Op_i,
    RegDst_o,
    ALUSrc_o, 
	MemtoReg_o,
    RegWrite_o,
	MemWrite_o,
	MemRead_o,
	Branch_o,
	Jump_o,
    ALUOp_o
);

input		[5:0]	Op_i;
output		[1:0]	ALUOp_o;
output				RegDst_o, ALUSrc_o, MemtoReg_o, RegWrite_o;
output				MemWrite_o, MemRead_o, Branch_o, Jump_o;
reg			[9:0]	tmp;
assign { RegDst_o, ALUSrc_o, MemtoReg_o, RegWrite_o,
	MemWrite_o, MemRead_o, Branch_o, Jump_o, ALUOp_o } = tmp;

always @(*) begin
	case (Op_i)
		6'b000000: begin // r-type
			tmp = 10'b1001000000;
		end
		6'b001000: begin // addi
			tmp = 10'b0101000001;
		end
		6'b100011: begin // lw
			tmp = 10'b0111010001;
		end
		6'b101011: begin // sw
			tmp = 10'bx1x01x0001;
		end
		6'b000100: begin // beq
			tmp = 10'bx0x00x1010;
		end
		6'b000010: begin // jump
			tmp = 10'bxxx00x01xx;
		end
	endcase
end


endmodule
