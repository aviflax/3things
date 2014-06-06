// Generated by CoffeeScript 1.7.1
(function() {
  var archive_thingset, backup_warning_maybe, clear_and_render_prior, clear_prior_things, current_iso_date, d, dismiss_warning, get_checkbox, get_current_thingset_state, get_thing_state, get_today_thing, get_today_thingset, handle_checkbox_change, handle_export_click, handle_import_click, handle_text_input, input_ids, interval_check_whether_day_changed, is_current_day, load_state, prior_thing_to_li, render_current_state, render_current_thing, render_prior_things, render_prior_thingset, reset_thing, reset_ui, resize_all_things, resize_textarea, save_current_state, thingset_is_empty, to_array, toggle_import_button, update_checkbox_state, update_today_list_date;

  d = document;

  input_ids = ['first', 'second', 'third'];

  to_array = function(sequential_thing) {
    return Array.prototype.slice.call(sequential_thing);
  };

  current_iso_date = function() {
    return new Date().toISOString();
  };

  get_checkbox = function(i) {
    return d.getElementById(input_ids[i] + '_status');
  };

  get_today_thing = function(i) {
    return d.getElementById(input_ids[i] + '_text');
  };

  get_today_thingset = function() {
    return d.getElementById('today_things');
  };

  update_today_list_date = function() {
    return get_today_thingset().dataset.date = current_iso_date();
  };

  update_checkbox_state = function(checkbox) {
    var text_input;
    text_input = checkbox.nextSibling;
    if (checkbox.checked) {
      text_input.classList.add('completed');
    } else {
      text_input.classList.remove('completed');
    }
  };

  handle_checkbox_change = function(event) {
    var checkbox;
    checkbox = event.target;
    update_checkbox_state(checkbox);
    if (checkbox.checked) {
      checkbox.dataset.dateTimeCompleted = current_iso_date();
    } else {
      delete checkbox.dataset.dateTimeCompleted;
    }
    save_current_state();
  };

  get_thing_state = function(i) {
    return {
      completed: get_checkbox(i).checked,
      date_time_completed: get_checkbox(i).dataset.dateTimeCompleted || null,
      text: get_today_thing(i).value.trim()
    };
  };

  get_current_thingset_state = function() {
    var i;
    return {
      things: (function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; _i <= 2; i = ++_i) {
          _results.push(get_thing_state(i));
        }
        return _results;
      })(),
      date: get_today_thingset().dataset.date
    };
  };

  save_current_state = function() {
    var current;
    current = get_current_thingset_state();
    if (!thingset_is_empty(current)) {
      localStorage.setItem('current', JSON.stringify(current));
      console.log('Saved state:', current);
    } else {
      console.log('Did *not* save state because it was empty.');
    }
  };

  resize_textarea = function(textarea) {
    textarea.style.height = '0';
    textarea.style.height = textarea.scrollHeight + 'px';
  };

  handle_text_input = function(event) {
    resize_textarea(this);
    update_today_list_date();
    save_current_state();
  };

  render_current_thing = function(thing, i) {
    var checkbox, textarea;
    textarea = get_today_thing(i);
    textarea.value = thing.text;
    resize_textarea(textarea);
    checkbox = get_checkbox(i);
    checkbox.checked = thing.completed;
    update_checkbox_state(checkbox);
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

  render_current_state = function(state) {
    var i, thing, _i, _len, _ref;
    get_today_thingset().dataset.date = state.date;
    _ref = state.things;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      thing = _ref[i];
      render_current_thing(thing, i);
    }
  };

  reset_thing = function(i) {
    var checkbox;
    checkbox = get_checkbox(i);
    checkbox.checked = false;
    get_today_thing(i).value = '';
  };

  reset_ui = function() {
    var i, _i;
    for (i = _i = 0; _i <= 2; i = ++_i) {
      reset_thing(i);
    }
    update_today_list_date();
  };

  archive_thingset = function(thingset) {
    var prior, prior_json;
    prior_json = localStorage.getItem('prior');
    prior = prior_json !== null ? JSON.parse(prior_json) : [];
    prior.push(thingset);
    localStorage.setItem('prior', JSON.stringify(prior));
    localStorage.removeItem('current');
    reset_ui();
    console.log('Archived current state');
    console.log('Archive value is now:', prior);
  };

  prior_thing_to_li = function(thing) {
    var li;
    li = d.createElement('li');
    if (thing.completed) {
      li.classList.add('completed');
    }
    li.appendChild(d.createTextNode(thing.text));
    return li;
  };

  render_prior_thingset = function(thingset) {
    var details, list, prior, summary, thing, _i, _len, _ref;
    prior = d.getElementById('prior');
    details = d.createElement('details');
    summary = d.createElement('summary');
    list = d.createElement('ul');
    summary.appendChild(d.createTextNode(new Date(thingset.date).toDateString()));
    details.appendChild(summary);
    details.appendChild(list);
    _ref = thingset.things;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      thing = _ref[_i];
      list.appendChild(prior_thing_to_li(thing));
    }
    prior.appendChild(details);
  };

  clear_prior_things = function() {
    var child, details, _i, _len, _ref;
    details = d.getElementById('prior');
    _ref = to_array(details.getElementsByTagName('details'));
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      details.removeChild(child);
    }
  };

  render_prior_things = function(prior_things) {
    var thingset, _i, _len, _ref;
    _ref = prior_things.sort(function(a, b) {
      if (a.date < b.date) {
        return 1;
      } else if (a.date > b.date) {
        return -1;
      } else {
        return 0;
      }
    });
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      thingset = _ref[_i];
      render_prior_thingset(thingset);
    }
  };

  is_current_day = function(date) {
    var value;
    value = date instanceof Date ? date : new Date(date);
    return new Date().getDay() === value.getDay();
  };

  clear_and_render_prior = function(prior_state) {
    clear_prior_things();
    if (prior_state) {
      render_prior_things(prior_state);
    }
    d.getElementById('prior').style.display = !prior_state || prior_state.length === 0 ? 'none' : 'block';
  };

  handle_export_click = function() {
    var child, data, output, _i, _len, _ref;
    output = d.getElementById('export_output');
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
    output.select();
    localStorage.last_warning_or_backup = Date.now();
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
    if (input.current !== null) {
      render_current_state(input.current);
    }
    clear_and_render_prior(input.prior);
    textarea.value = '';
    if (event.target) {
      event.target.disabled = true;
    }
    alert('Import/Restore succeeded!');
  };

  toggle_import_button = function(event) {
    setTimeout((function() {
      return d.getElementById('button_import').disabled = event.target.value.trim().length === 0;
    }), 1);
  };

  interval_check_whether_day_changed = function() {
    var current_thingset;
    current_thingset = get_current_thingset_state();
    if (current_thingset.date && !is_current_day(current_thingset.date) && !thingset_is_empty(current_thingset)) {
      console.log('Interval check: archiving current thingset since the day has changed');
      archive_thingset(current_thingset);
      clear_and_render_prior(load_state('prior'));
    } else {
      console.log('Interval check: *not* archiving current thingset');
    }
  };

  backup_warning_maybe = function() {
    var four_weeks_in_ms, last_warning_or_backup;
    last_warning_or_backup = localStorage.getItem('last_warning_or_backup');
    four_weeks_in_ms = 2419200000;
    if (last_warning_or_backup === null) {
      localStorage.last_warning_or_backup = Date.now();
    } else if (Date.now() - last_warning_or_backup > four_weeks_in_ms) {
      localStorage.last_warning_or_backup = Date.now();
      alert('You haven’t backed up your data in awhile. Better safe than sorry!');
    }
  };

  dismiss_warning = function() {
    localStorage.setItem('warning_dismissed', 'true');
    d.getElementById('warning').style.display = 'none';
  };

  resize_all_things = function() {
    var i, _i;
    for (i = _i = 0; _i <= 2; i = ++_i) {
      resize_textarea(get_today_thing(i));
    }
  };

  thingset_is_empty = function(thingset) {
    var thing, things_with_text;
    if (!thingset || !thingset.things || !thingset.things.length) {
      return true;
    }
    things_with_text = (function() {
      var _i, _len, _ref, _results;
      _ref = thingset.things;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        thing = _ref[_i];
        if (thing.text.trim().length > 0) {
          _results.push(thing);
        }
      }
      return _results;
    })();
    return things_with_text.length === 0;
  };

  d.addEventListener('DOMContentLoaded', function() {
    var current_state, input, ms, textarea, _i, _j, _k, _len, _len1, _ref, _ref1;
    if (localStorage.getItem('warning_dismissed')) {
      d.getElementById('warning').style.display = 'none';
    }
    current_state = load_state('current');
    if (!thingset_is_empty(current_state && !is_current_day(current_state.date))) {
      archive_thingset(current_state);
    } else if (current_state) {
      render_current_state(current_state);
    }
    for (ms = _i = 1; _i < 10; ms = ++_i) {
      setTimeout(resize_all_things, ms);
    }
    setInterval(interval_check_whether_day_changed, 60000);
    _ref = to_array(d.getElementsByClassName('thing_text'));
    for (_j = 0, _len = _ref.length; _j < _len; _j++) {
      textarea = _ref[_j];
      textarea.addEventListener('input', handle_text_input);
    }
    _ref1 = to_array(d.getElementsByTagName('input'));
    for (_k = 0, _len1 = _ref1.length; _k < _len1; _k++) {
      input = _ref1[_k];
      if (input.type === 'checkbox') {
        input.addEventListener('change', handle_checkbox_change);
      }
    }
    d.getElementById('button_dismiss_warning').addEventListener('click', dismiss_warning);
    d.getElementById('button_export').addEventListener('click', handle_export_click);
    d.getElementById('import_input').addEventListener('input', toggle_import_button);
    d.getElementById('button_import').addEventListener('click', handle_import_click);
    clear_and_render_prior(load_state('prior'));
    return backup_warning_maybe();
  });

}).call(this);
