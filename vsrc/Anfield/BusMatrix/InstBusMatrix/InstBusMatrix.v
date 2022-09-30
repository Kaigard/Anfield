/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-29 13:33:09
 * @FilePath: /Anfield_SOC/vsrc/Anfield/BusMatrix/InstBusMatrix/InstBusMatrix.v
 * @Description: 指令总线矩阵，连接主机和从机，仅有读功能。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module InstBusMatrix (
  input ACLK,
  input ARESETn,
  //master
  input BusRequest,
  input [`AddrBus] ReadAddrIn,
  output [`DataBus] ReadDataOut,
  output ReadDataReady,
  output reg [`AddrBus] InstAddrOut,
  output ReadShakeHands,
  //slaver
  input [`DataBus] ReadDataIn,
  output [`AddrBus] ReadAddrOut,
  output RomReady,
  output ReadEnableOut
);

//   wire AWVALID;
//   wire [`AddrBus] AWADDR;
//   wire [2:0] AWPROT;
//   wire AWREADY;

//   wire WVALID;
//   wire [`DataBus] WDATA;
//   wire [3:0] WSTRB;
//   wire WREADY;

//   wire BREADY;
//   wire BVALID;
//   wire [2:0] BRESP;

  wire ARVALID;
  wire [`AddrBus] ARADDR;
  wire [2 : 0] ARPROT;
  wire ARREADY;
  
  wire RVALID;
  wire [`DataBus] RDATA;
  wire [2 : 0] RRESP;
  wire RREADY;

  // always @(posedge ACLK) begin
  //   if(!ARESETn) begin
  //     InstAddrOut <= `PcInit;
  //   end else if(ReadDataReady) begin
  //     InstAddrOut <= ReadAddrIn; 
  //   end
  // end

  localparam RomBaseAddr = 64'h0000_0000_8000_0000;

  AxiLiteMasterInterface u_Axi_Lite_Master_Inst (
    .ReadEnableIn(BusRequest),
    .WriteEnableIn(),
    .ReadAddrIn(ReadAddrIn),
    .WriteAddrIn(),
    .WriteDataIn(),
    .WriteMask(),
    .ReadDataOut(ReadDataOut),
    .ReadDataReady(ReadDataReady),
    .WriteDataOver(),
    .ReadShakeHands(ReadShakeHands),
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .AWVALID(),
    .AWADDR(),
    .AWPROT(),
    .AWREADY(),
    .WVALID(),
    .WDATA(),
    .WSTRB(),
    .WREADY(),
    .BREADY(),
    .BVALID(),
    .BRESP(),
    .ARVALID(ARVALID),
    .ARADDR(ARADDR),
    .ARPROT(ARPROT),
    .ARREADY(ARREADY),
    .RVALID(RVALID),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RREADY(RREADY)
  );

  AxiLiteSlaverInterface u_Axi_Lite_Slaver_Inst (
    .ReadDataIn(ReadDataIn),
    .ReadAddrOut(ReadAddrOut),
    .ReadEnableOut(ReadEnableOut),
    .WriteAddrOut(),
    .WriteEnableOut(),
    .WriteDataOut(),
    .WriteStrb(),
    .SlaverReadReady(RomReady),
    .SlaverWriteReady(),
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .AWVALID(),
    .AWADDR(),
    .AWPROT(),
    .AWREADY(),
    .WVALID(),
    .WDATA(),
    .WSTRB(),
    .WREADY(),
    .BREADY(),
    .BVALID(),
    .BRESP(),
    .ARVALID(ARVALID),
    // Rom地址映射
    .ARADDR(ARADDR - RomBaseAddr),
    .ARPROT(ARPROT),
    .ARREADY(ARREADY),
    .RVALID(RVALID),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RREADY(RREADY)
  );


endmodule