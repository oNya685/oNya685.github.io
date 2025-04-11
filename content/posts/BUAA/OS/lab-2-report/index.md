---
title: "[BUAA-OS] Lab 2 实验报告"
date: 2025-04-11T09:53:55+08:00
categories: Operating System
tags: 
showToc: true
draft: false
comments: true
description: 
canonicalURL: "{{ .Permalink }}"
hideSummary: false
searchHidden: false
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: false
ShowWordCount: true
ShowRssButtonInSectionTermList: true
---
# 一、思考题

## Thinking 2.1

> 请根据上述说明，回答问题：在编写的 C 程序中，指针变量中存储的地址被视为虚拟地址，还是物理地址？MIPS 汇编程序中 lw和sw 指令使用的地址被视为虚拟地址，还是物理地址？

---

都是**虚拟地址**。本质都是翻译为含虚拟地址的机器码，交由CPU进行访存。

## Thinking 2.2

> 请思考下述两个问题：
> - 从可重用性的角度，阐述用宏来实现链表的好处。
> - 查看实验环境中的/usr/include/sys/queue.h，了解其中单向链表与循环链表的实现，比较它们与本实验中使用的双向链表，分析三者在插入与删除操作上的性能差异。

---

1. 通过宏定义，该链表实现了对于各种类型的可重用性。
	上机后补充：例如`MBlock`与其field（`mb_link`），可以直接使用该链表以及操作链表的宏（例如`LIST_INSERT_AFTER`与`LIST_REMOVE`）。
2. 比较单向链表、循环链表与双向链表：
		
| 操作  |         单向链表         |      循环链表      |         双向链表         |
| :-: | :------------------: | :------------: | :------------------: |
| 插入  | 性能相似，但插入到尾结点需要完整遍历链表 | 性能相似，但插入到尾结点更快 | 性能相似，但插入到尾结点需要完整遍历链表 |
| 删除  |   需要找上一结点的位置，O(n)    |   性能与双向链表相似    |      性能与循环链表相似       |

## Thinking 2.3

> 请阅读include/queue.h以及include/pmap.h,将Page_list的结构梳理清楚，选择正确的展开结构。

---

选C。

首先，`le_prev`是指向前继结点的后继指针的指针，类型是`struct Type **`，排除A。

其次，`lh_first`是指向链表首结点的指针，类型是`struct Type *`，排除B。

## Thinking 2.4

> 请思考下面两个问题：
> - 请阅读上面有关TLB的描述，从虚拟内存和多进程操作系统的实现角度，阐述ASID的必要性。
> - 请阅读 MIPS 4Kc 文档《MIPS32® 4K™ Processor Core Family Software User’s Manual》的 Section 3.3.1 与 Section 3.4，结合 ASID 段的位数，说明 4Kc 中可容纳不同的地址空间的最大数量。

---

1. 某一虚拟地址在不同地址空间中可以被映射到不同物理地址，所以需要ASID以确定地址空间。

2. 可容纳最多64个不同的地址空间。
```
Instead, the OS assigns a 6-bit unique code to each task’s distinct address space. Since the ASID is only 6 bits long, OS software does have to lend a hand if there are ever more than 64 address spaces in concurrent use; but it probably won’t happen too often.
```

## Thinking 2.5

> 请回答下述三个问题：
> - tlb_invalidate和tlb_out的调用关系？
> - 请用一句话概括tlb_invalidate的作用。
> - 逐行解释tlb_out中的汇编代码。

---

1. `tlb_invalidate`调用了`tlb_out`。
2. 调用`tlb_invalidate`可以将该地址与虚拟地址的映射表项从TLB中清除。
3. `tlb_out`：用于清除指定虚拟地址对应的TLB表项。通过先保存当前ENTRYHI值，然后设置新的ENTRYHI进行TLB探测，找到对应表项后通过写入空值实现删除，最后恢复原始ENTRYHI值。

```mips
LEAF(tlb_out)                    // 定义名为tlb_out的叶子函数
.set noreorder                   // 禁止汇编器重新排列指令顺序
	mfc0    t0, CP0_ENTRYHI      // 将协处理器CP0的ENTRYHI寄存器值保存到t0
	mtc0    a0, CP0_ENTRYHI      // 将参数寄存器a0的值写入CP0的ENTRYHI寄存器
	nop                          // 空操作，确保mtc0操作完成
	/* Step 1: Use 'tlbp' to probe TLB entry */
	/* Exercise 2.8: Your code here. (1/2) */
	tlbp                         // TLB探测指令，根据ENTRYHI查找匹配的TLB条目
	nop                          // 保证tlbp指令完成
	/* Step 2: Fetch the probe result from CP0.Index */
	mfc0    t1, CP0_INDEX        // 将CP0的INDEX寄存器值读取到t1
.set reorder                     // 允许汇编器重新排列指令顺序
	bltz    t1, NO_SUCH_ENTRY    // 如果未找到该ENTRY，跳转到NO_SUCH_ENTRY
.set noreorder                   // 再次禁止指令重排
	mtc0    zero, CP0_ENTRYHI    // 清零CP0的ENTRYHI寄存器
	mtc0    zero, CP0_ENTRYLO0   // 清零CP0的ENTRYLO0寄存器
	mtc0    zero, CP0_ENTRYLO1   // 清零CP0的ENTRYLO1寄存器
	nop                          // 保证寄存器写入操作完成
	/* Step 3: Use 'tlbwi' to write CP0.EntryHi/Lo into TLB at CP0.Index  */
	/* Exercise 2.8: Your code here. (2/2) */
	tlbwi                        // 将当前EntryHi/EntryLo写入TLB表项，删除该条目
.set reorder                     // 恢复指令重排

NO_SUCH_ENTRY:                   // 未找到对应TLB条目时的标签
	mtc0    t0, CP0_ENTRYHI      // 恢复原始ENTRYHI寄存器值
	j       ra                   // 函数返回
END(tlb_out)                     // 函数结束
```

