d = document
input_ids = ['first', 'second', 'third']

to_array = (sequential_thing) -> Array.prototype.slice.call sequential_thing

current_iso_date = () -> new Date().toISOString()

update_input_render_state = (checkbox) ->
  text_input = checkbox.nextSibling
  if checkbox.checked
    text_input.classList.add 'completed'
  else
    text_input.classList.remove 'completed'

handle_checkbox_change = (event) ->
  checkbox = event.target
  update_input_render_state checkbox

  if checkbox.checked
    checkbox.dataset.date_time_completed = current_iso_date()
  else
    delete checkbox.dataset.date_time_completed

  save_current_state()

get_checkbox = (i) -> d.getElementById input_ids[i] + '_status'
get_text_input = (i) -> d.getElementById input_ids[i] + '_text'
get_today_thingset = () -> d.getElementById 'today_things'

get_thing_state = (i) ->
  completed: get_checkbox(i).checked
  date_time_completed: get_checkbox(i).dataset.date_time_completed or null
  text: get_text_input(i).value

get_current_thingset_state = () ->
  things: (get_thing_state i for i in [0..2])
  date: get_today_thingset().dataset.date

save_current_state = () ->
  current = get_current_thingset_state()
  localStorage.setItem 'current', JSON.stringify current
  console.log 'Saved state:', current

update_today_list_date = () ->
  console.log 'Setting today’s list to current date'
  get_today_thingset().dataset.date = current_iso_date()

update_and_save = () ->
  update_today_list_date()
  save_current_state()

render_thing = (thing, i) ->
  get_text_input(i).value = thing.text

  checkbox = get_checkbox i
  checkbox.checked = thing.completed
  update_input_render_state checkbox

load_state = (which) ->
  json = localStorage.getItem which
  if json isnt null
    state = JSON.parse json
    console.log 'loaded', which, 'state from localStorage', state
    state
  else
    console.log 'state', which, 'not present in localStorage'
    null

render_current_state = (state) ->
  get_today_thingset().dataset.date = state.date
  render_thing thing, i for thing, i in state.things

reset_thing = (i) ->
  checkbox = get_checkbox i
  checkbox.checked = false

  text_input = get_text_input i
  text_input.value = ''
  text_input.style.textDecoration = ''

reset_ui = () ->
  reset_thing i for i in [0..2]
  update_today_list_date()

archive_thingset = (thingset) ->
  prior_json = localStorage.getItem 'prior'
  prior = if prior_json isnt null then JSON.parse prior_json else []
  prior.push thingset
  localStorage.setItem 'prior', JSON.stringify prior
  localStorage.removeItem 'current'
  reset_ui()
  console.log 'Archived current state'
  console.log 'Archive value is now:', prior

prior_thing_to_li = (thing) ->
  li = d.createElement 'li'
  if thing.completed then li.classList.add 'completed'
  li.appendChild d.createTextNode thing.text
  li

render_prior_thingset = (thingset) ->
  prior = d.getElementById 'prior'
  details = d.createElement 'details'
  summary = d.createElement 'summary'
  list = d.createElement 'ul'
  summary.appendChild d.createTextNode new Date(thingset.date).toDateString()
  details.appendChild summary
  details.appendChild list
  list.appendChild prior_thing_to_li thing for thing in thingset.things
  prior.appendChild details

clear_prior_things = () ->
  details = d.getElementById 'prior'
  details.removeChild child for child in to_array details.getElementsByTagName 'details'

render_prior_things = (prior_things) ->
  render_prior_thingset thingset for thingset in prior_things.sort (a, b) ->
    if a.date < b.date then 1 else if a.date > b.date then -1 else 0

is_current_day = (date) ->
  value = if date instanceof Date then date else new Date date
  new Date().getDay() is value.getDay()

clear_and_render_prior = (prior_state) ->
  clear_prior_things()
  render_prior_things prior_state if prior_state
  d.getElementById('prior').style.display = if not prior_state or prior_state.length is 0 then 'none' else 'block'
  return

do_export = () ->
  output = d.getElementById 'export_output'
  output.removeChild child for child in to_array output.childNodes
  data =
    current: load_state 'current'
    prior: load_state 'prior'
  output.value = JSON.stringify data
  output.select()

handle_import_click = (event) ->
  prompt_result = prompt 'This will ERASE all existing data! If you wish to proceed then enter “erase” below.'
  if prompt_result isnt 'erase' then return

  # TODO: add error handling if, say, the value isn’t valid JSON or is missing
  # the required keys or if their values are the wrong shape
  textarea = d.getElementById 'import_input'
  input = JSON.parse textarea.value
  localStorage.current = JSON.stringify input.current
  localStorage.prior = JSON.stringify input.prior
  render_current_state input.current unless input.current is null
  clear_and_render_prior input.prior
  textarea.value = ''
  event.target.disabled = true if event.target
  alert 'Import/Restore succeeded!'

toggle_import_button = (event) ->
  # This is crazy, but it’s necessary and it works
  # See http://stackoverflow.com/q/14841739
  setTimeout (()->
    d.getElementById('button_import').disabled = event.target.value.trim().length is 0
  ), 1

interval_check_whether_day_changed = () ->
  current_thingset_date = get_today_thingset().dataset.date
  if current_thingset_date and not is_current_day current_thingset_date
    archive_thingset get_current_thingset_state()
    clear_and_render_prior load_state 'prior'

d.addEventListener 'DOMContentLoaded', ->
  if localStorage.getItem('warning_dismissed')
    d.getElementById('warning').style.display = 'none'

  current_state = load_state 'current'
  if current_state and not is_current_day current_state.date
    archive_thingset current_state
  else if current_state
    render_current_state current_state

  setInterval interval_check_whether_day_changed, 60000

  inputs = to_array d.getElementsByTagName 'input'

  input.addEventListener 'change', update_and_save for input in inputs
  input.addEventListener 'keypress', update_and_save for input in inputs when input.type is 'text'

  # this currently results in save_current_state being called twice when checkbox state is changed,
  # apparently because the other event listener/handler causes another change event to be fired
  # on the text input
  input.addEventListener 'change', handle_checkbox_change for input in inputs when input.type is 'checkbox'

  d.getElementById('button_dismiss_warning').addEventListener 'click', () ->
    localStorage.setItem 'warning_dismissed', JSON.stringify true
    d.getElementById('warning').style.display = 'none'

  d.getElementById('button_export').addEventListener 'click', do_export

  # TODO: These listeners don’t seem to be sufficient to detect when text is pasted in
  d.getElementById('import_input').addEventListener 'keypress', toggle_import_button
  d.getElementById('import_input').addEventListener 'change', toggle_import_button
  d.getElementById('import_input').addEventListener 'paste', toggle_import_button

  d.getElementById('button_import').addEventListener 'click', handle_import_click

  # Prior state is rendered last because it’s more important to set up interactivity first
  clear_and_render_prior load_state 'prior'
