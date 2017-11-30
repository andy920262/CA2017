module IF_ID
(
    clk_i,
    pc_i,
    inst_i,
    hazard_i,
    flush_i,
    pc_o,
    inst_o
);

input       [31:0]  pc_i, inst_i;
input               clk_i, hazard_i, flush_i;
output  reg [31:0]  pc_o, inst_o;

initial begin
    pc_o = 0;
    inst_o = 0;
end

always @(posedge clk_i) begin
    if (flush_i) begin
        pc_o <= 0;
        inst_o <= 0;
    end
    else if (hazard_i) begin
        pc_o <= pc_i;
        inst_o <= inst_i;
    end
end

endmodule


