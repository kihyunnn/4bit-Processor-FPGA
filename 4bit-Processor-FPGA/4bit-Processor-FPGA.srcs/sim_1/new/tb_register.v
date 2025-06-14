`timescale 1ns / 1ps

module tb_alu_final;

    // --- Test Signals ---
    reg  [3:0] A_in;
    reg  [3:0] B_in;
    reg  [3:0] ALUOp_in;
    wire [3:0] Result_out;
    wire       Overflow_out;

    // --- Instantiate the ALU ---
    alu uut (
        .A(A_in),
        .B(B_in),
        .ALUOp(ALUOp_in),
        .Result(Result_out),
        .Overflow(Overflow_out)
    );
    
    initial begin
        // =================================================================
        // Part 1: 정상 경우 테스트 (A=6, B=3)
        // =================================================================
        A_in = 6;
        B_in = 3;
        
        $display("---------------------------------------------------");
        $display("Part 1: Normal Case Test Start (A=%d, B=%d)", A_in, B_in);
        $display("---------------------------------------------------");
        
        // --- Test 0: NOP ---
        ALUOp_in = 4'h0; #10;
        if(Result_out===4'd0 && !Overflow_out) $display("[PASS] Op 0: NOP"); else $display("[FAIL] Op 0: NOP");
        // --- Test 1: Write ---
        ALUOp_in = 4'h1; #10;
        if(Result_out===3 && !Overflow_out) $display("[PASS] Op 1: Write"); else $display("[FAIL] Op 1: Write");
        // --- Test 2: Read ---
        ALUOp_in = 4'h2; #10;
        if(Result_out===6 && !Overflow_out) $display("[PASS] Op 2: Read"); else $display("[FAIL] Op 2: Read");
        // --- Test 3: Copy ---
        ALUOp_in = 4'h3; #10;
        if(Result_out===6 && !Overflow_out) $display("[PASS] Op 3: Copy"); else $display("[FAIL] Op 3: Copy");
        // --- Test 4: NOT ---
        ALUOp_in = 4'h4; #10;
        if(Result_out===9 && !Overflow_out) $display("[PASS] Op 4: NOT"); else $display("[FAIL] Op 4: NOT");
        // --- Test 5: AND ---
        ALUOp_in = 4'h5; #10;
        if(Result_out===2 && !Overflow_out) $display("[PASS] Op 5: AND"); else $display("[FAIL] Op 5: AND");
        // --- Test 6: OR ---
        ALUOp_in = 4'h6; #10;
        if(Result_out===7 && !Overflow_out) $display("[PASS] Op 6: OR"); else $display("[FAIL] Op 6: OR");
        // --- Test 7: XOR ---
        ALUOp_in = 4'h7; #10;
        if(Result_out===5 && !Overflow_out) $display("[PASS] Op 7: XOR"); else $display("[FAIL] Op 7: XOR");
        // --- Test 8: NAND ---
        ALUOp_in = 4'h8; #10;
        if(Result_out===13 && !Overflow_out) $display("[PASS] Op 8: NAND"); else $display("[FAIL] Op 8: NAND");
        // --- Test 9: NOR ---
        ALUOp_in = 4'h9; #10;
        if(Result_out===8 && !Overflow_out) $display("[PASS] Op 9: NOR"); else $display("[FAIL] Op 9: NOR");
        // --- Test 10: ADD ---
        ALUOp_in = 4'hA; #10;
        if(Result_out===9 && !Overflow_out) $display("[PASS] Op A: ADD"); else $display("[FAIL] Op A: ADD");
        // --- Test 11: SUB ---
        ALUOp_in = 4'hB; #10;
        if(Result_out===3 && !Overflow_out) $display("[PASS] Op B: SUB"); else $display("[FAIL] Op B: SUB");
        // --- Test 12: ADDI ---
        ALUOp_in = 4'hC; #10;
        if(Result_out===9 && !Overflow_out) $display("[PASS] Op C: ADDI"); else $display("[FAIL] Op C: ADDI");
        // --- Test 13: SUBI ---
        ALUOp_in = 4'hD; #10;
        if(Result_out===3 && !Overflow_out) $display("[PASS] Op D: SUBI"); else $display("[FAIL] Op D: SUBI");
        // --- Test 14: Left Shift ---
        ALUOp_in = 4'hE; #10;
        if(Result_out===8 && !Overflow_out) $display("[PASS] Op E: Left Shift"); else $display("[FAIL] Op E: Left Shift");
        // --- Test 15: Right Shift ---
        ALUOp_in = 4'hF; #10;
        if(Result_out===0 && !Overflow_out) $display("[PASS] Op F: Right Shift"); else $display("[FAIL] Op F: Right Shift");

        // =================================================================
        // Part 2: 오버플로 경우 테스트 (A=5, B=4)
        // =================================================================
        A_in = 5;
        B_in = 4;

        $display("\n---------------------------------------------------");
        $display("Part 2: Overflow Case Test Start (A=%d, B=%d)", A_in, B_in);
        $display("---------------------------------------------------");

        // --- Test 0: NOP ---
        ALUOp_in = 4'h0; #10;
        if(Result_out===0 && !Overflow_out) $display("[PASS] Op 0: NOP"); else $display("[FAIL] Op 0: NOP");
        // ... (논리/이동 연산들은 Overflow가 0인지 함께 확인) ...
        ALUOp_in = 4'h5; #10;
        if(Result_out===4 && !Overflow_out) $display("[PASS] Op 5: AND"); else $display("[FAIL] Op 5: AND");
        
        // --- Test 10: ADD (Overflow 발생 예상) ---
        $display("--- Testing Op A: ADD (Expecting Overflow) ---");
        ALUOp_in = 4'hA; #10;
        if(Result_out===4'b1001 && Overflow_out) $display("[PASS] Op A: ADD - Overflow Detected!"); else $display("[FAIL] Op A: ADD - Overflow NOT Detected or wrong result.");

        // --- Test 11: SUB (Overflow 발생 안 함) ---
        $display("--- Testing Op B: SUB (No Overflow) ---");
        ALUOp_in = 4'hB; #10;
        if(Result_out===1 && !Overflow_out) $display("[PASS] Op B: SUB"); else $display("[FAIL] Op B: SUB");

        $display("---------------------------------------------------");
        $display("All Tests Finished.");
        $display("---------------------------------------------------");
        #10 $finish;
    end

endmodule