module decoder (
    input [31:0] instr_i,      // Registro de instrucción de 32 bits (entrada)
    
    output reg [2:0] alu_op_o, // Señal de operación de la ALU (salida)
    output reg reg_write_o,    // Señal para escribir en registros (salida)
    output reg branch_o,       // Señal de salto condicional (salida)
    output reg jump_o,         // Señal de salto incondicional (salida)
    output reg pc_write_o,     // Señal para escribir en el PC (salida)
    output reg mem_read_o,     // Señal de lectura de memoria (salida)
    output reg mem_write_o,    // Señal de escritura en memoria (salida)
    output reg mem_to_reg_o,   // Señal para escribir valor desde memoria al registro (salida)
    
    output [4:0] rs1_o,        // Registro fuente 1 (salida)
    output [4:0] rs2_o,        // Registro fuente 2 (salida)
    output [4:0] rd_o,         // Registro destino (salida)
    output reg [11:0] imm_o,       // Inmediato de 12 bits (salida)
    output [6:0] opcode_o      // Opcode de la instrucción (salida)
);

    // Instruction fields
    assign opcode_o = instr_i[6:0];      // Opcode
    assign rd_o = instr_i[11:7];         // Registro destino
    assign funct3 = instr_i[14:12];      // Función (funct3)
    assign rs1_o = instr_i[19:15];       // Registro fuente 1
    assign rs2_o = instr_i[24:20];       // Registro fuente 2
    wire  [31:0] I_imm = instr_i[31:20];       // Inmediato de 12 bits
    wire  [31:0] S_imm = {instr_i[31:25], instr_i[11:7]};  // Inmediato de 12 bits para SW
    wire  [31:0] B_imm = {instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};  // Inmediato de 13 bits para BEQ
    reg [6:0] funct7;                    // Campo funct7 para identificar instrucciones R-type

    // Decodificación de opcode y funct3 con asignación de valores por defecto
    always @(*) begin
        // Valores por defecto para las señales de control
        alu_op_o    <= 3'bxxx;  // No hay operación por defecto
        reg_write_o <= 1'b0;    // No se escribe en registros por defecto
        branch_o    <= 1'b0;    // No hay salto condicional por defecto
        jump_o      <= 1'b0;    // No hay salto incondicional por defecto
        pc_write_o  <= 1'b1;    // No se modifica el PC por defecto
        mem_read_o  <= 1'b0;    // No se lee de memoria por defecto
        mem_write_o <= 1'b0;    // No se escribe en memoria por defecto
        mem_to_reg_o<= 1'b0;    // No se pasa valor de memoria al registro por defecto
        imm_o       <= I_imm;

        case (opcode_o)
            7'b0010011: begin  // ADDI
                alu_op_o    <= 3'b000; // ADD (rs1 + inmediate)
                reg_write_o <= 1'b1;    
            end
            
            7'b1100011: begin  // BEQ
                if (funct3 == 3'b000) begin  // Comparación para BEQ
                    alu_op_o    <= 3'b001;  // Operación SUB (para comparar)
                    branch_o    <= 1'b1;    // Activar salto condicional
                    //pc_write_o  <= (rs1_o == rs2_o) ? 1'b1 : 1'b0;  // Salta si rs1 == rs2
                end
            end
            
            7'b1101111: begin  // J (JAL con rd = x0)
                jump_o     <= 1'b1;    // Activar salto incondicional
                //pc_write_o <= 1'b1;    // Escribir en el PC la nueva dirección
            end

            7'b0000011: begin  // LW (load word)
                alu_op_o    <= 3'b000;  // ADD (rs1 + offset)
                reg_write_o <= 1'b1;    // Escribir el valor cargado en el registro destino
                mem_read_o  <= 1'b1;    // Leer de la memoria
                mem_to_reg_o<= 1'b1;    // Llevar el valor de memoria al registro destino
                imm_o       <= S_imm;   // Inmediato de 12 bits
            end

            7'b0100011: begin  // SW (store word)
                alu_op_o    <= 3'b000;  // Operación ADD (sumar rs1 + offset)
                mem_write_o <= 1'b1;    // Escribir el valor de rs2 en memoria
                imm_o       <= S_imm;   // Inmediato de 12 bits
            end

            default: begin
            end
        endcase
    end
endmodule
