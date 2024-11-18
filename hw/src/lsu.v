module lsu (
    input wire ls_i,        
    input wire [1:0] funct3_i,
    input wire [1:0] d_addr_i,
    input wire mem_write_i,
    input wire mem_read_i,

    output reg [3:0] d_we_o,
    output wire load_ready_o
);

    always @(*) begin
        d_we_o = 4'b0000; // No action
        if (mem_write_i) begin
            case (funct3_i[1:0])
                3'b00: begin // SB 
                    case (d_addr_i[1:0])
                        2'b00: d_we_o = 4'b0001; 
                        2'b01: d_we_o = 4'b0010; 
                        2'b10: d_we_o = 4'b0100;
                        2'b11: d_we_o = 4'b1000;
                        default: ;
                    endcase
                end
                3'b01: begin // SH
                    case (d_addr_i[1:0])
                        2'b00: d_we_o = 4'b0011; 
                        2'b10: d_we_o = 4'b1100;
                        default: ;
                    endcase
                end
                3'b10: d_we_o = 4'b1111; // SW
                default: ;
            endcase                
        end else if (mem_read_i) begin
            case (funct3_i[1:0])
                3'b00: begin // LB
                    case (d_addr_i[1:0]) 
                        2'b00: d_rd_o = 4'b0001;
                        2'b01: d_rd_o = 4'b0010; 
                        2'b10: d_rd_o = 4'b0100;
                        2'b11: d_rd_o = 4'b1000;
                        default: ;
                    endcase
                end
                3'b01: begin // LH
                    case (d_addr_i[1:0])
                        2'b00: d_rd_o = 4'b0011; 
                        2'b10: d_rd_o = 4'b1100; 
                        default: ;
                    endcase
                end
                3'b10: d_rd_o = 4'b1111; // LW
                default: ;
            endcase    
            
        end
    end

    always @(*) begin 
        if (!rst_n_i) begin
            load_ready_o <= 1'b0;
        end else begin
            if (ls_w && mem_read_w) begin
                load_ready_o <= 1'b1;
            end else begin
                load_ready_o <= 1'b0;

            end
        end
    end

endmodule