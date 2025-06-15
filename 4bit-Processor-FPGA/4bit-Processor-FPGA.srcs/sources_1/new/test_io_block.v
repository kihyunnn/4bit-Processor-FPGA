// 파일: io_block.v (시뮬레이션을 위해 최소한으로 수정된 버전)
`timescale 1ns / 1ps

module test_io_block(
    input           clk,
    //input         rst,
    input   [3:0]   btn,
    input   [3:0]   switch,
    output  [3:0]   led,
    output  [1:0]   seg_en,
    output  [6:0]   seg_ab,
    output  [6:0]   seg_cd
);
    wire    [3:0]   result;
    wire            overflow;
    wire    [15:0]  instruction;

    wire rst = btn[3];

    wire    clk_125M = clk;
    wire    clk_1M, clk_10K, clk_100;

    // [수정 1] Clocking Wizard IP는 시뮬레이션에서 동작하지 않습니다.
    // 시뮬레이션 중에는 clk_gen_100M 모듈을 주석 처리하고,
    // 테스트벤치에서 들어오는 clk를 clk_100M으로 간주하여 사용합니다.
    // clk_gen_100M   u0  (.clk_ref(clk_125M), .rst(rst), .clk_100M(clk_100M));
    wire clk_100M = clk; // 시뮬레이션을 위한 임시 연결

    // 클럭 분주 로직은 behavioral 코드이므로 시뮬레이션에서 동작합니다.
    freq_div_100 u1 (.clk_ref(clk_100M), .rst(rst), .clk_div(clk_1M));
    freq_div_100 u2 (.clk_ref(clk_1M),   .rst(rst), .clk_div(clk_10K));
    freq_div_100 u3 (.clk_ref(clk_10K),  .rst(rst), .clk_div(clk_100));
    
    wire    [3:0]   ssd0, ssd1, ssd2, ssd3;
    wire    [6:0]   sega, segb, segc, segd;
        
    // FSM (mips_counter는 그대로 사용)
    wire    [3:0]   btn_pulse;
    // clk_ref에 100MHz 클럭을 연결하도록 수정
    mips_counter    c0  (.clk_ref(clk_100M), .rst(rst), .btn(btn), .btn_pulse(btn_pulse));
    
    // FSM의 clk도 100MHz로 수정
    mips_fsm f0 (
        .clk(clk_100M), .rst(rst), .btn0(btn_pulse[0]), .btn1(btn[1]), .btn3(btn[3]), 
        .switch(switch), .result(result), .overflow(overflow),
        .led(led), .ssd3(ssd3), .ssd2(ssd2), .ssd1(ssd1), .ssd0(ssd0), 
        .instruction(instruction));
        
    hex2ssd     s0  (.hex(ssd0), .seg(segd));
    hex2ssd     s1  (.hex(ssd1), .seg(segc));
    hex2ssd     s2  (.hex(ssd2), .seg(segb));
    hex2ssd     s3  (.hex(ssd3), .seg(sega));
    
    wire    reg_write, alu_src;
    wire    [3:0]   alu_op;     
    control m0  (.opcode(instruction[15:12]), .reg_write(reg_write), .alu_op(alu_op), .alu_src(alu_src));
    
    wire [3:0] reg_rd1_out, reg_rd2_out, mux_out, alu_result;
    
    // register의 clk도 100MHz로 수정
    register    m1  (
        .clk(clk_100M), .rst(rst), .RegWrite(reg_write),
        .Rd1(instruction[11:8]), .Rd2(instruction[7:4]), .Wr(instruction[3:0]), 
        .Write_data(alu_result), .Rd1_out(reg_rd1_out), .Rd2_out(reg_rd2_out));
        
    MUX_RtoA    m2  (.in0_reg(reg_rd2_out), .in1_inst(instruction[7:4]), .alu_src(alu_src), .out_data_to_alu(mux_out));
    
    // [수정 2] ALU 입력 오타 수정 (Rd2_out -> reg_rd2_out)
    alu m3 (
        .A(reg_rd1_out), // A 입력은 Rd1_out으로 수정
        .B(mux_out),
        .ALUOp(alu_op),
        .Result(alu_result),
        .Overflow(alu_overflow)
    );

    // [수정 3] 이 assign 문들은 무한 루프를 유발하여 시뮬레이션을 불가능하게 합니다. 제거해야 합니다.
    // assign led = led;
    // assign instruction = instruction;
    
    // [수정 4] 7-Segment 로직의 비트 폭 불일치 수정 (4'b00 -> 2'b00)
    assign seg_en = clk_1M ? 2'b11 : 2'b00;
    assign seg_ab = clk_1M ? segb : sega;
    assign seg_cd = clk_1M ? segd : segc;
    
endmodule