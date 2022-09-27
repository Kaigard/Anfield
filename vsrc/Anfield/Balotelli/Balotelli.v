/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:50:46
 * @FilePath: /Anfield/Balotelli/Balotelli.v
 * @Description: Balotelli核，实现RISC-V 64IM指令集，已过部分CPU tests，中断部分尚未进行验证。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


`include "./vsrc/defines.v"
module Balotelli (
  input Clk,
  input Rst,
  // From Bus
  input [`InstBus] InstIn,
  input [`DataBus] MemDataIn,
  input InstReadReady,
  input [`AddrBus] InstAddrIn,
  input DataReadReady,
  input DataWriteOver,
  input ReadShakeHands,
  input Timer0IntIn,
  // To mem
  output [`AddrBus] InstAddrToBus,
  output [`AddrBus] RaddrOut,
  output [`AddrBus] WaddrOut,
  output [`DataBus] MemDataOut,
  output [3:0] Wmask,
  output BusRequest
); 

  // RegFile In
  wire [`DataBus] RdWriteData_RegFileIn;
  wire [`RegFileAddr] RdAddr_RegFileIn;
  wire RdWriteEnable_RegFileIn;
  // RegFile Out
  wire [`DataBus] Rs1ReadData_RegFileOut;
  wire [`DataBus] Rs2ReadData_RegFileOut;  
  
  // Id IN
  wire [`InstBus] Inst_IdIn;
  wire [`AddrBus] InstAddr_IdIn;
  // Id OUT
  wire [`RegFileAddr] Rs1Addr_IdOut;
  wire [`RegFileAddr] Rs2Addr_IdOut;
  wire [`AddrBus] InstAddr_IdOut;
  wire Rs1ReadEnable_IdOut;
  wire Rs2ReadEnable_IdOut;
  wire [`RegFileAddr] RdAddr_IdOut;
  wire RdWriteEnable_IdOut;
  wire [`DataBus] Rs1ReadData_IdOut;
  wire [`DataBus] Rs2ReadData_IdOut;
  wire [`DataBus] Imm_IdOut;
  wire [6:0] OpCode_IdOut;
  wire [2:0] Funct3_IdOut;
  wire [6:0] Funct7_IdOut;
  wire [5:0] Shamt_IdOut;

  // Ex In
  wire [`AddrBus] InstAddr_ExIn;
  wire [`RegFileAddr] RdAddr_ExIn;
  wire RdWriteEnable_ExIn;
  wire [`DataBus] Rs1ReadData_ExIn;
  wire [`DataBus] Rs2ReadData_ExIn;
  wire [`DataBus] Imm_ExIn;
  wire [6:0] OpCode_ExIn;
  wire [2:0] Funct3_ExIn;
  wire [6:0] Funct7_ExIn;
  wire [5:0] Shamt_ExIn;
  // Ex Out
  wire [`DataBus] RdWriteData_ExOut;
  wire [`RegFileAddr] RdAddr_ExOut;
  wire RdWriteEnable_ExOut;
  wire [`DataBus] Imm_ExOut;
  wire [6:0] OpCode_ExOut;
  wire [2:0] Funct3_ExOut;
  wire [`DataBus] Rs1ReadData_ExOut;
  wire [`DataBus] Rs2ReadData_ExOut;
  wire HoldFlag_ExOut;

  // Mem In
  wire [`DataBus] Imm_MemIn;
  wire [6:0] OpCode_MemIn;
  wire [2:0] Funct3_MemIn;
  wire [`DataBus] Rs1ReadData_MemIn;
  wire [`DataBus] Rs2ReadData_MemIn;
  wire [`DataBus] RdWriteData_MemIn;
  wire [`RegFileAddr] RdAddr_MemIn;
  wire RdWriteEnable_MemIn;
  // Mem Out
  wire [`DataBus] RdWriteData_MemOut;
  wire [`RegFileAddr] RdAddr_MemOut;
  wire RdWriteEnable_MemOut;

  // Fwu in
  wire [`DataBus] Rs1ReadData_FwuIn;
  wire [`DataBus] Rs2ReadData_FwuIn;
  wire [`RegFileAddr] Rs1Addr_FwuIn;
  wire [`RegFileAddr] Rs2Addr_FwuIn;
  wire Rs1ReadEnable_FwuIn;
  wire Rs2ReadEnable_FwuIn;
  // Fwu out
  wire [`DataBus] Rs1ReadData_FwuOut;
  wire [`DataBus] Rs2ReadData_FwuOut;

  // Jar
  wire [`AddrBus] JumpAddr_PcIn;
  wire JumpFlag_PcIn;
  wire [`AddrBus] JumpAddr_ExOut;
  wire JumpFlag_ExOut;
  wire [2:0] HoldFlag;

  // Ctrl
  wire MulHoldFlagToCtrl;
  wire MulHoldEndToEx;
  wire [`MulDataBus] Rs1ReadDataMulRs2ReadData;

  wire [`DataBus] ExcInfo_ExOut;
  wire [`DataBus] ExcInfo_IdIn;
  wire [`DataBus] ExcInfo_IdOut;
  wire [`DataBus] ExcInfo_ExIn;
  wire [`DataBus] ExcInfo_MemIn;
  wire [`DataBus] ExcInfo_MemOut;

  wire [`InstAddrBus] PcOut;
  wire [`InstAddrBus] InstAddrToIf2Id;
  wire [`InstBus] InstToIf2Id;
  wire BusUsedEnd;


  wire [`InstAddrBus] PrePcOut;
  wire [`InstAddrBus] PcOut;
  wire PcChange;
  wire CacheMissing;
  wire CacheFull;
 
  Pc Balotelli_Pc (
    .Clk(Clk),
    .Rst(Rst),
    //Jump
    .JumpAddrFromCtrl(JumpAddr_PcIn),
    .HoldFlagFromCtrl(HoldFlag),
    .PcOut(PcOut),
    .HoldFlagEndFromClint(HoldFlagEndFromClint),
    .CacheMissing(CacheMissing),
    .CacheFull(CacheFull)
  );

  PrePc Balotelli_PrePc (
    .Clk(Clk),
    .Rst(Rst),
    //Jump
    // .JumpAddrFromCtrl(JumpAddr_PcIn),
    // .HoldFlagFromCtrl(HoldFlag),
    .PcIn(PcOut),
    .PrePcOut(InstAddrToBus),
    .ReadShakeHands(ReadShakeHands),
    .FetchReady(BusRequest),
    .CacheMissing(CacheMissing),
    .CacheFull(CacheFull)
  );

  wire [`InstAddrBus] InstAddrToIf2Id;
  wire [`InstBus] InstToIf2Id;

  Ifu Balotelli_Ifu (
    .Clk(Clk),
    .Rst(Rst),
    .PrePcIn(InstAddrToBus),
    .InstIn(InstIn),
    .ReadShakeHands(ReadShakeHands),
    .PcIn(PcOut),
    .HoldFlagFromCtrl(HoldFlag),
    .CacheFull(CacheFull),
    .CacheMissing(CacheMissing),
    .InstOut(InstToIf2Id),
    .InstAddrOut(InstAddrToIf2Id)
  );

  If2Id Balotelli_If2Id (
    .Clk(Clk),
    .Rst(Rst),
    .InstAddrIn(InstAddrToIf2Id),
    .InstIn(InstToIf2Id),
    //Jump
    .HoldFlagFromCtrl(HoldFlag),
    .InstAddrOut(InstAddr_IdIn),
    .InstOut(Inst_IdIn),
    .ExcInfoOut(ExcInfo_IdIn)
  );
  
  wire [`RegFileAddr] Zimm_IdOut;
  wire CsrWriteEnable_IdOut;
  wire [`InstBus] Inst_IdOut;
  wire [`DataBus] CsrReadData_IdOut;
  wire MRetEnable_IdOut;
  Id Balotelli_Id (
    .InstAddrIn(InstAddr_IdIn),
    .InstIn(Inst_IdIn),
    .Rs1ReadDataIn(Rs1ReadData_RegFileOut),
    .Rs2ReadDataIn(Rs2ReadData_RegFileOut),
    .InstAddrOut(InstAddr_IdOut),
    .Rs1AddrOut(Rs1Addr_IdOut),
    .Rs1ReadEnable(Rs1ReadEnable_IdOut),
    .Rs2AddrOut(Rs2Addr_IdOut),
    .Rs2ReadEnable(Rs2ReadEnable_IdOut),
    .RdAddrOut(RdAddr_IdOut),
    .RdWriteEnable(RdWriteEnable_IdOut),
    .Rs1ReadDataOut(Rs1ReadData_IdOut),
    .Rs2ReadDataOut(Rs2ReadData_IdOut),
    .Imm(Imm_IdOut),
    .OpCode(OpCode_IdOut),
    .Funct3(Funct3_IdOut),
    .Funct7(Funct7_IdOut),
    .ShamtOut(Shamt_IdOut),

    .ExcInfoIn(ExcInfo_IdIn),
    .ExcInfoOut(ExcInfo_IdOut),
    .Zimm(Zimm_IdOut),
    .CsrWriteEnable(CsrWriteEnable_IdOut),
    .CsrReadDataIn(CsrReadData_IdIn),
    .CsrReadDataOut(CsrReadData_IdOut),
    .MRetEnableOut(MRetEnable_IdOut)
  );

  wire ExcStopRegfile;
  RegFile Balotelli_RegFile (
    .Clk(Clk),
    .Rst(Rst),
    .RdWriteData(RdWriteData_RegFileIn),
    .RdWriteAddr(RdAddr_RegFileIn),
    .RdWriteEnable(RdWriteEnable_RegFileIn),
    .Rs1AddrIn(Rs1Addr_IdOut),
    .Rs1ReadEnable(Rs1ReadEnable_IdOut),
    .Rs2AddrIn(Rs2Addr_IdOut),
    .Rs2ReadEnable(Rs2ReadEnable_IdOut),
    .Rs1ReadData(Rs1ReadData_RegFileOut),
    .Rs2ReadData(Rs2ReadData_RegFileOut),
    .ExcStopRegfile(ExcStopRegfile)
  );

  wire [`RegFileAddr] Zimm_ExIn;
  wire CsrWriteEnable_ExIn;
  wire [`InstBus] Inst_ExIn;
  wire [`DataBus] CsrReadData_ExIn;
  wire MRetEnable_ExIn;
  wire [`DataBus] CsrReadData_FwuOut;
  Id2Ex Balotelli_Id2Ex (
    .Clk(Clk),
    .Rst(Rst),
    .InstAddrIn(InstAddr_IdOut),
    .RdAddrIn(RdAddr_IdOut),
    .RdWriteEnableIn(RdWriteEnable_IdOut),
    .Rs1ReadDataIn(Rs1ReadData_FwuOut),
    .Rs2ReadDataIn(Rs2ReadData_FwuOut),
    // .Rs1AddrIn(Rs1Addr_IdOut),
    // .Rs2AddrIn(Rs2Addr_IdOut),
    .ImmIn(Imm_IdOut),
    .OpCodeIn(OpCode_IdOut),
    .Funct3In(Funct3_IdOut),
    .Funct7In(Funct7_IdOut),
    .ShamtIn(Shamt_IdOut),
    .HoldFlagFromCtrl(HoldFlag),
    // .JumpAddrFromCtrl(JumpAddr_PcIn),
    .InstAddrOut(InstAddr_ExIn),
    .RdAddrOut(RdAddr_ExIn),
    .RdWriteEnableOut(RdWriteEnable_ExIn),
    //to Fwu
    .Rs1ReadDataOut(Rs1ReadData_ExIn),
    .Rs2ReadDataOut(Rs2ReadData_ExIn),
    // .Rs1AddrOut(),
    // .Rs2AddrOut(),
    //to Mem
    .ImmOut(Imm_ExIn),
    .OpCodeOut(OpCode_ExIn),
    .Funct3Out(Funct3_ExIn),
    .Funct7Out(Funct7_ExIn),
    .ShamtOut(Shamt_ExIn)
  );
  
  wire [1:0] RVM_HoldFlagOut;
  wire [`RegFileAddr] MulWriteAddrToMul;
  wire [`RegFileAddr] MulWriteAddrToEx;
  wire [6:0] MulOpCodeToEx;
  wire [2:0] MulFunct3ToEx;
  wire [6:0] MulFunct7ToEx;

  wire [`DataBus] Rs1ReadDataDivRs2ReadData;
  wire [`DataBus] Rs1ReadDataRemRs2ReadData;
  wire DivHoldEndToEx; 
  wire [`RegFileAddr] DivWriteAddrToEx;

  wire [6:0] DivOpCodeToEx;
  wire [2:0] DivFunct3ToEx;
  wire [6:0] DivFunct7ToEx;

  wire [6:0] Funct7_ExOut;

  wire [`InstAddrBus] InstAddr_ExOut;

  wire [`InstAddrBus] InstAddr_MemIn;
  wire [`InstAddrBus] InstAddr_MemOut;

  wire [`DataBus] CsrReadData_IdIn;
  wire [`DataBus] CsrWriteData_ExOut;
  wire CsrWriteEnable_ExOut;
  wire [11:0] CsrWriteAddr_ExOut;
  Ex Balotelli_Ex (
    .InstAddrIn(InstAddr_ExIn),
    .RdAddrIn(RdAddr_ExIn),
    .RdWriteEnableIn(RdWriteEnable_ExIn),
    .Rs1ReadDataIn(Rs1ReadData_ExIn),
    .Rs2ReadDataIn(Rs2ReadData_ExIn),
    .ImmIn(Imm_ExIn),
    .OpCodeIn(OpCode_ExIn),
    .Funct3In(Funct3_ExIn),
    .Funct7In(Funct7_ExIn),
    .ShamtIn(Shamt_ExIn),
    .MulHoldEndToEx(MulHoldEndToEx),
    .DivHoldEndToEx(DivHoldEndToEx),
    .MulWriteAddrToEx(MulWriteAddrToEx),
    .DivWriteAddrToEx(DivWriteAddrToEx),
    .MulOpCodeToEx(MulOpCodeToEx),
    .MulFunct3ToEx(MulFunct3ToEx),
    .MulFunct7ToEx(MulFunct7ToEx),
    .DivOpCodeToEx(DivOpCodeToEx),
    .DivFunct3ToEx(DivFunct3ToEx),
    .DivFunct7ToEx(DivFunct7ToEx),
    .Rs1ReadDataMulRs2ReadData(Rs1ReadDataMulRs2ReadData),
    .Rs1ReadDataDivRs2ReadData(Rs1ReadDataDivRs2ReadData),
    .Rs1ReadDataRemRs2ReadData(Rs1ReadDataRemRs2ReadData),
    .RdWriteDataOut(RdWriteData_ExOut),
    .RdAddrOut(RdAddr_ExOut),
    .RdWriteEnableOut(RdWriteEnable_ExOut),
    .HoldFlagToCtrl(HoldFlag_ExOut),
    .RVM_HoldFlagOut(RVM_HoldFlagOut),
    .JumpFlagToCtrl(JumpFlag_ExOut),
    .JumpAddrToCtrl(JumpAddr_ExOut),
    .ImmOut(Imm_ExOut),
    .OpCodeOut(OpCode_ExOut),
    .Funct3Out(Funct3_ExOut),
    .Funct7Out(Funct7_ExOut),
    .Rs1ReadDataOut(Rs1ReadData_ExOut),
    .Rs2ReadDataOut(Rs2ReadData_ExOut),
    // .RV32M_WriteAddrExOut(RV32M_WriteAddrExOut),
    // .RV32M_OpCodeExOut(RV32M_OpCodeExOut),
    // .RV32M_Funct3ExOut(RV32M_Funct3ExOut),
    // .RV32M_Funct7ExOut(RV32M_Funct7ExOut)

    /*****************INT****************/
    .InstAddrOut(InstAddr_ExOut),
    .ExcInfoIn(ExcInfo_ExIn),
    .ExcInfoOut(ExcInfo_ExOut),
    .ZimmIn(Zimm_ExIn),
    .CsrWriteEnableIn(CsrWriteEnable_ExIn),
    .CsrWriteEnableOut(CsrWriteEnable_ExOut),
    .CsrReadDataIn(CsrReadData_ExIn),
    .CsrWriteDataOut(CsrWriteData_ExOut),
    .CsrWriteAddrOut(CsrWriteAddr_ExOut),
    .MRetEnableIn(MRetEnable_ExIn)
  );

  wire [`DataBus] CsrWriteData_MemIn;
  wire [11:0] CsrWriteAddr_MemIn;
  wire CsrWriteEnable_MemIn;

  Ex2Mem Balotelli_Ex2Mem (
    .Clk(Clk),
    .Rst(Rst),
    .RdWriteDataIn(RdWriteData_ExOut),
    .RdAddrIn(RdAddr_ExOut),
    .RdWriteEnableIn(RdWriteEnable_ExOut),
    .ImmIn(Imm_ExOut),
    .OpCodeIn(OpCode_ExOut),
    .Funct3In(Funct3_ExOut),
    .Rs1ReadDataIn(Rs1ReadData_ExOut),
    .Rs2ReadDataIn(Rs2ReadData_ExOut), 
    .HoldFlagFromCtrl(HoldFlag),
    .RdWriteDataOut(RdWriteData_MemIn),
    .RdAddrOut(RdAddr_MemIn),
    .RdWriteEnableOut(RdWriteEnable_MemIn),
    .ImmOut(Imm_MemIn),
    .OpCodeOut(OpCode_MemIn),
    .Funct3Out(Funct3_MemIn),
    .Rs1ReadDataOut(Rs1ReadData_MemIn),
    .Rs2ReadDataOut(Rs2ReadData_MemIn),
    /********************INT*****************/
    .InstAddrIn(InstAddr_ExOut),
    .InstAddrOut(InstAddr_MemIn),
    .ExcInfoIn(ExcInfo_ExOut),
    .ExcInfoOut(ExcInfo_MemIn),
    .CsrWriteDataIn(CsrWriteData_ExOut),
    .CsrWriteAddrIn(CsrWriteAddr_ExOut),
    .CsrWriteEnableIn(CsrWriteEnable_ExOut),
    .CsrWriteDataOut(CsrWriteData_MemIn),
    .CsrWriteAddrOut(CsrWriteAddr_MemIn),
    .CsrWriteEnableOut(CsrWriteEnable_MemIn)
  );

  wire [`DataBus] CsrWriteData_MemOut;
  wire [11:0] CsrWriteAddr_MemOut;
  wire CsrWriteEnable_MemOut;
  Mem Balotelli_Mem (
    .Clk(Clk),
    .Rst(Rst),
    .RdWriteDataIn(RdWriteData_MemIn),
    .RdAddrIn(RdAddr_MemIn),
    .RdWriteEnableIn(RdWriteEnable_MemIn),
    .ImmIn(Imm_MemIn),
    .OpCodeIn(OpCode_MemIn),
    .Funct3In(Funct3_MemIn),
    .Rs1ReadDataIn(Rs1ReadData_MemIn),
    .Rs2ReadDataIn(Rs2ReadData_MemIn), 
    .RamReadReady(DataReadReady),
    .RdWriteDataOut(RdWriteData_MemOut),
    .RdAddrOut(RdAddr_MemOut),
    .RdWriteEnableOut(RdWriteEnable_MemOut),
    //mem 
    .RaddrOut(RaddrOut),
    .WaddrOut(WaddrOut),
    .MemDataOut(MemDataOut),
    .MemDataIn(MemDataIn),
    .Wmask(Wmask),
    /******************INT******************/
    .InstAddrIn(InstAddr_MemIn),
    .InstAddrOut(InstAddr_MemOut),
    .ExcInfoIn(ExcInfo_MemIn),
    .ExcInfoOut(ExcInfo_MemOut),
    .CsrWriteDataIn(CsrWriteData_MemIn),
    .CsrWriteAddrIn(CsrWriteAddr_MemIn),
    .CsrWriteEnableIn(CsrWriteEnable_MemIn),
    .CsrWriteDataOut(CsrWriteData_MemOut),
    .CsrWriteAddrOut(CsrWriteAddr_MemOut),
    .CsrWriteEnableOut(CsrWriteEnable_MemOut)
  );

  wire [`InstAddrBus] InstAddr_WbOut;
  wire [`DataBus] ExcInfo_WbOut;

  wire [`DataBus] CsrWriteData_WbOut;
  wire [11:0] CsrWriteAddr_WbOut;
  wire CsrWriteEnable_WbOut;
  Mem2Wb Balotelli_Mem2Wb (
    .Clk(Clk),
    .Rst(Rst),  
    .RdWriteDataIn(RdWriteData_MemOut),
    .RdAddrIn(RdAddr_MemOut),
    .RdWriteEnableIn(RdWriteEnable_MemOut),
    .HoldFlagFromCtrl(HoldFlag),
    .RdWriteDataOut(RdWriteData_RegFileIn),
    .RdAddrOut(RdAddr_RegFileIn),
    .RdWriteEnableOut(RdWriteEnable_RegFileIn),
    .InstAddrIn(InstAddr_MemOut),
    .InstAddrOut(InstAddr_WbOut),
    .ExcInfoIn(ExcInfo_MemOut),
    .ExcInfoOut(ExcInfo_WbOut),
    .CsrWriteDataIn(CsrWriteData_MemOut),
    .CsrWriteAddrIn(CsrWriteAddr_MemOut),
    .CsrWriteEnableIn(CsrWriteEnable_MemOut),
    .CsrWriteDataOut(CsrWriteData_WbOut),
    .CsrWriteAddrOut(CsrWriteAddr_WbOut),
    .CsrWriteEnableOut(CsrWriteEnable_WbOut)
  );

  Fwu Balotelli_Fwu (
  `ifdef DebugMode
    .PcAddr(InstAddr_IdOut),
  `endif
    .RdWriteDataExIn(RdWriteData_ExOut),
    .RdAddrExIn(RdAddr_ExOut),
    .RdWriteEnableExIn(RdWriteEnable_ExOut),
    .RdWriteDataMemIn(RdWriteData_MemOut),
    .RdAddrMemIn(RdAddr_MemOut),
    .RdWriteEnableMemIn(RdWriteEnable_MemOut),
    .RdWriteDataWbIn(RdWriteData_RegFileIn),
    .RdAddrWbIn(RdAddr_RegFileIn),
    .RdWriteEnableWbIn(RdWriteEnable_RegFileIn),
    .Rs1ReadDataRegFileIn(Rs1ReadData_RegFileOut),
    .Rs2ReadDataRegFileIn(Rs2ReadData_RegFileOut),
    .Rs1AddrRegFileIn(Rs1Addr_IdOut),
    .Rs2AddrRegFileIn(Rs2Addr_IdOut),
    .Rs1ReadEnableIn(Rs1ReadEnable_IdOut),
    .Rs2ReadEnableIn(Rs2ReadEnable_IdOut),
    .Rs1ReadDataFwuOut(Rs1ReadData_FwuOut),
    .Rs2ReadDataFwuOut(Rs2ReadData_FwuOut),

    .CsrWriteDataExIn(CsrWriteData_ExOut),
    .CsrWriteAddrExIn(CsrWriteAddr_ExOut),
    .CsrWriteEnableExIn(CsrWriteEnable_ExOut),
    .CsrWriteDataMemIn(CsrWriteData_MemOut),
    .CsrWriteAddrMemIn(CsrWriteAddr_MemOut),
    .CsrWriteEnableMemIn(CsrWriteEnable_MemOut),
    .CsrWriteDataWbIn(CsrWriteData_WbOut),
    .CsrWriteAddrWbIn(CsrWriteAddr_WbOut),
    .CsrWriteEnableWbIn(CsrWriteEnable_WbOut),
    .CsrWriteDataIdIn(CsrReadData_IdOut),
    .CsrWriteAddrIdIn(Imm_ExIn[11:0]),
    .CsrWriteEnableIdIn(CsrWriteEnable_IdOut),
    .CsrWriteDataFwuOut(CsrReadData_FwuOut)
  );

  wire HoldFlagFromClint;
  wire HoldFlagEndFromClint;
  wire [`InstAddrBus] JumpAddrFromClint;
  Ctrl Balotelli_Ctrl (
    .Clk(Clk),
    .Rst(Rst),
    .HoldFlagFromEx(HoldFlag_ExOut),
    .RVM_HoldFlagFromEx(RVM_HoldFlagOut),
    .MulHoldEndToEx(MulHoldEndToEx),
    .DivHoldEndToEx(DivHoldEndToEx),
    .JumpFlagFromEx(JumpFlag_ExOut),
    .JumpAddrFromEx(JumpAddr_ExOut),
    .JumpAddrToPc(JumpAddr_PcIn),
    .HoldFlagOut(HoldFlag),
    .HoldFlagFromClint(HoldFlagFromClint),
    .HoldFlagEndFromClint(HoldFlagEndFromClint),
    .JumpAddrFromClint(JumpAddrFromClint),

    .BusRequest(),
    .BusUsedEnd(),
    .DataReadReady(DataReadReady),
    .DataWriteOver(DataWriteOver)
  );

  Mul Balotelli_Mul (
    .Clk(Clk),
    .Rst(Rst),
    .MulOpCodeFromEx(OpCode_ExOut),
    .MulFunct3FromEx(Funct3_ExOut),
    .MulFunct7FromEx(Funct7_ExOut),
    .MulWriteAddrToMul(RdAddr_ExOut),
    .MulHoldFlagFromEx(RVM_HoldFlagOut),
    .MulitiplicandFromEx(Rs1ReadData_ExOut),
    .MulitiplierFromEx(Rs2ReadData_ExOut),
    .ProductToEx(Rs1ReadDataMulRs2ReadData),
    .MulHoldEndToEx(MulHoldEndToEx),
    .MulWriteAddrToEx(MulWriteAddrToEx),
    .MulOpCodeToEx(MulOpCodeToEx),
    .MulFunct3ToEx(MulFunct3ToEx),
    .MulFunct7ToEx(MulFunct7ToEx)
  );

  Div Balotelli_Div (
    .Clk(Clk),
    .Rst(Rst),
    .DividendFromEx(Rs1ReadData_ExOut), 
    .DivisorFromEx(Rs2ReadData_ExOut),
    .DivHoldFlagFromEx(RVM_HoldFlagOut),
    .DivWriteAddrToDiv(RdAddr_ExOut),
    .DivOpCodeFromEx(OpCode_ExOut),
    .DivFunct3FromEx(Funct3_ExOut),
    .DivFunct7FromEx(Funct7_ExOut),
    .QuotientToEx(Rs1ReadDataDivRs2ReadData),
    .RemainderToEx(Rs1ReadDataRemRs2ReadData),
    .DivHoldEndToEx(DivHoldEndToEx),
    .DivOpCodeToEx(DivOpCodeToEx),
    .DivFunct3ToEx(DivFunct3ToEx),
    .DivFunct7ToEx(DivFunct7ToEx),
    .DivWriteAddrToEx(DivWriteAddrToEx)
  );

  wire [`DataBus] CsrMstatusReadData;
  wire [`DataBus] CsrMtvecReadData;
  wire [`DataBus] CsrMepcReadData;
  wire [`DataBus] CsrMieReadData;
  wire [`DataBus] CsrMipReadData;
  wire [`DataBus] CsrWriteData;
  wire [11:0] CsrWriteAddr;
  wire CsrWriteEnable;
  wire [11:0] CsrReadAddr;
  wire CsrReadEnable;
  wire IntEnable;
  wire IntAppear;
  wire [`IntBus] IntFlag;
  Clint Balotelli_Clint (
    .Clk(Clk),
    .Rst(Rst),
    .InstAddrIn(InstAddr_WbOut),
    .ExcInfoIn(ExcInfo_WbOut),
    .IntEnableIn(IntEnable),
    .CsrMstatusReadDataIn(CsrMstatusReadData),
    .CsrMepcReadDataIn(CsrMepcReadData),
    .CsrMtvecReadDataIn(CsrMtvecReadData),
    .CsrMieReadDataIn(CsrMieReadData),
    .CsrMipReadDataIn(CsrMipReadData),
    .CsrWriteDataOut(CsrWriteData),
    .CsrWriteAddrOut(CsrWriteAddr),
    .CsrWriteEnableOut(CsrWriteEnable),
    .HoldFlagEndOut(HoldFlagEndFromClint),
    .HoldFlagOut(HoldFlagFromClint),
    .JumpAddrOut(JumpAddrFromClint),

    .IntAppearIn(IntAppear),
    .IntFlagIn(IntFlag),
    .ExcStopRegfile(ExcStopRegfile)
  );

  CrsRegFile Balotelli_CrsRegFile (
    .Clk(Clk),
    .Rst(Rst),
    .CsrWriteDataClintIn(CsrWriteData),
    .CsrWriteAddrClintIn(CsrWriteAddr),
    .CsrWriteEnableClintIn(CsrWriteEnable),
    .CsrMstatusReadDataToClint(CsrMstatusReadData),
    .CsrMtvecReadDataToClint(CsrMtvecReadData),
    .CsrMepcReadDataToClint(CsrMepcReadData),
    .CsrMieReadDataToClint(CsrMieReadData),
    .CsrMipReadDataToClint(CsrMipReadData),
    .CsrWriteDataWbIn(CsrWriteData_WbOut),
    .CsrWriteAddrWbIn(CsrWriteAddr_WbOut),
    .CsrWriteEnableWbIn(CsrWriteEnable_WbOut),
    .CsrReadAddrIdIn(Imm_IdOut[11:0]),
    .CsrReadEnableIdIn(CsrWriteEnable_IdOut),
    .CsrReadDataToId(CsrReadData_IdIn),
    .IntEnableOut(IntEnable)
  );


  Plic Balotelli_Plic (
    .Timer0IntIn(Timer0IntIn),
    .IntAppearOut(IntAppear),
    .IntFlagOut(IntFlag)
  );

endmodule