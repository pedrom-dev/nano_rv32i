module compare (
    input wire branch_i,
    input wire zero_i,
    input wire [31:0] alu_result_i,
    input wire [2:0] funct3_i,
    
    output reg take_branch_o
    
);

    always @(*) begin
        take_branch_o = 1'b0;
        if (branch_i) begin
            case (funct3_i)
                3'b000: take_branch_o = zero_i;            // BEQ
                3'b001: take_branch_o = ~zero_i;           // BNE
                3'b100: take_branch_o = alu_result_i;      // BLT
                3'b101: take_branch_o = alu_result_i;      // BGE
                3'b110: take_branch_o = alu_result_i;      // BLTU
                3'b111: take_branch_o = alu_result_i;      // BGEU
                default: take_branch_o = 1'b0;
            endcase
        end
    end

endmodule
