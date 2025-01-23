`ifndef GUARD_UART_ENV_PKG_SV
`define GUARD_UART_ENV_PKG_SV

package env_pkg;
  import uvm_pkg::*;
  import uart_pkg::*;
        `include "uart_scoreboard.sv"
        `include "uart_environment.sv"
endpackage: env_pkg

`endif

