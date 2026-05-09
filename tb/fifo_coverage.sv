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

    cp_full: coverpoint req.full {
      bins full_off = {0};
      bins full_on  = {1};
      
      bins full_transition    = (0 => 1), (1 => 0); 
    }

    cp_empty: coverpoint req.empty {
      bins empty_off = {0};
      bins empty_on  = {1};
      
      bins empty_transition   = (0 => 1), (1 => 0);
    }

    cross_w_r: cross cp_w_en, cp_r_en;

    cross_write_full: cross cp_w_en, cp_full {
      bins write_at_full = binsof(cp_w_en.write_on) && binsof(cp_full.full_on);
    }

    cross_read_empty: cross cp_r_en, cp_empty {
      bins read_at_empty = binsof(cp_r_en.read_on) && binsof(cp_empty.empty_on);
    }

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