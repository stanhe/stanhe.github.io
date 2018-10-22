---
title: AS for java
tags: AS
date: 2018-10-22 16:24:47
---
<!-- ![image]() -->
<center> Android stuido for java only,not java module </center>
<!---more--->
	use gradle create java-application(script below)
	./create.sh java-demo
```
#!/bin/bash
# save as create.sh
if [ ! $1 ]
then
    echo "No project name,please add a dir name."    
else
    echo "Init file $1..."
    mkdir $1
    cd $1
    gradle init --type java-application
    git init
    touch .gitignore
    echo -e "Ignore files:"
    echo -e "build/" | tee -a .gitignore
    echo "Finish build java project $1 !"
fi

```

android studio open as android project,edit configurations run.
![settings](http://pcnl48lkv.bkt.clouddn.com//asd2018-10-22.png)
