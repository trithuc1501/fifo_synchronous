class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    virtual fifo_if vif;
    uvm_analysis_port#(fifo_transaction) ap;

    function new(string name = "fifo_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("MON", "Could not get vif from config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
    fifo_transaction tr;
    
    bit       prev_w_en, prev_r_en, prev_full, prev_empty;
    bit [7:0] prev_w_data;

    prev_w_en = 0; 
    prev_r_en = 0;

    forever begin
      @(vif.mon_cb); 

        tr = fifo_transaction::type_id::create("tr");
        
        tr.w_en   = prev_w_en;
        tr.r_en   = prev_r_en;
        tr.w_data = prev_w_data;
        tr.full   = prev_full;
        tr.empty  = prev_empty;
        
        tr.r_data = vif.mon_cb.r_data; 
        
        `uvm_info("MON", $sformatf("Sent to SCB: W=%b R=%b WDATA=%h RDATA=%h", 
                  tr.w_en, tr.r_en, tr.w_data, tr.r_data), UVM_HIGH)
        
        ap.write(tr); 

      prev_w_en   = vif.mon_cb.w_en;
      prev_r_en   = vif.mon_cb.r_en;
      prev_w_data = vif.mon_cb.w_data;
      prev_full   = vif.mon_cb.full;
      prev_empty  = vif.mon_cb.empty;
      
    end
  endtask

endclass : fifo_monitor
