/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-28 17:27:41
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 19:48:05
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/Cache/DCache.v
 * @Description: 
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module DCache (
  input Clk,
  input Rst,
  input [`AddrBus] RaddrIn,
  input [`AddrBus] WaddrIn,
  input [`DataBus] MemDataIn,
  input [3:0] WriteMaskIn,
  output [`DataBus] MemDataOut
);
  //loading...


endmodule