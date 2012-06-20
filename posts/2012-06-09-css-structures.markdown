---
layout: post
title: "CSS Structures"
date: 2012-06-09 12:26
comments: true
categories: 器
published: false
---

从网上找来的关于如何写出结构清晰的 CSS 的一些诀窍，包括多个文件的结构
和文件内部的结构两个部分：

怎样写结构复杂的CSS？一个好办法是将样式表拆分到多个文件里。例如 Mike
Byrne 的
[做法](http://www.netmagazine.com/tutorials/how-structure-your-css)。
基本的文件包括一个用来 reset 样式表的空样式表，一个`@import`子样式表，
用来测试的 loader，以及一个核心的样式表。核心的样式表又可以拆分成 font、
body、layouts、general styles、custom classes、div、page 等几个章节或
者子样式表，并按照这个顺序载入。

在单个的样式表或者像 Octopress 这样局部定制的样式表里，则可遵循
[Emil Stenström](http://friendlybit.com/css/how-to-structure-large-css-files/)
提出的原则，将 CSS 的结构按照 HTML 中出现的先后次序和层级列出，并详细
定义各选择器的全“路径”。为了提高可读性，还应当适当缩进样式表，并将每个
属性按字母顺序排列，各占一行。
