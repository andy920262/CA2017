module MEM_WB(
    clk_i,
    WB_i,
    ReadMem_i,
    ALUresult_i,
    RDdata_i,
    WB_o,
    ReadMem_o,
    ALUresult_o,
    RDdata_o
);

// port
input           clk_i;
input   [1:0]   WB_i;
input   [31:0]  ReadMem_i;
input   [31:0]  ALUresult_i;
input   [4:0]   RDdata_i;
output reg  [1:0]   WB_o;
output reg  [31:0]  ReadMem_o;
output reg  [31:0]  ALUresult_o;
output reg  [4:0]   RDdata_o;

initial begin
    WB_o <= 0;
    ReadMem_o <= 0;
    ALUresult_o <= 0;
    RDdata_o <= 0;
end

// Write Data   
always@(posedge clk_i) begin
    WB_o <= WB_i;
    ReadMem_o <= ReadMem_i;
    ALUresult_o <= ALUresult_i;
    RDdata_o <= RDdata_i;
end

endmodule // MEM_WB