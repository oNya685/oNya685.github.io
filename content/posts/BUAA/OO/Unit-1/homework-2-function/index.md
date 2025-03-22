---
title: "[BUAA-OO] Unit 1 递归函数调用的解析与计算"
date: 2025-03-05T20:48:35
categories: Object Oriented
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
# 函数调用处理机制

## 核心思路

1. **实参与形参分离**：通过`assignment`哈希表实现参数映射，实现**形参**（函数定义时的参数名）与**相对实参**（调用时传入的具体因子）的对应关系。
2. **递归替换**：通过`assign`方法逐层展开函数调用
3. **终止条件**：当递归到**初始定义**表达式时完成解析

## 关键实现步骤

### 数据结构

为函数调用因子引入通过`HashMap<String, Factor>`实现的新成员变量`assignment`，并在为语素实现的`assign`方法中作为传入参数。

对于`FuncCall`因子，引入`Integer index`，`FuncDefine`，`ArrayList<Factor>`，用于实现对Expr中的FuncCall因子的完全解析。

```java
public class FuncCall extends VarFactor {
private final ConstantFactor index;  
private final FuncDefine define;  
private final HashMap<BaseVar, Factor> assignment; // 实际参数列表
}
```

### 处理流程

通过`expr = expr.assign(null)`中调用`funcCall.define.get(index).assign(assignment).assign(null)`，因除`FuncCall`以外的其他语素有其`assign`方法，所以将不断递归下降直到`funcCall.define.get(1)`和`funcCall.define.get(0)`。此时再递归向下将不再出现`FuncCall`类，递归结束并逐级返回。从而实现的`Expr`的去`FuncCall`流程，以便进行`toPoly`和`simplify`。

1. **初始化调用**

   ```java
   expr = expr.assign(null);
   // 通过expr.assign(null)启动替换链条，null参数表示要解析的最上层表达式中的参数为绝对实参
   ```

2. **参数替换机制**

   ```java
   // FuncCall.java
   ExprFactor assign(HashMap<String, Factor> assignment) {
       return this.define.get(this.index)
           .assign(this.assignment)
           // 先应用this.assignment当前层的参数绑定
           .assign(assignment);
           // 再应用外层传入的assignment参数，实现参数作用域的嵌套覆盖
   }
   ```

3. **递归展开过程**

   ```
   // 高层调用 → 中间层展开 → 基础层解析
   funcCall.assign(null)
   → funcCall.define.get(index).assign(assignment).assign(null)
   → ...
   → funcCall'.define.get(index').assign(assignment').assign(assignment).assign(null)
   → ...
   → funcCall''.define.get(index'').assign(assignment'').assign(assignment').assign(assignment).assign(null)
   → ...
   → funcCall.define.get(0 | 1).assign... // 初始定义表达式
   ```

### 类方法实现

经`assign`方法，`BaseVar.assign(assignment)`返回`Factor`，`PowerFunc.assign(assignment)`返回`ExprFactor`，`FuncCall`递归调用`(Expr)define.get(this.index).assign(this.assignment).assign(assignment)`返回`ExprFactor`，其他语素的`assign`方法返回同类对象。最终递归返回不含`FuncCall`的纯`Expr`，即可施之`toPoly`方法。

|类名|assign方法行为|返回类型|
|---------|-------------------------|----------|
|BaseVar|直接返回对应的含相对实参的Factor|Factor|
|PowerFunc|返回参数赋值的ExprFactor|ExprFactor|
|FuncCall|递归调用下层定义进行参数替换|ExprFactor|
|其他因子|返回由自身组成语素.assign()构造的同类对象|同类对象|

## 处理终点

当递归到`define.get(0 | 1)`时：
1. 不再包含FuncCall对象，函数调用结构完全消解
2. 所有形参已被实际参数替换
3. 表达式完全展开为基本元素
4. 可安全调用`toPoly()`进行多项式转换
5. 可进行最终化简`simplify()`