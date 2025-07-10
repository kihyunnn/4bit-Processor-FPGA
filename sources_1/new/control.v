`timescale 1ns / 1ps

module control(
    input       [3:0]   opcode,
    output  reg         reg_write,
    output  reg [3:0]   alu_op,
    output  reg         alu_src
    );
    
    always @(*) begin
    case (opcode)
        4'b0001: begin alu_op = 4'b0001; alu_src = 1; reg_write = 1; end
        4'b0010: begin alu_op = 4'b0010; alu_src = 0; reg_write = 0; end
        4'b0011: begin alu_op = 4'b0011; alu_src = 0; reg_write = 1; end
        4'b0100: begin alu_op = 4'b0100; alu_src = 0; reg_write = 1; end
        4'b0101: begin alu_op = 4'b0101; alu_src = 0; reg_write = 1; end 
        4'b0110: begin alu_op = 4'b0110; alu_src = 0; reg_write = 1; end 
        4'b0111: begin alu_op = 4'b0111; alu_src = 0; reg_write = 1; end
        4'b1000: begin alu_op = 4'b1000; alu_src = 0; reg_write = 1; end 
        4'b1001: begin alu_op = 4'b1001; alu_src = 0; reg_write = 1; end 
        4'b1010: begin alu_op = 4'b1010; alu_src = 0; reg_write = 1; end 
        4'b1011: begin alu_op = 4'b1011; alu_src = 0; reg_write = 1; end 
        4'b1100: begin alu_op = 4'b1100; alu_src = 1; reg_write = 1; end 
        4'b1101: begin alu_op = 4'b1101; alu_src = 1; reg_write = 1; end
        4'b1110: begin alu_op = 4'b1110; alu_src = 1; reg_write = 1; end  //T시프트문제 수정
        4'b1111: begin alu_op = 4'b1111; alu_src = 1; reg_write = 1; end 
        default: begin alu_op = 4'b0000; alu_src = 0; reg_write = 0; end
    endcase
end

endmodule
