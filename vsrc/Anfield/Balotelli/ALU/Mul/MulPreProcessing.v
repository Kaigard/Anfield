module MulPreProcessing(
  input [`DataBus] MulitiplicandFromEx,
  input [`DataBus] MulitiplierFromEx,
  input [6:0] MulOpCodeFromEx,
  input [2:0] MulFunct3FromEx,
  input [6:0] MulOpCodeToEx,
  input [2:0] MulFunct3ToEx,
  input MulitiplicandHighestBit,
  input MulitiplierHighestBit,
  input [`MulDataBus] Product,
  output [`DataBus] Mulitiplicand,
  output [`DataBus] Mulitiplier,
  output reg [`MulDataBus] ProductToEx
);

//根据传入的关键信息决定是何种乘法类型
  //Mulitiplicand
  wire [`DataBus] InvMulitiplicand;
  CLA_64Bit_Adder CLA_InvMulitiplicand ( , InvMulitiplicand, ~MulitiplicandFromEx, 64'h0000_0000_0000_0001, 1'b0);

  wire [`DataBus] Mulitiplicand_RV64M;
  wire [`DataBus] Mulitiplicand_RV32M;
  MuxKeyWithDefault #(2, 7, 64) MulitiplicandConverter (Mulitiplicand, MulOpCodeFromEx, 64'b0, {
    //Mul RV32M
    7'b0110011, Mulitiplicand_RV32M,
    //Mul RV64M
    7'b0111011, Mulitiplicand_RV64M
  });
    MuxKeyWithDefault #(4, 3, 64) MulitiplicandConverter_RV32M (Mulitiplicand_RV32M, MulFunct3FromEx, 64'b0, {
      //Mul
      3'b000, MulitiplicandFromEx,
      //Mulh
      3'b001, (MulitiplicandHighestBit ? InvMulitiplicand : MulitiplicandFromEx),
      //Mulhsu
      3'b010, (MulitiplicandHighestBit ? InvMulitiplicand : MulitiplicandFromEx),
      //Mulhu
      3'b011, MulitiplicandFromEx
    });
    MuxKeyWithDefault #(1, 3, 64) MulitiplicandConverter_RV64M (Mulitiplicand_RV64M, MulFunct3FromEx, 64'b0, {
      //Mulw
      3'b000, MulitiplicandFromEx
    });

  //Mulitiplier
  wire [`DataBus] InvMulitiplier;
  CLA_64Bit_Adder CLA_InvMulitiplier ( , InvMulitiplier, ~MulitiplierFromEx, 64'h0000_0000_0000_0001, 1'b0);

  wire [`DataBus] Mulitiplier_RV64M;
  wire [`DataBus] Mulitiplier_RV32M;
  MuxKeyWithDefault #(2, 7, 64) MulitiplierConverter (Mulitiplier, MulOpCodeFromEx, 64'b0, {
    //Mul RV32M
    7'b0110011, Mulitiplier_RV32M,
    //Mul RV64M
    7'b0111011, Mulitiplier_RV64M
  });
    MuxKeyWithDefault #(4, 3, 64) MulitiplierConverter_RV32M (Mulitiplier_RV32M, MulFunct3FromEx, 64'b0, {
      //Mul
      3'b000, MulitiplierFromEx,
      //Mulh
      3'b001, (MulitiplierHighestBit ? InvMulitiplier : MulitiplierFromEx),
      //Mulhsu
      3'b010, MulitiplierFromEx,
      //Mulhu
      3'b011, MulitiplierFromEx
    });
    MuxKeyWithDefault #(1, 3, 64) MulitiplierConverter_RV64M (Mulitiplier_RV64M, MulFunct3FromEx, 64'b0, {
      //Mulw
      3'b000, MulitiplierFromEx
    });

  wire [`MulDataBus] InvProduct;
  CLA_128Bit_Adder CLA_InvProduct (InvProduct, ~Product, 128'h0000_0000_0000_0000_0000_0000_0000_0001);

  always @( * ) begin
    case (MulOpCodeToEx)
      //RV32M
      7'b0110011 : begin
        case (MulFunct3ToEx)
          //Mul
          3'b000 : ProductToEx = Product;
          //Mulh
          3'b001 : begin
            case({MulitiplicandHighestBit, MulitiplierHighestBit})
              2'b00, 2'b11 : ProductToEx = Product;
              2'b01, 2'b10 : ProductToEx = InvProduct;
              default : ;
            endcase
          end
          //Mulhsu
          3'b010 : ProductToEx = MulitiplicandHighestBit ? InvProduct : Product;
          //Mulhu
          3'b011 : ProductToEx = Product;
          default : ;
        endcase
      end
      //RV64M
      7'b0111011 : ProductToEx = Product;
      default : ;
    endcase
  end
endmodule