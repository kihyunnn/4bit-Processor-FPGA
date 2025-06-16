`timescale 1ns / 1ps

module clk_gen_100M(
    input   clk_ref,
    input   rst,
    output  clk_100M
    );
    
    wire    clk_125M = clk_ref;
    
    clk_wiz_0 clk_gen (
        .clk_out1(clk_100M),  // PLL 출력 100 MHz
        .clk_in1 (clk_125M),  // PLL 입력 125 MHz
        .reset   (rst)        // Active-High reset
    );
    
endmodule
