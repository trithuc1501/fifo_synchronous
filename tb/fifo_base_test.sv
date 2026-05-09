class fifo_base_test extends uvm_test;
  `uvm_component_utils(fifo_base_test)

  fifo_env env;

  // 2. Constructor
  function new(string name = "fifo_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("TEST", "UVM Topology:", UVM_LOW)
    this.print();
  endfunction

  virtual task run_phase(uvm_phase phase);
    fifo_sequence seq;
    seq = fifo_sequence::type_id::create("seq");

    phase.raise_objection(this);

    `uvm_info("TEST", "--- STAGE 1: RUNNING READ_EMPTY ---", UVM_LOW)
    seq.mode = READ_EMPTY;
    seq.start(env.agt.sqr);

    `uvm_info("TEST", "--- STAGE 2: RUNNING WRITE_FULL ---", UVM_LOW)
    seq.mode = WRITE_FULL;
    seq.start(env.agt.sqr);

    `uvm_info("TEST", "--- STAGE 3: RUNNING DATA_STRESS ---", UVM_LOW)
    seq.mode = DATA_STRESS;
    seq.start(env.agt.sqr);

    `uvm_info("TEST", "--- STAGE 4: RUNNING RANDOM ---", UVM_LOW)
    seq.mode = RANDOM;
    seq.count = 200;
    seq.start(env.agt.sqr);

    `uvm_info("TEST", "--- STAGE 5: FINAL CLEANUP (READ_EMPTY) ---", UVM_LOW)
    seq.mode = READ_EMPTY;
    seq.start(env.agt.sqr);

    #100ns; 
    
    `uvm_info("TEST", "=======================================", UVM_LOW)
    `uvm_info("TEST", "  END MASTER SEQUENCE", UVM_LOW)
    `uvm_info("TEST", "=======================================", UVM_LOW)
    
    phase.drop_objection(this);
  endtask

endclass