class uart_driver extends uvm_driver #(uart_transaction);
        `uvm_component_utils(uart_driver)
        virtual virtual uart_if vif;
        uart_configuration uart_config;
        function new(string name = "uart driver", uvm_component parent);
                super.new(name, parent);
        endfunction : new

        virtual function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))begin
                         `uvm_fatal(get_type_name,$sformatf("Failed to get interface"))
                end
                if(!uvm_config_db#(uart_configuration)::get(this,"","uart_config",uart_config))begin
                         `uvm_fatal(get_type_name,$sformatf("Failed to get config"))
                end
        endfunction : build_phase

        virtual task run_phase(uvm_phase phase);
                uart_transaction drv_trans,to_sb_trans;
                bit[11:0] data,out;
                forever begin
                        seq_item_port.get(req);
                                `uvm_info(get_type_name, $sformatf("driver signal begin"), UVM_FULL)
                                drv_tx(req.data,data,out);
                                uart_vif.tx = 1'b1;
                        `uvm_info(get_type_name, $sformatf("send back data to sequencer: "), UVM_FULL)
                        seq_item_port.put(req);
                end
        endtask : run_phase

        task print_data(bit [11:0] data, bit [11:0] end_data = 11);
                string str="";
                for(int i = end_data - 1; i >= 0; i--)begin
                        if(data[i])begin
                                str = {str,"1"}
                        end
                        else begin
                                str = {str,"0"}
                        end
                end
                $display                                          ("%0d'b%s",end_data,str);
        endtask

        task drv_tx(input[8:0]data_in,output[11:0]data_out)
                bit[11:0] tx_data = 11'b0000_0000_0000;
                bit[8:0] tmp_data = 8'b0;
                bit parity_calculator;
                bit[3:0] tx_bit_total;
                case(uart_config.stop_bit)
                        2'b1: tx_data = 1'b1;
                        2'b2: tx_data = 2'b11;
                        default: begin
                                `uvm_fatal(get_type_name,$sformatf("uart_config set the stop bit outside valid range"))
                        end
                endcase
                case(uart_config.data_width)
                        4'd5: tmp_data = data_in[4:0];
                        4'd6: tmp_data = data_in[5:0];
                        4'd7: tmp_data = data_in[6:0];
                        4'd8: tmp_data = data_in[7:0];
                        4'd9: tmp_data = data_in[8:0];
                        default: begin
                                `uvm_fatal(get_type_name,$sformatf("uart_config set the data width outside valid range"))
                        end
                endcase
                `uvm_info(get_type_name, $sformatf("data random to transfer: "), UVM_LOW)
                $display("                                      (MSB->LSB)");
                print_data(tmp_data,uart_config.data wit);
                `uvm_info(get_type_name, $sformatf("tmp data is: %b", tmp_data), UVM_FULL)
                if(uart_config.parity == uart_configuration::ODD)begin
                        parity_calculator = ~(^tmp_data);
                        `uvm_info(get_type_name, $sformatf("odd mode parity is: %b", parity_calculator), UVM_FULL)

                end
                else if(uart_config.parity == uart_configuration::EVEN)begin
                        parity_calculator = (^tmp_data);
                        `uvm_info(get_type_name, $sformatf("even mode parity is: %b", parity_calculator), UVM_FULL)

                end

                if(uart_config.parity == uart_configuration::NO)begin
                        parity_calculator = 0;
                        tx_bit_total = uart_config.data_width + uart_config.stop_bit + 1;
//                      for(bit[3:0]j = 0,i = uart_config.stop_bit; i <= uart_config.data_width + (uart_config.stop_bit - 1); i++,j++)begin
                        for(bit[3:0]j = 0,i = uart_config.data.width + (uart_config_stop_bit - 1); i>= uart_config.stop.bit; i++,j++)begin
                                tx_data[i] = tmp_data[j];
                        end
                end
                else begin
                        tx_bit_total = uart_config.data_width + uart_config.stop_bit + 2;
                        tx_data{uart_config.stop_bit] = parity_calculator; 
//                      for(bit[3:0] j = 0,i = uart_config.stop_it +1; i <= uart_config.data_width + (uart_config.stop_bit - 1) +1; i++,j++)begin

                        for(bit[3:0]j = 0,i = uart_config.data.width + (uart_config_stop_bit - 1) +1; i>= uart_config.stop.bit + 1; i--,j++)begin
                                tx_data[i] = tmp_data[j];
                        end

                end                
                `uvm_info(get_type_name, $sformatf("data drive uart_tx %b", tx_data), UVM_FULL)
                `uvm_info(get_type_name, $sformatf("data after configuration and begin drive data: ", UVM_LOW)
                $display("                     [start bit;data bit(LSB->MSB);parity bit;end bit]");
                print_data(tx_data, tx_bit_total);
                        data_out = tx_data;
                for(int i = tx_bit_total - 1; i >= 0; i = i - 1)begin
                        uart.vif.tx = tx_data[i];
                        baud_rate(uart_config.baud_rate,1);
                        `uvm_info(get_type_name, $sformatf("value of uart_tx[%0d] = 1'b%b",i,tx_data[i]), UVM_FULL)
                        baud_rate(uart_config.baud_rate,1);
                end
                        data_out = tx_data;
        endtask: drv_tx
        task baud_rate(input bit[31:0] br, input bit[1:0] divide_half_cycle = 0);
                bit[31:0] number_cycle = 32'd1000000000/br;
                if(divide_half_cycle == 1)begin
                        number_cycle = number_cycle/2;
                end
                repeat(number_cycle)begin
                        #1ns;
                end
        endtask



endclass: uart_driver
                    