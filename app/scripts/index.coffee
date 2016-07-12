UIMixin = require('ui-mixin')

window.app = app =
  Model: Backbone.Model.extend
      # Add trailing slash after url
      url: ->
        origUrl = Backbone.Model::url.call(@)
        origUrl + (if origUrl.length > 0 and origUrl.charAt(origUrl.length - 1) == '/' then '' else '/')
      # parse tastypie style restful response
      parse: (data) ->
        if data and data.objects and _.isArray(data.objects)
          return data.objects[0] or {}
        data
  Collection: Backbone.Collection.extend
      parse: (data) ->
        @meta = data.meta if data and data.meta
        data and data.objects or data

_.extend app, UIMixin
app.initUI = ->
  @layout.activate()
  @pushMenu.activate()
  @tree()

$ ->
  app.initUI()
