`timescale 1ns / 1ps

module register (
    // Global Signals 
    input               clk,        // 시스템 클럭
    input               rst,        // 시스템 리셋 (Active High)
    //  Control Signal 
    input               RegWrite,   // 1'b1일 때 쓰기 활성화
    input               overflow,
    //  Address Inputs 
    input        [3:0]  Rd1,        // 첫 번째 읽기 포트 주소
    input        [3:0]  Rd2,        // 두 번째 읽기 포트 주소
    input        [3:0]  Wr,         // 쓰기 포트 주소
    //  Data I/O 
    input        [3:0]  Write_data, // 레지스터에 쓸 데이터
    output       [3:0]  Rd1_out,    // 첫 번째 읽기 포트 출력 데이터
    output       [3:0]  Rd2_out     // 두 번 째 읽기 포트 출력 데이터
);

    // 16개의 4비트 레지스터를 저장할 2차원 배열 선언
    reg [3:0] registers [0:15];
    integer i;

    //각각의 값은 주소의 값으로 맨 처음에 초기화됨
    initial begin
        for (i = 0 ; i< 16 ; i = i+1 ) begin
            registers[i] = i;
        end
    end

    // 쓰기 및 전체 리셋 로직 
    always @(posedge clk) begin
        registers[0] <= 4'b0000;  // 0번주소는 항상 0으로 초기화
        if (RegWrite && (Wr != 4'b0000) && !overflow) begin
            registers[Wr] <= Write_data;
        end
    end

    //  읽기 로직 (Read Logic) 
    assign Rd1_out = (Rd1 == 4'b0000) ? 4'b0000 : registers[Rd1];
    assign Rd2_out = (Rd2 == 4'b0000) ? 4'b0000 : registers[Rd2];

endmodule