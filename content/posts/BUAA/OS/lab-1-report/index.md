---
title: "[BUAA-OS] Lab 1 实验报告"
date: 2025-03-28T10:06:33+08:00
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

## Thinking 1.1

> 在阅读附录中的编译链接详解以及本章内容后，尝试分别使用实验环境中的原生x86工具链（gcc、ld、readelf、objdump等）和MIPS交叉编译工具链（带有mips-linux-gnu-前缀，如mips-linux-gnu-gcc、mips-linux-gnu-ld），重复其中的编译和解析过程，观察相应的结果，并解释其中向objdump传入的参数的含义。

---

```bash
git@23373270:~/test $  gcc -E hello.c > gcc-E.out

# gcc-E.out:

...(<stdio.h>的内容)

# 2 "hello.c" 2


# 3 "hello.c"
int main() {
    printf("Hello World!\n");
    return 0;
}

git@23373270:~/test $  mips-linux-gnu-gcc -E hello.c > mips-gcc-E.out

# mips-gcc-E.out:

...(<stdio.h>的内容)

# 2 "hello.c" 2


# 3 "hello.c"
int main() {
    printf("Hello World!\n");
    return 0;
}
```

进行预处理的情况下，两者几乎没有区别。

```bash
git@23373270:~/test $  gcc -c hello.c
git@23373270:~/test $  objdump -DS hello.o > objdump-DS.out

# objdump-DS.out:

hello.o：     文件格式 elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:   f3 0f 1e fa             endbr64
   4:   55                      push   %rbp
   5:   48 89 e5                mov    %rsp,%rbp
   8:   48 8d 05 00 00 00 00    lea    0x0(%rip),%rax        # f <main+0xf>
   f:   48 89 c7                mov    %rax,%rdi
  12:   e8 00 00 00 00          call   17 <main+0x17>
  17:   b8 00 00 00 00          mov    $0x0,%eax
  1c:   5d                      pop    %rbp
  1d:   c3                      ret

Disassembly of section .rodata:

0000000000000000 <.rodata>:
...

Disassembly of section .comment:

0000000000000000 <.comment>:
...

Disassembly of section .note.gnu.property:

0000000000000000 <.note.gnu.property>:
...

Disassembly of section .eh_frame:

0000000000000000 <.eh_frame>:
...

git@23373270:~/test $  mips-linux-gnu-gcc -c hello.c
git@23373270:~/test $  mips-linux-gnu-objdump -DS hello.o > mips-objdump-DS.out

# mips-objdump-DS.out:

hello.o：     文件格式 elf32-tradbigmips


Disassembly of section .text:

00000000 <main>:
   0:   27bdffe0        addiu   sp,sp,-32
   4:   afbf001c        sw      ra,28(sp)
   8:   afbe0018        sw      s8,24(sp)
   c:   03a0f025        move    s8,sp
  10:   3c1c0000        lui     gp,0x0
  14:   279c0000        addiu   gp,gp,0
  18:   afbc0010        sw      gp,16(sp)
  1c:   3c020000        lui     v0,0x0
  20:   24440000        addiu   a0,v0,0
  24:   8f820000        lw      v0,0(gp)
  28:   0040c825        move    t9,v0
  2c:   0320f809        jalr    t9
  30:   00000000        nop
  34:   8fdc0010        lw      gp,16(s8)
  38:   00001025        move    v0,zero
  3c:   03c0e825        move    sp,s8
  40:   8fbf001c        lw      ra,28(sp)
  44:   8fbe0018        lw      s8,24(sp)
  48:   27bd0020        addiu   sp,sp,32
  4c:   03e00008        jr      ra
  50:   00000000        nop
        ...

Disassembly of section .reginfo:

00000000 <.reginfo>:
...

Disassembly of section .MIPS.abiflags:

00000000 <.MIPS.abiflags>:
...

Disassembly of section .pdr:

00000000 <.pdr>:
...

Disassembly of section .rodata:

00000000 <.rodata>:
...

Disassembly of section .comment:

00000000 <.comment>:
...


Disassembly of section .gnu.attributes:

00000000 <.gnu.attributes>:
...

```

只编译不链接，生成目标文件，发现被编译为不同的汇编语言，且分别为64位和32位。

