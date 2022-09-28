<!--
 * @Author: Kai Zhou && zhouk9864@gmail.com
 * @Date: 2022-09-27 16:33:56
 * @LastEditors: Kai Zhou && zhouk9864@gmail.com
 * @LastEditTime: 2022-09-27 16:58:57
 * @FilePath: /Anfield/Readme.md
 * @Description: 
 * 
 * Copyright (c) 2022 by Kai Zhou zhouk9864@gmail.com, All Rights Reserved. 
-->
#### Anfield SoC
<font color=red>注意！！！  
此项目（V0.5）正在进行，必有Bug！！！  
此SoC绝大部分结构为作者自己瞎琢磨，因此有很多不合理之处！！！
想要合理正确的架构，请翻阅《CPU设计实战》及《超标量处理器设计》这两本书。
</font>

此SoC包含：
* Balotelli RISC-V 64IM核
* 不带字库RGB三色的VGA接口
* RAM、ROM行为级模型
* 未经验证的AXI-lite总线接口
* 不完整的Timer0 

> 除Balotelli核，其他外围设备均未进行完备验证。Balotelli核已通过大部分CPU-tests，中断异常模块未进行验证。  

Balotelli核框图如下：
<img src="https://github.com/Kaigard/Anfield/blob/V0.5/doc/design.png"> 

Balotelli核采用哈弗架构，实现了除Cache一致性指令以外的所有RISC-V 64IM指令，具体包含模块如下： 
* 数据通路五级流水
* 数据前推Fwu模块
* Ctrl控制模块
* 多周期乘、除法器
* PrePc伪地址寄存器
* Ifu预取指单元
* I-Cache
* 未经验证的AXI-lite Master接口 
* 未经验证的中断异常模块


Balotelli核亮点： 

* 尽量采用模块化建模（正在修改。。。）
* 使用PrePc与Pc双指令地址寄存器，将取指逻辑与总线接口逻辑解耦合，在核内尽量实现<font color=blue>硬连线的0周期状态</font>。
* 采用逐级互锁的流水控制方式，将Ex级以后流水阻塞与前级解耦。

> 硬连线的0周期状态：借助Cache，使得Ifu可以利用Pc地址直接取出指令，当Cache Missing时向流水线中注入气泡。

Balotelli核缺点：  
* 未实现D-Cache，访存周期浪费严重。
* 控制模块设计复杂混乱。
* I-Cache采用阻塞式直接映射，周期浪费严重。
