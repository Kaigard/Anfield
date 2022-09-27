`include "./vsrc/defines.v"
module AddPP_ThiL(
  input Clk,
  input Rst,
  input [1:0] MulHoldFlagFromEx,
  input [`DataWidth_CSA20 - 1 : 0] SumPP_CSA20,
  input [`DataWidth_CSA21 - 1 : 0] SumPP_CSA21,
  input [`DataWidth_CSA22 - 1 : 0] SumPP_CSA22,
  input [`DataWidth_CSA23 - 1 : 0] SumPP_CSA23,
  input [`DataWidth_CSA20 - 1 : 0] CarryPP_CSA20,
  input [`DataWidth_CSA21 - 1 : 0] CarryPP_CSA21,
  input [`DataWidth_CSA22 - 1 : 0] CarryPP_CSA22,
  input [`DataWidth_CSA23 - 1 : 0] CarryPP_CSA23,
  input Mulitiplier_63,
  output [(`DataWidth * 2) - 1 : 0] Sum,
  output MulHoldEndToEx
);
  
  reg [`DataWidth_CSA30 - 1 : 0] SumPP_CSA30Inside;
  reg [`DataWidth_CSA31 - 1 : 0] SumPP_CSA31Inside;
  reg [`DataWidth_CSA30 - 1 : 0] CarryPP_CSA30Inside;
  reg [`DataWidth_CSA31 - 1 : 0] CarryPP_CSA31Inside;
  
  reg Mulitiplier_63Inside;
  reg [1:0] MulHoldFlagFromExInside;
  // Third Level
  // CSA30 width = data_width
  wire [`DataWidth_CSA30 - 1 : 0] SumPP_CSA30;
  wire [`DataWidth_CSA30 - 1 : 0] CarryPP_CSA30;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA30)) CSA_30({16'h0000, SumPP_CSA20}, {SumPP_CSA21, 14'h0000}, {16'h0000, CarryPP_CSA20}, {CarryPP_CSA21, 14'h0000}, SumPP_CSA30, CarryPP_CSA30);

  // CSA31 width = data_width - 30
  wire [`DataWidth_CSA31 - 1 : 0] SumPP_CSA31;
  wire [`DataWidth_CSA31 - 1 : 0] CarryPP_CSA31;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA31)) CSA_31({16'h0000, SumPP_CSA22}, {SumPP_CSA23, 16'h0000}, {16'h0000, CarryPP_CSA22}, {CarryPP_CSA23, 16'h0000}, SumPP_CSA31, CarryPP_CSA31);  

  AddPP_ForL u_AddPP_ForL(Clk, Rst, MulHoldFlagFromExInside, SumPP_CSA30Inside, SumPP_CSA31Inside, CarryPP_CSA30Inside, CarryPP_CSA31Inside, Mulitiplier_63Inside, Sum, MulHoldEndToEx);
  
  Reg #(2, 2'b0) Reg_MulHoldFlagFromExInside (Clk, Rst, MulHoldFlagFromEx, MulHoldFlagFromExInside, 1'b1);
  
  always @ (posedge Clk) begin
    if(!Rst) begin
      SumPP_CSA30Inside <= `DataWidth_CSA30'h0;
      SumPP_CSA31Inside <= `DataWidth_CSA31'h0;
      CarryPP_CSA30Inside <= `DataWidth_CSA30'h0;
      CarryPP_CSA31Inside <= `DataWidth_CSA31'h0;
    end else begin
      SumPP_CSA30Inside <= SumPP_CSA30;
      SumPP_CSA31Inside <= SumPP_CSA31;
      CarryPP_CSA30Inside <= CarryPP_CSA30;
      CarryPP_CSA31Inside <= CarryPP_CSA31;
    end
  end
  
  Reg #(1, 1'b0) Reg_Mulitiplier_63Inside (Clk, Rst, Mulitiplier_63, Mulitiplier_63Inside, 1'b1);
endmodule