其中向`objdump`传入参数`-D`和`-S`。

```bash
git@23373270:~/test $  objdump --help
    -D, --disassemble-all    Display assembler contents of all sections
    -S, --source             Intermix source code with disassembly
```

`-D`：显示所有段的汇编内容
`-S`：将源代码与反汇编代码混合显示

## Thinking 1.2

> 思考下述问题：
> - 尝试使用我们编写的readelf程序，解析之前在target目录下生成的内核ELF文件。
> - 也许你会发现我们编写的readelf程序是不能解析readelf文件本身的，而我们刚才介绍的系统工具readelf则可以解析，这是为什么呢？（提示：尝试使用readelf -h，并阅读tools/readelf目录下的Makefile，观察readelf与hello的不同）

---

```bash
git@23373270:~/23373270 (lab1)$  tools/readelf/readelf target/mos
0:0x0
1:0x80020000
2:0x80021930
3:0x80021948
4:0x80021960
5:0x0
6:0x0
7:0x0
8:0x0
9:0x0
10:0x0
11:0x0
12:0x0
13:0x0
14:0x0
15:0x0
16:0x0
17:0x0
18:0x0
```

```bash
git@23373270:~/23373270/tools/readelf (lab1)$  readelf -h readelf
ELF 头：
  Magic：   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  类别:                              ELF64
  数据:                              2 补码，小端序 (little endian)
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI 版本:                          0
  类型:                              DYN (Position-Independent Executable file)
  系统架构:                          Advanced Micro Devices X86-64
  版本:                              0x1
  入口点地址：               0x1180
  程序头起点：          64 (bytes into file)
  Start of section headers:          14488 (bytes into file)
  标志：             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         13
  Size of section headers:           64 (bytes)
  Number of section headers:         31
  Section header string table index: 30
```

观察`tools/readelf/Makefile`：

```bash
readelf: main.o readelf.o
        $(CC) $^ -o $@

hello: hello.c
        $(CC) $^ -o $@ -m32 -static -g
```

区别在于`hello`为32位程序，`readelf`是64位程序，且`hello`的编译有`-static`修饰，是静态链接的。

## Thinking 1.3

> 在理论课上我们了解到，MIPS体系结构上电时，启动入口地址为0xBFC00000（其实启动入口地址是根据具体型号而定的，由硬件逻辑确定，也有可能不是这个地址，但一定是一个确定的地址），但实验操作系统的内核入口并没有放在上电启动地址，而是按照内存布局图放置。思考为什么这样放置内核还能保证内核入口被正确跳转到？
> 	（提示：思考实验中启动过程的两阶段分别由谁执行。）

---

系统能够正确跳转到内核入口在于两阶段启动过程和链接脚本控制：

1. 启动阶段划分

   - 阶段一：硬件上电后执行固化在 ROM 中的代码（地址 0xBFC00000）
   - 阶段二：Bootloader 加载操作系统内核到指定内存地址

2. 链接脚本控制（kernel.lds）

```ld
/*
 * Set the ENTRY point of the program to _start.
 */
ENTRY(_start)

SECTIONS {
    . = 0x80020000;
    .text : { *(.text) }
	...
}
```

3. 入口地址设置（start.S）

```mips
#include <asm/asm.h>
#include <mmu.h>

.text
EXPORT(_start)
.set at
.set reorder
/* Lab 1 Key Code "enter-kernel" */
    /* clear .bss segment */
    la      v0, bss_start
    la      v1, bss_end
    ...
    j       mips_init
```

实现原理：
1. Bootloader 将内核镜像加载到链接脚本指定的内存地址（0x80020000）
2. 通过`ENTRY(_start)`指定内核入口符号
3. 汇编代码中 `_start` 符号通过绝对跳转指令（`j mips_init`）转移到内核主函数

# 二、难点分析与实验体会

## 1. ELF文件

![](Pasted%20image%2020250328172841.png)

对ELF文件的概念缺少理解，写完`readelf`实际使用后才理解其含义。

# 三、原创说明

本以为是`readelf`在运行时无法读取自己，是因为自己正在运行导致的无法读取。在与赵德祥同学讨论后才注意到`readelf`与`hello`在64位和32位上的区别，在此致谢。