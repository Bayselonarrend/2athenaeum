import { getDataByUrl }   from './xhttp.js';
import { getCookie }      from './xhttp.js';
import { getUserData }    from './users.js';
import { ping }           from './xhttp.js';
import { showMessage }    from './effects.js';

document.addEventListener("DOMContentLoaded", makeBook);

function makeBook(){
  
  let booktitle       = document.querySelectorAll('.book-title');  
  let bookauthor      = document.querySelectorAll('.book-author');
  let bookauthorlink  = document.querySelectorAll('.book-authorlink');
  let bookdescription = document.querySelectorAll('.book-description');
  let body            = document.querySelector('body');
  let meta_description  = document.querySelector('meta[name="description"]');
  

    
  let searchParams = new URLSearchParams(window.location.search);
  let id    = searchParams.get('id');
  let uuid  = getCookie('uuid');


  getDataByUrl('/static/books/' + id + '/data.json', true).then(function(response)
  {
    let code                  = document.getElementById('code');
    document.title            = response.title + ' — Two-Digit Athenaeum';
    meta_description.content  = 'Читайте произведение ' + response.title + ', ' + response.author + ' на Two-Digit Athenaeum абсолютно бесплатно через VK или Telegram!'
    
    booktitle.forEach(function(element) {
      element.innerHTML = response.title;
    });
    
     bookauthor.forEach(function(element) {
       if (element.id != 'authorlink')
       {
        element.textContent = response.author;
       }
    }); 
    
    bookauthorlink.forEach(function(element) {
      element.href      = '/author?id=' + response.author_id;
      element.innerHTML = response.author;
    });
    

            
    bookdescription.forEach(function(element) {
      element.innerHTML = response.description;
    }); 
        
    code.innerHTML = String(id) + code.innerHTML;    

    body.style.setProperty('--cover', 'url(/static/books/' + id + '/medium.webp) no-repeat no-repeat center');
        
     
 });
 
  getUserData().then(function(response){
    
    let vk      = document.getElementById('vk-login');
    let tg      = document.getElementById('telegram-login');
    let session = getCookie('uuid');
       
    if (response == false)
    {
      vk.href = '/login?from=' + id;
      tg.href = '/login?from=' + id;   
    }
    else
    {
      vk.onclick = function(event) {
        let session = getCookie("uuid");
        event.preventDefault();       
        ping('https://api.athenaeum.digital/u/hs/bot/sendBook?cookie=' + session + '&book=' + id + '&social=vk').then(function(success){
          if(success) {showMessage('Отправлено!', 'success')}
          else        {showMessage('Ошибка! Проверьте, подключен ли у вас аккаунт данной социальной сети и начали ли вы диалог с <a class="alert-a" href="https://vk.com/im?sel=-218704372">нашим ботом в ВК</a> (нужно нажать <i>"Начать"</i> или написать любое сообщение)' , 'danger')}
          });
        };
      tg.onclick = function(event) {
        let session = getCookie("uuid");
        event.preventDefault(); 
        ping('https://api.athenaeum.digital/u/hs/bot/sendBook?cookie=' + session + '&book=' + id + '&social=tg').then(function(success){         
          if(success) {showMessage('Отправлено!', 'success')}
          else        {showMessage('Ошибка! Проверьте, подключен ли у вас аккаунт данной социальной сети и повторите попытку позже', 'danger')}
          });   
      };    
    }
    
    
    
  });

}
  