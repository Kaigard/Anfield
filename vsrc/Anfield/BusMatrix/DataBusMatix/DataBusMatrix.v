/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-29 11:00:14
 * @FilePath: /Anfield_SOC/vsrc/Anfield/BusMatrix/DataBusMatix/DataBusMatrix.v
 * @Description: 总线矩阵，连接主机和从机。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module DataBusMatrix (
  input ACLK,
  input ARESETn,
  //master
  input [`AddrBus] RaddrOut,
  input [`AddrBus] WaddrOut,
  input [`DataBus] MemDataOut,
  output [`DataBus] MemDataIn,
  output ReadDataReady,
  output WriteDataOver,
  input [3:0] WriteMask,
  //slaver 0
  input [`DataBus] ReadDataIn_S0,
  output [`AddrBus] ReadAddrOut_S0,
  output ReadEnableOut_S0,
  input RamReadReady_S0,
  input RamWriteReady_S0,
  output [`AddrBus] WriteAddrOut_S0,
  output [`DataBus] WriteDataOut_S0,
  output WriteEnableOut_S0,
  output [3 : 0] WriteStrb_S0,
  //slaver 1
  input [`DataBus] ReadDataIn_S1,
  output [`AddrBus] ReadAddrOut_S1,
  output ReadEnableOut_S1,
  input RamReadReady_S1,
  input RamWriteReady_S1,
  output [`AddrBus] WriteAddrOut_S1,
  output [`DataBus] WriteDataOut_S1,
  output WriteEnableOut_S1,
  output [3 : 0] WriteStrb_S1,
  //slaver 2
  input [`DataBus] ReadDataIn_S2,
  output [`AddrBus] ReadAddrOut_S2,
  output ReadEnableOut_S2,
  input RamReadReady_S2,
  input RamWriteReady_S2,
  output [`AddrBus] WriteAddrOut_S2,
  output [`DataBus] WriteDataOut_S2,
  output WriteEnableOut_S2,
  output [3 : 0] WriteStrb_S2
);

  wire AWVALID;
  wire [`AddrBus] AWADDR;
  wire [2 : 0] AWPROT;
  wire AWREADY;

  wire WVALID;
  wire [`DataBus] WDATA;
  wire [3 : 0] WSTRB;
  wire WREADY;

  wire BREADY;
  wire BVALID;
  wire [2 : 0] BRESP;

  wire ARVALID;
  wire [`AddrBus] ARADDR;
  wire [2 : 0] ARPROT;
  wire ARREADY;
  
  wire RVALID;
  wire [`DataBus] RDATA;
  wire [2 : 0] RRESP;
  wire RREADY;

  // slaver 0
  wire AWVALID_S0;
  wire [`AddrBus] AWADDR_S0;
  wire [2 : 0] AWPROT_S0;
  wire AWREADY_S0;

  wire WVALID_S0;
  wire [`DataBus] WDATA_S0;
  wire [3 : 0] WSTRB_S0;
  wire WREADY_S0;

  wire BREADY_S0;
  wire BVALID_S0;
  wire [2 : 0] BRESP_S0;

  wire ARVALID_S0;
  wire [`AddrBus] ARADDR_S0;
  wire [2 : 0] ARPROT_S0;
  wire ARREADY_S0;

  wire RVALID_S0;
  wire [`DataBus] RDATA_S0;
  wire [2 : 0] RRESP_S0;
  wire RREADY_S0;

  // slaver 1
  wire AWVALID_S1;
  wire [`AddrBus] AWADDR_S1;
  wire [2 : 0] AWPROT_S1;
  wire AWREADY_S1;

  wire WVALID_S1;
  wire [`DataBus] WDATA_S1;
  wire [3 : 0] WSTRB_S1;
  wire WREADY_S1;

  wire BREADY_S1;
  wire BVALID_S1;
  wire [2 : 0] BRESP_S1;

  wire ARVALID_S1;
  wire [`AddrBus] ARADDR_S1;
  wire [2 : 0] ARPROT_S1;
  wire ARREADY_S1;

  wire RVALID_S1;
  wire [`DataBus] RDATA_S1;
  wire [2 : 0] RRESP_S1;
  wire RREADY_S1;

  // slaver 2
  wire AWVALID_S2;
  wire [`AddrBus] AWADDR_S2;
  wire [2 : 0] AWPROT_S2;
  wire AWREADY_S2;

  wire WVALID_S2;
  wire [`DataBus] WDATA_S2;
  wire [3 : 0] WSTRB_S2;
  wire WREADY_S2;

  wire BREADY_S2;
  wire BVALID_S2;
  wire [2 : 0] BRESP_S2;

  wire ARVALID_S2;
  wire [`AddrBus] ARADDR_S2;
  wire [2 : 0] ARPROT_S2;
  wire ARREADY_S2;

  wire RVALID_S2;
  wire [`DataBus] RDATA_S2;
  wire [2 : 0] RRESP_S2;
  wire RREADY_S2;


  AxiLiteMasterInterface Anfield_Axi_Lite_Master_Data (
    .ReadEnableIn(RaddrOut != 64'h0),
    .WriteEnableIn(WaddrOut != 64'h0),
    .ReadAddrIn(RaddrOut),
    .WriteAddrIn(WaddrOut),
    .WriteDataIn(MemDataOut),
    .WriteMask(WriteMask),
    .ReadDataOut(MemDataIn),
    .ReadDataReady(ReadDataReady),
    .WriteDataOver(WriteDataOver),
    .ReadShakeHands(),
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .AWVALID(AWVALID),
    .AWADDR(AWADDR),
    .AWPROT(AWPROT),
    .AWREADY(AWREADY),
    .WVALID(WVALID),
    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WREADY(WREADY),
    .BREADY(BREADY),
    .BVALID(BVALID),
    .BRESP(BRESP),
    .ARVALID(ARVALID),
    .ARADDR(ARADDR),
    .ARPROT(ARPROT),
    .ARREADY(ARREADY),
    .RVALID(RVALID),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RREADY(RREADY)
  );

  DataBusDecode Anfield_DataBusDecode (
    .AWVALID(AWVALID),
    .AWADDR(AWADDR),
    .AWPROT(AWPROT),
    .AWREADY(AWREADY),
    .WVALID(WVALID),
    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WREADY(WREADY),
    .BREADY(BREADY),
    .BVALID(BVALID),
    .BRESP(BRESP),
    .ARVALID(ARVALID),
    .ARADDR(ARADDR),
    .ARPROT(ARPROT),
    .ARREADY(ARREADY),
    .RVALID(RVALID),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RREADY(RREADY),
    // slaver 0
    .AWVALID_S0(AWVALID_S0),
    .AWADDR_S0(AWADDR_S0),
    .AWPROT_S0(AWPROT_S0),
    .AWREADY_S0(AWREADY_S0),
    .WVALID_S0(WVALID_S0),
    .WDATA_S0(WDATA_S0),
    .WSTRB_S0(WSTRB_S0),
    .WREADY_S0(WREADY_S0),
    .BREADY_S0(BREADY_S0),
    .BVALID_S0(BVALID_S0),
    .BRESP_S0(BRESP_S0),
    .ARVALID_S0(ARVALID_S0),
    .ARADDR_S0(ARADDR_S0),
    .ARPROT_S0(ARPROT_S0),
    .ARREADY_S0(ARREADY_S0),
    .RVALID_S0(RVALID_S0),
    .RDATA_S0(RDATA_S0),
    .RRESP_S0(RRESP_S0),
    .RREADY_S0(RREADY_S0),
    // slaver 1
    .AWVALID_S1(AWVALID_S1),
    .AWADDR_S1(AWADDR_S1),
    .AWPROT_S1(AWPROT_S1),
    .AWREADY_S1(AWREADY_S1),
    .WVALID_S1(WVALID_S1),
    .WDATA_S1(WDATA_S1),
    .WSTRB_S1(WSTRB_S1),
    .WREADY_S1(WREADY_S1),
    .BREADY_S1(BREADY_S1),
    .BVALID_S1(BVALID_S1),
    .BRESP_S1(BRESP_S1),
    .ARVALID_S1(ARVALID_S1),
    .ARADDR_S1(ARADDR_S1),
    .ARPROT_S1(ARPROT_S1),
    .ARREADY_S1(ARREADY_S1),
    .RVALID_S1(RVALID_S1),
    .RDATA_S1(RDATA_S1),
    .RRESP_S1(RRESP_S1),
    .RREADY_S1(RREADY_S1),
    // slaver 2
    .AWVALID_S2(AWVALID_S2),
    .AWADDR_S2(AWADDR_S2),
    .AWPROT_S2(AWPROT_S2),
    .AWREADY_S2(AWREADY_S2),
    .WVALID_S2(WVALID_S2),
    .WDATA_S2(WDATA_S2),
    .WSTRB_S2(WSTRB_S2),
    .WREADY_S2(WREADY_S2),
    .BREADY_S2(BREADY_S2),
    .BVALID_S2(BVALID_S2),
    .BRESP_S2(BRESP_S2),
    .ARVALID_S2(ARVALID_S2),
    .ARADDR_S2(ARADDR_S2),
    .ARPROT_S2(ARPROT_S2),
    .ARREADY_S2(ARREADY_S2),
    .RVALID_S2(RVALID_S2),
    .RDATA_S2(RDATA_S2),
    .RRESP_S2(RRESP_S2),
    .RREADY_S2(RREADY_S2)
  );


  AxiLiteSlaverInterface Anfield_Axi_Lite_Slaver_Ram (
    .ReadDataIn(ReadDataIn_S0),
    .ReadAddrOut(ReadAddrOut_S0),
    .ReadEnableOut(ReadEnableOut_S0),
    .WriteAddrOut(WriteAddrOut_S0),
    .WriteDataOut(WriteDataOut_S0),
    .WriteEnableOut(WriteEnableOut_S0),
    .WriteStrb(WriteStrb_S0),
    .SlaverReadReady(RamReadReady_S0),
    .SlaverWriteReady(RamWriteReady_S0),

    .ACLK(ACLK),
    .ARESETn(ARESETn),

    .AWVALID(AWVALID_S0),
    .AWADDR(AWADDR_S0),
    .AWPROT(AWPROT_S0),
    .AWREADY(AWREADY_S0),

    .WVALID(WVALID_S0),
    .WDATA(WDATA_S0),
    .WSTRB(WSTRB_S0),
    .WREADY(WREADY_S0),

    .BREADY(BREADY_S0),
    .BVALID(BVALID_S0),
    .BRESP(BRESP_S0),

    .ARVALID(ARVALID_S0),
    .ARADDR(ARADDR_S0),
    .ARPROT(ARPROT_S0),
    .ARREADY(ARREADY_S0),

    .RVALID(RVALID_S0),
    .RDATA(RDATA_S0),
    .RRESP(RRESP_S0),
    .RREADY(RREADY_S0)
  );

  AxiLiteSlaverInterface Anfield_Axi_Lite_Slaver_Vga (
    .ReadDataIn(ReadDataIn_S1),
    .ReadAddrOut(ReadAddrOut_S1),
    .ReadEnableOut(),
    .WriteAddrOut(WriteAddrOut_S1),
    .WriteDataOut(WriteDataOut_S1),
    .WriteEnableOut(WriteEnableOut_S1),
    .WriteStrb(WriteStrb_S1),
    .SlaverReadReady(RamReadReady_S1),
    .SlaverWriteReady(RamWriteReady_S1),

    .ACLK(ACLK),
    .ARESETn(ARESETn),

    .AWVALID(AWVALID_S1),
    .AWADDR(AWADDR_S1),
    .AWPROT(AWPROT_S1),
    .AWREADY(AWREADY_S1),

    .WVALID(WVALID_S1),
    .WDATA(WDATA_S1),
    .WSTRB(WSTRB_S1),
    .WREADY(WREADY_S1),

    .BREADY(BREADY_S1),
    .BVALID(BVALID_S1),
    .BRESP(BRESP_S1),

    .ARVALID(ARVALID_S1),
    .ARADDR(ARADDR_S1),
    .ARPROT(ARPROT_S1),
    .ARREADY(ARREADY_S1),

    .RVALID(RVALID_S1),
    .RDATA(RDATA_S1),
    .RRESP(RRESP_S1),
    .RREADY(RREADY_S1)
  );

  AxiLiteSlaverInterface Anfield_Axi_Lite_Slaver_Timer0 (
    .ReadDataIn(ReadDataIn_S2),
    .ReadAddrOut(ReadAddrOut_S2),
    .ReadEnableOut(),
    .WriteAddrOut(WriteAddrOut_S2),
    .WriteDataOut(WriteDataOut_S2),
    .WriteEnableOut(WriteEnableOut_S2),
    .WriteStrb(WriteStrb_S2),
    .SlaverReadReady(RamReadReady_S2),
    .SlaverWriteReady(RamWriteReady_S2),

    .ACLK(ACLK),
    .ARESETn(ARESETn),

    .AWVALID(AWVALID_S2),
    .AWADDR(AWADDR_S2),
    .AWPROT(AWPROT_S2),
    .AWREADY(AWREADY_S2),

    .WVALID(WVALID_S2),
    .WDATA(WDATA_S2),
    .WSTRB(WSTRB_S2),
    .WREADY(WREADY_S2),

    .BREADY(BREADY_S2),
    .BVALID(BVALID_S2),
    .BRESP(BRESP_S2),

    .ARVALID(ARVALID_S2),
    .ARADDR(ARADDR_S2),
    .ARPROT(ARPROT_S2),
    .ARREADY(ARREADY_S2),

    .RVALID(RVALID_S2),
    .RDATA(RDATA_S2),
    .RRESP(RRESP_S2),
    .RREADY(RREADY_S2)
  );

endmodule