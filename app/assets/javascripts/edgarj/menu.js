/*
inspired from http://javascript-array.com/scripts/jquery_simple_drop_down_menu/
*/

Edgarj.Menu = {
  timeout:    500,
  closetimer: 0,
  ddmenuitem: 0,
  
  cancel_timer: function(){
    if(Edgarj.Menu.closetimer){
      window.clearTimeout(Edgarj.Menu.closetimer);
      Edgarj.Menu.closetimer = null;
    }
  },

  open: function(){
    Edgarj.Menu.cancel_timer();
    Edgarj.Menu.close();
    Edgarj.Menu.ddmenuitem = $(this).find('ul').eq(0).css('visibility', 'visible');
  },
  
  close: function(){
    if(Edgarj.Menu.ddmenuitem){
      Edgarj.Menu.ddmenuitem.css('visibility', 'hidden');
    }
  },
  
  timer: function(){
    Edgarj.Menu.closetimer = window.setTimeout(Edgarj.Menu.close, Edgarj.Menu.timeout);
  },
}

$(document).ready(function(){
  $('#edgarj_menu > li').bind('mouseover', Edgarj.Menu.open);
  $('#edgarj_menu > li').bind('mouseout',  Edgarj.Menu.timer);
});

document.onclick = Edgarj.Menu.close;
