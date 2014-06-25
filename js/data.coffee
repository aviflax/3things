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

export_data_json = ->
  data =
    current: load_state 'current'
    prior: load_state 'prior'
  JSON.stringify data

export_data_plaintext = ->
  output = d.getElementById 'export_output'
  if output.value.trim() is ''
    output.removeChild child for child in to_array output.childNodes
    output.value = export_data_json()
    setTimeout (()->output.select()), 10
    localStorage.last_warning_or_backup = Date.now()
  return

create_blob = ->
  new Blob [export_data_json()], {'type': 'application/json'}

export_data_file = ->
  a = d.getElementById 'save_export'
  a.download = "Three Things Export (Backup) of " + new Date().toISOString() + ".json"
  # This initially used a Data URI but that caused Chrome to ignore the value of the
  # download attribute and just save the file as download.json. For whatever reason,
  # using a blob URL ameliorates that issue.
  a.href = URL.createObjectURL create_blob()

do_import = (json_string) ->
  input = JSON.parse json_string
  localStorage.current = JSON.stringify input.current
  localStorage.prior = JSON.stringify input.prior
  return

handle_import_click = (event) ->
  prompt_result = prompt 'This will ERASE all existing data! If you wish to proceed then enter “erase” below.'
  if prompt_result isnt 'erase' then return

  # TODO: add error handling if, say, the value isn’t valid JSON or is missing
  # the required keys or if their values are the wrong shape
  textarea = d.getElementById 'import_input'
  do_import textarea.value
  textarea.value = ''
  event.target.disabled = true if event.target
  alert 'Import/Restore succeeded! Go back to Three Things to see the results.'
  return

toggle_import_button = (event) ->
  # This is crazy, but it’s necessary and it works
  # See http://stackoverflow.com/q/14841739
  setTimeout (()->
    d.getElementById('import_button').disabled = event.target.value.trim().length is 0
  ), 1
  return

import_file = (event) ->
  fr = new FileReader()
  fr.addEventListener 'load', ->
    do_import fr.result
    alert 'Import/Restore succeeded! Go back to Three Things to see the results.'
  fr.readAsText this.files[0]
  return

handle_delete_click = () ->
  prompt_result = prompt 'This will ERASE all existing data! If you wish to proceed then enter “erase” below.'
  if prompt_result isnt 'erase' then return
  localStorage.clear()
  alert 'All data deleted.'
  return

d.addEventListener 'DOMContentLoaded', ->

  # These two listeners should ideally be listening for the `toggle` event but that doesn’t seem to work
  # in any browsers right now
  d.getElementById('export_plaintext').addEventListener 'click', export_data_plaintext
  d.getElementById('export_file').addEventListener 'click', export_data_file

  d.getElementById('import_input').addEventListener 'input', toggle_import_button
  d.getElementById('import_button').addEventListener 'click', handle_import_click
  d.getElementById('import_file').addEventListener 'change', import_file
  d.getElementById('delete_button').addEventListener 'click', handle_delete_click
