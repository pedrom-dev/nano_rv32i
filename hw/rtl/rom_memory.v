module rom_memory (
    input wire clk,               
    input wire ena,               
    input wire [31:0] addra,     
    output reg [31:0] douta      
);

    reg [31:0] memory [0:15];  

    initial begin
        $readmemh("rom_data.hex", memory);  

    always @(posedge clk) begin
        if (ena) begin
            douta <= memory[addra[3:0]]; 
        end
    end
endmodule
