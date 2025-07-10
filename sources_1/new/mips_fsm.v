`timescale 1ns / 1ps

module mips_fsm(
    input       clk,
    input       rst,
    input       btn0,
    input       btn1,
    input       btn2,
    input       btn3,
    input       [3:0]   switch,
    input       [3:0]   result,     // ALU 결과 입력 (4비트)
    input               overflow,
    output reg  [3:0]   led,        // LED 표시: 상태별 표시
    output reg  [3:0]   ssd0,       // SSD 자리별 출력
    output reg  [3:0]   ssd1,
    output reg  [3:0]   ssd2,
    output reg  [3:0]   ssd3,
    output      [15:0]  instruction,
    output reg is_overflow,
    output reg  write_pulse    // <-- 추가 테스트용 숫자이상한거더해져서
);

// 문자 표현용 매핑 값 (hex2ssd와 대응되도록)
parameter CHAR_O = 4'hA;
parameter CHAR_V = 4'hB;
parameter CHAR_F = 4'hC;
parameter CHAR_L = 4'hD;

// state
parameter [3:0] 
    s0 = 4'd0, // idle
    s1 = 4'd1, // 명령어 입력 1: opcode
    s2 = 4'd2, // 명령어 입력 2: rd1
    s3 = 4'd3, // 명령어 입력 3: rd2
    s4 = 4'd4, // 명령어 입력 4: wr
    s5 = 4'd5, // 실행
    s6 = 4'd6; // done

reg [3:0] state;

reg [3:0] opcode, rd1, rd2, wr;
reg [26:0] exec_cnt;

always @(posedge clk or posedge rst) begin
    if (rst)
    begin
        state <= s0;
    end
    else
    begin
        case (state)
            s0: // idle
            begin
                if (btn0) state <= s1;
                else if (btn3) state <= s0;
            end
            s1: // 명령어 입력 1: opcode
            begin
                if (btn0) state <= s2;
                else if (btn3) state <= s0;
            end
            s2: // 명령어 입력 2: rd1
            begin
                if (btn0) state <= s3;
                else if (btn3) state <= s0;
            end
            s3: // 명령어 입력 3: rd2
            begin
                if (btn0) state <= s4;
                else if (btn3) state <= s0;
            end
            s4: // 명령어 입력 4: wr
            begin
                if (btn0) state <= s5;
                else if (btn3) state <= s0;
            end
            s5: // 실행
            begin
                //실행하고 1초 뒤 done 27'd100_000_000
                if (exec_cnt == 27'd100_000_000) state <= s6;   
                else if (btn3) state <= s0;
            end
            s6: // Done
            begin
                if (btn0 | btn3) state <= s0;
            end
        endcase
    end
end

// s5→s6 전환 순간에만 1클럭 펄스 -> 숫자이상하게 더해져서
always @(posedge clk or posedge rst) begin
  if (rst) begin
    write_pulse <= 1'b0;
  end else begin
    // exec_cnt == 10일 때 state는 아직 s5, 
    // 다음 클럭에 state==s6로 바뀌므로 이 타이밍을 잡습니다.
    write_pulse <= (state == s5 && exec_cnt == 4'd10);
  end
end

always @(posedge clk) begin
    case (state)
        s0: // idle
        begin
            is_overflow <=0;
            led <= 4'b0000;
            exec_cnt <= 0;
            // 상태 0에서 SSD 값 초기화
            // 한번돌리고 다시 idle state로 돌아왔을 때 맨뒤에 숫자 2개가 그대로 남아있어서 초기화
            ssd0 <= 4'b0000;
            ssd1 <= 4'b0000;
            ssd2 <= 4'b0000;
            ssd3 <= 4'b0000;
        end
        s1: // 명령어 입력 1: opcode
        begin
            opcode <= switch;
            led <= 4'b1000;
            ssd0 <= switch;
        end
        s2: // 명령어 입력 2: rd1
        begin
            rd1 <= switch;
            led <= 4'b0100;
            ssd1 <= switch;
        end
        s3: // 명령어 입력 3: rd2
        begin
            rd2 <= switch;
            led <= 4'b0010;
            ssd2 <= switch;
        end
        s4: // 명령어 입력 4: wr
        begin
            wr <= switch;
            led <= 4'b0001;
            ssd3 <= switch;
        end
        s5: // 실행
        begin
            exec_cnt <= exec_cnt + 1;
        end
        s6: // Done
        begin
            led <= 4'b1111;
            if (btn1)
            begin
                is_overflow <=0;
                ssd0 <= opcode;
                ssd1 <= rd1;
                ssd2 <= rd2;
                ssd3 <= wr;
            end
            else
            begin
                if (~overflow)
                begin
                    is_overflow <= 0;
                    ssd0 <= {3'b000, result[3]};
                    ssd1 <= {3'b000, result[2]};
                    ssd2 <= {3'b000, result[1]};
                    ssd3 <= {3'b000, result[0]};
                end
                else    // overflow일 경우 
                begin
                    is_overflow <=1;
                    ssd0 <= CHAR_O;
                    ssd1 <= CHAR_V;
                    ssd2 <= CHAR_F;
                    ssd3 <= CHAR_L;                    
                end            
            end
        end
    endcase
end

    // 명령어 출력
    assign instruction = {opcode, rd1, rd2, wr};

endmodule
