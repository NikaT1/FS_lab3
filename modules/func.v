`timescale 1ns / 1ps
module func (        
        input clk_i,
        input rst_i,        
        input [ 7 : 0 ] a_bi,    
        input [ 7 : 0 ] b_bi,    
        input start_i,
        output [ 1 : 0 ] busy_o,   
        output reg [ 4 : 0 ] y_bo
    );
        
    localparam IDLE = 3'h0;
    localparam WORK_CALC_B = 3'h1;    
    localparam WORK_CALC_SUM = 3'h2;  
    localparam WORK_CALC_SQRT = 3'h3;  
    localparam WORK_CALC_END = 3'h4;  
    
    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] state;
   
    
    reg  [9:0] sqrt_a;
    wire [4:0] sqrt_y;
    reg  sqrt_start;
    wire  sqrt_busy;
    
    sqrt sqrt1( .clk_i(clk_i), .rst_i(rst_i), .a_bi(sqrt_a), .start_i(sqrt_start), .busy_o(sqrt_busy), .y_bo(sqrt_y));
    
    reg   [7:0] cbrt_a;
    wire [3:0] cbrt_y;
    reg  cbrt_start;
    wire  cbrt_busy;
    
    cbrt cbrt1( .clk_i(clk_i), .rst_i(rst_i), .a_bi(cbrt_a), .start_i(cbrt_start), .busy_o(cbrt_busy), .y_bo(cbrt_y));
    
    reg [13:0] sum_a;
    reg [13:0] sum_b;
    wire [13:0] sum_y;
    
    adder adder1(.a_bi(sum_a), .b_bi(sum_b), .y_bo(sum_y));
    
    top top1 (.clk(clk_i), .y_bi(y_bo));
    
    assign busy_o = (state != IDLE);
        
    always @(posedge clk_i) begin
        if (rst_i) begin
            y_bo <= 0;
            cbrt_start <= 0;
            sqrt_start <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE:
                    begin
                        if (start_i) begin
                            y_bo <= 0; 
                            cbrt_start <= 0;
                            sqrt_start <= 0;
                            state <= WORK_CALC_B;
                            a <= a_bi;
                            b <= b_bi;
                            sum_a <= 0;
                        end
                    end
                WORK_CALC_B:
                    begin
                        cbrt_a <= b_bi;
                        cbrt_start <= 1;
                        state <= WORK_CALC_SUM;
                    end  
                WORK_CALC_SUM:
                    begin 
                        cbrt_start <= 0;
                        if(~cbrt_busy && ~cbrt_start) begin  
                            sum_a <= sum_a | cbrt_y;
                            sum_b <= a;
                            state <= WORK_CALC_SQRT;
                        end
                    end
                WORK_CALC_SQRT:
                    begin
                        sqrt_a <= sum_y;
                        sqrt_start <= 1;
                        state <= WORK_CALC_END;
                    end
                WORK_CALC_END:
                    begin
                        sqrt_start <= 0;
                        if(~sqrt_busy && ~sqrt_start) begin  
                            y_bo <= sqrt_y;
                            state <= IDLE;
                        end
                     end
            endcase
        end
    end
endmodule