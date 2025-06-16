`timescale 1ns / 1ps

module alu (
    input        [3:0]  A,
    input        [3:0]  B,
    input        [3:0]  ALUOp,
    output reg   [3:0]  Result,
    output reg          Overflow      //오버플로 출력 
);

    // cla4 모듈의 출력을 받기 위한 wire 선언
    wire [3:0] cla_sum;
    wire       cla_cout;    // 최종 캐리 (c4)
    wire       cla_c3;      // MSB로 들어가는 캐리 (c3) 

    //뺄셈을 위한 입력 사전 처리 로직 
    wire       is_subtraction = (ALUOp == 4'hB) || (ALUOp == 4'hD);
    wire [3:0] b_operand_for_cla = is_subtraction ? ~B : B;
    wire       cin_for_cla = is_subtraction;

    // 모듈 인스턴스화 (
    cla4 adder_unit (
        .A(A),
        .B(b_operand_for_cla),
        .Cin(cin_for_cla),
        .Sum(cla_sum),
        .Cout(cla_cout),
        .C3_out(cla_c3) 
    );

    // 오버플로 감지 로직 
    // MSB로 들어오는 캐리(c3)와 나가는 캐리(c4)가 다를 때 오버플로 발생 (XOR)
    wire overflow_detected = cla_c3 ^ cla_cout; 

    // 최종 결과 선택 로직
    always @(*) begin
        Overflow = 1'b0; // 기본적으로 Overflow는 0으로 설정

        case (ALUOp)
            // 데이터 이동 및 NOP
            4'h0: Result = 4'b0000;
            4'h1: Result = B;
            4'h2: Result = A;
            4'h3: Result = A;
            
            // 논리 연산
            4'h4: Result = ~A;
            4'h5: Result = A & B;
            4'h6: Result = A | B;
            4'h7: Result = A ^ B;
            4'h8: Result = ~(A & B);
            4'h9: Result = ~(A | B);
            
            // 산술 연산 - cla4 모듈의 결과를 사용하고 오버플로를 처리
            4'hA, 4'hB, 4'hC, 4'hD: begin 
                Result = cla_sum;
                Overflow = overflow_detected; // 감지된 오버플로 신호 연결
            end
            
            // 시프트 연산
            4'hE: Result = A << B;
            4'hF: Result = A >> B;

            default: Result = 4'b0000;
        endcase
    end

endmodule