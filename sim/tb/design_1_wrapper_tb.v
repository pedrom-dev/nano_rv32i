`timescale 1ns / 1ps

module testbench_design_1;

    reg clk;
    reg rst_n;

    
    design_1_wrapper uut (
        .clk_i_0(clk),    
        .rst_n_i_0(rst_n) 
    );

    always #10 clk = ~clk;  
    initial begin
        
        clk = 0;
        rst_n = 0; 

        #100;       
        rst_n = 1;  

        
        #1000;      

        // End simulation
        $stop;
    end

endmodule
