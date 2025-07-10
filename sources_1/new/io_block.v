`timescale 1ns / 1ps

module io_block(
    // input
    input           clk,
    input   [3:0]   btn,
    input   [3:0]   switch,
    // output
    output  [3:0]   led,    // state
    output  [1:0]   seg_en, // ssd 선택 신호
    output  [6:0]   seg_ab,     // ssd data
    output  [6:0]   seg_cd     // ssd data
    );
    wire   [3:0]   result; // ALU result
    wire           overflow;
    wire            is_overflow;

    wire  [15:0]  instruction;

    wire rst = btn[3];

    wire    clk_125M = clk;
    wire    clk_1M, clk_10K, clk_100;
    //클럭생성
    wire clk_100M;
    clk_gen_100M    u0  (.clk_ref(clk_125M), .rst(rst), .clk_100M(clk_100M));

    // 클럭 분주
    freq_div_100 u1 (.clk_ref(clk_100M), .rst(rst), .clk_div(clk_1M));
    freq_div_100 u2 (.clk_ref(clk_1M),   .rst(rst), .clk_div(clk_10K));
    freq_div_100 u3 (.clk_ref(clk_10K),  .rst(rst), .clk_div(clk_100));
    
    //wire    [3:0]   a, b, c, d;
    wire    [3:0]   ssd0, ssd1, ssd2, ssd3;
    wire    [6:0]   sega, segb, segc, segd;
       
    // FSM 
    wire    [3:0]   btn_pulse;
    mips_counter    c0  (.clk_ref(clk_100M), .rst(rst), .btn(btn), .btn_pulse(btn_pulse));
    
    mips_fsm f0 (
        .clk(clk_100M), .rst(rst), .btn0(btn_pulse[0]), .btn1(btn_pulse[1]), .btn3(btn_pulse[3]), // btn1도 펄스로 교체
        .switch(switch), .result(result), .overflow(overflow),
        .led(led), .ssd3(ssd3), .ssd2(ssd2), .ssd1(ssd1), .ssd0(ssd0), 
        .instruction(instruction) , .is_overflow(is_overflow),.write_pulse(write_pulse));
        
   // hex2ssd 모듈 인스턴스화 (자리수별)
    hex2ssd     s0  (.hex(ssd0), .is_overflow(is_overflow),.seg(segd));
    hex2ssd     s1  (.hex(ssd1), .is_overflow(is_overflow),.seg(segc));
    hex2ssd     s2  (.hex(ssd2), .is_overflow(is_overflow),.seg(segb));
    hex2ssd     s3  (.hex(ssd3), .is_overflow(is_overflow),.seg(sega));
    
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
        .clk(clk_100M), .rst(rst), .RegWrite(write_pulse), .overflow(alu_overflow),
        .Rd1(instruction[11:8]), .Rd2(instruction[7:4]), .Wr(instruction[3:0]), 
        .Write_data(alu_result), .Rd1_out(reg_rd1_out), .Rd2_out(reg_rd2_out));
        
    MUX_RtoA    m2  (.in0_reg(reg_rd2_out), .in1_inst(instruction[7:4]), .alu_src(alu_src), .out_data_to_alu(mux_out));
    
    alu m3 (
    .A(reg_rd1_out),
    .B(mux_out),
    .ALUOp(alu_op),
    .Result(alu_result),
    .Overflow(alu_overflow)
	);
    // fsm에서 ALU 결과와 오버플로우 플래그를 출력으로 사용
    assign result   = alu_result;
    assign overflow = alu_overflow;
	// assign led = led;
	assign seg_en = clk_1M ? 2'b11 : 2'b00;
	assign seg_ab = clk_1M ? segb : sega;
	assign seg_cd = clk_1M ? segd : segc;
	// assign instruction = instruction;
    
endmodule