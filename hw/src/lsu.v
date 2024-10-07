module lsu (
    input           clk_i,        // Reloj
    input           rst_n_i,        // Reset
    input [31:0]    addr_i,       // Dirección de memoria
    input [31:0]    write_data_i, // Datos para escribir en memoria
    input           mem_read_i,   // Señal para lectura de memoria
    input           mem_write_i,  // Señal para escritura en memoria
    output [31:0]   read_data_o,  // Datos leídos de memoria
    output          ready_o      // Señal lista, indica que la operación ha terminado

);

    // Definición de estados para FSM
    localparam IDLE      = 3'b000,
               WRITE     = 3'b001,
               WRITE_RESP= 3'b010,
               READ      = 3'b011,
               READ_WAIT = 3'b100;

    reg [2:0] state, next_state;

    // Señales de control
    reg axi_awvalid, axi_wvalid, axi_arvalid;
    reg [31:0] axi_awaddr, axi_araddr, axi_wdata;

    // Salida de la memoria leída
    reg [31:0] read_data;
    reg ready;

    // Asignaciones de salidas
    assign axi_awaddr_o  = axi_awaddr;
    assign axi_awvalid_o = axi_awvalid;
    assign axi_wdata_o   = axi_wdata;
    assign axi_wvalid_o  = axi_wvalid;
    assign axi_bready_o  = 1'b1;             // Siempre listo para aceptar la respuesta de escritura
    assign axi_araddr_o  = axi_araddr;
    assign axi_arvalid_o = axi_arvalid;
    assign axi_rready_o  = 1'b1;             // Siempre listo para aceptar la respuesta de lectura
    assign read_data_o   = read_data;
    assign ready_o       = ready;

    // FSM: Transiciones de estado
    always @(posedge clk_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Lógica de estado siguiente
    always @(*) begin
        next_state = state;  // Estado por defecto es el mismo
        case (state)
            IDLE: begin
                if (mem_write_i) begin
                    next_state = WRITE;
                end else if (mem_read_i) begin
                    next_state = READ;
                end
            end

            WRITE: begin
                if (axi_awready_i && axi_wready_i) begin
                    next_state = WRITE_RESP;
                end
            end

            WRITE_RESP: begin
                if (axi_bvalid_i) begin
                    next_state = IDLE;
                end
            end

            READ: begin
                if (axi_arready_i) begin
                    next_state = READ_WAIT;
                end
            end

            READ_WAIT: begin
                if (axi_rvalid_i) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Lógica de control
    always @(posedge clk_i) begin
        if (!rst_n_i) begin
            axi_awvalid <= 1'b0;
            axi_wvalid  <= 1'b0;
            axi_arvalid <= 1'b0;
            read_data   <= 32'b0;
            ready       <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1'b0;
                    if (mem_write_i) begin
                        axi_awaddr <= addr_i;
                        axi_wdata  <= write_data_i;
                        axi_awvalid <= 1'b1;
                        axi_wvalid  <= 1'b1;
                    end else if (mem_read_i) begin
                        axi_araddr <= addr_i;
                        axi_arvalid <= 1'b1;
                    end
                end

                WRITE: begin
                    if (axi_awready_i) begin
                        axi_awvalid <= 1'b0;
                    end
                    if (axi_wready_i) begin
                        axi_wvalid <= 1'b0;
                    end
                end

                WRITE_RESP: begin
                    if (axi_bvalid_i) begin
                        ready <= 1'b1;
                    end
                end

                READ: begin
                    if (axi_arready_i) begin
                        axi_arvalid <= 1'b0;
                    end
                end

                READ_WAIT: begin
                    if (axi_rvalid_i) begin
                        read_data <= axi_rdata_i;
                        ready <= 1'b1;
                    end
                end
            endcase
        end
    end
endmodule
