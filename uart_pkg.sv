`ifndef UART_PKG_SV
`define UART_PKG_SV
package uart_pkg;
  import uvm_pkg::*;

  // Include your file
        `include "uart_configuration.sv"
        `include "uart_transaction.sv"
        `include "uart_monitor.sv"
        `include "uart_driver.sv"
        `include "uart_sequencer.sv"
        `include "uart_agent.sv"

endpackage: uart_pkg

`endif
   