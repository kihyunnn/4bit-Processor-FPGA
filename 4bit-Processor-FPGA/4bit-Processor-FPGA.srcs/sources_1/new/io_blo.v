`timescale 1ns / 1ps

module io_block(
    // input
    input           clk,
    input           rst,
    input   [3:0]  result, // ALU result
    input           overflow,
    input   [3:0]   btn,
    input   [3:0]   switch,
    // output
    output  [3:0]   led,    // state
    output  [1:0]   seg_en, // ssd 선택 신호
    output  [6:0]   seg_ab,     // ssd data
    output  [6:0]   seg_cd,     // ssd data
    output  [15:0]  instruction
    );
    
    wire    clk_125M = clk;
    wire    clk_100M;
    clk_gen_100M    u0  (.clk_ref(clk_125M), .rst(rst), .clk_100M(clk_100M));
    
    wire    [3:0]   a, b, c, d;
    wire    [6:0]   sega, segb, segc, segd;
    
    // hex2ssd 모듈 인스턴스화 (자리수별)
    hex2ssd     s0  (.hex(a), .seg(sega));
    hex2ssd     s1  (.hex(b), .seg(segb));
    hex2ssd     s2  (.hex(c), .seg(segc));
    hex2ssd     s3  (.hex(d), .seg(segd));
    
    wire    [3:0]   ssd0, ssd1, ssd2, ssd3;
    
    // FSM 
    wire    [3:0]   btn_pulse;
    mips_counter    c0  (.clk_ref(clk), .rst(rst), .btn(btn), .btn_pulse(btn_pulse));
    
    mips_fsm f0 (
        .clk(clk), .rst(rst), .btn0(btn_pulse[0]), .btn1(btn[1]), .btn3(btn_pulse[3]), 
        .switch(switch), .result(result), .overflow(overflow),
        .led(led), .ssd0(ssd0), .ssd1(ssd1), .ssd2(ssd2), .ssd3(ssd3), 
        .instruction(instruction));
        
    wire    reg_write, alu_src;
    wire    [3:0]   alu_op;      
    control m0  (.opcode(instruction[15:12]), .reg_write(reg_write), .alu_op(alu_op), .alu_src(alu_src));
    
    // register - mux - alu 에 필요한 wire
    wire [3:0] reg_rd1_out;      // Register의 첫 번째 출력(Rd1_out)을 받을 전선
    wire [3:0] reg_rd2_out;      // Register의 두 번째 출력(Rd2_out)을 받을 전선
    wire [3:0] mux_out;          // MUX의 출력을 받을 전선
    wire [3:0] alu_result;       // ALU의 최종 결과(Result)를 받을 전선
    wire       alu_overflow;     // ALU의 Overflow 플래그를 받을 전선
    
    register    m1  (
        .clk(clk), .rst(rst), .RegWrite(reg_write),
        .Rd1(instruction[11:8]), .Rd2(instruction[7:4]), .Wr(instruction[3:0]), 
        .Write_data(alu_result), .Rd1_out(reg_rd1_out), .Rd2_out(reg_rd2_out));
        
    MUX_RtoA    m2  (.in0_reg(reg_rd2_out), .in1_inst(instruction[7:4]), .alu_src(alu_src), .out_data_to_alu(mux_out));
    
    alu m3 (
    .A(Rd2_out),
    .B(mux_out),
    .ALUOp(alu_op),
    .Result(alu_result),
    .Overflow(alu_overflow)
	);

	assign led = led;
	assign seg_en = clk_100M ? 2'b11 : 4'b00;
	assign seg_ab = clk_100M ? segb : sega;
	assign seg_cd = clk_100M ? segd : segc;
	assign instruction = instruction;
    
endmodule