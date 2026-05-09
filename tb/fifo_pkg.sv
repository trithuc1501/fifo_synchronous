package fifo_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum { 
        RANDOM,  
        WRITE_FULL, 
        READ_EMPTY, 
        DATA_STRESS 
    } fifo_mode_e;
    
    `include "fifo_transaction.sv"
    `include "fifo_sequence.sv"
    `include "fifo_driver.sv"
    `include "fifo_monitor.sv"
    `include "fifo_scoreboard.sv"
    `include "fifo_agent.sv"
    `include "fifo_coverage.sv"
    `include "fifo_env.sv"
    `include "fifo_base_test.sv"

endpackage : fifo_pkg