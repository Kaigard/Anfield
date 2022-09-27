/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:58:17
 * @FilePath: /Anfield/Balotelli/Pipeline/Id.v
 * @Description: 译码级。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


`include "./vsrc/defines.v"
module Id (
  //从If2Id模块输入的信号
  input [`AddrBus] InstAddrIn,
  input [`InstBus] InstIn,
  //从Regfile模块输入的信号
  input [`DataBus] Rs1ReadDataIn,
  input [`DataBus] Rs2ReadDataIn,
  //输出给Regfile模块的信号
  output reg [`RegFileAddr] Rs1AddrOut,
  output reg Rs1ReadEnable,
  output reg [`RegFileAddr] Rs2AddrOut,
  output reg Rs2ReadEnable,
  //输出给Id2Ex模块的信号
  output reg [`RegFileAddr] RdAddrOut,
  output [`AddrBus] InstAddrOut,                          //Pc地址
  output reg RdWriteEnable,
  output [`DataBus] Rs1ReadDataOut,
  output [`DataBus] Rs2ReadDataOut,
  output reg [`DataBus] Imm,
  output [6:0] OpCode,
  output [2:0] Funct3,
  output [6:0] Funct7,
  output [5:0] ShamtOut,

  /***************INT***************/
  input [`DataBus] ExcInfoIn,
  input [`DataBus] CsrReadDataIn,
  output [`DataBus] ExcInfoOut,
  output [`RegFileAddr] Zimm,
  output CsrWriteEnable,
  output [`DataBus] CsrReadDataOut,
  output MRetEnableOut
  );
  
  assign MRetEnableOut = (InstIn == 64'h0000_0000_3020_0073) ? 1'b1 : 1'b0;
  assign InstAddrOut = InstAddrIn;
  assign Rs1ReadDataOut = Rs1ReadDataIn;
  assign Rs2ReadDataOut = Rs2ReadDataIn;
  assign CsrReadDataOut = CsrReadDataIn;

  //通用译码
  assign OpCode = InstIn[6:0];
  assign Funct3 = InstIn[14:12];
  assign Funct7 = InstIn[31:25];
  wire [5:0] Shamt = InstIn[25:20];
  //I-Type译码
  wire [11:0] Imm_I_Type = InstIn[31:20];
  //S-Type译码
  wire [11:0] Imm_S_Type = {InstIn[31:25], InstIn[11:7]};
  //B-Type译码
  wire [12:1] Imm_B_Type = {InstIn[31], InstIn[7], InstIn[30:25], InstIn[11:8]};
  //U-Type译码
  wire [31:12] Imm_U_Type = InstIn[31:12];
  //J-Type译码
  wire [20:1] Imm_J_Type = {InstIn[31], InstIn[19:12], InstIn[20], InstIn[30:21]};
  
  //wire of Shamt come out
  wire [5:0] ShamtFunct3_00;
  wire [5:0] ShamtFunct3_01; 
  wire [5:0] ShamtFunct7;

  //Shamt在移位操作时输出至ex
  MuxKeyWithDefault #(1, 7, 6) Shamt_mux (ShamtOut, OpCode, 6'b0, {
    7'b0010011, ShamtFunct7
  });

  MuxKeyWithDefault #(2, 7, 6) ShamtFunct7_mux (ShamtFunct7, Funct7, 6'b0, {
    7'b0000000, ShamtFunct3_00,
    7'b0100000, ShamtFunct3_01
  });

  MuxKeyWithDefault #(2, 3, 6) ShamtFunct3_00_mux (ShamtFunct3_00, Funct3, 6'b0, {
    3'b001, Shamt,
    3'b101, Shamt
  });

  MuxKeyWithDefault #(1, 3, 6) ShamtFunct3_01_mux (ShamtFunct3_01, Funct3, 6'b0, {
    3'b101, Shamt 
  });

  wire CsrRs1ReadEnable;
  //Warning!!!部分扩展指令集也做了译码实现，但是不一定正确！！！
  MuxKeyWithDefault #(14, 7, 1) Id_Rs1ReadEnable_mux (Rs1ReadEnable, OpCode, 1'b0, {
    //RV32
    7'b0110111, 1'b0,
    7'b0010111, 1'b0,
    7'b1101111, 1'b0,
    7'b1100111, 1'b1,
    7'b1100011, 1'b1,
    7'b0000011, 1'b1,
    7'b0100011, 1'b1,
    7'b0010011, 1'b1,
    7'b0110011, 1'b1,
    //7'b0001111, 1'b1,
    7'b1110011, CsrRs1ReadEnable,
    //RV64增加
    7'b0011011, 1'b1,
    7'b0111011, 1'b1,
    7'b0101111, 1'b1,
    7'b1010011, 1'b1
  });
    MuxKeyWithDefault #(6, 3, 1) Id_CsrRs1ReadEnable_mux (CsrRs1ReadEnable, Funct3, 1'b0, {
      //Csrrc
      3'b011, 1'b1,
      //Csrrci
      3'b111, 1'b1,
      //Csrrs
      3'b010, 1'b1,
      //Csrrsi
      3'b110, 1'b1,
      //Csrrw
      3'b001, 1'b1,
      //Csrrwi
      3'b101, 1'b1
    });

  MuxKeyWithDefault #(14, 7, 5) Id_Rs1AddrOut (Rs1AddrOut, OpCode, 5'b0, {
    7'b0110111, 5'b0,
    7'b0010111, 5'b0,
    7'b1101111, 5'b0,
    7'b1100111, InstIn[19:15],
    7'b1100011, InstIn[19:15],
    7'b0000011, InstIn[19:15],
    7'b0100011, InstIn[19:15],
    7'b0010011, InstIn[19:15],
    7'b0110011, InstIn[19:15],
    //7'b0001111, InstIn[19:15],
    7'b1110011, InstIn[19:15],
    //RV64增加
    7'b0011011, InstIn[19:15],
    7'b0111011, InstIn[19:15],
    7'b0101111, InstIn[19:15],
    7'b1010011, InstIn[19:15]
  });

  MuxKeyWithDefault #(14, 7, 1) Id_Rs2ReadEnable (Rs2ReadEnable, OpCode, 1'b0, {
    7'b0110111, 1'b0,
    7'b0010111, 1'b0,
    7'b1101111, 1'b0,
    7'b1100111, 1'b0,
    7'b1100011, 1'b1,
    7'b0000011, 1'b0,
    7'b0100011, 1'b1,
    7'b0010011, 1'b0,
    7'b0110011, 1'b1,
    //7'b0001111, 1'b1,
    7'b1110011, 1'b0,
    //RV64增加
    7'b0011011, 1'b0,
    7'b0111011, 1'b1,
    7'b0101111, 1'b1,
    7'b1010011, 1'b1
  });

  MuxKeyWithDefault #(14, 7, 5) Id_Rs2AddrOut (Rs2AddrOut, OpCode, 5'b0, {
    7'b0110111, 5'b0,
    7'b0010111, 5'b0,
    7'b1101111, 5'b0,
    7'b1100111, 5'b0,
    7'b1100011, InstIn[24:20],
    7'b0000011, 5'b0,
    7'b0100011, InstIn[24:20],
    7'b0010011, 5'b0,
    7'b0110011, InstIn[24:20],
    //7'b0001111, InstIn[24:20],
    7'b1110011, 5'b0,
    //RV64增加
    7'b0011011, 5'b0,
    7'b0111011, InstIn[24:20],
    7'b0101111, InstIn[24:20],
    7'b1010011, InstIn[24:20]
  });
  
  wire RV32M_MulRdWriteEnable;
  wire RV64M_MulRdWriteEnable;
  wire CsrRdWriteEnable;
  MuxKeyWithDefault #(14, 7, 1) Id_RdWriteEnable (RdWriteEnable, OpCode, 1'b0, {
    7'b0110111, 1'b1,
    7'b0010111, 1'b1,
    7'b1101111, 1'b1,
    7'b1100111, 1'b1,
    7'b1100011, 1'b0,
    //Load，Rd写应该使能，但由于数据前推，Rd并不能在Ex环节被赋予数据，因此RdEn也同样放到Mem中
    7'b0000011, 1'b0,
    7'b0100011, 1'b0,
    7'b0010011, 1'b1,
    7'b0110011, RV32M_MulRdWriteEnable,
    //7'b0001111, 1'b1,
    7'b1110011, CsrRdWriteEnable,
    //RV64增加
    7'b0011011, 1'b1,
    7'b0111011, RV64M_MulRdWriteEnable,
    7'b0101111, 1'b1,
    7'b1010011, 1'b1
  });
    MuxKeyWithDefault #(1, 7, 1) Id_RV32M_MulRdWriteEnableEnable (RV32M_MulRdWriteEnable, Funct7, 1'b1, {
      7'b0000001, 1'b0
    });
    MuxKeyWithDefault #(1, 7, 1) Id_RV64M_MulRdWriteEnableEnable (RV64M_MulRdWriteEnable, Funct7, 1'b1, {
      7'b0000001, 1'b0
    });
    MuxKeyWithDefault #(6, 3, 1) Id_CsrRdWriteEnable_mux (CsrRdWriteEnable, Funct3, 1'b0, {
      //Csrrc
      3'b011, 1'b1,
      //Csrrci
      3'b111, 1'b1,
      //Csrrs
      3'b010, 1'b1,
      //Csrrsi
      3'b110, 1'b1,
      //Csrrw
      3'b001, 1'b1,
      //Csrrwi
      3'b101, 1'b1
    });

  MuxKeyWithDefault #(14, 7, 5) Id_RdAddrOut (RdAddrOut, OpCode, 5'b0, {
    7'b0110111, InstIn[11:7],
    7'b0010111, InstIn[11:7],
    7'b1101111, InstIn[11:7],
    //Jalr rd默认1
    7'b1100111, 5'b00001,
    7'b1100011, 5'b0,
    7'b0000011, InstIn[11:7],
    7'b0100011, 5'b0,
    7'b0010011, InstIn[11:7],
    7'b0110011, InstIn[11:7],
    //7'b0001111, InstIn[11:7],
    7'b1110011, InstIn[11:7],
    //RV64增加
    7'b0011011, InstIn[11:7],
    7'b0111011, InstIn[11:7],
    7'b0101111, InstIn[11:7],
    7'b1010011, InstIn[11:7]
  });

  MuxKeyWithDefault #(14, 7, 64) Id_Imm (Imm, OpCode, 64'b0, {
    //??????????
    7'b0110111, {{44{Imm_U_Type[19]}}, Imm_U_Type},
    //??????????
    7'b0010111, {{44{Imm_U_Type[19]}}, Imm_U_Type},
    7'b1101111, {{43{Imm_J_Type[20]}}, Imm_J_Type, {1'b0}},
    7'b1100111, {{52{Imm_I_Type[11]}}, Imm_I_Type},
    7'b1100011, {{51{Imm_B_Type[12]}}, Imm_B_Type, {1'b0}},
    7'b0000011, {{52{Imm_I_Type[11]}}, Imm_I_Type},
    7'b0100011, {{52{Imm_S_Type[11]}}, Imm_S_Type},
    7'b0010011, {{52{Imm_I_Type[11]}}, Imm_I_Type},
    7'b0110011, 64'b0,
    //7'b0001111, {{52{Imm_I_Type[11]}}, Imm_I_Type},
    7'b1110011, {{52{Imm_I_Type[11]}}, Imm_I_Type},
    //RV64增加
    7'b0011011, {{52{Imm_I_Type[11]}}, Imm_I_Type},
    7'b0111011, 64'b0,
    7'b0101111, 64'b0,
    7'b1010011, 64'b0
  });

  /********************INT*****************/ 
  reg IllegalInst;

  wire [`RegFileAddr] CsrZimm;
  MuxKeyWithDefault #(1, 7, 5) Id_Zimm_mux (Zimm, OpCode, 5'b0, {
    7'b1110011, CsrZimm
  });
    MuxKeyWithDefault #(3, 3, 5) Id_CsrZimm_mux (CsrZimm, Funct3, 5'b0, {
      //Csrrci
      3'b111, InstIn[19:15],
      //Csrrsi
      3'b110, InstIn[19:15],
      //Csrrwi
      3'b101, InstIn[19:15]
    });

  wire CsrWriteEnableFunct3;
  MuxKeyWithDefault #(1, 7, 1) Id_WriteEnable_mux (CsrWriteEnable, OpCode, 1'b0, {
    7'b1110011, CsrWriteEnableFunct3
  });
    MuxKeyWithDefault #(6, 3, 1) Id_CsrWriteEnable_mux (CsrWriteEnableFunct3, Funct3, 1'b0, {
      //Csrrc
      3'b011, 1'b1,
      //Csrrci
      3'b111, 1'b1,
      //Csrrs
      3'b010, 1'b1,
      //Csrrsi
      3'b110, 1'b1,
      //Csrrw
      3'b001, 1'b1,
      //Csrrwi
      3'b101, 1'b1
    });

  wire LuiLegal = (OpCode == 7'b0110111);
  wire AuipcLegal = (OpCode == 7'b0010111);
  wire JalLegal = (OpCode == 7'b1101111);
  wire JalrLegal = (OpCode == 7'b1100111) && (Funct3 == 3'b000);
  wire BenchLegal = (OpCode == 7'b1100011) && ((Funct3 == 3'b000) || 
                    (Funct3 == 3'b001) || (Funct3 == 3'b100) || (Funct3 == 3'b101) ||
                    (Funct3 == 3'b110) || (Funct3 == 3'b111));
  wire LoadLegal = (OpCode == 7'b0000011) && ((Funct3 == 3'b000) || (Funct3 == 3'b001) ||
                   (Funct3 == 3'b010) || (Funct3 == 3'b100) || (Funct3 == 3'b101) ||
                   (Funct3 == 3'b110) || (Funct3 == 3'b011));
  wire StoreLegal = (OpCode == 7'b0100011) && ((Funct3 == 3'b000) || (Funct3 == 3'b001) ||
                    (Funct3 == 3'b010) || (Funct3 == 3'b011));
  wire AluLegal_32_I = ((OpCode == 7'b0010011) && ((Funct3 == 3'b000) || (Funct3 == 3'b010) || 
                       (Funct3 == 3'b011) || (Funct3 == 3'b100) || (Funct3 == 3'b110) ||
                       (Funct3 == 3'b111) || ((Funct3 == 3'b001) && (Funct7 == 7'b0000000)) ||
                       ((Funct3 == 3'b001) && (Funct7 == 7'b0000000)) ||
                       ((Funct3 == 3'b101) && ((Funct7 == 7'b0000000) || (Funct7 == 7'b0100000)))));
  wire AluLega_32_R = (OpCode == 7'b0110011) &&
                      (((Funct3 == 3'b000) && ((Funct7 == 7'b0000000) ||(Funct7 == 7'b0100000))) ||
                      ((Funct3 == 3'b001) && (Funct7 == 7'b0000000)) ||
                      ((Funct3 == 3'b010) && (Funct7 == 7'b0000000)) ||
                      ((Funct3 == 3'b011) && (Funct7 == 7'b0000000)) ||
                      ((Funct3 == 3'b100) && (Funct7 == 7'b0000000)) ||
                      ((Funct3 == 3'b101) && ((Funct7 == 7'b0000000) || (Funct7 == 7'b0100000))) ||
                      ((Funct3 == 3'b110) && (Funct7 == 7'b000000)) ||
                      ((Funct3 == 3'b111) && (Funct7 == 7'b000000)));
  wire ELegal = (InstIn == 64'h0000_0000_0000_0073) || (InstIn == 64'h0010_0000_0000_0073) || (InstIn == 64'h0000_0000_3020_0073);
  wire CsrLegal = (OpCode == 7'b1110011) && ((Funct3 == 3'b001) ||
                  (Funct3 == 3'b010) || (Funct3 == 3'b011) || (Funct3 == 3'b101) ||
                  (Funct3 == 3'b110) || (Funct3 == 3'b111));
  wire MulLegal_32 = (OpCode == 7'b0110011) && (Funct7 == 7'b0000001) &&
                     ((Funct3 == 3'b000) || (Funct3 == 3'b001) || (Funct3 == 3'b010) ||
                     (Funct3 == 3'b011) || (Funct3 == 3'b100) || (Funct3 == 3'b101) ||
                     (Funct3 == 3'b110) || (Funct3 == 3'b111));
  wire MulLegal_64 = (OpCode == 7'b0111011) && (Funct7 == 7'b0000001) &&
                     ((Funct3 == 3'b000) || (Funct3 == 3'b100) || (Funct3 == 3'b101)||
                     (Funct3 == 3'b110) || (Funct3 == 3'b111));
  wire AluLegal_64_I = (OpCode == 7'b0011011) && 
                       ((Funct3 == 3'b000) || ((Funct3 == 3'b001) && (Funct7 == 7'b0000000)) ||
                       ((Funct3 == 3'b101) && ((Funct7 == 7'b0000000) || (Funct7 == 7'b0100000))));
  wire AluLegal_64_R = (OpCode == 7'b0111011) && (
                       ((Funct3 == 3'b000) && ((Funct7 == 7'b0000000) || (Funct7 == 7'b0100000))) ||
                       ((Funct3 == 3'b001) && (Funct7 == 7'b0000000)) || 
                       ((Funct3 == 3'b101) && ((Funct7 == 7'b0000000) || (Funct7 == 7'b0100000))));
  wire IdelLegal = (InstIn == 64'h0000_0000_0000_0000);
  wire InstLegal = (JalrLegal || BenchLegal || LoadLegal || StoreLegal || AluLegal_32_I ||
                   AluLega_32_R || ELegal || LuiLegal || AuipcLegal || JalLegal || CsrLegal ||
                   MulLegal_32 || MulLegal_64 || AluLegal_64_I || AluLegal_64_R || IdelLegal);
  
  always @( * ) begin
    if(InstLegal) begin
      IllegalInst = 1'b0;
    end else begin
      IllegalInst = 1'b1;
    end
  end

  assign ExcInfoOut = IllegalInst ? {ExcInfoIn[63:48], {1'b1}, {1'b0}, {14'h0002}, ExcInfoIn[31:0]} : ExcInfoIn;
endmodule