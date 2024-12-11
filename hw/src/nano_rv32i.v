module nano_rv32i (
    input           clk_i,          // Clock signal
    input           rst_n_i,        // Active-low reset

    output reg [31:0] i_addr_o,     // Instruction memory address
    output reg        i_rd_o,       // Instruction read enable
    input      [31:0] i_data_i,     // Instruction data

    output reg [31:0] d_addr_o,     // Data memory address
    input      [31:0] d_data_i,     // Data memory input
    output reg [31:0] d_data_o,     // Data memory output
    
    output reg [3:0]  d_rd_o,       // Data memory read enable
    output reg [3:0]  d_we_o        // Data memory write enable
);

    (* KEEP_HIERARCHY = "{TRUE}" *)wire [3:0]  alu_op_w;           // ALU operation
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [2:0]  funct3_w;           // Funct3 field
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        reg_write_w;        // Register write enable
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        branch_w;           // Conditional branch
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        jump_w;             // Unconditional jump
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        jalr_w;             // JALR jump
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        pc_write_w;         // Program Counter write enable
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        use_imm_w;          // Immediate operand selection
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        mem_read_w;         // Data memory read
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        mem_write_w;        // Data memory write
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        mem_to_reg_w;       // Write memory value to register
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        take_branch_w;      // Branch taken signal
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [3:0]  d_rd_w;             // Data memory read enable signal 

    // Register file interface
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [31:0] rs1_data_w;         // Register source 1 data
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [31:0] rs2_data_w;         // Register source 2 data
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [4:0]  rs1_w;              // Register source 1 address
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [4:0]  rs2_w;              // Register source 2 address
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [4:0]  rd_w;               // Destination register address
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [31:0] write_data_w;       // Data to be wrote

    // ALU interface
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [31:0] alu_result_w;       // ALU result
    (* KEEP_HIERARCHY = "{TRUE}" *)wire        zero_w;             // ALU zero flag

    // LSU interface
    (* KEEP_HIERARCHY = "{TRUE}" *)wire ls_w;
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [3:0] d_we_w;

    // Immediate values
    (* KEEP_HIERARCHY = "{TRUE}" *)wire [12:0] imm_w;              // 12-bit immediate value

    (* KEEP_HIERARCHY = "{TRUE}" *)reg [31:0] pc_r;                // Program Counter
    (* KEEP_HIERARCHY = "{TRUE}" *)wire stall_w;                   // Stall signal
    (* KEEP_HIERARCHY = "{TRUE}" *)wire load_ready_w;              // Load ready signal
 
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            pc_r <= 32'b0; // Reset PC
        end else if (pc_write_w) begin
            if (jump_w) begin
                pc_r <= jalr_w ? alu_result_w : pc_r + {{18{imm_w[12]}}, imm_w};
            end else if (take_branch_w) begin
                pc_r <= pc_r + {{18{imm_w[12]}}, imm_w};
            end else if (!stall_w) begin
                pc_r <= pc_r + 4; // Increment PC
            end
        end
    end

    always @(*) begin
        i_addr_o <= pc_r;
        i_rd_o <= 1'b1;
    end

    decoder decoder_inst (
        .instr_i(i_data_i),
        .alu_op_o(alu_op_w),
        .reg_write_o(reg_write_w),
        .use_imm_o(use_imm_w),
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
        .funct3_o(funct3_w),
        .ls_o(ls_w),
        .jalr_o(jalr_w),
        .load_ready_i(load_ready_w)
    );
        
    regfile regfile_inst (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .enable_i(!stall_w),
        .reg_write_i(reg_write_w),
        .rs1_i(rs1_w),
        .rs2_i(rs2_w),
        .rd_i(rd_w),
        .write_data_i(write_data_w),
        .rs1_data_o(rs1_data_w),
        .rs2_data_o(rs2_data_w)
    );
    
    alu alu_inst (
        .a_i(rs1_data_w),
        .b_i(use_imm_w ? {{18{imm_w[12]}}, imm_w} : rs2_data_w),
        .alu_op_i(alu_op_w),
        .result_o(alu_result_w),
        .zero_o(zero_w)
    );

    lsu lsu_inst (
        .rst_n_i(rst_n_i),
        .clk_i(clk_i),
        .ls_i(ls_w),
        .funct3_i(funct3_w[1:0]),
        .d_addr_i(alu_result_w[1:0]),
        .mem_read_i(mem_read_w),
        .mem_write_i(mem_write_w),
        .d_we_o(d_we_w),
        .d_rd_o(d_rd_w),
        .load_ready_o(load_ready_w)
    );

    compare compare_inst (
        .branch_i(branch_w),
        .zero_i(zero_w),
        .funct3_i(funct3_w),
        .take_branch_o(take_branch_w)
    );

    assign stall_w = (ls_w && mem_read_w) && !load_ready_w;
    
    always @(*) begin
        d_addr_o <= alu_result_w;
        d_data_o <= rs2_data_w;
        d_we_o <= d_we_w;
        d_rd_o <= d_rd_w;
    end

    assign write_data_w = jump_w ? pc_r + 4 :
                          mem_to_reg_w ? d_data_i : 
                          alu_result_w;

endmodule
