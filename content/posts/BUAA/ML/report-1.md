---
title: "[BUAA-ML] 第一次实验报告"
date: 2025-04-27T21:42:13+08:00
categories: 
tags: 
author: 
showToc: true
draft: false
comments: true
description: Linear Regression
canonicalURL: "{{ .Permalink }}"
hideSummary: false
searchHidden: false
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: false
ShowWordCount: true
ShowRssButtonInSectionTermList: true
---
机器学习实验报告

---

一、数据预处理：归一化与标准化处理  
（一）实验中的预处理方法  
1. 是否进行归一化/标准化  
   实验中使用了 标准化（Standardization） 处理，具体代码为：  
   ```python
   scaler = StandardScaler()
   X_train = scaler.fit_transform(X_train)
   X_test = scaler.transform(X_test)
   ```  
   • `fit_transform` 对训练集计算均值和标准差并应用转换。  

   • `transform` 对测试集直接使用训练集的参数进行转换。  


2. 归一化与标准化的区别  
   • 归一化（Normalization）：  

     将数据缩放到固定范围（如[0,1]），公式为：  
     \[
     x_{\text{norm}} = \frac{x - x_{\min}}{x_{\max} - x_{\min}}
     \]  
   • 标准化（Standardization）：  

     将数据调整为均值为0、标准差为1的分布，公式为：  
     \[
     x_{\text{std}} = \frac{x - \mu}{\sigma}
     \]  

3. 线性回归对特征尺度敏感的原因  
   • 解析解稳定性：参数解析解 \( w = (X^T X)^{-1} X^T y \) 中，若特征尺度差异大，矩阵 \( X^T X \) 的条件数增大，导致求逆不稳定。  

   • 梯度下降效率：不同尺度的特征需不同的学习率，尺度差异大会导致收敛速度慢。  


---

二、线性回归目标函数与参数求解  
（一）目标函数与解析解推导  
1. 目标函数：  
   \[
   J(w) = \sum_{i=1}^N (w^T x_i - y_i)^2
   \]  
2. 解析解推导：  
   • 矩阵形式：\( J(w) = (Xw - y)^T (Xw - y) \)  

   • 对 \( w \) 求导并令导数为零：  

     \[
     \frac{\partial J(w)}{\partial w} = 2X^T (Xw - y) = 0
     \]  
   • 解得：  

     \[
     w = (X^T X)^{-1} X^T y
     \]  

（二）标准方程组法与梯度下降法的对比  
1. 优势：  
   • 精确解：直接得到全局最优解，无需迭代调参。  

   • 效率高：当特征数 \( d \) 较小时（实验数据集特征数 \( d=8 \)），计算复杂度 \( O(d^3) \) 可接受。  

2. 劣势：  
   • 计算复杂度：若 \( d > 10^4 \)，矩阵求逆计算不可行。  

   • 内存限制：存储 \( X^T X \) 需要 \( O(d^2) \) 内存。  


---

三、模型评估指标分析  
（一）指标定义与意义  
1. 均方误差（MSE）：  
   \[
   \text{MSE} = \frac{1}{N} \sum_{i=1}^N (y_i - \hat{y}_i)^2
   \]  
   • 反映预测值与真实值的平均平方误差，值越小越好。  


2. 均方根误差（RMSE）：  
   \[
   \text{RMSE} = \sqrt{\text{MSE}}
   \]  
   • 与目标变量单位一致，更易解释误差的实际影响。  


3. 决定系数（R²）：  
   \[
   R^2 = 1 - \frac{\sum_{i=1}^N (y_i - \hat{y}_i)^2}{\sum_{i=1}^N (y_i - \bar{y})^2}
   \]  
   • 表示模型解释的方差比例，范围 \( (-\infty, 1] \)，越接近1越好。  


（二）R²为负的原因  
• 模型性能极差：当 \( \sum (y_i - \hat{y}_i)^2 > \sum (y_i - \bar{y})^2 \)，即模型预测比直接取均值更差。  

• 可能原因：  

  1. 数据存在严重噪声或非线性关系未被捕捉。  
  2. 特征与目标变量无关，模型欠拟合。  

---

四、非线性关系的拟合方法  
（一）问题分析  
直接使用线性回归无法捕捉特征与目标变量之间的非线性关系（如二次函数），导致预测性能下降。  

（二）改进方法  
1. 多项式特征扩展：  
   • 添加特征的高次项（如 \( x^2, x^3 \)）或交互项（如 \( x_1 x_2 \)）。  

   • 代码示例：  

     ```python
     poly = PolynomialFeatures(degree=2)
     X_poly = poly.fit_transform(X)
     ```  
2. 核方法（Kernel Trick）：  
   • 将特征映射到高维空间，间接实现非线性拟合。  

3. 树模型（如决策树、随机森林）：  
   • 直接处理非线性关系，但需牺牲模型可解释性。  


（三）实验中的应用建议  
• 在步骤二中引入 `PolynomialFeatures` 生成多项式特征，再使用线性回归拟合。  


---

结论  
实验通过标准化处理提升模型稳定性，利用线性回归解析解高效求解参数，并通过评估指标验证模型性能。针对非线性关系，可通过特征工程扩展模型表达能力。