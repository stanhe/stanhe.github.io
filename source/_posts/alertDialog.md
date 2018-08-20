---
title: AlertDialog 相关问题汇总
date: 2017-2-21 12:10:45
tags: android
---
![AlertDialog](http://oanvj2lsv.bkt.clouddn.com/android/dialog.png)
<center>AlertDialog 应用中遇到的相关问题汇总,待更新~</center>
<!---more--->
### 反射修改AlertDialog默認title显示不全的问题

其实title应该是没有问题的,默认显示一行也符合设定,毕竟title要那么长干嘛,又不是写春联.然而我可能希望
在这个默认样式上就使用title显示很长的文字,这个时候就发现它真的不够长~ so~
```
AlertDialog dialog = new AlertDialog.Builder(MainActivity.this)
                .setTitle(title)
                .setPositiveButton(getString(R.string.update_now),positiveClickEvent)
                .setNegativeButton(getString(R.string.update_later),negativeClickEvent)
                .setCancelable(false)
                .create();
        dialog.show();
        try {
            Class<?> mDialog = dialog.getClass();
            Field field = mDialog.getDeclaredField("mAlert");
            field.setAccessible(true);
            Field mTitleView = field.get(dialog).getClass().getDeclaredField("mTitleView");
            mTitleView.setAccessible(true);
            Object AlertController = field.get(dialog);
            Object obj = mTitleView.get(AlertController);
            TextView textView = ((TextView) obj);
            textView.setSingleLine(false);
        } catch (Exception e) {
            e.printStackTrace();
        }

```
