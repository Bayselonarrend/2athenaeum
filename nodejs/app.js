const http 	= require("http");
const winax = require('winax');
const url 	= require('url');

const con 		= new ActiveXObject('V83.ComConnector', { activate: true });	
const processor = con.Connect('srvr ="AIONIOTISCORE";Ref ="AioPg"').DataProcessors.NodeProcessor;
	
function processePOST(request, response, method){
	
	return new Promise(function(resolve, reject) {
	
		let data = "";
		
		request.on("data", chunk => {
			data += chunk;
		});
		
		request.on("end", () => {
			call1C(data, response, method).then(function(response)
			{
				resolve(response);
			});
		});
		
	});
	
}	

function processeGET(parsed, response, method){
	
	return new Promise(function(resolve, reject) {
		let data = parsed.query;
		call1C(data, response, method).then(function(response)
		{
			resolve(response);
		});
	});
}

function call1C(data, response, method){
	
	return new Promise(function(resolve, reject) {
		try {
			
			responseData = processor[method](data);
			response.statusCode = 200;
			
			if (responseData != undefined){
				response.setHeader('Content-Type', 'application/json');
				resolve(responseData);	
			}
			else{
				resolve("");
			}
			return;
			
		} catch (error) {
			response.statusCode = 502;
			console.error(error);
			reject(undefined);
		}
		
		resolve(undefined);
	});
	
}
	
http.createServer(function(request,response){
    
	try{
	parsed 		= url.parse(request.url);
	pathname 	= parsed.pathname;
	
	response.setHeader('Access-Control-Allow-Headers', '*');
	response.setHeader('Access-Control-Allow-Origin', 'https://athenaeum.digital');
	
	switch (request.method) {

		
		case 'OPTIONS': {
			response.statusCode = 200;
			response.end();
			break;
		}
		
		case 'GET': { 
				
			switch (pathname) {
				
				case '/node/bot/site_ping': {
					response.end();
					break;
				}
				
                case '/node/bot/site_start': {

					processeGET(parsed, response, 'TakeStart').then(function(responseData){;
						response.end(responseData);
						
					});
					break;
				}
				
				case '/node/bot/site_session': {

					processeGET(parsed, response, 'CookieCheck').then(function(responseData){
						response.statusCode = responseData;
						response.end();				
					});
					break;
				}
				
				case '/node/bot/tg_miniapp': { 

					processeGET(parsed, response, 'MiniApp').then(function(responseData){;
						response.end(responseData);						
					});
					break;
				}
				
				case '/node/bot/vk_login': {

					processeGET(parsed, response, 'VKLogin').then(function(responseData)
					{
					
						let code = responseData['code'];
						let loc  = responseData['headers']['Location'];
							
						if(loc  != undefined){ response.setHeader('Location', loc.toString());}
						if(code != undefined){ response.statusCode = code;}
						
						response.writeHead(code, {
							location: loc.toString(),
						});

						
						response.end();			
					});
					break;
				}
				
				case '/node/bot/site_user': {

					processeGET(parsed, response, 'UserData').then(function(responseData)
					{
					
						let code   = responseData['code'];
						let rdata  = responseData['data'];
						
						if(code  != undefined){ response.statusCode = code;}			
						if(rdata != undefined) {response.end(rdata.toString())} else {response.end()};						
					});
					break;
				}
				
				case '/node/bot/site_list': {

					processeGET(parsed, response, 'BookList').then(function(responseData)
					{
					
						if(responseData != undefined) {response.end(responseData.toString())} else {response.end()};	
												
					});
					break;
				}
				
				case '/node/bot/site_progress': {

					processeGET(parsed, response, 'UserProgress').then(function(responseData)
					{
					
						if(responseData != undefined) {response.end(responseData.toString())} else {response.end()};	
												
					});
					break;
				}
				
				default: {
					response.statusCode = 200;
					response.end();
				}
			}
			break;

		}
		
		
		case 'POST': { 
					
			switch (pathname) {
				
                case '/node/bot/tg_bot': {

					processePOST(request, response, 'BotTelegram').then(function(responseData)
					{
						response.statusCode = 200;
						response.end(responseData);				
					});					
					break;
				}
				
				case '/node/bot/vk_bot': {
					
					processePOST(request, response, 'BotVK').then(function(responseData)
					{
						response.statusCode = 200;
						response.end(responseData);						
					});
					break;
					
				}
				
				default: {
					response.statusCode = 404;
					response.end();					
				}
			}
			break;
		}
		
		
		default: {
			response.statusCode = 200;
			response.end();
			break;
		}
	}

}catch{console.error(error);}	
     
}).listen(3000, "127.0.0.1",function(){
    console.log("Start 3000");	
});