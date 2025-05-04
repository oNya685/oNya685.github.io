---
title: "[BUAA-OS] 理论作业 5"
date: 2025-05-04T14:49:00+08:00
categories: Operating System
tags: 
author: 
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
**[点此查看作业源文件](作业5.pdf)**

# 1. 有五个进程P1、P2、P3、P4、P5，它们同时依次进入就绪队列，它们的优先数和需要的处理器时间如下表

| 进程  | 处理器时间 | 优先级<br>（数小优先级高） |
| :-: | :---: | :-------------: |
| P1  |  $10$   |        $3$        |
| P2  |   $1$   |        $1$        |
| P3  |   $2$   |        $3$        |
| P4  |   $1$   |        $4$        |
| P5  |   $5$   |        $2$        |

忽略进行调度等所花费的时间，回答下列问题：

## (1) 写出采用“先来先服务”、“短作业（进程）优先”、“非抢占式的优先数”和“轮转法”等调度算法，进程执行的次序。（其中轮转法的时间片为2）

|   调度算法    |       |       |       |       |       |        |        |        |        |        |        |
| :-------: | :---: | :---: | :---: | :---: | :---: | :----: | :----: | :----: | :----: | :----: | :----: |
|   先来先服务   |  P1   |  P2   |  P3   |  P4   |  P5   |        |        |        |        |        |        |
| 短作业（进程）优先 |  P2   |  P4   |  P3   |  P5   |  P1   |        |        |        |        |        |        |
| 非抢占式的优先数  |  P2   |  P5   |  P1   |  P3   |  P4   |        |        |        |        |        |        |
|    轮转法    | P1: 2 | P2: 3 | P3: 5 | P4: 6 | P5: 8 | P1: 10 | P5: 12 | P1: 14 | P5: 15 | P1: 17 | P1: 19 |

## (2) 分别计算上述算法中各进程的周转时间和等待时间，以及平均周转时间。

|   调度算法    | P1等待时间 | P2等待时间 | P3等待时间 | P4等待时间 | P5等待时间 |
| :-------: | :----: | :----: | :----: | :----: | :----: |
|   先来先服务   |   $0$    |   $10$   |   $11$   |   $13$   |   $14$   |
| 短作业（进程）优先 |   $9$    |   $0$    |   $2$    |   $1$    |   $4$    |
| 非抢占式的优先数  |   $6$    |   $0$    |   $16$   |   $18$   |   $1$    |
|    轮转法    |   $0$    |   $2$    |   $3$    |   $5$    |   $6$    |

|   调度算法    | P1周转时间 | P2周转时间 | P3周转时间 | P4周转时间 | P5周转时间 | 平均周转时间$T$ |
| :-------: | :----: | :----: | :----: | :----: | :----: | :-------: |
|   先来先服务   |   $10$   |   $11$   |   $13$   |   $14$   |   $19$   |   $13.4$    |
| 短作业（进程）优先 |   $19$   |   $1$    |   $4$    |   $2$    |   $9$    |     $7$     |
| 非抢占式的优先数  |   $16$   |   $1$    |   $18$   |   $19$   |   $6$    |    $12$     |
|    轮转法    |   $19$   |   $3$    |   $5$    |   $6$    |   $15$   |    $9.6$    |

# 2. 假设某系统使用时间片轮转调度算法进行CPU调度，时间片大小为5ms，系统共10个进程，初始时均处于就绪队列，执行结束前仅处于执行态或就绪态。若队尾的进程P所需的CPU时间最短，时间为25ms，不考虑系统开销，则进程P的周转时间为？

0-45ms在依次执行其他进程，45-50ms首次执行进程P，P剩余所需CPU时间20ms。

由于进程P所需的CPU时间最短，所以每周期执行进程P前都需要45ms依次执行其他进程，50ms为一周期。

以此类推，第195-200ms第四次执行进程P，P剩余所需CPU时间5ms。第200-245ms依次执行其他进程，第245-250ms第五次执行进程P，250ms时进程P执行结束。

故进程P的周转时间为250ms。

# 3. 某个进程调度程序采用基于优先数(priority)的调度策略，即选择优先数最小的进程运行，运行创建时由用户指定一个nice作为静态优先数。为了动态调整优先数，引入运行时间cpuTime和等待时间waitTime，初值为0。进程处于执行态时，cpuTime定时加1，且waitTime置0；进程处于就绪态时，cpuTime置0，waitTime定时加1。

## (1) 若调度程序只将nice的值作为进程优先级，即priority = nice，则可能出现饥饿现象。为什么？

当调度程序仅将用户指定的静态优先数 `nice` 作为进程优先级时，静态优先级无法动态调整。

若系统中持续有低 `nice` 值（高优先级）的进程到达，高 `nice` 值（低优先级）的进程可能因无法获得 CPU 时间而长期处于就绪队列，导致饥饿。低 `nice` 值的进程可能因优先级高而持续占用 CPU，即使其实际运行时间较长或资源需求不合理，也会挤压其他进程的执行机会。

## (2) 使用nice，cpuTime，waitTime设计一种动态优先数计算方法，以避免产生饥饿现象，并说明waitTime的作用

