/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:53:55
 * @FilePath: /Anfield/Balotelli/Privileged/Clint.v
 * @Description: 异常处理模块，负责更改CRS寄存器。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module Clint (
  input Clk,
  input Rst,
  input [`InstAddrBus] InstAddrIn,
  input [`DataBus] ExcInfoIn,
  input IntEnableIn,
  input [`DataBus] CsrMstatusReadDataIn,
  input [`DataBus] CsrMtvecReadDataIn,
  input [`DataBus] CsrMepcReadDataIn,
  input [`DataBus] CsrMieReadDataIn,
  input [`DataBus] CsrMipReadDataIn,
  input IntAppearIn,
  input [`IntBus] IntFlagIn,
  //各级流水例外类型
  output reg [`DataBus] CsrWriteDataOut,
  output reg [11:0] CsrWriteAddrOut,
  output reg CsrWriteEnableOut,
  output reg HoldFlagEndOut,
  output HoldFlagOut,
  output reg [`DataBus] JumpAddrOut,
  output ExcStopRegfile
);

  `define ExcInfoBus 15:0
  `define ExcEnBit 15
  `define ExcIntBit 14
  `define ExcMRetBit 13
  `define ExcIntKindsBit 5:0
  `define ExcIntKindsBus 5:0
  `define ExcCodeBus 6:0
  `define ExcCodeBit 6:0

  //ExcInfo译码
  wire [`ExcInfoBus] IfStepExc = ExcInfoIn[63:48];
  wire [`ExcInfoBus] IdStepExc = ExcInfoIn[47:32];
  wire [`ExcInfoBus] ExStepExc = ExcInfoIn[31:16];                          //ExExcInfo译码比较特殊，包含了1位Ret使能信息
  wire [`ExcInfoBus] MemStepExc = ExcInfoIn[15:0];

  wire IfStepExc_En = IfStepExc[`ExcEnBit];
  wire IdStepExc_En = IdStepExc[`ExcEnBit];
  wire ExStepExc_En = ExStepExc[`ExcEnBit];
  wire MemStepExc_En = MemStepExc[`ExcEnBit];

  wire ExStepMRetEn = ExStepExc[`ExcMRetBit];

  wire [`ExcCodeBus] IfStepExc_ExcCode = IfStepExc[`ExcCodeBit];
  wire [`ExcCodeBus] IdStepExc_ExcCode = IdStepExc[`ExcCodeBit];
  wire [`ExcCodeBus] ExStepExc_ExcCode = ExStepExc[`ExcCodeBit];
  wire [`ExcCodeBus] MemStepExc_ExcCode = MemStepExc[`ExcCodeBit];

  //中断仲裁
  reg [`ExcCodeBus] ExcCode;
  always @( * ) begin
    if(IfStepExc_En || IdStepExc_En ||ExStepExc_En || MemStepExc_En) begin
      if(IfStepExc_En) begin
        ExcCode = IfStepExc_ExcCode;
      end else if(IdStepExc_En) begin
        ExcCode = IdStepExc_ExcCode;
      end else if(ExStepExc_En) begin
        ExcCode = ExStepExc_ExcCode;
      end else if(MemStepExc_En) begin
        ExcCode = MemStepExc_ExcCode;
      end else begin
        ExcCode = 7'h00;
      end
    end else if(IntAppearIn) begin
      case (IntFlagIn)
        6'h08 : begin
          ExcCode = 7'h07;
        end
        default : begin
          ExcCode = 7'h00;
        end
      endcase
    end else begin
      ExcCode = 7'h00;
    end
  end

  reg [`DataBus] InstAddrRetention;
  reg [`ExcCodeBus] ExcCodeRetention;

  wire ExcAppear = (IfStepExc_En || IdStepExc_En || ExStepExc_En || MemStepExc_En);
  assign ExcStopRegfile = ExcAppear;

  always @(posedge Clk) begin
    if(!Rst) begin
      InstAddrRetention <= `RegZero;
      ExcCodeRetention <= 7'b0;
    end else if(ExcAppear || IntAppearIn) begin
      InstAddrRetention <= InstAddrIn;
      ExcCodeRetention <= ExcCode;
    end
  end

  assign HoldFlagOut = (ExcAppear || (IntAppearIn && CsrMstatusReadDataIn[3]) || ExStepMRetEn);

  parameter Idel = 7'b000_0000;
  parameter SyncExc = 7'b000_0001;
  parameter AsyncExc = 7'b000_0010;
  parameter SetMip = 7'b000_0100;
  parameter SetMepc = 7'b000_1000;
  parameter SetMcause = 7'b001_0000;
  parameter SetMstatus = 7'b010_0000;
  parameter MRet = 7'b100_0000; 

  reg [6:0] CurrentState;
  reg [6:0] NextState;
  reg [`DataBus] InstAddrOutRetention;

  always @(posedge Clk) begin
    if(!Rst) begin
      CurrentState <= Idel;
    end else begin
      CurrentState <= NextState;
    end
  end
  always @( * ) begin
    case (CurrentState) 
      Idel : begin
        if(IfStepExc_En || IdStepExc_En || ExStepExc_En || MemStepExc_En) begin
          NextState = SyncExc;
        end else if(IntAppearIn && CsrMstatusReadDataIn[3]) begin
          NextState = AsyncExc;
        end else if(ExStepMRetEn) begin
          NextState = MRet;
        end else begin
          NextState = Idel;
        end
      end
      SyncExc : begin
        NextState = SetMepc;
      end
      AsyncExc : begin
        NextState = SetMip;
      end
      SetMip : begin
        case (ExcCodeRetention)
          7'h7: begin
            NextState = (CsrMieReadDataIn[7] && CsrMipReadDataIn[7]) ? SetMepc : Idel;
          end
          default : begin
            NextState = Idel;
          end
        endcase
      end
      SetMepc : begin
        NextState = SetMcause;
      end
      SetMcause : begin
        NextState = SetMstatus;
      end
      SetMstatus : begin
        NextState = Idel;
      end
      MRet : begin
        NextState = Idel;
      end
      default : begin
        NextState = Idel;
      end
    endcase
  end
  always @( * ) begin
    case (CurrentState)
      AsyncExc : begin
        CsrWriteEnableOut = 1'b1;
        CsrWriteAddrOut = 12'h344;
        HoldFlagEndOut = 1'b0;
        JumpAddrOut = `PcInit;
        case (ExcCodeRetention)
          7'h01 : begin
            CsrWriteDataOut = 64'h0000_0000_0000_0002;
          end
          7'h03 : begin
            CsrWriteDataOut = 64'h0000_0000_0000_0008;
          end
          7'h05 : begin
            CsrWriteDataOut = 64'h0000_0000_0000_0020;
          end
          7'h07 : begin
            CsrWriteDataOut = 64'h0000_0000_0000_0080;
          end
          7'h09 : begin
            CsrWriteDataOut = 64'h0000_0000_0000_0200;
          end
          7'h0b : begin
            CsrWriteDataOut = 64'h0000_0000_0000_0800;
          end
          default : begin
            CsrWriteDataOut = 64'h0000_0000_0000_0000;
          end
        endcase 
      end
      SetMepc : begin
        CsrWriteEnableOut = 1'b1;
        CsrWriteAddrOut = 12'h341;
        CsrWriteDataOut = InstAddrRetention;
        HoldFlagEndOut = 1'b0;
        JumpAddrOut = `PcInit;
      end
      SetMcause : begin
        CsrWriteEnableOut = 1'b1;
        CsrWriteAddrOut = 12'h342;
        CsrWriteDataOut = {{57{1'b0}}, ExcCodeRetention};
        HoldFlagEndOut = 1'b0;
        JumpAddrOut = `PcInit;
      end
      SetMstatus : begin
        CsrWriteEnableOut = 1'b1;
        CsrWriteAddrOut = 12'h300;
        CsrWriteDataOut = {CsrMstatusReadDataIn[63:8], CsrMstatusReadDataIn[3], CsrMstatusReadDataIn[6:4], 1'b0, CsrMstatusReadDataIn[2:0]};
        HoldFlagEndOut = 1'b1;
        JumpAddrOut = CsrMtvecReadDataIn;
      end
      MRet : begin
        CsrWriteEnableOut = 1'b1;
        CsrWriteAddrOut = 12'h300;
        CsrWriteDataOut = {CsrMstatusReadDataIn[63:4], CsrMstatusReadDataIn[7], CsrMstatusReadDataIn[2:0]};
        JumpAddrOut = CsrMepcReadDataIn;
        HoldFlagEndOut = 1'b1;
      end
      default : begin
        CsrWriteEnableOut = 1'b0;
        CsrWriteAddrOut = 12'h000;
        CsrWriteDataOut = `RegZero;
        HoldFlagEndOut = 1'b0;
        JumpAddrOut = `PcInit;
      end
    endcase
  end
  always @(posedge Clk) begin
    if(!Rst) begin
      InstAddrOutRetention <= `RegZero;
    end else begin
      case (CurrentState)
        SyncExc : begin
          InstAddrOutRetention <= InstAddrRetention;
        end
        AsyncExc : begin
          InstAddrOutRetention <= InstAddrRetention + 4;
        end
        default : ;
      endcase 
    end
  end


endmodule