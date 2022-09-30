/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 11:28:20
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/Interface/AxiLiteMasterInterface.v
 * @Description: 主机端接口，未进行完备的验证。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module AxiLiteMasterInterface ( 
  //input from if or mem
  input ReadEnableIn,
  input WriteEnableIn,
  input [`AddrBus] ReadAddrIn,
  input [`AddrBus] WriteAddrIn,
  input [`DataBus] WriteDataIn,
  input [3:0] WriteMask,
  output reg [`DataBus] ReadDataOut,
  output reg ReadDataReady,
  output WriteDataOver,
  output ReadShakeHands,
  //global 
  input ACLK,
  input ARESETn,
  //write addr channel
  output reg AWVALID,
  output reg [`AddrBus] AWADDR,
  output [2:0] AWPROT,
  input AWREADY,
  //write data channel
  output reg WVALID,
  output reg [`DataBus] WDATA,
  output reg [3:0] WSTRB,
  input WREADY,
  //wire repair channel
  output reg BREADY,
  input BVALID,
  input [2:0] BRESP,
  //read addr channel
  output reg ARVALID,	   								      	                  // 接ReadEnable
  output reg [`AddrBus] ARADDR,
  output [2:0] ARPROT,
  input ARREADY,
  //read data channel
  input RVALID,
  input [`DataBus] RDATA,
  input [2:0] RRESP,
  output reg RREADY
);

  assign AWPROT = 3'b000;
  assign ARPROT = 3'b000;

  //---------------------------------------write---------------------------------------//
  //write addr
  localparam WriteAddrIdel = 3'b001;
  localparam WriteAddrReady = 3'b010;
  localparam WriteAddrRet = 3'b100;
  reg [2:0] WriteAddrCurrentState;
  reg [2:0] WriteAddrNextState;
  // reg [`AddrBus] WriteAddrStore;

  // always @(posedge ACLK) begin
  //   if(!ARESETn) begin
  //     WriteAddrStore <= `RegZero;
  //   end else if(WriteEnableIn) begin
  //     WriteAddrStore <= WriteAddrIn;
  //   end
  // end

  always @(posedge ACLK) begin
    if(!ARESETn) begin
	    WriteAddrCurrentState <= WriteAddrIdel;
	  end else begin
      WriteAddrCurrentState <= WriteAddrNextState;
	  end
  end
  always @( * ) begin
    case (WriteAddrCurrentState)
      WriteAddrIdel : begin
        if(WriteEnableIn) begin
          WriteAddrNextState = WriteAddrRet;
        end else begin
          WriteAddrNextState = WriteAddrIdel;
        end
      end
      // WriteAddrReady : begin
      //   WriteAddrNextState = WriteAddrRet;
      // end
      WriteAddrRet : begin
        if(AWVALID && AWREADY) begin
          WriteAddrNextState = WriteAddrIdel;
        end else begin
          WriteAddrNextState = WriteAddrRet;
        end
      end
      default : begin
        WriteAddrNextState = WriteAddrIdel;
      end
    endcase
  end
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      AWVALID <= 1'b0;
      AWADDR <= `RegZero;
    end else begin
      case (WriteAddrCurrentState)
        WriteAddrIdel : begin
          if(WriteEnableIn) begin
            AWVALID <= 1'b1;
            AWADDR <= WriteAddrIn;
          end else begin
            AWVALID <= 1'b0;
            AWADDR <= `RegZero;
          end
        end
        // WriteAddrReady : begin
        //   AWVALID <= 1'b1;
        //   AWADDR <= WriteAddrStore;
        // end
        WriteAddrRet : begin
          if(AWVALID && AWREADY) begin
            AWVALID <= 1'b0;
            AWADDR <= `RegZero;
          end
        end
        default : begin
          AWVALID <= 1'b0;
          AWADDR <= 64'b0;
        end
      endcase
    end
  end

  //Write Data
  reg [2:0] WriteDataCurrentState;
  reg [2:0] WriteDataNextState;
  localparam WriteDataIdel = 3'b001;
  localparam WriteDataReady = 3'b010;
  localparam WriteDataRet = 3'b100;
  // reg [`DataBus] WriteDataStore;
  // reg [3 : 0] WriteStrbStore;

  // always @(posedge ACLK) begin
  //   if(!ARESETn) begin
  //     WriteDataStore <= `RegZero;
  //   end else if(WriteEnableIn) begin
  //     WriteDataStore <= WriteDataIn;
  //   end
  // end

  // always @(posedge ACLK) begin
  //   if(!ARESETn) begin
  //     WriteStrbStore <= 4'h0;
  //   end else if(WriteEnableIn) begin
  //     WriteStrbStore <= WriteMask;
  //   end
  // end

  always @(posedge ACLK) begin
    if(!ARESETn) begin
      WriteDataCurrentState <= WriteDataIdel;
    end else begin
      WriteDataCurrentState <= WriteDataNextState;
    end
  end
  always @( * ) begin
    case  (WriteDataCurrentState)
      WriteDataIdel : begin
        if(WriteEnableIn) begin
          WriteDataNextState = WriteDataRet;
        end else begin
          WriteDataNextState = WriteDataIdel;
        end
      end
      // WriteDataReady : begin
      //   WriteDataNextState = WriteDataRet;
      // end 
      WriteDataRet : begin
        if(WVALID && WREADY) begin
          WriteDataNextState = WriteDataIdel;
        end else begin
          WriteDataNextState = WriteDataRet;
        end
      end
      default : begin
        WriteDataNextState = WriteDataIdel;
      end
    endcase
  end
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      WVALID <= 1'b0;
      WDATA <= `RegZero;
      WSTRB <= 4'h0;
    end else begin
      case (WriteDataCurrentState)
        WriteDataIdel : begin
          if(WriteEnableIn) begin
            WVALID <= 1'b1;
            WDATA <= WriteDataIn;
            WSTRB <= WriteMask;
          end else begin
            WVALID <= 1'b0;
            WDATA <= `RegZero;
            WSTRB <= 4'h0;
          end
        end
        // WriteDataReady : begin
        //   WVALID <= 1'b1;
        //   WDATA <= WriteDataStore;
        //   WSTRB <= WriteStrbStore;
        // end
        WriteDataRet : begin
          if(WVALID && WREADY) begin
            WVALID <= 1'b0;
            WDATA <= `RegZero;
            WSTRB <= 4'h0;
          end
        end
        default : begin
          WVALID <= 1'b0;
          WDATA <= 64'b0;
          WSTRB <= 4'b0;
        end
      endcase
    end
  end
  
  //write response 阻塞式写，因此always ready
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      BREADY <= 1'b1;
    end else if(BVALID) begin
      BREADY <= 1'b0;
    end else begin
      BREADY <= 1'b1;
    end
  end

  assign WriteDataOver = (BRESP == 3'b111);

  //----------------------------------------read---------------------------------------//
  parameter ReadAddrIdel = 2'b01;
  parameter ReadAddrReady = 2'b10;
  parameter ReadAddrRet = 2'b11;
  reg [1:0] ReadAddrCurrentState;
  reg [1:0] ReadAddrNextState;
  // reg [`AddrBus] ReadAddrStore;

  assign ReadShakeHands = ReadDataReady;

  // always @(posedge ACLK) begin
  //   if(!ARESETn) begin
  //     ReadAddrStore <= `PcInit;
  //   end else if(ReadEnableIn) begin
  //     ReadAddrStore <= ReadAddrIn;
  //   end
  // end

  //read addr
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      ReadAddrCurrentState <= ReadAddrIdel;
    end else begin
      ReadAddrCurrentState <= ReadAddrNextState;
    end 
  end

  always @( * ) begin
    case (ReadAddrCurrentState)
      ReadAddrIdel : begin
        if(ReadEnableIn) begin
          ReadAddrNextState = ReadAddrRet;
        end else begin
          ReadAddrNextState = ReadAddrIdel;
        end
      end
      // ReadAddrReady : begin
      //   ReadAddrNextState = ReadAddrRet;
      // end 
      ReadAddrRet : begin
        if(ARREADY && ARVALID) begin
          ReadAddrNextState = ReadAddrIdel;
        end else begin
          ReadAddrNextState = ReadAddrRet;
        end
      end
      default : begin
        ReadAddrNextState = ReadAddrIdel;
      end
    endcase
  end

  always @(posedge ACLK) begin
    if(!ARESETn) begin
      ARVALID <= 1'b0;
      ARADDR <= `RegZero;
    end else begin
      case (ReadAddrCurrentState) 
        ReadAddrIdel : begin
          if(ReadEnableIn) begin
            ARVALID <= 1'b1;
            ARADDR <= ReadAddrIn;
          end else begin
            ARVALID <= 1'b0;
            ARADDR <= `RegZero;
          end
        end
        // ReadAddrReady : begin
        //   ARVALID <= 1'b1;
        //   ARADDR <= ReadAddrStore;
        // end 
        ReadAddrRet : begin
          if(ARVALID && ARREADY) begin
            ARVALID <= 1'b0;
            ARADDR <= `RegZero;
          end 
        end
        default : begin
          ARVALID <= 1'b0;
          ARADDR <= 64'b0;
        end 
      endcase
    end 
  end   

  //读data channel
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      ReadDataOut <= `RegZero;
      ReadDataReady <= 1'b0;
    end else if(RVALID && RREADY) begin
      ReadDataOut <= RDATA;
      ReadDataReady <= 1'b1;
    end else begin
      ReadDataOut <= `RegZero;
      ReadDataReady <= 1'b0;
    end
  end 

  // assign ReadDataReady = RVALID && RREADY;

  // data channel状态机
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      RREADY <= 1'b1;
    end else if(RVALID) begin
      RREADY <= 1'b0;
    end else begin
      RREADY <= 1'b1;
    end
  end


endmodule
