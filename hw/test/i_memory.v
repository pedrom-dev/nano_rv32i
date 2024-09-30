module i_memory
(
    input             clk_i,
    input  [31:0]     address_i,
    input             rd_i,
    output reg [31:0] data_o
);

    reg [31:0] memory [32:0];

    initial begin
        memory [0] = 32'h00500093;  // 0000 0000 0101 | 0000 0 | 000 | 0000 1 | 001 0011;  // ADDI x1, x0, 5
        memory [4] = 32'h00102223   ;  // 0000 000 | 0 0001 | 0000 0 | 010 | 0010 0 | 010 0011;  // SW x1, 4(x0)
        memory [8] = 32'h00108093;  // 0000 0000 0001 | 0000 1 | 000 | 0000 1 | 001 0011;  // ADDI x1, x1, 1
        memory [12] = 32'h00102083;  // 0000 000 | 0 0001 | 0000 0 | 010 | 0000 1 | 000 0011;  // LW x1, 4(x0)
        memory [16] = 32'h00108063;  // 0000 0000 0001 0000 1000 0000 0110 0011;  // BEQ x1, x0, offset
    end

    always@(posedge clk_i) begin 
        if (rd_i) begin
            data_o <= memory[address_i];
        end 
    end 


endmodule