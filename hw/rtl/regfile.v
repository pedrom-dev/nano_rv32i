module regfile (
    input clk_i,               // Clock signal
    input rst_n_i,             // Reset signal
    input rsta_busy_i,

    input enable_i,            // Enable signal    
    input reg_write_i,         // Register write control signal
    input [4:0] rs1_i,         // Source register 1
    input [4:0] rs2_i,         // Source register 2
    input [4:0] rd_i,          // Destination register
    input [31:0] write_data_i, // Data to write to destination register
    
    output [31:0] rs1_data_o,  // Data read from source register 1
    output [31:0] rs2_data_o   // Data read from source register 2
    
    
);

    // Register file: 32 registers, 32-bit each
    integer i;
    reg [31:0] regfile [31:0];

    // Read logic
    assign rs1_data_o = (rs1_i != 0) ? regfile[rs1_i] : 32'b0;  // x0 is always 0
    assign rs2_data_o = (rs2_i != 0) ? regfile[rs2_i] : 32'b0;

    // Write logic
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i || rsta_busy_i) begin
            // Initialize all registers to 0 on reset
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] <= 32'h0000_0000;
            end        
        end else begin
            if (enable_i == 1 && (reg_write_i && rd_i != 0)) begin
                regfile[rd_i] <= write_data_i;  // Write to destination register, except x0
            end
        end
    end

endmodule
