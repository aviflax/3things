// Generated by CoffeeScript 1.7.1
(function() {
  var create_blob, d, do_import, export_data_file, export_data_json, export_data_plaintext, handle_delete_click, handle_import_click, import_file, load_state, to_array, toggle_import_button, unhide, unhide_safari;

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

  export_data_json = function() {
    var data;
    data = {
      current: load_state('current'),
      prior: load_state('prior')
    };
    return JSON.stringify(data);
  };

  export_data_plaintext = function() {
    var child, output, _i, _len, _ref;
    output = d.getElementById('export_output');
    if (output.value.trim() === '') {
      _ref = to_array(output.childNodes);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        output.removeChild(child);
      }
      output.value = export_data_json();
      setTimeout((function() {
        return output.select();
      }), 10);
      localStorage.last_warning_or_backup = Date.now();
    }
  };

  create_blob = function() {
    return new Blob([export_data_json()], {
      'type': 'application/json'
    });
  };

  export_data_file = function() {
    var a;
    a = d.getElementById('save_export');
    a.download = "Three Things Export (Backup) of " + new Date().toISOString() + ".json";
    return a.href = URL.createObjectURL(create_blob());
  };

  do_import = function(json_string) {
    var input;
    input = JSON.parse(json_string);
    localStorage.current = JSON.stringify(input.current);
    localStorage.prior = JSON.stringify(input.prior);
  };

  handle_import_click = function(event) {
    var prompt_result, textarea;
    prompt_result = prompt('This will ERASE all existing data! If you wish to proceed then enter “erase” below.');
    if (prompt_result !== 'erase') {
      return;
    }
    textarea = d.getElementById('import_input');
    do_import(textarea.value);
    textarea.value = '';
    if (event.target) {
      event.target.disabled = true;
    }
    alert('Import/Restore succeeded! Go back to Three Things to see the results.');
  };

  toggle_import_button = function(event) {
    setTimeout((function() {
      return d.getElementById('import_button').disabled = event.target.value.trim().length === 0;
    }), 1);
  };

  import_file = function(event) {
    var fr;
    fr = new FileReader();
    fr.addEventListener('load', function() {
      do_import(fr.result);
      return alert('Import/Restore succeeded! Go back to Three Things to see the results.');
    });
    fr.readAsText(this.files[0]);
  };

  handle_delete_click = function() {
    var prompt_result;
    prompt_result = prompt('This will ERASE all existing data! If you wish to proceed then enter “erase” below.');
    if (prompt_result !== 'erase') {
      return;
    }
    localStorage.clear();
    alert('All data deleted.');
  };

  unhide = function(browser_identifier, class_name) {
    var e, _i, _len, _ref;
    if (window.navigator.userAgent.indexOf(browser_identifier) !== -1) {
      _ref = to_array(d.getElementsByClassName(class_name));
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        e.style.display = 'block';
      }
    }
  };

  unhide_safari = function() {
    var e, _i, _len, _ref;
    if (window.navigator.userAgent.indexOf('Safari') !== -1 && window.navigator.userAgent.indexOf('Chrome') === -1) {
      _ref = to_array(d.getElementsByClassName('safari'));
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        e.style.display = 'block';
      }
    }
  };

  d.addEventListener('DOMContentLoaded', function() {
    d.getElementById('export_plaintext').addEventListener('click', export_data_plaintext);
    d.getElementById('export_file').addEventListener('click', export_data_file);
    d.getElementById('import_input').addEventListener('input', toggle_import_button);
    d.getElementById('import_button').addEventListener('click', handle_import_click);
    d.getElementById('import_file').addEventListener('change', import_file);
    d.getElementById('delete_button').addEventListener('click', handle_delete_click);
    unhide('MSIE', 'ie');
    return unhide_safari();
  });

}).call(this);
