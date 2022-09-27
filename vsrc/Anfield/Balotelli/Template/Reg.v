// 触发器模板
module Reg #(WIDTH = 1, RESET_VAL = 0) (
  input clk,
  input rst,
  input [WIDTH-1:0] din,
  output reg [WIDTH-1:0] dout,
  input wen
);

  always @(posedge clk) begin
    if (!rst) begin
      dout <= RESET_VAL;
    end else if (wen) begin
      dout <= din;
    end
  end
  
endmodule