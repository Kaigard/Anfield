`include "./vsrc/defines.v"
module AddPP_FivL(
  input Clk,
  input Rst,
  input [1:0] MulHoldFlagFromEx,
  input [`DataWidth_CSA40 - 1 : 0] SumPP_CSA40,
  input [`DataWidth_CSA40 - 1 : 0] CarryPP_CSA40,
  input Mulitiplier_63,
  output [(`DataWidth * 2) - 1 : 0] Sum,
  output reg MulHoldEndToEx
);
  reg [`DataWidth_CSA50 - 1 : 0] SumPP_CSA50Inside;
  reg [`DataWidth_CSA50 - 1 : 0] CarryPP_CSA50Inside;  
  
  reg [1:0] MulHoldFlagFromExInside;
  // Fiveth Level 使用3-2压缩器
  // CSA50 width = data_width
  wire [`DataWidth_CSA50 - 1 : 0] SumPP_CSA50;
  wire [`DataWidth_CSA50 - 1 : 0] CarryPP_CSA50;
  CasAdder3_2 #(`DataWidth_CSA50) CSA_50({2'h0, SumPP_CSA40}, {2'h0, CarryPP_CSA40}, {65'h0_0000_0000_0000_0000, Mulitiplier_63, 62'h0000_0000_0000_0000}, SumPP_CSA50, CarryPP_CSA50);

  AddPP_FinL u_AddPP_FinL(Clk, Rst, MulHoldFlagFromExInside, SumPP_CSA50Inside, CarryPP_CSA50Inside, Sum, MulHoldEndToEx);
  
  Reg #(2, 2'b0) Reg_MulHoldFlagFromExInside (Clk, Rst, MulHoldFlagFromEx, MulHoldFlagFromExInside, 1'b1);
  
  always @ (posedge Clk) begin
    if(!Rst) begin
      SumPP_CSA50Inside <= `DataWidth_CSA50'h0;
      CarryPP_CSA50Inside <= `DataWidth_CSA50'h0;
    end else begin
      SumPP_CSA50Inside <= SumPP_CSA50;
      CarryPP_CSA50Inside <= CarryPP_CSA50;
    end
  end
endmodule
