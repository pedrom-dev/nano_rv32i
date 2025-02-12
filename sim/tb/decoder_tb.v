module decoder_tb;

    // Entradas
    reg [31:0] instr_i;

    // Salidas
    wire [2:0] alu_op_o;
    wire reg_write_o;
    wire branch_o;
    wire jump_o;
    wire pc_write_o;
    wire mem_read_o;
    wire mem_write_o;
    wire mem_to_reg_o;
    wire [4:0] rs1_o;
    wire [4:0] rs2_o;
    wire [4:0] rd_o;
    wire [11:0] imm_o;
    wire [6:0] opcode_o;

    // Instanciar el decodificador
    decoder uut (
        .instr_i(instr_i),
        .alu_op_o(alu_op_o),
        .reg_write_o(reg_write_o),
        .branch_o(branch_o),
        .jump_o(jump_o),
        .pc_write_o(pc_write_o),
        .mem_read_o(mem_read_o),
        .mem_write_o(mem_write_o),
        .mem_to_reg_o(mem_to_reg_o),
        .rs1_o(rs1_o),
        .rs2_o(rs2_o),
        .rd_o(rd_o),
        .imm_o(imm_o),
        .opcode_o(opcode_o)
    );

    initial begin
        // Instrucción ADDI (Tipo I)
        instr_i = 32'h00a28293; // ADDI x5, x5, 10 (rd = 5, rs1 = 5, imm = 10)
        #10;

        // Instrucción BEQ (Tipo B)
        instr_i = 32'h00a30063; // BEQ x6, x5, 10 (rs1 = 6, rs2 = 5, imm = 10)
        #10;

        // Instrucción JAL (Tipo J)
        instr_i = 32'h0040006f; // JAL x0, 4 (rd = 0, imm = 4)
        #10;

        // Instrucción LW (Tipo I)
        instr_i = 32'h00012003; // LW x4, 0(x2) (rd = 4, rs1 = 2, imm = 0)
        #10;

        // Instrucción SW (Tipo S)
        instr_i = 32'h00112023; // SW x1, 0(x2) (rs1 = 2, rs2 = 1, imm = 0)
        #10;

        // Finalizar la simulación
        $finish;
    end
endmodule
