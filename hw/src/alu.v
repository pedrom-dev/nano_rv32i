module alu (
    input [31:0] a_i,          // Primer operando
    input [31:0] b_i,          // Segundo operando
    input [2:0] alu_op_i,      // Operación a realizar
    output reg [31:0] result_o, // Resultado de la operación
    output reg zero_o          // Señal de zero (1 si el resultado es 0)
);

    always @(*) begin
        case (alu_op_i)
            3'b000: result_o <= a_i + b_i;   // ADD
            3'b001: result_o <= a_i - b_i;   // SUB
            3'b010: result_o <= a_i & b_i;   // AND
            3'b011: result_o <= a_i | b_i;   // OR
            3'b100: result_o <= a_i ^ b_i;   // XOR
            3'b101: result_o <= a_i << b_i[4:0]; // SLL (Shift Left Logical)
            3'b110: result_o <= a_i >> b_i[4:0]; // SRL (Shift Right Logical)
            3'b111: result_o <= $signed(a_i) >>> b_i[4:0]; // SRA (Shift Right Arithmetic)
            default: result_o <= 32'b0;      // Valor por defecto
        endcase

        // Asignar la señal de zero
        if (result_o == 32'b0) begin
            zero_o <= 1'b1;
        end else begin
            zero_o <= 1'b0;
        end
    end
endmodule
