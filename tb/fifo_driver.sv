class fifo_driver extends uvm_driver #(fifo_transaction);
    `uvm_component_utils(fifo_driver)

    virtual fifo_if vif;

    function new(string name = "fifo_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV", "Could not get vif from config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        vif.drv_cb.w_en <= 0;
        vif.drv_cb.r_en <= 0;
        vif.drv_cb.w_data <= 0;

        forever begin
            wait(vif.rst_n === 1);

            seq_item_port.get_next_item(req);
            driver_item(req);
            seq_item_port.item_done();
        end
    endtask

    virtual task driver_item(fifo_transaction tr);
        @(vif.drv_cb);

        vif.drv_cb.w_en <= tr.w_en;
        vif.drv_cb.r_en <= tr.r_en;
        vif.drv_cb.w_data <= tr.w_data;
        
    endtask

endclass: fifo_driver
