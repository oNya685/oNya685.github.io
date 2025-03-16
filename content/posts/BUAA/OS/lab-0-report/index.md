---
title: "[BUAA-OS] Lab 0 实验报告"
date: 2025-03-16T11:27:33+08:00
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

## Thinking 0.1

> 思考下列有关Git的问题：
> - 在前述已初始化的~/learnGit 目录下，创建一个名为README.txt的文件。执 行命令git status > Untracked.txt（其中的 > 为输出重定向，我们将在0.6.3中详细介绍）。
> - 在README.txt 文件中添加任意文件内容，然后使用add命令，再执行命令git status > Stage.txt。
> - 提交README.txt，并在提交说明里写入自己的学号。
> - 执行命令cat Untracked.txt 和cat Stage.txt，对比两次运行的结果，体会README.txt两次所处位置的不同。
> - 修改README.txt 文件，再执行命令git status > Modified.txt。
> - 执行命令cat Modified.txt，观察其结果和第一次执行add命令之前的status是否一样，并思考原因。

---

### 1. Untracked.txt

```bash
$  cat Untracked.txt
位于分支 master
未跟踪的文件:
  （使用 "git add <文件>..." 以包含要提交的内容）
        README.txt
        Untracked.txt

提交为空，但是存在尚未跟踪的文件（使用 "git add" 建立跟踪）
```

新建了`README.txt`文件，处于Untracked状态。

### 2. Staged.txt

```bash
$  cat Staged.txt
位于分支 master
要提交的变更：
  （使用 "git restore --staged <文件>..." 以取消暂存）
        新文件：   README.txt

未跟踪的文件:
  （使用 "git add <文件>..." 以包含要提交的内容）
        Staged.txt
        Untracked.txt

```

修改了`README.txt`的文件内容，并跟踪和暂存该文件，处于Staged状态。

### 3. Modified.txt

```bash
$  cat Modified.txt
位于分支 master
尚未暂存以备提交的变更：
  （使用 "git add <文件>..." 更新要提交的内容）
  （使用 "git restore <文件>..." 丢弃工作区的改动）
        修改：     README.txt

未跟踪的文件:
  （使用 "git add <文件>..." 以包含要提交的内容）
        Modified.txt
        Staged.txt
        Untracked.txt

修改尚未加入提交（使用 "git add" 和/或 "git commit -a"）
```

`README.txt`经暂存和提交后处于Unmodified状态，修改文件内容使其进入Modified状态等待暂存。

## Thinking 0.2

> 仔细看看[0.10](图%200.10%20-%20Git%20中的四种状态转换关系.png)，思考一下箭头中的add the file、stage the file和commit分别对应的是Git里的哪些命令呢？
> 
> ![图 0.10 - Git 中的四种状态转换关系](图%200.10%20-%20Git%20中的四种状态转换关系.png)

---

### 1. add the file 

add the file 对应的是`git add`。

### 2. stage the file

stage the file 对应的是`git add`。

### 3. commit

commit 对应的是`git commit`。

## Thinking 0.3

> 思考下列问题：
> 1. 代码文件print.c被错误删除时，应当使用什么命令将其恢复？
> 2. 代码文件print.c被错误删除后，执行了git rm print.c命令，此时应当使用什么命令将其恢复？
> 3. 无关文件hello.txt已经被添加到暂存区时，如何在不删除此文件的前提下将其移出暂存区？

### 1. 代码文件 print.c 被错误删除时，应当使用什么命令将其恢复？

```bash
git restore print.c
```

print.c 尚未执行`git add`，故可以从暂存区将print.c恢复到工作区中。

### 2. 代码文件 print.c 被错误删除后，执行了 git rm print.c 命令，此时应当使用什么命令将其恢复？

```bash
git reset HEAD print.c
git restore print.c
```

首先撤销暂存区的修改（删除了print.c），然后将print.c从暂存区恢复到工作区。

### 3. 无关文件 hello.txt 已经被添加到暂存区时，如何在不删除此文件的前提下将其移出暂存区？

```bash
git reset HEAD hello.txt
```

撤销暂存区的修改，把暂存区恢复到执行`git add`之前的状态。

## Thinking 0.4

