/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 19:56:20
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/Cache/ICache.v
 * @Description: I-Cache，采用直接映射阻塞式Cache。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module ICache (
  input Clk,
  input Rst,
  input [`InstAddrBus] PrePcIn,
  input ReadShakeHands,
  input [`InstBus] InstIn,
  input [`InstAddrBus] PcIn,
  output [`InstBus] InstOut,
  output CacheFull,
  output CacheMissing
);

  reg [`DataBus] CacheLine [7 : 0];
  reg [59 : 0] TagLine [7 : 0];                     //TagLine[58] 为Vaild位用来判断是否可替换，
  wire [2 : 0] WriteCacheLineNumber = PrePcIn[4 : 2];
  wire [2 : 0] ReadCacheLineNumber = PcIn[4 : 2];
  wire [59 : 0] TagOneLine = TagLine[ReadCacheLineNumber];

  always @(posedge Clk) begin
    if(!Rst) begin
      CacheLine[0] <= `RegZero;
      CacheLine[1] <= `RegZero;
      CacheLine[2] <= `RegZero;
      CacheLine[3] <= `RegZero;
      CacheLine[4] <= `RegZero;
      CacheLine[5] <= `RegZero;
      CacheLine[6] <= `RegZero;
      CacheLine[7] <= `RegZero;
      TagLine[0] <= 60'h0;
      TagLine[1] <= 60'h0;
      TagLine[2] <= 60'h0;
      TagLine[3] <= 60'h0;
      TagLine[4] <= 60'h0;
      TagLine[5] <= 60'h0;
      TagLine[6] <= 60'h0;
      TagLine[7] <= 60'h0;
      // for (integer i = 0; i < 8; i = i + 1) begin
      //   CacheLine[i] <= `RegZero;
      //   TagLine[i] <= 60'h0;
      // end
    end else begin
      if(ReadShakeHands) begin
        CacheLine[WriteCacheLineNumber] <= InstIn;
        TagLine[WriteCacheLineNumber] <= {1'b1, PrePcIn[63 : 5]};
      end else if(CacheMissing) begin
        // for (integer i = 0; i < 8; i = i + 1) begin
        //   TagLine[i] <= 60'h0;
        // end
        TagLine[0] <= 60'h0;
        TagLine[1] <= 60'h0;
        TagLine[2] <= 60'h0;
        TagLine[3] <= 60'h0;
        TagLine[4] <= 60'h0;
        TagLine[5] <= 60'h0;
        TagLine[6] <= 60'h0;
        TagLine[7] <= 60'h0;
      end
    end
  end

  MuxKeyWithDefault #(1, 1, 64) InstOut_mux (InstOut, ((PcIn[63 : 5] == TagOneLine[58 : 0]) && TagOneLine[59]), `RegZero, {
    1'b1, CacheLine[ReadCacheLineNumber]
  });

  MuxKeyWithDefault #(1, 1, 1) CacheMissing_mux (CacheMissing, ((PcIn[63 : 5] == TagOneLine[58 : 0]) && TagOneLine[59]), 1'b0, {
    1'b0, 1'b1
  });

  // assign InstOut = ((PcIn[63 : 5] == TagOneLine[58 : 0]) && TagOneLine[59]) ? CacheLine[ReadCacheLineNumber] : `RegZero;
  // assign CacheMissing = ~((PcIn[63 : 5] == TagOneLine[58 : 0]) && TagOneLine[59]);

  wire [59 : 0] TagLine0 = TagLine[0];
  wire [59 : 0] TagLine1 = TagLine[1];
  wire [59 : 0] TagLine2 = TagLine[2];
  wire [59 : 0] TagLine3 = TagLine[3];
  wire [59 : 0] TagLine4 = TagLine[4];
  wire [59 : 0] TagLine5 = TagLine[5];
  wire [59 : 0] TagLine6 = TagLine[6];
  wire [59 : 0] TagLine7 = TagLine[7];
  
  wire TagValid0 = TagLine0[59];
  wire TagValid1 = TagLine1[59];
  wire TagValid2 = TagLine2[59];
  wire TagValid3 = TagLine3[59];
  wire TagValid4 = TagLine4[59];
  wire TagValid5 = TagLine5[59];
  wire TagValid6 = TagLine6[59];
  wire TagValid7 = TagLine7[59];

  MuxKeyWithDefault #(1, 1, 1) CacheFull_mux (CacheFull, (TagValid0 && TagValid1 && TagValid2 && TagValid3 && 
                                                                TagValid4 && TagValid5 && TagValid6 && TagValid7), 1'b0, {
    1'b1, 1'b1
  });

  // assign CacheFull = (TagValid0 && TagValid1 && TagValid2 && TagValid3 && 
  //                     TagValid4 && TagValid5 && TagValid6 && TagValid7);


endmodule