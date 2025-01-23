class uart_transaction extends uvm_sequence_item;
        rand bit[11:0] data;
        int count_time_baudrate;
        typedef enum{TX_TRANS = 0, RX_TRANS = 1}type_transfer;
        type_transfer tp tr;
        `uvm_object_utils_begin (uart_transaction)
                `uvm_field_int (data    ,UVM_ALL_ON|UVM_BIN)
        `uvm_object_utils_end
        function new(string name = "uart_transaction");
                super.new(name);
        endfunction: new

endclass: uart_transaction