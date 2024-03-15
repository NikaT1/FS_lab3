module top(
    input clk,
    input [ 4 : 0 ] y_bi,
    output DS_EN1, DS_EN2, DS_EN3, DS_EN4, DS_EN5,
    output DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G
);

wire [4:0] anodes;
assign {DS_EN1, DS_EN2, DS_EN3, DS_EN4, DS_EN5} = ~anodes;

wire [6:0]segments;
assign {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = segments;

wire clk2;

clk_div clk_div(.clk(clk), .clk2(clk2));

display disp(.clk(clk2), .data(y_bi), .anodes(anodes), .segments(segments));

endmodule