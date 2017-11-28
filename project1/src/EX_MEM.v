module EX_MEM(
    WB_i,
    M_i,
    ALUresult_i,
    WriteData_i,
    RegRD_i,
    WB_o,
    M_o,
    ALUresult_o,
    WriteData_o,
    RegRD_o
);

// port
input   [1:0]   WB_i;
input   [1:0]   M_i;
input   [31:0]  ALUresult_i;
input   [31:0]  WriteData_i;
input   [4:0]   RegRD_i;
output  reg [1:0]   WB_o;
output  reg [1:0]   M_o;
output  reg [31:0]  ALUresult_o;
output  reg [31:0]  WriteData_o;
output  reg [4:0]   RegRD_o;

initial begin
    WB_o <= 0;
    M_o <= 0;
    ALUresult_o <= 0;
    WriteData_o <= 0;
    RegRD_o <= 0;
end

always@(posedge clk_i) begin
    WB_o <= WB_i;
    M_o <= M_i;
    ALUresult_o <= ALUresult_i;
    WriteData_o <= WriteData_i;
    RegRD_o <= RegRD_i;
end

endmodule // EX_MEM