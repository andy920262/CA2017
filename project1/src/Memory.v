module Memory
(
    clk_i,
    Address_i.
    WriteData_i,
    MemWrite_i,
    MemRead_i,
    ReadData_o
);

// Ports
input               clk_i;
input               MemRead_i;
input               MemWrite_i;
input   [31:0]      Address_i;
input   [31:0]      WriteData_i;
output  [31:0]      ReadData_o;

// Register File
reg     [31:0]  mem [0:7];

// Read Data      
always@(negedge clk_i) begin
    if(MemRead_i)
        ReadData_o = mem[Address_i];
end

// Write Data   
always@(posedge clk_i) begin
    if(RegWrite_i)
        register[RDaddr_i] = RDdata_i;
end
   
endmodule 
