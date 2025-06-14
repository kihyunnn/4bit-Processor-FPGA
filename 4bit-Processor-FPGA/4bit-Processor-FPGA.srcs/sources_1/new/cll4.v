`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module Name: cll4
// Description: 4-bit Carry Lookahead Logic unit
//////////////////////////////////////////////////////////////////////////////////

module cll4 (
    input  [3:0] Gin,   // 4개의 G 신호 입력 (G[3:0])
    input  [3:0] Pin,   // 4개의 P 신호 입력 (P[3:0])
    input        Cin,   // 최초 캐리 입력 (c0)
    output [3:1] C,     // 중간 캐리 출력 c1, c2, c3
    output       Cout   // 최종 캐리 출력 c4
);

    // c1 = G0 + P0*c0
    assign C[1] = Gin[0] | (Pin[0] & Cin);

    // c2 = G1 + P1*G0 + P1*P0*c0
    assign C[2] = Gin[1] | (Pin[1] & Gin[0]) | (Pin[1] & Pin[0] & Cin);

    // c3 = G2 + P2*G1 + P2*P1*G0 + P2*P1*P0*c0
    assign C[3] = Gin[2] | (Pin[2] & Gin[1]) | (Pin[2] & Pin[1] & Gin[0]) | (Pin[2] & Pin[1] & Pin[0] & Cin);
    
    // c4 = G3 + P3*G2 + P3*P2*G1 + P3*P2*P1*G0 + P3*P2*P1*P0*c0
    assign Cout = Gin[3] | (Pin[3] & Gin[2]) | (Pin[3] & Pin[2] & Gin[1]) | (Pin[3] & Pin[2] & Pin[1] & Gin[0]) | (Pin[3] & Pin[2] & Pin[1] & Pin[0] & Cin);

endmodule