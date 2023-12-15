import { getDataByUrl }   from './xhttp.js?v4';
import { getCookie }      from './xhttp.js?v4';
import { uuidv4 }         from './xhttp.js?v4';

function getUserData(){
  
  return new Promise(function(resolve, reject) {
  
    let session = getCookie("uuid");
    let ready   = false;
    
    getDataByUrl('https://api.athenaeum.digital/node/bot/site_user?cookie=' + session, true).then(function(response)
    {
         
      if ((response) && response.status == "ok")
      {
        resolve(response);
      }
      else
      {
        resolve(false);
      }
      
    });
    
  }); 
}

function getBooksList(count){
  
  return new Promise(function(resolve, reject) {
  
    let session = getCookie("uuid");
    let ready   = false;
    
    count       = count == 0 ? '' : count;
    
    getDataByUrl('https://api.athenaeum.digital/node/bot/site_list?cookie=' + session + '&count=' + count, true).then(function(response)
    
    {
         
      if (response)
      {
        resolve(response);
      }
      else
      {
        resolve(false);
      }
      
    });
    
  }); 
}

 export{getUserData};
 export{getBooksList};