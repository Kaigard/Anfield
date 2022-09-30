/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 10:35:54
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/ShareCell/SycnFIFO.v
 * @Description: 同步FIFO
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module SyncFIFO
#(
  parameter DataWidth = 64,
  parameter Deepth = 16
)
(
  input Clk,
  input Rst,
  input [DataWidth - 1 : 0] WData,
  input WInc,
  output WFull,
  output reg [DataWidth - 1 : 0] RData,
  input RInc,
  output REmpty
);
  
  localparam DeepthBit = $clog2(Deepth);
  
  reg [DeepthBit : 0] WritePoint;
  reg [DeepthBit : 0] ReadPoint;
  
  //empty or full
  assign WFull = ((WritePoint[DeepthBit] != ReadPoint[DeepthBit]) && (WritePoint[DeepthBit - 1 : 0] == ReadPoint[DeepthBit - 1 : 0]));
  assign REmpty = (WritePoint == ReadPoint); 
  
  //write logic
  always @(posedge Clk) begin
    if(!Rst) begin
      WritePoint <= 'h0;
    end else begin
      if(WInc && ~WFull) begin
        WritePoint <= WritePoint + 1;
      end
    end
  end  

  //read logic
  always @(posedge Clk) begin
    if(!Rst) begin
      ReadPoint <= 'h0;
    end else begin
      if(RInc && ~REmpty) begin
        ReadPoint <= ReadPoint + 1;
      end
    end
  end

  DualPortRam
  #(
    .DataWidth(DataWidth),
    .Deepth(Deepth)
  ) 
  u_DualPortRam
  (
    .WClk(Clk),
    .WData(WData),
    .WAddr(WritePoint[DeepthBit - 1 : 0]),
    .WEnc(WInc),
    .RClk(Clk),
    .RData(RData),
    .RAddr(ReadPoint[DeepthBit - 1 : 0]),
    .REnc(RInc)
  );

endmodule