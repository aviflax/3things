d = document
input_ids = ['first', 'second', 'third']

to_array = (sequential_thing) -> Array.prototype.slice.call sequential_thing

update_input_render_state = (checkbox) ->
  text_input = checkbox.nextSibling
  text_input.style.textDecoration = if checkbox.checked then 'line-through' else ''

handle_checkbox_change = (event) ->
  checkbox = event.target
  update_input_render_state checkbox
  save_state()

get_checkbox = (i) -> d.getElementById input_ids[i] + '_status'
get_text_input = (i) -> d.getElementById input_ids[i] + '_text'

get_item_state = (i) ->
  checked: get_checkbox(i).checked
  text: get_text_input(i).value

save_state = () ->
  today = (get_item_state i for i in [0..2])
  localStorage.setItem 'today', JSON.stringify today
  console.log 'Saved state:', today

render_item = (item, i) ->
  get_text_input(i).value = item.text

  checkbox = get_checkbox i
  checkbox.checked = item.checked
  update_input_render_state checkbox

load_state = () ->
  today_json = localStorage.getItem 'today'
  if today_json isnt null
    JSON.parse today_json
  else
    console.log 'State not present in localStorage'

render_state = (state) ->
  render_item item, i for item, i in state

d.addEventListener 'DOMContentLoaded', ->
  render_state load_state()
  inputs = to_array d.getElementsByTagName 'input'

  input.addEventListener 'change', save_state for input in inputs

  # this currently results in save_state being called twice when checkbox state is changed,
  # apparently because the other event listener/handler causes another change event to be fired
  # on the text input
  input.addEventListener 'change', handle_checkbox_change for input in inputs when input.type is 'checkbox'
