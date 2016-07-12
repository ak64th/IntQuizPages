module.exports = class TableView extends Backbone.View
  initialize: ->
    @listenTo @collection, 'add', @add
    @listenTo @collection, 'reset', @render
  row: (model) -> throw new Error('Not implemented')
  add: (model) ->
    row = @row(model)
    row.$el.addClass('success')
    @$('table tbody').prepend row.render().$el
  render: (collection) ->
    tbody = @$('table tbody')
    tbody.empty()
    collection.each ((model) ->
      tbody.append @row(model).render().$el), @
    @
