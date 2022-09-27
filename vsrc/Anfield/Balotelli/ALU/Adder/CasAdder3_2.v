module CasAdder3_2
#(parameter DataWidth = 128)
(
  input [DataWidth - 1 : 0] Addend0,
  input [DataWidth - 1 : 0] Addend1,
  input [DataWidth - 1 : 0] Addend2,
  output [DataWidth - 1 : 0] Sum,
  output [DataWidth - 1 : 0] Carry 
);

  assign Sum = Addend0 ^ Addend1 ^ Addend2;

  wire [DataWidth : 0] CarryMore = {(Addend0 & Addend2) | (Addend1 & Addend2) | (Addend0 & Addend1), 1'b0};

  assign Carry = CarryMore[DataWidth - 1 : 0];
  
  wire [DataWidth - 1 : 0] testsum0 = Addend0 + Addend1 + Addend2;
  wire [DataWidth - 1 : 0] testsum1 = Sum + Carry;
  
endmodule
