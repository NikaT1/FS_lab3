module clk_div(
    input clk,

    output clk2
);

reg [9:0]cnt = 0;

assign clk2 = cnt[9];

always @(posedge clk) begin
    cnt <= cnt + 10'b1;
end

endmodule