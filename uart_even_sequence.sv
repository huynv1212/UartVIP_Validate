class uart_even_sequence extends uvm_sequence #(uart_transaction);
        `uvm_object_utils(uart_even_sequence)
        function new(string name = "uart_rhs_txrx_sequence");
                super.new(name);
        endfunction: new
        virtual task body();
                        req = uart_transaction::type_id::create("reg");
                        start_item(req);
                        if(req.randomize()with {req.data == 12'b0000_0101_0101;
                                                                })begin
//                      `uvm_info(get_type_name,$sformatf("Transaction ramdomize is $0s",req.sprint()),UVM_LOW)
                        end
                        else begin
                                `uvm_fatal(get_type_name,$sformatf("Transaction ramdomize is ERROR"))
                        end
                        finish_item(req);
                        get_response(req);
                        #1000us;
//-------------------------------------------------------------------------------------------
                        req = uart_transaction::type_id::create("reg");
                        start_item(req);
                        if(req.randomize()with {req.data == 12'b0000_0000_1110;
                                                                })begin
//                      `uvm_info(get_type_name,$sformatf("Transaction ramdomize is $0s",req.sprint()),UVM_LOW)
                        end
                        else begin
                                `uvm_fatal(get_type_name,$sformatf("Transaction ramdomize is ERROR"))
                        end
                        finish_item(req);
                        get_response(req);
        endtask: body
endclass: uart_even_sequence
      