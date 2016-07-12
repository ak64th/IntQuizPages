module.exports = class ModalView extends Backbone.View
  render: ->
    $('#' + @id).remove()
    $('body').append @template id: @id
    @setElement($('#' + @id))
    return @
  events:
    'show.bs.modal': 'show'
    'hidden.bs.modal': 'hidden'
    'click [type=submit]': 'save'
  show: (e) ->
    data = $(e.relatedTarget).data()
    @model = if data.id then @collection.get(data.id) else new @collection.model
    @stickit()
    @bindValidation()
    @model.validate() if not @model.isNew()
  hidden: ->
    @unstickit()
    @stopListening()
    delete @model
  save: (e) ->
    e.preventDefault()
    xhr = @model.save()
    if xhr
      xhr.then ( =>
        @collection.add @model
        @$el.modal 'hide')

  onValidField: (name, value, model) ->
    field = @$("[name=#{name}]")
    group = field.closest('.form-group');
    group.removeClass 'has-error'
    group.find('.help-block').remove()
  onInvalidField: (name, value, errors, model) ->
    field = @$("[name=#{name}]")
    group = field.closest('.form-group');
    group.find('.help-block').remove()
    for error in errors
      field.after("<div class='help-block'>#{error}</div>")
    group.addClass 'has-error'
