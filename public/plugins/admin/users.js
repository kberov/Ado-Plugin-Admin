// public/plugins/admin/users.js
$('#tab_body .ui.dropdown').dropdown();
/*  */
function set_users_list_grid_height(){
  $('#tab_body #users_list.grid').outerHeight(
    $('.main.container').height() 
    - $('#tab_title').outerHeight()
    - $('#users_list_controls').outerHeight()
    - $('#users_list_header').outerHeight() -9
  );
}
set_users_list_grid_height();
//$(window).resize(set_users_list_grid_heigh);
