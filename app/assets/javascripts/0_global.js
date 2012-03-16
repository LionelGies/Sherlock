$.ajaxSetup({
    'beforeSend': function (xhr) {
      xhr.setRequestHeader("Accept", "text/javascript");      
    }  
});

var SHERLOCK = SHERLOCK || {};
SHERLOCK.utils = SHERLOCK.utils || {};

SHERLOCK.utils.flashMessage = function(clazz, txt) {
    var msgs = $('.flash-messages');
    var m = msgs.find('.' + clazz);
    if (!m.length) {
        m = $('<div>').addClass('msg').addClass(clazz);
        msgs.append(m);
    }
    m.html(txt);
    setTimeout(SHERLOCK.utils.hideFlashMessages, 5000);
};

SHERLOCK.utils.showAjaxError = function() {
  SHERLOCK.utils.hideAjaxLoading();
  alert('Request failed, please try again');
};

SHERLOCK.utils.formAjaxify = function(form) {
  form.bind('ajax:before', function() {
    var f = this;
    // manually copy over TinyMCE contents into the textarea(s)
    if (tinyMCE) {
      $('textarea.rich', f).each(function() {
        var id = $(this).attr('id');
        if (id) {
          var ed = tinyMCE.get(id);          
          if (ed) {            
            $(this).val(ed.getContent());
          }
        }
      });    
    }
    SHERLOCK.utils.showAjaxLoading();
  });
  form.bind('ajax:complete', function(e) {    
  });
  form.bind('ajax:error', SHERLOCK.utils.showAjaxError);
};

SHERLOCK.utils.hideFlashMessages = function() {
    $('.flash-messages .msg').remove();        
};

SHERLOCK.focusOnField = function(element) {
    var form = $(element).get(0).form;
    var focusField = element;
    var errorFields = $('.field_with_errors input', form);
    if (errorFields.length) {
        focusField = errorFields[0];        
    }
    focusField.focus();    
};

SHERLOCK.utils.removeTinyMCE = function(eltId) {
    if (tinyMCE && eltId) {
        var exists = tinyMCE.get(eltId);
        if (exists) {
            tinyMCE.remove(exists);
        }
    }
};

SHERLOCK.utils.cookie = function(cookieName) {
    var result = '';    
    var cookies = document.cookie.split(';');
    $(cookies).each(function() {
        var pair = this.split('=');
        alert(pair[0]);
        if (pair[0] == cookieName) {          
          result = pair[1];          
        }
    });
    return result;      
}

SHERLOCK.utils.focusTinyMCE = function(eltId) {
    if (tinyMCE) {       
        setTimeout(function() {       
            tinyMCE.execCommand('mceFocus', false, eltId);
        }, 1000);                
    }
};

SHERLOCK.utils.showAjaxLoading = function() {
  var msg = 'Please wait';  
  $.blockUI({
    fadeIn: 0,    
    message: '<div id="ajax-loading"><div>' + msg + '...</div></div>'          
  });        
};

SHERLOCK.utils.hideAjaxLoading = function() {
  $.unblockUI({
    fadeOut: 0
  });
};

SHERLOCK.utils.hintFieldOnBlur = function(inst) {    
    var title = $(inst).attr('title');
    if (($(inst).val() == '')) {     
        $(inst).val(title).addClass('hinted');
    } else {
        $(inst).removeClass('hinted');
    }    
};

SHERLOCK.utils.initializeAutoHintFields = function() {
    
    var fields = $('.hint');
    fields.focus(function() {
        if (!$(this).hasClass('datepicker')) {
            if ($(this).val() == $(this).attr('title')) { 
                $(this).val('').removeClass('hinted');            
            }
        }
    });    
    
    fields.blur(function() {
        if (!$(this).hasClass('datepicker')) {
            SHERLOCK.utils.hintFieldOnBlur(this);
        }
    });    
    
    fields.each(function() {
        $(this).attr('AUTOCOMPLETE', 'OFF');
        var title = $(this).attr('title');
        if (this.value == '') { 
            this.value = title;
        }
        if (this.value == title) { 
            $(this).addClass('hinted'); 
        }        
    });
};

$(function() {
  
    $.rails.ajax = function(options) {      
      if (!options.timeout) {
        options.timeout = 1000 * 10;
      }      
      return $.ajax(options);
    };

    SHERLOCK.utils.initializeAutoHintFields();            
    
    $('.styled-select-rounded-x select').change(function() {
      this.blur();
    });
    
    $('.styled-select select').change(function() {
      this.blur();
    });
    
});


        
