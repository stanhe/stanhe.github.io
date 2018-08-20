---
title: Android Travis CI
date: 2017-10-13 22:00:00
tags: 学习笔记
---
<center> travis 集成记录 </center>
<!---more--->

### 最终集成文件
```
language: android

android:
  components:
    - build-tools-26.0.1
    - android-26
    - extra-android-m2repository
    - extra-android-support
  licenses:
    - 'android-sdk-license-.+'
    - '.+'

script:
  - "./gradlew assembleRelease"

before_install:
    - chmod +x gradlew
```
### 中间遇到的问题：
#### 1.权限问题
```
before_install:
    - chmod +x gradlew
```
#### 2.license问题,注意licenses节点位置
```
 licenses:
    - 'android-sdk-license-.+'
    - '.+'
```

#### 3.ConstraintLayout license问题

直接删除 ConstraintLayout，他喵的捣鼓半天无解。

