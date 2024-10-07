`timescale 1ns / 1ps

module tb_regfile;

    // Señales de prueba
    reg clk_i;
    reg rst_n_i;
    reg reg_write_i;
    reg [4:0] rs1_i;
    reg [4:0] rs2_i;
    reg [4:0] rd_i;
    reg [31:0] write_data_i;
    wire [31:0] rs1_data_o;
    wire [31:0] rs2_data_o;

    // Instanciar el módulo regfile (banco de registros)
    regfile uut (
        .clk_i(clk_i), 
        .rst_n_i(rst_n_i), 
        .reg_write_i(reg_write_i), 
        .rs1_i(rs1_i), 
        .rs2_i(rs2_i), 
        .rd_i(rd_i), 
        .write_data_i(write_data_i), 
        .rs1_data_o(rs1_data_o), 
        .rs2_data_o(rs2_data_o)
    );

    // Generador de reloj
    always #5 clk_i = ~clk_i;  // Reloj de 10ns (100 MHz)

    initial begin
        // Inicialización de señales
        clk_i = 0;
        rst_n_i = 0;
        reg_write_i = 0;
        rs1_i = 0;
        rs2_i = 0;
        rd_i = 0;
        write_data_i = 0;

        // Aplicar reset
        #10 rst_n_i = 1;  // Quitamos el reset después de 10 ns
        
        // Escritura en el registro 1
        #10 rd_i = 5'd1;  // Registro destino: 1
            write_data_i = 32'hDEADBEEF;  // Dato a escribir
            reg_write_i = 1;  // Activar escritura

        #10 reg_write_i = 0;  // Desactivar escritura

        // Leer desde el registro 1
        #10 rs1_i = 5'd1;  // Leer el registro fuente 1

        // Escritura en el registro 2
        #10 rd_i = 5'd2;  // Registro destino: 2
            write_data_i = 32'hCAFEBABE;  // Dato a escribir
            reg_write_i = 1;

        #10 reg_write_i = 0;  // Desactivar escritura

        // Leer desde el registro 2
        #10 rs2_i = 5'd2;  // Leer el registro fuente 2

        // Probar lectura del registro 0 (siempre debe ser 0)
        #10 rs1_i = 5'd0;  // Leer el registro x0
            rs2_i = 5'd0;  // Leer el registro x0

        // Finalizar simulación
        #50 $finish;
    end

        // Monitor de estado del banco de registros
    always @(posedge clk_i) begin
        if (!rst_n_i) begin
            $display("Reseteando el banco de registros...");
        end else begin
            $display("Banco de registros en el ciclo de reloj actual:");
            for (int i = 0; i < 32; i = i + 1) begin
                $display("Registro [%0d] = %h", i, uut.regfile[i]);
            end
            $display("---------------------------------------------");
        end
    end

endmodule

