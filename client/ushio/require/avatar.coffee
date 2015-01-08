#set handle
elem = $$ '#avatar-ac-footer'
img = elem.find 'img'
pts = $ '<span class="pts">1</span>'
pts.insertAfter elem

#param
st = $.now()
count = 0

#action
elem.click ->

  #count
  count++

  #when 50
  if count % 50 == 0
    #change avatar
    src = system.path.short + '/umeditor/dialogs/emotion/images/ac/' + $.rnd(1, 55) + '.gif'
    $.preload src, ->
      img
      .stop()
      .transition
        opacity: 0
      , 200, ->
        img.attr src: src
      .transition
        opacity: 1
      , 200

  #when 100
  if count % 100 == 0
    #check apm
    apm = (count / (($.now() - st) / 1e3 / 60)) | 0
    #check apm
    if apm > 600
      $.info 'warning', '未知核弹已经升空。'
      return
    $.info 'info', '连续点击了' + count + '次，APM为' + apm + '次/分。'

  #show pts
  pts
  .text $.parsePts count
  .riseInfo '+1 Click'
#first time
.click()