/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 13:35:06
 * @FilePath: /Anfield_SOC/vsrc/Anfield/Balotelli/Pipeline/RegFile.v
 * @Description: 寄存器堆。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module RegFile (
  input Clk,
  input Rst,
  //从Id模块输入的信号
  input [`DataBus] RdWriteData,
  input [`RegFileAddr] RdWriteAddr,
  input RdWriteEnable,
  input [`RegFileAddr] Rs1AddrIn,
  input Rs1ReadEnable,
  input [`RegFileAddr] Rs2AddrIn,
  input Rs2ReadEnable,
  input ExcStopRegfile,
  //输出给Id模块的信号
  output reg [`DataBus] Rs1ReadData,
  output reg [`DataBus] Rs2ReadData
);

  reg [`DataBus] rf [0 : `RegNum - 1];

  `ifdef DebugMode
    //显示rf二进制
    import "DPI-C" function void set_gpr_ptr(input logic [63:0] a []);
    initial set_gpr_ptr(rf);  // rf为通用寄存器的二维数组变量
    
    //记录提交时数据及地址
    reg [`DataBus] rf_en_set [0:2];
    /* verilator lint_off WIDTH */
    always @( * ) begin
      rf_en_set[0] = RdWriteData;
      rf_en_set[1] = RdWriteAddr;
      rf_en_set[2] = RdWriteEnable;
    end
    import "DPI-C" function void get_when_commit(input logic [63:0] a []);
    initial get_when_commit(rf_en_set);
  `endif

  //rd同步写
  always @(posedge Clk) begin
    if(!Rst) begin
      // generate
      //   for (integer i = 0; i < `RegNum; i = i + 1) begin
      //     rf[i] <= `RegZero;
      //   end
      // endgenerate
      rf[0] <= `RegZero;
      rf[1] <= `RegZero;
      rf[2] <= `RegZero;
      rf[3] <= `RegZero;
      rf[4] <= `RegZero;
      rf[5] <= `RegZero;
      rf[6] <= `RegZero;
      rf[7] <= `RegZero;
      rf[8] <= `RegZero;
      rf[9] <= `RegZero;
      rf[10] <= `RegZero;
      rf[11] <= `RegZero;
      rf[12] <= `RegZero;
      rf[13] <= `RegZero;
      rf[14] <= `RegZero;
      rf[15] <= `RegZero;
      rf[16] <= `RegZero;
      rf[17] <= `RegZero;
      rf[18] <= `RegZero;
      rf[19] <= `RegZero;
      rf[20] <= `RegZero;
      rf[21] <= `RegZero;
      rf[22] <= `RegZero;
      rf[23] <= `RegZero;
      rf[24] <= `RegZero;
      rf[25] <= `RegZero;
      rf[26] <= `RegZero;
      rf[27] <= `RegZero;
      rf[28] <= `RegZero;
      rf[29] <= `RegZero;
      rf[30] <= `RegZero;
      rf[31] <= `RegZero;
    end else if (RdWriteEnable && RdWriteAddr != 0 && !ExcStopRegfile) begin                     //0号寄存器始终为0
      rf[RdWriteAddr] <= RdWriteData;
    end
  end

  //rs1异步读，数据前推全部放入FWU模块
  always @( * ) begin
    if(Rs1ReadEnable) Rs1ReadData = rf[Rs1AddrIn];
    else Rs1ReadData = `RegZero;
  end

  //rs2异步读
  always @( * ) begin
    if(Rs2ReadEnable) Rs2ReadData = rf[Rs2AddrIn];
    else Rs2ReadData = `RegZero;
  end

endmodule