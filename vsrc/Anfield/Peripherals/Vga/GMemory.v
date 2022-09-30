/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-27 10:46:32
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-29 20:52:56
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Peripherals/Vga/GMemory.v
 * @Description: 本模块为NJU数字电路实验中的实验八，模块已经过验证，但集成到Soc后因未编写Stdio库，所以暂未进行集成后验证。（未来会进行验证。。。）
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module GMemory(
	input Clk,
	input Rst,
	input [18:0] WriteAddr,
	input [23:0] WriteData,
	input WriteEnable,
	output reg WriteOk,
	output [23:0] vga_data,
	input [9:0] h_addr,
	input [8:0] v_addr
);

reg [23:0] vga_mem [524287:0];

always @(posedge Clk) begin
  if(WriteEnable) begin
	vga_mem[WriteAddr] <= WriteData;
	WriteOk <= 1'b1;
  end else begin
	WriteOk <= 1'b0;
  end
end

assign vga_data = vga_mem[{h_addr, v_addr}];

endmodule
