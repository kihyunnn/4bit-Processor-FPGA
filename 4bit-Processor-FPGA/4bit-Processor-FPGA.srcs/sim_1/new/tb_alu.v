`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
// Module Name: tb_alu_overflow
// Description: ALU의 오버플로 감지 기능을 검증하기 위한 테스트벤치
//
//////////////////////////////////////////////////////////////////////////////////

module tb_alu;

    // --- Test Signals ---
    reg  [3:0] A_in;
    reg  [3:0] B_in;
    reg  [3:0] ALUOp_in;
    wire [3:0] Result_out;
    wire       Overflow_out; // 오버플로 출력을 받을 wire

    // --- Instantiate the ALU ---
    alu uut (
        .A(A_in),
        .B(B_in),
        .ALUOp(ALUOp_in),
        .Result(Result_out),
        .Overflow(Overflow_out) // Overflow 포트 연결
    );

    // --- Main Test Scenario ---
    initial begin
        $display("-------------------------------------------");
        $display("ALU Overflow Detection Test Start");
        $display("-------------------------------------------");

        // --- 시나리오 1: 정상적인 덧셈 (오버플로 발생 X) ---
        $display("--- Test 1: Normal Addition (2 + 3) ---");
        
        A_in = 2;
        B_in = 3;
        ALUOp_in = 4'hA; // ADD 연산
        
        #10; // ALU가 계산할 시간을 줌
        
        $display("Inputs: A=%d, B=%d", A_in, B_in);
        $display("Expected: Result=5, Overflow=0");
        $display("Actual:   Result=%d, Overflow=%b", Result_out, Overflow_out);

        if (Result_out === 5 && Overflow_out === 1'b0) begin
            $display("[PASS] Correctly calculated without overflow.");
        end else begin
            $display("[FAIL] Incorrect result or overflow flag.");
        end
        
        $display("-------------------------------------------");
        #20;

        // --- 시나리오 2: 오버플로 발생하는 덧셈 ---
        $display("--- Test 2: Addition with Overflow (5 + 4) ---");
        
        A_in = 5;
        B_in = 4;
        ALUOp_in = 4'hA; // ADD 연산
        
        #10; // ALU가 계산할 시간을 줌
        
        $display("Inputs: A=%d, B=%d", A_in, B_in);
        $display("Expected: Result is invalid, Overflow=1");
        $display("Actual:   Result=%d (4'b%b), Overflow=%b", Result_out, Result_out, Overflow_out);
        
        if (Overflow_out === 1'b1) begin
            $display("[PASS] Overflow correctly detected.");
        end else begin
            $display("[FAIL] Failed to detect overflow.");
        end

        $display("-------------------------------------------");
        #20;
        $finish;
    end

endmodule