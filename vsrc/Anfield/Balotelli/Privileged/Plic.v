/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-26 20:35:23
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:54:57
 * @FilePath: /Anfield/Balotelli/Privileged/Plic.v
 * @Description: 外部中断模块，因只有Timer0一个带中断的外设，因此未涉及仲裁。
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module Plic (
  input Timer0IntIn,
  output IntAppearOut,
  output [`IntBus] IntFlagOut
);

  assign IntAppearOut = Timer0IntIn ? 1'b1 : 1'b0;
  assign IntFlagOut = Timer0IntIn ? 6'b001000 : 6'h00;

endmodule