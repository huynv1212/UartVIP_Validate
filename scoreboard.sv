`uvm_analysis_imp_decl(uart_lhs_mon);
`uvm_analysis_imp_decl(uart_rhs_mon);
 
class uart_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(uart_scoreboard);
        uvm_analysis_imp_uart_lhs_mon #(uart_transaction,uart_scoreboard) uart_lhs_mon_analysis_export;
        uvm_analysis_imp_uart_rhs_mon #(uart_transaction,uart_scoreboard) uart_rhs_mon_analysis_export;
        uart_configuration lhs_config;
        uart_configuration rhs_config;
        uart_transaction drv_lhs_queue[$];
        uart_transaction drv_rhs_queue[$];
        uart_transaction mon_lhs_queue[$];
        uart_transaction mon_rhs_queue[$];
        int test_different = 0;
 
        function new( string name = "uart_scoreboard", uvm_component parent);
                super.new(name,parent);
        endfunction: new
        virtual function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                uart_lhs_mon_analysis_export = new("uart_lhs_mon_analysis_export",this);
                uart_rhs_mon_analysis_export = new("uart_rhs_mon_analysis_export",this);
                if(!uvm_config_db#(uart_configuration)::get(this,"","lhs_config",lhs_config) || !uvm_config_db#(uart_configuration)::get(this,"","rhs_config",rhs_config))begin
                        `uvm_fatal(get_type_name,$sformatf("Failed to get config"))
                end

         endfunction: build_phase
 
         virtual task run_phase(uvm_phase phase);
                 uart_transaction drv_lhs_trans;
                 uart_transaction drv_rhs_trans;
                 uart_transaction mon_lhs_trans;
                 uart_transaction mon_rhs_trans;
                 config_data_check();
                 forever begin
                         wait(drv_lhs_queue.size()!=0 && mon_rhs_queue.size()!=0)||(drv_rhs_queue.size()!=0 && mon_lhs_queue.size()!=0);
                         `uvm_info(get_type_name,$sformatf("begin compare data"),UVM_LOW)
                         if(drv_lhs_queue.size()!=0 && mon_rhs_queue.size()!=0)begin
                                 drv_lhs_trans = drv_lhs_queue.pop_front();
                                 mon_rhs_trans = mon_rhs_queue.pop_front();
                                 $display("------------------------------------------------------------");
                                 $display(" compare uart_lhs_tx and uart_rhs_rx");
                                 data_check(drv_lhs_trans.data,mon_rhs_trans.data);
                                 baudrate_check(drv_lhs_trans.count_time_baudrate,mon_rhs_trans.count_time_baudrate);

                         end
                         if(drv_rhs_queue.size()!=0 && mon_lhs_queue.size()!=0)begin
                                 drv_rhs_trans = drv_rhs_queue.pop_front();
                                 mon_lhs_trans = mon_lhs_queue.pop_front();
                                 $display("--------------------------------------------------------------------------------------------------------");
                                 $display(" compare uart_rhs_tx and uart_lhs_rx");
                                 data_check(drv_rhs_trans.data,mon_lhs_trans.data);
                                 baudrate_check(drv_rhs_trans.count_time_baudrate,mon_lhs_trans.count_time_baudrate);


                         end
                         $display("--------------------------------------------------------------------------------------------------------");

                 end

         endtask: run_phase

         function void config_data_check();
                 if(lhs_config.stop_bit != rhs_config.stop_bit)begin
                         test_different++;
                         `\uvm_warning(get_type_name,$sformatf("         *** The stop_bit of the lhs_config is different from the rhs config"))
                 end
                 if(lhs_config.data_width != rhs_config.data_width)begin
                         test_different++;
                         `\uvm_warning(get_type_name,$sformatf("         *** The data_width of the lhs_config is different from the rhs config"))
                 end
                 if(lhs_config.baud_rate != rhs_config.baud_rate)begin
                         test_different++;
                         `\uvm_warning(get_type_name,$sformatf("         *** The baud_rate of the lhs_config is different from the rhs config"))
                 end
                 if(lhs_config.parity != rhs_config.parity)begin
                         test_different++;
                         `\uvm_warning(get_type_name,$sformatf("         *** The parity_bit of the lhs_config is different from the rhs config"))
                 end
                 if(lhs_config.data_width == 4'd9 && lhs_config.parity != uart_configuration::NO)begin
                         `\uvm_fatal(get_type_name,$sformatf("Cannot configure data_width = 9 with a parity bit. Please check the configuration for the lhs_uart VIP"))
                 end
                 if(rhs_config.data_width == 4'd9 && rhs_config.parity != uart_configuration::NO)begin
                         `\uvm_fatal(get_type_name,$sformatf("Cannot configure data_width = 9 with a parity bit. Please check the configuration for the rhs_uart VIP"))
                 end


         endfunction:config_data_check

         function void data_check(input bit[11:0] tx, input bit[11:0] rx);
                 bit parity_calculator_lhs;
                 bit parity_calculator_rhs;
                 bit[3:0] bit_total;
                 bit[11:0] tmp_data_lhs;
                 bit[11:0] tmp_data_rhs;
                 if(tx==rx)begin
                         $display("              Data_bit: PASS");
                         case(lhs_config.stop_bit)
                                 2'd1: begin
                                                 if(rx[0] == 1'b1)begin
                                                         $display("        stop_bit: PASS");
                                                 end
                                                 else begin
                                                         `uvm_error(get_type_name,$sformatf("stop_bit: FAIL"));
                                                 end
                                         end
                                 2'd2: begin
                                                 if(rx[1:0] == 2'b11)begin
                                                         $display("        stop_bit: PASS");
                                                 end
                                                 else begin
                                                         `uvm_error(get_type_name,$sformatf("stop_bit: FAIL"));
                                                 end
                                         end
                                 default: begin
                                                 `uvm_fatal(get_type_name,$sformatf("lhs_config set the stop bit outside valid range"));
                                         end
                         endcase
             
                         if(lhs_config.parity == uart_configuration::NO)begin
                                 $display("              parity bit: not check in this config");
                         end  
                         else begin
                                 for(bit[3:0] j = 0; j = lhs_config.stop_bit+1; i <= lhs_config.data_width + lhs_config.stop_bit; i++,j++)begin
                                         tmp_data_lhs[j] = tx[i];
                                 end
                                 if(lhs_config.parity == uart_configuration::ODD)begin
                                         parity_calculator_lhs = ~(^tmp_data_lhs);
                                 end
                                 else if(lhs_config.parity == uart_configuration::EVEN)begin
                                         parity_calculator_lhs = (^tmp_data_lhs);
                                 end

 
                                 for(bit[3:0] j = 0, i = rhs_config.stop_bit+1; i < rhs_config.data_width + rhs_config.stop_bit; i++,j++)begin
                                         tmp_data_rhs[j] = rx[i];
                                 end
                                 if(rhs_config.parity == uart_configuration::ODD)begin
                                         parity_calculator_rhs = ~(^tmp_data_rhs);
                                 end
                                 else if(rhs_config.parity == uart_configuration::EVEN)begin
                                         parity_calculator_rhs = (^tmp_data_rhs);
                                 end
 
                                 if((tx[lhs_config.stop_bit]==parity_calculator_lhs) && (rx[rhs_config.stop_bit]==parity_calculator_rhs))begin
                                         $display("              parity bit: PASS");
                                 end
                                 else begin
                                         if(test_different != 0) begin
                                                 `uvm_info(get_type_name,$sformatf("parity_bit: FAI_L,  but test: PASS because the lhs_config is different from the rhs config"),UVM_LOW)
                                         end
                                         else begin
                                                 `uvm_error(get_type_name,$sformatf("            parity bit: FAIL"))
                                         end
                                 end
 
                         end
                         if(rhs_config.parity == uart_configuration::NO)begin
                                 bit_total = rhs_config.data_width + rhs_config.stop_bit + 1;
                         end
                         else begin
                                 bit_total = rhs_config.data_width + rhs_config.stop_bit + 2;
                         end
                         if(rx[bit_total]==1'b0)begin
                                 $display("              start_bit: PASS");
                         end
                         else begin
                                 `uvm_error(get_type_name,$sformatf("            start_bit: FAIL"))
                         end



                 end
                 else begin
                         if(test_different != 0 )begin
                                 `uvm_info(get_type_name,$sformatf("Data COMPARE between tx: b'%1b and rx: b'%1b not matching but test: PASS because the lhs_config is different from the rhs config",tx,rx),UVM_LOW)
                         end
                         else begin
        
                                 `uvm_error(get_type_name,$sformatf("            Data FAIL COMPARE between tx: b'%1b and rx: b'%1b ",tx,rx))
                         end
                 end
         endfunction:data_check
 
         function void baudrate_check(input int baudrate_tx,input int baudrate_rx);
                 if(baudrate_tx == baudrate_rx)begin
                         $display("baud_rate: PASS");
                 end
                 else begin
                         if(test_different != 0 )begin
                                                 `uvm_info(get_type_name,$sformatf("baud_rate: FAI_L, but test: PASS because the lhs_config is different from the rhs config"),UVM_LOW)
                         end
                         else begin
                                                 `uvm_error(get_type_name,$sformatf("            baud_rate: FAIL"))
                         end
                 end
         endfunction


         function void write_uart_lhs_mon(uart_transaction mon_lhs_trans);
                         if(mon_lhs_trans.tp_tr == uart_transaction::RX_TRANS)begin
                                 `uvm_info(get_type_name,$sformatf("recieved data from uart_mon_lhs_rx %b:",mon_lhs_trans.data),UVM_LOW)
                                 mon_lhs_queue.push_back(mon_lhs_trans);
                         end
                         else if(mon_lhs_trans.tp_tr == uart_transaction::TX_TRANS)begin
                                 `uvm_info(get_type_name,$sformatf("recieved data from uart_drv_lhs_tx %b:",mon_lhs_trans.data),UVM_LOW)
                                 drv_lhs_queue.push_back(mon_lhs_trans);
                         end
                         else begin
                                 `uvm_warning(get_type_name,$sformatf("NO type transaction from monitor define"))
                         end
         endfunction
         function void write_uart_rhs_mon(uart_transaction mon_rhs_trans);
                         if(mon_rhs_trans.tp_tr == uart_transaction::RX_TRANS)begin
                                 `uvm_info(get_type_name,$sformatf("recieved data from uart_mon_rhs_rx %b:",mon_rhs_trans.data),UVM_LOW)
                                 mon_rhs_queue.push_back(mon_rhs_trans);
                         end
                         else if(mon_rhs_trans.tp_tr == uart_transaction::TX_TRANS)begin
                                 `uvm_info(get_type_name,$sformatf("recieved data from uart_drv_rhs_tx %b:",mon_rhs_trans.data),UVM_LOW)
                                 drv_rhs_queue.push_back(mon_rhs_trans);
                         end
                         else begin
                                 `uvm_warning(get_type_name,$sformatf("NO type transaction from monitor define"))
                         end
         endfunction



 endclass: uart_scoreboard

       

        