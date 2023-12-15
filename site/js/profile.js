import { getUserData }        from './users.js?v4';
import { getBooksList }       from './users.js?v4';
import { getCookie }          from './xhttp.js?v4';
import { ping }               from './xhttp.js?v4';
import { generateLinks }      from './socials.js?v4';
import { setPreloaderEvent }  from './effects.js?v4';
import { showMessage }        from './effects.js?v4';

document.addEventListener("DOMContentLoaded", checkAuth);

function checkAuth(){
  
  let name      = document.getElementById('name');
  let id        = document.getElementById('id');
  let logout    = document.getElementById('logout');
  let total     = document.getElementById('total');
  let today     = document.getElementById('today');
  let actions   = document.getElementById('actions');
  let userinfo  = document.getElementById('userinfo');
  let week      = document.getElementById('week');
  let fin       = document.getElementById('fin');
  let senderbox = document.getElementById('senderbox');
  let session   = getCookie("uuid");
 
  getUserData().then(function(response){
       
    if (response == false)
    {
      if(window.location.pathname != '/login')
      {
        window.location.href = '/login?update=false';
      }
      else 
      {
        generateLinks();  
      }
    }
    
    else
    {
      if(window.location.pathname != '/profile')
      {
       window.location.href = '/profile';
       return
      }
      
   
      name.textContent    = response.name;
      id.textContent      = '#' + response.id;
      today.textContent   = response.data.length > 0 ? response.data[response.data.length - 1] : 0
      total.textContent   = response.total;
      week.textContent    = response.week;
      fin.textContent     = response.fin;
      
      if(!response.VK)
      {
        let a = document.createElement('a');
        a.id = "vk-login";
        a.innerHTML = "<li>Подключить ВК</li>";  
        actions.append(a);
        
        let b = document.createElement('li');
        b.innerHTML = "ВКонтакте не подключен";  
        userinfo.append(b);
      }
      else
      {
        let b = document.createElement('li');
        b.innerHTML = "ВКонтакте подключен";  
        userinfo.append(b);       
      }
      
      
      if(!response.Telegram)
      {
        let a = document.createElement('a');
        a.id = "telegram-login";
        a.innerHTML = "<li>Подключить Telegram</li>";  
        actions.append(a);
        
        let b = document.createElement('li');
        b.innerHTML = "Телеграм не подключен";  
        userinfo.append(b);
      }
      else
      {
        let b = document.createElement('li');
        b.innerHTML = "Телеграм подключен";  
        userinfo.append(b);       
      }
            
     
      logout.onclick = (event) => { 
        
        let uuid = getCookie("uuid");
        ping('https://api.athenaeum.digital/node/bot/site_user?cookie=' + uuid + '&action=logout')
        .then(function(success)
        {
            document.cookie = "uuid=" + uuid + ";max-age=-1;path=/";
            window.location.href = '/login';
  
        })
        .catch(function(error) {
          document.cookie = "uuid=" + uuid + ";max-age=-1;path=/";
          window.location.href = '/login';
        });
          
        
      };
      
      generateLinks(!response.VK, !response.Telegram, getCookie("uuid"));
      makeBooksList();
      
      
      //makeChartRound(response);
      makeWeekChart(response);
       senderbox.style.opacity = 1;
    }
     
  });
 
}

function makeChartRound(response){
 
 const el = document.getElementById('chartRound');
      const data = {
        categories: ['Слов'],
        series: [
          {
            name: 'Эта неделя',
            data: response.week,
          },
          {
            name: 'Сегодня',
            data: response.data.length > 0 ? response.data[response.data.length - 1] : 0,
          },

        ],
      };
      const options = {
        chart: { width: 250, height: 250 },
        series: {
          radiusRange: {
            inner: '40%',
            outer: '100%',
          },
          selectable: false,
        },
        legend:{
          visible: false,
        },
        exportMenu:{
          visible: false,
        },
        theme: {
          chart: {
            fontFamily: 'Verdana',
            backgroundColor: 'transparent',
            margin: 'auto',
          },
          series: {
            colors: ['#FFFFFF', '#0000004d', '#F8961E', '#F9C74F', '#90BE6D', '#43AA8B', '#577590'],
            lineWidth: 1,
            strokeStyle: '#000000',
          },
        }
      };

      const chart = toastui.Chart.pieChart({ el, data, options });

  
}

