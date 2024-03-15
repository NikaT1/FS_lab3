module display(
    input clk,
    input [4:0]data,

    output [4:0]anodes,
    output [6:0]segments
);

reg [2:0]i = 0;

assign anodes = (5'b1 << i);

always @(posedge clk) begin
    if (i[2] == 1) begin
        i <= 3'b0;
    end else begin
         i <= i + 3'b1;
    end
end

wire b = data[i];

dig_to_sig dig_to_sig1(.data(b), .segments(segments));

endmodule