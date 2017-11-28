module Forward
(
    EX_MEM_RegWrite_i,
    MEM_WB_RegWrite_i,
    EX_MEM_RegRd_i,
    ID_EX_RegRs_i,
    ID_EX_RegRt_i,
    MEM_WB_RegRd_i,
    forwardA_o,
    forwardB_o
);

input       [4:0]   EX_MEM_RegRd_i, ID_EX_RegRs_i, ID_EX_RegRt_i, MEM_WB_RegRd_i;
input               EX_MEM_RegWrite_i, MEM_WB_RegWrite_i;
output  reg [1:0]   forwardA_o, forwardB_o;

always @(*) begin
    if (EX_MEM_RegWrite_i &&
        EX_MEM_RegRd_i != 32'b0 &&
        EX_MEM_RegRd_i == ID_EX_RegRs_i) begin
        forwardA_o = 2'b10;
    end
    else if(MEM_WB_RegWrite_i &&
            MEM_WB_RegRd_i != 32'b0 &&
            EX_MEM_RegRd_i != ID_EX_RegRs_i &&
            MEM_WB_RegRd_i != ID_EX_RegRs_i) begin
        forwardA_o = 2'b01;
    end
    else begin
        forwardA_o = 2'b00;
    end
    if (EX_MEM_RegWrite_i &&
        EX_MEM_RegRd_i != 32'b0 &&
        EX_MEM_RegRd_i == ID_EX_RegRt_i) begin
        forwardB_o = 2'b10;
    end
    else if(MEM_WB_RegWrite_i &&
            MEM_WB_RegRd_i != 32'b0 &&
            EX_MEM_RegRd_i != ID_EX_RegRt_i &&
            MEM_WB_RegRd_i != ID_EX_RegRt_i) begin
        forwardB_o = 2'b01;
    end
    else begin
        forwardB_o = 2'b00;
    end
end

endmodule

