module nano_rv32i (
    input           clk_i,          // Señal de reloj (clock input)
    input           rst_n_i,        // Señal de reset activo en bajo (active-low reset)

    output reg [31:0] i_addr_o,     // Dirección de la instrucción actual que se va a leer de la memoria de instrucciones
    output reg        i_rd_o,       // Señal para activar la lectura de la instrucción (siempre activada)
    input      [31:0] i_data_i,     // Instrucción de 32 bits leída desde la memoria de instrucciones

    output reg [31:0] d_addr_o,     // Dirección de memoria de datos para operaciones de carga/almacenamiento (lectura/escritura)
    input       [31:0] d_data_i,     // Dato de 32 bits leído desde la memoria de datos
    output reg [31:0] d_data_o,     // Dato de 32 bits que se va a escribir en la memoria de datos
    output reg        d_rd_o,       // Señal para activar la lectura de datos desde la memoria
    output reg        d_wr_o       // Señal para activar la escritura de datos en la memoria
);

    wire [2:0]  alu_op_w;           // Operación que la ALU debe realizar (add, sub, etc.) | DECODER -> ALU
    wire [2:0]  funct3_w;
    wire        reg_write_w;        // Señal que indica si se debe escribir en un registro | DECODER -> REGFILE
    wire        branch_w;           // Señal que indica si se está ejecutando una instrucción de salto condicional (branch) | DECODER -> PC CONTROL
    wire        jump_w;             // Señal que indica si se está ejecutando una instrucción de salto incondicional (jump) | DECODER -> PC CONTROL
    wire        pc_write_w;         // Señal que permite escribir una nueva dirección en el Program Counter (PC) | DECODER -> PC CONTROL
    wire        use_imm_w;          
    wire        mem_read_w;         // Señal que indica si se debe leer desde la memoria de datos | DECODER -> MEMORY INTERFACE
    wire        mem_write_w;        // Señal que indica si se debe escribir en la memoria de datos | DECODER -> MEMORY INTERFACE
    wire        mem_to_reg_w;       // Señal que indica si el valor a escribir en el registro proviene de la memoria (LOAD) | DECODER -> REGFILE
    
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

    // Interfaz de memoria de datos (Lectura y Escritura)
    wire [31:0] write_data_w;       // Dato que se va a escribir en el registro de destino (puede provenir de la ALU o de la memoria)
    wire [31:0] read_data_w;        // Dato leído desde la memoria de datos
    
    // Señales de inmediato (Immediate)
    wire [11:0] imm_w;              // Valor inmediato de 12 bits decodificado de la instrucción

    reg [31:0] pc_r; // Registro para manejar el Program Counter (PC)


    always @(posedge clk_i) begin
        if (!rst_n_i) begin
            pc_r <= 32'b0;  // Inicialización del PC
            stall_pc <= 1'b0;
            stall_count <= 2'b0;
        end else if (pc_write_w) begin
            if (jump_w) begin
                pc_r <= pc_r + {{20{imm_w[11]}}, imm_w};  // Salto incondicional
            end else if (branch_w && zero_w) begin
                pc_r <= pc_r + {{20{imm_w[11]}}, imm_w};  // Salto condicional (beq)
            end else begin
                if
                pc_r <= pc_r + 4;  // Siguiente instrucción
            end
        end
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
        .ls_o(ls_w)
    );

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

    alu alu_inst (
        .a_i(rs1_data_w),
        .b_i(use_imm_w ? {{20{imm_w[11]}}, imm_w} : rs2_data_w), // Inmediato o registro
        .alu_op_i(alu_op_w),
        .result_o(alu_result_w),
        .zero_o(zero_w)
    );

    lsu lsu_inst (
        .lsu_i(ls_w),
        .funct3_i(funct3_w),
        .d_addr_i(alu_result_w),
        .d_data_i(rs2_data_o),
        .mem_read_i(mem_read_w),
        .mem_write_i(mem_write_w),
        .d_data_o(read_data_w)
    );

    //assign d_addr_o = alu_result_w; //???????
    //assign d_rd_o = reg_write_w; // ??????
    //assign d_data_o = rs2_data_w; // ????
    //assign d_wr_o = mem_write_w;
    //assign i_addr_o = pc_r;
    //assign i_rd_o = 1'b1;
    
    always @(*) begin 
        if (!rst_n_i) begin
            d_addr_o <= 32'b0;
            d_rd_o <= 1'b0;
            d_data_o <= 32'b0;
            d_wr_o <= 1'b0;
            i_addr_o <= 32'b0;
            i_rd_o <= 1'b0;

        end else begin
            d_addr_o <= alu_result_w;     
            d_rd_o <= reg_write_w;        
           d_data_o <= rs2_data_w;       
            d_wr_o <= mem_write_w;        
            i_addr_o <= pc_r;             
            i_rd_o <= 1'b1;               
        end
    end
    

    assign write_data_w = mem_to_reg_w ? read_data_w : alu_result_w;
    
endmodule
