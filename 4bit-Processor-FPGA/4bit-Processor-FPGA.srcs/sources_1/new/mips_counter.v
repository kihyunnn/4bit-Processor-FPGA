`timescale 1ns / 1ps

module mips_counter(
    input             clk_ref,    
    input             rst,
    input      [3:0]  btn,         // 비동기 버튼
    output     [3:0]  btn_pulse    // 1클럭 펄스 출력
);
    
    wire clk_100M = clk_ref;
    wire clk_1M, clk_10K, clk_100;

    wire [3:0] s_btn;     // 동기화
    wire [3:0] d_btn;     // 디바운싱

    // 클럭 분주
    freq_div_100 u1 (.clk_ref(clk_100M), .rst(rst), .clk_div(clk_1M));
    freq_div_100 u2 (.clk_ref(clk_1M),   .rst(rst), .clk_div(clk_10K));
    freq_div_100 u3 (.clk_ref(clk_10K),  .rst(rst), .clk_div(clk_100));

    // 동기화
    synchronizer s0 (.clk(clk_100), .async_in(btn[0]), .sync_out(s_btn[0]));
    synchronizer s1 (.clk(clk_100), .async_in(btn[1]), .sync_out(s_btn[1]));
    synchronizer s2 (.clk(clk_100), .async_in(btn[2]), .sync_out(s_btn[2]));
    synchronizer s3 (.clk(clk_100), .async_in(btn[3]), .sync_out(s_btn[3]));

    // 디바운싱
    debouncer d0 (.clk(clk_100), .noisy(s_btn[0]), .debounced(d_btn[0]));
    debouncer d1 (.clk(clk_100), .noisy(s_btn[1]), .debounced(d_btn[1]));
    debouncer d2 (.clk(clk_100), .noisy(s_btn[2]), .debounced(d_btn[2]));
    debouncer d3 (.clk(clk_100), .noisy(s_btn[3]), .debounced(d_btn[3]));

    // 1클럭 펄스 생성
    reg [3:0] d_btn_d;
    reg [3:0] pulse;

    always @(posedge clk_100 or posedge rst) 
    begin
        if (rst) 
        begin
            d_btn_d <= 4'b0000;
            pulse   <= 4'b0000;
        end 
        else 
        begin
            d_btn_d <= d_btn;
            pulse   <= d_btn & ~d_btn_d;  // 상승 에지
        end
    end

    assign btn_pulse = pulse;

endmodule
