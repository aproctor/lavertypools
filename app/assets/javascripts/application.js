// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require_tree .


$( document ).ready(function() {
  $('.datepicker').datepicker({format: 'yyyy-mm-dd'})

  $('form.ajax').submit(function() {
      var valuesToSubmit = $(this).serialize();
      $.ajax({
          url: $(this).attr('action'), //sumbits it to the given url of the form
          data: valuesToSubmit,
          method: $(this).attr('method'),
          dataType: "json" // you want a difference between normal and ajax-calls, and json is standard
      }).success(function(json){
          //act on result.
      });
      return false; // prevents normal behaviour
  });
});

var setPick = function(pickEl, pickId, pickValue) {
  $('#pick_'+pickId+'_row .selected').removeClass('selected');
  $(pickEl).addClass('selected');
  $formEl = $('#edit_pick_'+pickId);
  $formEl.find('#pick_winner_'+pickValue).prop('checked', true);
  $formEl.submit();
};


var toggleDateMode = function() {
  $('.simple_date,.advanced_date').toggle('hidden');
  var $check = $('#simple_format');
  $check.prop('checked', !$check.prop('checked'));
};
