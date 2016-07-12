BaseModel = require('data/base-model')
BaseCollection = require('data/base-collection')
TableView = require('views/table-view')
PaginationView = require('views/pagination-view')
ModalView = require('views/modal-view')

class User extends BaseModel
  urlRoot: '/api/v1/user'
  defaults:
    username: ''
    password: ''
  validation:
    username:
      blank: false
      message: '用户名不能为空'
    password:
      blank: false
      minLength: 6
      message: '密码不能少于6位'
  activate: ->
    attrs = active: true
    url = "/accounts/#{@id}/toggle"
    @save(attrs, {attrs, url})
  deactivate: ->
    attrs = active: false
    url = "/accounts/#{@id}/toggle"
    @save(attrs, {attrs, url})

class Users extends BaseCollection
  url: '/api/v1/user'
  model: User

class UserView extends Backbone.View
  tagName: 'tr',
  template: require('templates/user-row')
  events:
    'click #deactivate': -> @model.deactivate()
    'click #activate': -> @model.activate()
  initialize: ->
    @listenTo @model, "sync", @render
    @listenTo @model, "destroy", @remove
  render: ->
    @$el.html @template @model.toJSON()
    return @

class UserModalView extends ModalView
  template: require('templates/user-modal')
  bindings:
    '#username': 'username'
    '#password': 'password'
  save: (e) ->
    e.preventDefault()
    url = if @model.isNew() then "/accounts/create"
    else "/accounts/#{@model.id}/changePwd"
    xhr = @model.save(null, {url})
    if xhr
      xhr.then ( =>
        @collection.add @model
        @$el.modal 'hide')

class UsersView extends TableView
  row: (model) -> new UserView model: model

module.exports = class AccountPageView extends Backbone.View
  render: ->
    users = new Users
    usersView = new UsersView
      el: $('.table-container')
      collection: users
    pageNavView = new PaginationView collection: users
    usersView.$el.after pageNavView.render().$el
    userModalView = new UserModalView
      id: 'userModalForm'
      collection: users
    userModalView.render()
    users.fetch reset: true
    return @