> 思考下列有关 Git 的问题：
> - 找到在 /home/22xxxxxx/learnGit 下刚刚创建的 README.txt 文件，若不存在则新建该文件。
> - 在文件里加入 Testing 1，git add，git commit，提交说明记为 1。
> - 模仿上述做法，把 1 分别改为 2 和 3，再提交两次。
> - 使用 git log 命令查看提交日志，看是否已经有三次提交，记下提交说明为 3 的哈希值[^1]。
> - 进行版本回退。执行命令 git reset --hard HEAD^ 后，再执行 git log，观察其变化。
> - 找到提交说明为 1 的哈希值，执行命令 git reset --hard <hash\> 后，再执行 git log，观察其变化。
> - 现在已经回到了旧版本，为了再次回到新版本，执行 git reset --hard <hash\>，再执行 git log，观察其变化。
> 
> [^1]: 使用 git log 命令时，在 commit 标识符后的一长串数字和字母组成的字符串

---

```bash
$  git log
commit a6ebe244272dd6bcb1f57ba9af3c957f3e7235b3 (HEAD -> master)
Author: 姜宇墨 <YumoJiang@buaa.edu.cn>
Date:   Tue Mar 11 19:08:41 2025 +0800

    3

commit 1d11df1461528ce8e2b67151384d4b24bdfec571
Author: 姜宇墨 <YumoJiang@buaa.edu.cn>
Date:   Tue Mar 11 19:08:33 2025 +0800

    2

commit 3f8eb4043efae29bbb9eb626444f955a825f3535
Author: 姜宇墨 <YumoJiang@buaa.edu.cn>
Date:   Tue Mar 11 19:08:12 2025 +0800

    1

```

提交说明为`3`的哈希值为`a6ebe244272dd6bcb1f57ba9af3c957f3e7235b3`。

```bash
$  git reset --hard HEAD^
HEAD 现在位于 1d11df1 2
$  git log
commit 1d11df1461528ce8e2b67151384d4b24bdfec571 (HEAD -> master)
Author: 姜宇墨 <YumoJiang@buaa.edu.cn>
Date:   Tue Mar 11 19:08:33 2025 +0800

    2

commit 3f8eb4043efae29bbb9eb626444f955a825f3535
Author: 姜宇墨 <YumoJiang@buaa.edu.cn>
Date:   Tue Mar 11 19:08:12 2025 +0800

    1

```

变化：当前Git仓库的状态回到了`2`。

```bash
$  git reset --hard 3f8eb4043efae29bbb9eb626444f955a825f3535
HEAD 现在位于 3f8eb40 1
$  git log
commit 3f8eb4043efae29bbb9eb626444f955a825f3535 (HEAD -> master)
Author: 姜宇墨 <YumoJiang@buaa.edu.cn>
Date:   Tue Mar 11 19:08:12 2025 +0800

    1

```

变化：当前Git仓库的状态回到了`1`。

```bash
$  git reset --hard a6ebe244272dd6bcb1f57ba9af3c957f3e7235b3
HEAD 现在位于 a6ebe24 3
$  git log
commit a6ebe244272dd6bcb1f57ba9af3c957f3e7235b3 (HEAD -> master)
Author: 姜宇墨 <YumoJiang@buaa.edu.cn>
Date:   Tue Mar 11 19:08:41 2025 +0800

    3

commit 1d11df1461528ce8e2b67151384d4b24bdfec571
Author: 姜宇墨 <YumoJiang@buaa.edu.cn>
Date:   Tue Mar 11 19:08:33 2025 +0800

    2

commit 3f8eb4043efae29bbb9eb626444f955a825f3535
Author: 姜宇墨 <YumoJiang@buaa.edu.cn>
Date:   Tue Mar 11 19:08:12 2025 +0800

    1

```

变化：当前Git仓库的状态回到了`3`。

## Thinking 0.5

> 执行如下命令, 并查看结果
> - echo first
> - echo second > output.txt
> - echo third > output.txt
> - echo forth >> output.txt

---

```bash
$  echo first
first
$  echo second > output.txt && cat output.txt
second
$  echo third > output.txt && cat output.txt
third
$  echo forth >> output.txt && cat output.txt
third
forth
```

## Thinking 0.6