## Thinking 2.6

> 请结合 Lab2 开始的 CPU 访存流程与下图中的 Lab2 用户函数部分，尝试将函数调用与CPU访存流程对应起来，思考函数调用与CPU访存流程的关系。

![图 2.9 - Lab2 in MOS](图%202.9%20-%20Lab2%20in%20MOS.png)

---

在 Lab2（以及后续实验）中，4Kc CPU 的访存过程可以概括为以下几个关键步骤
- 当 CPU 执行一条访存相关的指令（包含取指令、读数据、写数据）时，会把**虚拟地址**送入 MMU。
- MMU 会首先在 TLB 中查找该虚拟地址是否有对应的物理地址映射。
    - 若命中（TLB Hit），CPU 即可直接得知该虚拟地址对应的**物理地址**，并进行后续的读写缓存或内存操作。
    - 若未命中（TLB Miss），CPU 会触发异常，进入内核执行 TLB refill / page fault 处理流程（视情况而定），由操作系统的异常/中断处理例程负责查找该虚拟地址应对应的物理地址、分配物理页、更新 TLB。
- 当映射关系建立后，CPU 可以“拿到”正确的物理地址并进行实际的内存（或外设寄存器）读写操作。

在这个过程中，所看到的「kuseg、kseg0、kseg1」等地址段的区别，决定了 CPU 是否直接对高地址位清零映射（无缓存/有缓存）或者需要通过 TLB。**对于用户态的地址（kuseg，0x00000000~0x7fffffff），一定要通过 TLB**。

在 Lab2 中，当我们调用函数时，背后的硬件过程正是 CPU 发出虚拟地址、经 TLB 查表或异常处理、进而映射到物理地址并访问内存的流程。**函数调用是软件层面分配、管理地址空间的逻辑，而 CPU 访存流程是硬件层面真正将指令和数据从内存取出、写入的机制；两者一一对应、紧密耦合**。通过把它们结合起来，我们就能全面理解操作系统与用户态程序在地址空间管理上的工作原理。

## Thinking 2.7

> 从下述三个问题中任选其一回答：
> - 简单了解并叙述X86体系结构中的内存管理机制，比较X86和MIPS 在内存管理上的区别。
> - 简单了解并叙述RISC-V 中的内存管理机制，比较RISC-V 与 MIPS 在内存管理上的区别。
> - 简单了解并叙述LoongArch 中的内存管理机制，比较 LoongArch 与 MIPS 在内存管理上的区别。

---

X86 与 MIPS 内存管理的主要区别

- 分段机制与固定地址区间
	- **X86：**  
	    传统上依靠分段来实现内存保护和地址转换，虽然现代操作系统多采用扁平模型，但分段概念依然存在，并且在保护模式下提供了多级特权和动态调整段基址的能力。
	- **MIPS：**  
	    使用固定的地址区间划分（如kuseg、kseg0、kseg1），没有灵活的分段机制，内核与用户空间的划分由硬件地址范围直接确定，整体设计更加简单。
- 分页管理方式
	- **X86：**  
	    采用硬件支持的多级页表结构，地址转换过程由硬件直接完成（结合 TLB 缓存），在现代 x86-64 中使用 4 级或更多级页表，同时支持 PAE 和 NX 等扩展特性。
	- **MIPS：**  
	    通常依赖软件管理的 TLB，当发生 TLB miss 时，通过异常处理由操作系统完成页表查找和 TLB 填充，其页表结构也较为灵活，但整体在硬件自动化管理程度上较 X86 要简单。
- TLB 设计
	- **X86：**  
	    TLB 作为硬件缓存，通常与分页机制紧密结合，自动维护地址映射缓存，减少页表查找延迟。
	- **MIPS：**  
	    TLB 由软件管理，需要操作系统在 TLB miss 异常处理程序中主动维护，虽然这种设计在一定程度上降低了硬件复杂性，但对操作系统的设计与调度要求更高。

# 二、难点分析与实验体会

## 1. 链表宏的理解与使用

链表中大量指针，指针的指针，混杂在一起，较难理解其具体含义。经过`struct Page`链表的阅读及补全后初步理解链表宏的使用流程与传参细节。

## 2. 二级页表的实现

经过实验代码，我们能发现二级页表的页表项其实是`u_long`类型，由页框号与有效位组成。通过这一类型的实现有一些反直觉，在理解其为字对齐后便理解了一些实现细节。

# 三、原创说明

参考资料：
1. *MIPS32® 4K™ Processor Core Family Software User’s Manual*
2. [全网超详细解析！X86/X64处理器体系结构及寻址模式 - 知乎](https://zhuanlan.zhihu.com/p/549874101)
3. [X86内存管理机制--分段机制详析_x86 为什么要这么多段寄存器-CSDN博客](https://blog.csdn.net/d1306937299/article/details/87874422)