BaseModel = require('data/base-model')
BaseCollection = require('data/base-collection')
TableView = require('views/table-view')
PaginationView = require('views/pagination-view')
ModalView = require('views/modal-view')

DATETIME_FORMAT = 'YYYY-MM-DD HH:mm:ss'

class Activity extends BaseModel
  urlRoot: '/api/v1/activity/'
  defaults:
    "info_field_1": ""
    "info_field_2": ""
    "info_field_3": ""

class Activities extends BaseCollection
  url: '/api/v1/activity/'
  model: Activity,

class ActivityView extends Backbone.View
  tagName: 'tr'
  template: require('templates/activity-row')
  render: ->
    front_host = window.front_host or '/'
    data = @model.toJSON()
    start_at = new moment(data.start_at, DATETIME_FORMAT)
    end_at = new moment(data.end_at, DATETIME_FORMAT)
    now = new moment()
    data['status'] = if (start_at < now < end_at)  then '开启' else '关闭'
    data['url'] = "http://#{front_host}/index.html##{data['code']}"
    data['type'] = switch data['type']
      when 0 then '普通'
      when 1 then '限时'
      when 2 then '挑战'
      else '未知'
    @$el.html @template data
    return @

class ActivitiesView extends TableView
  row: (model) -> new ActivityView model: model

module.exports = class ActivityPageView extends Backbone.View
  render: ->
    activities = new Activities
    activitiesView = new ActivitiesView
      el: $('#activity-table-container')
      collection: activities
    pageNavView = new PaginationView collection: activities
    activitiesView.$el.after pageNavView.render().$el
    activities.fetch reset: true
    return @
