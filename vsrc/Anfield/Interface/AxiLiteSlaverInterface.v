/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-29 10:08:23
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/Interface/AxiLiteSlaverInterface.v
 * @Description: 从机端接口。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module AxiLiteSlaverInterface (
  //from ram or rom
  input [`DataBus] ReadDataIn,
  output reg [`AddrBus] ReadAddrOut,
  output reg ReadEnableOut,
  output reg [`AddrBus] WriteAddrOut,
  output reg [`DataBus] WriteDataOut,
  output reg WriteEnableOut,
  output reg [3 : 0] WriteStrb,
  input SlaverReadReady,
  input SlaverWriteReady,
  //global 
  input ACLK,
  input ARESETn,
  //write addr channel
  input AWVALID,
  input [`AddrBus] AWADDR,
  input [2:0] AWPROT,
  output reg AWREADY,
  //write data channel
  input WVALID,
  input [`DataBus] WDATA,
  input [3:0] WSTRB,
  output reg WREADY,
  //wire repair channel
  input BREADY,
  output reg BVALID,
  output reg [2:0] BRESP,
  //read addr channel
  input ARVALID,
  input [`AddrBus] ARADDR,
  input [2:0] ARPROT,
  output reg ARREADY,
  //read data channel
  output reg RVALID,
  output reg [`DataBus] RDATA,
  output reg [2:0] RRESP,
  input RREADY
);

  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  AWREADY <= 1'b1;
	end else if(AWVALID) begin
	  AWREADY <= 1'b0;
	end else begin
	  AWREADY <= 1'b1;
	end
  end

  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  WREADY <= 1'b1;
	end else if(WVALID) begin
	  WREADY <= 1'b0;
	end else begin
	  WREADY <= 1'b1;
	end
  end

  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  WriteAddrOut <= `RegZero;
	  WriteEnableOut <= 1'b0;
	end else if(AWVALID && AWREADY) begin
	  WriteAddrOut <= AWADDR;
	  WriteEnableOut <= 1'b1;
	end else begin
	  WriteAddrOut <= `RegZero;
	  WriteEnableOut <= 1'b0;
	end
  end 

  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  WriteDataOut <= `RegZero;
	  WriteStrb <= 4'h0;
	end else if(WVALID && WREADY) begin
	  WriteDataOut <= WDATA;
	  WriteStrb <= WSTRB;
	end else begin
	  WriteDataOut <= `RegZero;
	  WriteStrb <= 4'h0;
	end
  end 

  //WriteResponse channel状态机
  parameter WriteResponseIdel = 2'b01;
  parameter WriteResponseReady = 2'b10;
  parameter WriteResponseRet = 2'b11;
  reg [1 : 0] WriteResponseCurrentState;
  reg [1 : 0] WriteResponseNextState;
  reg [`DataBus] WriteResponseStore;

  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  WriteResponseCurrentState <= WriteResponseIdel;
	end else begin
	  WriteResponseCurrentState <= WriteResponseNextState;
	end
  end
  always @( * ) begin
	case (WriteResponseCurrentState)
	  WriteResponseIdel : begin
		//Slaver readready or writeready已经包含了前后依赖关系  
		if(SlaverWriteReady) begin
		  WriteResponseNextState = WriteResponseReady;
		end else begin
		  WriteResponseNextState = WriteResponseIdel;
		end
	  end
	  WriteResponseReady : begin
		WriteResponseNextState = WriteResponseRet;
	  end
	  WriteResponseRet : begin
		if(BVALID && BREADY) begin
		  WriteResponseNextState = WriteResponseIdel;
		end else begin
		  WriteResponseNextState = WriteResponseRet;
		end
	  end
	  default : begin
	    WriteResponseNextState = WriteResponseIdel;
	  end
	endcase
  end
  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  BRESP <= 3'b000;
	  BVALID <= 1'b0;
	end else begin
	  case (WriteResponseCurrentState)
		WriteResponseIdel : begin
		  BRESP <= 3'b000;
	  	  BVALID <= 1'b0;
		end
		WriteResponseReady : begin
		  BRESP <= 3'b111;	//need change
	  	  BVALID <= 1'b1;
		end
		WriteResponseRet : begin
		  if(BVALID && BREADY) begin
			BRESP <= 3'b000;
			BVALID <= 1'b0;
		  end
		end
		default : begin
		  BRESP <= 3'b0;
		  BVALID <= 1'b0;
		end
	  endcase
	end
  end

  //************************************ read ***************************************
  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  ARREADY <= 1'b1;
	end else if(ARVALID) begin
	  ARREADY <= 1'b0;
	end else begin
	  ARREADY <= 1'b1;
	end
  end

  //读addr channel 状态机
  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  ReadAddrOut <= `RegZero;
	  ReadEnableOut <= 1'b0;
	end else if(ARREADY && ARVALID) begin
	  ReadAddrOut <= ARADDR;
	  ReadEnableOut <= 1'b1;
	end else begin
	  ReadAddrOut <= `RegZero;
	  ReadEnableOut <= 1'b0;
	end
  end 

  //读addr channel状态机
  parameter ReadDataIdel = 2'b01;
  parameter ReadDataReady = 2'b10;
  parameter ReadDataRet = 2'b11;
  reg [1:0] ReadDataCurrentState;
  reg [1:0] ReadDataNextState;
  reg [`DataBus] ReadDataStore;

  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  ReadDataStore <= `RegZero;
	end else if(SlaverReadReady) begin
	  ReadDataStore <= ReadDataIn;
	end
  end 
  
  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  ReadDataCurrentState <= ReadDataIdel;
	end else begin
	  ReadDataCurrentState <= ReadDataNextState;
	end
  end
  
  always @( * ) begin
	case (ReadDataCurrentState)
	  ReadDataIdel : begin
		if(SlaverReadReady) begin
		  ReadDataNextState = ReadDataReady;
		end else begin
		  ReadDataNextState = ReadDataIdel;
		end
	  end 
	  ReadDataReady : begin
		ReadDataNextState = ReadDataRet;
	  end 
	  ReadDataRet : begin
		if(RREADY && RVALID) begin
		  ReadDataNextState = ReadDataIdel;
		end else begin
		  ReadDataNextState = ReadDataRet;
		end
	  end
	  default : begin
		ReadDataNextState = ReadDataIdel;
	  end
	endcase
  end

  always @(posedge ACLK) begin
	if(!ARESETn) begin
	  RVALID <= 1'b0;
	  RDATA <= `RegZero;
	end else begin
	  case (ReadDataCurrentState)
	  	ReadDataIdel : begin
		  RVALID <= 1'b0;
		  RDATA <= `RegZero;
		end
		ReadDataReady : begin
		  RVALID <= 1'b1;
		  RDATA <= ReadDataStore;
		end
		ReadDataRet : begin
		  if(RVALID && RREADY) begin
		    RVALID <= 1'b0;
			RDATA <= `RegZero;
		  end
		end
		default : begin
		  RVALID <= 1'b0;
		  RDATA <= 64'b0;
		end
	  endcase
	end
  end 

endmodule
