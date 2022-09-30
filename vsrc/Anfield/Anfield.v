/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-29 11:21:05
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Anfield.v
 * @Description: Anfield Soc包含一个RISCV64 IM指令集的核(Balotelli)、VGA接口、Timer0以及行为级建模Ram和Rom，采用AXI-lite总线进行链接。
 *               注意！！！！！ 外设还在建设中，AXI-lite也未进行验证！！！！！
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module Anfield (
  // Global
  input Clk,
  input Rst,
  // From mem
  input [`DataBus] MemDataIn,
  // Vga out
  output hsync,
  output vsync,
  output valid,
  output [7:0] vga_r,
  output [7:0] vga_g,
  output [7:0] vga_b 
); 

  wire ACLK = Clk;
  wire ARESETn = Rst;

  wire BusRequest;

  wire [`AddrBus] RaddrOut;
  wire [`AddrBus] WaddrOut;
  wire [`DataBus] MemDataOut;
  wire [3:0] Wmask;
  // wire [`InstAddrBus] PcOut;

  wire [`InstAddrBus] InstIn;

  wire [`AddrBus] ReadAddrIn;
  wire ReadEnableIn;
  wire [`DataBus] ReadDataIn;
  wire [`AddrBus] ReadAddrOut;

  wire [`DataBus] ReadDataOut;
  wire RomReady;
  wire ReadInstReady;
  wire DataReadReady;
  wire DataWriteOver;

  wire [`DataBus] MemDataInInside;
  wire [`AddrBus] InstAddr;

  wire ReadShakeHands;

  wire [`AddrBus] RamWAddr;
  wire [`DataBus] RamWData;
  wire [`AddrBus] RamRAddr;
  wire [`DataBus] RamRData;
  wire [3 : 0] RamWriteStrb;
  wire RamReadReady;
  wire RamWriteReady;

  wire [`AddrBus] VgaWriteAddr;
  wire [`DataBus] VgaWriteData;
  wire VgaWriteOk;

  wire [`AddrBus] Timer0WriteAddr;
  wire [`DataBus] Timer0WriteData;
  wire Timer0WriteOk;
  wire Timer0IntIn;

  wire RomReadEnable;

  wire VgaWriteEnable;

  wire RamReadEnable;
  wire RamWriteEnable;

  wire Timer0WriteEnable;

  // assign PcOut = ReadAddrIn;

  Balotelli Anfield_Balotelli (
    .Clk(Clk),
    .Rst(Rst),
    .InstIn(InstIn),
    .InstAddrToBus(ReadAddrIn),
    .RaddrOut(RaddrOut),
    .WaddrOut(WaddrOut),
    .MemDataOut(MemDataOut),
    .Wmask(Wmask),
    .MemDataIn(MemDataInInside),
    .BusRequest(BusRequest),
    .InstReadReady(ReadInstReady),
    .InstAddrIn(InstAddr),
    .DataReadReady(DataReadReady),
    .DataWriteOver(DataWriteOver),
    .ReadShakeHands(ReadShakeHands),
    .Timer0IntIn(Timer0IntIn)
  );

  Rom Anfield_Rom (
    .Clk(Clk),
    .Rst(Rst),
    .ReadAddrIn(ReadAddrOut),
    .ReadDataOut(ReadDataIn),
    .ReadEnableIn(RomReadEnable),
    .RomReady(RomReady)
  );

  Ram Anfield_Ram (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .RamWriteAddr(RamWAddr),
    .RamWriteData(RamWData),
    .RamWriteStrb(RamWriteStrb),
    .RamReadAddr(RamRAddr),
    .ReadEnable(RamReadEnable),
    .WriteEnable(RamWriteEnable),
    .RamReadData(RamRData),
    .RamReadReady(RamReadReady),
    .RamWriteReady(RamWriteReady)
  );

  Vga Anfield_Vga (
    .clk(ACLK),
    .clrn(ARESETn),
    .clken(1'b1),
    .WriteAddrIn(VgaWriteAddr),
    .WriteDataIn(VgaWriteData),
    .WriteEnableIn(VgaWriteEnable),
    .WriteStrb(),
    .SlaverWriteReady(VgaWriteOk),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .hsync(hsync),
    .vsync(vsync),
    .valid(valid)
  );

  Timer0 Anfield_Timer0 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .WriteAddr(Timer0WriteAddr),
    .WriteData(Timer0WriteData),
    .WriteEnable(Timer0WriteEnable),
    .WriteStrb(),
    .SlaverWriteReady(Timer0WriteOk),
    .Timer0Init(Timer0IntIn)
  );

  InstBusMatrix Anfield__InstBusMatrix (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Master
    .BusRequest(BusRequest),
    .ReadAddrIn(ReadAddrIn),
    .ReadEnableOut(RomReadEnable),
    .ReadDataOut(InstIn),
    .ReadDataReady(ReadInstReady),
    .InstAddrOut(InstAddr),
    .ReadShakeHands(ReadShakeHands),
    // Slaver
    .ReadDataIn(ReadDataIn),
    .ReadAddrOut(ReadAddrOut),
    .RomReady(RomReady)
  );

  DataBusMatrix Anfield_DataBusMatrix (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Master
    .RaddrOut(RaddrOut),
    .WaddrOut(WaddrOut),
    .MemDataOut(MemDataOut),
    .MemDataIn(MemDataInInside),
    .ReadDataReady(DataReadReady),
    .WriteDataOver(DataWriteOver),
    .WriteMask(Wmask),
    // Slaver 0
    .ReadDataIn_S0(RamRData),
    .ReadAddrOut_S0(RamRAddr),
    .ReadEnableOut_S0(RamReadEnable),
    .RamReadReady_S0(RamReadReady),
    .RamWriteReady_S0(RamWriteReady),
    .WriteAddrOut_S0(RamWAddr),
    .WriteDataOut_S0(RamWData),
    .WriteEnableOut_S0(RamWriteEnable),
    .WriteStrb_S0(RamWriteStrb),
    // Slaver 1
    .ReadDataIn_S1(),
    .ReadAddrOut_S1(),
    .ReadEnableOut_S1(),
    .RamReadReady_S1(),
    .RamWriteReady_S1(VgaWriteOk),
    .WriteAddrOut_S1(VgaWriteAddr),
    .WriteDataOut_S1(VgaWriteData),
    .WriteEnableOut_S1(VgaWriteEnable),
    .WriteStrb_S1(),
    // Slaver 2
    .ReadDataIn_S2(),
    .ReadAddrOut_S2(),
    .ReadEnableOut_S2(),
    .RamReadReady_S2(),
    .RamWriteReady_S2(Timer0WriteOk),
    .WriteAddrOut_S2(Timer0WriteAddr),
    .WriteDataOut_S2(Timer0WriteData),
    .WriteEnableOut_S2(Timer0WriteEnable),
    .WriteStrb_S2()
  );
  

endmodule
