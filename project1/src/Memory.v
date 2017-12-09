module Memory
(
    clk_i,
    Address_i,
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
// reg                 ReadData_o;

// Register File
reg     [7:0]  mem [0:31];

// Read Data
assign ReadData_o = {mem[Address_i + 3], mem[Address_i + 2], mem[Address_i + 1], mem[Address_i]};
// always@(negedge clk_i or posedge clk_i) begin
//     if(MemRead_i)
//         ReadData_o = {mem[Address_i + 3], mem[Address_i + 2], mem[Address_i + 1], mem[Address_i]};
// end

// Write Data   
always@(posedge clk_i) begin
    if(MemWrite_i) begin
        mem[Address_i]		<= WriteData_i[7:0];
        mem[Address_i + 1]	<= WriteData_i[15:8];
        mem[Address_i + 2]	<= WriteData_i[23:16];
        mem[Address_i + 3]	<= WriteData_i[31:24];
        
        /* This sometime not work ?????? */
        //{mem[Address_i + 3], mem[Address_i + 2], mem[Address_i + 1], mem[Address_i]} = WriteData_i;
    end
end
   
endmodule 
