module Control
(
    Op_i,
    RegDst_o,
    ALUSrc_o, 
	MemtoReg,
    RegWrite_o,
	MemWrite_o,
	Branch_o,
	Jump_o,
	ExtOp_o,
    ALUOp_o
);

input		[5:0]	Op_i;
output		[2:0]	ALUOp_o;
output				RegDst_o, ALUSrc_o, MemtoReg, RegWrite_o,
output				MemWrite_o, Branch_o, Jump_o, ExtOp_o;
reg			[11:0]	tmp;
assign { RegDst_o, ALUSrc_o, MemtoReg, RegWrite_o,
	MemWrite_o, Branch_o, Jump_o, ExtOp_o, ALUOp_o } = tmp;

always @(*) begin
	case (Op_i)
		6'b000000: begin // r-type
			tmp = 12'b1001000x000 
		end
		6'b001000: begin // addi
			tmp = 12'b01010000001
		end
		6'b100011: begin // lw
			tmp = 12'b01110001010
		end
		6'b101011: begin // sw
			tmp = 12'bx1x01001010
		end
		6'b000100: begin // beq
			tmp = 12'bx0x0010x011
		end
		6'b000010: begin // jump
			tmp = 12'bxxx0001xxxx
		end
	endcase
end


endmodule
