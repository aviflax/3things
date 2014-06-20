// Generated by CoffeeScript 1.7.1
(function() {
  var d, export_data, handle_import_click, load_state, to_array, toggle_import_button;

  d = document;

  to_array = function(sequential_thing) {
    return Array.prototype.slice.call(sequential_thing);
  };

  load_state = function(which) {
    var json, state;
    json = localStorage.getItem(which);
    if (json !== null) {
      state = JSON.parse(json);
      console.log('loaded', which, 'state from localStorage', state);
      return state;
    } else {
      console.log('state', which, 'not present in localStorage');
      return null;
    }
  };

  export_data = function() {
    var child, data, output, _i, _len, _ref;
    output = d.getElementById('export_output');
    if (output.value.trim() === '') {
      _ref = to_array(output.childNodes);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        output.removeChild(child);
      }
      data = {
        current: load_state('current'),
        prior: load_state('prior')
      };
      output.value = JSON.stringify(data);
      setTimeout((function() {
        return output.select();
      }), 10);
      localStorage.last_warning_or_backup = Date.now();
    }
  };

  handle_import_click = function(event) {
    var input, prompt_result, textarea;
    prompt_result = prompt('This will ERASE all existing data! If you wish to proceed then enter “erase” below.');
    if (prompt_result !== 'erase') {
      return;
    }
    textarea = d.getElementById('import_input');
    input = JSON.parse(textarea.value);
    localStorage.current = JSON.stringify(input.current);
    localStorage.prior = JSON.stringify(input.prior);
    textarea.value = '';
    if (event.target) {
      event.target.disabled = true;
    }
    alert('Import/Restore succeeded! Go back to Three Things to see the results.');
  };

  toggle_import_button = function(event) {
    setTimeout((function() {
      return d.getElementById('button_import').disabled = event.target.value.trim().length === 0;
    }), 1);
  };

  d.addEventListener('DOMContentLoaded', function() {
    d.getElementById('export').addEventListener('click', export_data);
    d.getElementById('import_input').addEventListener('input', toggle_import_button);
    return d.getElementById('button_import').addEventListener('click', handle_import_click);
  });

}).call(this);
