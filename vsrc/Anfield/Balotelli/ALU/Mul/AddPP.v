`include "./vsrc/defines.v"
module AddPP(
  input Clk,
  input Rst,
  input [`DataBus] Mulitiplier,
  input [1:0] MulHoldFlagFromEx,
  input [`DataWidth : 0] PartialProduct0,
  input [`DataWidth : 0] PartialProduct1,
  input [`DataWidth : 0] PartialProduct2,
  input [`DataWidth : 0] PartialProduct3,
  input [`DataWidth : 0] PartialProduct4,
  input [`DataWidth : 0] PartialProduct5,
  input [`DataWidth : 0] PartialProduct6,
  input [`DataWidth : 0] PartialProduct7,
  input [`DataWidth : 0] PartialProduct8,
  input [`DataWidth : 0] PartialProduct9,
  input [`DataWidth : 0] PartialProduct10,
  input [`DataWidth : 0] PartialProduct11,
  input [`DataWidth : 0] PartialProduct12,
  input [`DataWidth : 0] PartialProduct13,
  input [`DataWidth : 0] PartialProduct14,
  input [`DataWidth : 0] PartialProduct15,
  input [`DataWidth : 0] PartialProduct16,
  input [`DataWidth : 0] PartialProduct17,
  input [`DataWidth : 0] PartialProduct18,
  input [`DataWidth : 0] PartialProduct19,
  input [`DataWidth : 0] PartialProduct20,
  input [`DataWidth : 0] PartialProduct21,
  input [`DataWidth : 0] PartialProduct22,
  input [`DataWidth : 0] PartialProduct23,
  input [`DataWidth : 0] PartialProduct24,
  input [`DataWidth : 0] PartialProduct25,
  input [`DataWidth : 0] PartialProduct26,
  input [`DataWidth : 0] PartialProduct27,
  input [`DataWidth : 0] PartialProduct28,
  input [`DataWidth : 0] PartialProduct29,
  input [`DataWidth : 0] PartialProduct30,
  input [`DataWidth : 0] PartialProduct31,
  output [(`DataWidth * 2) - 1 : 0] Sum,
  output MulHoldEndToEx
);
  
  reg [`DataWidth_CSA10 - 1 : 0] SumPP_CSA10Inside;
  reg [`DataWidth_CSA11 - 1 : 0] SumPP_CSA11Inside;
  reg [`DataWidth_CSA12 - 1 : 0] SumPP_CSA12Inside;
  reg [`DataWidth_CSA13 - 1 : 0] SumPP_CSA13Inside;
  reg [`DataWidth_CSA14 - 1 : 0] SumPP_CSA14Inside;
  reg [`DataWidth_CSA15 - 1 : 0] SumPP_CSA15Inside;
  reg [`DataWidth_CSA16 - 1 : 0] SumPP_CSA16Inside;
  reg [`DataWidth_CSA17 - 1 : 0] SumPP_CSA17Inside;
  reg [`DataWidth_CSA10 - 1 : 0] CarryPP_CSA10Inside;
  reg [`DataWidth_CSA11 - 1 : 0] CarryPP_CSA11Inside;
  reg [`DataWidth_CSA12 - 1 : 0] CarryPP_CSA12Inside;
  reg [`DataWidth_CSA13 - 1 : 0] CarryPP_CSA13Inside;
  reg [`DataWidth_CSA14 - 1 : 0] CarryPP_CSA14Inside;
  reg [`DataWidth_CSA15 - 1 : 0] CarryPP_CSA15Inside;
  reg [`DataWidth_CSA16 - 1 : 0] CarryPP_CSA16Inside;
  reg [`DataWidth_CSA17 - 1 : 0] CarryPP_CSA17Inside;
  
  reg Mulitiplier_63Inside;
  reg [1:0] MulHoldFlagFromExInside;
  
  // CSA10 width = datawidth
  wire [`DataWidth_CSA10 - 1 : 0] AddPP0_CSA10 = {{6{1'b0}}, PartialProduct0[`DataWidth - 1 : 0]};
  wire [`DataWidth_CSA10 - 1 : 0] AddPP1_CSA10 = {{4{1'b0}}, PartialProduct1[`DataWidth - 1 : 0], 1'b0, Mulitiplier[1]};
  wire [`DataWidth_CSA10 - 1 : 0] AddPP2_CSA10 = {{2{1'b0}}, PartialProduct2[`DataWidth - 1 : 0], 1'b0, Mulitiplier[3], 2'h0};
  wire [`DataWidth_CSA10 - 1 : 0] AddPP3_CSA10 = {PartialProduct3[`DataWidth - 1 : 0], 1'b0, Mulitiplier[5], 4'h0};
  wire [`DataWidth_CSA10 - 1 : 0] SumPP_CSA10;
  wire [`DataWidth_CSA10 - 1 : 0] CarryPP_CSA10;
  //wire [`DataWidth - 1 : 0] testsum0 = AddPP0_CSA10 + AddPP1_CSA10 + AddPP2_CSA10 + AddPP3_CSA10;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA10 )) CSA_10(AddPP0_CSA10, AddPP1_CSA10, AddPP2_CSA10, AddPP3_CSA10, SumPP_CSA10, CarryPP_CSA10);

  // CSA11 width = datawidth - 6
  wire [`DataWidth_CSA11 - 1 : 0] AddPP0_CSA11 = {{6{1'b0}}, PartialProduct4[`DataWidth - 1 : 0], 1'b0, Mulitiplier[7]};
  wire [`DataWidth_CSA11 - 1 : 0] AddPP1_CSA11 = {{4{1'b0}}, PartialProduct5[`DataWidth - 1 : 0], 1'b0, Mulitiplier[9], 2'h0};
  wire [`DataWidth_CSA11 - 1 : 0] AddPP2_CSA11 = {{2{1'b0}}, PartialProduct6[`DataWidth - 1 : 0], 1'b0, Mulitiplier[11], 4'h0};
  wire [`DataWidth_CSA11 - 1 : 0] AddPP3_CSA11 = {PartialProduct7[`DataWidth - 1 : 0], 1'b0, Mulitiplier[13], 6'h00};
  wire [`DataWidth_CSA11 - 1 : 0] SumPP_CSA11;
  wire [`DataWidth_CSA11 - 1 : 0] CarryPP_CSA11;
  //wire [`DataWidth - 1 : 0] testsum1 = AddPP0_CSA11 + AddPP1_CSA11 + AddPP2_CSA11 + AddPP3_CSA11;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA11)) CSA_11(AddPP0_CSA11, AddPP1_CSA11, AddPP2_CSA11, AddPP3_CSA11, SumPP_CSA11, CarryPP_CSA11);

  // CSA12 width = datawidth - 14
  wire [`DataWidth_CSA12 - 1 : 0] AddPP0_CSA12 = {{6{1'b0}}, PartialProduct8[`DataWidth - 1 : 0], 1'b0, Mulitiplier[15]};
  wire [`DataWidth_CSA12 - 1 : 0] AddPP1_CSA12 = {{4{1'b0}}, PartialProduct9[`DataWidth - 1 : 0], 1'b0, Mulitiplier[17], 2'h0};
  wire [`DataWidth_CSA12 - 1 : 0] AddPP2_CSA12 = {{2{1'b0}}, PartialProduct10[`DataWidth - 1 : 0], 1'b0, Mulitiplier[19], 4'h0};
  wire [`DataWidth_CSA12 - 1 : 0] AddPP3_CSA12 = {PartialProduct11[`DataWidth - 1 : 0], 1'b0, Mulitiplier[21], 6'h00};
  wire [`DataWidth_CSA12 - 1 : 0] SumPP_CSA12;
  wire [`DataWidth_CSA12 - 1 : 0] CarryPP_CSA12;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA12)) CSA_12(AddPP0_CSA12, AddPP1_CSA12, AddPP2_CSA12, AddPP3_CSA12, SumPP_CSA12, CarryPP_CSA12);

  // CSA13 width = datawidth - 22
  wire [`DataWidth_CSA13 - 1 : 0] AddPP0_CSA13 = {{6{1'b0}}, PartialProduct12[`DataWidth - 1 : 0], 1'b0, Mulitiplier[23]};
  wire [`DataWidth_CSA13 - 1 : 0] AddPP1_CSA13 = {{4{1'b0}}, PartialProduct13[`DataWidth - 1 : 0], 1'b0, Mulitiplier[25], 2'h0};
  wire [`DataWidth_CSA13 - 1 : 0] AddPP2_CSA13 = {{2{1'b0}}, PartialProduct14[`DataWidth - 1 : 0], 1'b0, Mulitiplier[27], 4'h0};
  wire [`DataWidth_CSA13 - 1 : 0] AddPP3_CSA13 = {PartialProduct15[`DataWidth - 1 : 0], 1'b0, Mulitiplier[29], 6'h00};
  wire [`DataWidth_CSA13 - 1 : 0] SumPP_CSA13;
  wire [`DataWidth_CSA13 - 1 : 0] CarryPP_CSA13;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA13)) CSA_13(AddPP0_CSA13, AddPP1_CSA13, AddPP2_CSA13, AddPP3_CSA13, SumPP_CSA13, CarryPP_CSA13);

  // CSA14 width = datawidth - 30
  wire [`DataWidth_CSA14 - 1 : 0] AddPP0_CSA14 = {{6{1'b0}}, PartialProduct16[`DataWidth - 1 : 0], 1'b0, Mulitiplier[31]};
  wire [`DataWidth_CSA14 - 1 : 0] AddPP1_CSA14 = {{4{1'b0}}, PartialProduct17[`DataWidth - 1 : 0], 1'b0, Mulitiplier[33], 2'h0};
  wire [`DataWidth_CSA14 - 1 : 0] AddPP2_CSA14 = {{2{1'b0}}, PartialProduct18[`DataWidth - 1 : 0], 1'b0, Mulitiplier[35], 4'h0};
  wire [`DataWidth_CSA14 - 1 : 0] AddPP3_CSA14 = {PartialProduct19[`DataWidth - 1 : 0], 1'b0, Mulitiplier[37], 6'h00};
  wire [`DataWidth_CSA14 - 1 : 0] SumPP_CSA14;
  wire [`DataWidth_CSA14 - 1 : 0] CarryPP_CSA14;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA14)) CSA_14(AddPP0_CSA14, AddPP1_CSA14, AddPP2_CSA14, AddPP3_CSA14, SumPP_CSA14, CarryPP_CSA14);

  // CSA15 width = datawidth - 38
  wire [`DataWidth_CSA15 - 1 : 0] AddPP0_CSA15 = {{6{1'b0}}, PartialProduct20[`DataWidth - 1 : 0], 1'b0, Mulitiplier[39]};
  wire [`DataWidth_CSA15 - 1 : 0] AddPP1_CSA15 = {{4{1'b0}}, PartialProduct21[`DataWidth - 1 : 0], 1'b0, Mulitiplier[41], 2'h0};
  wire [`DataWidth_CSA15 - 1 : 0] AddPP2_CSA15 = {{2{1'b0}}, PartialProduct22[`DataWidth - 1 : 0], 1'b0, Mulitiplier[43], 4'h0};
  wire [`DataWidth_CSA15 - 1 : 0] AddPP3_CSA15 = {PartialProduct23[`DataWidth - 1 : 0], 1'b0, Mulitiplier[45], 6'h00};
  wire [`DataWidth_CSA15 - 1 : 0] SumPP_CSA15;
  wire [`DataWidth_CSA15 - 1 : 0] CarryPP_CSA15;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA15)) CSA_15(AddPP0_CSA15, AddPP1_CSA15, AddPP2_CSA15, AddPP3_CSA15, SumPP_CSA15, CarryPP_CSA15);

  // CSA16 width = datawidth - 46
  wire [`DataWidth_CSA16 - 1 : 0] AddPP0_CSA16 = {{6{1'b0}}, PartialProduct24[`DataWidth - 1 : 0], 1'b0, Mulitiplier[47]};
  wire [`DataWidth_CSA16 - 1 : 0] AddPP1_CSA16 = {{4{1'b0}}, PartialProduct25[`DataWidth - 1 : 0], 1'b0, Mulitiplier[49], 2'h0};
  wire [`DataWidth_CSA16 - 1 : 0] AddPP2_CSA16 = {{2{1'b0}}, PartialProduct26[`DataWidth - 1 : 0], 1'b0, Mulitiplier[51], 4'h0};
  wire [`DataWidth_CSA16 - 1 : 0] AddPP3_CSA16 = {PartialProduct27[`DataWidth - 1 : 0], 1'b0, Mulitiplier[53], 6'h00};
  wire [`DataWidth_CSA16 - 1 : 0] SumPP_CSA16;
  wire [`DataWidth_CSA16 - 1 : 0] CarryPP_CSA16;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA16)) CSA_16(AddPP0_CSA16, AddPP1_CSA16, AddPP2_CSA16, AddPP3_CSA16, SumPP_CSA16, CarryPP_CSA16);

  // CSA17 width = datawidth - 54Mulitiplier
  wire [`DataWidth_CSA17 - 1 : 0] AddPP0_CSA17 = {{6{1'b0}}, PartialProduct28[`DataWidth - 1 : 0], 1'b0, Mulitiplier[55]};
  wire [`DataWidth_CSA17 - 1 : 0] AddPP1_CSA17 = {{4{1'b0}}, PartialProduct29[`DataWidth - 1 : 0], 1'b0, Mulitiplier[57], 2'h0};
  wire [`DataWidth_CSA17 - 1 : 0] AddPP2_CSA17 = {{2{1'b0}}, PartialProduct30[`DataWidth - 1 : 0], 1'b0, Mulitiplier[59], 4'h0};
  wire [`DataWidth_CSA17 - 1 : 0] AddPP3_CSA17 = {PartialProduct31[`DataWidth - 1 : 0], 1'b0, Mulitiplier[61], 6'h00};
  wire [`DataWidth_CSA17 - 1 : 0] SumPP_CSA17;
  wire [`DataWidth_CSA17 - 1 : 0] CarryPP_CSA17;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA17)) CSA_17(AddPP0_CSA17, AddPP1_CSA17, AddPP2_CSA17, AddPP3_CSA17, SumPP_CSA17, CarryPP_CSA17);

  AddPP_SecL u_AddPP_SecL(Clk, Rst, MulHoldFlagFromExInside, SumPP_CSA10Inside, SumPP_CSA11Inside, SumPP_CSA12Inside, SumPP_CSA13Inside, SumPP_CSA14Inside, SumPP_CSA15Inside, SumPP_CSA16Inside, SumPP_CSA17Inside, CarryPP_CSA10Inside, CarryPP_CSA11Inside, CarryPP_CSA12Inside, CarryPP_CSA13Inside, CarryPP_CSA14Inside, CarryPP_CSA15Inside, CarryPP_CSA16Inside, CarryPP_CSA17Inside, Mulitiplier_63Inside, Sum, MulHoldEndToEx);
  
  always @ (posedge Clk) begin
    if(!Rst) begin
      MulHoldFlagFromExInside <= 2'b0;
    end else begin
      MulHoldFlagFromExInside <= MulHoldFlagFromEx;
    end
  end
  
  always @ (posedge Clk) begin
    if(!Rst) begin
      SumPP_CSA10Inside <= `DataWidth_CSA10'h0;
      SumPP_CSA11Inside <= `DataWidth_CSA11'h0;
      SumPP_CSA12Inside <= `DataWidth_CSA12'h0;
      SumPP_CSA13Inside <= `DataWidth_CSA13'h0;
      SumPP_CSA14Inside <= `DataWidth_CSA14'h0;
      SumPP_CSA15Inside <= `DataWidth_CSA15'h0;
      SumPP_CSA16Inside <= `DataWidth_CSA16'h0;
      SumPP_CSA17Inside <= `DataWidth_CSA17'h0;
      CarryPP_CSA10Inside <= `DataWidth_CSA10'h0;
      CarryPP_CSA11Inside <= `DataWidth_CSA11'h0;
      CarryPP_CSA12Inside <= `DataWidth_CSA12'h0;
      CarryPP_CSA13Inside <= `DataWidth_CSA13'h0;
      CarryPP_CSA14Inside <= `DataWidth_CSA14'h0;
      CarryPP_CSA15Inside <= `DataWidth_CSA15'h0;
      CarryPP_CSA16Inside <= `DataWidth_CSA16'h0;
      CarryPP_CSA17Inside <= `DataWidth_CSA17'h0;
    end else begin
      SumPP_CSA10Inside <= SumPP_CSA10;
      SumPP_CSA11Inside <= SumPP_CSA11;
      SumPP_CSA12Inside <= SumPP_CSA12;
      SumPP_CSA13Inside <= SumPP_CSA13;
      SumPP_CSA14Inside <= SumPP_CSA14;
      SumPP_CSA15Inside <= SumPP_CSA15;
      SumPP_CSA16Inside <= SumPP_CSA16;
      SumPP_CSA17Inside <= SumPP_CSA17;
      CarryPP_CSA10Inside <= CarryPP_CSA10;
      CarryPP_CSA11Inside <= CarryPP_CSA11;
      CarryPP_CSA12Inside <= CarryPP_CSA12;
      CarryPP_CSA13Inside <= CarryPP_CSA13;
      CarryPP_CSA14Inside <= CarryPP_CSA14;
      CarryPP_CSA15Inside <= CarryPP_CSA15;
      CarryPP_CSA16Inside <= CarryPP_CSA16;
      CarryPP_CSA17Inside <= CarryPP_CSA17;
    end
  end
  
  Reg #(1, 1'b0) Reg_Mulitiplier_63Inside (Clk, Rst, Mulitiplier[63], Mulitiplier_63Inside, 1'b1);

endmodule
