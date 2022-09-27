/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 16:04:36
 * @FilePath: /Anfield/Balotelli/Pipeline/Ifu.v
 * @Description: 取值级，该级内含一个64 Byte的阻塞式直接映射I-Cache，从预取指级及总线送来的地址及指令将会存储到Cache中，当Cache存储满时，按Pc给出的地址读取指令。
 *               Balotelli_GOAL信号确定了何时将指令与地址发出，防止一条指令多次进入流水线中。
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module Ifu (
  input Clk,
  input Rst,
  // From PrePc module
  input [`InstAddrBus] PrePcIn,
  input [`InstBus] InstIn,
  input ReadShakeHands,
  // From Pc module
  input [`InstAddrBus] PcIn,
  input [`HoldFlagBus] HoldFlagFromCtrl,
  // To PrePc module
  output CacheFull,
  output CacheMissing,
  // To If2Id module
  output [`InstBus] InstOut,
  output [`InstAddrBus] InstAddrOut
);

  wire Balotelli_GOAL;
  wire [`InstBus] InstInside;

  ICache Balotelli_ICache (
    .Clk(Clk),
    .Rst(Rst),
    .PrePcIn(PrePcIn),
    .ReadShakeHands(ReadShakeHands),
    .InstIn(InstIn),
    .PcIn(PcIn),
    // .CpuHoldIn(HoldFlagFromCtrl == 3'b010 | HoldFlagFromCtrl == 3'b100),
    .InstOut(InstInside),
    .CacheFull(CacheFull),
    .CacheMissing(CacheMissing)
  );

  assign Balotelli_GOAL = CacheFull && ~(HoldFlagFromCtrl == 3'b010 | HoldFlagFromCtrl == 3'b100) && ~CacheMissing;
  assign InstOut = Balotelli_GOAL ? InstInside : `RegZero;
  assign InstAddrOut = Balotelli_GOAL ? PcIn : `PcInit;

endmodule