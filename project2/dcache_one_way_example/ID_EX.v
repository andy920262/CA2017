module ID_EX
(
    clk_i,
    stall_i,
    WB_i,
    M_i,
    EX_i,
    data1_i,
    data2_i,
    ext_i,
    inst_i,
    WB_o,
    M_o,
    EX_o,
    data1_o,
    data2_o,
    ext_o,
    inst_o
);

input               clk_i, stall_i;
input       [1:0]   WB_i, M_i;
input       [3:0]   EX_i;
input       [31:0]  data1_i, data2_i, ext_i;
input       [14:0]  inst_i;

output  reg     [1:0]   WB_o, M_o;
output  reg     [3:0]   EX_o;
output  reg     [31:0]  data1_o, data2_o, ext_o;
output  reg     [14:0]  inst_o;

initial begin
    WB_o = 0;
    M_o = 0;
    EX_o = 0;
    data1_o = 0;
    data2_o = 0;
    ext_o = 0;
    inst_o = 0;
end

always@(posedge clk_i) begin
    if (stall_i) begin
        WB_o <= WB_o;
        M_o <= M_o;
        EX_o <= EX_o;
        data1_o <= data1_o;
        data2_o <= data2_o;
        ext_o <= ext_o;
        inst_o <= inst_o;
    end
    else begin
        WB_o <= WB_i;
        M_o <= M_i;
        EX_o <= EX_i;
        data1_o <= data1_i;
        data2_o <= data2_i;
        ext_o <= ext_i;
        inst_o <= inst_i;
    end
end

endmodule
