`timescale 1ns / 1ps

module tb_regfile;

    // Inputs
    reg clk_i;
    reg reset_n;
    reg [4:0] r1_addr_i;
    reg [4:0] r2_addd_i;
    reg [4:0] w_addr_i;
    reg we_i;
    reg [31:0] wdata_i;

    // Outputs
    wire [31:0] r1_data_o;
    wire [31:0] r2_data_o;

    // Instantiate the Unit Under Test (UUT)
    regfile uut (
        .clk_i(clk_i), 
        .reset_n(reset_n), 
        .r1_addr_i(r1_addr_i), 
        .r2_addd_i(r2_addd_i), 
        .w_addr_i(w_addr_i), 
        .we_i(we_i), 
        .wdata_i(wdata_i), 
        .r1_data_o(r1_data_o), 
        .r2_data_o(r2_data_o)
    );

    // Clock generation
    always #5 clk_i = ~clk_i; // 10ns clock period (100 MHz)

    initial begin
        // Initialize Inputs
        clk_i = 0;
        reset_n = 0;
        r1_addr_i = 0;
        r2_addd_i = 0;
        w_addr_i = 0;
        we_i = 0;
        wdata_i = 0;

        // Reset the regfile
        #10 reset_n = 1;

        // Write to register 1
        #10 w_addr_i = 5'd1;
            wdata_i = 32'hDEADBEEF;
            we_i = 1;
        
        #10 we_i = 0;

        // Read from register 1
        #10 r1_addr_i = 5'd1;

        // Write to register 2
        #10 w_addr_i = 5'd2;
            wdata_i = 32'hCAFEBABE;
            we_i = 1;

        #10 we_i = 0;

        // Read from register 2
        #10 r2_addd_i = 5'd2;

        // Test reading from register 0 (should always be 0)
        #10 r1_addr_i = 5'd0;
            r2_addd_i = 5'd0;

        // Finish simulation
        #50 $finish;
    end

    // Monitor output values
    initial begin
        $monitor("Time = %t | r1_addr = %d | r1_data = %h | r2_addr = %d | r2_data = %h",
                 $time, r1_addr_i, r1_data_o, r2_addd_i, r2_data_o);
    end

endmodule
