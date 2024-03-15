module clk_div(
    input clk,

    output clk2
);

reg [20:0]cnt = 0;

assign clk2 = cnt[20];

always @(posedge clk) begin
    cnt <= cnt + 21'b1;
end

endmodule