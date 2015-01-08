# core.coffee

---

## 更新日志：

### 0.2.0 @ 2014.6.6
- 添加$.require()方法。
- 在脚本头部添加说明文档(就是你正在读的这个)。
- 将$.parseChannel()方法中的“特摄·霹雳”更改为“特摄·布袋戏”。
- 现在，你可以使用$.require('ready')来取代system.func.ready()。
- 修复了一个$.isViewing()方法中func.name调用出错的问题。
- 禁用了配置中的“Debug 模式”选项。

### 0.2.1 @ 2014.6.6
- 令$.require()方法能够使用“qrcode”参数。

### 0.2.2 @ 2014.6.6
- 从$.require()方法中移除“manga”参数。
- 修复了一个$.require()方法中“qrcode”和“hashchange”两个参数颠倒的问题。

### 0.2.3 @ 2014.6.13
- 当$.preload()方法完成载入队列后，将不会再显示debug信息。

### 0.2.4 @ 2014.6.13
- 在非debug模式下，$.i()现在什么都不会做(也不会去执行$.require('info'))。

### 0.2.5 @ 2014.6.17
- 通过新增内建方法bind()，使$.require()及其相关方法变得更小，调用也更便捷。
- 移除了$.setEditorConfig()方法。因为我们换了新的文本编辑器(umeditor)。
- 修改了$.require('editor')以适配新的文本编辑器。
- 重写了$.scrollOnto()方法。
- 重写了$.save()方法。

### 0.2.6 @ 2014.6.17
- 为$.require()方法中的文件路径添加了版本盐。

### 0.2.7 @ 2014.6.17
- 升级版本号，以能够从cdn获取最新的文本编辑器样式文件。该版本除升级版本号外没有任何改动。

### 0.2.8 @ 2014.6.18
- 修复了一个$.ensure()方法不能正常执行的问题。

### 0.2.9 @ 2014.6.18
- 修复了一个有关于system.path.short错误的问题。
- 把说明文档用中文重写了一遍。

### 0.2.10 @ 2014.6.27
- 移除了了$.now()。因为它实际上是jQuery提供的方法之一。
- 重写了$.rnd()方法。
- 移除了$.save()方法对system.browser.localstorage的依赖。
- 增添了内建方法system.func.checkBrowser()以解耦modernizr.min.js。
- 为$.require()方法添加了“jqueryui”参数以解耦jquery.ui.min.js。
- 重写了$.parsePing()方法。
- 重写了$.parsePts()方法。
- 重写了$$()方法。
- 重写了$.parseString()方法。
- 重写了$.parseJson()方法。
- 重写了$.parseSafe()方法。
- 重写了$.parseChannel()方法。
- 重写了$.preload()方法。
- 重写了$.fn.loadin()方法。
- 修复了判断cache版本号失效的一个错误。
- 移除了cache中的style项。
- 重写了$.parseTime()。
- 修复了一个form模块中表单自动存储功能会明文记录用户密码的问题。

### 0.2.11 @ 2014.7.1
- 增添了$.parseTemp()方法。
- 修改了$.curtain()方法。
- 重写了$.parsePts()方法。
- 增添了$.route()方法。
- 重写了$.isViewing()方法。
- 重写了$.setup()方法。
- 重写了$.setHash()方法。
- 重写了$.setParam()方法。
- 移除了$.readyStage()方法中执行的$.save('user')方法。

### 0.2.12 @ 2014.7.1
- 增添了cache.history.ups。
- 回滚$.setup()方法。

### 0.2.13 @ 2014.7.2
- 修复了$.parsePts()方法计算精度的问题。

### 0.2.14 @ 2014.7.2
- 增添了hash模块。
- 修改了内置的bind()方法，以使其能够传递所有参数。
- 增添了flash模块。
- 增添了$.fn.flash()方法。
- 去除了$.require('editor')方法的时间戳和版本盐。

### 0.2.15 @ 2014.7.7
- 增添了$.salt()方法。
- 修复了表情转换出错的问题。

### 0.2.16 @ 2014.7.10
- 增添了$.timeStamp()方法。

### 0.2.17 @ 2014.7.17
- $.check('online')中将user.uid的类型由str调整为int。
- 移除了一些window.config中无用的冗余项。

### 0.2.18 @ 2014.7.18
- 调整了system.path类。

### 0.2.19 @ 2014.7.28
- 在core中载入system.date。
- 修复一个$.parseTemp()方法中可能存在的问题。
- 使用原生对象window.Worker检测取代system.browser.webworkers。
- 增添$.require('tarnsit')方法。
- 重写了$.parsePts()方法。

