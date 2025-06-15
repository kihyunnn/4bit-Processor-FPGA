`timescale 1ns / 1ps

// 최상위 모듈: CPU 코어 로직과 최종 7-Segment 구동 로직을 포함
module mips_top(
    input           clk,
    input   [3:0]   btn,
    input   [3:0]   switch,
    output  [3:0]   led,
    // [수정] 학생의 원래 7-Segment 포트로 변경
    output  [1:0]   seg_en,
    output  [6:0]   seg_ab,
    output  [6:0]   seg_cd
);
    
    // --- 1. 안정적인 리셋 신호 및 100MHz 클럭 생성 ---
    wire rst;
    wire clk_100M;
    
    reg btn3_sync_r1, btn3_sync_r2, btn3_stable;
    reg [19:0] btn3_debounce_cnt;
    always @(posedge clk_100M) begin
        btn3_sync_r1 <= btn[3];
        btn3_sync_r2 <= btn3_sync_r1;
        if (btn3_sync_r2 != btn3_stable) btn3_debounce_cnt <= 0;
        else if (btn3_debounce_cnt < 20'd1_000_000) btn3_debounce_cnt <= btn3_debounce_cnt + 1;
        else btn3_stable <= btn3_sync_r2;
    end
    assign rst = btn3_stable;

    clk_gen_100M u_clk_gen (.clk_ref(clk), .rst(rst), .clk_100M(clk_100M));

    // --- 2. 모듈 간 연결 신호 ---
    wire [15:0] instruction_bus;
    wire [3:0]  result_bus;
    wire        overflow_flag;
    wire [6:0]  sega, segb, segc, segd;

    // --- 3. I/O 블록 인스턴스화 ---
    io_block u_io_block (
        .clk(clk_100M), .rst(rst), .btn(btn), .switch(switch),
        .result(result_bus), .overflow(overflow_flag),
        .instruction(instruction_bus), .led(led),
        .sega(sega), .segb(segb), .segc(segc), .segd(segd)
    );

    // --- 4. CPU 코어 로직 ---
    wire        core_reg_write, core_alu_src;
    wire [3:0]  core_alu_op, core_reg_rd1_out, core_reg_rd2_out, core_mux_out;

    control u_control (.opcode(instruction_bus[15:12]), .reg_write(core_reg_write), .alu_op(core_alu_op), .alu_src(core_alu_src));
    register u_register (.clk(clk_100M), .rst(rst), .RegWrite(core_reg_write), .Rd1(instruction_bus[11:8]), .Rd2(instruction_bus[7:4]), .Wr(instruction_bus[3:0]), .Write_data(result_bus), .Rd1_out(core_reg_rd1_out), .Rd2_out(core_reg_rd2_out));
    MUX_RtoA u_mux (.in0_reg(core_reg_rd2_out), .in1_inst(instruction_bus[7:4]), .alu_src(core_alu_src), .out_data_to_alu(core_mux_out));
    alu u_alu (.A(core_reg_rd1_out), .B(core_mux_out), .ALUOp(core_alu_op), .Result(result_bus), .Overflow(overflow_flag));

    // --- 5. 7-Segment 구동 로직 (학생의 원래 방식 유지) ---
    wire clk_1M;
    freq_div_100 u_div100 (.clk_ref(clk_100M), .rst(rst), .clk_div(clk_1M));

    assign seg_en = clk_1M ? 2'b11 : 2'b00;
    assign seg_ab = clk_1M ? segb : sega;
    assign seg_cd = clk_1M ? segd : segc;

endmodule