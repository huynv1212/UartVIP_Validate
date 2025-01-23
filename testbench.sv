`timescale 1us/1ns
module testbench;
  import uvm_pkg::*;
  import uart_pkg::*;
  import test_pkg::*;

  /** Instantiate UART Interface */
  uart_if lhs_if();
  uart_if rhs_if();

  /** Interconnect */
  uart_dut dut(.tx(lhs_if.rx),
               .rx(lhs_if.tx),
               .tx(rhs_if.rx),
               .rx(rhs_if.tx)
              );

  /** Set the VIP interface on the environment */
        initial begin
                lhs_if.tx = 1'b1;
                rhs_if.tx = 1'b1;
        end
  initial begin
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(),"uvm_test_top","lhs_vif",lhs_if);
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(),"uvm_test_top","rhs_vif",rhs_if);

    /** Start the UVM test */
    run_test();
  end


endmodule

