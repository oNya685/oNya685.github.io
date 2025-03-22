---
title: 用Condition干掉notifyAll
date: 2025-03-17T16:04:09+08:00
categories: 
tags: 
author: 
showToc: true
draft: true
comments: true
description: Desc Text.
canonicalURL: "{{ .Permalink }}"
hideSummary: false
searchHidden: false
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: false
ShowWordCount: true
ShowRssButtonInSectionTermList: true
---
`synchronized`关键字修饰的局部代码块内，我们能通过`wait()`, `notify()`, `notifyAll()`方法来调控线程之间的协作。

# `notify()`和`notifyAll()`是什么？

我们先定义两个概念，一个是**等待池**，一个是**锁池**，它们都是随一个锁而形成的**暂存线程**的容器。具体来说：

**等待池**中的线程只有被**通知**（notify）时，才会进入**锁池**；否则什么也不做。

**锁池**中的线程会不断尝试**抢锁**，如果抢到了锁，会进入`synchronized`，从开头或上次离开的位置（通过wait离开时）继续执行。

当某线程尝试进入`synchronized`，即尝试**抢锁**，但**失败**了（因为有其他线程在占用这把锁）时，它会进入**锁池**，持续不断尝试抢锁。

当某线程**抢锁成功**，进入了`synchronized`，它会离开**锁池**。

当某线程进入了`synchronized`，并遵循程序的设计，执行了`wait()`方法，它会进入**等待池**。

当某线程在`synchronized`中执行了`notify()`方法，会从**等待池**中随机选取一个线程让其移动到**锁池**。

当某线程在`synchronized`中执行了`notifyAll()`方法，会将**等待池**中的所有线程移动到**锁池**。

# 什么时候用`notify()`，什么时候用`notifyAll`？

## 考虑某多线程任务

假设我们有一个资源池，生产者线程向其中添加资源，消费者线程从中获取资源。我们需要确保生产者在资源池满时等待，消费者在资源池空时等待。

```java
import java.util.LinkedList;
import java.util.Queue;

public class ResourcePool {
    private Queue<Object> resources = new LinkedList<>();
    private int capacity;
    private final Object lock = new Object();

    public ResourcePool(int capacity) {
        this.capacity = capacity;
    }

    public void rent(Object resource) {
        synchronized (lock) {
            while (resources.size() >= capacity) {
                try {
	                System.out.println("生产者进入等待");
                    lock.wait(); // 如果资源池已满，生产者等待
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println("生产者被唤醒");
            }
            resources.add(resource);
            System.out.println("生产者: 生产了一个资源, 当前资源数: " + resources.size());
            lock.notify(); // 唤醒等待的消费者线程
        }
    }

    public Object consume() {
        synchronized (lock) {
            while (resources.isEmpty()) {
                try {
	                System.out.println("消费者进入等待");
                    lock.wait(); // 如果资源池为空，消费者等待
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println("消费者被唤醒");
            }
            Object resource = resources.remove();
            System.out.println("消费者: 消费了一个资源, 当前资源数: " + resources.size());
            lock.notify(); // 唤醒等待的生产者线程
            return resource;
        }
    }
}

public class Main {
    public static void main(String[] args) {
        ResourcePool pool = new ResourcePool(1);

        // 借用者1
        Thread renter = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                pool.rent();
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        producer.start();
        consumer.start();
    }
}
```

在本例中，只有一个生产者线程和一个消费者线程，它们`notify()`时，只会唤醒彼此，它们被唤醒并继续运行的条件均为`resources`暂时没被其他人访问。

## 考虑生产者-消费者多线程任务

在生产者-消费者模型中，生产者和消费者线程需要协调工作。生产者在资源池满时等待，消费者在资源池空时等待。当资源池有空间或有资源时，相应的线程被唤醒。

```java
import java.util.LinkedList;
import java.util.Queue;

public class ResourcePool {
    private Queue<Object> resources = new LinkedList<>();
    private int capacity;
    private final Object lock = new Object();

    public ResourcePool(int capacity) {
        this.capacity = capacity;
    }

    public void produce(Object resource) {
        synchronized (lock) {
            while (resources.size() >= capacity) {
                try {
	                System.out.println("生产者进入等待");
                    lock.wait(); // 如果资源池已满，生产者等待
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println("生产者被唤醒");
            }
            resources.add(resource);
            System.out.println("生产者: 生产了一个资源, 当前资源数: " + resources.size());
            lock.notifyAll(); // 唤醒所有等待的消费者线程
        }
    }

    public Object consume() {
        synchronized (lock) {
            while (resources.isEmpty()) {
                try {
	                System.out.println("消费者进入等待");
                    lock.wait(); // 如果资源池为空，消费者等待
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println("消费者被唤醒");
            }
            Object resource = resources.remove();
            System.out.println("消费者: 消费了一个资源, 当前资源数: " + resources.size());
            lock.notifyAll(); // 唤醒所有等待的生产者线程
            return resource;
        }
    }
}

public class Main {
    public static void main(String[] args) {
        ResourcePool pool = new ResourcePool(3);

        // 生产者线程
        Thread producer = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                pool.produce(new Object());
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        // 消费者线程1
        Thread consumer1 = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                pool.consume();
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        // 消费者线程2
        Thread consumer2 = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                pool.consume();
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        producer.start();
        consumer1.start();
        consumer2.start();
    }
}
```