设计动态优先数公式：

$$\text{priority} = \text{nice} + k_1 \times \text{cpuTime} - k_2 \times \text{waitTime}, k_1 > 0, k_2 > 0$$

• `k1 > 0`：惩罚 CPU 占用时间长的进程（防止 CPU 霸占）。

• `k2 > 0`：补偿等待时间长的进程（避免饥饿）。

• `cpuTime` 的作用：进程运行时，`cpuTime` 定时增加。若进程长期占用 CPU，其优先级会因 `cpuTime` 增大而降低，从而让出 CPU 给其他进程。

• `waitTime` 的作用：进程就绪时，`waitTime` 定时增加。其值越大，优先级提升越多，确保长时间等待的进程能被及时调度，通过补偿等待时间，确保低优先级进程最终能被调度，避免饥饿。

# 4. 死锁

## (1) 有m个同类资源供n个进程共享，若每个进程最多申请k个资源（k>=1），采用银行家算法分配资源，为保证系统不发生死锁，则各进程的最大需求量之和为？并说明理由

最坏情况下，每个进程均已分配$k-1$个资源，此时要保证存在至少一个安全序列。则剩余资源$m-n\times (k-1) \geq 1$，即需求量之和$nk\leq m+n-1$。

因此，各进程的最大需求量之和为$m+n-1$。

## (2) 有8台打印机，由K个进程竞争使用，每个进程最多使用3台打印机。求K的最大值，使系统可能发生死锁。

为使系统发生死锁，$3\times K \geq 8 + K$，即$K \geq 4$。所以：

使系统不发生死锁的K的最大值为3；

使系统可能发生死锁的K的最小值为4。

## (3) 某系统有n台互斥使用的同类设备，三个并发进程分别需要3，4，5台设备。求n的最小值，使系统不发生死锁。

假设给三个并发进程已经分别发配了2，3，4台设备，则剩余资源$n-2-3-4\geq 1$，即$n \geq 10$。

故使系统不发生死锁的最小值为10。

# 5. 什么是进程之间的同步关系？什么是进程之间的互斥关系？

- 互斥：某一资源同时只允许一个访问者对其进行访问，具有唯一性和排它性
- 同步：是指在互斥的基础上（大多数情况），通过其它机制实现访问者对资源的有序访问

# 6. 假设具有5个进程的进程集合P= {P0,P1,P2,P3,P4}，系统中有三类资源A,B,C，假设在某时刻有如下状态：

| 进程  |                       Allocation                       |                       Max                       |                     Available                     |
| :-: | :----------------------------------------------------: | :---------------------------------------------: | :---------------------------------------------: |
|     | $\left(\begin{matrix} A && B && C \end{matrix}\right)$ | $\left(\begin{matrix} A && B && C \end{matrix}\right)$ | $\left(\begin{matrix} A && B && C \end{matrix}\right)$ |
| P0  |     $\left(\begin{matrix} 0 && 0 && 3 \end{matrix}\right)$     |   $\left(\begin{matrix} 0 && 0 && 4 \end{matrix}\right)$  |   $\left(\begin{matrix} 1 && 4 && 0 \end{matrix}\right)$  |
| P1  |     $\left(\begin{matrix} 1 && 0 && 0 \end{matrix}\right)$     |   $\left(\begin{matrix} 1 && 7 && 5 \end{matrix}\right)$  |                                                 |
| P2  |     $\left(\begin{matrix} 1 && 3 && 5 \end{matrix}\right)$     |   $\left(\begin{matrix} 2 && 3 && 5 \end{matrix}\right)$  |                                                 |
| P3  |     $\left(\begin{matrix} 0 && 0 && 2 \end{matrix}\right)$     |   $\left(\begin{matrix} 0 && 6 && 4 \end{matrix}\right)$  |                                                 |
| P4  |     $\left(\begin{matrix} 0 && 0 && 1 \end{matrix}\right)$     |   $\left(\begin{matrix} 0 && 6 && 5 \end{matrix}\right)$  |                                                 |

## (1) 根据上表内容，当前系统是否处于安全状态？

