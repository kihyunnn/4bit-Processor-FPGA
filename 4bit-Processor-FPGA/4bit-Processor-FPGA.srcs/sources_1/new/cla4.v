`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module Name: cla4
// Description: 4-bit Carry Lookahead Adder (Top Module) - Overflow 감지용 C3 출력 추가
//////////////////////////////////////////////////////////////////////////////////

module cla4 (
    input  [3:0] A, B,
    input        Cin,
    output [3:0] Sum,
    output       Cout,   // 최종 캐리 (c4)
    output       C3_out  // MSB로 들어가는 캐리 (c3)  <-- 포트 추가
);

    // 내부 연결을 위한 wire 선언
    wire [3:0] G, P;
    wire [3:1] C;

    // 1. 4개의 GPFA 모듈 인스턴스화
    gpfa u0_gpfa (.A(A[0]), .B(B[0]), .Cin(Cin),  .G(G[0]), .P(P[0]), .Sum(Sum[0]));
    gpfa u1_gpfa (.A(A[1]), .B(B[1]), .Cin(C[1]), .G(G[1]), .P(P[1]), .Sum(Sum[1]));
    gpfa u2_gpfa (.A(A[2]), .B(B[2]), .Cin(C[2]), .G(G[2]), .P(P[2]), .Sum(Sum[2]));
    gpfa u3_gpfa (.A(A[3]), .B(B[3]), .Cin(C[3]), .G(G[3]), .P(P[3]), .Sum(Sum[3]));

    // 2. 1개의 CLL4 모듈 인스턴스화
    cll4 u4_cll (.Gin(G), .Pin(P), .Cin(Cin), .C(C), .Cout(Cout));

    // 3. c3 값을 외부 포트로 연결
    assign C3_out = C[3]; // <--- 이 라인 추가

endmodule