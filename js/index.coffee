d = document
input_ids = ['first', 'second', 'third']

to_array = (sequential_thing) -> Array.prototype.slice.call sequential_thing
current_iso_date = -> new Date().toISOString()
get_checkbox = (i) -> d.getElementById input_ids[i] + '_status'
get_today_thing = (i) -> d.getElementById input_ids[i] + '_text'
get_today_thingset = -> d.getElementById 'today_things'
update_today_list_date = -> get_today_thingset().setAttribute 'data-date', current_iso_date()

Array::group_by = (f) ->
  # A naïve port of Clojure’s group-by — thanks, Rich Hickey!
	@reduce (r,x) ->
		k = f x
		r[k] = r[k] or []
		r[k].push x
		r
	, {}

update_checkbox_state = (checkbox) ->
  text_input = checkbox.nextSibling
  if checkbox.checked
    text_input.classList.add 'completed'
  else
    text_input.classList.remove 'completed'
  return

handle_checkbox_change = (event) ->
  checkbox = event.target
  update_checkbox_state checkbox

  if checkbox.checked
    checkbox.setAttribute 'data-dateTimeCompleted', current_iso_date()
  else
    checkbox.removeAttribute 'data-dateTimeCompleted'

  save_current_state()
  return

get_thing_state = (i) ->
  completed: get_checkbox(i).checked
  date_time_completed: get_checkbox(i).getAttribute('data-dateTimeCompleted') or null
  text: get_today_thing(i).value.trim()

get_current_thingset_state = ->
  things: (get_thing_state i for i in [0..2])
  date: get_today_thingset().getAttribute 'data-date'

save_current_state = ->
  current = get_current_thingset_state()
  if not thingset_is_empty current
    localStorage.setItem 'current', JSON.stringify current
    console.log 'Saved state:', current
  else
    console.log 'Did *not* save state because it was empty.'
  return

resize_textarea = (textarea) ->
  # technique from http://stackoverflow.com/a/8522283/7012
  textarea.style.height = '0'
  textarea.style.height = textarea.scrollHeight + 'px'
  return

handle_text_input = (event) ->
  resize_textarea this
  update_today_list_date()
  save_current_state()
  return

render_current_thing = (thing, i) ->
  textarea = get_today_thing i
  textarea.value = thing.text
  resize_textarea textarea
  checkbox = get_checkbox i
  checkbox.checked = thing.completed
  update_checkbox_state checkbox
  return

# TODO: this is duplicated across 3things.coffee and data.coffee
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
  get_today_thingset().setAttribute 'data-date', state.date
  render_current_thing thing, i for thing, i in state.things
  return

reset_thing = (i) ->
  checkbox = get_checkbox i
  checkbox.checked = false
  update_checkbox_state checkbox
  get_today_thing(i).value = ''
  return

reset_ui = ->
  reset_thing i for i in [0..2]
  update_today_list_date()
  return

archive_thingset = (thingset) ->
  prior_json = localStorage.getItem 'prior'
  prior = if prior_json isnt null then JSON.parse prior_json else []
  prior.push thingset
  localStorage.setItem 'prior', JSON.stringify prior
  localStorage.removeItem 'current'
  reset_ui()
  console.log 'Archived current state'
  console.log 'Archive value is now:', prior
  return

prior_thing_to_li = (thing) ->
  li = d.createElement 'li'
  if thing.completed then li.classList.add 'completed'
  li.appendChild d.createTextNode thing.text
  li

render_prior_thingset = (thingset, parent) ->
  details = d.createElement 'details'
  summary = d.createElement 'summary'
  list = d.createElement 'ul'
  summary.appendChild d.createTextNode new Date(thingset.date).toDateString()
  details.appendChild summary
  details.appendChild list
  list.appendChild prior_thing_to_li thing for thing in thingset.things
  parent.appendChild details
  return

clear_prior_things = ->
  details = d.getElementById 'prior'
  details.removeChild child for child in to_array details.getElementsByTagName 'details'
  return

render_group_of_prior_thingsets = (month, thingsets) ->
  prior = d.getElementById 'prior'
  details = d.createElement 'details'
  summary = d.createElement 'summary'
  summary.appendChild d.createTextNode month
  details.appendChild summary
  render_prior_thingset thingset, details for thingset in thingsets
  prior.appendChild details
  return

