module alu_tb;

    reg clk_i;
    reg rst_n_i;

    reg [31:0] a_i;
    reg [31:0] b_i;
    reg [2:0] alu_op_i;
    
    wire [31:0] result_o;
    wire zero_o;

    alu uut (
        .a_i(a_i),
        .b_i(b_i),
        .alu_op_i(alu_op_i),
        .result_o(result_o),
        .zero_o(zero_o)
    );

    initial begin
        a_i = 32'h00000005;
        b_i = 32'h00000003;
        alu_op_i = 3'b000;  // ADD
        #10;

        a_i = 32'h00000005;
        b_i = 32'h00000005;
        alu_op_i = 3'b001;  // SUB
        #10;

        a_i = 32'hFF00FF00;
        b_i = 32'h00FF00FF;
        alu_op_i = 3'b010;  // AND
        #10;

        a_i = 32'hFF00FF00;
        b_i = 32'h00FF00FF;
        alu_op_i = 3'b011;  // OR
        #10;

        a_i = 32'hFF00FF00;
        b_i = 32'h00FF00FF;
        alu_op_i = 3'b100;  // XOR
        #10;

        a_i = 32'h00000001;
        b_i = 32'h00000002;
        alu_op_i = 3'b101;  // Shift Left Logical (SLL)
        #10;

        a_i = 32'h00000008;
        b_i = 32'h00000002;
        alu_op_i = 3'b110;  // Shift Right Logical (SRL)
        #10;

        a_i = 32'h80000000;
        b_i = 32'h00000002;
        alu_op_i = 3'b111;  // Shift Right Arithmetic (SRA)
        #10;

        $finish;
    end

endmodule
