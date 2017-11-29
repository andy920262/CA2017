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

wire [31:0] next_pc, now_pc, IFID_pc;
wire [31:0] IM_inst, extended, IFID_inst, IDEX_inst;
wire [31:0] Jump_or_next, Branch_or_next, ctrl_or_nop;
wire [31:0] Branch_addr;
wire [31:0] always_zero;
wire [1:0]  ctrl_ALUOp;
wire        ctrl_RegDst, ctrl_ALUSrc;
wire        ctrl_MemWrite, ctrl_MemRead; // MEM
wire        ctrl_MemtoReg, ctrl_RegWrite; // WB
wire        ctrl_Branch, ctrl_Jump;
wire        hazard, flush;
wire        Eq_o;
wire [31:0] read_data1, read_data2;
wire [1:0]  IDEX_wb, ;
wire [1:0]  IDEX_m;
wire [3:0]  IDEX_ex;
wire [31:0] IDEX_d1, IDEX_d2;
wire [31:0] IDEX_ext;


//
wire [4:0]  post_M5;
wire [31:0] post_M32;
wire [2:0]  ALU_ctrl;
wire [31:0] ALU_o;
wire        zero;


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
    .MemRead_o  (ctrl_MemRead),
    .MemtoReg_o (ctrl_MemtoReg),
    .Branch_o   (ctrl_Branch),
    .Jump_o     (ctrl_Jump)
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
    .data1_in   ({extended[31:2], 2'b0}),
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
    .data2_i    ({Branch_or_next[31:28], IFID_inst[25:0], 2'b0}),
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

Eq Eq(
    .in1        (read_data1),
    .in2        (read_data2),
    .out        (Eq_o)
);

Hazard Hazard(
    .ID_EX_MemRead_i    (IDEX_m[0]),
    .ID_EX_RdAddr_i     (IDEX_inst[10:6]),
    .IF_ID_inst_i       (IFID_inst),
    .hazard_o           (hazard)
);

MUX32 Mux_Harzard_Control(
    .data1_i    ({24'b0, ctrl_ALUOp, ctrl_RegDst, ctrl_ALUSrc, 
        ctrl_MemWrite, ctrl_MemRead, ctrl_MemtoReg, ctrl_RegWrite}),
    .data2_i    (always_zero),
    .select_i   (hazard),
    .data_o     (ctrl_or_nop)
);

ID_EX ID_EX(
    .WB_i       (ctrl_or_nop[1:0]),
    .M_i        (ctrl_or_nop[3:2]),
    .EX_i       (ctrl_or_nop[7:4]),
    .data1_i    (read_data1),
    .data2_i    (read_data2),
    .ext_i      (extended),
    .inst_i     (IFID_inst[25:11]),
    .WB_o       (IDEX_wb),
    .M_o        (IDEX_m),
    .EX_o       (IDEX_ex),
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

