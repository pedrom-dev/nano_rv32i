`include "regfile.v"
`include "decoder.v"
`include "alu.v"
`include "lsu.v"

module nano_rv32i (
    input           clk_i,          
    input           rst_n_i,    

    output reg [31:0] i_addr_o,
    output reg        i_rd_o,
    input      [31:0] i_data_i, 

    output reg [31:0] d_addr_o,
    output reg        d_rd_o,
    input  reg [31:0] d_data_i,
    output reg        d_wr_o, 
    output reg [31:0] d_data_o 
);

    // Señales internas
    wire [2:0]  alu_op_w;
    wire        reg_write_w;
    wire        branch_w;
    wire        jump_w;
    wire        pc_write_w;
    wire        mem_read_w;
    wire        mem_write_w;
    wire        mem_to_reg_w;
    wire [31:0] rs1_data_w;
    wire [31:0] rs2_data_w;
    wire [31:0] alu_result_w;
    wire [31:0] write_data_w;
    wire [31:0] read_data_w;
    wire [4:0]  rs1_w;
    wire [4:0]  rs2_w;
    wire [4:0]  rd_w;
    wire [11:0] imm_w;
    wire        zero_w;

    // Registros para manejar el Program Counter (PC)
    reg [31:0] pc_r;

    always @(posedge clk_i) begin
        if (!rst_n_i) begin
            pc_r <= 32'b0;  // Inicialización del PC
        end else if (pc_write_w) begin
            if (jump_w) begin
                pc_r <= pc_r + {{20{imm_w[11]}}, imm_w};  // Para salto incondicional
            end else if (branch_w && zero_w) begin
                pc_r <= pc_r + {{20{imm_w[11]}}, imm_w};  // Para salto condicional (beq)
            end else begin
                pc_r <= pc_r + 4;  // Siguiente instrucción
            end
        end
    end

    // Instancia del decodificador
    decoder decoder_inst (
        .instr_i(i_data_i),
        .alu_op_o(alu_op_w),
        .reg_write_o(reg_write_w),
        .branch_o(branch_w),
        .jump_o(jump_w),
        .pc_write_o(pc_write_w),
        .mem_read_o(mem_read_w),
        .mem_write_o(mem_write_w),
        .mem_to_reg_o(mem_to_reg_w),
        .rs1_o(rs1_w),
        .rs2_o(rs2_w),
        .rd_o(rd_w),
        .imm_o(imm_w),
        .opcode_o()
    );

    // Instancia del archivo de registros
    regfile regfile_inst (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .reg_write_i(reg_write_w),
        .rs1_i(rs1_w),
        .rs2_i(rs2_w),
        .rd_i(rd_w),
        .write_data_i(write_data_w),
        .rs1_data_o(rs1_data_w),
        .rs2_data_o(rs2_data_w)
    );

    // Instancia de la ALU
    alu alu_inst (
        .a_i(rs1_data_w),
        .b_i(mem_to_reg_w ? read_data_w : {{20{imm_w[11]}}, imm_w}),  // Inmediato o valor de memoria
        .alu_op_i(alu_op_w),
        .result_o(alu_result_w),
        .zero_o(zero_w)
    );

    always @(*) begin
        d_addr_o = alu_result_w;
        d_rd_o = reg_write_w;
        d_data_o = rs2_data_w;
        d_wr_o = mem_write_w;
        i_addr_o = pc_r;
        i_rd_o = 1'b1;
    end
    

    assign write_data_w = mem_to_reg_w ? read_data_w : alu_result_w;

endmodule
