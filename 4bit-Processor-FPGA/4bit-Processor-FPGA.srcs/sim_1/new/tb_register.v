`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
//
// Module Name: tb_register
// Description: Testbench for verifying the register.v module
// 설명: register.v 모듈을 검증하기 위한 테스트벤치
//
////////////////////////////////////////////////////////////////////////////////

module tb_register;

    // --- Test Signals ---
    // --- 테스트 신호들 ---
    reg         clk;        // 클럭 신호
    reg         rst;        // 리셋 신호
    reg         RegWrite;   // 레지스터 쓰기 활성화 신호
    reg  [3:0]  Rd1;        // 첫 번째 읽기 주소
    reg  [3:0]  Rd2;        // 두 번째 읽기 주소
    reg  [3:0]  Wr;         // 쓰기 주소
    reg  [3:0]  Write_data; // 쓰기 데이터

    // --- Module Outputs ---
    // --- 모듈 출력 ---
    wire [3:0]  Rd1_out;    // 첫 번째 읽기 출력 데이터
    wire [3:0]  Rd2_out;    // 두 번째 읽기 출력 데이터

    // --- Instantiate the Module Under Test (MUT) ---
    // --- 테스트 대상 모듈 인스턴스화 ---
    register uut (
        .clk(clk),
        .rst(rst),
        .RegWrite(RegWrite),
        .Rd1(Rd1),
        .Rd2(Rd2),
        .Wr(Wr),
        .Write_data(Write_data),
        .Rd1_out(Rd1_out),
        .Rd2_out(Rd2_out)
    );

    // --- Clock Generation ---
    // --- 클럭 생성 ---
    initial clk = 0;
    always #5 clk = ~clk;   // 10ns 주기 클럭 (100MHz)

    // --- Test Scenario Synchronized to Clock ---
    // --- 클럭과 동기화된 테스트 시나리오 ---
    initial begin
        // 1. Initialize all signals at T=0
        // 1. T=0에서 모든 신호 초기화
        rst = 0;
        RegWrite = 0;
        Rd1 = 0; Rd2 = 0; Wr = 0; Write_data = 0;
        $display("----------------- Simulation Start -----------------");

        // 2. Reset the system for 2 clock cycles
        // 2. 2 클럭 사이클 동안 시스템 리셋
        @(posedge clk); // Move to T=5ns - T=5ns로 이동
        rst <= 1;
        $display("[T=%0t ns] Asserting Reset.", $time);
        
        @(posedge clk); // T=15ns
        @(posedge clk); // T=25ns
        rst <= 0;
        $display("[T=%0t ns] De-asserting Reset. Registers are now all 0.", $time);

        // 3. Write Operation 1
        // 3. 첫 번째 쓰기 동작
        @(posedge clk); // T=35ns
        $display("[T=%0t ns] Test 1: Writing value 10 to Register 5.", $time);
        RegWrite <= 1;      // 쓰기 활성화
        Wr       <= 5;      // 주소 5
        Write_data <= 10;   // 데이터 10

        // 4. Write Operation 2
        // 4. 두 번째 쓰기 동작
        @(posedge clk); // T=45ns. Write 1 happens here. - T=45ns. 첫 번째 쓰기가 실행됨
        $display("[T=%0t ns] Test 2: Writing value 12 to Register 10.", $time);
        Wr       <= 10;     // 주소 10
        Write_data <= 12;   // 데이터 12

        // 5. Read Operation
        // 5. 읽기 동작
        @(posedge clk); // T=55ns. Write 2 happens here. - T=55ns. 두 번째 쓰기가 실행됨
        RegWrite <= 0;      // 쓰기 비활성화
        Wr       <= 0;      // 쓰기 주소 클리어
        Write_data <= 0;    // 쓰기 데이터 클리어

        $display("[T=%0t ns] Test 3: Reading from Reg 5 & 10.", $time);
        Rd1 <= 5;           // 레지스터 5에서 읽기
        Rd2 <= 10;          // 레지스터 10에서 읽기
        #1; // Wait 1ps for combinational read to propagate - 조합회로 읽기 전파를 위해 1ps 대기
        $display("           Result: Rd1_out=%d, Rd2_out=%d. (Expecting 10 and 12)", Rd1_out, Rd2_out);

        // 6. Test Register-Zero
        // 6. 0번 레지스터 테스트
        @(posedge clk); // T=65ns
        $display("[T=%0t ns] Test 4: Attempting to write 15 to Reg 0 (should be ignored).", $time);
        RegWrite <= 1;      // 쓰기 활성화
        Wr       <= 0;      // 주소 0 (0번 레지스터)
        Write_data <= 15;   // 데이터 15
        
        @(posedge clk); // T=75ns. Write attempt happens here (and is ignored by DUT). - T=75ns. 쓰기 시도 실행 (DUT에서 무시됨)
        RegWrite <= 0;      // 쓰기 비활성화
        Wr       <= 0;      // 입력 클리어
        Write_data <= 0;    // 입력 클리어

        $display("[T=%0t ns] Test 5: Reading from Reg 0.", $time);
        Rd1 <= 0;           // 레지스터 0에서 읽기
        #1;
        $display("           Result: Rd1_out=%d. (Expecting 0)", Rd1_out);

        #20;
        $display("----------------- Simulation End -----------------");
        $finish;
    end

endmodule