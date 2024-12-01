module compare (
    input wire branch_i,
    input wire zero_i,
    input wire alu_result_i,
    input wire [2:0] funct3_i,
    
    output reg take_branch_o
    
);

    always @(*) begin
        take_branch_o = 1'b0;
        if (branch_i) begin
            case (funct3_i)
                4'b0000: take_branch_o = zero_i;            // BEQ
                4'b0001: take_branch_o = ~zero_i;           // BNE
                4'b1001: take_branch_o = alu_result_i;      // BLT
                4'b1001: take_branch_o = alu_result_i;     // BGE
                4'b0110: take_branch_o = alu_result_i;      // BLTU
                4'b0111: take_branch_o = alu_result_i;     // BGEU
                default: take_branch_o = 1'b0;
            endcase
        end
    end

endmodule
