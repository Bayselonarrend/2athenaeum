import { getDataByUrl }   from './xhttp.js?v4';
import { setPreloaderEvent } from './effects.js?v4';

document.addEventListener("DOMContentLoaded", AddEventListenerSearch);

function AddEventListenerSearch() {
   
    let searchIndex;
    let authorsIndex;
    let glossaryIndex;
    let searchInput     = document.getElementById('search-input');
    let searchResults   = document.getElementById('search-results');
    let copymi          = document.getElementById('copymi');
    let mainblock       = document.getElementById('mainblock');
    let searchTimeout;
    let timeout         = 0;

    getDataByUrl('../static/authors.json', true).then(function(response)
    {
      authorsIndex = response;
    });

    
    getDataByUrl('../static/search.json', true).then(function(response)
    {
      searchIndex = response;
      makeBooksGrid(searchIndex);
    });

    searchInput.addEventListener('input', function() {
       
       mainblock.style.minHeight = '450px'; 
       
      if(copymi != undefined)
      {
      copymi.style.display = "none";
      }
      
    	clearTimeout(searchTimeout);

    	searchTimeout = setTimeout(function() {
    	    	  
    		let query               = searchInput.value.toLowerCase();
    		let results             = search(query, searchIndex, authorsIndex, glossaryIndex);
    		
    			
        searchResults.innerHTML = '';
        
        searchResults.style.opacity = 1;

    		for (var i = 0; i < results.length && i < 5; i++) {

    			let result               = results[i].book;
    			result                   = !result.url ? result.book : result;
    			let resultElement        = document.createElement('a');
    			resultElement.href       = result.url;
    			resultElement.className  = 'list-group-item list-group-item-action search-list';
    			
    			if(result.title)
          {
    			 resultElement.innerHTML = '<div class="result"><span class="oi oi-book result-oi"></span><span class="result-text">' + result.name + ' ' + result.surname + ' - ' + result.title + '</span></div>';
          } 
    			else if(result.surname)
          {
    			 resultElement.innerHTML = '<div class="result"><span class="oi oi-person result-oi"></span><span class="result-text">' + result.name + ' ' + result.surname + '</div>';
    			}
          else
          {
    			 resultElement.innerHTML = '<div class="result"><span class="oi oi-text result-oi"></span><span class="result-text">' + result.name + '</div>';
    			}

    			searchResults.appendChild(resultElement);
    			searchResults.style.opacity = 1;
    			setTimeout(() => {resultElement.style.opacity = 1;}, 100);

    		}
    		
    		if (results.length == 0) {

    		  let resultElement2          = document.createElement('div');
    			resultElement2.className   = 'list-group-item list-group-item-action search-list';
    			resultElement2.innerHTML   = '<div class="result">Ничего не найдено</div>';
    			searchResults.appendChild(resultElement2); 

    		}
    		
    		setPreloaderEvent();
    		
    	}, 500);
    });
}

function makeBooksGrid(searchIndex){
 
 let booksGrid  = document.querySelectorAll('.last-book');
 let siLength   = searchIndex.length;
 let sliceCount = siLength <= 12 ? 0 : 6;
 sliceCount     = sliceCount == 0 && siLength >= 6 ? siLength - 6 : 0;
 let lastBooks  = searchIndex.slice(0, siLength - sliceCount);
 let gridBooks  = new Set();
 
 for (var j = 0; j < lastBooks.length && j < 6; j++) {
  
    let i   = Math.floor(Math.random() * searchIndex.length); 
    
    while (gridBooks.has(i))
    {
     i   = Math.floor(Math.random() * searchIndex.length);  
    }
    
    gridBooks.add(i);
    
    var re  = '/book?id=';
    let url = searchIndex[i].url;
    let id  = url.replace(re, ''); 
  
    let c = document.createElement('a');
    c.href = url;
    booksGrid[j].append(c);
    
    let b       = document.createElement('img');
    b.src       = '/static/books/' + id + '/small.webp'; 
    b.className = 'book-card';
    b.alt       = id;
    b.onload    = function() {
      this.style.animation = "ani 0.7s ease-out forwards";
    };
    
    c.append(b); 
    
    let d = document.createElement('br');
    c.append(d);
    
    let y = document.createElement('small');
    y.className = 'bookauthor-small';
    y.innerHTML = searchIndex[i].name + ' ' + searchIndex[i].surname;
    c.append(y); 
    
    let v = document.createElement('p');
    v.innerHTML = searchIndex[i].title;
    v.className = 'grid-p';
    c.append(v); 

 }
 
  setPreloaderEvent();
}

function search(query, searchIndex, authorsIndex, glossaryIndex) {


  let results = {};
  
  if (!query){
   return results; 
  }
  
  const words = query.toLowerCase().trim().split(' ').filter(str => str.length >= 2);
  
  var searchLength    = searchIndex.length;
  var authorsLength   = authorsIndex.length;
  var aIndex          = authorsIndex;
  var sIndex          = searchIndex;
  var gIndex          = glossaryIndex;
  var j               = 0;
  var entriesCount    = 0;
  
  
  
  for (let i = 0; i < words.length; i++) {
    
    const word = words[i];
    let ti = 0;
    
    for (let l = 0; l < authorsLength; l++) {

      const author = aIndex[l];

      if (author.name.toLowerCase().indexOf(word) !== -1 || author.surname.toLowerCase().indexOf(word) !== -1) {
        
        if (results[l]) 
        {
          results[l].count++;
        } 
        else 
        {
          results[ti] = {book: author, name: author.name, surname: author.surname, count: 100};
          ti++;
        }

      } 
      else 
      {
        
        if (results[l]) 
        {
          results[l].count = results[l].count - 50;
        }
      }
    }
    
    authorsLength  = Object.keys(results).length;  
    aIndex        = results;
    results       = {};
    
    searchLength    = searchLength;
    ti              = 0;
    
    for (let j = 0; j < searchLength; j++) {
      const book = sIndex[j];

      if (book.title.toLowerCase().indexOf(word) !== -1 || book.name.toLowerCase().indexOf(word) !== -1 || book.surname.toLowerCase().indexOf(word) !== -1) {
       
        if (results[j]) 
        {
          results[j].count++;
        } 
        else 
        {
          results[ti] = {book: book, name: book.name, surname: book.surname, title: book.title, count: 1};
          ti++;
        }

      } 
      else 
      {
       if (results[j]) 
       { 
       results[j].count = results[j].count - 4;
       }
      }
    }
     
    searchLength  = Object.keys(results).length;
    authorsLength = entriesCount;
     

    if (i > 0) 
    {      
      j = Object.keys(results)[Object.keys(results).length - 1];
      entriesCount = 0;
    }
    else
    {
      entriesCount = 1 + (Object.keys(results).length == 0 ? 0 : Object.keys(results)[Object.keys(results).length - 1]); 
    };  
    
    
    searchLength  = Object.keys(results).length;  
    sIndex        = results;
    results       = {};

  }
  
  
  let data  = Object.values(aIndex).concat(Object.values(sIndex));
  let final = Object.assign({}, data);
  
  Object.keys(final).forEach(key => {
  if (final[key].count < 0) {
    delete final[key];
  }
  
});
 
  const sortedResults = Object.values(final).sort((a, b) => b.count - a.count); 

  return sortedResults;

}

 export{AddEventListenerSearch};