module regfile (
    input clk_i,               // Señal de reloj
    input rst_n_i,             // Señal de reset

    input enable_i,            // Señal de habilitación    
    input reg_write_i,         // Señal de control de escritura en registro
    input [4:0] rs1_i,         // Registro fuente 1
    input [4:0] rs2_i,         // Registro fuente 2
    input [4:0] rd_i,          // Registro destino
    input [31:0] write_data_i, // Datos a escribir en el registro destino
    
    output [31:0] rs1_data_o,  // Datos leídos del registro fuente 1
    output [31:0] rs2_data_o   // Datos leídos del registro fuente 2
);

    // ------------------------
    // -- completar
    integer i;
    reg [31:0] regfile [31:0];

    // Lectura de registros
    assign rs1_data_o = (rs1_i != 0) ? regfile[rs1_i] : 32'b0;  // Registro x0 siempre es 0
    assign rs2_data_o = (rs2_i != 0) ? regfile[rs2_i] : 32'b0;

    // Escritura en registros
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] <= 32'h0000_0000;
            end        
        end else begin
            if (enable_i == 1 && (reg_write_i && rd_i != 0)) begin
                regfile[rd_i] <= write_data_i;  // Escritura en el registro destino, excepto x0
            end
        end
    end
    // ------------------------

endmodule