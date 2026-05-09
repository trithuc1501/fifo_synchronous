class fifo_transaction extends uvm_sequence_item;
    parameter Width = 8;

    rand bit [Width - 1:0] w_data;
    rand bit w_en;
    rand bit r_en;

    bit [Width - 1:0] r_data;
    bit full;
    bit empty;

    `uvm_object_utils_begin(fifo_transaction)
        `uvm_field_int(w_data, UVM_ALL_ON)
        `uvm_field_int(w_en, UVM_ALL_ON)
        `uvm_field_int(r_en, UVM_ALL_ON)
        `uvm_field_int(r_data, UVM_ALL_ON)
        `uvm_field_int(full, UVM_ALL_ON)
        `uvm_field_int(empty, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "fifo_transaction");
        super.new(name);
    endfunction

    constraint c_wr_rd {
        w_en dist {1 := 50, 0 := 50};
        r_en dist {1 := 30, 0 := 70};
    }

endclass