### 为什么要用`notifyAll()`？用`notify()`会怎么样？

使用`notifyAll()`会唤醒所有等待的线程，确保它们都能重新评估条件。而使用`notify()`只唤醒一个线程，可能会导致该锁**假死**：有线程在等待，但没有线程在占用或竞争该锁。

如果使用`notify()`：
- 如果当前资源数为1，且消费者1消耗了一个资源并执行`notify()`，此时资源数为0；
	- 如果消费者1恰好`notify()`了生产者，正常运行；
	- 如果不巧，消费者1`notify()`了消费者2，消费者2会因为没有可用资源而重新`wait()`；
		- 此时三者都处于等待池，锁池为空，程序陷入**假死**。

如果使用`notifyAll()`：
- 所有等待的线程都会被唤醒，重新评估条件。
- 即使某些线程发现条件不满足并继续等待，其他线程仍然有机会执行。

## 如何判断用`notify()`还是`notifyAll()`？

判断使用`notify()`还是`notifyAll()`的关键在于线程等待的**条件**（condition）是否相同。

- 如果所有等待的线程都在等待同一个条件，使用`notify()`可能足够。
- 如果线程等待的条件不同，或者需要确保所有线程都能重新评估条件，使用`notifyAll()`更安全。

> 要是我们能给不同的线程设置不同的等待条件该多好。生产者生产后只唤醒条件为`资源不为空`的消费者，消费者消费后只唤醒条件为`资源不为满`的生产者们，那就肯定不会假死了！

## 用`synchronized`的代码怎么改造成用`ReentrantLock`和`Condition`

### 什么是`ReentrantLock`

`ReentrantLock`是一个可重入的互斥锁，它提供了与`synchronized`类似的功能，但更加灵活。它允许更细粒度的锁控制，并且可以配合`Condition`对象使用。

### `Condition`有什么优势

`Condition`接口提供了类似于`wait()`、`notify()`和`notifyAll()`的方法，但更加灵活。它允许一个锁对象有多个`Condition`实例，每个实例可以用于不同的条件等待和通知。

### 代码改造

将上述代码改造成使用`ReentrantLock`和`Condition`：

```java
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class ResourcePool {
    private Queue<Object> resources = new LinkedList<>();
    private int capacity;
    private final Lock lock = new ReentrantLock();
    private final Condition notFull = lock.newCondition();
    private final Condition notEmpty = lock.newCondition();

    public ResourcePool(int capacity) {
        this.capacity = capacity;
    }

    public void produce(Object resource) {
        lock.lock();
        try {
            while (resources.size() >= capacity) {
                notFull.await(); // 如果资源池已满，生产者等待
            }
            resources.add(resource);
            System.out.println("生产者: 生产了一个资源, 当前资源数: " + resources.size());
            notEmpty.signal(); // 唤醒单个等待的消费者线程
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            lock.unlock();
        }
    }

    public Object consume() {
        lock.lock();
        try {
            while (resources.isEmpty()) {
                notEmpty.await(); // 如果资源池为空，消费者等待
            }
            Object resource = resources.remove();
            System.out.println("消费者: 消费了一个资源, 当前资源数: " + resources.size());
            notFull.signal(); // 唤醒单个等待的生产者线程
            return resource;
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            lock.unlock();
        }
    }
}

public class Main {
    public static void main(String[] args) {
        ResourcePool pool = new ResourcePool(3);

        // 生产者线程
        Thread producer = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                pool.produce(new Object());
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        // 消费者线程1
        Thread consumer1 = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                pool.consume();
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        // 消费者线程2
        Thread consumer2 = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                pool.consume();
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        producer.start();
        consumer1.start();
        consumer2.start();
    }
}
```

### 改造后的代码解释

1. **锁的初始化**：
   - 使用`ReentrantLock`代替`synchronized`，提供更灵活的锁控制。

2. **条件的初始化**：
   - 为生产者和消费者分别创建两个`Condition`实例`notFull`和`notEmpty`，分别用于等待资源池满和空的条件。

3. **生产者方法**：
   - 在资源池满时，生产者线程调用`notFull.await()`进入等待。
   - 当资源池有空间时，调用`notEmpty.signal()`唤醒单个消费者线程。

4. **消费者方法**：
   - 在资源池空时，消费者线程调用`notEmpty.await()`进入等待。
   - 当资源池有资源时，调用`notFull.signal()`唤醒单个生产者线程。

通过这种改造，我们使用`ReentrantLock`和`Condition`实现了更灵活的线程同步，避免了`synchronized`的一些限制。