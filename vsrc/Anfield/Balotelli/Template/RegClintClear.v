// 触发器模板
module RegClintClear 
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
    if (!rst | en == 3'b011) begin
      dout <= RESET_VAL;
    end else if (wen) begin
      dout <= din;
    end
  end
  
endmodule