BaseModel = require('data/base-model')
BaseCollection = require('data/base-collection')
TableView = require('views/table-view')
PaginationView = require('views/pagination-view')
ModalView = require('views/modal-view')

class QuizBook extends BaseModel
  urlRoot: '/api/v1/quizbook'
  validation:
    title:
      blank: false
      message: '题库名不能为空'

class QuizBooks extends BaseCollection
  url: '/api/v1/quizbook'
  model: QuizBook

class QuizBookView extends Backbone.View
  tagName: 'tr'
  template: require('templates/book-row')
  initialize: ->
    @listenTo @model, "sync", @render
  render: ->
    @$el.html @template @model.toJSON()
    return @

class QuizBookModalView extends ModalView
  template: require('templates/book-modal')
  bindings: '#title': 'title'

class QuizBooksView extends TableView
  row: (model) -> new QuizBookView model: model

module.exports = class BookPageView extends Backbone.View
  render: ->
    quizBooks = new QuizBooks
    quizBooksView = new QuizBooksView
      el: $('#quizbook-table-container')
      collection: quizBooks
    pageNavView = new PaginationView collection: quizBooks
    quizBooksView.$el.after pageNavView.render().$el
    quizBookModalView = new QuizBookModalView
      id: 'bookModalForm'
      collection: quizBooks
    quizBookModalView.render()
    quizBooks.fetch reset: true
    return @
