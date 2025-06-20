`timescale 1ns / 1ps

module hex2ssd(
    input           [3:0]   hex,
    output  reg     [6:0]   seg
    );
    
    always @ (*)
    begin
        case(hex)
            4'h0    :   seg = 7'h3f;
            4'h1    :   seg = 7'h06;
            4'h2    :   seg = 7'h5b;
            4'h3    :   seg = 7'h4f;
            4'h4    :   seg = 7'h66;
            4'h5    :   seg = 7'h6d;
            4'h6    :   seg = 7'h7d;
            4'h7    :   seg = 7'h07;
            4'h8    :   seg = 7'h7f;
            4'h9    :   seg = 7'h67;
            4'ha    :   seg = 7'h77;
            4'hb    :   seg = 7'h7c;
            4'hc    :   seg = 7'h39;
            4'hd    :   seg = 7'h5e;
            4'he    :   seg = 7'h79;
            4'hf    :   seg = 7'h71;
            
            // 문자 출력
            4'hA: seg = 7'h3f; // o
            4'hB: seg = 7'h1c; // v0011100
            4'hC: seg = 7'h71; // f
            4'hD: seg = 7'h38; // l 0111000
            
            default: seg = 7'h7f; // all off
        endcase
    end
endmodule

