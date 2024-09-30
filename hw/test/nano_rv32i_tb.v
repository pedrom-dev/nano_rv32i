module top_tb;

    reg clk;
    reg rst_n;

    wire [31:0] i_addr_w;
    wire i_rd_w;
    wire [31:0] i_data_w;

    wire [31:0] d_addr_w;
    wire d_rd_w;
    wire [31:0] d_rdata_w;
    wire d_wr_w;
    wire [31:0] d_wdata_w;

    // Instancia del módulo top
    nano_rv32i uut (
        .clk_i(clk),
        .rst_n_i(rst_n),
        .i_addr_o(i_addr_w),
        .i_rd_o(i_rd_w),
        .i_data_i(i_data_w),
        .d_addr_o(d_addr_w),
        .d_rd_o(d_rd_w),
        .d_data_i(d_rdata_w),
        .d_wr_o(d_wr_w),
        .d_data_o(d_wdata_w)
    );


    i_memory i_memory_inst (
        .clk_i(clk),
        .address_i(i_addr_w),
        .rd_i(i_rd_w),
        .data_o(i_data_w)
    );

    d_memory d_memory_inst (
        .clk_i(clk),
        .address_i(d_addr_w),
        .rd_i(d_rd_w),
        .data_i(d_wdata_w),
        .wr_i(d_wr_w),
        .data_o(d_rdata_w)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    initial begin
        // Inicialización
        clk = 0;
        rst_n = 0;
        #10 rst_n = 1;

        #100;
        $stop;
    end
endmodule
