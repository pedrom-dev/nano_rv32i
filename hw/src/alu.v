module alu (
    input [31:0] a_i,         
    input [31:0] b_i,          
    input [3:0] alu_op_i,      
    
    output reg [31:0] result_o, 
    output reg zero_o

);

    always @(*) begin
        result_o = 32'b0;
        case (alu_op_i) 
            4'b0000: result_o = a_i + b_i;   // ADD
            4'b0001: result_o = a_i - b_i;   // SUB
            4'b0010: result_o = a_i & b_i;   // AND
            4'b0011: result_o = a_i | b_i;   // OR
            4'b0100: result_o = a_i ^ b_i;   // XOR
            4'b0101: result_o = a_i << b_i[4:0]; // SLL (Shift Left Logical)
            4'b0110: result_o = a_i >> b_i[4:0]; // SRL (Shift Right Logical)
            4'b0111: result_o = $signed(a_i) >>> b_i[4:0]; // SRA (Shift Right Arithmetic)
            4'b1000: result_o = ($signed(a_i) < $signed(b_i)) ? 32'b1 : 32'b0;
            4'b1001: result_o = a_i < b_i ? 32'b1 : 32'b0;
            default: ;
        endcase

        // Asignar la señal de zero
        zero_o = (result_o == 32'b0) ? 1'b1 : 1'b0;
    end
endmodule
