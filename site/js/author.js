import { getDataByUrl }       from './xhttp.js?v4';
import { ping }               from './xhttp.js?v4';
import { setPreloaderEvent }  from './effects.js?v4';
 
document.addEventListener("DOMContentLoaded", makeAuthor);

function makeAuthor(){
    var path = window.location.pathname;
    var booktitle;
    var bookauthor;
    var bookdescription;

    let authorname        = document.querySelectorAll('.author-name');  
    let authordate        = document.querySelectorAll('.author-date');
    let authordescription = document.querySelectorAll('.author-description');
    let mainimg           = document.querySelectorAll('.mainimg');
    let meta_description  = document.querySelector('meta[name="description"]');
      
      // Получить параметр id из URL-адреса
      var searchParams  = new URLSearchParams(window.location.search);
      var id            = searchParams.get('id');
      var image         = false;
      var imageUrl      = '/static/authors/' + id + '/0.webp';
      
      ping(imageUrl).then(function(success)
      { 
                
        if(success)
        {
         image = true; 
        }
        
        getDataByUrl('/static/authors/' + id + '/data.json', true).then(function(response)
        {   
          
          document.title = response.author + ' — Two-Digit Athenaeum';
          meta_description.content = 'Читайте произведения автора ' + response.author + ' на Two-Digit Athenaeum абсолютно бесплатно через VK или Telegram!'
          
          authorname.forEach(function(element) {
            element.innerHTML = response.author;
          });
              
          authordate.forEach(function(element) {
            element.innerHTML = response.date;
          });
                    
          mainimg.forEach(function(element) {
            element.src = image ? imageUrl : '/static/patterns/noauthor.webp';
            element.onload    = function() {
              this.classList.add('animate');
            };
          }); 
          
        }); 
        
        getDataByUrl('/static/authors/' + id + '/description.html', false).then(function(response)
        {         
          authordescription.forEach(function(element) {
            element.innerHTML = response;
            setPreloaderEvent();
          }); 
          
        });
        
        
        
      });   
}

makeAuthor();

    