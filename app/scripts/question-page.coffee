BaseModel = require('data/base-model')
BaseCollection = require('data/base-collection')
TableView = require('views/table-view')
PaginationView = require('views/pagination-view')
ModalView = require('views/modal-view')

int2Char = (i) -> String.fromCharCode(64 + parseInt(i))
char2Int = (c) -> if !!c then c.charCodeAt(0) else c

class Question extends BaseModel
  urlRoot: '/api/v1/question/'
  defaults:
    "type": 1
    "correct_option": "1"
    "option_A": ""
    "option_B": ""
    "option_C": ""
    "option_D": ""
    "option_E": ""
    "option_F": ""
  validation:
    content:
      blank: false
      message: '题目内容不能为空'
    type:
      blank: false
      fn: (value)-> value in [1, 2]
      message: '题目类型必须是多选或单选'
    correct_option:
      blank: false
      fn: (value) ->
        value = switch
          when _.isArray value then value
          when _.isString value then value.split ','
          else false
        not (_.isEmpty value) and _.every value, ((i) ->
          @get 'option_' + int2Char i ), @
      message: '正确答案设置出错，注意对应的选项是否设置了答案'

class Questions extends BaseCollection
  url: '/api/v1/question/'
  model: Question
  state: {}
  fetch: (options) ->
    options = _.extend({}, options)
    data = options.data
    options.data = _.extend({}, @state, data)
    super(options)

class QuestionView extends Backbone.View
  tagName: 'tr'
  template: require('templates/question-row')
  events:
    'click #delete': -> @model.destroy() if window.confirm("是否删除?")
  initialize: ->
    @listenTo @model, "sync", @render
    @listenTo @model, "destroy", @remove
  render: ->
    data = @model.toJSON()
    correct = data['correct_option'].split ','
    data['correct_option'] = _.map(correct, int2Char).join()
    data['type'] = switch data['type']
      when 1 then '单选'
      when 2 then '多选'
      else '多选'
    @$el.html @template data
    return @

class QuestionsView extends TableView
  row: (model) -> new QuestionView model: model

class QuestionModalView extends ModalView
  template: require('templates/question-modal')
  bindings: ->
    _bindings =
      '[name=content]': 'content'
      '[name=type]':
        observe: 'type'
        selectOptions:
          collection: ->
            [{label: '单选', value: 1},
            {label: '多选', value: 2}]
        setOptions: silent:false
      '[name=correct_option]':
        observe: 'correct_option'
        onGet: (value) -> value.split(',')
        onSet: (value) -> if _.isArray(value) then value.join(',') else value
    for code in  ['A', 'B', 'C', 'D', 'E', 'F']
      _bindings["[name=option_#{code}]"] = 'option_' + code
    return _bindings
  show: (e) ->
    super(e)
    @model.set('book', @collection.state.book) if @model.isNew()
    @changeType(@model, @model.get('type'))
    @listenTo @model, "change:type", @changeType
  changeType: (model, value, options)->
    type = if value == 1 then 'radio' else 'checkbox'
    curVal = model.get('correct_option')
    if type == 'radio' and curVal
      model.set('correct_option', curVal[0])
    @$('input[name=correct_option]').prop('type', type)
    @stickit()
  onInvalidField: (name, value, errors, model) ->
    if name != 'correct_option'
      super(name, value, errors, model)
    else
      field = @$("[name=#{name}]")
      group = field.closest('.form-group');
      group.find('.help-block').remove()
      for error in errors
        group.append("<div class='help-block col-sm-offset-2'>#{error}</div>")
      group.addClass 'has-error'

class QuestionListPanelView extends Backbone.View
  events:
    'change #book': -> @collection.state.book = @$('#book').val()
    'click #loadBook': -> @collection.fetch(reset: true)

module.exports = class QuestionPageView extends Backbone.View
  render: (bookId)->
    bookId = $('form select[name=book]').val() if not bookId
    questions = new Questions
    questions.state.book = bookId
    panelView = new QuestionListPanelView
      el: $('.table-control')
      collection: questions
    questionsView = new QuestionsView
      el: $('#question-table-container')
      collection: questions
    pageNavView = new PaginationView collection: questions
    questionsView.$el.after pageNavView.render().$el
    questionModalView = new QuestionModalView
      id: 'questionModalForm'
      collection: questions
    questionModalView.render()
    questions.fetch(reset: true)
    super()
