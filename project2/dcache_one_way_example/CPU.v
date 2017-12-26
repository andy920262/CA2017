module CPU
(
	clk_i,
	rst_i,
	start_i,
   
	mem_data_i, 
	mem_ack_i, 	
	mem_data_o, 
	mem_addr_o, 	
	mem_enable_o, 
	mem_write_o
);

//input
input clk_i;
input rst_i;
input start_i;

//
// to Data Memory interface		
//
input	[256-1:0]	mem_data_i; 
input				mem_ack_i; 	
output	[256-1:0]	mem_data_o; 
output	[32-1:0]	mem_addr_o; 	
output				mem_enable_o; 
output				mem_write_o;

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
wire [4:0]  EX_RegDst, MEM_RegDst, WB_RegDst;
wire [31:0] MEM_data, WB_data, WB_wdata;
wire [1:0]  forwardA, forwardB;
wire [2:0]  ALU_ctrl;
wire [31:0] ALU_res, MEM_res, WB_res;
wire [31:0] EX_wd, MEM_wd;
wire [31:0] ALU_in1, ALU_in2;
wire [31:0] post_fa, post_fb;
wire        zero;

wire		stall;

assign always_zero = 0;
assign flush = (ID_Eq && ctrl_Branch) || ctrl_Jump;
assign ALU_in1 = post_fa;
assign EX_wd = post_fb;

//
// add your project1 here!
//

//IF
PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
	.stall_i	(stall),
    .hazard_i   (hazard),
    .pc_i       (Jump_or_next),
    .pc_o       (now_pc)
);

Adder Add_PC(
    .data1_i    (now_pc),
    .data2_i    (32'd4),
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
    .stall_i    (stall),
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
    .RDaddr_i   (WB_RegDst), 
    .RDdata_i   (WB_wdata),
    .RegWrite_i (WB_wb[0]), 
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
    .data1_i    ({ID_ext[29:0], 2'b0}),
    .data2_i    (ID_pc),
    .data_o     (Branch_addr)
);

Hazard Hazard(
    .ID_EX_MemRead_i    (EX_m[0]),
    .ID_EX_RdAddr_i     (EX_inst[9:5]),
    .IF_ID_inst_i       (ID_inst),
    .hazard_o           (hazard)
);

MUX32 Mux_Hazard_Control(
    .data1_i    ({24'b0, ctrl_ALUOp, ctrl_RegDst, ctrl_ALUSrc, 
        ctrl_MemWrite, ctrl_MemRead, ctrl_MemtoReg, ctrl_RegWrite}),
    .data2_i    (always_zero),
    .select_i   (hazard),
    .data_o     (ctrl_or_nop)
);

ID_EX ID_EX(
    .clk_i      (clk_i),
    .stall_i    (stall),
    .WB_i       (ctrl_or_nop[1:0]),
    .M_i        (ctrl_or_nop[3:2]),
    .EX_i       (ctrl_or_nop[7:4]),
    .data1_i    (ID_rd1),
    .data2_i    (ID_rd2),
    .ext_i      (ID_ext),
    .inst_i     (ID_inst[25:11]),
    .WB_o       (EX_wb),
    .M_o        (EX_m), // MemWrtie, MemRead
    .EX_o       (EX_ex),
    .data1_o    (EX_rd1),
    .data2_o    (EX_rd2),
    .ext_o      (EX_ext),
    .inst_o     (EX_inst)
);

//EX
MUX5 MUX_RegDst(
    .data1_i    (EX_inst[9:5]),
    .data2_i    (EX_inst[4:0]),
    .select_i   (EX_ex[1]),
    .data_o     (EX_RegDst)
);

MUX32_3 MUX_ForwardA(
    .data1_i    (EX_rd1),
    .data2_i    (WB_wdata),
    .data3_i    (MEM_res),
    .select_i   (forwardA),
    .data_o     (post_fa)
);

MUX32_3 MUX_ForwardB(
    .data1_i    (EX_rd2),
    .data2_i    (WB_wdata),
    .data3_i    (MEM_res),
    .select_i   (forwardB),
    .data_o     (post_fb)
);

MUX32 MUX_ALUSrc(
    .data1_i    (post_fb),
    .data2_i    (EX_ext),
    .select_i   (EX_ex[0]),
    .data_o     (ALU_in2)
);

ALU_Control ALU_Control(
    .funct_i    (EX_ext[5:0]),
    .ALUOp_i    (EX_ex[3:2]),
    .ALUCtrl_o  (ALU_ctrl)
);

ALU ALU(
    .data1_i    (ALU_in1),
    .data2_i    (ALU_in2),
    .ALUCtrl_i  (ALU_ctrl),
    .data_o     (ALU_res),
    .Zero_o     (zero)
);

EX_MEM EX_MEM(
    .clk_i      (clk_i),
    .stall_i    (stall),
    .WB_i       (EX_wb),
    .M_i        (EX_m),
    .ALUresult_i(ALU_res),
    .WriteData_i(EX_wd),
    .RegDst_i   (EX_RegDst),
    .WB_o       (MEM_wb),
    .M_o        (MEM_m),
    .ALUresult_o(MEM_res),
    .WriteData_o(MEM_wd),
    .RegDst_o   (MEM_RegDst)
);

//MEM

MEM_WB MEM_WB(
    .clk_i      (clk_i),
    .stall_i    (stall),
    .WB_i       (MEM_wb),
    .ReadMem_i  (MEM_data),
    .ALUresult_i(MEM_res),
    .RegRD_i    (MEM_RegDst),
    .WB_o       (WB_wb),
    .ReadMem_o  (WB_data),
    .ALUresult_o(WB_res),
    .RegRD_o    (WB_RegDst)
);

//WB
MUX32 MUX_MemtoReg(
    .data1_i    (WB_res),
    .data2_i    (WB_data),
    .select_i   (WB_wb[1]),
    .data_o     (WB_wdata)
);

Forward Forward(
    .EXMEM_rw_i (MEM_wb[0]),
    .MEMWB_rw_i (WB_wb[0]),
    .EXMEM_rd_i (MEM_RegDst),
    .MEMWB_rd_i (WB_RegDst),
    .IDEX_rs_i  (EX_inst[14:10]),
    .IDEX_rt_i  (EX_inst[9:5]),
    .forwardA_o (forwardA),
    .forwardB_o (forwardB)
);

//data cache
dcache_top dcache
(
    // System clock, reset and stall
	.clk_i(clk_i), 
	.rst_i(rst_i),
	
	// to Data Memory interface
	.mem_data_i(mem_data_i),
	.mem_ack_i(mem_ack_i),
	.mem_data_o(mem_data_o),
	.mem_addr_o(mem_addr_o),
	.mem_enable_o(mem_enable_o),
	.mem_write_o(mem_write_o),
	
	// to CPU interface
	.p1_data_i(MEM_wd),
	.p1_addr_i(MEM_res),
	.p1_MemRead_i(MEM_m[0]),
	.p1_MemWrite_i(MEM_m[1]),
	.p1_data_o(MEM_data),
	.p1_stall_o(stall)
);

endmodule