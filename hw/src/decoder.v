    module decoder (
        input [31:0] instr_i,      // Registro de instrucción de 32 bits
        
        output reg [3:0] alu_op_o, // Señal de operación de la ALU
        output reg reg_write_o,    // Señal para escribir en registros
        output reg branch_o,       // Señal de salto condicional
        output reg jump_o,         // Señal de salto incondicional
        output reg pc_write_o,     // Señal para escribir en el PC
        output reg mem_read_o,     // Señal de lectura de memoria
        output reg mem_write_o,    // Señal de escritura en memoria
        output reg mem_to_reg_o,   // Señal para escribir valor desde memoria al registro
        output reg use_imm_o,
        output reg ls_o,           // LSU signal
    
        output [4:0] rs1_o,        // Registro fuente 1 
        output [4:0] rs2_o,        // Registro fuente 2
        output [4:0] rd_o,         // Registro destino
        output reg [11:0] imm_o,   // Inmediato de 12 bits
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

        always @(*) begin
            alu_op_o    = 3'bxxx; 
            reg_write_o = 1'b0;    
            branch_o    = 1'b0;
            jump_o      = 1'b0;  
            pc_write_o  = 1'b1;  
            mem_read_o  = 1'b0;    
            mem_write_o = 1'b0;    
            mem_to_reg_o = 1'b0;    
            imm_o       = I_imm;
            use_imm_o = 1'b0;

            case (opcode_o)
                7'b0010011: begin
                    case (funct3)
                        3'b000: begin  // ADDI
                            alu_op_o    = 4'b0000;  
                            reg_write_o = 1'b1;   
                            imm_o = I_imm;
                            use_imm_o = 1  
                        end
                        3'b010: begin  // SLTI
                            alu_op_o    = 4'b0001;  
                            reg_write_o = 1'b1;  
                            imm_o = I_imm;  
                        end
                        3'b011: begin  // SLTIU
                            alu_op_o = 4'b1001;
                            reg_write_o = 1'b1;
                            imm_o = I_imm;
                        end
                        3'b111: begin  // ANDI  
                            alu_op_o = 4'b0010;
                            reg_write_o = 1'b1;
                            imm_o = I_imm;
                        end
                        3'b110: begin  // ORI
                            alu_op_o = 4'b0011;
                            reg_write_o = 1'b1;
                            imm_o = I_imm;
                        end
                        3'b100: begin  // XORI
                            alu_op_o = 4'b0100;
                            reg_write_o = 1'b1;
                            imm_o = I_imm;
                        end
                        3'b001: begin  // SLLI 
                            alu_op_o = 4'b0101;
                            reg_write_o = 1'b1;
                            imm_o = I_imm;
                        end
                        3'b101: begin  // SRLI o SRAI   
                            alu_op_o = 4'b0110;
                            reg_write_o = 1'b1;
                            imm_o = I_imm;
                        end
                    endcase     
                end
                7'b0110011: begin  // Tipo R (Register-Register)
                    case (funct3)
                        3'b000: begin
                            if (funct7 == 7'b0000000) begin  // ADD
                                alu_op_o    = 4'b0000;
                                reg_write_o = 1'b1;
                                use_imm_o   = 1'b0;
                            end else if (funct7 == 7'b0100000) begin  // SUB
                                alu_op_o    = 4'b0111;
                                reg_write_o = 1'b1;
                                use_imm_o   = 1'b0;
                            end
                        end
                        3'b001: begin  // SLL
                            alu_op_o    = 4'b0101;
                            reg_write_o = 1'b1;
                            use_imm_o   = 1'b0;
                        end
                        3'b010: begin  // SLT
                            alu_op_o    = 4'b0001;
                            reg_write_o = 1'b1;
                            use_imm_o   = 1'b0;
                        end
                        3'b011: begin  // SLTU
                            alu_op_o    = 4'b1001;
                            reg_write_o = 1'b1;
                            use_imm_o   = 1'b0;
                        end
                        3'b100: begin  // XOR
                            alu_op_o    = 4'b0100;
                            reg_write_o = 1'b1;
                            use_imm_o   = 1'b0;
                        end
                        3'b101: begin
                            if (funct7 == 7'b0000000) begin  // SRL
                                alu_op_o    = 4'b0110;
                                reg_write_o = 1'b1;
                                use_imm_o   = 1'b0;
                            end else if (funct7 == 7'b0100000) begin  // SRA
                                alu_op_o    = 4'b1000;
                                reg_write_o = 1'b1;
                                use_imm_o   = 1'b0;
                            end
                        end
                        3'b110: begin  // OR
                            alu_op_o    = 4'b0011;
                            reg_write_o = 1'b1;
                            use_imm_o   = 1'b0;
                        end
                        3'b111: begin  // AND
                            alu_op_o    = 4'b0010;
                            reg_write_o = 1'b1;
                            use_imm_o   = 1'b0;
                        end
                    endcase
                end
                7'b0100011: begin  
                    case(funct3) 
                        3'b010: begin // SW
                            alu_op_o    = 3'b000;
                            mem_write_o = 1'b1; 
                            imm_o       = S_imm;
                            ls_o = 1'b1;
                        end
                        3'b001: begin // SH
                            alu_op_o    = 3'b000;
                            mem_write_o = 1'b1; 
                            imm_o       = S_imm;
                            ls_o = 1'b1;
                        end
                        3'b000: begin // SB
                            alu_op_o    = 3'b000;
                            mem_write_o = 1'b1; 
                            imm_o       = S_imm
                            ls_o = 1'b1;
                        end
                    endcase
                end
                7'b1100011: begin  // BEQ
                    if (funct3 == 3'b000) begin
                        alu_op_o    = 3'b001;  // Operación SUB (para comparar)
                        branch_o    = 1'b1;
                        //pc_write_o  = (rs1_o == rs2_o) ? 1'b1 : 1'b0;  // Salta si rs1 == rs2
                    end
                end
                
                7'b1101111: begin  // J (JAL con rd = x0)
                    jump_o     = 1'b1;    // Activar salto incondicional
                    //pc_write_o = 1'b1;    // Escribir en el PC la nueva dirección
                end
                
                7'b0000011: begin  // LW (load word) (MAL)
                    alu_op_o    = 3'b000;  // ADD (rs1 + offset)
                    reg_write_o = 1'b1;   
                    mem_read_o  = 1'b1;   
                    mem_to_reg_o = 1'b1;  
                    imm_o       = S_imm;  
                end
                7'b0110011: begin // SLL
                    
                end

                default: begin
                end
            endcase
        end
    endmodule
