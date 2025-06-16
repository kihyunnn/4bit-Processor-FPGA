`timescale 1ns / 1ps

module tb_test_io_block;

    // DUT(설계)의 입력을 위한 reg 선언
    reg clk;
    reg [3:0] btn;
    reg [3:0] switch;

    // DUT의 출력을 받기 위한 wire 선언
    wire [3:0] led;
    wire [1:0] seg_en;
    wire [6:0] seg_ab;
    wire [6:0] seg_cd;

    // io_block 모듈을 테스트하기 위해 인스턴스화
    io_block uut (
        .clk(clk),
        .btn(btn),
        .switch(switch),
        .led(led),
        .seg_en(seg_en),
        .seg_ab(seg_ab),
        .seg_cd(seg_cd)
    );

    // 1. 100MHz 클럭 생성 (주기: 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 5ns 마다 0과 1을 반복
    end

    // 2. 명령어 실행을 위한 task 정의
    task execute_instruction;
        input [15:0] inst;
        begin
            $display("[%0t] Sending instruction: %h", $time, inst);
            // 16비트 명령어를 4비트씩 4번에 걸쳐 입력 (MSB부터)
            // s1: opcode
            switch = inst[15:12];
            #10; btn[0] = 1; #10; btn[0] = 0; #10;
            // s2: rd1
            switch = inst[11:8];
            #10; btn[0] = 1; #10; btn[0] = 0; #10;
            // s3: rd2
            switch = inst[7:4];
            #10; btn[0] = 1; #10; btn[0] = 0; #10;
            // s4: wr
            switch = inst[3:0];
            #10; btn[0] = 1; #10; btn[0] = 0; #10;
            
            // FSM이 실행(Execute)되고 완료(Done)될 때까지 충분히 기다림
            #1000; 
        end
    endtask


    // 3. 시뮬레이션 시나리오
    initial begin
        // 모든 입력 초기화
        btn = 4'b0000;
        switch = 4'b0000;

        // 리셋 신호 인가 (btn[3] 사용)
        btn[3] = 1;
        #20; // 20ns 동안 리셋 유지
        btn[3] = 0;
        #20;

        $display("--- Test Start ---");

        // 테스트 1: R3에 값 5 쓰기 (Write R3, 5)
        // 명령어: 0001 0000 0101 0011 (16'h1053)
        execute_instruction(16'h1053);
        
        #50; // 명령어 사이 간격

        // 테스트 2: R3에서 값 읽기 (Read R3)
        // 명령어: 0010 0011 0000 0000 (16'h2300)
        execute_instruction(16'h2300);

        #200;
        $display("--- Test End: Check waveform now ---");
        $stop; // 시뮬레이션 종료
    end

endmodule