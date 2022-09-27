/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:18:26
 * @FilePath: /Anfield/Balotelli/Mul/AddPP_FinL.v
 * @Description: 
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


`include "./vsrc/defines.v"
module AddPP_FinL(
  input Clk,
  input Rst,
  input [1:0] MulHoldFlagFromEx,
  input [`DataWidth_CSA50 - 1 : 0] SumPP_CSA50,
  input [`DataWidth_CSA50 - 1 : 0] CarryPP_CSA50,
  output reg [(`DataWidth * 2) - 1 : 0] Sum,
  output reg MulHoldEndToEx
);

  wire [(`DataWidth * 2) - 1 : 0] SumInside;
  //Finally
  CLA_128Bit_Adder_CLK CLA(Clk, Rst, Sum, SumPP_CSA50, CarryPP_CSA50);
  
  always @ (posedge Clk) begin
    if(!Rst) begin
      MulHoldEndToEx <= 1'b0;
    end else if(MulHoldFlagFromEx == 2'b01) begin
      MulHoldEndToEx <= 1'b1;
    end else begin
      MulHoldEndToEx <= 1'b0;
    end
  end
  
endmodule
