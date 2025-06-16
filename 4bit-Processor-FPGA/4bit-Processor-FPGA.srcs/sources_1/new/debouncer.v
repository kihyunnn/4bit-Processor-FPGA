
`timescale 1ns / 1ps

module debouncer #(
    parameter N = 1000000, // 입력이 N 클럭 동안 안정되어야 함
    parameter K = 20   // N을 카운트하기 위한 비트 수, K >= ceil(log2(N+1))
) (
    input clk,
    input noisy,
    output reg debounced //디바운싱 처리된 단일 클럭 펄스 (
);

reg [K-1:0] count;
reg noisy_prev_state; // noisy 신호의 이전 안정 상태를 기억하기 위한 레지스터

always @(posedge clk)
begin
    if (!noisy) begin // noisy 입력이 0 (버튼 떼짐 또는 초기 상태)
        count <= 0;
        debounced <= 1'b0;
        noisy_prev_state <= 1'b0; // 이전 상태도 0으로
    end
    else begin // noisy 입력이 '1' (버튼 눌림)
        if (count < N) begin
            count <= count + 1'b1;
            debounced <= 1'b0; // 아직 안정화 기간, 펄스 출력 안 함
        end
        else begin // count == N, 즉 noisy 입력이 N 클럭 동안 1로 안정됨
            if (noisy_prev_state == 1'b0) begin // 이전 안정 상태가 '0'이었다가 처음 1로 안정된 경우
                debounced <= 1'b1; // 펄스 발생!
            end
            else begin
                debounced <= 1'b0; // 이미 펄스 발생 후 계속 안정된 상태이므로 더 이상 펄스 발생 안 함
            end
            noisy_prev_state <= 1'b1; // 현재 안정 상태 1을 기억
        end
    end
end

endmodule