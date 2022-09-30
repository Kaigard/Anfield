/*
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-27 10:46:32
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 15:38:59
 * @FilePath: /Anfield/Vga/vga_ctrl.v
 * @Description: 本模块为NJU数字电路实验中的实验八，模块已经过验证，但集成到Soc后因未编写Stdio库，所以暂未进行集成后验证。（未来会进行验证。。。）
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
 */

module vga_ctrl (
    input pclk,
    input reset,
    input [23:0] vga_data,
    output [9:0] h_addr,
    output [9:0] v_addr,
    output hsync,
    output vsync,
    output valid,
    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b
);

parameter h_frontporch = 96;
parameter h_active = 144;
parameter h_backporch = 784;
parameter h_total = 800;

parameter v_frontporch = 2;
parameter v_active = 35;
parameter v_backporch = 515;
parameter v_total = 525;

reg [9:0] x_cnt;
reg [9:0] y_cnt;
wire h_valid;
wire v_valid;

always @(posedge pclk) begin
    if(!reset) begin
        x_cnt <= 1;
        y_cnt <= 1;
    end
    else begin
        if(x_cnt == h_total)begin
            x_cnt <= 1;
            if(y_cnt == v_total) y_cnt <= 1;
            else y_cnt <= y_cnt + 1;
        end
        else x_cnt <= x_cnt + 1;
    end
end

//生成同步信号    
assign hsync = (x_cnt > h_frontporch);
assign vsync = (y_cnt > v_frontporch);
//生成消隐信号
assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
assign valid = h_valid & v_valid;
//计算当前有效像素坐标
assign h_addr = h_valid ? (x_cnt - 10'd145) : 10'd0;
assign v_addr = v_valid ? (y_cnt - 10'd36) : 10'd0;
//设置输出的颜色值
assign {vga_r, vga_g, vga_b} = vga_data;

endmodule
