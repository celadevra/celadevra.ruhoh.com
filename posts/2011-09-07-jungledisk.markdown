---
date: '2011-09-07 16:48:00'
layout: post
slug: jungledisk
status: publish
title: JungleDisk
wordpress_id: '98'
tags:
- hacking
- s3
- web
---

I have used [JungleDisk](http://www.jungledisk.com/) once, long ago. I wanted to set up an remote backup site so my data would be safe in the unlikely event that both my computer and my backup drive gets stolen or burned. But then I find that the initial backup was long and tedious, and my broadband subscription had a monthly transfer cap, beyond which I will be charged dearly for every byte I download and upload. So I determined that this tool was not for me.

A few years later I am in an office, with no data transfer cap, but no cheap portable hard drives around for me to backup data. Then I decide to use [Amazon S3](http://s3.amazonaws.com/) as my remote backup destination again. The question is what tool or interface I should use. I have tried [DragonDisk](http://www.dragondisk.com/), which is fantastic as a free S3 client, the problem is that I have an Outlook `.pst` file which is close to 2GB, and if I want to backup it, DragonDisk has no other way but to transfer it as a whole every time. This is because S3 doesn't support rsync and if a file is changed, it has to be transferred again.

I can setup a server side `rsync` and mount the S3 bucket as an `s3fs`, if I tinker a bit with cygwin. But again, as S3 has no rsync ability, what this configuration does is downloading the file from S3, comparing it with the local one, and deciding whether update it on the S3 or not. This will bring even higher data transfer between S3 and my computer, so that's a no-no, too.

JungleDisk does serverside file comparison by setting their server on Amazon EC2 instances, so I was told, thus it supports true incremental backup without incurring a log of data being transferred and discarded. So, I decide to try JungleDisk once again. A surprise is that they still have my account back when I downloaded the then free desktop client – and it is still free to use. To have the said ability to do bit-level incremental backup, though, you still need a subscription at $1/month. Compared to the standard $3/month price, that is still a bargain. Rarely do early adopters really feel the benefit like this.

However, bandwidth is still an issue. My 20 GB data (and growing) at the current speed will take 18 days – that's 432 hours, mind you – to be completely uploaded. So if I spend 10 hours at my office computer each day, it will take at least 8 weeks. Anyway, JungleDisk and Amazon S3 may be the best affordable off-site backup solution nowadays. I will see how it plays out in the future. I am also considering hosting some media files for my blog and website on S3.
