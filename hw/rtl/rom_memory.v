module rom_memory (
    input wire clk,               
    input wire ena,               
    input wire [31:0] addra,     
    output reg [31:0] douta      
);

    reg [31:0] memory [0:15]; 

    initial begin
        $readmemh("init_mem.mem", memory);
    end

    always @(posedge clk) begin
        if (ena) begin
            douta <= memory[addra[5:2]];
        end
    end
endmodule

