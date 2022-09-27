`include "./vsrc/defines.v"
module DivCore (
  input Clk,
  input Rst,
  //从Ex模块输入的信号
  input [`DataBus] Divisor,
  input [`DataBus] Dividend, 
  input [1:0] DivHoldFlagFromEx,
  input [`RegFileAddr] DivWriteAddrToDiv,
  input [6:0] DivOpCodeFromEx,
  input [2:0] DivFunct3FromEx,
  input [6:0] DivFunct7FromEx,
  //输出给Ex模块的信号
  output reg [`DataBus] Quotient,
  output reg [`DataBus] Remainder,
  output reg DivHoldEndToEx,                                          //该信号同样也会输出给Ctrl模块
  output [6:0] DivOpCodeToEx,
  output [2:0] DivFunct3ToEx,
  output [6:0] DivFunct7ToEx,
  output [`RegFileAddr] DivWriteAddrToEx
);
  //状态机状态，采用独热编码(本伪AI专业学生更愿意称之为互斥编码)
  parameter DivIdel = 4'b0001;
  parameter DivStart = 4'b0010;
  parameter DivRun = 4'b0100;
  parameter DivEnd = 4'b1000;
  
  reg [3:0] CurrentState;
  reg [3:0] NextState;
  //除法周期计数
  reg [6:0] DivCounter;
  reg [127:0] RemainderInside;
  //寄存除数和被除数，以防止混乱
  reg [`DataBus] DivisorInside;
  reg [`DataBus] DividendInside;
  //寄存部分关键信息，以返回Ex模块进行下一步操作
  reg [6:0] DivOpocdeInside;
  reg [2:0] DivFunct3Inside;
  reg [6:0] DivFunct7Inside;
  reg [`RegFileAddr] DivWriteAddrInside;
  //在Div开始时，对关键信息进行寄存
  always @ (posedge Clk) begin
    if(!Rst) begin
      DivisorInside <= `RegZero;
      DividendInside <= `RegZero;
      DivOpocdeInside <= 7'h00;
      DivFunct3Inside <= 3'h0;
      DivFunct7Inside <= 7'h00;
      DivWriteAddrInside <= 5'h00;
    end else if(DivHoldFlagFromEx == 2'b10) begin
      DivisorInside <= Divisor;
      DividendInside <= Dividend;
      DivOpocdeInside <= DivOpCodeFromEx;
      DivFunct3Inside <= DivFunct3FromEx;
      DivFunct7Inside <= DivFunct7FromEx;
      DivWriteAddrInside <= DivWriteAddrToDiv;
    end
  end
  //在Div计算结束时将关键信息返回Ex模块
  assign DivOpCodeToEx = DivHoldEndToEx ? DivOpocdeInside : 7'h00;
  assign DivFunct3ToEx = DivHoldEndToEx ? DivFunct3Inside : 3'h0;
  assign DivFunct7ToEx = DivHoldEndToEx ? DivFunct7Inside : 7'h00;
  assign DivWriteAddrToEx = DivHoldEndToEx ? DivWriteAddrInside : 5'h00;
  
  wire [`DataBus] ans;
  wire [`DataBus] InvDivisorInside = ~DivisorInside + 1;
  wire CarryOut;
  
  CLA_64Bit_Adder CLA_64Bit_Adder_Div(CarryOut, ans, RemainderInside[127:64], InvDivisorInside, 1'b0);
  //状态机第一段
  always @ (posedge Clk) begin
    if(!Rst) begin
      CurrentState <= DivIdel;
    end else begin
      CurrentState <= NextState;
    end
  end
  //状态机第二段，进行下一态转移确定
  always @ ( * ) begin
    case (CurrentState) 
      DivIdel : begin
        if(DivHoldFlagFromEx == 2'b10) begin
          NextState = DivStart;
        end else begin
          NextState = DivIdel;
        end
      end
      DivStart : begin
        NextState = DivRun;
      end
      DivRun : begin
        if(DivCounter == 7'h40) begin
          NextState = DivEnd;
        end else begin
          NextState = DivRun;
        end
      end
      DivEnd : begin
        NextState = DivIdel;
      end
      default : begin
        NextState = DivIdel;
      end
    endcase
  end
  //状态机第三段，进行结果输出
  always @ ( * ) begin
    case (CurrentState)
      DivIdel : begin
        Remainder = 64'b0;
        DivHoldEndToEx = 1'b0;
        Quotient = 64'b0;
      end
      DivStart : begin
        Remainder = 64'b0;
        DivHoldEndToEx = 1'b0;
        Quotient = 64'b0;
      end
      DivEnd : begin
        DivHoldEndToEx = 1'b1;
        Remainder = RemainderInside[127:64] >> 1;
        Quotient = RemainderInside[63:0];
      end
      default : begin
        Remainder = 64'b0;
        DivHoldEndToEx = 1'b0;
        Quotient = 64'b0;
      end
    endcase
  end
  //处理输出结果中的时序逻辑部分
  always @ (posedge Clk) begin
    if(!Rst) begin
      DivCounter <= 7'h00;
      RemainderInside <= 128'h0;
    end else begin
      case (CurrentState)
        DivStart : begin
          DivCounter <= 7'h00;
          RemainderInside <= {64'h0000_0000_0000_000, DividendInside};
        end
        DivRun : begin
          RemainderInside <= (CarryOut == 1) ? {ans[62:0], RemainderInside[63:0], 1'b1} : {RemainderInside[126:0], 1'b0};
          if(DivCounter == 7'h40) begin
            DivCounter <= 7'h00;
          end else begin
            DivCounter <= DivCounter + 1;
          end
        end
        default : begin
          DivCounter <= 7'h00;
          RemainderInside <= 128'h0;
        end
      endcase
    end
  end
endmodule
