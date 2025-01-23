class uart_monitor extends uvm_monitor;
        `uvm_component_utils(uart_monitor)
        virtual uart_if uart_vif;
        uart_configuration uart_config;
        int count;
        bit state;
        uvm_analysis_port#(uart_transaction) uart_mon_analysis_port;
        function new(string name = "uart_monitor", uvm_component parent);
                super.new(name, parent);
                uart_mon_analysis_port = new("uart_mon_analysis_port",this);
        endfunction;

        virtual function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))begin
                        `uvm_fatal(get_type_name,$sformatf("Failed to get interface"))
                end
                if(!uvm_config_db#(uart_configuration)::get(this,"","uart_config",uart_config))begin
                        `uvm_fatal(get_type_name,$sformatf("Failed to get config"))
                end
        endfunction: build_phase

        virtual task run_phase(uvm_phase phase);
                uart_transaction mon_trans_to_sb_trans;
                bit[11:0] rx_data;
                bit[11:0] tx_data;
                forever begin
//                      wait(uart_vif.rx==1'b0);
//                      `uvm_info(get_type_name, $sformatf("Begin capture data from uart_rx"), UVM_FULL)

                        fork
                                begin
                                        mon_rx(rx_data);
                                        `uvm_info(get_type_name, $sformatf("finish capture one transaction rx: "), UVM_FULL)
                                        mon_trans_to_sb_trans = uart_transaction::type_id::create("mon_trans_to_sb_trans", this);
                                        mon_trans_to_sb_trans.data = rx_data;
                                        mon_trans_to_sb_trans.tp_tr = uart_transaction::RX_TRANS;
                                        state=0;
                                        mon_trans_to_sb_trans.count_time_baudrate       =       count;
                                        uart_mon_analysis_port.write(mon_trans_to_sb_trans);
                                end
                                begin
                                        mon_tx(tx_data);
                                        uvm_info(get_type_name, $sformatf("finish capture one transaction tx: "), UVM_FULL)
                                        mon_trans_to_sb_trans = uart_transaction::type_id::create("mon_trans_to_sb_trans", this);
                                        mon_trans_to_sb_trans.data = tx_data;
                                        mon_trans_to_sb_trans.tp_tr = uart_transaction::TX_TRANS;
                                        state=0;
                                end
                        join
                end
        endtask:run_phase

        task baud_rate_count(input bit st = 0,output int cnt_time);
                state = st;
                fork
        
                        begin
                                while(state)begin
                                        #500ns;
                                        count++;
                                end
                                cnt_time=count;
                                count = 0;
                         `uvm_info(get_type_name, $sformatf("baurate time count :%d*500ns for one transaction ",cnt_time), UVM_FULL)
                         end

                join_none

       endtask: baud_rate_count




       task mon_rx(output bit[11:0] out_data_rx);
               bit[11:0] rx_data = 11'b0000_0000_0000;
               bit[3:0] rx_bit_total;
               wait(uart_vif.rx==1'b0);
               `uvm_info(get_type_name, $sformatf("Begin capture data from uart_rx"), UVM_FULL)

               if(uart_config.parity == uart_configuration::NO)begin
                       rx_bit_total = uart_config.data_width + uart_config.stop_bit + 1;
               end
               else begin
                       rx_bit_total = uart_config.data_width + uart_config.stop_bit + 2;
               end
               baud_rate(uart_config.baud_rate,1);
               baud_rate_count(1,count);
               for(int i = rx_bit_total - 1 ; i >= 0 ; i--)begin
                       rx_data[i] = uart_vif.rx;
                       `uvm_info(get_type_name, $sformatf("valua of uart_rx[%0d] = 1'b%0b",i,rx_data[i]), UVM_FULL)
                       baud_rate(uart_config.baud_rate);
               end
               `uvm_info(get_type_name, $sformatf("data drive uart_rx  %b", rx_data), UVM_FULL)
               out_data_rx = rx_data;
       endtask: mon_rx


       task mon_tx(output bit[1:0] out_data_tx);
               bit[11:0] tx_data = 11'b0000_0000_0000;
               bit[3:0] tx_bit_total;
               wait(uart_vif.tx==1'b0);
               `uvm_info(get_type_name, $sformatf("Begin capture data from uart_tx"), UVM_FULL)

               if(uart_config.parity == uart_configuration::NO)begin
                       tx_bit_total = uart_config.data_width + uart_config.stop_bit + 1;
               end
               else begin
                       tx_bit_total = uart_config.data_width + uart_config.stop_bit + 2;
               end
               baud_rate(uart_config.baud_rate,1);
               baud_rate_count(1,count);
               for(int i = tx_bit_total - 1 ; i >= 0 ; i--)begin
                       tx_data[i] = uart_vif.tx;
                       `uvm_info(get_type_name, $sformatf("valua of uart_tx[%0d] = 1'b%0b",i,tx_data[i]), UVM_FULL)
                       baud_rate(uart_config.baud_rate);
               end
               `uvm_info(get_type_name, $sformatf("data drive uart_tx  %b", tx_data), UVM_FULL)
               out_data_tx = tx_data;
       endtask: mon_tx


       task baud_rate(input bit[3:0] br, input bit[1:0] divide_half_cycle = 0);
               bit[31:0] number_cycle = 32'd1000000000/br;
               if(divide_half_cycle == 1)begin
                      number_cycle = number_cycle/2;
               end
               repeat(number_cycle)begin
                       #1ns;
               end
       endtask

endclass: uart_monitor
