---
title: "[BUAA-OS] Lab 3 实验报告"
date: 2025-04-21T09:26:00+08:00
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

## Thinking 3.1

> 请结合MOS中的页目录自映射应用解释代码中 `e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_V` 的含义。

---

`UVPT`是用户页表的起始虚拟地址，所以`e->env_pgdir[PDX(UVPT)]`是当前进程的虚拟内存中，`UVPT`地址所在的页目录项。而`e->env_pgdir`是当前进程页目录的虚拟地址，`PADDR(e->env_pgdir)`则是其物理地址，`| PTE_V`是附上权限位。

这句赋值语句的含义是，将访问`UVPT`时解析的页目录项映射到的页框号设置为页目录的物理地址所在页的页框号，并附上权限位。

## Thinking 3.2

> elf_load_seg 以函数指针的形式，接受外部自定义的回调函数 map_page。请你找到与之相关的data这一参数在此处的来源，并思考它的作用。没有这个参数可不可以？为什么？

---

data 是传入`load_icode`函数的参数中的指向一个进程控制块的指针(`struct Env *`)。

不能没有这个参数。它的作用是传入`load_icode_mapper`类型转换为进程控制块指针，获取其`env_pgdir`并对其进程空间执行`page_insert`。缺少该参数则无法正常运行`load_icode_mapper`。

## Thinking 3.3

> 结合 elf_load_seg 的参数和实现，考虑该函数需要处理哪些页面加载的情况。

---

```c
int elf_load_seg(Elf32_Phdr *ph, const void *bin, elf_mapper_t map_page, void *data) {
	u_long va = ph->p_vaddr;
	size_t bin_size = ph->p_filesz;
	size_t sgsize = ph->p_memsz;
	u_int perm = PTE_V;
	if (ph->p_flags & PF_W) {
		perm |= PTE_D;
	}
	int r;
	size_t i;
	u_long offset = va - ROUNDDOWN(va, PAGE_SIZE);
	// 1.非页对齐的段起始地址  
    // 当段的虚拟地址va不是页对齐的（offset != 0），函数会先映射一个不完整的页，加载文件中对应的部分数据到该页的偏移位置。
	if (offset != 0) {
		if ((r = map_page(data, va, offset, perm, bin,
				  MIN(bin_size, PAGE_SIZE - offset))) != 0) {
			return r;
		}
	}
	// 2.逐页加载文件数据
	// 对于段中包含文件数据的部分（bin_size范围内），函数分页处理，每页调用map_page，将文件数据加载到对应虚拟地址。
	/* Step 1: load all content of bin into memory. */
	for (i = offset ? MIN(bin_size, PAGE_SIZE - offset) : 0; i < bin_size; i += PAGE_SIZE) {
		if ((r = map_page(data, va + i, 0, perm, bin + i, MIN(bin_size - i, PAGE_SIZE))) !=
		    0) {
			return r;
		}
	}
	// 3.内存扩展分配与零初始化
    // 当段的内存大小sgsize大于文件大小bin_size时，函数继续分配页并初始化为零，确保段在内存中完整分配。
	/* Step 2: alloc pages to reach `sgsize` when `bin_size` < `sgsize`. */
	while (i < sgsize) {
		if ((r = map_page(data, va + i, 0, perm, NULL, MIN(sgsize - i, PAGE_SIZE))) != 0) {
			return r;
		}
		i += PAGE_SIZE;
	}
	return 0;
}
```

## Thinking 3.4

> 思考上面这一段话，并根据自己在Lab2中的理解，回答：
> - 你认为这里的env_tf.cp0_epc存储的是物理地址还是虚拟地址?

---

`epc`存储的是**虚拟地址**。

## Thinking 3.5

> 试找出0、1、2、3号异常处理函数的具体实现位置。8号异常（系统调用）涉及的do_syscall()函数将在Lab4中实现。

---

0、1、2、3号异常处理函数的具体实现在`genex.S`中。

## Thinking 3.6

> 阅读entry.S、genex.S和env_asm.S这几个文件，并尝试说出时钟中断在哪些时候开启，在哪些时候关闭。

---

在`entry.S`中关闭时钟中断；
在`env_asm.S`中重置时钟；
在`genex.S`中开启时钟中断。

## Thinking 3.7

> 阅读相关代码，思考操作系统是怎么根据时钟中断切换进程的。

---

在进程运行时触发时钟中断，跳转`exc_gen_entry`，进入`hande_int`，从而通过`schedule`进行调度切换进程。

# 二、难点分析与实验体会

## 1. 进程的内存空间分布

- 进程的内存空间由页目录和页表进行管理，页目录项自映射使得页目录本身的物理地址能够被映射到虚拟地址空间（如`UVPT`）。这为内核提供了直接访问进程页目录的能力，方便进行页表操作和内存空间的管理。
- 进程的用户态页面（如代码段、数据段、堆栈等）通过页目录和页表进行映射，系统调用`elf_load_seg`等函数时，会根据 ELF 文件的程序头部信息，将文件中的代码和数据段加载到相应的虚拟地址，并设置正确的页权限。

## 2. 中断的处理流程

- 中断处理从硬件触发开始，CPU在检测到中断信号后，会暂停当前进程的执行，保存当前的执行上下文（如`cp0_epc`寄存器保存中断发生时的指令指针），并将控制权转移到中断处理程序。
- 时钟中断通过`genex.S`中的异常处理入口`exc_gen_entry`进行处理。内核会根据中断类型调用相应的处理函数，如时钟中断主要用于进程调度，通过调用`schedule`函数实现进程的切换。
- 中断处理需要考虑中断源的多样性，包括时钟中断、外部设备中断、软件异常等，并执行相应的处理逻辑。

# 三、原创说明

无参考资料。