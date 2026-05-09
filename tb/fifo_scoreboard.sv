class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_imp #(fifo_transaction, fifo_scoreboard) item_got;

    bit [7:0] expectation_queue [$];
    int match_count = 0;
    int error_count = 0;

    function new(string name = "fifo_scoreboard", uvm_component parent);
        super.new(name, parent);
        item_got = new("item_got", this);
    endfunction

    virtual function void write(fifo_transaction tr);
        if(tr.w_en && !tr.full) begin
            expectation_queue.push_back(tr.w_data);
            `uvm_info("SCB", $sformatf("Stored: %h | Queue Size: %0d", tr.w_data, expectation_queue.size()), UVM_LOW)
        end

        if(tr.r_en && !tr.empty) begin
            if (expectation_queue.size() > 0) begin
                bit [7:0] expected_data;
                expected_data = expectation_queue.pop_front();

                if(tr.r_data === expected_data) begin
                    `uvm_info("SCB", $sformatf("PASS: Captured %h | Expected %h", tr.r_data, expected_data), UVM_LOW)
                    match_count++;
                end else begin
                    `uvm_error("SCB", $sformatf("FAIL: Captured %h | Expected %h", tr.r_data, expected_data))
                    error_count++;
                end
            end else begin
                `uvm_error("SCB", "Read operation on an empty Golden Model!")
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("SCB", "--------------------------------------", UVM_LOW)
        `uvm_info("SCB", $sformatf("FINAL REPORT: Matches: %0d, Errors: %0d", match_count, error_count), UVM_LOW)
        `uvm_info("SCB", "--------------------------------------", UVM_LOW)
    endfunction

endclass