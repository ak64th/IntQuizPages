class BaseModel extends Backbone.Model
    # Add trailing slash after url
    url: ->
      origUrl = super()
      origUrl + (if origUrl.length > 0 and origUrl.charAt(origUrl.length - 1) == '/' then '' else '/')
    # parse tastypie style restful response
    parse: (data) ->
      if data and data.objects and _.isArray(data.objects)
        return data.objects[0] or {}
      data

module.exports = BaseModel
