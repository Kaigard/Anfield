/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 16:13:09
 * @FilePath: /Anfield/Balotelli/ALU/Div/Div.v
 * @Description: 多周期除法器。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */


module Div(
  input Clk,
  input Rst,
  //从Ex模块输入的信号
  input [`DataBus] DivisorFromEx,
  input [`DataBus] DividendFromEx, 
  input [1:0] DivHoldFlagFromEx,
  input [`RegFileAddr] DivWriteAddrToDiv,
  input [6:0] DivOpCodeFromEx,
  input [2:0] DivFunct3FromEx,
  input [6:0] DivFunct7FromEx,
  //输出给Ex模块的信号
  output reg [`DataBus] QuotientToEx,
  output reg [`DataBus] RemainderToEx,
  output reg DivHoldEndToEx,                                         //该信号同样也会输出给Ctrl模块                                    
  output [6:0] DivOpCodeToEx,
  output [2:0] DivFunct3ToEx,
  output [6:0] DivFunct7ToEx,
  output [`RegFileAddr] DivWriteAddrToEx
);

  wire [`DataBus] Divisor;
  wire [`DataBus] Dividend;
  wire [`DataBus] Quotient;
  wire [`DataBus] Remainder;
  DivCore DivCore_RISCV (Clk, Rst, Divisor, Dividend, DivHoldFlagFromEx,
                         DivWriteAddrToDiv, DivOpCodeFromEx, DivFunct3FromEx,
                         DivFunct7FromEx, Quotient, Remainder, DivHoldEndToEx, 
                         DivOpCodeToEx, DivFunct3ToEx, DivFunct7ToEx, DivWriteAddrToEx);

  wire [`DataBus] Dividend_RV64M;
  wire [`DataBus] Dividend_RV32M;
  wire [`DataBus] Divisor_RV64M;
  wire [`DataBus] Divisor_RV32M;
  reg DividendHighestBit;
  reg DivisorHighestBit;

  Reg #(1, 1'b0) Reg_DividendHighestBit (Clk, Rst, DividendFromEx[63], DividendHighestBit, 1'b1);
  Reg #(1, 1'b0) Reg_DivisorHighestBit (Clk, Rst, DivisorFromEx[63], DivisorHighestBit, 1'b1);
  //Dividend
  wire [`DataBus] InvDividend;
  CLA_64Bit_Adder CLA_InvDividend ( , InvDividend, ~DividendFromEx, 64'h0000_0000_0000_0001, 1'b0);
  MuxKeyWithDefault #(2, 7, 64) DividendConverter (Dividend, DivOpCodeFromEx, 64'b0, {
    //Div or Rem RV32M
    7'b0110011, Dividend_RV32M,
    //Div or Rem RV64M
    7'b0111011, Dividend_RV64M
  });
    MuxKeyWithDefault #(4, 3, 64) DividendConverter_RV32M (Dividend_RV32M, DivFunct3FromEx, 64'b0, {
      //Div
      3'b100, (DividendHighestBit ? InvDividend : DividendFromEx),
      //Divu
      3'b101, DividendFromEx,
      //Rem
      3'b110, (DividendHighestBit ? InvDividend : DividendFromEx),
      //Remu
      3'b111, DividendFromEx
    });
    MuxKeyWithDefault #(4, 3, 64) DividendConverter_RV64M (Dividend_RV64M, DivFunct3FromEx, 64'b0, {
      //Divuw
      3'b101, DividendFromEx,
      //Divw
      3'b100, (DividendHighestBit ? InvDividend : DividendFromEx),
      //Remuw
      3'b111, DividendFromEx,
      //Remw
      3'b110, (DividendHighestBit ? InvDividend : DividendFromEx)
    });

  //Divisor
  wire [`DataBus] InvDivisor;
  CLA_64Bit_Adder CLA_InvDivisor ( , InvDivisor, ~DivisorFromEx, 64'h0000_0000_0000_0001, 1'b0);
  MuxKeyWithDefault #(2, 7, 64) DivisorConverter (Divisor, DivOpCodeFromEx, 64'b0, {
    //Div RV32M
    7'b0110011, Divisor_RV32M,
    //Div RV64M
    7'b0111011, Divisor_RV64M
  });
    MuxKeyWithDefault #(4, 3, 64) DivisorConverter_RV32M (Divisor_RV32M, DivFunct3FromEx, 64'b0, {
      //Div
      3'b100, (DivisorHighestBit ? InvDivisor : DivisorFromEx),
      //Divu
      3'b101, DivisorFromEx,
      //Rem
      3'b110, (DivisorHighestBit ? InvDivisor : DivisorFromEx),
      //Remu
      3'b111, DivisorFromEx
    });
    MuxKeyWithDefault #(4, 3, 64) DivisorConverter_RV64M (Divisor_RV64M, DivFunct3FromEx, 64'b0, {
      //Divuw
      3'b101, DivisorFromEx,
      //Divw
      3'b100, (DivisorHighestBit ? InvDivisor : DivisorFromEx),
      //Remuw
      3'b111, DivisorFromEx,
      //Remw
      3'b110, (DivisorHighestBit ? InvDivisor : DivisorFromEx)
    });

  wire [`DataBus] InvQuotient;
  CLA_64Bit_Adder CLA_InvQuotient ( , InvQuotient, ~Quotient, 64'h0000_0000_0000_0001, 1'b0);
  wire [`DataBus] InvRemainder;
  CLA_64Bit_Adder CLA_InvRemainder ( , InvRemainder, ~Remainder, 64'h0000_0000_0000_0001, 1'b0);
  
  always @( * ) begin
    case (DivOpCodeToEx)
      //RV32M
      7'b0110011 : begin
        case (DivFunct3ToEx)
          //Div
          3'b100 : begin
            case({DividendHighestBit, DivisorHighestBit})
              2'b00, 2'b11 : begin
                QuotientToEx = Quotient;
                RemainderToEx = `RegZero;
              end
              2'b01, 2'b10 : begin
                QuotientToEx = InvQuotient;
                RemainderToEx = `RegZero;
              end
              default : ;
            endcase
          end
          //Divu
          3'b101 : begin
            QuotientToEx = Quotient;
            RemainderToEx = `RegZero;
          end
          //Rem
          3'b110 : begin
            case({DividendHighestBit, DivisorHighestBit})
              2'b00, 2'b11 : begin
                QuotientToEx = `RegZero;
                RemainderToEx = Remainder;
              end
              2'b01, 2'b10 : begin
                QuotientToEx = `RegZero;
                RemainderToEx = InvRemainder;
              end
              default : ;
            endcase
          end
          //Remu
          3'b111: begin
            QuotientToEx = `RegZero;
            RemainderToEx = Remainder;
          end
          default : ;
        endcase
      end
      //RV64M
      7'b0111011 : begin
        case (DivFunct3ToEx)
          //Divw
          3'b100 : begin
            case({DividendHighestBit, DivisorHighestBit})
              2'b00, 2'b11 : begin
                QuotientToEx = Quotient;
                RemainderToEx = `RegZero;
              end
              2'b01, 2'b10 : begin
                QuotientToEx = InvQuotient;
                RemainderToEx = `RegZero;
              end
              default : ;
            endcase
          end
          //Divuw
          3'b101 : begin
            QuotientToEx = Quotient;
            RemainderToEx = `RegZero;
          end
          //Remuw
          3'b111 : begin
            QuotientToEx = `RegZero;
            RemainderToEx = Remainder;
          end
          //Remw
          3'b110 : begin
            case({DividendHighestBit, DivisorHighestBit})
              2'b00, 2'b11 : begin
                QuotientToEx = `RegZero;
                RemainderToEx = Remainder;
              end
              2'b01, 2'b10 : begin
                QuotientToEx = `RegZero;
                RemainderToEx = InvRemainder;
              end
              default : ;
            endcase
          end
          default : ;
        endcase
      end
      default : ;
    endcase
  end
endmodule