> 使用你知道的方法（包括重定向）创建下图内容的文件（文件命名为 test），将创建该文件的命令序列保存在command文件中，并将test文件作为批处理文件运行，将运行结果输出至result文件中。给出command文件和result文件的内容，并对最后的结果进行解释说明（可以从test文件的内容入手）。具体实现的过程中思考下列问题: echo echo Shell Start 与 echo \`echo Shell Start\` 效果是否有区别; echo echo $c>file1 与 echo \`echo $c>file1\` 效果是否有区别.

---

```bash
# command
echo 'echo Shell Start...' > test
echo 'echo set a = 1' >> test
echo 'a=1' >> test
echo 'echo set b = 2' >> test
echo 'b=2' >> test
echo 'echo set c = a+b' >> test
echo 'c=$[$a+$b]' >> test
echo 'echo c = $c' >> test
echo 'echo save c to ./file1' >> test
echo 'echo $c>file1' >> test
echo 'echo save b to ./file2' >> test
echo 'echo $b>file2' >> test
echo 'echo save a to ./file3' >> test
echo 'echo $a>file3' >> test  # 注意此处逻辑错误，应为echo $a>file3
echo 'echo save file1 file2 file3 to file4' >> test
echo 'cat file1>file4' >> test
echo 'cat file2>>file4' >> test
echo 'cat file3>>file4' >> test
echo 'echo save file4 to ./result' >> test
echo 'cat file4>>result' >> test
```

```bash
# test
echo Shell Start...        # 输出初始化提示
echo set a = 1
a=1                        # 设置变量a=1
echo set b = 2
b=2                        # 设置变量b=2
echo set c = a+b
c=$[$a+$b]                 # 执行算术运算c=a+b=1+2=3
echo c = $c                # 输出计算结果
echo save c to ./file1
echo $c>file1              # 将c的值写入file1
echo save b to ./file2
echo $b>file2              # 将b的值写入file2
echo save a to ./file3
echo $a>file3              # 将a的值写入file3
echo save file1 file2 file3 to file4
cat file1>file4            # 创建file4并写入file1内容
cat file2>>file4           # 追加file2内容
cat file3>>file4           # 追加file3内容
echo save file4 to ./result
cat file4>>result          # 最终结果是c,b,a的值
```

```bash
$  ./test
Shell Start...
set a = 1
set b = 2
set c = a+b
c = 3
save c to ./file1
save b to ./file2
save a to ./file3
save file1 file2 file3 to file4
save file4 to ./result
```

```bash
$  cat result
3
2
1
```


反引号会先执行命令替换，改变重定向行为。

| echo echo Shell Start   | echo \`echo Shell Start\`                       |
| ----------------------- | ----------------------------------------------- |
| 输出字符串`echo Shell Start` | 先执行命令`echo Shell Start`再输出该命令的执行结果`Shell Start` |

| echo echo $c>file1  | echo \`echo $c>file1\`             |
| ------------------- | ---------------------------------- |
| 将字符串`echo 3`写入file1 | 先将`3`写入file1，再输出写入的执行结果（为空），即终端无输出 |

# 二、难点分析与实验体会

本次实验的主要难点在于**工具链的命令行参数**和**shell编程**掌握不够熟练。

### 难点1：`sed`的用法

为实现在 hello_os.sh 所处的目录新建一个名为BBB的文件，其内容为 AAA文件的第8、32、128、512、1024行的内容提取，构造`sed`命令

```bash
sed -n '8p;32p;128p;512p;1024p' "$1" > "$2"
```

### 难点2：`awk`行号提取

```bash
grep -n "$2" ./"$1" | awk -F ':' '{print $1}' > ./"$3"
```

### 难点3：GCC与Make的特殊用法

```bash
# 多目录编译示例
gcc -I ../include -c fibo.c -o fibo.o

# 调用子目录make命令示例
make -C code fibo.o
```

---

# 三、原创说明

在本次实验中，对工具链的使用参考了官方manual和`--help`参数。

在Neovim和LazyVim的安装与配置中，参考了[如何在Ubuntu上安装最新版本的Neovim并快速配置_ubuntu安装neovim-CSDN博客](https://blog.csdn.net/m0_60670525/article/details/136329707)