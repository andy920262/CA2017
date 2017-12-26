module Eq(
    in1,
    in2,
    out
);

input   [31:0]  in1, in2;
output  reg     out;

always@(*) begin
    if (in1 == in2) begin
        out <= 1;
    end
    else begin
        out <= 0;
    end
end

endmodule // Eq