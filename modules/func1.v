`timescale 1ns / 1ps
module func1 (        
        input clk_i,
        input rst_i,        
        input [ 7 : 0 ] a_bi,    
        input [ 7 : 0 ] b_bi,    
        input start_i,
        output [ 1 : 0 ] busy_o,   
        output reg [ 4 : 0 ] y_bo
    );
        
    localparam IDLE = 5'h0;
    localparam WORK_CALC_B = 5'h1;    
    localparam WORK_CALC_SUM = 5'h2;  
    localparam WORK_CALC_SQRT = 5'h3;  
    localparam WORK_CALC_END = 5'h4;  
    localparam WORK_START_STEP_CBRT = 5'h5;    
    localparam WORK_CALC_B_1 = 5'h6;  
    localparam WORK_CALC_B_2 = 5'h7;  
    localparam WORK_CALC_B_3 = 5'h8;  
    localparam WORK_CALC_B_4 = 5'h9;
    localparam WORK_CALC_B_5 = 5'h10;   
    localparam WORK_CHECK = 5'h11;  
    localparam WORK_SUB_RES = 5'h12; 
    
    reg [7:0] a_i;
    reg [7:0] b_i;
    reg [5:0] state;
   
    reg signed [4:0] s;
    wire end_step;
    reg [7:0] x;
    reg [13:0] b, y, tmp1, tmp2;
    reg [ 3 : 0 ] cbrt_y;
   
    reg  [9:0] sqrt_a;
    wire [4:0] sqrt_y;
    reg  sqrt_start;
    wire  sqrt_busy;
    
    sqrt sqrt1( .clk_i(clk_i), .rst_i(rst_i), .a_bi(sqrt_a), .start_i(sqrt_start), .busy_o(sqrt_busy), .y_bo(sqrt_y));
    
    reg [13:0] sum_a;
    reg [13:0] sum_b;
    wire [13:0] sum_y;
    
    adder adder1(.a_bi(sum_a), .b_bi(sum_b), .y_bo(sum_y));
    
    reg   [7:0] mult1_a;
    reg   [7:0] mult1_b;
    wire [15:0] mult1_y;
    reg  mult1_start;
    wire  mult1_busy;
    
    mult mult1( .clk_i(clk_i), .rst_i(rst_i), .a_bi(mult1_a), .b_bi(mult1_b), .start_i(mult1_start), .busy_o(mult1_busy), .y_bo(mult1_y));
    
    
    reg [13:0] sub_a;
    reg [13:0] sub_b;
    wire [13:0] sub_y;
    
    sub sub1(.a_bi(sub_a), .b_bi(sub_b), .y_bo(sub_y));
    
    assign end_step = (s == 'b11101);
    assign busy_o = (state != IDLE);
        
    always @(posedge clk_i) begin
        if (rst_i) begin
            y_bo <= 0;
            sqrt_start <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE:
                    begin
                        if (start_i) begin
                            y_bo <= 0; 
                            sqrt_start <= 0;
                            mult1_start <= 0;
                            state <= WORK_START_STEP_CBRT;
                            a_i <= a_bi;
                            b_i <= b_bi;
                            s <= 'd12;
                            sum_a <= 0;
                            x <= b_bi;
                        end
                    end
                WORK_CALC_SUM:
                    begin 
                        sum_a <= sum_a | cbrt_y;
                        sum_b <= a_i;
                        state <= WORK_CALC_SQRT;
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
                
                WORK_START_STEP_CBRT:
                    begin
                        if (end_step) begin
                            state <= WORK_CALC_SUM;
                            cbrt_y <= y;
                            sum_a <= 0;
                            sum_b <= 0;
                            mult1_a <= 0;
                            mult1_b <= 0;
                        end else begin
                            y <= y << 1;
                            state <= WORK_CALC_B_1;
                        end
                    end  
                WORK_CALC_B_1:
                    begin 
                        tmp1 <= y << 1; 
                        sum_a <= y;
                        sum_b <= 1;
                        state <= WORK_CALC_B_2;
                    end
                WORK_CALC_B_2:
                    begin
                        tmp2 <= sum_y;
                        sum_a <= y;
                        sum_b <= tmp1;
                        state <= WORK_CALC_B_3;
                    end
                WORK_CALC_B_3:
                    begin
                        mult1_a <= sum_y;
                        mult1_b <= tmp2;
                        mult1_start <= 1;
                        state <= WORK_CALC_B_4;
                     end
                WORK_CALC_B_4:
                     begin
                        mult1_start <= 0;
                        if(~mult1_busy && ~mult1_start) begin  
                            sum_a <= mult1_y;
                            sum_b <= 1;
                            state <= WORK_CALC_B_5;
                        end
                    end
                WORK_CALC_B_5:
                     begin
                            b <= sum_y << s;
                            sub_a <= s;
                            sub_b <= 3;
                            state <= WORK_CHECK;
                      end
                WORK_CHECK:
                    begin
                        s <= sub_y;
                        if (x >= b) begin
                            sub_a <= x;
                            sub_b <= b;
                            y <= tmp2;
                            state <= WORK_SUB_RES;
                        end else begin
                            state <= WORK_START_STEP_CBRT;
                        end
                    end
                WORK_SUB_RES:
                    begin
                        x <= sub_y;
                        state <= WORK_START_STEP_CBRT;
                    end
                   
            endcase
        end
    end
endmodule