function makeWeekChart(response){
  
    const el = document.getElementById('chartWeek');
    const data = {
        categories: response.days,
        series: [
          {
            name: 'Слов',
            data: response.data,
          },
          
          {
            name: 'Цель',
            data: response.target,
          },

        ],
        
        
      };
      const options = {
        chart: { title: '', width: 'auto', height:'auto'},
        xAxis: { pointOnColumn: false, title: { text: 'Дни' } },
        yAxis: { title: 'Эта неделя' },
        legend:{
          visible: false,
        },
        exportMenu:{
          visible: false,
        },
        theme: {
          chart: {
            fontFamily: 'Tahoma',
            backgroundColor: 'transparent',
            margin: 'auto',
            color: '#FFFFFF',
            boxShadow: 'rgba(0,0,0,.40) 0px 5px 7px',
            title: {color: '#FFFFFF'},
          },
          legend:{
            color: '#FFFFFF',
          },
          series: {
            colors: ['#0000004d', '#00000019', '#F8961E', '#F9C74F', '#90BE6D', '#43AA8B', '#577590'],
          },
          xAxis: {
            title: {
              color: '#FFFFFF',
            },
            label: {
              color: '#FFFFFF',
            },
            width: 2,
            color: '#FFFFFF',
          },
          yAxis: [
      {
        title: {
          fontSize: 17,
          fontWeight: 400,
          color: '#FFFFFF'
        },
        label: {
          
          fontSize: 11,
          fontWeight: 700,
          color: '#FFFFFF'
        },
        width: 3,
        color: '#FFFFFF'
      },
      {
        title: {
          fontSize: 13,
          fontWeight: 600,
          color: '#FFFFFF'
        },
        label: {
          fontSize: 11,
          fontWeight: 700,
          color: '#FFFFFF'
        },
        width: 3,
        color: '#FFFFFF'
      }
    ]
        }
      };

      const chart = toastui.Chart.areaChart({ el, data, options }); 
}

function makeBooksList(){
 
 const table = document.getElementById('booksList');
 
 getBooksList(5).then(function(response){
   
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
      vk.title = 'VK';
      vk.innerHTML = '<i class="fa fa-vk vk-i"></i>';
      
      tg.classList.add('btn');
      tg.classList.add('sender-button');
      tg.classList.add('btn-outline-light');
      tg.classList.add('small-button');
      tg.title = 'Telegram';
      tg.innerHTML = '<i class="fa fa-telegram tg-i"></i>';
     
      c.append(tg);
      c.append(vk);
      
      vk.onclick = function(event) {
        let session = getCookie("uuid");
        event.preventDefault();       
        ping('https://api.athenaeum.digital/node/bot/site_start?cookie=' + session + '&book=' + item.id + '&social=vk').then(function(success){
          if(success) {showMessage('Отправлено!', 'success')}
          else        {showMessage('Ошибка! Проверьте, подключен ли у вас аккаунт данной социальной сети и повторите попытку позже', 'danger')}
          });
        };
      tg.onclick = function(event) {
        let session = getCookie("uuid");
        event.preventDefault(); 
        ping('https://api.athenaeum.digital/node/bot/site_start?cookie=' + session + '&book=' + item.id + '&social=tg').then(function(success){         
          if(success) {showMessage('Отправлено!', 'success')}
          else        {showMessage('Ошибка! Проверьте, подключен ли у вас аккаунт данной социальной сети и повторите попытку позже', 'danger')}
          });   
      };
     
    setPreloaderEvent(); 
 });

  
});
}