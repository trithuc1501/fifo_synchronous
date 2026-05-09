class fifo_sequence extends uvm_sequence #(fifo_transaction);
    `uvm_object_utils(fifo_sequence)

    fifo_mode_e mode = RANDOM;
    int count = 10;
    bit [7:0] fixed_data = 8'h00;
    parameter Depth = 8;

    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction

    task body();
      case (mode)
            RANDOM: begin
                `uvm_info("SEQ", $sformatf("Starting RANDOM mode with %0d items", count), UVM_LOW)
                repeat(count) begin
                    req = fifo_transaction::type_id::create("req");
                    start_item(req);
                    if (!req.randomize()) begin
                        `uvm_error("SEQ", "Randomization failed!")
                    end
                    finish_item(req);
                end
            end

            WRITE_FULL: begin
                `uvm_info("SEQ", $sformatf("Starting WRITE_FULL mode (%0d writes)", Depth+1), UVM_LOW)
                repeat(Depth + 1) begin
                    req = fifo_transaction::type_id::create("req");
                    start_item(req);
                    if (!req.randomize() with {w_en == 1; r_en == 0;}) begin
                        `uvm_error("SEQ", "Randomization failed!")
                    end
                    finish_item(req);
                end
            end

            READ_EMPTY: begin
                `uvm_info("SEQ", $sformatf("Starting READ_EMPTY mode (%0d reads)", Depth+1), UVM_LOW)
                repeat(Depth + 1) begin
                    req = fifo_transaction::type_id::create("req");
                    start_item(req);
                    if (!req.randomize() with {w_en == 0; r_en == 1;}) begin
                        `uvm_error("SEQ", "Randomization failed!")
                    end
                    finish_item(req);
                end
            end

            DATA_STRESS: begin
                `uvm_info("SEQ", "Starting DATA_STRESS mode", UVM_LOW)
               
                repeat(Depth) begin
                    req = fifo_transaction::type_id::create("req");
                    start_item(req);
                    if (!req.randomize() with {w_en == 1; r_en == 0;}) begin
                        `uvm_error("SEQ", "Randomization failed!")
                    end
                    finish_item(req);
                end

                repeat(Depth) begin
                    req = fifo_transaction::type_id::create("req");
                    start_item(req);
                    if (!req.randomize() with {w_en == 0; r_en == 1;}) begin
                        `uvm_error("SEQ", "Randomization failed!")
                    end
                    finish_item(req);
                end
            end
        endcase
    endtask
endclass