render_prior_things = (prior_thingsets) ->
  sorted_thingsets = prior_thingsets.sort (a, b) ->
    if a.date < b.date then 1 else if a.date > b.date then -1 else 0

  months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

  grouped_thingsets = sorted_thingsets.group_by (thingset) ->
    date = new Date(thingset.date)
    months[date.getMonth()] + ' ' + date.getFullYear()

  render_group_of_prior_thingsets month, things for month, things of grouped_thingsets

  return

is_current_day = (date) ->
  value = if date instanceof Date then date else new Date date
  new Date().getDay() is value.getDay()

clear_and_render_prior = (prior_state) ->
  clear_prior_things()
  render_prior_things prior_state if prior_state
  d.getElementById('prior').style.display = if not prior_state or prior_state.length is 0 then 'none' else 'block'
  return

interval_check_whether_day_changed = ->
  current_thingset = get_current_thingset_state()
  if current_thingset.date and not is_current_day(current_thingset.date) and not thingset_is_empty(current_thingset)
    console.log 'Interval check: archiving current thingset since the day has changed'
    archive_thingset current_thingset
    clear_and_render_prior load_state 'prior'
  else
    console.log 'Interval check: *not* archiving current thingset'
  return

backup_warning_maybe = ->
  last_warning_or_backup = localStorage.getItem 'last_warning_or_backup'
  four_weeks_in_ms = 2419200000

  if last_warning_or_backup is null
    localStorage.last_warning_or_backup = Date.now()
  else if Date.now() - last_warning_or_backup > four_weeks_in_ms
    localStorage.last_warning_or_backup = Date.now()
    alert 'You haven’t backed up your data in awhile. Better safe than sorry!'

  return

dismiss_warning = (event) ->
  storage_key = this.parentNode.id + '_dismissed'
  localStorage.setItem storage_key, 'true'
  this.parentNode.style.display = 'none'
  return

resize_all_things = ->
  resize_textarea get_today_thing i for i in [0..2]
  return

thingset_is_empty = (thingset) ->
  return true if not thingset or not thingset.things or not thingset.things.length
  things_with_text = (thing for thing in thingset.things when thing.text.trim().length > 0)
  return things_with_text.length is 0

d.addEventListener 'DOMContentLoaded', ->
  if localStorage.getItem('data_warning_dismissed') is null
    d.getElementById('data_warning').style.display = 'block'

  if window.navigator.userAgent.indexOf('Firefox') isnt -1 and localStorage.getItem('firefox_warning_dismissed') is null
    d.getElementById('firefox_warning').style.display = 'block'
  if window.navigator.userAgent.indexOf('MSIE') isnt -1 and localStorage.getItem('ie_warning_dismissed') is null
    d.getElementById('ie_warning').style.display = 'block'

  current_state = load_state 'current'
  if not thingset_is_empty(current_state) and not is_current_day(current_state.date)
    archive_thingset current_state
  else if current_state
    render_current_state current_state

  # render_current_state calls resize_textarea but I’ve noticed that there’s some kind of
  # race condition in Chrome/Mac wherein sometimes the resizing doesn’t properly work until
  # a few ms after the page loads — I’m not sure how many exactly. Therefore this VOODOO HACK!
  setTimeout resize_all_things, ms for ms in [1...10]

  setInterval interval_check_whether_day_changed, 60000

  textarea.addEventListener 'input', handle_text_input for textarea in to_array d.getElementsByClassName 'thing_text'
  input.addEventListener 'change', handle_checkbox_change for input in to_array d.getElementsByTagName 'input' when input.type is 'checkbox'
  d.getElementById('button_dismiss_data_warning').addEventListener 'click', dismiss_warning
  d.getElementById('button_dismiss_firefox_warning').addEventListener 'click', dismiss_warning
  d.getElementById('button_dismiss_ie_warning').addEventListener 'click', dismiss_warning

  # Prior state is rendered last because it’s more important to set up interactivity first
  clear_and_render_prior load_state 'prior'

  backup_warning_maybe()
