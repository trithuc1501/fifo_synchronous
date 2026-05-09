`include "fifo_if.sv"
`include "fifo_pkg.sv"
module fifo_top;
    import uvm_pkg::*;
    import fifo_pkg::*;
    
    `include "uvm_macros.svh"

    logic clk;
    logic rst_n;

    fifo_if p_if(clk, rst_n);

    fifo_sync #(
        .Depth(8), 
        .Width(8)
    ) dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .w_en   (p_if.w_en),
        .r_en   (p_if.r_en),
        .w_data (p_if.w_data),
        .r_data (p_if.r_data),
        .full   (p_if.full),
        .empty  (p_if.empty)
    );

    initial begin
        
        uvm_config_db#(virtual fifo_if)::set(null, "*", "vif", p_if);

        uvm_top.finish_on_completion = 1;   
        uvm_top.set_timeout(1ms, 1);

        run_test("fifo_base_test");
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst_n = 0;
        #20 rst_n = 1; 
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end

endmodule