|                          Work                           | 进程  |                          Need                          |                       Allocation                       |                     Work+Allocation                     | Finish |
| :-----------------------------------------------------: | :-: | :----------------------------------------------------: | :----------------------------------------------------: | :-----------------------------------------------------: | ------ |
| $\left(\begin{matrix} A && B && C \end{matrix}\right)$  |     | $\left(\begin{matrix} A && B && C \end{matrix}\right)$ | $\left(\begin{matrix} A && B && C \end{matrix}\right)$ | $\left(\begin{matrix} A && B && C \end{matrix}\right)$  |        |
| $\left(\begin{matrix} 1 && 4 && 0 \end{matrix}\right)$  | P2  | $\left(\begin{matrix} 1 && 0 && 0 \end{matrix}\right)$ | $\left(\begin{matrix} 1 && 3 && 5 \end{matrix}\right)$ | $\left(\begin{matrix} 2 && 7 && 5 \end{matrix}\right)$  | `true` |
| $\left(\begin{matrix} 2 && 7 && 5 \end{matrix}\right)$  | P0  | $\left(\begin{matrix} 0 && 0 && 1 \end{matrix}\right)$ | $\left(\begin{matrix} 0 && 0 && 3 \end{matrix}\right)$ | $\left(\begin{matrix} 2 && 7 && 8 \end{matrix}\right)$  | `true` |
| $\left(\begin{matrix} 2 && 7 && 8 \end{matrix}\right)$  | P1  | $\left(\begin{matrix} 0 && 7 && 5 \end{matrix}\right)$ | $\left(\begin{matrix} 1 && 0 && 0 \end{matrix}\right)$ | $\left(\begin{matrix} 3 && 7 && 8 \end{matrix}\right)$  | `true` |
| $\left(\begin{matrix} 3 && 7 && 8 \end{matrix}\right)$  | P3  | $\left(\begin{matrix} 0 && 6 && 2 \end{matrix}\right)$ | $\left(\begin{matrix} 0 && 0 && 2 \end{matrix}\right)$ | $\left(\begin{matrix} 3 && 7 && 10 \end{matrix}\right)$ | `true` |
| $\left(\begin{matrix} 3 && 7 && 10 \end{matrix}\right)$ | P4  | $\left(\begin{matrix} 0 && 6 && 4 \end{matrix}\right)$ | $\left(\begin{matrix} 0 && 0 && 1 \end{matrix}\right)$ | $\left(\begin{matrix} 3 && 7 && 11 \end{matrix}\right)$ | `true` |

当前系统处于安全状态，存在安全序列：$\text{P2} \to \text{P0} \to \text{P1} \to \text{P3} \to \text{P4}$

## (2) 若系统中的可利用资源 Available 为（0,6,2），系统是否安全？若系统处在安全状态，请给出安全序列；若系统处在非安全状态，简要说明原因。

|                          Work                          | 进程  |                          Need                          |                       Allocation                       |                    Work+Allocation                     | Finish  |
| :----------------------------------------------------: | :-: | :----------------------------------------------------: | :----------------------------------------------------: | :----------------------------------------------------: | ------- |
| $\left(\begin{matrix} A && B && C \end{matrix}\right)$ |     | $\left(\begin{matrix} A && B && C \end{matrix}\right)$ | $\left(\begin{matrix} A && B && C \end{matrix}\right)$ | $\left(\begin{matrix} A && B && C \end{matrix}\right)$ |         |
| $\left(\begin{matrix} 0 && 6 && 2 \end{matrix}\right)$ | P0  | $\left(\begin{matrix} 0 && 0 && 1 \end{matrix}\right)$ | $\left(\begin{matrix} 0 && 0 && 3 \end{matrix}\right)$ | $\left(\begin{matrix} 0 && 6 && 5 \end{matrix}\right)$ | `true`  |
| $\left(\begin{matrix} 0 && 6 && 5 \end{matrix}\right)$ | P3  | $\left(\begin{matrix} 0 && 6 && 2 \end{matrix}\right)$ | $\left(\begin{matrix} 0 && 0 && 2 \end{matrix}\right)$ | $\left(\begin{matrix} 0 && 6 && 7 \end{matrix}\right)$ | `true`  |
| $\left(\begin{matrix} 0 && 6 && 7 \end{matrix}\right)$ | P4  | $\left(\begin{matrix} 0 && 6 && 4 \end{matrix}\right)$ | $\left(\begin{matrix} 0 && 0 && 1 \end{matrix}\right)$ | $\left(\begin{matrix} 0 && 6 && 8 \end{matrix}\right)$ | `true`  |
| $\left(\begin{matrix} 0 && 6 && 8 \end{matrix}\right)$ | P1  | $\left(\begin{matrix} 0 && 7 && 5 \end{matrix}\right)$ | $\left(\begin{matrix} 1 && 0 && 0 \end{matrix}\right)$ |                           ——                           | `false` |
| $\left(\begin{matrix} 0 && 6 && 8 \end{matrix}\right)$ | P2  | $\left(\begin{matrix} 1 && 0 && 0 \end{matrix}\right)$ | $\left(\begin{matrix} 1 && 3 && 5 \end{matrix}\right)$ |                           ——                           | `false` |

因此，系统处于非安全状态。

1. 部分进程可执行：  
	- 初始可用资源 `(0,6,2)` 可满足 P0（Need `(0,0,1)`），执行后释放资源，可用资源更新为 `(0,6,5)`。
	- 资源 `(0,6,5)` 可满足 P3（Need `(0,6,2)`），执行后可用资源更新为 `(0,6,7)`。
	- 资源 `(0,6,7)` 可满足 P4（Need `(0,6,4)`），执行后可用资源更新为 `(0,6,8)`。
2. 剩余进程无法执行：  
	- P1 需要 `B=7`，但当前可用 `B=6`，资源不足。
	- P2 需要 `A=1`，但当前可用 `A=0`，资源不足。
3. 无法形成完整安全序列：  
	- `P0 → P3 → P4` 可执行，但剩余进程 P1 和 P2 的资源需求无法满足，无法形成完整安全序列。