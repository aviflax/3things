d = document

to_array = (sequential_thing) -> Array.prototype.slice.call sequential_thing


input_to_text = (input) ->
  text = d.createTextNode input.value
  text.addEventListener 'click', (e) -> text_to_input e.target
  input.parentNode.replaceChild text, input
  return undefined


text_to_input = (text) ->
  console.log 'converting'
  input = d.createElement 'input'
  text.parentNode.replaceChild input, text
  return undefined


handle_item_click = (event) ->
  item = event.target
  console.log item
  console.log item.firstChild.nodeType
  fn = if item.firstChild.nodeType is Node.TEXT_NODE then text_to_input else input_to_text
  fn item.firstChild
  return undefined


d.addEventListener 'DOMContentLoaded', ->
  input.addEventListener('blur', (e) -> input_to_text e.target) for input in to_array d.getElementsByTagName 'input'
  #item.addEventListener 'click', handle_item_click for item in to_array d.getElementsByTagName 'li'
