/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 16:13:35
 * @FilePath: /Anfield/Balotelli/ALU/Mul/Mul.v
 * @Description: 多周期乘法器。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

`include "./vsrc/defines.v"
module Mul(
  input Clk,
  input Rst,
  //从Ex模块输入的信号
  input [1:0] MulHoldFlagFromEx,
  input [`RegFileAddr] MulWriteAddrToMul,
  input [`DataBus] MulitiplicandFromEx,
  input [`DataBus] MulitiplierFromEx,
  input [6:0] MulOpCodeFromEx,
  input [2:0] MulFunct3FromEx,
  input [6:0] MulFunct7FromEx,
  //输出给Ex模块的信号
  output reg [(`DataWidth * 2) - 1 : 0] ProductToEx,
  output MulHoldEndToEx,                                                    //同样也会传送给Ctrl模块
  output reg [`RegFileAddr] MulWriteAddrToEx,
  output [6:0] MulOpCodeToEx,
  output [2:0] MulFunct3ToEx,
  output [6:0] MulFunct7ToEx
);

  wire [`DataBus] Mulitiplicand;
  wire [`DataBus] Mulitiplier;
  wire [`MulDataBus] Product;
  reg MulitiplicandHighestBit;
  reg MulitiplierHighestBit;
  
  MulPreProcessing MulPreProcessing_RISCV (MulitiplicandFromEx, MulitiplierFromEx,
                                           MulOpCodeFromEx,MulFunct3FromEx, 
                                           MulOpCodeToEx, MulFunct3ToEx,
                                           MulitiplicandHighestBit, MulitiplierHighestBit,
                                           Product, Mulitiplicand, Mulitiplier, ProductToEx);

  //部分积产生
  wire [`DataWidth : 0] PartialProduct0;
  wire [`DataWidth : 0] PartialProduct1;
  wire [`DataWidth : 0] PartialProduct2;
  wire [`DataWidth : 0] PartialProduct3;
  wire [`DataWidth : 0] PartialProduct4;
  wire [`DataWidth : 0] PartialProduct5;
  wire [`DataWidth : 0] PartialProduct6;
  wire [`DataWidth : 0] PartialProduct7;
  wire [`DataWidth : 0] PartialProduct8;
  wire [`DataWidth : 0] PartialProduct9;
  wire [`DataWidth : 0] PartialProduct10;
  wire [`DataWidth : 0] PartialProduct11;
  wire [`DataWidth : 0] PartialProduct12;
  wire [`DataWidth : 0] PartialProduct13;
  wire [`DataWidth : 0] PartialProduct14;
  wire [`DataWidth : 0] PartialProduct15;
  wire [`DataWidth : 0] PartialProduct16;
  wire [`DataWidth : 0] PartialProduct17;
  wire [`DataWidth : 0] PartialProduct18;
  wire [`DataWidth : 0] PartialProduct19;
  wire [`DataWidth : 0] PartialProduct20;
  wire [`DataWidth : 0] PartialProduct21;
  wire [`DataWidth : 0] PartialProduct22;
  wire [`DataWidth : 0] PartialProduct23;
  wire [`DataWidth : 0] PartialProduct24;
  wire [`DataWidth : 0] PartialProduct25;
  wire [`DataWidth : 0] PartialProduct26;
  wire [`DataWidth : 0] PartialProduct27;
  wire [`DataWidth : 0] PartialProduct28;
  wire [`DataWidth : 0] PartialProduct29;
  wire [`DataWidth : 0] PartialProduct30;
  wire [`DataWidth : 0] PartialProduct31;

  GenPP GenPP_64(Mulitiplicand, Mulitiplier, PartialProduct0, PartialProduct1, PartialProduct2, 
                PartialProduct3, PartialProduct4, PartialProduct5, PartialProduct6, PartialProduct7, PartialProduct8, 
                PartialProduct9, PartialProduct10, PartialProduct11, PartialProduct12, PartialProduct13, PartialProduct14, 
                PartialProduct15, PartialProduct16, PartialProduct17, PartialProduct18, PartialProduct19, PartialProduct20, 
                PartialProduct21, PartialProduct22, PartialProduct23, PartialProduct24, PartialProduct25, PartialProduct26, 
                PartialProduct27, PartialProduct28, PartialProduct29, PartialProduct30, PartialProduct31);

  AddPP AddPP_64(Clk, Rst, Mulitiplier, MulHoldFlagFromEx, PartialProduct0, PartialProduct1, PartialProduct2, 
                PartialProduct3, PartialProduct4, PartialProduct5, PartialProduct6, PartialProduct7, PartialProduct8, 
                PartialProduct9, PartialProduct10, PartialProduct11, PartialProduct12, PartialProduct13, PartialProduct14, 
                PartialProduct15, PartialProduct16, PartialProduct17, PartialProduct18, PartialProduct19, PartialProduct20, 
                PartialProduct21, PartialProduct22, PartialProduct23, PartialProduct24, PartialProduct25, PartialProduct26, 
                PartialProduct27, PartialProduct28, PartialProduct29, PartialProduct30, PartialProduct31, Product, MulHoldEndToEx);

  Reg #(1, 1'b0) Reg_MulitiplicandHighestBit (Clk, Rst, Mulitiplicand[63], MulitiplicandHighestBit, (MulHoldFlagFromEx == 2'b01));
  Reg #(1, 1'b0) Reg_MulitiplierHighestBit (Clk, Rst, Mulitiplier[63], MulitiplierHighestBit, (MulHoldFlagFromEx == 2'b01));
  //RdWriteAddr
  reg [`RegFileAddr] MulWriteAddr;

  Reg #(5, 5'b0) Reg_MulWriteAddr (Clk, Rst, MulWriteAddrToMul, MulWriteAddr, (MulHoldFlagFromEx == 2'b01));
  assign MulWriteAddrToEx = MulHoldEndToEx ? MulWriteAddr : 5'b0;

  //OpCode
  reg [6:0] MulOpCode;

  Reg #(7, 7'b0) Reg_MulOpCode (Clk, Rst, MulOpCodeFromEx, MulOpCode, (MulHoldFlagFromEx == 2'b01));
  assign MulOpCodeToEx = MulHoldEndToEx ? MulOpCode: 7'b0;

  //Funct7
  reg [6:0] MulFunct7;

  Reg #(7, 7'b0) Reg_MulFunct7 (Clk, Rst, MulFunct7FromEx, MulFunct7, (MulHoldFlagFromEx == 2'b01));
  assign MulFunct7ToEx = MulHoldEndToEx ? MulFunct7 : 7'b0;

  //Funct3
  reg [2:0] MulFunct3;

  Reg #(3, 3'b0) Reg_MulFunct3 (Clk, Rst, MulFunct3FromEx, MulFunct3, (MulHoldFlagFromEx == 2'b01));
  assign MulFunct3ToEx = MulHoldEndToEx ? MulFunct3 : 3'b0;
endmodule
