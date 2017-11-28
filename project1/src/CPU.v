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

wire [31:0] IM_inst, IFID_inst, extended;
wire [31:0] Branch_addr;
wire        ctrl_RegDst;
wire        ctrl_ALUSrc;
wire        ctrl_RegWrite;
wire [1:0]  ctrl_ALUOp;
wire        ctrl_MemtoReg;
wire        ctrl_MemWrite;
wire        ctrl_Branch;
wire        ctrl_Jump;
wire        ctrl_ExtOp;
wire        hazard, flush;
wire        Jump_or_next, Branch_or_next, ctrl_or_nop;
wire        Eq_o;
wire [31:0] read_data1, read_data2;
wire [31:0] next_pc, now_pc, IFID_pc;
wire [4:0]  post_M5;
wire [31:0] post_M32;
wire [2:0]  ALU_ctrl;
wire [31:0] ALU_o;
wire        zero;
wire [31:0] always_zero;

assign always_zero = 0;
assign flush = (Eq_o && ctrl_Branch) || ctrl_Jump;

Adder Add_PC(
    .data1_in   (now_pc),
    .data2_in   (32'd4),
    .data_o     (next_pc)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (now_pc), 
    .instr_o    (IM_inst)
);

Control Control(
    .Op_i       (IFID_inst[31:26]),
    .RegDst_o   (ctrl_RegDst),
    .ALUOp_o    (ctrl_ALUOp),
    .ALUSrc_o   (ctrl_ALUSrc),
    .MemWrite_o (ctrl_MemWrite),
    .RegWrite_o (ctrl_RegWrite),
    .MemtoReg_o (ctrl_MemtoReg),
    .Branch_o   (ctrl_Branch),
    .Jump_o     (ctrl_Jump),
    .ExtOp_o    (ctrl_ExtOp)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .hazard_i   (hazard),
    .pc_i       (Jump_or_next),
    .pc_o       (now_pc)
);

Sign_Extend Sign_Extend(
    .data_i     (IFID_inst[15:0]),
    .data_o     (extended)
);

Adder Add_Branch(
    .data1_in   ({extended[31:2], 2'b00}),
    .data2_in   (IFID_pc),
    .data_o     (Branch_addr)
);

MUX32 Mux_Branch(
    .data1_i    (next_pc),
    .data2_i    (Branch_addr),
    .select_i   (Eq_o && ctrl_Branch),
    .data_o     (Branch_or_next)
);

MUX32 Mux_Jump(
    .data1_i    (Branch_or_next),
    .data2_i    ({Branch_or_next[31:28], IFID_inst[25:0], 2'b00}),
    .select_i   (ctrl_Jump),
    .data_o     (Jump_or_next)
);

IF_ID IF_ID(
    .clk_i      (clk_i),
    .pc_i       (next_pc),
    .inst_i     (IM_inst),
    .hazard_i   (hazard),
    .flush_i    (flush),
    .pc_o       (IFID_pc),
    .inst_o     (IFID_inst)
);

//
MUX32 Mux_Harzard_Control(
    .data1_i    ({}),
    .data2_i    (always_zero),
    .select_i   (hazard),
    .data_o     (ctrl_or_nop)
);

Eq Eq(
    .in1        (read_data1),
    .in2        (read_data2),
    .out        (Eq_o)
);
//
Hazard Hazard(
    ID_EX_MemRead_i   (),
    ID_EX_RdAddr_i    (),
    IF_ID_inst_i(IFID_inst),
    hazard_o    (hazard)
);
//
ID_EX ID_EX(
    .WB_i       (ctrl_or_nop),
    .M_i        (ctrl_or_nop),
    .EX_i       (ctrl_or_nop),
    .data1_i    (read_data1),
    .data2_i    (read_data2),
    .ext_i      (extended),
    .inst_i     (IFID_inst[25:11]),
    .WB_o       (IDEX_wb),
    .M_i        (IDEX_m),
    .EX_i       (IDEX_ex),
    .data1_o    (IDEX_d1),
    .data2_o    (IDEX_d2),
    .ext_o      (IDEX_ext),
    .inst_o     (IDEX_inst)
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

