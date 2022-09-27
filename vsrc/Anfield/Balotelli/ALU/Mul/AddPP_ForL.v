`include "./vsrc/defines.v"
module AddPP_ForL(
  input Clk,
  input Rst,
  input [1:0] MulHoldFlagFromEx,
  input [`DataWidth_CSA30 - 1 : 0] SumPP_CSA30,
  input [`DataWidth_CSA31 - 1 : 0] SumPP_CSA31,
  input [`DataWidth_CSA30 - 1 : 0] CarryPP_CSA30,
  input [`DataWidth_CSA31 - 1 : 0] CarryPP_CSA31,
  input Mulitiplier_63,
  output [(`DataWidth * 2) - 1 : 0] Sum,
  output reg MulHoldEndToEx
);
  reg [`DataWidth_CSA40 - 1 : 0] SumPP_CSA40Inside;
  reg [`DataWidth_CSA40 - 1 : 0] CarryPP_CSA40Inside;
  
  reg Mulitiplier_63Inside;
  reg [1:0] MulHoldFlagFromExInside;
  // Forth Level
  // CSA40 width = data_width
  wire [`DataWidth_CSA40 - 1 : 0] SumPP_CSA40;
  wire [`DataWidth_CSA40 - 1 : 0] CarryPP_CSA40;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA40)) CSA_40({32'h0000_0000, SumPP_CSA30}, {SumPP_CSA31, 30'h0000_0000}, {32'h0000_0000, CarryPP_CSA30}, {CarryPP_CSA31, 30'h0000_0000}, SumPP_CSA40, CarryPP_CSA40);

  AddPP_FivL u_AddPP_FivL(Clk, Rst, MulHoldFlagFromExInside, SumPP_CSA40Inside, CarryPP_CSA40Inside, Mulitiplier_63Inside, Sum, MulHoldEndToEx);
  
  Reg #(2, 2'b0) Reg_MulHoldFlagFromExInside (Clk, Rst, MulHoldFlagFromEx, MulHoldFlagFromExInside, 1'b1);
  
  always @ (posedge Clk) begin
    if(!Rst) begin
      SumPP_CSA40Inside <= `DataWidth_CSA40'h0;
      CarryPP_CSA40Inside <= `DataWidth_CSA40'h0;
    end else begin
      SumPP_CSA40Inside <= SumPP_CSA40;
      CarryPP_CSA40Inside <= CarryPP_CSA40;
    end
  end
  
  Reg #(1, 1'b0) Reg_Mulitiplier_63Inside (Clk, Rst, Mulitiplier_63, Mulitiplier_63Inside, 1'b1);
endmodule
