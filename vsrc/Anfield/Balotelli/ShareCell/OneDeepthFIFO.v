/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 10:43:49
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/ShareCell/OneDeepthFIFO.v
 * @Description: 1深度同步FIFO，用来进行数据缓冲。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


module OneDeepthFIFO
#(
  parameter DataWidth = 64,
  parameter Deepth = 1
)
(
  input Clk,
  input Rst,
  input [DataWidth - 1 : 0] WData,
  input WInc,
  output WFull,
  output [DataWidth - 1 : 0] RData,
  input RInc,
  output REmpty,
  input JumpFlag
);
  
  reg [DataWidth : 0] OneDeepthMem;
  always @(posedge Clk) begin
    if(!Rst) begin
      OneDeepthMem <= 'h0;
    end else begin
      case ({WInc, RInc})
        2'b01 : begin
          OneDeepthMem[DataWidth] <= 1'b0;
          OneDeepthMem[DataWidth - 1 : 0] <= OneDeepthMem[DataWidth - 1 : 0];
        end
        2'b10 : begin
          OneDeepthMem[DataWidth] <= 1'b1;
          OneDeepthMem[DataWidth - 1 : 0] <= WData;
        end
        default : begin

        end
      endcase
    end
  end

  assign RData = OneDeepthMem[DataWidth - 1 : 0];
  assign WFull = OneDeepthMem[DataWidth];
  assign REmpty = !OneDeepthMem[DataWidth];

endmodule