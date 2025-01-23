`ifndef GUARD_UART_SEQ_PKG_SV
`define GUARD_UART_SEQ_PKG_SV

package seq_pkg;
    import uvm_pkg::*;
    import uart_pkg::*;

          `include "uart_lhs_txrx_sequence.sv"
          `include "uart_even_sequence.sv"
          `include "uart_odd_sequence.sv"

endpackage: seq_pkg

`endif


        