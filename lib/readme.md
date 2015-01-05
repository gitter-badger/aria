# config.coffee

---

## 使用方法

### cache
设置缓存类型。可使用的值为`redis`和`memory`。

### jade

- cache
设置是否开启jade缓存。可使用的值为`true`和`false`。

---

## 更新日志：

### 0.0.1 @ 2014.12.1
- 建立日志。

---

## 近期计划：
- 无。

---

# cache.coffee

---

## 使用方法

在`/lib/config.coffee`中的`cache`项目中可设置缓存类型。可使用的值为`redis`和`memory`。

### set
```
$.cache.set 'key', value = 'test', ->
  $.log 'done'
```

### get
```
$.cache.get 'key', (value) ->
  $.log value
```

### del
```
$.cache.del 'key', (num) ->
  if num
    $.log 'deleted 1 key'
  else
    $.log 'deleted nothing'
```

### clear
```
$.cache.clear ->
  $.log 'done'
```

---

## 更新日志：

### 0.0.1 @ 2014.12.1
- 建立日志。

---

## 近期计划：
- 无。