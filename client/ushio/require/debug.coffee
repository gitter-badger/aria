do -> $.i '页面编译于' + $.parseTime(system.date) + '。'

#unit test
do ->
  elem = $$ '#qunit'
  if elem.length
    #width
    elem.css width: $$('#guide-inner').width()
    #insert js
    $.getScript system.path.short + '/project/test/script/case/' + elem.data().src + '.js'