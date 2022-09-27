/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 16:05:08
 * @FilePath: /Anfield/Balotelli/Pipeline/Mem2Wb.v
 * @Description: 流水缓冲级。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module Mem2Wb (
  input Clk,
  input Rst,
  //前面传进来的
  input [`DataBus] RdWriteDataIn,
  input [`RegFileAddr] RdAddrIn,
  input RdWriteEnableIn,
  input [`HoldFlagBus] HoldFlagFromCtrl,
  //传给后面案的
  output reg [`DataBus] RdWriteDataOut,
  output reg [`RegFileAddr] RdAddrOut,
  output reg RdWriteEnableOut,
  input [`InstAddrBus] InstAddrIn,
  output [`InstAddrBus] InstAddrOut,
  input [`DataBus] ExcInfoIn,
  output [`DataBus] ExcInfoOut,
  input [`DataBus] CsrWriteDataIn,
  input [11:0] CsrWriteAddrIn,
  input CsrWriteEnableIn,
  output [`DataBus] CsrWriteDataOut,
  output [11:0] CsrWriteAddrOut,
  output CsrWriteEnableOut
);

  RegClintClear #(`DataWidth, `DataRegInit) RdWriteData_Reg (Clk, Rst, RdWriteDataIn, HoldFlagFromCtrl, RdWriteDataOut, 1'b1);

  RegClintClear #(`RegFileAddrWidth, `RegAddrInit) RdAddr_Reg (Clk, Rst, RdAddrIn, HoldFlagFromCtrl, RdAddrOut, 1'b1);

  RegClintClear #(1, 1'b0) RdWriteEnable_Reg (Clk, Rst, RdWriteEnableIn, HoldFlagFromCtrl, RdWriteEnableOut, 1'b1);

  RegClintClear #(`InstRegWidth, `PcInit) InstAddr_Reg (Clk, Rst, InstAddrIn, HoldFlagFromCtrl, InstAddrOut, 1'b1);

  RegClintClear #(`DataWidth, `DataRegInit) ExcInfo_Reg (Clk, Rst, ExcInfoIn, HoldFlagFromCtrl, ExcInfoOut, 1'b1);

  /*
    ExcInfor_IfStep  ||   1bit   ||   1bit   ||   1bit   ||   6bit   ||   7bit   ||
    Using Form             Exc         Int         Ret      IntKinds     ExcCode
    中断信息仅在If阶段ExcInfo中存在
  */
  RegClintClear #(`DataWidth, `DataRegInit) CsrWriteData (Clk, Rst, CsrWriteDataIn, HoldFlagFromCtrl, CsrWriteDataOut, 1'b1);

  RegClintClear #(12, 12'b0) CsrWriteAddr (Clk, Rst, CsrWriteAddrIn, HoldFlagFromCtrl, CsrWriteAddrOut, 1'b1);

  RegClintClear #(1, 1'b0) CsrWriteEnable (Clk, Rst, CsrWriteEnableIn, HoldFlagFromCtrl, CsrWriteEnableOut, 1'b1);
endmodule