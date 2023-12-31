import { getDataByUrl }     from './xhttp.js?v4';
import { ping }             from './xhttp.js?v4';
import { getCookie }        from './xhttp.js?v4';
import { getUserData }      from './users.js?v4';
import { setPreloaderEvent} from './effects.js?v4';

const content     = document.getElementById('content');
const sidebar     = document.getElementById('sidebar');
const vkbar       = document.getElementById('vk_groups');


window.addEventListener ('pageshow', function (event) {
  
    if (event.currentTarget.origin !== "https://athenaeum.digital") // Compliant
    return;
  
  if (event.persisted) 
  {
    setOpacity();
  } 
  
});

standartOnLoad();

function standartOnLoad(){
  
          if ('serviceWorker' in navigator && navigator.serviceWorker.controller != null && navigator.serviceWorker.controller.state != 'activated') 
        {
         navigator.serviceWorker.register('/sw.js').then(
           function(registration) {
             console.log('ServiceWorker registration successful with scope: ', registration.scope); 
             
             },
           function(err) {
             console.log('ServiceWorker registration failed: ', err);
           });
      
        }
  
    let sidebarCache = false;
    
    getDataByUrl('/blocks/sidebar.html', false).then(function(response)
    {

        if(sidebar != undefined)
        {
          sidebar.innerHTML = response;
          sidebar.style.display = 'flex';
          localStorage.setItem('navigation', sidebar.innerHTML);
        }
      
      
      const status      = document.getElementById("status");
      const info        = document.getElementById("statinfo");
      const profile     = document.getElementById('profilelink');
      
      ping('https://api.athenaeum.digital/node/bot/site_ping')
      .then(function(success)
      {
        
        if(success)
        {
          status.classList.remove("oi-link-broken"); 
          status.classList.remove("oi-loop-circular"); 
          status.classList.add("oi-link-intact");
          status.style.color = "#869F3F";
          status.title = "Сервер ботов онлайн!";
          if (info) { info.textContent = "Этот значек обычно находится на панели навигации. Значек цепи означает что сервера онлайн и все функции библиотеки сейчас доступны. Если сервер по каким-либо причнам будет недоступен, на индикаторе будет разорванная цепь" }
        }
        else
        {
          status.classList.remove("oi-link-intact");
          status.classList.remove("oi-loop-circular"); 
          status.classList.add("oi-link-broken");
          status.style.color = "#9E3F3F";
          status.title = "Сервер ботов оффлайн!";
          if (info) { info.textContent = "Этот значек обычно находится на панели навигации. Сейчас он выглядит как разорванная цепь. Это означает что авторизация и боты библиотеки временно недоступны. Как только мы все починим на этом индикаторе значек цепи будет целым" }
        }

      })
      .catch(function(error) {
        status.classList.remove("oi-link-intact");
        status.classList.remove("oi-loop-circular"); 
        status.classList.add("oi-link-broken");
        status.style.color = "#9E3F3F";
        status.title = "Сервер ботов оффлайн!";
        if (info) { info.textContent = "Этот значек обычно находится на панели навигации. Сейчас он красный. Это означает что авторизация и боты библиотеки временно недоступны. Как только мы все починим, этот значек станет зеленым" }
     
      });
      

      setPreloaderEvent();
      setOpacity();  
      
      let tg      = window.Telegram;

      
    if(tg != undefined){
      if (tg.WebApp != undefined && tg.WebApp.initData != undefined){
       
      let safe    = tg.WebApp.initData;
      
       tg.WebApp.backgroundColor = '#3d3d3d';
       tg.WebApp.headerColor = '#212121';
       tg.WebApp.expand(); 
  
          ping('https://api.athenaeum.digital/node/bot/tg_miniapp?cookie=' + getCookie("uuid") + "&" + safe);
      }    
    }
    });        
}

function setOpacity(){
    content.style.opacity       = "1";
    
    if(vkbar){
     
    setTimeout(function() {  
       vkbar.style.opacity = "1";
       vkbar.style.transition = "opacity 1s ease-out";    
    }, 1800); 
    
    }
}

