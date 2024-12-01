`timescale 1ns / 1ps

module tb_nano_rv32i;

    reg           clk;           
    reg           rst_n;         

    wire [31:0]   i_addr;        // Current instruction address
    wire [31:0]   i_data;        // Current instruction
    wire [31:0]   d_addr;        // Data address
    wire [31:0]   d_data_in;     // Data input to memory
    wire [31:0]   d_data_out;    // Data output from memory
    wire [3:0]    d_rd;          // Memory read signal
    wire [3:0]    d_wr;          // Memory write signal
    wire          i_rd;          // Instruction read signal

    // Instantiate nano_rv32i module
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

    // Instruction memory (64 words)
    reg [31:0] instruction_mem [0:63];  
    
    // Data memory (32 words)
    reg [31:0] data_mem [0:31];  

    // Clock generation
    always #5 clk = ~clk;

    // Assign instruction memory output
    assign i_data = instruction_mem[i_addr >> 2];  // 4-byte aligned
    assign d_data_in = data_mem[d_addr >> 2];      // 4-byte aligned

    // Handle memory writes
    always @(posedge clk) begin
        if (d_wr != 4'b0000) begin
            data_mem[d_addr >> 2] <= d_data_out;
        end
    end

    // Loop variable declared outside initial block
    integer i;

    initial begin
        clk = 0;
        rst_n = 0;
        #10 rst_n = 1;

        // Program: initializing instructions
        instruction_mem[0] = 32'h00500093; // addi x1, x0, 5
        instruction_mem[1] = 32'h0000d663; // bne x1, x0, 12
        instruction_mem[4] = 32'h00105663; // bge x0, x1, 12
        instruction_mem[5] = 32'h00106463; // bltu x0, x1, 8
        instruction_mem[7] = 32'h0000e463; // bltu x1, x0, 8
        instruction_mem[8] = 32'h0000f463; // bgeu x1, x0, 8
        instruction_mem[10] = 32'h00007463; // bgeu x0, x0, 8

        // Initialize data memory
        for (i = 0; i < 32; i = i + 1) begin
            data_mem[i] = 32'h00000000;
        end

        // Example value for LOAD/STORE testing
        data_mem[1] = 32'h12345678; 

        // Simulate for 1000 clock cycles
        #1000 $finish;
    end

    // Monitor signals during simulation
    initial begin
        $monitor("Time: %d | PC: %h | Instr: %h | Addr: %h | DDataIn: %h | DDataOut: %h | D_RD: %b | D_WR: %b",
                 $time, i_addr, i_data, d_addr, d_data_in, d_data_out, d_rd, d_wr);
    end

endmodule
