class uart_lhs_rhs_combination2_test extends uart_test;
        `uvm_component_utils(uart_lhs_rhs_combination2_test)
        uart lhs_txrx_sequence lhs_txrx_seq;
        uart lhs_txrx_sequence rhs_txrx_seq;
        function new(string name = "uart_lhs_rhs_combination2_test", uvm_component parent);
                super.new(name, parent);
        endfunction: new
        virtual task run_phase(uvm_phase phase);
                $display("**************************************** uart_lhs_rhs_combination2_test ****************************************");
      
                if(lhs_config.randomize() with {lhs_config.stop_bit == 2'd2;
                                                lhs_config.parity == uart_configuration::EVEN;
                                                lhs_config.data_width == 4'd6;
                                                lhs_config.baud_rate == 32'd9600;
                                                                                         }) begin
                        `uvm_info(get_type_name,$sformatf("Uart lhs_config ramdomize is",lhs_config.sprint()),UVM_LOW)
                end
                else begin
                        `uvm_fatal(get_type_name,$sformatf("Config ramdomize is ERROR"))
                end
                if(rhs_config.randomize() with {rhs_config.stop_bit == 2'd2;
                                                rhs_config.parity == uart_configuration::EVEN;
                                                rhs_config.data_width == 4'd6;
                                                rhs_config.baud_rate == 32'd9600;
                                                                                         }) begin
                        `uvm_info(get_type_name,$sformatf("Uart rhs_config ramdomize is",rhs_config.sprint()),UVM_LOW)
                end
                else begin
                        `uvm_fatal(get_type_name,$sformatf("Config ramdomize is ERROR"))
                end
               

                phase.raise_objection(this);
                        fork
                                begin
                                        lhs_txrx_seq = uart_lhs_txrx_sequence::type_id::create("lhs_txrx_seq");
                                        lhs_txrx_seq.start(uart_env.uart_lhs.agt.uart_seq);
                                end
                                begin
                                        rhs_txrx_seq = uart_lhs_txrx_sequence::type_id::create("rhs_txrx_seq");
                                        rhs_txrx_seq.start(uart_env.uart_rhs.agt.uart_seq);
                                end
                        join
                        #100000us;
                phase.drop_objection(this);
                $display("**************************************** uart_lhs_rhs_combination2_test ****************************************");
    
        endtask: run_phase

endclass: uart_lhs_rhs_combination2_test

