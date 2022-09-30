/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 10:03:19
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/Pipeline/Pc.v
 * @Description: Pc寄存器，当前流水级需要的指令地址，当Cache Full时工作（阻塞式Cache）。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module Pc (
  input Clk,
  input Rst,
  //从Ctrl输入的信号
  input [`AddrBus] JumpAddrFromCtrl,               //输入下一跳转地址
  input [`HoldFlagBus] HoldFlagFromCtrl,           //控制流水线暂停和清洗
  //输出给If2Id模块的信号
  input HoldFlagEndFromClint,
  input CacheMissing,
  input CacheFull,
  output reg [`AddrBus] PcOut
);

  /*
  //根据控制信号判断下一地址
  wire [`AddrBus] PcIn;
  assign PcIn = (HoldFlagFromCtrl == 3'b001) | ((HoldFlagFromCtrl == 3'b011) && HoldFlagEndFromClint) ? JumpAddrFromCtrl 
                : (((HoldFlagFromCtrl == 3'b010) | (HoldFlagFromCtrl == 3'b100) | (HoldFlagFromCtrl == 3'b111)) ? PcOut 
                : (PcOut + 4));

  //使用Reg模板实现Pc_reg，后续只需要更改Reg模块的输入输出即可
  Reg #(`AddrRegWidth, `PcInit) Pc_reg (Clk, Rst, PcIn, PcOut, 1'b1);
  */

  always @(posedge Clk) begin
    if(!Rst) begin
      PcOut <= `PcInit;
    end else if((HoldFlagFromCtrl == 3'b001) | ((HoldFlagFromCtrl == 3'b011) && HoldFlagEndFromClint)) begin
      PcOut <= JumpAddrFromCtrl;
    end else if(((HoldFlagFromCtrl == 3'b010) | (HoldFlagFromCtrl == 3'b100) | CacheMissing | !CacheFull)) begin
      PcOut <= PcOut;
    end else begin
      PcOut <= PcOut + 4;
    end
  end

endmodule
