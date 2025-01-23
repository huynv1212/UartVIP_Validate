class uart_agent extends uvm_agent;
        `uvm_component_utils(uart_agent)
        uart_driver uart_drv;
        uart_monitor uart_mon;
        uart_sequencer uart_seq;
        virtual uart_if uart_vif;
        uart_configuration uart_config;
        function new(string name = "uart_agent", uvm_component parent);
                super.new(name, parent);
        endfunction: new

        virtual function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(is_active == UVM_ACTIVE)begin
                        `uvm_info(get_type_name, $sformatf("Active agent is configued"), UVM_MEDIUM)
                        uart_drv = uart_driver::type_id::create("uart_drv", this);
                        uart_mon = uart_monitor::type_id::create("uart_mon", this);
                        uart_seq = uart_sequencer::type_id::create("uart_seq", this);
                end
                else begin
                        `uvm_info(get_type_name, $sformatf("Passive agent is configued"), UVM_MEDIUM)
                        uart_mon = uart_monitor::type_id::create("uart_mon", this);
                end

                if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))begin
                        `uvm_fatal(get_type_name,$sformatf("Failed to get interface"))
                end
                if(!uvm_config_db#(uart_configuration)::get(this,"","uart_config",uart_config))begin
                        `uvm_fatal(get_type_name,$sformatf("Failed to get config"))
                end

                uvm_config_db#(virtual uart_if)::set(this,"uart_drv","uart_vif",uart_vif);
                uvm_config_db#(virtual uart_if)::set(this,"uart_mon","uart_vif",uart_vif);
                uvm_config_db#(uart_configuration)::set(this,"uart_drv","uart_config",uart_config);
                uvm_config_db#(uart_configuration)::set(this,"uart_mon","uart_config",uart_config);
        endfunction: build_phase

        virtual function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                if(is_active == UVM_ACTIVE)begin
                        uart_drv.seq_item_port.connect(uart_seq.seq_item_export);
                end
        endfunction:connect_phase

endclass: uart_agent
        