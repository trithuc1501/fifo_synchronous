interface fifo_if(
    input logic clk,
    input logic rst_n
);
    parameter Depth = 8;
    parameter Width = 8;

    logic w_en;
    logic r_en;
    logic [Width - 1:0] w_data;
    logic [Width - 1:0] r_data;
    logic full;
    logic empty;

    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        output w_en;
        output r_en;
        output w_data;
        input full;
        input empty;
        input r_data;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1ns output #1ns;
        input w_en;
        input r_en;
        input w_data;
        input full;
        input empty;
        input r_data;
    endclocking

    modport DRV (clocking drv_cb, input clk, rst_n);
    modport MON (clocking mon_cb, input clk, rst_n);
      
    property p_mutex_flags;
      @(posedge clk) disable iff (!rst_n)
      !(full && empty);
    endproperty

    property p_empty_stable;
      @(posedge clk) disable iff (!rst_n)
      (empty && !w_en) |=> empty;
    endproperty

    property p_full_stable;
      @(posedge clk) disable iff (!rst_n)
      (full && !r_en) |=> full;
    endproperty

    A_MUTEX_FLAGS : assert property(p_mutex_flags) 
                    else $fatal(1, "[SVA] FATAL ERROR: FIFO is both FULL and EMPTY at the same time!");

    A_EMPTY_STABLE: assert property(p_empty_stable) 
                    else $error("[SVA] ERROR: EMPTY flag deasserted without any Write command!");

    A_FULL_STABLE : assert property(p_full_stable) 
                    else $error("[SVA] ERROR: FULL flag deasserted without any Read command!");

endinterface
