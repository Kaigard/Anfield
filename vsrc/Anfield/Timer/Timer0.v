/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:36:29
 * @FilePath: /Anfield/Timer/Timer0.v
 * @Description: 乞丐版定时器，未来会将已有的几个低性能定时器进行集成，目前Timer0共有四个寄存器，分别为：ARR（计数上限）、SR（中断标志位）、CR1（定时器使能标志位）、CNT（计数寄存器）。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module Timer0 (
  // Global
  input ACLK,
  input ARESETn,
  // From BusMatrix
  input [`DataBus] WriteAddr,
  input [`DataBus] WriteData,
  input [3:0] WriteStrb,
  // To BusMatrix
  output reg SlaverWriteReady,
  // To Core
  output reg Timer0Init
);
  
  reg [`DataBus] Timer0_ARR;
  reg [`DataBus] Timer0_SR;
  reg [`DataBus] Timer0_CR1;
  reg [`DataBus] Timer0_CNT;

  always @(posedge ACLK) begin
    if(!ARESETn) begin
      Timer0_CR1 <= `RegZero;
      Timer0_ARR <= `RegZero;
      Timer0_SR <= `RegZero;
    end else begin
      case (WriteAddr)
        64'h5000_0000 : begin
          Timer0_CR1 <= WriteData;
          SlaverWriteReady <= 1'b1;
        end
        64'h5000_0004 : begin
          Timer0_ARR <= WriteData;
          SlaverWriteReady <= 1'b1;
        end
        64'h5000_0008 : begin
          Timer0_SR <= WriteData;
          SlaverWriteReady <= 1'b1;
        end
        default : begin
          SlaverWriteReady <= 1'b0;
        end
      endcase
    end
  end

  always @(posedge ACLK) begin
    if(!ARESETn) begin
      Timer0_CNT <= `RegZero;
      Timer0Init <= 1'b0;
    end else begin
      if(Timer0_CNT == Timer0_ARR) begin
        Timer0_CNT <= `RegZero;
        Timer0Init <= Timer0_SR[0];
      end else begin
        if(Timer0_CR1[0]) begin
          Timer0_CNT <= Timer0_CNT + 1;
          Timer0Init <= 1'b0;
        end else begin
          Timer0_CNT <= Timer0_CNT;
          Timer0Init <= 1'b0;
        end
      end
    end
  end

endmodule