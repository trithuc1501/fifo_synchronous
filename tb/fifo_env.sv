class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  fifo_agent      agt;
  fifo_scoreboard scb;
  fifo_coverage   cov;

  function new(string name = "fifo_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agt = fifo_agent::type_id::create("agt", this);
    scb = fifo_scoreboard::type_id::create("scb", this);
    cov = fifo_coverage::type_id::create("cov", this);
  endfunction

  // Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    agt.mon.ap.connect(scb.item_got);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction

endclass : fifo_env