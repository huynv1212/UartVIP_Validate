class uart_test extends uvm_test;
         `uvm_component_utils (uart_test);
         uart_environment uart_env;
         virtual uart_if lhs_vif;
         virtual uart_if rhs_vif;
         uart_configuration lhs_config;
         uart_configuration rhs_config;
         function new(string name = "uart_test", uvm_component parent);
                 super.new(name,parent);
         endfunction:new
         virtual function void build_phase(uvm_phase phase);
                 super.build_phase(phase);
                 uart_env = uart_environment::type_id::create("uart_env", this);
                 lhs_config = uart_configuration::type_id::create("lhs_config");
                 rhs_config = uart_configuration::type_id::create("rhs_config");
                 if(!uvm_config_db#(virtual uart_if)::get(this,"","lhs_vif",lhs_vif) || !uvm_config_db#(virtual uart_if)::get(this,"","rhs_vif",rhs_vif))begin
                         `uvm_fatal(get_type_name(),$sformatf("Failed to get interface"))
                 end
                 uvm_config_db#(virtual uart_if)::set(this,"uart_env","lhs_vif",lhs_vif);
                 uvm_config_db#(virtual uart_if)::set(this,"uart_env","rhs_vif",rhs_vif);
                 uvm_config_db#(uart_configuration)::set(this,"uart_env","lhs_config",lhs_config);
                 uvm_config_db#(uart_configuration)::set(this,"uart_env","rhs_config",rhs_config);

         endfunction: build_phase
 
endclass: uart_test