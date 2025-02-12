module decoder (
    input [31:0] instr_i,      // 32-bit instruction register
    input wire load_ready_i,   // Signal indicating load operation is ready
    
    output reg [3:0] alu_op_o, // ALU operation signal
    output reg reg_write_o,    // Register write enable signal
    output reg branch_o,       // Conditional branch signal
    output reg jump_o,         // Unconditional jump signal
    output reg jalr_o,         // JALR signal
    output reg pc_write_o,     // Program Counter write enable signal
    output reg mem_read_o,     // Memory read enable signal
    output reg mem_write_o,    // Memory write enable signal
    output reg mem_to_reg_o,   // Write memory value to register signal
    output reg use_imm_o,      // Use immediate value signal
    output reg ls_o,           // Load/Store Unit signal

    output [4:0] rs1_o,        // Source register 1
    output [4:0] rs2_o,        // Source register 2
    output [4:0] rd_o,         // Destination register
    output reg [12:0] imm_o,   // 12-bit immediate value
    output [2:0] funct3_o      // Funct3 field
);

    // Instruction fields
    wire [6:0] opcode_o = instr_i[6:0];                                                             // Opcode
    assign rd_o = instr_i[11:7];                                                                    // Destination register
    assign funct3_o = instr_i[14:12];                                                               // Funct3 field
    assign rs1_o = instr_i[19:15];                                                                  // Source register 1
    assign rs2_o = instr_i[24:20];                                                                  // Source register 2
    wire [12:0] I_imm = {1'b0, instr_i[31:20]};                                                     // 12-bit immediate for I-type instructions
    wire [12:0] S_imm = {instr_i[31:25], instr_i[11:7]};                                            // 12-bit immediate for S-type (store)
    wire [12:0] B_imm = {instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};             // 13-bit immediate for B-type (branch)
    wire [20:0] J_imm = {instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};           // 21-bit immediate for JAL
    wire [6:0] funct7 = instr_i[31:25];                                                             // Funct7 field for R-type instructions

    always @(*) begin
        alu_op_o     = 4'bxxxx;  
        reg_write_o  = 1'b0;     
        branch_o     = 1'b0;     
        jump_o       = 1'b0;     
        pc_write_o   = 1'b1;     
        mem_read_o   = 1'b0;     
        mem_write_o  = 1'b0;     
        mem_to_reg_o = 1'b0;     
        imm_o        = I_imm;    
        use_imm_o    = 1'b0;     
        ls_o         = 1'b0;     
        jalr_o       = 1'b0;     

        case (opcode_o)
            7'b0010011: begin  // I-type instructions
                reg_write_o = 1'b1;
                use_imm_o   = 1'b1;
                imm_o       = I_imm;
                case (funct3_o)
                    3'b000: alu_op_o = 4'b0000; // ADDI
                    3'b010: alu_op_o = 4'b0001; // SLTI
                    3'b011: alu_op_o = 4'b1001; // SLTIU
                    3'b111: alu_op_o = 4'b0010; // ANDI
                    3'b110: alu_op_o = 4'b0011; // ORI
                    3'b100: alu_op_o = 4'b0100; // XORI
                    3'b001: alu_op_o = 4'b0101; // SLLI
                    3'b101: alu_op_o = 4'b0110; // SRLI or SRAI
                endcase     
            end
            7'b0110011: begin  // R-type instructions
                reg_write_o = 1'b1;
                case (funct3_o)
                    3'b000: alu_op_o = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0000; // SUB or ADD
                    3'b001: alu_op_o = 4'b0101; // SLL
                    3'b010: alu_op_o = 4'b0001; // SLT
                    3'b011: alu_op_o = 4'b1001; // SLTU
                    3'b100: alu_op_o = 4'b0100; // XOR
                    3'b101: alu_op_o = (funct7 == 7'b0100000) ? 4'b1000 : 4'b0110; // SRA or SRL
                    3'b110: alu_op_o = 4'b0011; // OR
                    3'b111: alu_op_o = 4'b0010; // AND
                endcase
            end
            7'b0100011: begin  // S-type (store)
                alu_op_o    = 4'b0000;
                mem_write_o = 1'b1;
                imm_o       = S_imm;
                ls_o        = 1'b1;
                use_imm_o   = 1'b1;
                
                if(load_ready_i) begin 
                    ls_o         = 1'b0;
                    mem_write_o   = 1'b1;
                end
            end
            7'b0000011: begin  // L-type (load)
                alu_op_o     = 4'b0000;
                reg_write_o  = 1'b1;
                mem_read_o   = 1'b1;
                mem_to_reg_o = 1'b1;
                imm_o        = I_imm;
                use_imm_o    = 1'b1;
                ls_o         = 1'b1;
                
                if(load_ready_i) begin 
                    ls_o         = 1'b0;
                    mem_read_o   = 1'b1;
                end
            end
            // ------------------------
            7'b1100011: begin  // B-type (branch)
                branch_o = 1'b1;
                imm_o    = B_imm;
                case (funct3_o)
                    3'b000: alu_op_o = 4'b0001; // BEQ
                    3'b001: alu_op_o = 4'b0001; // BNE
                    3'b100: alu_op_o = 4'b1000; // BLT
                    3'b101: alu_op_o = 4'b1011; // BGE
                    3'b110: alu_op_o = 4'b1001; // BLTU
                    3'b111: alu_op_o = 4'b1010; // BGEU
                    default: ;
                endcase
            end
            7'b1101111: begin  // JAL
                jump_o = 1'b1;
                use_imm_o = 1'b1;
                imm_o = J_imm;
                reg_write_o = 1'b1;
            end
            7'b1100111: begin  // JALR
                jump_o = 1'b1;
                jalr_o = 1'b1;
                alu_op_o = 3'b000;
                use_imm_o = 1'b1;
                imm_o = J_imm;
                reg_write_o = 1'b1;
            end
            default: ;
        endcase
    end

endmodule
