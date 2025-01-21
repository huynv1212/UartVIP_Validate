module uart_dut( rx_lhs,  
                  tx_lhs,  
                  rx_rhs,  
                  tx_rhs);  

output wire rx_lhs;  
output wire tx_rhs;  
input wire rx_rhs;  

/**  
 * Pass-through assignment  
 */  
assign tx_lhs = rx_lhs;  
assign tx_rhs = rx_rhs;  

endmodule