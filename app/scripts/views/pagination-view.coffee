module.exports = class PaginationView extends Backbone.View
  tagName: 'nav',
  className: 'page-nav',
  template: require('templates/page-nav')
  events:
    'click a[data-id]': 'loadPage'
  initialize: -> @listenTo @collection, 'reset', @render
  render: ->
    if @collection.meta
      @$el.html @template @collection.meta
    return @
  loadPage: (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    @collection.fetch data:{page: data.id}, reset:true
