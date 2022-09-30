/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 10:02:51
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/Pipeline/Ex2Mem.v
 * @Description: 流水阻塞级，进行流水线控制解耦，跳转及暂停均不会对该级造成影响，便于五级流水与三级流水之间进行更改。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */
 
`include "./vsrc/defines.v"
module Ex2Mem (
  input Clk,
  input Rst,
  //从Ex模块输入的信号
  input [`DataBus] RdWriteDataIn,
  input [`RegFileAddr] RdAddrIn,
  input RdWriteEnableIn,
  input [`DataBus] ImmIn,
  input [6:0] OpCodeIn,
  input [2:0] Funct3In,
  input [`DataBus] Rs1ReadDataIn,
  input [`DataBus] Rs2ReadDataIn,
  input [`HoldFlagBus] HoldFlagFromCtrl,
  //输出给mem模块的信号
  output [`DataBus] RdWriteDataOut,
  output [`RegFileAddr] RdAddrOut,
  output RdWriteEnableOut,
  output [`DataBus] ImmOut,
  output [6:0] OpCodeOut,
  output [2:0] Funct3Out,
  output [`DataBus] Rs1ReadDataOut,
  output [`DataBus] Rs2ReadDataOut,
  /**********************INT*******************/
  input [`InstAddrBus] InstAddrIn,
  input [`DataBus] ExcInfoIn,
  input [`DataBus] CsrWriteDataIn,
  input [11:0] CsrWriteAddrIn,
  input CsrWriteEnableIn,
  output [`InstAddrBus] InstAddrOut,
  output [`DataBus] ExcInfoOut,
  output [`DataBus] CsrWriteDataOut,
  output [11:0] CsrWriteAddrOut,
  output CsrWriteEnableOut
);
  //此级流水使用普通不带使能的寄存器即可，将后续流水控制与前面解耦，从而在需要更改为三级流水时更加方便
  RegClintClear #(`DataWidth, `DataRegInit) RdWriteData_Reg (Clk, Rst, RdWriteDataIn, HoldFlagFromCtrl, RdWriteDataOut, 1'b1);

  RegClintClear #(`RegFileAddrWidth, `RegAddrInit) RdAddr_Reg (Clk, Rst, RdAddrIn, HoldFlagFromCtrl, RdAddrOut, 1'b1);

  RegClintClear #(1, 1'b0) RdWriteEnable_Reg (Clk, Rst, RdWriteEnableIn, HoldFlagFromCtrl, RdWriteEnableOut, 1'b1);

  RegClintClear #(`DataWidth, `DataRegInit) Imm_Reg (Clk, Rst, ImmIn, HoldFlagFromCtrl, ImmOut, 1'b1);

  RegClintClear #(7, 7'b0) OpCode_Reg (Clk, Rst, OpCodeIn, HoldFlagFromCtrl, OpCodeOut, 1'b1);

  RegClintClear #(3, 3'b0) Funct3_Reg (Clk, Rst, Funct3In, HoldFlagFromCtrl, Funct3Out, 1'b1);

  RegClintClear #(`DataWidth, `DataRegInit) Rs1ReadData_Reg (Clk, Rst, Rs1ReadDataIn, HoldFlagFromCtrl, Rs1ReadDataOut, 1'b1);

  RegClintClear #(`DataWidth, `DataRegInit) Rs2ReadData_Reg (Clk, Rst, Rs2ReadDataIn, HoldFlagFromCtrl, Rs2ReadDataOut, 1'b1);

  /**********************INT*******************/
  RegClintClear #(`InstRegWidth, `PcInit) InstAddr_Reg (Clk, Rst, InstAddrIn, HoldFlagFromCtrl, InstAddrOut, 1'b1);

  RegClintClear #(`DataWidth, `DataRegInit) ExcInfo_Reg (Clk, Rst, ExcInfoIn, HoldFlagFromCtrl, ExcInfoOut, 1'b1);

  RegClintClear #(`DataWidth, `DataRegInit) CsrWriteData (Clk, Rst, CsrWriteDataIn, HoldFlagFromCtrl, CsrWriteDataOut, 1'b1);

  RegClintClear #(12, 12'b0) CsrWriteAddr (Clk, Rst, CsrWriteAddrIn, HoldFlagFromCtrl, CsrWriteAddrOut, 1'b1);

  RegClintClear #(1, 1'b0) CsrWriteEnable (Clk, Rst, CsrWriteEnableIn, HoldFlagFromCtrl, CsrWriteEnableOut, 1'b1);
endmodule