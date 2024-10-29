    module lsu (
        input clk_i,
        int rst_n_i,
        
        input wire ls_i
        input wire [2:0] funct3_i,
        input wire [31:0] d_addr_i, // Data memory address for load/store instructions (rs1 + offset)
        input wire [31:0] d_data_i, // Data to be stored for store instructions (rs2)
        input wire mem_read_i,
        input wire mem_write_i,

        output wire d_data_o // Data to be stored in regfile for load instructions
    );

        // Simulated memory of 1024 words, each 32 bits
        reg [31:0] memory [0:1023];

        reg [31:0] load_data;
        assign d_data_o = load_data;

        always @(*) begin
            if (mem_write_i) begin
                case (funct3_i)
                    3'b000: begin // SB
                        case (d_addr_i[1:0])
                            2'b00: memory[d_addr_i[31:2]][7:0]   <= d_data_i[7:0];
                            2'b01: memory[d_addr_i[31:2]][15:8]  <= d_data_i[7:0];
                            2'b10: memory[d_addr_i[31:2]][23:16] <= d_data_i[7:0];
                            2'b11: memory[d_addr_i[31:2]][31:24] <= d_data_i[7:0];
                        endcase
                    end
                    3'b001: begin // SH 
                        case (d_addr_i[1:0])
                            2'b00: memory[d_addr_i[31:2]][15:0]  <= d_data_i[15:0];
                            2'b10: memory[d_addr_i[31:2]][31:16] <= d_data_i[15:0];
                            default: ;
                        endcase
                    end
                    3'b010: begin // SW
                        memory[d_addr_i[31:2]] <= d_data_i;
                    end
                    default: ; // No action
                endcase
                
            end else if (mem_read_i) begin
                case (funct3_i[1:0])
                    2'b00: load_data <= {{24{memory[d_addr_i[31:2]][7]}}, memory[d_addr_i[31:2]][7:0]};  // LB - Load byte with sign extension
                    2'b01: load_data <= {{16{memory[d_addr_i[31:2]][15]}}, memory[d_addr_i[31:2]][15:0]}; // LH - Load half-word with sign extension
                    2'b10: load_data <= memory[d_addr_i[31:2]];                                          // LW - Load word
                    default: load_data <= 32'b0;
                endcase
            end
        end

    endmodule