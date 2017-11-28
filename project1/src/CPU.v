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

wire [31:0] inst_addr, IM_inst, IFID_inst, extended;
wire        ctrl_RegDst;
wire        ctrl_ALUSrc;
wire        ctrl_RegWrite;
wire [1:0]  ctrl_ALUOp;
wire        ctrl_MemtoReg;
wire        ctrl_MemWrite;
wire        ctrl_Branch;
wire        ctrl_Jump;
wire        ctrl_ExtOp;
wire        harzard, flush;

wire [31:0] read_data1, read_data2;
wire [31:0] next_pc, now_pc, IFID_pc;
wire [4:0]  post_M5;
wire [31:0] post_M32;
wire [2:0]  ALU_ctrl;
wire [31:0] ALU_o;
wire        zero;
wire [31:0] always_zero;

Control Control(
    .Op_i       (IFID_inst[31:26]),
    .RegDst_o   (ctrl_RegDst),
    .ALUOp_o    (ctrl_ALUOp),
    .ALUSrc_o   (ctrl_ALUSrc),
    .RegWrite_o (ctrl_RegWrite),
    .MemtoReg_o (ctrl_MemtoReg),
    .MemWrite_o (ctrl_MemWrite),
    .Branch_o   (ctrl_Branch),
    .Jump_o     (ctrl_Jump),
    .ExtOp_o    (ctrl_ExtOp)
);

Adder Add_PC(
    .data1_in   (now_pc),
    .data2_in   (32'd4),
    .data_o     (next_pc)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (now_pc), 
    .instr_o    (IM_inst)
);

IF_ID IF_ID(
    .clk_i      (clk_i),
    .pc_i       (next_pc),
    .inst_i     (IM_inst),
    .harzard_i  (harzard),
    .flush_i    (flush),
    .pc_o       (IFID_pc),
    .inst_o     (IFID_inst)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .hazard_i   (harzard),
    .pc_i       (next_pc),
    .pc_o       (now_pc)
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

