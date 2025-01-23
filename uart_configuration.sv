class uart_configuration extends uvm_object;
        typedef enum bit[1:0] {
                ODD = 2'b01
                ,EVEN = 2'b10
                ,NO = 2'b11
        }parity_bit;

        rand parity_bit parity;
        rand bit[1:0] stop_bit;
        rand bit[3:0]data_width;
        rand bit[31:0] baud_rate;

        constraint range{ data_width inside{4'd5, 4'd6, 4'd7, 4'd8, 4'd9};
                          stop_bit inside{2'd1, 2'd2};
                          baud_rate inside{32'd4800, 32'd9600, 32'd 19200, 32'd57600, 32'd115200};
                    }

        `uvm_object_utils_begin(uart_configuration)
                `uvm_field_enum (parity_bit,parity,UVM_ALL_ON|UVM_DEC)
                `uvm_field_int (data_width        ,UVM_ALL_ON|UVM_DEC)
                `uvm_field_int (stop_bit          ,UVM_ALL_ON|UVM_DEC)
                `uvm_field_int (baud_rate         ,UVM_ALL_ON|UVM_DEC)
   
        `uvm_object_utils_end
        function new(string name = "uart_configuration");
                super.new(name);
        endfunction: new
endclass