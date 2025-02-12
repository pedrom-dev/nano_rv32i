module lsu_tb;

    reg clk;
    reg rst_n;
    reg [2:0] funct3;
    reg [31:0] d_addr;
    reg [31:0] d_data;
    reg mem_read;
    reg mem_write;
    wire [31:0] d_data_out;

    lsu dut (
        .clk_i(clk),
        .rst_n_i(rst_n),
        .funct3_i(funct3),
        .d_addr_i(d_addr),
        .d_data_i(d_data),
        .mem_read_i(mem_read),
        .mem_write_i(mem_write),
        .d_data_o(d_data_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        funct3 = 3'b000;
        d_addr = 32'h00000000;
        d_data = 32'h00000000;
        mem_read = 0;
        mem_write = 0;

        #10 rst_n = 1;

        #10 d_addr = 32'h00000004;
            d_data = 32'hDEADBEEF;
            mem_write = 1;
            funct3 = 3'b010; // SW

        #10 mem_write = 0;

        #10 d_addr = 32'h00000004;
            mem_read = 1;
            funct3 = 3'b010; // LW

        #10 mem_read = 0;

        #10 $finish;
    end

endmodule
