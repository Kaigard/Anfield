/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-27 10:46:32
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:37:51
 * @FilePath: /Anfield/Vga/Vga.v
 * @Description: 本模块为NJU数字电路实验中的实验八，模块已经过验证，但集成到Soc后因未编写Stdio库，所以暂未进行集成后验证。（未来会进行验证。。。）
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


module Vga (
  input clk,
  input clrn,
  input clken,
  input [`AddrBus] WriteAddrIn,
  input [`DataBus] WriteDataIn,
  input [3:0] WriteStrb,
  output SlaverWriteReady,
  output [7:0] vga_r,
  output [7:0] vga_g,
  output [7:0] vga_b,
  output hsync,
  output vsync,
  output valid
);

wire pclk;
wire [23:0] vga_data;
wire [9:0] h_addr;
wire [9:0] v_addr;

clkgen clk_25M(
	.clkin(clk),
	.rst(clrn),
	.clken(clken),
	.clkout(pclk)
);

vga_ctrl out(
	.pclk(clk),
	.reset(clrn),
	.vga_data(vga_data),
	.h_addr(h_addr),
	.v_addr(v_addr),
	.hsync(hsync),
	.vsync(vsync),
	.valid(valid),
	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_b(vga_b)
);

pic pic_test(
  .Clk(clk),
  .Rst(clrn),
  .WriteAddr(WriteAddrIn[18:0]),
  .WriteData(WriteDataIn[23:0]),
  .WriteEnable(WriteAddrIn[31:28] == 4'h5),
  .WriteOk(SlaverWriteReady),
  .vga_data(vga_data),
  .h_addr(h_addr),
  .v_addr(v_addr[8:0])
);
endmodule
