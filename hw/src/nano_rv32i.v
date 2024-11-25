module nano_rv32i (
    input           clk_i,          // Señal de reloj (clock input)
    input           rst_n_i,        // Señal de reset activo en bajo (active-low reset)

    output reg [31:0] i_addr_o,     // Dirección de la instrucción actual que se va a leer de la memoria de instrucciones
    output reg        i_rd_o,       // Señal para activar la lectura de la instrucción (siempre activada)
    input      [31:0] i_data_i,     // Instrucción de 32 bits leída desde la memoria de instrucciones

    output reg [31:0] d_addr_o,     // Dirección de memoria de datos para operaciones de carga/almacenamiento (lectura/escritura)
    input      [31:0] d_data_i,     // Dato de 32 bits leído desde la memoria de datos
    output reg [31:0] d_data_o,     // Dato de 32 bits que se va a escribir en la memoria de datos
    
    output reg [3:0]  d_rd_o,       // Señal para activar la lectura de datos desde la memoria
    output reg [3:0]  d_we_o        // Señal de habilitación de escritura de memoria  
    
);

    wire [3:0]  alu_op_w;           // Operación que la ALU debe realizar (add, sub, etc.) | DECODER -> ALU
    wire [2:0]  funct3_w; 
    wire        reg_write_w;        // Señal que indica si se debe escribir en un registro | DECODER -> REGFILE
    wire        branch_w;           // Señal que indica si se está ejecutando una instrucción de salto condicional (branch) | DECODER -> PC CONTROL
    wire        jump_w;             // Señal que indica si se está ejecutando una instrucción de salto incondicional (jump) | DECODER -> PC CONTROL
    wire        jalr_w;
    wire        pc_write_w;         // Señal que permite escribir una nueva dirección en el Program Counter (PC) | DECODER -> PC CONTROL
    wire        use_imm_w;          
    wire        mem_read_w;         // Señal que indica si se debe leer desde la memoria de datos | DECODER -> MEMORY INTERFACE
    wire        mem_write_w;        // Señal que indica si se debe escribir en la memoria de datos | DECODER -> MEMORY INTERFACE
    wire        mem_to_reg_w;       // Señal que indica si el valor a escribir en el registro proviene de la memoria (LOAD) | DECODER -> REGFILE
    wire        take_branch_w;

    // Interfaz del archivo de registros    
    wire [31:0] rs1_data_w;         // Valor del registro fuente 1 (rs1)
    wire [31:0] rs2_data_w;         // Valor del registro fuente 2 (rs2)
    wire [4:0]  rs1_w;              // Dirección del registro fuente 1
    wire [4:0]  rs2_w;              // Dirección del registro fuente 2
    wire [4:0]  rd_w;               // Dirección del registro de destino (donde se va a escribir el resultado)

    // Interfaz de la ALU
    wire [31:0] alu_result_w;       // Resultado de la operación realizada por la ALU
    wire        zero_w;             // Señal que indica si el resultado de la ALU es cero (usado en instrucciones de salto condicional)

    //LSU's interface
    wire ls_w;
    wire [3:0] d_we_w;

    // Interfaz de memoria de datos (Lectura y Escritura)
    wire [31:0] write_data_w;       // Dato que se va a escribir en el registro de destino (puede provenir de la ALU o de la memoria)
    //wire [31:0] read_data_w;        // Dato leído desde la memoria de datos
    wire [3:0] d_strb_w;
    
    // Señales de inmediato (Immediate)
    wire [12:0] imm_w;              // Valor inmediato de 12 bits decodificado de la instrucción

    reg [31:0] pc_r; // Registro para manejar el Program Counter (PC)    
    wire stall_w;
    wire load_ready_w;
 
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            pc_r <= 32'b0;

        end else if (pc_write_w) begin
            if (jump_w) begin
                if (jalr_w) begin  
                    pc_r <= alu_result_w;      

                end else begin              
                    pc_r <= pc_r + {{18{imm_w[12]}}, imm_w};

                end
            end else if (take_branch_w) begin //branch_w quitado
                pc_r <= pc_r + {{18{imm_w[12]}}, imm_w};  

            end else if (!stall_w) begin
                pc_r <= pc_r + 4;  

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
        .jalr_o(jalr_w)

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
        .alu_result_i(alu_result_w),
        .funct3_i(funct3_w),
        .take_branch_o(take_branch_w)
    );
        
    // ------------------------
    // -- completar
    assign stall_w = (ls_w && mem_read_w) && !load_ready_w;
    // ------------------------

    always @(*) begin
        d_addr_o <= alu_result_w;
        d_data_o <= rs2_data_w; 
        d_rd_o <= reg_write_w;
        d_we_o <= d_we_w;
        d_rd_o <= d_rd_w;
    end

    assign write_data_w = jump_w ? pc_r + 4 :
                          mem_to_reg_w ? d_data_i : 
                          alu_result_w;

    
endmodule
