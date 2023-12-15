import { getDataByUrl }   from './xhttp.js?v4';
import { setPreloaderEvent} from './effects.js?v4';

document.addEventListener("DOMContentLoaded", makeAuthorsList);

function makeAuthorsList(){
  
  let authorsByFirstLetter  = {};
  let authorslist           = document.querySelector('.author-list');
  let authorsindul          = document.querySelector('.author-index ul');
  let indexHtml             = '';
  let listHtml              = '';
  let authors;

  getDataByUrl('/static/authors.json', true).then(function(response)
  {
    authors = response;
    
    authors.sort(function(a, b) {
      return a.surname.localeCompare(b.surname);
    });
      
    for (let i = 0; i < authors.length; i ++) {
  
      let author      = authors[i];
      let firstLetter = author.surname.charAt(0).toUpperCase();
  
      if (!authorsByFirstLetter[firstLetter]) 
      {
        authorsByFirstLetter[firstLetter] = [];
      }
  
      authorsByFirstLetter[firstLetter].push(author);
    }
    
  
  
    for (let letter in authorsByFirstLetter) {
    
      indexHtml   += '<div class="nav-item"><a class="nav-link" href="#' + letter + '">' + letter + '</a></div>';
      listHtml    += '<div style="break-inside: avoid-column;"><h2 id="' + letter + '">' + letter + '</h2><ul>';
  
      for (let x = 0; x < authorsByFirstLetter[letter].length; x ++) {
        let author      = authorsByFirstLetter[letter][x];
        listHtml    += '<li><a class="authorname" href="' + author.url + '">' + author.surname + ' ' + author.name + '</a></li>';
      }
    
      listHtml += '</ul></div>';
  
    }
    
    authorsindul.innerHTML  = indexHtml;
    authorslist.innerHTML   = listHtml;
    setPreloaderEvent();
  });
  


}