`timescale 1ns / 1ps


module gpfa (
    input   A, B, Cin,  // 1-bit 입력 A, B와 이전 캐리 입력 Cin
    output  G, P, Sum   // Generate, Propagate, Sum 출력
);

    // G는 A와 B가 모두 1일 때 생성
    assign G = A & B;
    
    // P는 A와 B 중 하나만 1일 때 전파 조건을 만족
    assign P = A ^ B;
    
    // Sum은 P와 이전 캐리(Cin)의 XOR 연산과 같음
    assign Sum = P ^ Cin;

endmodule