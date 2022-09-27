/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:43:29
 * @FilePath: /Anfield/Memory/Ram.v
 * @Description: 该模块对双口Ram进行封装，以实现64bit的双口Ram可以实现，低8bit、16bit、32bit写操作。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module Ram (
  // Global
  input ACLK,
  input ARESETn,
  // From BusMatrix
  input [`AddrBus] RamWriteAddr,
  input [`DataBus] RamWriteData,
  input [3 : 0] RamWriteStrb,
  input [`AddrBus] RamReadAddr,
  // To BusMatrix
  output reg [`DataBus] RamReadData,
  output reg RamReadReady,
  output reg RamWriteReady
);

  //实现Ram掩码存储，当掩码有效时先从双口Ram中读取数据再将数据写入
  reg [`AddrBus] WAddr;
  reg [`AddrBus] RAddr;
  reg [`DataBus] WData;
  reg [`DataBus] RData;
  reg WEnc;
  reg REnc;
  
  reg RamOk;
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      RamOk <= 1'b0;
    end else begin
      RamOk <= REnc;
    end
  end

  wire WriteEnable = (RamWriteAddr != 64'h0);
  wire ReadEnable = (RamReadAddr != 64'h0);

  localparam RamIdel = 3'b000;
  localparam RamRead = 3'b001;
  localparam RamWriteOneByte = 3'b010;
  localparam RamWriteTwoByte = 3'b100;
  localparam RamWriteFourByte = 3'b110;
  localparam RamWriteFull = 3'b011;
  localparam RamWrite = 3'b101;
  localparam RamRet = 3'b111;
  reg [2 : 0] RamCurrentState;
  reg [2 : 0] RamNextState;

  reg [`AddrBus] ReadAddrStore;
  reg [`AddrBus] WriteAddrStore;
  reg [`DataBus] WriteDataStore;
  // FSM，使用多周期先读后写，实现对双口Ram的非对齐写操作
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      WriteAddrStore <= `RegZero;
      WriteDataStore <= `RegZero;
    end else if(WriteEnable) begin
      WriteAddrStore <= RamWriteAddr;
      WriteDataStore <= RamWriteData;
    end
  end
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      ReadAddrStore <= `RegZero;
    end else if(ReadEnable) begin
      ReadAddrStore <= RamReadAddr;
    end
  end

  always @(posedge ACLK) begin
    if(!ARESETn) begin
      RamCurrentState <= RamIdel;  
    end else begin
      RamCurrentState <= RamNextState;
    end
  end
  always @( * ) begin
    case (RamCurrentState)
      RamIdel : begin
        case ({WriteEnable, ReadEnable}) 
          2'b01 : begin
            RamNextState = RamRead;
          end
          2'b10 : begin
            case (RamWriteStrb)
              4'h1 : begin
                RamNextState = RamWriteOneByte;
              end
              4'h2 : begin
                RamNextState = RamWriteTwoByte;
              end
              4'h4 : begin
                RamNextState = RamWriteFourByte;
              end
              4'h8 : begin
                RamNextState = RamWriteFull;
              end
              default : begin
                RamNextState = RamIdel;
              end
            endcase
          end
          default : begin
            RamNextState = RamIdel;
          end
        endcase   
      end
      RamWriteOneByte : begin
        if(RamOk) begin
          RamNextState = RamWrite;
        end else begin
          RamNextState = RamWriteOneByte;
        end
      end
      RamWriteTwoByte : begin
        if(RamOk) begin
          RamNextState = RamWrite;
        end else begin
          RamNextState = RamWriteTwoByte;
        end
      end
      RamWriteFourByte : begin
        if(RamOk) begin
          RamNextState = RamWrite;
        end else begin
          RamNextState = RamWriteFourByte;
        end
      end
      RamRead : begin
        if(RamOk) begin
          RamNextState = RamIdel;
        end else begin
          RamNextState = RamRead;
        end
      end
      RamWrite, RamWriteFull : begin
        RamNextState = RamIdel;
      end
      default : begin
        RamNextState = RamIdel;
      end
    endcase
  end
  always @(posedge ACLK) begin
    if(!ARESETn) begin
      RAddr <= `RegZero;
      REnc <= 1'b0;
      WData <= `RegZero;
      WEnc <= 1'b0;
      WAddr <= `RegZero;
      WData <= `RegZero;
      RamWriteReady <= 1'b0;
      RamReadData <= `RegZero;
      RamReadReady <= 1'b0;
    end else begin
      case (RamCurrentState)
        RamIdel : begin
          case ({WriteEnable, ReadEnable}) 
            2'b01 : begin
              RAddr <= RamReadAddr;
              REnc <= 1'b1;
              WData <= `RegZero;
              WEnc <= 1'b0;
              WAddr <= `RegZero;
              RamWriteReady <= 1'b0;
              RamReadData <= `RegZero;
              RamReadReady <= 1'b0;
            end
            2'b10 : begin
                case (RamWriteStrb)
                  4'h1, 4'h2, 4'h4 : begin
                    RAddr <= RamWriteAddr;
                    REnc <= 1'b1;
                    WData <= RamWriteData;
                    WEnc <= 1'b0;
                    WAddr <= `RegZero;
                    RamWriteReady <= 1'b0;
                    RamReadData <= `RegZero;
                    RamReadReady <= 1'b0;
                  end
                  4'h8 : begin
                    RAddr <= `RegZero;
                    REnc <= 1'b0;
                    WData <= RamWriteData;
                    WEnc <= 1'b1;
                    WAddr <= RamWriteAddr;
                    RamWriteReady <= 1'b0;
                    RamReadData <= `RegZero;
                    RamReadReady <= 1'b0;
                  end
                  default : begin
                    RAddr <= 'x;
                    REnc <= 1'x;
                    WData <= 'x;
                    WEnc <= 1'x;
                    WAddr <= 'x;
                    RamWriteReady <= 1'x;
                    RamReadData <= 'x;
                    RamReadReady <= 1'x;
                  end
                endcase
            end
            default : begin
              RAddr <= 'x;
              REnc <= 1'x;
              WData <= 'x;
              WEnc <= 1'x;
              WAddr <= 'x;
              RamWriteReady <= 1'x;
              RamReadData <= 'x;
              RamReadReady <= 1'x;
            end
            endcase   
        end
        RamRead : begin
          RAddr <= `RegZero;
          REnc <= 1'b0;
          WData <= `RegZero;
          WEnc <= 1'b0;
          WAddr <= `RegZero;
          if(RamOk) begin
            RamReadData <= RData;
            RamReadReady <= 1'b1;
          end else begin
            RamReadData <= `RegZero;
            RamReadReady <= 1'b0;
          end
          RamWriteReady <= 1'b0;
        end
        RamWriteOneByte : begin
          RAddr <= `RegZero;
          REnc <= 1'b0;
          if(RamOk) begin
            WAddr <= WriteAddrStore;
            WData <= {RData[63 : 8], WriteDataStore[7 : 0]};
            WEnc <= 1'b1;
          end else begin
            WAddr <= RAddr;
            WData <= `RegZero;
            WEnc <= 1'b0;
          end
          RamReadData <= `RegZero;
          RamWriteReady <= 1'b0;
          RamReadReady <= 1'b0;
        end
        RamWriteTwoByte : begin
          RAddr <= `RegZero;
          REnc <= 1'b0;
          if(RamOk) begin
            WAddr <= WriteAddrStore;
            WData <= {RData[63 : 16], WriteDataStore[15 : 0]};
            WEnc <= 1'b1;
          end else begin
            WAddr <= RAddr;
            WData <= `RegZero;
            WEnc <= 1'b0;
          end
          RamReadData <= `RegZero;
          RamWriteReady <= 1'b0;
          RamReadReady <= 1'b0;
        end
        RamWriteFourByte : begin
          RAddr <= `RegZero;
          REnc <= 1'b0;
          if(RamOk) begin
            WAddr <= WriteAddrStore;
            WData <= {RData[63 : 32], WriteDataStore[31 : 0]};
            WEnc <= 1'b1;
          end else begin
            WAddr <= RAddr;
            WData <= `RegZero;
            WEnc <= 1'b0;
          end
          RamReadData <= `RegZero;
          RamWriteReady <= 1'b0;
          RamReadReady <= 1'b0;
        end
        RamWriteFull, RamWrite : begin
          RAddr <= `RegZero;
          REnc <= 1'b0;
          WAddr <= `RegZero;
          WData <= `RegZero;
          WEnc <= 1'b0;
          RamWriteReady <= 1'b1;
          RamReadData <= `RegZero;
          RamReadReady <= 1'b0;
        end
        default : begin
          RAddr <= `RegZero;
          REnc <= 1'b0;
          WAddr <= `RegZero;
          WData <= `RegZero;
          WEnc <= 1'b0;
          RamWriteReady <= 1'b0;
          RamReadData <= `RegZero;
          RamReadReady <= 1'b0;
        end
      endcase
    end
  end

  DualPortRam #(
    .Deepth(32'h8fff_ffff),
    .Ground(32'h8000_0000)
  )
  Soc_Ram (
     .WClk(ACLK),
     .WData(WData),
     .WAddr(WAddr[31 : 0]),
     .WEnc(WEnc),
     .RClk(ACLK),
     .RData(RData),
     .RAddr(RAddr[31 : 0]),
     .REnc(REnc)
  );

endmodule