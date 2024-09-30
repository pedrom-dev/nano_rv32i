module dummy_axi_memory (
    input           clk_i,
    input           rst_n_i,
    
    // AXI-Lite Slave Interface
    input [31:0]    axi_awaddr_i,   // Dirección de escritura
    input           axi_awvalid_i,  // Señal válida para dirección de escritura
    output reg      axi_awready_o,  // Listo para aceptar dirección de escritura

    input [31:0]    axi_wdata_i,    // Datos de escritura
    input           axi_wvalid_i,   // Señal válida para datos de escritura
    output reg      axi_wready_o,   // Listo para aceptar datos de escritura

    output reg      axi_bvalid_o,   // Señal de respuesta válida para la escritura
    input           axi_bready_i,   // Listo para aceptar la respuesta de escritura

    input [31:0]    axi_araddr_i,   // Dirección de lectura
    input           axi_arvalid_i,  // Señal válida para dirección de lectura
    output reg      axi_arready_o,  // Listo para aceptar dirección de lectura

    output reg [31:0] axi_rdata_o,  // Datos leídos
    output reg      axi_rvalid_o,   // Señal de respuesta válida para lectura
    input           axi_rready_i    // Listo para aceptar los datos leídos
);

    reg [31:0] memory [0:255];  // Memoria de 256 posiciones de 32 bits

    // Manejo del reset
    always @(posedge clk_i) begin
        if (!rst_n_i) begin
            axi_arready_o <= 1'b1;
            axi_awready_o <= 1'b1;
            axi_wready_o  <= 1'b1;
            axi_bvalid_o  <= 1'b0;
            axi_rvalid_o  <= 1'b0;

        end else begin

            if (axi_wvalid_i) begin
                memory[axi_awaddr_i[7:0] >> 2] <= axi_wdata_i;  // Escribe en memoria
                axi_bvalid_o <= 1'b1;  // Genera la respuesta de escritura
            end 

            // Respuesta de escritura (b channel)
            if (axi_bvalid_o && axi_bready_i) begin
                axi_bvalid_o <= 1'b0;  // Se completó la operación de escritura
            end

            if (axi_arvalid_i) begin
                axi_rdata_o <= memory[axi_araddr_i[7:0] >> 2];  // Lee de memoria
                axi_rvalid_o <= 1'b1;  // Respuesta válida de lectura
            end else if (axi_rvalid_o) begin
                axi_rvalid_o <= 1'b0;  // Se completó la operación de lectura
            end
        end
    end
endmodule
