module Forward
(
    EXMEM_rw_i,
    MEMWB_rw_i,
    EXMEM_rd_i,
    MEMWB_rd_i,
    IDEX_rs_i,
    IDEX_rt_i,
    forwardA_o,
    forwardB_o
);

input       [4:0]   EXMEM_rd_i, IDEX_rs_i, IDEX_rt_i, MEMWB_rd_i;
input               EXMEM_rw_i, MEMWB_rw_i;
output  reg [1:0]   forwardA_o, forwardB_o;

always @(*) begin
    if (EXMEM_rw_i &&
        EXMEM_rd_i != 32'b0 &&
        EXMEM_rd_i == IDEX_rs_i) begin
        forwardA_o = 2'b10;
    end
    else if(MEMWB_rw_i &&
            MEMWB_rd_i != 32'b0 &&
            EXMEM_rd_i != IDEX_rs_i &&
            MEMWB_rd_i != IDEX_rs_i) begin
        forwardA_o = 2'b01;
    end
    else begin
        forwardA_o = 2'b00;
    end
    if (EXMEM_rw_i &&
        EXMEM_rd_i != 32'b0 &&
        EXMEM_rd_i == IDEX_rt_i) begin
        forwardB_o = 2'b10;
    end
    else if(MEMWB_rw_i &&
            MEMWB_rd_i != 32'b0 &&
            EXMEM_rd_i != IDEX_rt_i &&
            MEMWB_rd_i != IDEX_rt_i) begin
        forwardB_o = 2'b01;
    end
    else begin
        forwardB_o = 2'b00;
    end
end

endmodule

