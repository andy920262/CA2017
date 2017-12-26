module MEM_WB(
    clk_i,
    stall_i,
    WB_i,
    ReadMem_i,
    ALUresult_i,
    RegRD_i,
    WB_o,
    ReadMem_o,
    ALUresult_o,
    RegRD_o
);

// port
input           clk_i, stall_i;
input   [1:0]   WB_i;
input   [31:0]  ReadMem_i;
input   [31:0]  ALUresult_i;
input   [4:0]   RegRD_i;
output reg  [1:0]   WB_o;
output reg  [31:0]  ReadMem_o;
output reg  [31:0]  ALUresult_o;
output reg  [4:0]   RegRD_o;

initial begin
    WB_o <= 0;
    ReadMem_o <= 0;
    ALUresult_o <= 0;
    RegRD_o <= 0;
end

// Write Data   
always@(posedge clk_i) begin
    if (stall_i) begin
        WB_o <= WB_i;
        ReadMem_o <= ReadMem_i;
        ALUresult_o <= ALUresult_i;
        RegRD_o <= RegRD_i;
    end
    else begin
        WB_o <= WB_i;
        ReadMem_o <= ReadMem_i;
        ALUresult_o <= ALUresult_i;
        RegRD_o <= RegRD_i;
    end
end

endmodule // MEM_WB
