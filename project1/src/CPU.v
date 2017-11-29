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

wire [31:0] next_pc, now_pc, ID_pc;
wire [31:0] IF_inst, ID_inst;
wire [14:0] EX_inst;
wire [31:0] ID_ext, EX_ext;
wire [31:0] Jump_or_next, Branch_or_next, ctrl_or_nop;
wire [31:0] Branch_addr;
wire [31:0] always_zero;

wire [1:0]  ctrl_ALUOp;
wire        ctrl_RegDst, ctrl_ALUSrc;
wire        ctrl_MemWrite, ctrl_MemRead;  // MEM
wire        ctrl_MemtoReg, ctrl_RegWrite; // WB
wire        ctrl_Branch, ctrl_Jump;

wire        hazard, flush;
wire        ID_Eq;
wire [31:0] ID_rd1, EX_rd1, ID_rd2, EX_rd2;
wire [1:0]  EX_wb, MEM_wb, WB_wb;
wire [1:0]  EX_m, MEM_m;
wire [3:0]  EX_ex;
wire [4:0]  EX_RegDst, MEM_RegDst;
//
wire [31:0] post_M32;
wire [2:0]  ALU_ctrl;
wire [31:0] ALU_res, MEM_res, WB_res;
wire        zero;


assign always_zero = 0;
assign flush = (ID_Eq && ctrl_Branch) || ctrl_Jump;

//IF
PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .hazard_i   (hazard),
    .pc_i       (Jump_or_next),
    .pc_o       (now_pc)
);

Adder Add_PC(
    .data1_in   (now_pc),
    .data2_in   (32'd4),
    .data_o     (next_pc)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (now_pc), 
    .instr_o    (IF_inst)
);

MUX32 Mux_Branch(
    .data1_i    (next_pc),
    .data2_i    (Branch_addr),
    .select_i   (ID_Eq && ctrl_Branch),
    .data_o     (Branch_or_next)
);

MUX32 Mux_Jump(
    .data1_i    (Branch_or_next),
    .data2_i    ({Branch_or_next[31:28], ID_inst[25:0], 2'b0}),
    .select_i   (ctrl_Jump),
    .data_o     (Jump_or_next)
);

IF_ID IF_ID(
    .clk_i      (clk_i),
    .pc_i       (next_pc),
    .inst_i     (IF_inst),
    .hazard_i   (hazard),
    .flush_i    (flush),
    .pc_o       (ID_pc),
    .inst_o     (ID_inst)
);

//ID
Control Control(
    .Op_i       (ID_inst[31:26]),
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

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (ID_inst[25:21]),
    .RTaddr_i   (ID_inst[20:16]),
    .RDaddr_i   (), 
    .RDdata_i   (),
    .RegWrite_i (ctrl_RegWrite), 
    .RSdata_o   (ID_rd1), 
    .RTdata_o   (ID_rd2) 
);

Eq Eq(
    .in1        (ID_rd1),
    .in2        (ID_rd2),
    .out        (ID_Eq)
);

Sign_Extend Sign_Extend(
    .data_i     (ID_inst[15:0]),
    .data_o     (ID_ext)
);

Adder Add_Branch(
    .data1_in   ({ID_ext[31:2], 2'b0}),
    .data2_in   (ID_pc),
    .data_o     (Branch_addr)
);

Hazard Hazard(
    .ID_EX_MemRead_i    (EX_m[0]),
    .ID_EX_RdAddr_i     (EX_inst[10:6]),
    .IF_ID_inst_i       (ID_inst),
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
    .clk_i      (clk_i),
    .WB_i       (ctrl_or_nop[1:0]),
    .M_i        (ctrl_or_nop[3:2]),
    .EX_i       (ctrl_or_nop[7:4]),
    .data1_i    (ID_rd1),
    .data2_i    (ID_rd2),
    .ext_i      (ID_ext),
    .inst_i     (ID_inst[25:11]),
    .WB_o       (EX_wb),
    .M_o        (EX_m),
    .EX_o       (EX_ex),
    .data1_o    (EX_rd1),
    .data2_o    (EX_rd2),
    .ext_o      (EX_ext),
    .inst_o     (EX_inst)
);

//EX
MUX5 MUX_RegDst(
    .data1_i    (EX_inst[10:6]),
    .data2_i    (EX_inst[5:1]),
    .select_i   (EX_ex[1]),
    .data_o     (EX_RegDst)
);

ALU_Control ALU_Control(
    .funct_i    (EX_ext[5:0]),
    .ALUOp_i    (EX_ex[3:2]),
    .ALUCtrl_o  (ALU_ctrl)
);

ALU ALU(
    .data1_i    (),
    .data2_i    (),
    .ALUCtrl_i  (ALU_ctrl),
    .data_o     (ALU_res),
    .Zero_o     (zero)
);

EX_MEM EX_MEM(
    .clk_i      (clk_i),
    .WB_i       (EX_wb),
    .M_i        (EX_m),
    .ALUresult_i(ALU_res),
    .WriteData_i(),
    .RegDst_i   (EX_RegDst),
    .WB_o       (MEM_wb),
    .M_o        (MEM_m),
    .ALUresult_o(MEM_res),
    .WriteData_o(),
    .RegDst_o   (MEM_RegDst)
);

//MEM

Memory Memory(
    .clk_i      (clk_i),
    .Address_i  (),
    .WriteData_i(),
    .MemWrite_i (),
    .MemRead_i  (),
    .ReadData_o ()
);

MEM_WB MEM_WB(
    .clk_i      (clk_i),
    .WB_i       (MEM_wb),
    .ReadMem_i  (),
    .ALUresult_i(MEM_res),
    .RegRD_i    (),
    .WB_o       (WB_wb),
    .ReadMem_o  (),
    .ALUresult_o(WB_res),
    .RegRD_o    ()
);

//WB

MUX32 MUX_ALUSrc(
    .data1_i    (read_data2),
    .data2_i    (ID_ext),
    .select_i   (ctrl_ALUSrc),
    .data_o     (post_M32)
);

endmodule

