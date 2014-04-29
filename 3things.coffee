d = document
input_ids = ['first', 'second', 'third']

to_array = (sequential_thing) -> Array.prototype.slice.call sequential_thing

kill_event = (event) ->
  event.preventDefault()
  event.stopPropagation()

get_label_for_input_id = (input_id) -> d.getElementById input_id + '_label'

update_input_render_state = (input) ->
  label = get_label_for_input_id input.id
  label.style.textDecoration = if input.checked then 'line-through' else ''

handle_input_click = (event) ->
  update_input_render_state event.target
  save_state()

get_item_state = (input_id) ->
  input = d.getElementById input_id
  label = get_label_for_input_id input_id

  checked: input.checked
  goal: if label.firstChild then label.firstChild.nodeValue else ''

save_state = () ->
  today = (get_item_state id for id in input_ids)
  localStorage.setItem 'today', JSON.stringify today
  console.log 'Saved state:', today

render_item = (item, position) ->
  input_id = input_ids[position]
  input = d.getElementById input_id

  label = get_label_for_input_id input_id
  if label.firstChild
    label.firstChild.nodeValue = item.goal
  else
    label.appendChild d.createTextNode item.goal

  input.checked = item.checked
  update_input_render_state input

load_state = () ->
  today_json = localStorage.getItem 'today'
  if today_json isnt null
    today = JSON.parse today_json
    console.log 'Loaded state', today
    render_item item, i for item, i in today
  else
    console.log 'State not present in localStorage'

d.addEventListener 'DOMContentLoaded', ->
  load_state()

  get_labels = () -> to_array d.getElementsByTagName 'label'

  # Kill click events on labels because otherwise when you click on a label to edit it,
  # the state of the corresponding checkbox is toggled
  label.addEventListener 'click', kill_event for label in get_labels()

  label.addEventListener 'blur', save_state for label in get_labels()
  input.addEventListener 'click', handle_input_click for input in to_array d.getElementsByTagName 'input'
