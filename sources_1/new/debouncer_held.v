
`timescale 1ns / 1ps

module debouncer_held #(
    parameter N = 2_000_000,   // 약 20ms @100MHz
    parameter K = 21
)(
    input clk,
    input noisy,
    output reg debounced
);

    reg [K-1:0] count;

    always @(posedge clk) begin
        if (noisy) 
        begin
            if (count < N)
                count <= count + 1;
            else
                debounced <= 1;  // 안정화 이후 1 유지
        end 
        else 
        begin
            count <= 0;
            debounced <= 0;      // 버튼 떼면 0으로
        end
    end

endmodule
