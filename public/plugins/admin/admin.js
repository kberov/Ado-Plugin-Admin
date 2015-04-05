//admin.js - browser-side functionality for Ado::Plugin::Admin
// common functionality reused by all Admin plugins
(function($) {
  'use strict';
  $(document).ready(function($){
    /* Bind all the links from the sidebar to list_items */
    $('#admin_menu a[href*="ado"]').each(function(i){
      console.log('binding '+i+': ' + this.href);
      $(this).click(get_data);
    });
  }); // end $(document).ready(function($)
  function get_data () {
    $.get(this.href, render_response);
    return false;
  }
  /**
  Causes every link loaded in the #tabbody to
  behave the same way as the links in the main menu.
  This causes the side efect that click events 
  set within those pages get overwritten by this function, 
  because it is executed after the content is loaded
  and JS in it executed.
  Todo: Think If we really need this or plugins may
  do it explicitly if they need this behavior. 
  */
  function render_response (res) {
      $('#main_content').html(res);
      $('title').text($('#tab_title').text());
      $('#main_content #tab_body a').each(function (i) {
        $(this).click(get_data);
      });
  }
})(jQuery); //execute;
