/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 16:11:37
 * @FilePath: /Anfield/Balotelli/Controler/Ctrl.v
 * @Description: 流水级控制模块，设计最差的地方，后期会进行修改。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


`include "./vsrc/defines.v"
module Ctrl (
  input Clk,
  input Rst,
  input HoldFlagFromEx,
  input [1:0] RVM_HoldFlagFromEx,
  input MulHoldEndToEx,
  input DivHoldEndToEx,
  input [`AddrBus] JumpAddrFromEx,
  input JumpFlagFromEx,

  output [`AddrBus] JumpAddrToPc,
  output [`HoldFlagBus] HoldFlagOut,
  //INT
  input HoldFlagFromClint,
  input HoldFlagEndFromClint,
  input [`InstAddrBus] JumpAddrFromClint,

  input BusRequest,
  input BusUsedEnd,
  input DataReadReady,
  input DataWriteOver
);

  assign JumpAddrToPc = HoldFlagEndFromClint ? JumpAddrFromClint : JumpAddrFromEx;
  
  reg MulHoldFlag;
  reg DivHoldFlag;
  reg ClintHolgFlag;
  reg BusUsedHoldFlag;
  reg MemHoldFlag;

  always @(posedge Clk) begin
    if(!Rst) begin
      MemHoldFlag <= 1'b0;
    end else if(HoldFlagFromEx) begin
      MemHoldFlag <= 1'b1;
    end else if(DataReadReady | DataWriteOver) begin
      MemHoldFlag <= 1'b0;
    end
  end

  always @(posedge Clk) begin
    if(!Rst) begin
      BusUsedHoldFlag <= 1'b0;
    end else if(BusUsedEnd) begin
      BusUsedHoldFlag <= 1'b0;
    end else if(BusRequest) begin
      BusUsedHoldFlag <= 1'b1;
    end 
  end

  always @ (posedge Clk) begin
    if(!Rst) begin
      ClintHolgFlag <= 1'b0;
    end else if(HoldFlagFromClint) begin
      ClintHolgFlag <= 1'b1;
    end else if(HoldFlagEndFromClint) begin
      ClintHolgFlag <= 1'b0;
    end
  end

  always @ (posedge Clk) begin
    if(!Rst) begin
      MulHoldFlag <= 1'b0;
    end else if(RVM_HoldFlagFromEx == 2'b01) begin
      MulHoldFlag <= 1'b1;
    end else if(MulHoldEndToEx) begin
      MulHoldFlag <= 1'b0;
    end
  end

  always @ (posedge Clk) begin
    if(!Rst) begin
      DivHoldFlag <= 1'b0;
    end else if(RVM_HoldFlagFromEx == 2'b10) begin
      DivHoldFlag <= 1'b1;
    end else if(DivHoldEndToEx) begin
      DivHoldFlag <= 1'b0;
    end
  end

  wire MulHoldUp = MulHoldFlag | RVM_HoldFlagFromEx == 2'b01;
  wire DivHoldUp = DivHoldFlag | RVM_HoldFlagFromEx == 2'b10;
  wire BusUsedHoldFlagUp = BusRequest | BusUsedHoldFlag && (~BusUsedEnd);
  wire MemHoldUp = HoldFlagFromEx | MemHoldFlag;

  //HoldFlag can be externed to 3 bit
  assign HoldFlagOut = ClintHolgFlag | HoldFlagFromClint ? 3'b011     //Clint带来的流水线暂停
                      : MemHoldUp ? 3'b010    //流水线暂停
                      : MulHoldUp | DivHoldUp ? 3'b100    //乘法器带来的流水线暂停
                      : JumpFlagFromEx ? 3'b001     //流水线清洗
                      : BusUsedHoldFlagUp ? 3'b111
                      : 3'b000;

endmodule
