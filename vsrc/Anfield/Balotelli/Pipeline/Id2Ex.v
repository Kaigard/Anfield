/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:58:43
 * @FilePath: /Anfield/Balotelli/Pipeline/Id2Ex.v
 * @Description: 流水缓冲级，当发生跳转或流水暂停时，该级将对其后流水级塞入气泡。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module Id2Ex (
  input Clk,
  input Rst,
  //从Id模块输入的信号
  input [`AddrBus] InstAddrIn,
  input [`RegFileAddr] RdAddrIn,
  input RdWriteEnableIn,
  input [`DataBus] Rs1ReadDataIn,
  input [`DataBus] Rs2ReadDataIn,
  // input [`RegFileAddr] Rs1AddrIn,
  // input [`RegFileAddr] Rs2AddrIn,
  input [`DataBus] ImmIn,
  input [6:0] OpCodeIn,
  input [2:0] Funct3In,
  input [6:0] Funct7In,
  input [5:0] ShamtIn,
  //从Ctrl模块输入的信号，用来控制流水线暂停和清洗
  input [`HoldFlagBus] HoldFlagFromCtrl,
  //输出给Ex模块的信号
  output [`AddrBus] InstAddrOut,
  output [`RegFileAddr] RdAddrOut,
  output RdWriteEnableOut,
  output [`DataBus] Rs1ReadDataOut,
  output [`DataBus] Rs2ReadDataOut,
  // output [`RegFileAddr] Rs1AddrOut,
  // output [`RegFileAddr] Rs2AddrOut,
  output [`DataBus] ImmOut,
  output [6:0] OpCodeOut,
  output [2:0] Funct3Out,
  output [6:0] Funct7Out,
  output [5:0] ShamtOut
);

  //此级流水采用带使能的寄存器，且在使能有效时对数据进行清洗，以防止在Ex阶段对统一指令多次执行。
  RegWithEnClearData #(`InstRegWidth, `PcInit) InstAddr_reg (Clk, Rst, InstAddrIn, HoldFlagFromCtrl, InstAddrOut, 1'b1);
  
  // RegWithEn #(`RegFileAddrWidth, `RegAddrInit) Rs1Addr_reg (Clk, Rst, Rs1AddrIn, HoldFlagFromCtrl, Rs1AddrOut, 1'b1);

  // RegWithEn #(`RegFileAddrWidth, `RegAddrInit) Rs2Addr_reg (Clk, Rst, Rs2AddrIn, HoldFlagFromCtrl, Rs2AddrOut, 1'b1);

  RegWithEnClearData #(`RegFileAddrWidth, `RegAddrInit) RdAddr_reg (Clk, Rst, RdAddrIn, HoldFlagFromCtrl, RdAddrOut, 1'b1);

  RegWithEnClearData #(1, 1'b0) RdWriteEnable_reg (Clk, Rst, RdWriteEnableIn, HoldFlagFromCtrl, RdWriteEnableOut, 1'b1);

  RegWithEnClearData #(`DataWidth, `DataRegInit) Rs1ReadData_reg (Clk, Rst, Rs1ReadDataIn, HoldFlagFromCtrl, Rs1ReadDataOut, 1'b1);

  RegWithEnClearData #(`DataWidth, `DataRegInit) Rs2ReadData_reg (Clk, Rst, Rs2ReadDataIn, HoldFlagFromCtrl, Rs2ReadDataOut, 1'b1);

  RegWithEnClearData #(`DataWidth, `DataRegInit) Imm_reg (Clk, Rst, ImmIn, HoldFlagFromCtrl, ImmOut, 1'b1);
 
  RegWithEnClearData #(7, 7'b0) OpCode_reg (Clk, Rst, OpCodeIn, HoldFlagFromCtrl, OpCodeOut, 1'b1);

  RegWithEnClearData #(3, 3'b0) Funct3_reg (Clk, Rst, Funct3In, HoldFlagFromCtrl, Funct3Out, 1'b1);

  RegWithEnClearData #(7, 7'b0) Funct7_reg (Clk, Rst, Funct7In, HoldFlagFromCtrl, Funct7Out, 1'b1);
  
  RegWithEnClearData #(6, 6'b0) Shamt_reg (Clk, Rst, ShamtIn, HoldFlagFromCtrl, ShamtOut, 1'b1);

endmodule