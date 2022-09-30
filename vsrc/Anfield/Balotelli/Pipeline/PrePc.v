/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 17:53:27
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/Pipeline/PrePc.v
 * @Description: 该级为伪Pc级，对Bus的请求及地址从该级发出，取出的数据交给Ifu中的Cache，该级对Bus采取阻塞式读取，当Pc寻找Cache发生Missing时，进行地址跳转（跳转对跳转地址缓冲，从而实现对Bus阻塞读取）。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
//为了提高总线传输速率，设置伪Pc寄存器，该模块提供的Pc与流水线中的Pc并无完全对应关系，由Ifu模块进行指令-Pc的对应
module PrePc (
  input Clk,
  input Rst,
  //输出给If2Id模块的信号
  input [`InstAddrBus] PcIn,
  input CacheMissing,
  input CacheFull,
  input ReadShakeHands,
  output reg FetchReady,
  output reg [`InstAddrBus] PrePcOut
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
  
  reg BusUsedHoldFlag;
  always @(posedge Clk) begin
    if(!Rst) begin
      BusUsedHoldFlag <= 1'b0;
    end else if(FetchReady) begin
      BusUsedHoldFlag <= 1'b1;
    end else if(ReadShakeHands) begin
      BusUsedHoldFlag <= 1'b0;
    end
  end

  wire WFull;
  wire REmpty;
  wire [`InstAddrBus] PcInChange;

  OneDeepthFIFO JumpAddrBuffer (
    .Clk(Clk),
    .Rst(Rst),
    .WData(PcIn),
    .WInc(CacheMissing),
    .WFull(),
    .RData(PcInChange),
    .RInc(ReadShakeHands && !REmpty),
    .REmpty(REmpty),
    .JumpFlag()
  );

  always @(posedge Clk) begin
    if(!Rst) begin
      PrePcOut <= `PcInit;
      FetchReady <= 1'b1;
    end else if(CacheFull) begin
      PrePcOut <= PrePcOut;
      FetchReady <= 1'b0;
    end else if(!REmpty) begin
      if(BusUsedHoldFlag | FetchReady & ~ReadShakeHands) begin
        PrePcOut <= PrePcOut;
        FetchReady <= 1'b0;
      end else begin
        PrePcOut <= PcInChange;
        FetchReady <= 1'b1;
      end
    end else begin
      if(BusUsedHoldFlag | FetchReady & ~ReadShakeHands) begin
        PrePcOut <= PrePcOut;
        FetchReady <= 1'b0;
      end else begin
        PrePcOut <= PrePcOut + 4;
        FetchReady <= 1'b1;
      end
    end
  end

endmodule
