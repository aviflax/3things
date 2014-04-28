d = document

to_array = (sequential_thing) -> Array.prototype.slice.call sequential_thing

kill_event = (event) ->
  event.preventDefault()
  event.stopPropagation()

handle_input_click = (event) ->
  input = event.target
  label_id = input.id + '_label'
  label = d.getElementById label_id
  label.style.textDecoration = if input.checked then 'line-through' else ''

d.addEventListener 'DOMContentLoaded', ->
  # Kill click events on the label because otherwise when you click on the label to edit it,
  # the checkbox state gets toggled
  label.addEventListener 'click', kill_event for label in to_array d.getElementsByTagName 'label'

  input.addEventListener 'click', handle_input_click for input in to_array d.getElementsByTagName 'input'
