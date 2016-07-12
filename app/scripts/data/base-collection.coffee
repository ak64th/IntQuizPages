class BaseCollection extends Backbone.Collection
  parse: (data) ->
    if data and data.meta
      @meta = data.meta
    data and data.objects or data

module.exports = BaseCollection
