module Hazard
(
    ID_EX_MemRead_i,
    ID_EX_RdAddr_i,
    IF_ID_inst_i,
    hazard_o
);

input               ID_EX_MemRead_i;
input       [4:0]   ID_EX_RdAddr_i;
input       [31:0]  IF_ID_inst_i;
output  reg         hazard_o;

always @(*) begin

    if (ID_EX_MemRead_i && (IF_ID_inst_i[25:21] == ID_EX_RdAddr_i || IF_ID_inst_i[20:16] == ID_EX_RdAddr_i)) begin
        hazard_o = 1'b1;
    end
    else begin
        hazard_o = 1'b0;
    end
end

endmodule
