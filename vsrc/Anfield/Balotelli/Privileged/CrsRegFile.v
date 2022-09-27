/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:54:44
 * @FilePath: /Anfield/Balotelli/Privileged/CrsRegFile.v
 * @Description: CSR寄存器堆。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


module CrsRegFile (
  input Clk,
  input Rst,
  //Wb阶段，对现场进行保存
  input [`DataBus] CsrWriteDataClintIn, 
  input [11:0] CsrWriteAddrClintIn,
  input CsrWriteEnableClintIn,
  output [`DataBus] CsrMstatusReadDataToClint,
  output [`DataBus] CsrMtvecReadDataToClint,
  output [`DataBus] CsrMepcReadDataToClint,
  output [`DataBus] CsrMieReadDataToClint,
  output [`DataBus] CsrMipReadDataToClint,
  //Ex阶段，读写Csrs
  input [`DataBus] CsrWriteDataWbIn,
  input [11:0] CsrWriteAddrWbIn,
  input CsrWriteEnableWbIn,
  input [11:0] CsrReadAddrIdIn,
  input CsrReadEnableIdIn,
  output reg [`DataBus] CsrReadDataToId,
  output IntEnableOut
);
  reg [`DataBus] Mtvec;
  reg [`DataBus] Mepc;
  reg [`DataBus] Mcause;
  reg [`DataBus] Mie;
  reg [`DataBus] Mip;
  reg [`DataBus] Mtval;
  reg [`DataBus] Mscratch;
  reg [`DataBus] Mstatus;

  assign CsrMstatusReadDataToClint = Mstatus;
  assign CsrMtvecReadDataToClint = Mtvec;
  assign CsrMepcReadDataToClint = Mepc;

  //Ex or Cint Write
  always @ (posedge Clk) begin
    if(!Rst) begin
      Mtvec <= `PcInit;
      Mepc <= `RegZero;
      Mcause <= `RegZero;
      Mie <= `RegZero;
      Mip <= `RegZero;
      Mtval <= `RegZero;
      Mscratch <= `RegZero;
      Mstatus <= `RegZero;
    end else begin
      case ({CsrWriteEnableWbIn, CsrWriteEnableClintIn})
        2'b10 : begin
          case (CsrWriteAddrWbIn)
            12'h643 : Mtvec <= CsrWriteDataWbIn;
            12'h341 : Mepc <= CsrWriteDataWbIn;
            12'h342 : Mcause <= CsrWriteDataWbIn;
            12'h304 : Mie <= CsrWriteDataWbIn;
            12'h344 : Mip <= CsrWriteDataWbIn;
            12'h343 : Mtval <= CsrWriteDataWbIn;
            12'h340 : Mscratch <= CsrWriteDataWbIn;
            12'h300 : Mstatus <= CsrWriteDataWbIn;
            default : ;
          endcase
        end
        2'b01 : begin
          case (CsrWriteAddrClintIn)
            12'h643 : Mtvec <= CsrWriteDataClintIn;
            12'h341 : Mepc <= CsrWriteDataClintIn;
            12'h342 : Mcause <= CsrWriteDataClintIn;
            12'h304 : Mie <= CsrWriteDataClintIn;
            12'h344 : Mip <= CsrWriteDataClintIn;
            12'h343 : Mtval <= CsrWriteDataClintIn;
            12'h340 : Mscratch <= CsrWriteDataClintIn;
            12'h300 : Mstatus <= CsrWriteDataClintIn;
            default : ;
          endcase
        end
        default : begin
          Mtvec <= Mtvec;
          Mepc <= Mepc;
          Mcause <= Mcause;
          Mie <= Mie;
          Mip <= Mip;
          Mtval <= Mtval;
          Mscratch <= Mscratch;
          Mstatus <= Mstatus;
        end
      endcase
    end
  end

  always @ ( * ) begin
    //数据前推
    if(CsrReadEnableIdIn && (CsrReadAddrIdIn == CsrWriteAddrWbIn) && CsrWriteEnableWbIn) begin
      CsrReadDataToId = CsrWriteDataWbIn;
    end else if(CsrReadEnableIdIn) begin
      case (CsrReadAddrIdIn)
        12'h643 : CsrReadDataToId = Mtvec;
        12'h341 : CsrReadDataToId = Mepc;
        12'h342 : CsrReadDataToId = Mcause;
        12'h304 : CsrReadDataToId = Mie;
        12'h344 : CsrReadDataToId = Mip;
        12'h343 : CsrReadDataToId = Mtval;
        12'h340 : CsrReadDataToId = Mscratch;
        12'h300 : CsrReadDataToId = Mstatus;
        default : ;
      endcase
    end else begin
      CsrReadDataToId = `RegZero;
    end
  end

endmodule