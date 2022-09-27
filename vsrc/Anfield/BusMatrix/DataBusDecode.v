/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:40:04
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:44:38
 * @FilePath: /Anfield/BusMatrix/DataBusDecode.v
 * @Description: 数据总线矩阵Mux，因采用哈弗架构且采用阻塞方式对外读写所以并未含有仲裁功能，目前支持一主三从。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


`include "./vsrc/defines.v"
module DataBusDecode (
  // write addr channel
  input AWVALID,
  input [`AddrBus] AWADDR,
  input [2:0] AWPROT,
  output reg AWREADY,
  // write data channel
  input WVALID,
  input [`DataBus] WDATA,
  input [3:0] WSTRB,
  output reg WREADY,
  // write repair channel
  input BREADY,
  output reg BVALID,
  output reg [2:0] BRESP,
  // read addr channel
  input ARVALID,
  input [`AddrBus] ARADDR,
  input [2:0] ARPROT,
  output ARREADY,
  // read data channel
  output reg RVALID,
  output reg [`DataBus] RDATA,
  output reg [2:0] RRESP,
  input RREADY,
  // slaver 0
  // read data channel
  output AWVALID_S0,
  output [`AddrBus] AWADDR_S0,
  output [2:0] AWPROT_S0,
  input AWREADY_S0,
  // write data channel
  output WVALID_S0,
  output [`DataBus] WDATA_S0,
  output [3:0] WSTRB_S0,
  input WREADY_S0,
  // write repair channel
  output BREADY_S0,
  input BVALID_S0,
  input [2:0] BRESP_S0,
  // read addr channel
  output ARVALID_S0,
  output [`AddrBus] ARADDR_S0,
  output [2:0] ARPROT_S0,
  input ARREADY_S0,
  // read data channel
  input RVALID_S0,
  input [`DataBus] RDATA_S0,
  input [2:0] RRESP_S0,
  output RREADY_S0,
  // slaver 1
  // read data channel
  output AWVALID_S1,
  output [`AddrBus] AWADDR_S1,
  output [2:0] AWPROT_S1,
  input AWREADY_S1,
  // write data channel
  output WVALID_S1,
  output [`DataBus] WDATA_S1,
  output [3:0] WSTRB_S1,
  input WREADY_S1,
  // write repair channel
  output BREADY_S1,
  input BVALID_S1,
  input [2:0] BRESP_S1,
  // read addr channel
  output ARVALID_S1,
  output [`AddrBus] ARADDR_S1,
  output [2:0] ARPROT_S1,
  input ARREADY_S1,
  // read data channel
  input RVALID_S1,
  input [`DataBus] RDATA_S1,
  input [2:0] RRESP_S1,
  output RREADY_S1,
  // slaver 2
  // read data channel
  output AWVALID_S2,
  output [`AddrBus] AWADDR_S2,
  output [2:0] AWPROT_S2,
  input AWREADY_S2,
  // write data channel
  output WVALID_S2,
  output [`DataBus] WDATA_S2,
  output [3:0] WSTRB_S2,
  input WREADY_S2,
  // write repair channel
  output BREADY_S2,
  input BVALID_S2,
  input [2:0] BRESP_S2,
  // read addr channel
  output ARVALID_S2,
  output [`AddrBus] ARADDR_S2,
  output [2:0] ARPROT_S2,
  input ARREADY_S2,
  // read data channel
  input RVALID_S2,
  input [`DataBus] RDATA_S2,
  input [2:0] RRESP_S2,
  output RREADY_S2
);

  // slaver 0
  assign AWVALID_S0 = AWADDR[31:28] == 4'h8 ? AWVALID : 1'b0;
  assign AWADDR_S0 = AWADDR[31:28] == 4'h8 ? AWADDR : `RegZero;
  assign AWPROT_S0 = AWADDR[31:28] == 4'h8 ? AWPROT : 3'h0;
  assign WVALID_S0 = AWADDR[31:28] == 4'h8 ? WVALID : 1'b0;
  assign WDATA_S0 = AWADDR[31:28] == 4'h8 ? WDATA : `RegZero;
  assign WSTRB_S0 = AWADDR[31:28] == 4'h8 ? WSTRB : 4'h0;
  assign ARVALID_S0 = ARADDR[31:28] == 4'h8 ? ARVALID : 1'b0;
  assign ARADDR_S0 = ARADDR[31:28] == 4'h8 ? ARADDR : `RegZero;
  assign ARPROT_S0 = ARADDR[31:28] == 4'h8 ? ARPROT : 3'h0;

  // slaver 1
  assign AWVALID_S1 = AWADDR[31:28] == 4'h4 ? AWVALID : 1'b0;
  assign AWADDR_S1 = AWADDR[31:28] == 4'h4 ? AWADDR : `RegZero;
  assign AWPROT_S1 = AWADDR[31:28] == 4'h4 ? AWPROT : 3'h0;
  assign WVALID_S1 = AWADDR[31:28] == 4'h4 ? WVALID : 1'b0;
  assign WDATA_S1 = AWADDR[31:28] == 4'h4 ? WDATA : `RegZero;
  assign WSTRB_S1 = AWADDR[31:28] == 4'h4 ? WSTRB : 4'h0;
  assign ARVALID_S1 = ARADDR[31:28] == 4'h4 ? ARVALID : 1'b0;
  assign ARADDR_S1 = ARADDR[31:28] == 4'h4 ? ARADDR : `RegZero;
  assign ARPROT_S1 = ARADDR[31:28] == 4'h4 ? ARPROT : 3'h0;

  // slaver 2
  assign AWVALID_S2 = AWADDR[31:28] == 4'h5 ? AWVALID : 1'b0;
  assign AWADDR_S2 = AWADDR[31:28] == 4'h5 ? AWADDR : `RegZero;
  assign AWPROT_S2 = AWADDR[31:28] == 4'h5 ? AWPROT : 3'h0;
  assign WVALID_S2 = AWADDR[31:28] == 4'h5 ? WVALID : 1'b0;
  assign WDATA_S2 = AWADDR[31:28] == 4'h5 ? WDATA : `RegZero;
  assign WSTRB_S2 = AWADDR[31:28] == 4'h5 ? WSTRB : 4'h0;
  assign ARVALID_S2 = ARADDR[31:28] == 4'h5 ? ARVALID : 1'b0;
  assign ARADDR_S2 = ARADDR[31:28] == 4'h5 ? ARADDR : `RegZero;
  assign ARPROT_S2 = ARADDR[31:28] == 4'h5 ? ARPROT : 3'h0;

  assign AWREADY = AWREADY_S0 | AWREADY_S1 | AWREADY_S2;
  assign WREADY = WREADY_S0 | WREADY_S1 | WREADY_S2;
  assign BREADY_S0 = BREADY;
  assign BREADY_S1 = BREADY;
  assign BREADY_S2 = BREADY;
  assign BVALID = BVALID_S0 | BVALID_S1 | BVALID_S2;
  assign BRESP = BRESP_S0 | BRESP_S1 | BRESP_S2;
  assign ARREADY = ARREADY_S0 | ARREADY_S1 | ARREADY_S2;
  assign RVALID = RVALID_S0 | RVALID_S1 | RVALID_S2;
  assign RDATA = RDATA_S0 | RDATA_S1 | RDATA_S2;
  assign RRESP = RRESP_S0 | RRESP_S1 | RRESP_S2;
  assign RREADY_S0 = RREADY;
  assign RREADY_S1 = RREADY;
  assign RREADY_S2 = RREADY;

endmodule