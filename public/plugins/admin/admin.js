//admin.js - browser-side functionality for Ado::Plugin::Admin
// common functionality reused by all Admin plugins
(function($) {
  'use strict';
  $(document).ready(function($){
    /* Bind all the links from the sidebar to list_items */
    $('#admin_menu a[href*="ado"]').each(function(i){
      console.log('binding '+i+': ' + this.href);
      $(this).click(list_items);
    });
  }); // end $(document).ready(function($)

})(jQuery); //execute;
