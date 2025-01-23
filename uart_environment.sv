class uart_environment extends uvm_env;
        `uvm_component_utils(uart_environment)
        uart_agent uart_lhs_agt;
        uart_agent uart_rhs_agt;
        uart_scoreboard uart_sb;
        virtual uart_if lhs_vif;
        virtual uart_if rhs_vif;
        uart_configuration lhs_config;
        uart_configuration rhs_config;
        function new(string name = "uart_environment", uvm_component parent);
                super.new(name,parent);
        endfunction: new

        virtual function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                uart_sb = uart_scoreboard::type_id::create("uart_sb", this);
                uart_lhs_agt = uart_agent::type_id::create("uart_lhs_agt", this);
                uart_rhs_agt = uart_agent::type_id::create("uart_rhs_agt", this);
                if(!uvm_config_db#(virtual uart_if)::get(this,"","lhs_vif",lhs_vif) || !uvm_config_db#(virtual uart_if)::get(this,"","rhs_vif",rhs_vif))begin
                        `uvm_fatal(get_type_name,$sformatf("Failed to get interface"))
                end
                if(!uvm_config_db#(uart_configuration)::get(this,"","lhs_config",lhs_config) || !uvm_config_db#(uart_configuration)::get(this,"","rhs_config",rhs_config))begin
                    `uvm_fatal(get_type_name,$sformatf("Failed to get config"))
                end
                uvm_config_db#(virtual uart_if)::set(this,"uart_lhs_agt","uart_vif",lhs_vif);
                uvm_config_db#(virtual uart_if)::set(this,"uart_rhs_agt","uart_vif",rhs_vif);
                uvm_config_db#(uart_configuration)::set(this,"uart_lhs_agt","uart_config",lhs_config);
                uvm_config_db#(uart_configuration)::set(this,"uart_rhs_agt","uart_config",rhs_config);
                uvm_config_db#(uart_configuration)::set(this,"uart_sb","lhs_config",lhs_config);
                uvm_config_db#(uart_configuration)::set(this,"uart_sb","rhs_config",rhs_config);
                if(lhs_config == null || rhs_config == null)begin
                       `uvm_fatal(get_type_name,$sformatf("config null"))
                end
        endfunction: build_phase

        virtual function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                uart_lhs_agt.uart_mon.uart_mon_analysis_port.connect(uart_sb.uart_lhs_mon_analysis_export);
                uart_rhs_agt.uart_mon.uart_mon_analysis_port.connect(uart_sb.uart_rhs_mon_analysis_export);
        endfunction: connect_phase

endclass: uart_environment
            