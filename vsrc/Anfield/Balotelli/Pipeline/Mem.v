/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 16:04:42
 * @FilePath: /Anfield/Balotelli/Pipeline/Mem.v
 * @Description: 访存级。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module Mem (
  input Clk,
  input Rst,
  //从Ex2Mem模块输入的信号
  input [`DataBus] RdWriteDataIn,
  input [`RegFileAddr] RdAddrIn,
  input RdWriteEnableIn,
  input [`DataBus] ImmIn,
  input [6:0] OpCodeIn,
  input [2:0] Funct3In,
  input [`DataBus] Rs1ReadDataIn,
  input [`DataBus] Rs2ReadDataIn,
  input RamReadReady,
  //输出给Mem2Wb模块的信号
  output [`DataBus] RdWriteDataOut,
  output [`RegFileAddr] RdAddrOut,
  output RdWriteEnableOut,
  //load or store
  output [`AddrBus] RaddrOut,
  output [`AddrBus] WaddrOut,
  output [`DataBus] MemDataOut,
  output [3:0] Wmask,
  input [`DataBus] MemDataIn,
  /*******************INT*****************/
  input [`InstAddrBus] InstAddrIn,
  input [`DataBus] CsrWriteDataIn,
  input [11:0] CsrWriteAddrIn,
  input CsrWriteEnableIn,
  input [`DataBus] ExcInfoIn,
  output [`DataBus] ExcInfoOut,
  output [`InstAddrBus] InstAddrOut,
  output [`DataBus] CsrWriteDataOut,
  output [11:0] CsrWriteAddrOut,
  output CsrWriteEnableOut
);

  wire [`DataBus] MemTypeData;
  wire [`AddrBus] LoadTypeAddr;
  wire [`AddrBus] StoreTypeAddr;
  wire [`DataBus] StoreTypeData;
  wire [3:0] StoreTypeMask;

  assign InstAddrOut = InstAddrIn;
  assign ExcInfoOut = ExcInfoIn;
  assign CsrWriteDataOut = CsrWriteDataIn;
  assign CsrWriteAddrOut = CsrWriteAddrIn;
  assign CsrWriteEnableOut = CsrWriteEnableIn;

  //对齐和非对齐需要硬件实现
  assign ExcInfoOut = ExcInfoIn;

  reg [2 : 0] Funct3Store;
  always @(posedge Clk) begin
    if(!Rst) begin
      Funct3Store <= 3'h0;
    end else if(RdAddrIn != 5'h00) begin
      Funct3Store <= Funct3In;
    end
  end

  wire [`DataBus] RdWriteDataOutInside;
  assign RdWriteDataOut  = RdWriteDataOutInside | MemTypeData;
  MuxKeyWithDefault #(1, 7, 64) RdWriteData_mux (RdWriteDataOutInside, OpCodeIn, RdWriteDataIn, {
    //Load
    7'b0000011, MemTypeData
  });

  MuxKeyWithDefault #(7, 3, 64) MemTypeData_mux (MemTypeData, Funct3Store, 64'b0, {
    //Ld
    3'b011, MemDataIn,
    //Lw
    3'b010, {{32{MemDataIn[31]}}, MemDataIn[31:0]},
    //Lh
    3'b001, {{48{MemDataIn[31]}}, MemDataIn[15:0]},
    //Lb
    3'b000, {{56{MemDataIn[31]}}, MemDataIn[7:0]},
    //Lbu
    3'b100, {{56{1'b0}}, MemDataIn[7:0]},
    //Lhu
    3'b101, {{48{1'b0}}, MemDataIn[15:0]},
    //Lwu
    3'b110, {{32{1'b0}}, MemDataIn[31:0]}
  });

  MuxKeyWithDefault #(1, 7, 64) MemRAddr_mux (RaddrOut, OpCodeIn, 64'b0, {
    //Load
    7'b0000011, LoadTypeAddr
  });

  MuxKeyWithDefault #(7, 3, 64) LoadTypeAddr_mux (LoadTypeAddr, Funct3In, 64'b0, {
    //Ld
    3'b011, Rs1ReadDataIn + ImmIn,
    //Lw
    3'b010, Rs1ReadDataIn + ImmIn,
    //Lh
    3'b001, Rs1ReadDataIn + ImmIn,
    //Lb
    3'b000, Rs1ReadDataIn + ImmIn,
    //Lbu
    3'b100, Rs1ReadDataIn + ImmIn,
    //Lhu
    3'b001, Rs1ReadDataIn + ImmIn,
    //Lwu
    3'b110, Rs1ReadDataIn + ImmIn
  });

  MuxKeyWithDefault #(1, 7, 64) MemWAddr_mux (WaddrOut, OpCodeIn, 64'b0, {
    //Store
    7'b0100011, StoreTypeAddr
  });

  MuxKeyWithDefault #(4, 3, 64) StoreTypeAddr_mux (StoreTypeAddr, Funct3In, 64'b0, {
    //Sd
    3'b011, Rs1ReadDataIn + ImmIn, 
    //Sw
    3'b010, Rs1ReadDataIn + ImmIn,
    //Sh
    3'b001, Rs1ReadDataIn + ImmIn,
    //Sb
    3'b000, Rs1ReadDataIn + ImmIn
  });

  MuxKeyWithDefault #(1, 7, 64) MemWData_mux (MemDataOut, OpCodeIn, 64'b0, {
    //Store
    7'b0100011, StoreTypeData
  });

  MuxKeyWithDefault #(4, 3, 64) StoreTypeData_mux (StoreTypeData, Funct3In, 64'b0, {
    //Sd
    3'b011, Rs2ReadDataIn,
    //Sw
    3'b010, Rs2ReadDataIn,
    //Sh
    3'b001, Rs2ReadDataIn,
    //Sb
    3'b000, Rs2ReadDataIn
  });

  MuxKeyWithDefault #(1, 7, 4) MemMask_mux (Wmask, OpCodeIn, 4'b0, {
    //Store
    7'b0100011, StoreTypeMask
  });

  //Mask output
  MuxKeyWithDefault #(4, 3, 4) StoreTypeMask_mux (StoreTypeMask, Funct3In, 4'b0, {
    //Sd
    3'b011, 4'b1000,
    //Sw
    3'b010, 4'b0100,
    //Sh
    3'b001, 4'b0010,
    //Sb
    3'b000, 4'b0001
  });

 //按设计美学来看，应该扔出去
  reg [`RegFileAddr] RdAddrStore;
  always @(posedge Clk) begin
    if(!Rst) begin
      RdAddrStore <= 5'h00;
    end else if(RdAddrIn != 5'h00) begin
      RdAddrStore <= RdAddrIn;
    end
  end

  wire RdWriteEnableOutInside;
  assign RdWriteEnableOut = RdWriteEnableOutInside | RamReadReady;
  //避免数据前推时，将未load的数据前推
  MuxKeyWithDefault #(1, 7, 1) RdWriteEnable_mux (RdWriteEnableOutInside, OpCodeIn, RdWriteEnableIn, {
    //Load
    7'b0000011, 1'b0
  });

  wire [`RegFileAddr] RdAddr = (RamReadReady ? RdAddrStore : 5'h00);
  assign RdAddrOut = RdAddrIn | RdAddr;

  // MuxKeyWithDefault #(1, 7, 5) RdWriteAddr_mux (RdAddrOut, OpCodeIn, RdAddrIn, {
  //   //Load
  //   7'b0000011, (RamReadReady ? RdAddrStore : 5'h00)
  // });

endmodule