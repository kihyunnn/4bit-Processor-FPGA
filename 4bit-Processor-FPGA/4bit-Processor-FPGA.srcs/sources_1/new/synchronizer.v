`timescale 1ns / 1ps

module synchronizer(
    input clk,        //  시스템 동기 클럭
    input async_in,   // 비동기 입력 신호 
    output reg sync_out // 동기화된 신호 (레지스터 타입)
);

// 내부 레지스터 선언
reg tmp; // 첫 번째 플립플롭의 출력을 저장하기 위한 임시 레지스터

// always 블록: clk의 상승 에지에서 동작
always @(posedge clk)
begin
    tmp <= async_in;   // 비동기 입력을 클럭에 맞춰 한 번 동기화
    sync_out <= tmp;   // 첫 번째 플립플롭의 출력을 다시 한 번 동기화하여 안정성 향상
end
endmodule