module Control
(
    Op_i,
    RegDst_o,
    ALUSrc_o, 
	MemtoReg,
    RegWrite_o,
	MemWrite_o,
	MemRead_o,
	Branch_o,
	Jump_o,
	ExtOp_o,
    ALUOp_o
);

input		[5:0]	Op_i;
output		[2:0]	ALUOp_o;
output				RegDst_o, ALUSrc_o, MemtoReg, RegWrite_o;
output				MemWrite_o, MemRead_o, Branch_o, Jump_o, ExtOp_o;
reg			[12:0]	tmp;
assign { RegDst_o, ALUSrc_o, MemtoReg, RegWrite_o,
	MemWrite_o, MemRead_o, Branch_o, Jump_o, ExtOp_o, ALUOp_o } = tmp;

always @(*) begin
	case (Op_i)
		6'b000000: begin // r-type
			tmp = 13'b10010000x000 
		end
		6'b001000: begin // addi
			tmp = 13'b010100000001
		end
		6'b100011: begin // lw
			tmp = 13'b011101001010
		end
		6'b101011: begin // sw
			tmp = 13'bx1x01x001010
		end
		6'b000100: begin // beq
			tmp = 13'bx0x00x10x011
		end
		6'b000010: begin // jump
			tmp = 13'bxxx00x01xxxx
		end
	endcase
end


endmodule
