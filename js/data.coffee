d = document
to_array = (sequential_thing) -> Array.prototype.slice.call sequential_thing

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

handle_export_click = ->
  output = d.getElementById 'export_output'
  output.removeChild child for child in to_array output.childNodes
  data =
    current: load_state 'current'
    prior: load_state 'prior'
  output.value = JSON.stringify data
  output.select()
  localStorage.last_warning_or_backup = Date.now()
  return

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
  textarea.value = ''
  event.target.disabled = true if event.target
  alert 'Import/Restore succeeded! Go back to Three Things to see the results.'
  return

toggle_import_button = (event) ->
  # This is crazy, but it’s necessary and it works
  # See http://stackoverflow.com/q/14841739
  setTimeout (()->
    d.getElementById('button_import').disabled = event.target.value.trim().length is 0
  ), 1
  return

d.addEventListener 'DOMContentLoaded', ->
  d.getElementById('button_export').addEventListener 'click', handle_export_click
  d.getElementById('import_input').addEventListener 'input', toggle_import_button
  d.getElementById('button_import').addEventListener 'click', handle_import_click
