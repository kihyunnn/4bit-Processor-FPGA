`timescale 1ns / 1ps

// I/O 블록: 이제 4개의 7-segment 데이터를 계산하여 출력하는 역할만 담당
module io_block(
    input           clk,        // 100MHz 시스템 클럭
    input           rst,
    input   [3:0]   btn,
    input   [3:0]   switch,
    input   [3:0]   result,
    input           overflow,
    
    output  [15:0]  instruction,
    output  [3:0]   led,
    // [수정] TDM 로직이 Top 모듈로 이동했으므로, 여기서는 4개의 seg 데이터만 출력
    output  [6:0]   sega,
    output  [6:0]   segb,
    output  [6:0]   segc,
    output  [6:0]   segd
);

    // --- 내부 신호 ---
    wire    [3:0]   btn_pulse;
    wire    [3:0]   fsm_ssd0, fsm_ssd1, fsm_ssd2, fsm_ssd3;

    // --- 안정적인 버튼 처리 로직 ---
    integer i;
    reg [3:0] btn_sync_r1, btn_sync_r2, btn_stable, btn_stable_d;
    reg [19:0] debounce_cnt[3:0];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {btn_sync_r1, btn_sync_r2, btn_stable, btn_stable_d} <= 16'b0;
            for (i=0; i<4; i=i+1) debounce_cnt[i] <= 0;
        end else begin
            btn_sync_r1 <= btn; btn_sync_r2 <= btn_sync_r1;
            for (i=0; i<4; i=i+1) begin
                if (btn_sync_r2[i] != btn_stable[i]) debounce_cnt[i] <= 0;
                else if (debounce_cnt[i] < 20'd1_000_000) debounce_cnt[i] <= debounce_cnt[i] + 1;
                else btn_stable[i] <= btn_sync_r2[i];
            end
            btn_stable_d <= btn_stable;
        end
    end
    assign btn_pulse = btn_stable & ~btn_stable_d;

    // --- FSM ---
    mips_fsm u_fsm (
        .clk(clk), .rst(rst), .btn0(btn_pulse[0]), .btn1(btn_stable[1]), .btn2(btn_pulse[2]), .btn3(rst),
        .switch(switch), .result(result), .overflow(overflow),
        .led(led), .ssd0(fsm_ssd0), .ssd1(fsm_ssd1), .ssd2(fsm_ssd2), .ssd3(fsm_ssd3), 
        .instruction(instruction)
    );

    // --- hex to 7-segment 변환 ---
    // 변환된 데이터를 sega, segb, segc, segd 출력 포트로 바로 연결
    hex2ssd u_hex2ssd_0 (.hex(fsm_ssd0), .seg(sega));
    hex2ssd u_hex2ssd_1 (.hex(fsm_ssd1), .seg(segb));
    hex2ssd u_hex2ssd_2 (.hex(fsm_ssd2), .seg(segc));
    hex2ssd u_hex2ssd_3 (.hex(fsm_ssd3), .seg(segd));
    
endmodule