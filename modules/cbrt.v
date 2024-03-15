`timescale 1ns / 1ps
module cbrt (        
        input clk_i,
        input rst_i,        
        input [ 7 : 0 ] a_bi,       
        input start_i,
        output [ 1 : 0 ] busy_o,   
        output reg [ 3 : 0 ] y_bo
    );
        
    localparam IDLE = 4'h0;
    localparam WORK_START_STEP = 4'h1;    
    localparam WORK_CALC_B_1 = 4'h2;  
    localparam WORK_CALC_B_2 = 4'h3;  
    localparam WORK_CALC_B_3 = 4'h4;  
    localparam WORK_CALC_B_4 = 4'h5;
    localparam WORK_CALC_B_5 = 4'h6;   
    localparam WORK_CHECK = 4'h7;  
    localparam WORK_SUB_RES = 4'h8; 
    
    reg signed [4:0] s;
    wire end_step;
    reg [7:0] x;
    reg [13:0] b, y, tmp1, tmp2;
    reg [3:0] state;
   
    
    reg   [7:0] mult1_a;
    reg   [7:0] mult1_b;
    wire [15:0] mult1_y;
    reg  mult1_start;
    wire  mult1_busy;
    
    mult mult1( .clk_i(clk_i), .rst_i(rst_i), .a_bi(mult1_a), .b_bi(mult1_b), .start_i(mult1_start), .busy_o(mult1_busy), .y_bo(mult1_y));
    
    reg [13:0] sum_a;
    reg [13:0] sum_b;
    wire [13:0] sum_y;
    
    adder adder1(.a_bi(sum_a), .b_bi(sum_b), .y_bo(sum_y));
    
    reg [13:0] sub_a;
    reg [13:0] sub_b;
    wire [13:0] sub_y;
    
    sub sub1(.a_bi(sub_a), .b_bi(sub_b), .y_bo(sub_y));
    
    assign end_step = (s == 'b11101); // s == -3
    assign busy_o = (state != IDLE);
        
    always @(posedge clk_i) begin
        if (rst_i) begin
            y_bo <= 0;
            s <= 0;
            mult1_start <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE:
                    begin
                        if (start_i) begin
                            y_bo <= 0; 
                            mult1_start <= 0;
                            state <= WORK_START_STEP;
                            x <= a_bi;
                            s <= 'd12;
                            y <= 0;
                        end
                    end
                WORK_START_STEP:
                    begin
                        if (end_step) begin
                            state <= IDLE;
                            y_bo <= y;
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
                            state <= WORK_START_STEP;
                        end
                    end
                WORK_SUB_RES:
                    begin
                        x <= sub_y;
                        state <= WORK_START_STEP;
                    end
            endcase
        end
    end
endmodule