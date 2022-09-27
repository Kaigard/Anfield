`include "./vsrc/defines.v"
module AddPP_SecL(
  input Clk,
  input Rst,
  input [1:0] MulHoldFlagFromEx,
  input [`DataWidth_CSA10 - 1 : 0] SumPP_CSA10,
  input [`DataWidth_CSA11 - 1 : 0] SumPP_CSA11,
  input [`DataWidth_CSA12 - 1 : 0] SumPP_CSA12,
  input [`DataWidth_CSA13 - 1 : 0] SumPP_CSA13,
  input [`DataWidth_CSA14 - 1 : 0] SumPP_CSA14,
  input [`DataWidth_CSA15 - 1 : 0] SumPP_CSA15,
  input [`DataWidth_CSA16 - 1 : 0] SumPP_CSA16,
  input [`DataWidth_CSA17 - 1 : 0] SumPP_CSA17,
  input [`DataWidth_CSA10 - 1 : 0] CarryPP_CSA10,
  input [`DataWidth_CSA11 - 1 : 0] CarryPP_CSA11,
  input [`DataWidth_CSA12 - 1 : 0] CarryPP_CSA12,
  input [`DataWidth_CSA13 - 1 : 0] CarryPP_CSA13,
  input [`DataWidth_CSA14 - 1 : 0] CarryPP_CSA14,
  input [`DataWidth_CSA15 - 1 : 0] CarryPP_CSA15,
  input [`DataWidth_CSA16 - 1 : 0] CarryPP_CSA16,
  input [`DataWidth_CSA17 - 1 : 0] CarryPP_CSA17,
  input Mulitiplier_63,
  output [(`DataWidth * 2) - 1 : 0] Sum,
  output MulHoldEndToEx
);
  reg [`DataWidth_CSA20 - 1 : 0] SumPP_CSA20Inside;
  reg [`DataWidth_CSA21 - 1 : 0] SumPP_CSA21Inside;
  reg [`DataWidth_CSA22 - 1 : 0] SumPP_CSA22Inside;
  reg [`DataWidth_CSA23 - 1 : 0] SumPP_CSA23Inside;
  reg [`DataWidth_CSA20 - 1 : 0] CarryPP_CSA20Inside;
  reg [`DataWidth_CSA21 - 1 : 0] CarryPP_CSA21Inside;
  reg [`DataWidth_CSA22 - 1 : 0] CarryPP_CSA22Inside;
  reg [`DataWidth_CSA23 - 1 : 0] CarryPP_CSA23Inside;
  
  reg Mulitiplier_63Inside;
  reg [1:0] MulHoldFlagFromExInside;
  // Second Level
  // CSA20 width = data_width
  wire [`DataWidth_CSA20 - 1 : 0] SumPP_CSA20;
  wire [`DataWidth_CSA20 - 1 : 0] CarryPP_CSA20;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA20)) CSA_20({8'h00, SumPP_CSA10}, {SumPP_CSA11, 6'h00}, {8'h00, CarryPP_CSA10}, {CarryPP_CSA11, 6'h00}, SumPP_CSA20, CarryPP_CSA20);

  // CSA21 width = data_width - 14
  wire [`DataWidth_CSA21 - 1 : 0] SumPP_CSA21;
  wire [`DataWidth_CSA21 - 1 : 0] CarryPP_CSA21;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA21)) CSA_21({8'h00, SumPP_CSA12}, {SumPP_CSA13, 8'h00}, {8'h00, CarryPP_CSA12}, {CarryPP_CSA13, 8'h00}, SumPP_CSA21, CarryPP_CSA21);
  
  // CSA21 width = data_width - 30
  wire [`DataWidth_CSA22 - 1 : 0] SumPP_CSA22;
  wire [`DataWidth_CSA22 - 1 : 0] CarryPP_CSA22;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA22)) CSA_22({8'h00, SumPP_CSA14}, {SumPP_CSA15, 8'h00}, {8'h00, CarryPP_CSA14}, {CarryPP_CSA15, 8'h00}, SumPP_CSA22, CarryPP_CSA22);

  // CSA21 width = data_width - 46
  wire [`DataWidth_CSA23 - 1 : 0] SumPP_CSA23;
  wire [`DataWidth_CSA23 - 1 : 0] CarryPP_CSA23;
  CasAdder4_2 #(.DataWidth(`DataWidth_CSA23)) CSA_23({8'h00, SumPP_CSA16}, {SumPP_CSA17, 8'h00}, {8'h00, CarryPP_CSA16}, {CarryPP_CSA17, 8'h00}, SumPP_CSA23, CarryPP_CSA23);

  AddPP_ThiL u_AddPP_ThiL(Clk, Rst, MulHoldFlagFromExInside, SumPP_CSA20Inside, SumPP_CSA21Inside, SumPP_CSA22Inside, SumPP_CSA23Inside, CarryPP_CSA20Inside, CarryPP_CSA21Inside, CarryPP_CSA22Inside, CarryPP_CSA23Inside, Mulitiplier_63Inside, Sum, MulHoldEndToEx);
  
  Reg #(2, 2'b0) Reg_MulHoldFlagFromExInside (Clk, Rst, MulHoldFlagFromEx, MulHoldFlagFromExInside, 1'b1);
  
  always @ (posedge Clk) begin
    if(!Rst) begin
      SumPP_CSA20Inside <= `DataWidth_CSA20'h0;
      SumPP_CSA21Inside <= `DataWidth_CSA21'h0;
      SumPP_CSA22Inside <= `DataWidth_CSA22'h0;
      SumPP_CSA23Inside <= `DataWidth_CSA23'h0;
      CarryPP_CSA20Inside <= `DataWidth_CSA20'h0;
      CarryPP_CSA21Inside <= `DataWidth_CSA21'h0;
      CarryPP_CSA22Inside <= `DataWidth_CSA22'h0;
      CarryPP_CSA23Inside <= `DataWidth_CSA23'h0;
    end else begin
      SumPP_CSA20Inside <= SumPP_CSA20;
      SumPP_CSA21Inside <= SumPP_CSA21;
      SumPP_CSA22Inside <= SumPP_CSA22;
      SumPP_CSA23Inside <= SumPP_CSA23;
      CarryPP_CSA20Inside <= CarryPP_CSA20;
      CarryPP_CSA21Inside <= CarryPP_CSA21;
      CarryPP_CSA22Inside <= CarryPP_CSA22;
      CarryPP_CSA23Inside <= CarryPP_CSA23;
    end
  end
  
  Reg #(1, 1'b0) Reg_Mulitiplier_63Inside (Clk, Rst, Mulitiplier_63, Mulitiplier_63Inside, 1'b1);

endmodule
