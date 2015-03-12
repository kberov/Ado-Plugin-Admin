//admin.js - browser-side functionality for Ado::Plugin::Admin
// common functionality reused by all Admin plugins
(function($) {
  'use strict';
  $(document).ready(function($){
    /* Bind all the links from the sidebar to list_items */
    $('#admin_menu a[href*="ado"]').each(function(i){
      console.log('binding '+i+': ' + this.href);
      $(this).click(render_response);
    });
  }); // end $(document).ready(function($)

  function render_response () {
    $.get(this.href, function(res) {
      $('#main_content').html(res);
      $('title').text($('#tab_title').text())
    });
    return false;
  }
})(jQuery); //execute;
