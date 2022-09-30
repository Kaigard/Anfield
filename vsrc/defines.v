/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-27 14:47:25
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-28 21:02:14
 * @FilePath: /Anfield_SOC/vsrc/defines.v
 * @Description: 全局宏定义及运行模式选择
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


//Bus
`define AddrBus 63:0
`define DataBus 63:0
`define InstBus 63:0
`define InstAddrBus 63:0
`define AluBus 31:0
`define HalfDataBus 31:0
`define HoldFlagBus 2:0
`define MulDataBus 127:0
`define HighMulDataBus 127:64
`define IntBus 5:0

//
`define AddrRegWidth 64
`define InstRegWidth 64
`define DataWidth 64
`define RegFileAddrWidth 5
`define RegFileAddr 4:0

//Init
`define RegZero 64'h0
`define AddrRegInit 64'h0
`define InstRegInit 64'h0
`define RegAddrInit 5'b0
`define DataRegInit 64'h0
`define MulSumZero 128'h0

//Pc module
`define PcInit 64'h0000_0000_8000_0000

//RegFile
`define RegNum 32

//Modechoose
 `define DebugMode 1
`define CpuTestsMode 1

//Mul
//First level
`define DataWidth_CSA10 70
`define DataWidth_CSA11 72
`define DataWidth_CSA12 72
`define DataWidth_CSA13 72
`define DataWidth_CSA14 72
`define DataWidth_CSA15 72
`define DataWidth_CSA16 72
`define DataWidth_CSA17 72
//Second level
`define DataWidth_CSA20 78
`define DataWidth_CSA21 80
`define DataWidth_CSA22 80
`define DataWidth_CSA23 80
//Third level
`define DataWidth_CSA30 94
`define DataWidth_CSA31 96
//Forth level
`define DataWidth_CSA40 126
//Fiveth level
`define DataWidth_CSA50 128
 






