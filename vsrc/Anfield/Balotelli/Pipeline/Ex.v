/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:55:28
 * @FilePath: /Anfield/Balotelli/Pipeline/Ex.v
 * @Description: 执行级
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


`include "./vsrc/defines.v"
module Ex (
  //从Id2Ex模块输入的信号
  input [`AddrBus] InstAddrIn,
  input [`RegFileAddr] RdAddrIn,
  input RdWriteEnableIn,
  input [`DataBus] Rs1ReadDataIn,
  input [`DataBus] Rs2ReadDataIn,
  input [`DataBus] ImmIn,
  input [6:0] OpCodeIn,
  input [2:0] Funct3In,
  input [6:0] Funct7In,
  input [5:0] ShamtIn,
  //从Mul和Div模块输入的信号
  input MulHoldEndToEx,                                            //Mul运算截止信号
  input DivHoldEndToEx,                                            //Div运算截止信号
  input [`RegFileAddr] MulWriteAddrToEx,                           //将RdWriteAddr随Mul保存7个时钟周期
  input [`RegFileAddr] DivWriteAddrToEx,                           //将RdWriteAddr随Div保存65个时钟周期
  input [6:0] MulOpCodeToEx,                                       //将OpCode随Mul保存7个时钟周期   
  input [2:0] MulFunct3ToEx,                                       //将Funct3随Mul保存7个时钟周期
  input [6:0] MulFunct7ToEx,                                       //将Funct7随Mul保存7个时钟周期
  input [6:0] DivOpCodeToEx,                                       //将OpCode随Div保存65个时钟周期
  input [2:0] DivFunct3ToEx,                                       //将Funct3随Div保存65个时钟周期
  input [6:0] DivFunct7ToEx,                                       //将Funct7随Div保存65个时钟周期
  input [`MulDataBus] Rs1ReadDataMulRs2ReadData,                   //Mul输出结果
  input [`DataBus] Rs1ReadDataDivRs2ReadData,                      //Div输出结果
  input [`DataBus] Rs1ReadDataRemRs2ReadData,                      //Rem
  //输出给Ctrl模块的信号
  output HoldFlagToCtrl,     
  output [1:0] RVM_HoldFlagOut,                                    //Mul Hold请求还是Div Hold请求
  output JumpFlagToCtrl,                                           //是否跳转标志
  output [`AddrBus] JumpAddrToCtrl,                                //跳转目的地址
  //输出给Mul and Div模块的信号
  // output [`RegFileAddr] RV32M_WriteAddrExOut,
  // output [6:0] RV32M_OpCodeExOut,
  // output [2:0] RV32M_Funct3ExOut,
  // output [6:0] RV32M_Funct7ExOut,
  //输出给Ex2Mem模块的信号
  output reg [`DataBus] RdWriteDataOut,
  output [`RegFileAddr] RdAddrOut,
  output RdWriteEnableOut,
  //Load or Store
  output [`DataBus] ImmOut,
  output [6:0] OpCodeOut,
  output [2:0] Funct3Out,
  output [6:0] Funct7Out,
  output [`DataBus] Rs1ReadDataOut,
  output [`DataBus] Rs2ReadDataOut,
  /**************************INT************************/
  input [`DataBus] ExcInfoIn,
  input [`RegFileAddr] ZimmIn,
  input CsrWriteEnableIn,
  input [`DataBus] CsrReadDataIn,
  input MRetEnableIn,
  output [`InstAddrBus] InstAddrOut,
  output reg [`DataBus] ExcInfoOut,
  output CsrWriteEnableOut,
  output [`DataBus] CsrWriteDataOut,
  output [11:0] CsrWriteAddrOut
  
);

  assign CsrWriteEnableOut = CsrWriteEnableIn;
  assign CsrWriteAddrOut = ImmIn[11:0];
  assign InstAddrOut = InstAddrIn;
  /*****************************************************/
  wire [`DataBus] CsrWriteDataFunct3;
  MuxKeyWithDefault #(1, 7, 64) Id_CsrWriteData_mux (CsrWriteDataOut, OpCodeIn, 64'b0, {
    7'b1110011, CsrWriteDataFunct3
  });
    MuxKeyWithDefault #(6, 3, 64) Id_CsrWriteDataFunct3_mux (CsrWriteDataFunct3, Funct3In, 64'b0, {
      //Csrrc
      3'b011, CsrReadDataIn & ~Rs1ReadDataIn,
      //Csrrs
      3'b010, CsrReadDataIn | Rs1ReadDataIn,
      //Csrrw
      3'b001, Rs1ReadDataIn,
      //Csrrci
      3'b111, CsrReadDataIn & ~{{59{1'b0}}, ZimmIn},
      //Csrrsi
      3'b110, CsrReadDataIn | {{59{1'b0}}, ZimmIn},
      //Csrrwi
      3'b101, {{59{1'b0}}, ZimmIn}
    });

  //Mul or Div模块在进行输出时，Ex模块的所有数据都是被清洗掉的，因此直接使用或逻辑不会产生数据冲突
  assign RdAddrOut = RdAddrIn | MulWriteAddrToEx | DivWriteAddrToEx;
  assign RdWriteEnableOut = RdWriteEnableIn | MulHoldEndToEx | DivHoldEndToEx;

  //阻止非load or store指令传入数据至mem模块
  //阻止非Mul or Div指令传入数据至Mul/Div模块
  MuxKeyWithDefault #(2, 7, 64) Imm_mux (ImmOut, OpCodeIn, 64'b0, {
    7'b0000011, ImmIn,
    7'b0100011, ImmIn
  });
 
  wire [6:0] RV32M_OpCodeAluFunct7Out;
  wire [6:0] RV64M_OpCodeAluFunct7Out;
  wire [2:0] RV32M_Funct3AluFunct7Out;
  wire [2:0] RV64M_Funct3AluFunct7Out;
  wire [6:0] RV32M_Funct7AluFunct7Out;
  wire [6:0] RV64M_Funct7AluFunct7Out;
  wire [`DataBus] RV32M_Rs1ReadDataAluFunct7Out;
  wire [`DataBus] RV64M_Rs1ReadDataAluFunct7Out;
  wire [`DataBus] RV32M_Rs2ReadDataAluFunct7Out;
  wire [`DataBus] RV64M_Rs2ReadDataAluFunct7Out;
  //Opcode
  MuxKeyWithDefault #(4, 7, 7) OpCode_mux (OpCodeOut, OpCodeIn, 7'b0, {
    7'b0000011, OpCodeIn,
    7'b0100011, OpCodeIn,
    //RV32M Alu class
    7'b0110011, RV32M_OpCodeAluFunct7Out,
    //RV64M Alu class
    7'b0111011, RV64M_OpCodeAluFunct7Out
  });
    MuxKeyWithDefault #(1, 7, 7) OpCodeRV32MAluFunct7_mux (RV32M_OpCodeAluFunct7Out, Funct7In, 7'b0, {
      7'b0000001, OpCodeIn
    });
    MuxKeyWithDefault #(1, 7, 7) OpCodeRV64MAluFunct7_mux (RV64M_OpCodeAluFunct7Out, Funct7In, 7'b0, {
      7'b0000001, OpCodeIn
    });
  //Funct3
  MuxKeyWithDefault #(4, 7, 3) Funct3_mux (Funct3Out, OpCodeIn, 3'b0, {
    7'b0000011, Funct3In,
    7'b0100011, Funct3In,
    //RV32M Alu class
    7'b0110011, RV32M_Funct3AluFunct7Out,
    //RV64M Alu class
    7'b0111011, RV64M_Funct3AluFunct7Out
  });
    MuxKeyWithDefault #(1, 7, 3) Funct3RV32MAluFunct7_mux (RV32M_Funct3AluFunct7Out, Funct7In, 3'b0, {
      7'b0000001, Funct3In
    });
    MuxKeyWithDefault #(1, 7, 3) Funct3RV64MAluFunct7_mux (RV64M_Funct3AluFunct7Out, Funct7In, 3'b0, {
      7'b0000001, Funct3In
    });
  //Funct7
  MuxKeyWithDefault #(4, 7, 7) Funct7_mux (Funct7Out, OpCodeIn, 7'b0, {
    7'b0000011, Funct7In,
    7'b0100011, Funct7In,
    //RV32M Alu class
    7'b0110011, RV32M_Funct7AluFunct7Out,
    //RV64M Alu class
    7'b0111011, RV64M_Funct7AluFunct7Out
  });
    MuxKeyWithDefault #(1, 7, 7) Funct7RV32MAluFunct7_mux (RV32M_Funct7AluFunct7Out, Funct7In, 7'b0, {
      7'b0000001, Funct7In
    });
    MuxKeyWithDefault #(1, 7, 7) Funct7RV64MAluFunct7_mux (RV64M_Funct7AluFunct7Out, Funct7In, 7'b0, {
      7'b0000001, Funct7In
    });
  //Rs1ReadData
  MuxKeyWithDefault #(4, 7, 64) Rs1ReadData_mux (Rs1ReadDataOut, OpCodeIn, 64'b0, {
    7'b0000011, Rs1ReadDataIn,
    7'b0100011, Rs1ReadDataIn,
    //RV32M Alu class
    7'b0110011, RV32M_Rs1ReadDataAluFunct7Out,
    //RV64M Alu class
    7'b0111011, RV64M_Rs1ReadDataAluFunct7Out
  });
    MuxKeyWithDefault #(1, 7, 64) Rs1ReadDataRV32MAluFunct7_mux (RV32M_Rs1ReadDataAluFunct7Out, Funct7In, 64'b0, {
      7'b0000001, Rs1ReadDataIn
    });
    MuxKeyWithDefault #(1, 7, 64) Rs1ReadDataRV64MAluFunct7_mux (RV64M_Rs1ReadDataAluFunct7Out, Funct7In, 64'b0, {
      7'b0000001, Rs1ReadDataIn
    });
  //Rs2ReadDatas
  MuxKeyWithDefault #(4, 7, 64) Rs2ReadData_mux (Rs2ReadDataOut, OpCodeIn, 64'b0, {
    7'b0000011, Rs2ReadDataIn,
    7'b0100011, Rs2ReadDataIn,
    //RV32M Alu class
    7'b0110011, RV32M_Rs2ReadDataAluFunct7Out,
    //RV64M Alu class
    7'b0111011, RV64M_Rs2ReadDataAluFunct7Out
  });
    MuxKeyWithDefault #(1, 7, 64) Rs2ReadDataRV32MAluFunct7_mux (RV32M_Rs2ReadDataAluFunct7Out, Funct7In, 64'b0, {
      7'b0000001, Rs2ReadDataIn
    });
    MuxKeyWithDefault #(1, 7, 64) Rs2ReadDataRV64MAluFunct7_mux (RV64M_Rs2ReadDataAluFunct7Out, Funct7In, 64'b0, {
      7'b0000001, Rs2ReadDataIn
    });

  wire [`DataBus] Funct3_RV32I_I_TypeOut;
  wire [`DataBus] Shift_RV32I_Right;
  wire [`DataBus] Shift_RV32I_Left;
  wire [`DataBus] ImmShift = ImmIn << 12;

  wire [`DataBus] Funct7_RV32I_R_TypeOut;
    //Funct7为7'b0000000
    wire [`DataBus] Funct3_RV32I_R_Type_ZeroOut;
    //Funct7为7'b0100000
    wire [`DataBus] Funct3_RV32I_R_Type_OneOut;
    //Funct7为7'b0110011
    wire [`DataBus] Funct3_RV32I_R_Type_SixOut;

  wire [`DataBus] Funct3_RV64I_I_TypeOut;
  wire [`DataBus] Shift_RV64I_Right;
  wire [`DataBus] Shift_RV64I_Left;

  wire [`DataBus] Funct7_RV64I_R_TypeOut;
    //Funct7为7'b0000000
    wire [`DataBus] Funct3_RV64I_R_Type_ZeroOut;
    //Funct7为7'b0100000
    wire [`DataBus] Funct3_RV64I_R_Type_OneOut;

  //DPI-C
  parameter RaiseException_Ebreak = 2'b01;
  parameter RaiseException_Ecall = 2'b10;
  wire [1:0] RaiseException;

  //ALU
    //Addi 使用CLA实现
    wire [`DataBus] ImmAddRs1ReadData;
    CLA_64Bit_Adder CLA_ImmAddRs1ReadData( , ImmAddRs1ReadData, ImmIn, Rs1ReadDataIn, 1'b0);
    //Add 使用CLA实现
    wire [`DataBus] Rs1ReadDataAddRs2ReadData;
    CLA_64Bit_Adder CLA_Rs1ReadDataAddRs2ReadData( , Rs1ReadDataAddRs2ReadData, Rs1ReadDataIn, Rs2ReadDataIn, 1'b0);
    //Sub 使用3_2压缩后再进行CLA加法
    wire [`DataBus] Rs1ReadDataSubRs2ReadData;
    wire [`DataBus] CAS_3_2_SubSum;
    wire [`DataBus] CAS_3_2_SubCarry;
    CasAdder3_2 #(64) CAS3_2_Rs1ReadDataSubRs2ReadData(Rs1ReadDataIn, ~Rs2ReadDataIn, 64'h0000_0000_0000_0001, CAS_3_2_SubSum, CAS_3_2_SubCarry);
    CLA_64Bit_Adder CLA_Rs1ReadDataSubRs2ReadData( , Rs1ReadDataSubRs2ReadData, CAS_3_2_SubSum, CAS_3_2_SubCarry, 1'b0);
    //And
    wire [`DataBus] Rs1ReadDataAndRs2ReadData = Rs1ReadDataIn & Rs2ReadDataIn;
    //Andi
    wire [`DataBus] Rs1ReadDataAndImm = Rs1ReadDataIn & ImmIn;
    //Or
    wire [`DataBus] Rs1ReadDataOrRs2ReadData = Rs1ReadDataIn | Rs2ReadDataIn;
    //Ori
    wire [`DataBus] Rs1ReadDataOrImm = Rs1ReadDataIn | ImmIn;
    //Xor
    wire [`DataBus] Rs1ReadDataXorRs2ReadData = Rs1ReadDataIn ^ Rs2ReadDataIn;
    //Sll
    wire [`DataBus] Rs1ReadDataSllRs2ReadData = Rs1ReadDataIn << Rs2ReadDataIn[5:0];
    //Slli
    wire [`DataBus] Rs1ReadDataSllImm = Rs1ReadDataIn << ShamtIn;
    //Sra
    wire [`DataBus] Rs1ReadDataSraRs2ReadData = Rs1ReadDataIn <<< Rs2ReadDataIn[5:0];
    //Srai
    wire [`DataBus] Rs1ReadDataSraImm = Rs1ReadDataIn >>> ShamtIn;
    //Srl
    wire [`DataBus] Rs1ReadDataSrlRs2ReadData = Rs1ReadDataIn >> Rs2ReadDataIn[5:0];
    //Srli
    wire [`DataBus] Rs1ReadDataSrlImm = Rs1ReadDataIn >> ShamtIn;
    //Sllw
    wire [`HalfDataBus] Rs1ReadDataSllwRs2ReadData = Rs1ReadDataIn[31:0] << Rs2ReadDataIn[4:0];
    //Sraw
    wire [`HalfDataBus] Rs1ReadDataSrawRs2ReadData = Rs1ReadDataIn[31:0] >>> Rs2ReadDataIn[4:0];
    //Srlw
    wire [`HalfDataBus] Rs1ReadDataSrlwRs2ReadData = Rs1ReadDataIn[31:0] >> Rs2ReadDataIn[4:0];

  //RV32I
    //I类型执行模块
    MuxKeyWithDefault #(7, 3, 64) Funct3_RV32_I_Type (Funct3_RV32I_I_TypeOut, Funct3In, 64'b0, {
      //Addi
      3'b000, ImmAddRs1ReadData,
      //Andi
      3'b111, Rs1ReadDataAndImm,
      //Ori
      3'b110, Rs1ReadDataOrImm,
      //Slti
      3'b010, (((Rs1ReadDataIn[63] == 1'b1) && (ImmIn[63] == 1'b0)) ? 64'b1 :
              ((Rs1ReadDataIn[63] == 1'b0) && (ImmIn[63] == 1'b1)) ? 64'b0 :
              (Rs1ReadDataAddRs2ReadData[63] == Rs1ReadDataIn[63]) ? 64'b1 : 64'b0),
      //Sltiu
      3'b011, ((Rs1ReadDataIn < ImmIn) ? 64'b1 : 64'b0),
      //Slli
      3'b001, Shift_RV32I_Left,
      //Srli or srai
      3'b101, Shift_RV32I_Right
    });
      //这里由于译码特殊性，先对Funct3译码再对Funct7译码。 
      MuxKeyWithDefault #(2, 7, 64) Shift_RV32I_Right_mux (Shift_RV32I_Right, Funct7In, 64'b0, {
        7'b0000000, Rs1ReadDataSrlImm,
        7'b0100000, Rs1ReadDataSraImm
      }); 
      MuxKeyWithDefault #(1, 7, 64) Shift_RV32I_Left_mux (Shift_RV32I_Left, Funct7In, 64'b0, {
        7'b0000000, Rs1ReadDataSllImm
      }); 
    
    //R类型执行模块
    MuxKeyWithDefault #(2, 7, 64) Funct7_RV32I_R_Type (Funct7_RV32I_R_TypeOut, Funct7In, 64'b0, {
      //Add or Xor or Or or And or Slt or Sltu or Sll or Srl
      7'b0000000, Funct3_RV32I_R_Type_ZeroOut,
      //Sub or Sra
      7'b0100000, Funct3_RV32I_R_Type_OneOut
    }); 
      //Funct7为7'b0000000
      MuxKeyWithDefault #(8, 3, 64) Funct3_RV32I_R_Type_Zero (Funct3_RV32I_R_Type_ZeroOut, Funct3In, 64'b0, {
        //Add
        3'b000, Rs1ReadDataAddRs2ReadData,
        //Xor
        3'b100, Rs1ReadDataXorRs2ReadData,
        //Or
        3'b110, Rs1ReadDataOrRs2ReadData,
        //And
        3'b111, Rs1ReadDataAndRs2ReadData,
        //Slt
        3'b010, (((Rs1ReadDataIn[63] == 1'b1) && (Rs2ReadDataIn[63] == 1'b0)) ? 64'b1 :
                ((Rs1ReadDataIn[63] == 1'b0) && (Rs2ReadDataIn[63] == 1'b1)) ? 64'b0 :
                (Rs1ReadDataAddRs2ReadData[63] == Rs1ReadDataIn[63]) ? 64'b1 : 64'b0),
        //Sltu
        3'b011, ((Rs1ReadDataIn < Rs1ReadDataIn) ? 64'b1 : 64'b0),
        //Sll
        3'b001, Rs1ReadDataSllRs2ReadData,
        //Srl
        3'b101, Rs1ReadDataSrlRs2ReadData
      });
      //Funct7为7'b0100000
      MuxKeyWithDefault #(2, 3, 64) Funct3_RV32I_R_Type_One (Funct3_RV32I_R_Type_OneOut, Funct3In, 64'b0, {
        //Sub
        3'b000, Rs1ReadDataSubRs2ReadData,
        //Sra
        3'b101, Rs1ReadDataSraRs2ReadData
      });
     
  //RV64I
    //I类型执行模块
    MuxKeyWithDefault #(3, 3, 64) Funct3_RV64I_I_Type (Funct3_RV64I_I_TypeOut, Funct3In, 64'b0, {
      //Addiw
      3'b000, {{32{ImmAddRs1ReadData[31]}}, ImmAddRs1ReadData[31:0]},
      //Slliw
      3'b001, {{32{Shift_RV64I_Left[31]}}, Shift_RV64I_Left[31:0]},
      //Srliw or Sraiw
      3'b101, {{32{Shift_RV64I_Right[31]}}, Shift_RV64I_Right[31:0]}
    });
      //这里由于译码特殊性，先对Funct3译码再对Funct7译码。 
      MuxKeyWithDefault #(2, 7, 64) Shift_RV64I_Right_mux (Shift_RV64I_Right, Funct7In, 64'b0, {
        //Srliw
        7'b0000000, Rs1ReadDataSrlImm,
        //Sraiw
        7'b0100000, Rs1ReadDataSraImm
      }); 
      MuxKeyWithDefault #(1, 7, 64) Shift_RV64I_Left_mux (Shift_RV64I_Left, Funct7In, 64'b0, {
        7'b0000000, Rs1ReadDataSllImm
      }); 

    //R类型执行模块 
    MuxKeyWithDefault #(2, 7, 64) Funct7_RV64I_R_Type (Funct7_RV64I_R_TypeOut, Funct7In, 64'b0, {
      //Addw or Sllw or Srlw
      7'b0000000, Funct3_RV64I_R_Type_ZeroOut,
      //Subw or Sraw
      7'b0100000, Funct3_RV64I_R_Type_OneOut
    });
      MuxKeyWithDefault #(3, 3, 64) Funct3_RV64I_R_Type_Zero (Funct3_RV64I_R_Type_ZeroOut, Funct3In, 64'b0, {
        //Addw
        3'b000, {{32{Rs1ReadDataAddRs2ReadData[31]}}, Rs1ReadDataAddRs2ReadData[31:0]},
        //Sllw
        3'b001, {{32{Rs1ReadDataSllwRs2ReadData[31]}}, Rs1ReadDataSllwRs2ReadData},
        //Srlw
        3'b101, {{32{Rs1ReadDataSrlwRs2ReadData[31]}}, Rs1ReadDataSrlwRs2ReadData}
      });
      MuxKeyWithDefault #(2, 3, 64) Funct3_RV64I_R_Type_One (Funct3_RV64I_R_Type_OneOut, Funct3In, 64'b0, {
        //Subw
        3'b000, {{32{Rs1ReadDataSubRs2ReadData[31]}}, Rs1ReadDataSubRs2ReadData[31:0]},
        //Sraw
        3'b101, {{32{Rs1ReadDataSrawRs2ReadData[31]}}, Rs1ReadDataSrawRs2ReadData}
      });

  wire [`DataBus] RdWriteDataOutRVI;
  wire [`DataBus] RdWriteDataOutRVM;
  //Output
  MuxKeyWithDefault #(8, 7, 64) OpOcde_RdWriteDataRV32IOut (RdWriteDataOutRVI, OpCodeIn, 64'b0, {
    //RV32I
    7'b0010011, Funct3_RV32I_I_TypeOut,
    7'b0110011, Funct7_RV32I_R_TypeOut,
    7'b0010111, (InstAddrIn + (ImmIn << 12)),                            //Auipc
    7'b1101111, (InstAddrIn + 4),                                        //Jar
    7'b1100111, (InstAddrIn + 4),                                        //Jalr
    7'b0110111, {{32{ImmShift[31]}} ,ImmShift[31:0]},                    //Lui 
    //RV64I
    7'b0011011, Funct3_RV64I_I_TypeOut,
    7'b0111011, Funct7_RV64I_R_TypeOut
  });

  wire [`DataBus] Funct3_RV32M_R_Type_SixOut;
  wire [`DataBus] Funct7_RV32M_R_TypeOut;
  wire [`DataBus] Funct3_RV64M_R_Type_SixOut;
  wire [`DataBus] Funct7_RV64M_R_TypeOut;
  //RV32M
  //R类型执行模块
  MuxKeyWithDefault #(1, 7, 64) Funct7_RV32M_R_Type (Funct7_RV32M_R_TypeOut, MulFunct7ToEx | DivFunct7ToEx, 64'b0, {
    //Mul or Div
    7'b0000001, Funct3_RV32M_R_Type_SixOut
  }); 
  //Funct7为7'b0000001
    MuxKeyWithDefault #(8, 3, 64) Funct3_RV32M_R_Type_One (Funct3_RV32M_R_Type_SixOut, MulFunct3ToEx | DivFunct3ToEx, 64'b0, {
      //Mul
      3'b000, Rs1ReadDataMulRs2ReadData[`DataBus],
      //Mulh
      3'b001, Rs1ReadDataMulRs2ReadData[`HighMulDataBus],
      //Mulhsu
      3'b010, Rs1ReadDataMulRs2ReadData[`HighMulDataBus],
      //Mulhu
      3'b011, Rs1ReadDataMulRs2ReadData[`HighMulDataBus],
      //Div
      3'b100, Rs1ReadDataDivRs2ReadData,
      //Divu
      3'b101, Rs1ReadDataDivRs2ReadData,
      //Rem
      3'b110, Rs1ReadDataRemRs2ReadData,
      //Remu
      3'b111, Rs1ReadDataRemRs2ReadData
      });
  //R64M
  //R类型执行模块
  MuxKeyWithDefault #(1, 7, 64) Funct7_RV64M_R_Type (Funct7_RV64M_R_TypeOut, MulFunct7ToEx | DivFunct7ToEx, 64'b0, {
    //Mulw or Divw
    7'b0000001, Funct3_RV64M_R_Type_SixOut
  }); 
  //Funct7为7'b0000001
    MuxKeyWithDefault #(5, 3, 64) Funct3_RV64M_R_Type_One (Funct3_RV64M_R_Type_SixOut, MulFunct3ToEx | DivFunct3ToEx, 64'b0, {
      //Mulw
      3'b000, {{32{Rs1ReadDataMulRs2ReadData[31]}}, Rs1ReadDataMulRs2ReadData[31:0]},
      //Divuw
      3'b101, {{32{Rs1ReadDataDivRs2ReadData[31]}}, Rs1ReadDataDivRs2ReadData[31:0]},
      //Divw
      3'b100, {{32{Rs1ReadDataDivRs2ReadData[31]}}, Rs1ReadDataDivRs2ReadData[31:0]},
      //Remuw
      3'b111, {{32{Rs1ReadDataRemRs2ReadData[31]}}, Rs1ReadDataRemRs2ReadData[31:0]},
      //Remw
      3'b110, {{32{Rs1ReadDataRemRs2ReadData[31]}}, Rs1ReadDataRemRs2ReadData[31:0]}
    });
  //Output
  MuxKeyWithDefault #(2, 7, 64) OpOcde_RdWriteDataRVMOut (RdWriteDataOutRVM, MulOpCodeToEx | DivOpCodeToEx, 64'b0, {
    //RV32M
    7'b0110011, Funct7_RV32M_R_TypeOut,
    //RV64M
    7'b0111011, Funct7_RV64M_R_TypeOut
  });
  
  //RV32I和RV32M译码不重叠，因此不存在数据冲突的情况
  assign RdWriteDataOut = RdWriteDataOutRVI | RdWriteDataOutRVM | CsrReadDataIn;

  //DPI-C
  //Ebreak or Ecall
  MuxKeyWithDefault #(2, 12, 2) Funct_Environment (RaiseException, ImmIn[11:0], 2'b0, {
    //Ebreak
    12'b000000000001, RaiseException_Ebreak,
    //Ecall
    12'b000000000000, RaiseException_Ecall
  });

  //INT
  always @( * ) begin
    if((OpCodeIn == 7'b1110011) && (RaiseException != 2'b00)) begin
      case (RaiseException)
        RaiseException_Ebreak: begin
          ExcInfoOut = {ExcInfoIn[63:32], {1'b1}, {1'b0}, {1'b0}, {13'h03}, ExcInfoIn[15:0]};
        end
        RaiseException_Ecall: begin
          ExcInfoOut = {ExcInfoIn[63:32], {1'b1}, {1'b0}, {1'b0}, {13'h0b}, ExcInfoIn[15:0]};
        end
        default : ;
      endcase
    end else if(MRetEnableIn) 
      ExcInfoOut = {ExcInfoIn[63:32], {1'b0}, {1'b0}, {1'b1}, {13'h00}, ExcInfoIn[15:0]};
    else
      ExcInfoOut = ExcInfoIn;
  end

  `ifdef CpuTestsMode
    import "DPI-C" function void SystemBreak (input int Ebreak);
    always @( * ) begin
      if(OpCodeIn == 7'b1110011 && RaiseException == RaiseException_Ebreak) 
        SystemBreak(1);
      else
        SystemBreak(0);
    end  
  `endif 
          
  //Ebrack or Ecall
  wire BranchFlag;
  //Jump
  MuxKeyWithDefault #(3, 7, 1) JumpFlag_mux (JumpFlagToCtrl, OpCodeIn, 1'b0, {
    //Jar
    7'b1101111, 1'b1,
    //Jalr
    7'b1100111, 1'b1,
    //Beq、Bge、Bgeu、Blt、Bltu、Bne
    7'b1100011, BranchFlag
  });

  MuxKeyWithDefault #(6, 3, 1) BranchFlag_mux (BranchFlag, Funct3In, 1'b0, {
    //Beq
    3'b000, ((Rs1ReadDataIn == Rs2ReadDataIn) ? 1'b1 : 1'b0),
    //Bge
    3'b101, (((Rs1ReadDataIn[63] == 1'b1) && (Rs2ReadDataIn[63] == 1'b0)) ? 1'b0 :
            ((Rs1ReadDataIn[63] == 1'b0) && (Rs2ReadDataIn[63] == 1'b1)) ? 1'b1 :
            ((Rs1ReadDataIn[63] == Rs1ReadDataIn[63]) && (Rs1ReadDataSubRs2ReadData[63] == 1)) ? 1'b0 : 1'b1),
    //Bgeu
    3'b111, ((Rs1ReadDataSubRs2ReadData[63] == 1'b1) ? 1'b0 : 1'b1),
    //Blt
    3'b100, (((Rs1ReadDataIn[63] == 1'b1) && (Rs2ReadDataIn[63] == 1'b0)) ? 1'b1 :
            ((Rs1ReadDataIn[63] == 1'b0) && (Rs2ReadDataIn[63] == 1'b1)) ? 1'b0 :
            ((Rs1ReadDataIn[63] == Rs1ReadDataIn[63]) && (Rs1ReadDataSubRs2ReadData[63] == 1)) ? 1'b1 : 1'b0),
    //Bltu
    3'b110, ((Rs1ReadDataSubRs2ReadData[63] == 1'b1) ? 1'b1 : 1'b0),
    //Bne
    3'b001, ((Rs1ReadDataIn != Rs2ReadDataIn) ? 1'b1 : 1'b0)
  });
  
  MuxKeyWithDefault #(2, 7, 1) HoldFlag_mux (HoldFlagToCtrl, OpCodeIn, 1'b0, {
    //Load
    7'b0000011, 1'b1,
    //Store
    7'b0100011, 1'b1
  });

  //RV32M扩展，HoldFlag生成以及部分关键信号传送给Div和Mul模块
  wire [1:0] RV32M_HoldFlagToOpCodeMux;
  wire [1:0] RV64M_HoldFlagToOpCodeMux;
  wire [1:0] RV32M_HoldFlagToFunct7Mux;
  wire [1:0] RV64M_HoldFlagToFunct7Mux;
  //Mul暂停流水线 
  MuxKeyWithDefault #(2, 7, 2) RVM_HoldFlag_mux (RVM_HoldFlagOut, OpCodeIn, 2'b0, {
    //Mul or Div
    7'b0110011, RV32M_HoldFlagToOpCodeMux,
    //RV64M
    7'b0111011, RV64M_HoldFlagToOpCodeMux
  });
    //RV32M
    MuxKeyWithDefault #(1, 7, 2) RV32M_HoldFlagFunct7_mux (RV32M_HoldFlagToOpCodeMux, Funct7In, 2'b0, {
      7'b0000001, RV32M_HoldFlagToFunct7Mux
    });
      MuxKeyWithDefault #(8, 3, 2) RV32M_HoldFlagFunct3_mux (RV32M_HoldFlagToFunct7Mux, Funct3In, 2'b0, {
        //Mul
        3'b000, 2'b01,
        //Mulh
        3'b001, 2'b01,
        //Mulhsu
        3'b010, 2'b01,
        //Mulhu
        3'b011, 2'b01,
        //Div
        3'b100, 2'b10,
        //Divu
        3'b101, 2'b10,
        //Rem
        3'b110, 2'b10,
        //Remu
        3'b111, 2'b10
      });
    //RV64M
    MuxKeyWithDefault #(1, 7, 2) RV64M_HoldFlagFunct7_mux (RV64M_HoldFlagToOpCodeMux, Funct7In, 2'b0, {
      7'b0000001, RV64M_HoldFlagToFunct7Mux
    });
      MuxKeyWithDefault #(5, 3, 2) RV64M_HoldFlagFunct3_mux (RV64M_HoldFlagToFunct7Mux, Funct3In, 2'b0, {
        //Mulw
        3'b000, 2'b01,
        //Divuw
        3'b101, 2'b10,
        //Divw 
        3'b100, 2'b10,
        //Remuw
        3'b111, 2'b10,
        //Remw
        3'b110, 2'b10
      });

  // wire [`DataBus] RV32M_WriteAddrToMux;
  // //Mul暂停流水线 RegWriteAddr
  // MuxKeyWithDefault #(1, 7, 5) MulWriteAddr_mux (RV32M_WriteAddrExOut, OpCodeIn, 5'b0, {
  //   //Mul
  //   7'b0110011, RV32M_WriteAddrToMux
  // });
  // MuxKeyWithDefault #(1, 7, 5) MulWriteAddrFunct7_mux (RV32M_WriteAddrToMux, Funct7In, 5'b0, {
  //   //Mul
  //   7'b0000001, RdAddrIn
  // });

  // wire [6:0] MulOpCodeToMux;
  // //Mul暂停流水线 OpCode
  // MuxKeyWithDefault #(1, 7, 7) MulOpCode_mux (RV32M_OpCodeExOut, OpCodeIn, 7'b0, {
  //   //Mul
  //   7'b0110011, MulOpCodeToMux
  // });
  // MuxKeyWithDefault #(1, 7, 7) MulOpCodeFunct7_mux (MulOpCodeToMux, Funct7In, 7'b0, {
  //   //Mul
  //   7'b0000001, OpCodeIn
  // });

  // wire [6:0] MulFunct7ToMux;
  // //Mul暂停流水线 Funct7
  // MuxKeyWithDefault #(1, 7, 7) MulFunct7_mux (RV32M_Funct7ExOut, OpCodeIn, 7'b0, {
  //   //Mul
  //   7'b0110011, MulFunct7ToMux
  // });
  // MuxKeyWithDefault #(1, 7, 7) MulFunct7Funct7_mux (MulFunct7ToMux, Funct7In, 7'b0, {
  //   //Mul
  //   7'b0000001, Funct7In
  // });

  // wire [2:0] MulFunct3ToMux;
  // //Mul暂停流水线 Funct3
  // MuxKeyWithDefault #(1, 7, 3) MulFunct3_mux (RV32M_Funct3ExOut, OpCodeIn, 3'b0, {
  //   //Mul
  //   7'b0110011, MulFunct3ToMux
  // });
  // MuxKeyWithDefault #(1, 7, 3) MulFunct3Funct7_mux (MulFunct3ToMux, Funct7In, 3'b0, {
  //   //Mul
  //   7'b0000001, Funct3In
  // });

  MuxKeyWithDefault #(3, 7, 64) JumpAddr (JumpAddrToCtrl, OpCodeIn, 64'b0, {
    //Jar
    7'b1101111, (InstAddrIn + ImmIn),
    //Jalr
    7'b1100111, ((Rs1ReadDataIn + ImmIn) & ~1),
    //Beq、Bge、Bgeu、Blt、Bltu、Bne
    7'b1100011, (InstAddrIn + ImmIn)
  });

endmodule
