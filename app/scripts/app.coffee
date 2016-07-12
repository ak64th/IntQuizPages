UIMixin = require('ui-mixin')

window.IntApp = IntApp =
  AccountPageView: require('account-page')
  BookPageView: require('book-page')
  QuestionPageView: require('question-page')
  ActivityPageView: require('activity-page')

_.extend IntApp, UIMixin
IntApp.initUI = ->
  @layout.activate()
  @pushMenu.activate()
  @tree()

$ ->
  IntApp.initUI()
