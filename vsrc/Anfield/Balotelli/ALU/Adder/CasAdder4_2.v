//并不是完整意义上的CSA，因为不需要所以没有进位与溢出

module CasAdder4_2
#(parameter DataWidth = 128)
(
  input [DataWidth - 1 : 0] Addend0,
  input [DataWidth - 1 : 0] Addend1,
  input [DataWidth - 1 : 0] Addend2,
  input [DataWidth - 1 : 0] Addend3,
  output [DataWidth - 1 : 0] Sum,
  output [DataWidth - 1 : 0] Carry 
);
  /*
  wire [DataWidth - 1: 0] Addend0XorAddend1 = Addend0 ^ Addend1;
  wire [DataWidth - 1: 0] Addend2XorAddend3 = Addend2 ^ Addend3;
  wire [DataWidth - 1: 0] AllXor = Addend0XorAddend1 ^ Addend2XorAddend3;
  
  assign Sum = AllXor;
  
  wire [DataWidth : 0] CarryMore = {(Addend3AndAddend2 | Addend1AndAddend0 | Addend2AndAddend0 | Addend2AndAddend1 | Addend3AndAddend0 | Addend3AndAddend1), 1'b0};

  assign Carry = CarryMore[DataWidth - 1 : 0];
  */
  
  wire [DataWidth - 1 : 0] Addend1AndAddend0 = Addend1 & Addend0;
  wire [DataWidth - 1 : 0] Addend2AndAddend0 = Addend2 & Addend0;
  wire [DataWidth - 1 : 0] Addend2AndAddend1 = Addend2 & Addend1;
  
  wire [DataWidth - 1 : 0] Sum1 = Addend0 ^ Addend1 ^ Addend2;
  wire [DataWidth : 0] Carry1 = {(Addend1AndAddend0 | Addend2AndAddend0 | Addend2AndAddend1), 1'b0};
  
  wire [DataWidth - 1 : 0] Carry2 = Carry1[DataWidth - 1 : 0];
  
  assign Sum = Sum1 ^ Addend3 ^ Carry2;
  
  wire [DataWidth : 0] Carry3 = {((Sum1 & Addend3) | (Sum1 & Carry2) | (Addend3 & Carry2)), 1'b0};
  assign Carry[DataWidth - 1 : 0] = Carry3[DataWidth - 1 : 0];
  
  //wire [DataWidth - 1 : 0] testsum0 = Addend0 + Addend1 + Addend2 + Addend3;
  //wire [DataWidth - 1 : 0] testsum1 = Sum + Carry;
endmodule
