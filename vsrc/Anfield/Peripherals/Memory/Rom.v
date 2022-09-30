/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-29 10:24:33
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Peripherals/Memory/Rom.v
 * @Description: 行为及Rom，读取预编译的指令文件。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module Rom (
  input Clk,
  input Rst,
  input [`AddrBus] ReadAddrIn,
  output reg [`DataBus] ReadDataOut,
  input ReadEnableIn,
  output reg RomReady
);

  reg [7:0] Balotelli_Ram [32'h0fff_ffff : 32'h0000_0000];
  initial begin
    $readmemh("code.mem", Balotelli_Ram);
  end
  /* verilator lint_off WIDTH */
  always @(posedge Clk) begin
    if(!Rst) begin
      ReadDataOut <= `RegZero;
      RomReady <= 1'b0;
    end else if(ReadEnableIn) begin
      ReadDataOut <= {Balotelli_Ram[ReadAddrIn], Balotelli_Ram[ReadAddrIn + 1], Balotelli_Ram[ReadAddrIn + 2], Balotelli_Ram[ReadAddrIn + 3]};
      RomReady <= 1'b1;
    end else begin
      RomReady <= 1'b0;
    end
  end

endmodule