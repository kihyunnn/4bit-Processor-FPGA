`timescale 1ns / 1ps

module mips_counter(
    input             clk_ref,    
    input             rst,
    input      [3:0]  btn,         // 비동기 버튼
    output     [3:0]  btn_pulse    // 1클럭 펄스 출력
);
    
    wire clk_100M = clk_ref;

    wire [3:0] s_btn;     // 동기화
    wire [3:0] d_btn;     // 디바운싱


    // 동기화
    synchronizer s0 (.clk(clk_100M), .async_in(btn[0]), .sync_out(s_btn[0]));
    synchronizer s1 (.clk(clk_100M), .async_in(btn[1]), .sync_out(s_btn[1]));
    synchronizer s2 (.clk(clk_100M), .async_in(btn[2]), .sync_out(s_btn[2]));
    synchronizer s3 (.clk(clk_100M), .async_in(btn[3]), .sync_out(s_btn[3]));

    // 디바운싱
    debouncer d0 (.clk(clk_100M), .noisy(s_btn[0]), .debounced(d_btn[0]));
    debouncer_held d1 (.clk(clk_100M), .noisy(s_btn[1]), .debounced(d_btn[1]));
    debouncer d2 (.clk(clk_100M), .noisy(s_btn[2]), .debounced(d_btn[2]));
    debouncer d3 (.clk(clk_100M), .noisy(s_btn[3]), .debounced(d_btn[3]));

    // 1클럭 펄스 생성
    reg [3:0] d_btn_d;
    reg [3:0] pulse;

    always @(posedge clk_100M or posedge rst) 
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
            //pulse   <= (d_btn & ~d_btn_d) ? 4'b1111 : 4'b0000; //에지 감지시 펄스가 최대 1클럭만 1이되며 그 이상 유지 안됨. 테스트
        end
    end

    assign btn_pulse[0] = pulse[0];
    assign btn_pulse[3] = pulse[3];
    assign btn_pulse[1] = d_btn[1];

endmodule
