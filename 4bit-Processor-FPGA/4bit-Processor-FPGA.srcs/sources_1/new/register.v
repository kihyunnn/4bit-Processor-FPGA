`timescale 1ns / 1ps

module register (
    // Global Signals 
    input               clk,        // 시스템 클럭
    input               rst,        // 시스템 리셋 (Active High)

    //  Control Signal 
    input               RegWrite,   // 1'b1일 때 쓰기 활성화

    //  Address Inputs 
    input        [3:0]  Rd1,        // 첫 번째 읽기 포트 주소
    input        [3:0]  Rd2,        // 두 번째 읽기 포트 주소
    input        [3:0]  Wr,         // 쓰기 포트 주소
    
    //  Data I/O 
    input        [3:0]  Write_data, // 레지스터에 쓸 데이터
    output       [3:0]  Rd1_out,    // 첫 번째 읽기 포트 출력 데이터
    output       [3:0]  Rd2_out     // [3.0] -> [3:0]으로 오타 수정
);

    // 16개의 4비트 레지스터를 저장할 2차원 배열 선언
    reg [3:0] registers [0:15];
    
    // for 루프를 위한 integer 변수 선언
    integer i;
    
    // 0번 레지스터 초기화
    initial begin
        registers[0] = 4'b0000;
    end

    // 쓰기 및 전체 리셋 로직 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1) begin
                registers[i] <= 4'b0000;
            end
            // 3번 주소에 5 (4'b0101) 값을 하드코딩하여 저장 -> 읽기 테스트용. 3번주소에 5번값 read 먼저 테스트
            registers[3] <= 4'b0101;  // 3번 주소에 5를 저장
            registers[4] <= 4'b0001;  // 4번 주소에 1를 저장
            registers[5] <= 4'b0111;  // 5번 주소에 7를 저장
        end else if (RegWrite && (Wr != 4'b0000)) begin
            registers[Wr] <= Write_data;
        end
    end

    //  읽기 로직 (Read Logic) 
    assign Rd1_out = (Rd1 == 4'b0000) ? 4'b0000 : registers[Rd1];
    assign Rd2_out = (Rd2 == 4'b0000) ? 4'b0000 : registers[Rd2];

endmodule