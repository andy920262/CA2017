module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

wire [31:0] inst_addr, inst, extended;
wire        ctrl_RegDst;
wire        ctrl_ALUSrc;
wire        ctrl_RegWrite;
wire [1:0]  ctrl_ALUOp;
wire [31:0] read_data1, read_data2;
wire [31:0] next_pc, now_pc;
wire [4:0]  post_M5;
wire [31:0] post_M32;
wire [2:0]  ALU_ctrl;
wire [31:0] ALU_o;
wire        zero;

Control Control(
    .Op_i       (inst[31:26]),
    .RegDst_o   (ctrl_RegDst),
    .ALUOp_o    (ctrl_ALUOp),
    .ALUSrc_o   (ctrl_ALUSrc),
    .RegWrite_o (ctrl_RegWrite)
);

Adder Add_PC(
    .data1_in   (now_pc),
    .data2_in   (32'd4),
    .data_o     (next_pc)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (next_pc),
    .pc_o       (now_pc)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (now_pc), 
    .instr_o    (inst)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[25:21]),
    .RTaddr_i   (inst[20:16]),
    .RDaddr_i   (post_M5), 
    .RDdata_i   (ALU_o),
    .RegWrite_i (ctrl_RegWrite), 
    .RSdata_o   (read_data1), 
    .RTdata_o   (read_data2) 
);

MUX5 MUX_RegDst(
    .data1_i    (inst[20:16]),
    .data2_i    (inst[15:11]),
    .select_i   (ctrl_RegDst),
    .data_o     (post_M5)
);

MUX32 MUX_ALUSrc(
    .data1_i    (read_data2),
    .data2_i    (extended),
    .select_i   (ctrl_ALUSrc),
    .data_o     (post_M32)
);

Sign_Extend Sign_Extend(
    .data_i     (inst[15:0]),
    .data_o     (extended)
);
  

ALU ALU(
    .data1_i    (read_data1),
    .data2_i    (post_M32),
    .ALUCtrl_i  (ALU_ctrl),
    .data_o     (ALU_o),
    .Zero_o     (zero)
);

ALU_Control ALU_Control(
    .funct_i    (inst[5:0]),
    .ALUOp_i    (ctrl_ALUOp),
    .ALUCtrl_o  (ALU_ctrl)
);

endmodule