### 0.2.20 @ 2014.8.4
- 移除$.parseTemp()方法中的复杂匹配规则。
- 修复了某些特殊情况下$.fn.card()无法正常工作的问题。
- 重写了$.salt()方法。
- 重写了$.require()方法，移除其对于system.require的依赖。
- 重写了$.delay()方法，移除其对于system.timer的依赖。
- 重写了$.parseColor()方法，使其返回16位色码。
- 移除了$.parsePing()方法。
- 重写了$.mid()方法。
- 调整$.readyStage()方法中记录在线时间的策略。

### 0.3.0 @ 2014.8.6
- 移除$.readyStage()方法。
- 重写了$.parseChannel()方法。
- 重写了$.setup()方法。
- 移除了$.rndColor()方法。
- 移除了$.exe()方法。
- 重写了$.info()方法。
- 重写了$.fn.info()方法。
- 在info类中使用$.transition()方法取代$.animate()方法。
- 重写了$.curtain()方法。
- 在win类中使用$.transition()方法取代$.animate()方法。
- 添加config.globe.guideFloatAllowed配置项。

### 0.3.1 @ 2014.8.7
- 修复了一个$.call('qrcode')无法使用canvas进行渲染的问题。
- 修复了一个用户名片和视频名片弹出时机错误的问题。

### 0.3.2 @ 2014.8.22
- 修改了$.makePager()以适配font-awesome。
- 修改了info模块以适配font-awesome。

### 0.3.3 @ 2014.8.26
- $fn.call('reg')更新。

### 0.3.4 @ 2014.9.1
- 增添了$.require('chart')方法。
- 增添了$.require('canvas')方法。
- 增添了$.fn.edit()方法。

### 0.3.5 @ 2014.9.12
- 修复了$.require('chart')内IE兼容性的问题。
- 优化了$.require()方法。现在在同时发起多个$.require()时不再会导致浏览器同时发起多个连接请求。

### 0.3.6 @ 2014.9.12
- 修复了console在IE8下报错的问题。
- 调整了$.require('canvas')的执行策略。

### 0.3.7 @ 2014.9.17
- 更新了store模块。
- 修改了ubb相关设置。

### 0.3.8 @ 2014.9.18
- 重写了$.fn.setup.readyDropdown()。
- 令$.setup()支持.switch。

### 0.3.9 @ 2014.9.19
- 使用$.Callbacks()重写$.require()。
- 重写了$.parseSafe()。

### 0.3.10 @ 2014.9.27
- 修复了一个有关于$.salt(0)的错误。
- 重写了$.parseString()方法。

### 0.3.11 @ 2014.9.28
- 增添了$.log()方法。
- 重写了$.delay()方法。

### 0.3.12 @ 2014.10.11
- 增添了$.fn.share()方法。

### 0.3.13 @ 2014.10.31
- 增添了$.next()方法。

### 0.3.14 @ 2014.10.31
- 清空window.config。
- 修复了$.preload()中的一处错误。

### 0.3.15 @ 2014.11.25
- 将更新日志外置为core.md。
- 重写了$.i()方法。现在在生产环境中它将会调用$.log()。
- 增添了$.try()方法。
- 修复了form模块中的一处错误。
- 重写了$.info()方法。
- 重写了$.setup()方法。
- 增添了form-new模块。
- 重写了$.parseSafe()方法。现在它会内部调用$.parseString()。
- 重写了$.fn.riseInfo()方法。

### 0.3.16 @ 2014.12.1
- 重写了$.setParam()方法。
- 重写了$.setHash()方法。
- 增添了$.hash()方法。
- 增添了$.query()方法。
- 移除了$.check()方法。

### 0.3.17 @ 2014.12.2
- 重写了$.hash()方法。
- 重写了$.query()方法。

### 0.3.18 @ 2014.12.25
- 重写了$.fn.riseInfo()方法。
- 修复了$.info()方法中的一处错误。
- 修复了$.timeStamp()方法中的一处问题。
- 修复了form-new模块中的一处问题。
- 重写了$.query()方法。
- 重写了$.route()方法。

### 0.3.19 @ 2014.12.30
- 重写了$.salt()方法。
- 重写了$.require()方法。
- 重写了$.preload()方法。
- 调整了system的写入策略。

---

## 近期计划：
- 修呀么修bug。
- 规范化传入参数名称。以方便IDE提示。
- 修改$.card()。
- 移除$.setHash()和$.setParam()。