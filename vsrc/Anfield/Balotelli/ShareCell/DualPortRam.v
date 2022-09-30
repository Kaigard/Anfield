/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-29 10:28:31
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/ShareCell/DualPortRam.v
 * @Description: 双口Ram行为级模型。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module DualPortRam
#(
  parameter DataWidth = 64,
  parameter Deepth = 1,
  parameter Ground = 0
)
(
  input WClk,
  input [DataWidth - 1 : 0] WData,
  input [((Deepth == 1) ? Deepth : $clog2(Deepth) - 1) : 0] WAddr,
  input WEnc,
  input RClk,
  output reg [DataWidth - 1 : 0] RData,
  input [((Deepth == 1) ? Deepth : $clog2(Deepth) - 1) : 0] RAddr,
  input REnc
);

  reg [DataWidth - 1 : 0] RamMem [Deepth : Ground];

  // write
  always @(posedge WClk) begin
    if(WEnc) begin
      /* verilator lint_off WIDTH */
      RamMem[WAddr] <= WData;
	  end
  end

  // read
  always @(posedge RClk) begin
    if(REnc) begin
      /* verilator lint_off WIDTH */
	    RData <= RamMem[RAddr];
    end
  end
  // assign RData = RamMem[RAddr];

endmodule