d = document

to_array = (sequential_thing) -> Array.prototype.slice.call sequential_thing

d.addEventListener 'DOMContentLoaded', ->
  # add event listeners here
