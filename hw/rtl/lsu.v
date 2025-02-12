module lsu (
    input wire rst_n_i,
    input wire rsta_busy_i,
    input wire clk_i,

    input wire ls_i,
    input wire [1:0] funct3_i,
    input wire [31:0] d_addr_i,
    input wire [31:0] d_data_i,
    input wire mem_write_i,
    input wire mem_read_i,
    
    output reg [3:0] d_we_o,
    output reg [3:0] d_rd_o,
    output reg load_ready_o,

    // AXI Lite interface for GPIO
    output reg [31:0] s_axi_awaddr_o,  // AXI write address
    output reg s_axi_awvalid_o,       // AXI write address valid
    input wire s_axi_awready_i,       // AXI GPIO ready to accept write address

    output reg [31:0] s_axi_wdata_o,  // AXI write data
    output reg s_axi_wvalid_o,        // AXI write data valid
    input wire s_axi_wready_i,        // AXI GPIO ready to accept write data
    
    input wire          s_axi_rvalid_i,
    output reg [31:0]  s_axi_araddr_o,
    output reg          s_axi_arvalid_o,
    input wire [31:0]   s_axi_rdata_i,
    output reg         s_axi_rready_o,
    input wire          s_axi_bvalid_i,
    output wire        is_mmio_o,
    input wire          s_axi_arready_i
);
    
    wire is_mmio;
    assign is_mmio = (d_addr_i[31:24] == 8'h30);
    assign is_mmio_o = is_mmio;

    always @(*) begin
        d_we_o = 4'b0000; 
        d_rd_o = 4'b0000; 
        s_axi_awaddr_o = 32'b0;
        s_axi_awvalid_o = 1'b0;
        s_axi_wdata_o = 32'b0;
        s_axi_wvalid_o = 1'b0;
        s_axi_araddr_o = 32'b0;
        s_axi_arvalid_o = 1'b0;
        s_axi_rready_o = 1'b0;
        
        // Address decoding for AXI GPIO (mapped to 0x3XXXXXXX)
        if (d_addr_i[31:24] == 8'h30) begin 
            if (mem_write_i) begin
                // AXI Lite write logic for GPIO
                s_axi_awaddr_o = d_addr_i;       // Map memory address to AXI write address
                s_axi_awvalid_o = 1'b1;         // Indicate valid address for AXI write
                s_axi_wdata_o = d_data_i;       // Map memory write data to AXI write data
                s_axi_wvalid_o = 1'b1;          // Indicate valid data for AXI write
            end else if (mem_read_i) begin
                s_axi_araddr_o = d_addr_i; 
                s_axi_arvalid_o = 1'b1;         
            end
        end else begin
            // Standard memory operations
            if (mem_write_i) begin
                case (funct3_i[1:0])
                    2'b00: begin // SB (Store Byte)
                        case (d_addr_i[1:0])
                            2'b00: d_we_o = 4'b0001; 
                            2'b01: d_we_o = 4'b0010;
                            2'b10: d_we_o = 4'b0100;
                            2'b11: d_we_o = 4'b1000;
                            default: ;
                        endcase
                    end
                    2'b01: begin // SH (Store Half-word)
                        case (d_addr_i[1:0])
                            2'b00: d_we_o = 4'b0011;
                            2'b10: d_we_o = 4'b1100;
                            default: ;
                        endcase
                    end
                    2'b10: d_we_o = 4'b1111; // SW (Store Word)
                    default: ;
                endcase                
            end else if (mem_read_i) begin
                case (funct3_i[1:0])
                    2'b00: begin // LB (Load Byte)
                        case (d_addr_i[1:0]) 
                            2'b00: d_rd_o = 4'b0001;
                            2'b01: d_rd_o = 4'b0010; 
                            2'b10: d_rd_o = 4'b0100;
                            2'b11: d_rd_o = 4'b1000;
                            default: ;
                        endcase
                    end
                    2'b01: begin // LH (Load Half-word)
                        case (d_addr_i[1:0])
                            2'b00: d_rd_o = 4'b0011; 
                            2'b10: d_rd_o = 4'b1100;
                            default: ;
                        endcase
                    end
                    2'b10: d_rd_o = 4'b1111; // LW (Load Word)
                    default: ;
                endcase    
            end
        end
    end
    
//    always @(posedge clk_i) begin
//        if (!rst_n_i || rsta_busy_i) begin
//            load_ready_o <= 1'b0;
//        end else begin
//            if (ls_i && mem_read_i) begin
//                load_ready_o <= 1'b1;
//            end else begin
//                load_ready_o <= 1'b0;
//            end
//        end
//    end
    
    always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || rsta_busy_i) begin
        load_ready_o <= 1'b0;
    end else begin
        if (ls_i) begin
            if (mem_read_i) begin 
                if (is_mmio) begin
                    if (s_axi_rvalid_i) begin
                        load_ready_o <= 1;
                    end 
                end else begin
                    load_ready_o <= 1;
                end
            end else if (mem_write_i) begin  
                if (is_mmio) begin
                    if (s_axi_bvalid_i) begin
                        load_ready_o <= 1; 
                    end
                end 
            end else begin
                load_ready_o <= 1'b0;
            end
        end else begin
            load_ready_o <= 1'b0;
        end
    end             
end
endmodule
