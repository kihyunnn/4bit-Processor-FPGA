`timescale 1ns / 1ps

module clk_gen_100M(
    input   clk_ref,
    input   rst,
    output  clk_100M
    );
    
    wire    clk_125M = clk_ref;
    
    clk_wiz_0   clk_gen (clk_100M, rst, clk_125M);
    
endmodule
