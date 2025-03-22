---
title: "[BUAA-OS] Lab 1"
date: 2025-03-15T18:59:20+08:00
categories: Operating System
tags: 
showToc: true
draft: true
comments: true
description: 内核、启动和 PRINTF
canonicalURL: "{{ .Permalink }}"
hideSummary: false
searchHidden: false
ShowReadingTime: true
ShowBreadCrumbs: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
cover:
  image: OSome.png
  caption: Logo of [操作系统课程平台](https://os.buaa.edu.cn/)
---
```bash
git@23373270:~/23373270/tools/readelf (lab1)$ ./readelf ../../target/mos
0:0x0
1:0x80020000
2:0x80021700
3:0x80021718
4:0x80021730
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
```

$$ bug修复基础分=\frac{修复的强测数据bug数 + 修复的互测数据bug数}{强测bug总数 + 互测bug总数}\times100 $$ $$ bug修复补偿分=\Sigma修复的强测数据点的正确性得分\times\alpha\ \ \ (其中\alpha为该数据点的bug修复补偿系数) $$

$$ bug修复分=bug修复基础分+bug修复补偿分 $$
