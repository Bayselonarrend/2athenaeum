#Область СлужебныйПрограммныйИнтерфейс

Функция wall_post(Параметры) Экспорт
	
	Линк = "https://api.vk.com/method/wall.post";
	
	Параметры.Вставить("friends_only"	, "0");
	Параметры.Вставить("owner_id"		, "-" + Параметры["owner_id"]);
	Параметры.Вставить("from_group"		, "1");
	Параметры.Вставить("signed"			, "0");
	Параметры.Вставить("topic_id"		, "1");
	
	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;
	
КонецФункции

Функция autorize(Параметры) Экспорт
		
	Возврат  
		"https://oauth.vk.com/authorize?client_id=" 
		+ Параметры["client_id"] 
		+ "&scope=offline,wall,groups,photos,stats,ads&v=5.60&response_type=token&redirect_uri=https://api.vk.com/blank.html";
		
		
КонецФункции
 
Функция getAccess_token(Параметры) Экспорт
	
	Возврат 
		"https://oauth.vk.com/access_token?client_id=" 
		+ Параметры["client_id"] 
		+ "&client_secret=" 
		+ Параметры["client_secret"] + "&redirect_uri=https://api.vk.com/blank.html&code=" 
		+ Параметры["response_code"];
		
КонецФункции
	
Функция photos_getWallUploadServer(Параметры) Экспорт
	
	Линк = "https://api.vk.com/method/photos.getWallUploadServer";
	
	Параметры.Вставить("group_id", Параметры["owner_id"]);
	
	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;
	
КонецФункции
 
Функция photos_saveWallPhoto(Параметры) Экспорт
	
	Линк = "https://api.vk.com/method/photos.saveWallPhoto";
	
	Параметры.Вставить("group_id"	, Параметры["owner_id"]);
	Параметры.Вставить("gid"		, Параметры["owner_id"]);

	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;
	
КонецФункции

Функция photos_getUploadServer(Параметры) Экспорт
	
	Линк = "https://api.vk.com/method/photos.getUploadServer";
	
	Параметры.Вставить("group_id"	, Параметры["owner_id"]);
	Параметры.Вставить("gid"		, Параметры["owner_id"]);
	
	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;
	
КонецФункции

Функция photos_save(Параметры) Экспорт
	
	Линк = "https://api.vk.com/method/photos.save";
	
	Параметры.Вставить("group_id"	, Параметры["owner_id"]);
	Параметры.Вставить("gid"		, Параметры["owner_id"]);

	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;

КонецФункции

Функция stats_get(Параметры) Экспорт
	
	Линк = "https://api.vk.com/method/stats.get";
	
	Параметры.Вставить("group_id", Параметры["owner_id"]);

	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;

КонецФункции

Функция users_get(Параметры) Экспорт
	
	Линк = "https://api.vk.com/method/users.get";
	
	ПараметрыОтвета = КоннекторHTTP.GetJson(getUserToken(Параметры), Параметры);
	Параметры.Вставить("access_token", ПараметрыОтвета["access_token"]);
	
	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);	
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;
	
КонецФункции

Функция getUserToken(Параметры) Экспорт
	
	Параметры.Вставить("client_id"			, "51654824");
	Параметры.Вставить("client_secret"		, "g9E89rlrU2Qzw6fj7b24");                                     
	
	Возврат 
		"https://oauth.vk.com/access_token?client_id=" 
		+ Параметры["client_id"] 
		+ "&client_secret=" 
		+ Параметры["client_secret"] 
		+ "&redirect_uri="
		+ Параметры["redirect_url"]
		+"&code=" 
		+ Параметры["response_code"];

	
КонецФункции

Функция message_send(Параметры) Экспорт	
	
	Линк = "https://api.vk.com/method/messages.send"; 
	
	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;

КонецФункции

Функция stories_getPhotoUploadServer(Параметры) Экспорт
	
	Линк = "https://api.vk.com/method/stories.getPhotoUploadServer";
	
	Параметры.Вставить("add_to_news", "1");
	Параметры.Вставить("group_id"	, Параметры["owner_id"]);
	
	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;

КонецФункции

Функция stories_save(Параметры) Экспорт
	
	Линк = "https://api.vk.com/method/stories.save";
	
	Ответ = КоннекторHTTP.GetJson(Линк, Параметры);
	
	ИнструментарийВызовСервера.ЗаписьВОтветыАпи(Ответ, Перечисления.СоцСети.VK, Линк);
	
	Возврат Ответ;
	
КонецФункции

Функция utils_getShortLink(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/utils.getShortLink", Параметры);
	
КонецФункции

Функция wall_delete(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/wall.delete", Параметры);
	
КонецФункции

Функция wall_repost(Параметры, Прокси = "") Экспорт
	
	Параметры.Вставить("mark_as_ads", 0);
	
	Если Прокси <> "" Тогда
		Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/wall.repost", Параметры, Новый Структура("Прокси", Прокси));	
	Иначе
		Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/wall.repost", Параметры);
	КонецЕсли;

КонецФункции

Функция wall_get(Параметры, Прокси = "") Экспорт
	Если Прокси <> "" Тогда
		Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/wall.get", Параметры, Новый Структура("Прокси", Прокси));	
	Иначе
		Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/wall.get", Параметры);	
	КонецЕсли;
КонецФункции

Функция likes_add(Параметры, Прокси = "") Экспорт
	
	Параметры.Вставить("type", "post");
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/likes.add", Параметры);
	
КонецФункции

Функция ads_createCampaigns(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/ads.createCampaigns", Параметры);
	
КонецФункции

Функция ads_createAds(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/ads.createAds", Параметры);
	
КонецФункции

Функция ads_getSuggestions(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/ads.getSuggestions", Параметры);
	
КонецФункции

Функция ads_getAds(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/ads.getAds", Параметры);
	
КонецФункции

Функция ads_updateAds(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/ads.updateAds", Параметры);
	
КонецФункции

Функция polls_create(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/polls.create", Параметры);
	
КонецФункции

Функция polls_getPhotoUploadServer(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/polls.getPhotoUploadServer", Параметры);
	
КонецФункции

Функция polls_savePhoto(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/polls.savePhoto", Параметры);
	
КонецФункции

Функция photos_createAlbum(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/photos.createAlbum", Параметры);
	
КонецФункции

Функция stats_getPostReach(Параметры) Экспорт
	
	Возврат КоннекторHTTP.GetJson("https://api.vk.com/method/stats.getPostReach", Параметры);
	
КонецФункции

#КонецОбласти