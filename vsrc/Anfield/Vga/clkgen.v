/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-27 10:46:32
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:39:15
 * @FilePath: /Anfield/Vga/clkgen.v
 * @Description: 本模块为NJU数字电路实验中的实验八，模块已经过验证，但集成到Soc后因未编写Stdio库，所以暂未进行集成后验证。（未来会进行验证。。。）
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module clkgen(
    input clkin,
    input rst,
    input clken,
    output reg clkout
    );
    parameter clk_freq=1000;
    parameter countlimit=50000000/2/clk_freq; //自动计算计数次数

  reg[31:0] clkcount;
  always @ (posedge clkin) begin
    if(!rst)
    begin
        clkcount=0;
        clkout=1'b0;
    end
    else
    begin
    if(clken)
        begin
            clkcount=clkcount+1;
            if(clkcount>=countlimit)
            begin
                clkcount=32'd0;
                clkout=~clkout;
            end
            else
                clkout=clkout;
        end
      else
        begin
            clkcount=clkcount;
            clkout=clkout;
        end
    end
  end  
endmodule
