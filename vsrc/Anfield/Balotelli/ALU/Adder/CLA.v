module CLA_4Bits(PP,GP,S,A,B,CI);
  output          PP,GP;                  // Carry Propagate & Generate Prime
  output [3:0]    S;                      // Sum
  input  [3:0]    A,B;                    // Adder Inputs
  input           CI;                     // Carry In

  wire [3:0] P =  A | B;
  wire [3:0] G =  A & B;

  wire  C1 =  G[0] | P[0]&CI;
  wire  C2 =  G[1] | P[1]&C1;
  wire  C3 =  G[2] | P[2]&C2;
  wire [3:0] C = { C3, C2, C1, CI };

  assign PP = & P[3:0];
  assign GP = G[3] | P[3]&G[2] | P[3]&P[2]&G[1] | P[3]&P[2]&P[1]&G[0];
  assign S  =  A ^ B ^ C ;
endmodule

// Four Bit Carry Look-Ahead generator
module CLA_Gen_2Bits(PPP,GPP,C4,PP,GP,CI);
  output          PPP, GPP, C4;
  input  [1:0]    PP, GP;
  input           CI;

  assign C4=GP[0] | PP[0]&CI,
         GPP=GP[1] | PP[1]&GP[0],
         PPP=PP[1]&PP[0];

endmodule

// Four Bit Carry Look-Ahead generator
module CLA_Gen_4Bits(PPP,GPP,C4,C8,C12,PP,GP,CI);
  output          PPP, GPP, C4, C8, C12;
  input  [3:0]    PP, GP;
  input           CI;

      assign C4=GP[0] | PP[0]&CI,
             C8=GP[1] | PP[1]&GP[0] | PP[1]&PP[0]&CI,
             C12=GP[2] | PP[2]&GP[1] | PP[2]&PP[1]&GP[0] | PP[2]&PP[1]&PP[0]&CI,
             GPP=GP[3] | PP[3]&GP[2] | PP[3]&PP[2]&GP[1] | PP[3]&PP[2]&PP[1]&GP[0],
             PPP = & PP[3:0];

endmodule

// SixTeen Bit Slice Carry Look-Ahead Adder
module CLA_16Bits(PPP,GPP,S,A,B,CI);
  output          GPP, PPP;
  output [15:0]   S;
  input  [15:0]   A,B;
  input           CI;
  wire   [3:0]    PP, GP;
  wire            C4, C8, C12;

  CLA_4Bits  BITS30(PP[0],GP[0],S[3:0],A[3:0],B[3:0],CI),
             BITS74(PP[1],GP[1],S[7:4],A[7:4],B[7:4],C4),
             BITS118(PP[2],GP[2],S[11:8],A[11:8],B[11:8],C8),
             BITS1512(PP[3],GP[3],S[15:12],A[15:12],B[15:12],C12);

  CLA_Gen_4Bits GEN150(PPP,GPP,C4,C8,C12,PP[3:0],GP[3:0],CI);

endmodule

// Sixty-four Bit Slice Carry Look-Ahead Adder
module CLA_64Bits(PPP,GPP,S,A,B,CI);
  output          GPP, PPP;
  output [63:0]   S;
  input  [63:0]   A,B;
  input           CI;
  wire   [3:0]    PP, GP;
  wire            C16, C32, C48;
  
  CLA_16Bits     BITS15_0(PP[0],GP[0],S[15:0],A[15:0],B[15:0],CI),
                 BITS31_16(PP[1],GP[1],S[31:16],A[31:16],B[31:16],C16),
                 BITS47_32(PP[2],GP[2],S[47:32],A[47:32],B[47:32],C32),
                 BITS63_48(PP[3],GP[3],S[63:48],A[63:48],B[63:48],C48);

  CLA_Gen_4Bits  GEN63_0(PPP,GPP,C16,C32,C48,PP[3:0],GP[3:0],1'b0);

endmodule


// Thirty Two Bit Carry Look-Ahead Adder
//
module CLA_32Bit_Adder(CO,S,A,B,CI);
  output          CO;
  output [31:0]   S;
  input  [31:0]   A,B;
  input           CI;
  wire            GPP, PPP;
  wire   [1:0]    PP, GP;
  wire            C16, C32, C48;

  CLA_16Bits     BITS15_0(PP[0],GP[0],S[15:0],A[15:0],B[15:0],CI),
                 BITS31_16(PP[1],GP[1],S[31:16],A[31:16],B[31:16],C16);

  CLA_Gen_2Bits  GEN31_0(PPP,GPP,C16,PP[1:0],GP[1:0],CI);
  assign         CO =  GPP | PPP&CI;

endmodule

// SixtyFour Bit Carry Look-Ahead Adder
module CLA_64Bit_Adder(CO,S,A,B,CI);
  output          CO;
  output [63:0]   S;
  input  [63:0]   A,B;
  input           CI;
  wire            GPP, PPP;
  wire   [3:0]    PP, GP;
  wire            C16, C32, C48;

  CLA_16Bits     BITS15_0(PP[0],GP[0],S[15:0],A[15:0],B[15:0],CI),
                 BITS31_16(PP[1],GP[1],S[31:16],A[31:16],B[31:16],C16),
                 BITS47_32(PP[2],GP[2],S[47:32],A[47:32],B[47:32],C32),
                 BITS63_48(PP[3],GP[3],S[63:48],A[63:48],B[63:48],C48);

  CLA_Gen_4Bits  GEN63_0(PPP,GPP,C16,C32,C48,PP[3:0],GP[3:0],CI);
  assign         CO =  GPP | PPP&CI;

endmodule

// 128 Bit Carry Look-Ahead Adder
module CLA_128Bit_Adder_CLK(Clk, Rst, S, A, B);
  input Clk;
  input Rst;
  output reg [127:0]   S;
  input  [127:0]   A,B;
  wire            GPP, PPP;
  wire   [1:0]    PP, GP;
  wire            C64;
  reg [127:0] SInside;

  CLA_64Bits     BITS63_0(PP[0],GP[0],SInside[63:0],A[63:0],B[63:0],1'b0),
                 BITS128_64(PP[1],GP[1],SInside[127:64],A[127:64],B[127:64],C64);

  CLA_Gen_2Bits  GEN63_0(PPP,GPP,C64,PP[1:0],GP[1:0],1'b0);
  
  always @ (posedge Clk) begin
    if(!Rst) begin
      S <= 128'h0;
    end else begin
      S <= SInside;
    end
  end

endmodule

// 128 Bit Carry Look-Ahead Adder
module CLA_128Bit_Adder(S, A, B);
  output reg [127:0]   S;
  input  [127:0]   A,B;
  wire            GPP, PPP;
  wire   [1:0]    PP, GP;
  wire            C64;

  CLA_64Bits     BITS63_0(PP[0],GP[0],S[63:0],A[63:0],B[63:0],1'b0),
                 BITS128_64(PP[1],GP[1],S[127:64],A[127:64],B[127:64],C64);

  CLA_Gen_2Bits  GEN63_0(PPP,GPP,C64,PP[1:0],GP[1:0],1'b0);

endmodule
