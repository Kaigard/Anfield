/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 10:03:01
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/Pipeline/If2Id.v
 * @Description: 流水缓冲级，从预取值来的指令及地址通过该级传入后级，当发生流水暂停时该级将锁住数据，当发生跳转时该级将引入气泡冲刷流水线。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module If2Id (
  input Clk,
  input Rst,
  //从Pc模块传入的信号
  input [`AddrBus] InstAddrIn,
  //未实现RAM阶段，使用软件虚拟化RAM，此端口为软件输入Inst的接口，从top层引出
  input [`InstBus] InstIn,
  //从Ctrl模块输入的信号，用来控制流水线暂停和清洗
  input [`HoldFlagBus] HoldFlagFromCtrl,
  //输出到Id模块的信号
  output [`AddrBus] InstAddrOut,
  output [`InstBus] InstOut,
  output [`DataBus] ExcInfoOut
);

  wire [`DataBus] ExcInfo;
  /*
    ExcInfor_IfStep  ||   1bit   ||   1bit   ||   1bit   ||   6bit   ||   7bit   ||
    Using Form             Exc         Int         Ret      IntKinds     ExcCode 
  */
  //目前仅支持指令地址错误例外，及时钟中断
  assign ExcInfo[62:55] = 8'h00;
  assign ExcInfo[54:0] = 55'h0000_0000_0000_00;
  assign ExcInfo[63] = (InstAddrIn[1:0] != 2'b00) ? 1'b1 : 1'b0;

  // //此级流水使用带使能的寄存器，且在流水线暂停时有效时对信号进行保持，从而使得下一级流水线可以直接清洗，而不需保存数据
  RegWithEnHoldData #(`AddrRegWidth, `PcInit) InstAddr_reg (Clk, Rst, InstAddrIn, HoldFlagFromCtrl, InstAddrOut, 1'b1);

  RegWithEnHoldData #(`InstRegWidth, `InstRegInit) Inst_reg (Clk, Rst, InstIn, HoldFlagFromCtrl, InstOut, 1'b1);

  RegWithEnHoldData #(`DataWidth, `DataRegInit) ExcInfo_reg (Clk, Rst, ExcInfo, HoldFlagFromCtrl, ExcInfoOut, 1'b1);
  // assign InstAddrOut = InstAddrIn;
  // assign InstOut = InstIn;
  // assign ExcInfoOut = ExcInfo;

endmodule