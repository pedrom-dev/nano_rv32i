`timescale 1ns / 1ps

module tb_nano_rv32i;

    reg           clk;           // Señal de reloj
    reg           rst_n;         // Señal de reset

    wire [31:0]   i_addr;        // Dirección de la instrucción actual
    wire [31:0]   i_data;        // Instrucción actual
    wire [31:0]   d_addr;        // Dirección de datos
    wire [31:0]   d_data_in;     // Dato de entrada para la memoria de datos
    wire [31:0]   d_data_out;    // Dato de salida de la memoria de datos
    wire [3:0]    d_rd;          // Señal de lectura de memoria
    wire [3:0]    d_wr;          // Señal de escritura de memoria
    wire          i_rd;          // Señal de lectura de instrucción

    // Instancia del módulo nano_rv32i
    nano_rv32i uut (
        .clk_i(clk),
        .rst_n_i(rst_n),
        .i_addr_o(i_addr),
        .i_rd_o(i_rd),
        .i_data_i(i_data),
        .d_addr_o(d_addr),
        .d_data_i(d_data_in),
        .d_data_o(d_data_out),
        .d_rd_o(d_rd),
        .d_we_o(d_wr)
    );

    // Memoria de instrucciones
    reg [31:0] instruction_mem [0:63];  // Memoria de instrucciones (64 posiciones)
    
    // Memoria de datos
    reg [31:0] data_mem [0:31];  // Memoria de datos (32 posiciones)

    // Generación del reloj
    always #5 clk = ~clk;

    // Asignar la instrucción de la memoria
    assign i_data = instruction_mem[i_addr >> 2];  // Direcciones alineadas a 4 bytes
    assign d_data_in = data_mem[d_addr >> 2];      // Direcciones alineadas a 4 bytes

    // Escritura en memoria de datos
    always @(posedge clk) begin
        if (d_wr != 4'b0000) begin
            data_mem[d_addr >> 2] <= d_data_out;
        end
    end

    // Declarar la variable de bucle fuera del bloque initial
    integer i;

    // Testbench para probar instrucciones nuevas
    initial begin
        // Inicialización
        clk = 0;
        rst_n = 0;
        #10 rst_n = 1;  // Quitar el reset después de 10 ns

        // Instrucciones implementadas
        // ADDI x1, x0, 5
        instruction_mem[0] = 32'h00500093; 
        // ADDI x2, x1, 10
        instruction_mem[1] = 32'h00A08113; 
        
        // SW x2, 4(x1)
        instruction_mem[2] = 32'h0020a223; 
        // LW x3, 4(x1) 
        instruction_mem[3] = 32'h00412183; 
        // JAL x4, 8 
        instruction_mem[4] = 32'h00800297; 
        // JALR x0, x4, 0
        instruction_mem[5] = 32'h00028067; 
        // BEQ x1, x0, 4 
        instruction_mem[6] = 32'h00008063; 
        // BNE x2, x1, -8 
        instruction_mem[7] = 32'hFE1080E3; 

        // Inicializar la memoria de datos
        for (i = 0; i < 32; i = i + 1) begin
            data_mem[i] = 32'h00000000;
        end

        // Colocar un valor inicial en la memoria para probar LOAD y STORE
        data_mem[1] = 32'h12345678; 

        // Simulación por 1000 ciclos de reloj
        #1000 $finish;
    end

    // Monitorear señales
    initial begin
        $monitor("Time: %d | PC: %h | Instr: %h | Addr: %h | DDataIn: %h | DDataOut: %h | D_RD: %b | D_WR: %b",
                 $time, i_addr, i_data, d_addr, d_data_in, d_data_out, d_rd, d_wr);
    end

endmodule
