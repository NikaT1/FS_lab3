`timescale 1ns / 1ps
module sub (           
        input [ 13 : 0 ] a_bi, 
        input [ 13 : 0 ] b_bi,         
        output [ 13 : 0 ] y_bo
    );
    assign y_bo = a_bi - b_bi; 
endmodule