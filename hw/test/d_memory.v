module d_memory
(
    input             clk_i,
    input  [31:0]     address_i,
    input             rd_i,
    input             wr_i,
    input  [31:0]     data_i,
    output reg [31:0] data_o
);

    reg [31:0] memory [255:0];

    always@(posedge clk_i) begin 
        if (rd_i) begin
            data_o <= memory[address_i];
        end else if (wr_i) begin
            memory[address_i] <= data_i;
        end
    end 

endmodule