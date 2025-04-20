---
title: "[BUAA-OS] 理论作业 4"
date: 2025-04-17T21:25:00+08:00
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
**[点此查看作业源文件](作业4.pdf)**

# 1. 读者写者问题（写者优先）

1. 共享读;
2. 互斥写、读写互斥;
3. 写者优先于读者（一旦有写者，则后续读者必须等待，唤醒时优先考虑写者）。

---

```c
semaphore room_empty = 1;      // 读写互斥
semaphore mutex_read = 1;      // 保护 read_count
semaphore mutex_write = 1;     // 保护 write_count
semaphore write_priority = 1;  // 写者优先锁
int read_count = 0, write_count = 0;

void reader() {
    P(write_priority);         // 检查是否有写者等待
    P(mutex_read);
    read_count++;
    if (read_count == 1) {
        P(room_empty);         // 第一个读者获取读写锁
    }
    V(mutex_read);
    V(write_priority);         // 释放写者优先锁
    
    // 读取
    
    P(mutex_read);
    read_count--;
    if (read_count == 0) {
        V(room_empty);           // 最后一个读者释放读写锁
    }
    V(mutex_read);
}

void writer() {
    P(mutex_write);
    write_count++;
    if (write_count == 1) {
        P(write_priority);     // 第一个写者阻止新读者
    }
    V(mutex_write);
    
    P(room_empty);             // 获取读写锁
    
	// 写入
	
    V(room_empty);
    
    P(mutex_write);
    write_count--;
    if (write_count == 0) {
        V(write_priority);     // 最后一个写者允许新读者
    }
    V(mutex_write);
}
```

# 2. 寿司店问题

假设一个寿司店有5个座位，如果你到达的时候有一个空座位，你可以立刻就坐。但是如果你到达的时候5个座位都是满的有人已经就坐，这就意味着这些人都是一起来吃饭的，那么你需要等待所有的人一起离开才能就坐。编写同步原语，实现这个场景的约束。

---

```c
semaphore mutex = 1;         // 保护共享变量
semaphore batch_lock = 1;    // 批次锁
semaphore waiting = 0;       // 等待新批次
int count = 0;               // 当前批次人数

void customer() {
CONSUME:
    P(mutex);
    if (count == 0) {
        // 新批次开始
        P(batch_lock);       // 获取批次锁
    }
    if (count < 5) {
        count++;
        V(mutex);
        
        // 就坐
        
        // 离开
        
        P(mutex);
        count--;
        if (count == 0) {
            // 批次结束，唤醒等待者
            V(batch_lock);
            for (int i = 0; i < 5; i++) {
                V(waiting); // 唤醒最多5人
            }
        }
        V(mutex);
    } else {
        V(mutex);
        P(waiting);          // 等待新批次
		// 上一批次结束，被唤醒
        goto CONSUME;
    }
}
```

# 3. 进门问题。

## （1）请给出P、V操作和信号量的物理意义。

1. 信号量的物理意义：信号量是一种同步机制，用于控制多个进程/线程对共享资源的访问。可以看作是一个计数器，表示当前可用的资源数量或某种状态。
2. P操作的物理意义：表示申请资源。在互斥访问中，P(S) 相当于加锁。
3. V操作的物理意义：表示释放资源，如果有进程在等待该资源，则唤醒其中一个。在互斥访问中，V(S) 相当于解锁。

## （2）一个软件公司有5名员工，每人刷卡上班。员工刷卡后需要等待，直到所有员工都刷卡后才能进入公司。为了避免拥挤，公司要求员工一个一个通过大门。所有员工都进入后，最后进入的员工负责关门。请用P、V操作实现员工之间的同步关系。

---

```c
semaphore barrier = 0;       // 等待所有员工到达
semaphore door = 1;          // 控制逐个通过
semaphore mutex = 1;         // 保护计数器
int count = 0;

void employee() {
    P(mutex);
    count++;
    if (count == 5) {
        V(barrier);          // 第5人触发屏障
    }
    V(mutex);
    
    P(barrier);              // 所有员工等待在此
    V(barrier);              // 保持屏障信号
    
    P(door);
    
    // 通过大门
    
    V(door);
    
    P(mutex);
    count--;
    if (count == 0) {
    
        // 关门
        
    }
    V(mutex);
}
```

# 4. 搜索-插入-删除问题。

三个线程对一个单链表进行并发的访问，分别进行搜索、插入和删除。搜索线程仅仅读取链表，因此多个搜索线程可以并发。插入线程把数据项插入到链表最后的位置；多个插入线程必须互斥防止同时执行插入操作。但是，一个插入线程可以和多个搜索线程并发执行。最后，删除线程可以从链表中任何一个位置删除数据。一次只能有一个删除线程执行；删除线程之间，删除线程和搜索线程，删除线程和插入线程都不能同时执行。

请编写三类线程的同步互斥代码，描述这种三路的分类互斥问题。

---

```c
semaphore search_mutex = 1;    // 搜索并发控制
semaphore insert_mutex = 1;    // 插入互斥
semaphore delete_mutex = 1;    // 删除独占
int search_count = 0;

void search() {
    P(search_mutex);
    search_count++;
    if (search_count == 1) {
        P(delete_mutex);       // 阻止删除
    }
    V(search_mutex);
    
    // 搜索
    
    P(search_mutex);
    search_count--;
    if (search_count == 0) {
        V(delete_mutex);
    }
    V(search_mutex);
}

void insert() {
    P(insert_mutex);           // 插入互斥
    
    // 插入
    
    V(insert_mutex);
}

void delete() {
    P(delete_mutex);           // 独占删除
    
    // 删除
    
    V(delete_mutex);
}
```