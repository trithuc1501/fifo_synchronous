class fifo_coverage extends uvm_subscriber #(fifo_transaction);
  `uvm_component_utils(fifo_coverage)

  fifo_transaction req;

  covergroup fifo_cg;
    option.per_instance = 1; 
    
    cp_w_en: coverpoint req.w_en {
      bins write_off = {0};
      bins write_on  = {1};
    }
    
    cp_r_en: coverpoint req.r_en {
      bins read_off = {0};
      bins read_on  = {1};
    }

    cp_full: coverpoint req.full;
    cp_empty: coverpoint req.empty;

    cross_w_r: cross cp_w_en, cp_r_en;
  endgroup

  function new(string name = "fifo_coverage", uvm_component parent);
    super.new(name, parent);
    fifo_cg = new();
  endfunction

  virtual function void write(fifo_transaction t);
    this.req = t;
    fifo_cg.sample();
  endfunction
  
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV_REPORT", 
              $sformatf("=================================================="), UVM_NONE)
    `uvm_info("COV_REPORT", 
              $sformatf(" FINAL FUNCTIONAL COVERAGE: %0.2f %%", fifo_cg.get_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", 
              $sformatf("=================================================="), UVM_NONE)
  endfunction

endclass : fifo_coverage