`timescale 1ns / 1ps

module MUX_RtoA (
    input        [3:0]  in0_reg,       // 0번 입력: 레지스터로부터 온 데이터
    input        [3:0]  in1_inst,      // 1번 입력: 명령ㅇ어로부터 온 즉시값 데이터 Rd2
    input               alu_src,                // ALUSrc
    output       [3:0]  out_data_to_alu     // 출력: 선택된 데이터
);

    // alu_src이 1이면 in1_from_inst를, 0이면 in0_reg를 선택하여 출력
    assign out_data_to_alu = (alu_src == 1'b1) ? in1_inst : in0_reg;

endmodule