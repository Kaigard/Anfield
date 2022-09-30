//触发器模板
`include "./vsrc/defines.v"
//当hold信号使能时不清除当前数据
module RegWithEnHoldData 
#(
  parameter WIDTH = 1,
  parameter RESET_VAL = 0
)
(
  input clk,
  input rst,
  input [WIDTH-1:0] din,
  input [`HoldFlagBus] en,
  output reg [WIDTH-1:0] dout,
  input wen
);

  always @(posedge clk) begin
    if (!rst | en == 3'b001 | en == 3'b011) dout <= RESET_VAL;
    else if (en == 3'b010 | en == 3'b100) dout <= dout;
    else if (wen) dout <= din;
  end
  
endmodule