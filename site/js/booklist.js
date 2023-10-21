import { getUserData }        from './users.js';
import { getBooksList }       from './users.js';
import { getCookie }          from './xhttp.js';
import { ping }               from './xhttp.js';
import { generateLinks }      from './socials.js';
import { setPreloaderEvent }  from './effects.js';
import { showMessage }        from './effects.js';

document.addEventListener("DOMContentLoaded", checkAuthBookList);

function checkAuthBookList(){
  
  let session   = getCookie("uuid");
 
  getUserData().then(function(response){
       
    if (response == false)
    {
      if(window.location.pathname != '/login')
      {
        window.location.href = '/login';
      }
    }
    
    else
    {
      if(window.location.pathname != '/booklist')
      {
       window.location.href = '/booklist';
       return
      }
       
      makeBooksListFull();
      
    }
     
  });
 
}
function makeBooksListFull(){
 
 const table = document.getElementById('booksList');
 
 getBooksList(0).then(function(response){
   
   response.forEach(function(item, i, arr) {
      let b = document.createElement('tr');
      
      if(item.fin == true)
      {
        b.style.color     = "#869F3F";
      }
      
      b.innerHTML  += '<td><b>' + item.id             + '</b></td>';
      b.innerHTML  += '<td><a href="author?id='       + item.author_id    + '">' + item.author  + '</a></td>';
      b.innerHTML  += '<td><a href="book?id='         + item.id           + '">' + item.name    + '</a></td>';
      b.innerHTML  += '<td style="padding-top:0" id=' + item.id           +'></td>'; 
      b.innerHTML  += '<td><div class="progressbar"><span style="width: ' + (item.amount / item.total) * 100 + '%"></span></div></td>';
      
      table.append(b); 
      
      let tg  = document.createElement('button');
      let vk  = document.createElement('button');
      let c   = document.getElementById(item.id);
      
      
      vk.classList.add('btn');
      vk.classList.add('sender-button');
      vk.classList.add('btn-outline-light');
      vk.classList.add('small-button');
      vk.innerHTML = '<i class="fa fa-vk vk-i"></i>';
      
      tg.classList.add('btn');
      tg.classList.add('sender-button');
      tg.classList.add('btn-outline-light');
      tg.classList.add('small-button');
      tg.innerHTML = '<i class="fa fa-telegram tg-i"></i>';
     
      c.append(tg);
      c.append(vk);
      
      vk.onclick = function(event) {
        let session = getCookie("uuid");
        event.preventDefault();       
        ping('https://api.athenaeum.digital/u/hs/bot/sendBook?cookie=' + session + '&book=' + item.id + '&social=vk').then(function(success){
          if(success) {showMessage('Отправлено!', 'success')}
          else        {showMessage('Ошибка! Проверьте, подключен ли у вас аккаунт данной социальной сети и повторите попытку позже', 'danger')}
          });
        };
      tg.onclick = function(event) {
        let session = getCookie("uuid");
        event.preventDefault(); 
        ping('https://api.athenaeum.digital/u/hs/bot/sendBook?cookie=' + session + '&book=' + item.id + '&social=tg').then(function(success){         
          if(success) {showMessage('Отправлено!', 'success')}
          else        {showMessage('Ошибка! Проверьте, подключен ли у вас аккаунт данной социальной сети и повторите попытку позже', 'danger')}
          });   
      };
     
   });
     
    setPreloaderEvent(); 
 });

  
}