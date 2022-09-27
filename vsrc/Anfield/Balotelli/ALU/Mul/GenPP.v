`include "./vsrc/defines.v"
module GenPP(
  input [`DataBus] Mulitiplicand,
  input [`DataBus] Mulitiplier,
  output [`DataWidth : 0] PartialProduct0,
  output [`DataWidth : 0] PartialProduct1,
  output [`DataWidth : 0] PartialProduct2,
  output [`DataWidth : 0] PartialProduct3,
  output [`DataWidth : 0] PartialProduct4,
  output [`DataWidth : 0] PartialProduct5,
  output [`DataWidth : 0] PartialProduct6,
  output [`DataWidth : 0] PartialProduct7,
  output [`DataWidth : 0] PartialProduct8,
  output [`DataWidth : 0] PartialProduct9,
  output [`DataWidth : 0] PartialProduct10,
  output [`DataWidth : 0] PartialProduct11,
  output [`DataWidth : 0] PartialProduct12,
  output [`DataWidth : 0] PartialProduct13,
  output [`DataWidth : 0] PartialProduct14,
  output [`DataWidth : 0] PartialProduct15,
  output [`DataWidth : 0] PartialProduct16,
  output [`DataWidth : 0] PartialProduct17,
  output [`DataWidth : 0] PartialProduct18,
  output [`DataWidth : 0] PartialProduct19,
  output [`DataWidth : 0] PartialProduct20,
  output [`DataWidth : 0] PartialProduct21,
  output [`DataWidth : 0] PartialProduct22,
  output [`DataWidth : 0] PartialProduct23,
  output [`DataWidth : 0] PartialProduct24,
  output [`DataWidth : 0] PartialProduct25,
  output [`DataWidth : 0] PartialProduct26,
  output [`DataWidth : 0] PartialProduct27,
  output [`DataWidth : 0] PartialProduct28,
  output [`DataWidth : 0] PartialProduct29,
  output [`DataWidth : 0] PartialProduct30,
  output [`DataWidth : 0] PartialProduct31
);

  wire [2:0] Segment0 = {Mulitiplier[1:0], 1'b0};
  wire [2:0] Segment1 = Mulitiplier[3:1];
  wire [2:0] Segment2 = Mulitiplier[5:3];
  wire [2:0] Segment3 = Mulitiplier[7:5];
  wire [2:0] Segment4 = Mulitiplier[9:7];
  wire [2:0] Segment5 = Mulitiplier[11:9];
  wire [2:0] Segment6 = Mulitiplier[13:11];
  wire [2:0] Segment7 = Mulitiplier[15:13];
  wire [2:0] Segment8 = Mulitiplier[17:15];
  wire [2:0] Segment9 = Mulitiplier[19:17];
  wire [2:0] Segment10 = Mulitiplier[21:19];
  wire [2:0] Segment11 = Mulitiplier[23:21];
  wire [2:0] Segment12 = Mulitiplier[25:23];
  wire [2:0] Segment13 = Mulitiplier[27:25];
  wire [2:0] Segment14 = Mulitiplier[29:27];
  wire [2:0] Segment15 = Mulitiplier[31:29];
  wire [2:0] Segment16 = Mulitiplier[33:31];
  wire [2:0] Segment17 = Mulitiplier[35:33];
  wire [2:0] Segment18 = Mulitiplier[37:35];
  wire [2:0] Segment19 = Mulitiplier[39:37];
  wire [2:0] Segment20 = Mulitiplier[41:39];
  wire [2:0] Segment21 = Mulitiplier[43:41];
  wire [2:0] Segment22 = Mulitiplier[45:43];
  wire [2:0] Segment23 = Mulitiplier[47:45];
  wire [2:0] Segment24 = Mulitiplier[49:47];
  wire [2:0] Segment25 = Mulitiplier[51:49];
  wire [2:0] Segment26 = Mulitiplier[53:51];
  wire [2:0] Segment27 = Mulitiplier[55:53];
  wire [2:0] Segment28 = Mulitiplier[57:55];
  wire [2:0] Segment29 = Mulitiplier[59:57];
  wire [2:0] Segment30 = Mulitiplier[61:59];
  wire [2:0] Segment31 = Mulitiplier[63:61];

  assign PartialProduct0 = BoothDecode(Segment0, Mulitiplicand);
  assign PartialProduct1 = BoothDecode(Segment1, Mulitiplicand);
  assign PartialProduct2 = BoothDecode(Segment2, Mulitiplicand);
  assign PartialProduct3 = BoothDecode(Segment3, Mulitiplicand);
  assign PartialProduct4 = BoothDecode(Segment4, Mulitiplicand);
  assign PartialProduct5 = BoothDecode(Segment5, Mulitiplicand);
  assign PartialProduct6 = BoothDecode(Segment6, Mulitiplicand);
  assign PartialProduct7 = BoothDecode(Segment7, Mulitiplicand);
  assign PartialProduct8 = BoothDecode(Segment8, Mulitiplicand);
  assign PartialProduct9 = BoothDecode(Segment9, Mulitiplicand);
  assign PartialProduct10 = BoothDecode(Segment10, Mulitiplicand);
  assign PartialProduct11 = BoothDecode(Segment11, Mulitiplicand);
  assign PartialProduct12 = BoothDecode(Segment12, Mulitiplicand);
  assign PartialProduct13 = BoothDecode(Segment13, Mulitiplicand);
  assign PartialProduct14 = BoothDecode(Segment14, Mulitiplicand);
  assign PartialProduct15 = BoothDecode(Segment15, Mulitiplicand);
  assign PartialProduct16 = BoothDecode(Segment16, Mulitiplicand);
  assign PartialProduct17 = BoothDecode(Segment17, Mulitiplicand);
  assign PartialProduct18 = BoothDecode(Segment18, Mulitiplicand);
  assign PartialProduct19 = BoothDecode(Segment19, Mulitiplicand);
  assign PartialProduct20 = BoothDecode(Segment20, Mulitiplicand);
  assign PartialProduct21 = BoothDecode(Segment21, Mulitiplicand);
  assign PartialProduct22 = BoothDecode(Segment22, Mulitiplicand);
  assign PartialProduct23 = BoothDecode(Segment23, Mulitiplicand);
  assign PartialProduct24 = BoothDecode(Segment24, Mulitiplicand);
  assign PartialProduct25 = BoothDecode(Segment25, Mulitiplicand);
  assign PartialProduct26 = BoothDecode(Segment26, Mulitiplicand);
  assign PartialProduct27 = BoothDecode(Segment27, Mulitiplicand);
  assign PartialProduct28 = BoothDecode(Segment28, Mulitiplicand);
  assign PartialProduct29 = BoothDecode(Segment29, Mulitiplicand);
  assign PartialProduct30 = BoothDecode(Segment30, Mulitiplicand);
  assign PartialProduct31 = BoothDecode(Segment31, Mulitiplicand);
  
  // FUNCTION: BoothDecode - Use Booth Encoding to generate partial products.
  // 此处生成的Booth编码并不是补码，而是反码！
  function [`DataWidth : 0] BoothDecode;
    input [2:0] Segment;
    input [`DataWidth - 1 : 0] Mulitiplicand;
    case ( Segment[2:0] )
         3'b000  :  BoothDecode = 65'h0_0000_0000_0000_0000;                                         // + Zero
         3'b001,
         3'b010  :  BoothDecode = { Mulitiplicand[`DataWidth-1], Mulitiplicand[`DataWidth-1:0] }  ; // +Mulitiplicand
         3'b011  :  BoothDecode = { Mulitiplicand[`DataWidth-1:0], 1'b0 }  ;                       // +2Mulitiplicand
         3'b100  :  BoothDecode = { ~Mulitiplicand[`DataWidth-1:0], 1'b1 }  ;                      // -2Mulitiplicand
         3'b101,
         3'b110  :  BoothDecode = { ~Mulitiplicand[`DataWidth-1], ~Mulitiplicand[`DataWidth-1:0] } ;// -Mulitiplicand
         3'b111  :  BoothDecode = 65'h1FFFFFFFF_FFFFFFFF;                                           // - Zero
    endcase
  endfunction

endmodule
