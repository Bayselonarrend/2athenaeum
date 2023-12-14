Функция BotTelegram(Знач Запрос) Экспорт
	
	МассивПараметровФона = Новый Массив;
	МассивПараметровФона.Добавить(Запрос);
	
	ИнструментарийВызовСервера.ВыполнитьФоном("МетодыApiСайта.POST_ТелеграмБот", МассивПараметровФона);

	Возврат "Alright!";
	
КонецФункции

Функция BotVK(Знач Запрос) Экспорт
	
	МассивПараметровФона = Новый Массив;
	МассивПараметровФона.Добавить(Запрос);
	
	ИнструментарийВызовСервера.ВыполнитьФоном("МетодыApiСайта.POST_ВКБот", МассивПараметровФона);

	Возврат "ok";
	
КонецФункции

Функция TakeStart(Знач Данные) Экспорт
	
	Данные = РаскодироватьСтроку(Данные, СпособКодированияСтроки.КодировкаURL);
	
	МассивПараметровФона = Новый Массив;
	МассивПараметровФона.Добавить(Данные);
	
	ИнструментарийВызовСервера.ВыполнитьФоном("МетодыApiСайта.GET_ОбработатьНачало", МассивПараметровФона);

	Возврат "Alright!";
	
КонецФункции

Функция VKLogin(Знач Данные) Экспорт
	
	Данные = РаскодироватьСтроку(Данные, СпособКодированияСтроки.КодировкаURL);
	Ответ  =  МетодыApiСайта.GET_ВКЛогин(Данные);
	Возврат Ответ;
	
КонецФункции

Функция UserData(Знач Данные) Экспорт
	
	Данные = РаскодироватьСтроку(Данные, СпособКодированияСтроки.КодировкаURL);
	Ответ  =  МетодыApiСайта.GET_ДанныеПользователя(Данные);
	Возврат Ответ;

КонецФункции

Функция MiniApp(Знач Данные) Экспорт
	
	Данные = РаскодироватьСтроку(Данные, СпособКодированияСтроки.КодировкаURL);
	МассивПараметровФона = Новый Массив;
	МассивПараметровФона.Добавить(Данные);
	
	ИнструментарийВызовСервера.ВыполнитьФоном("МетодыApiСайта.GET_MiniApp", МассивПараметровФона);

	Возврат "Alright!";

КонецФункции

Функция CookieCheck(Знач Данные) Экспорт
	
	Данные = РаскодироватьСтроку(Данные, СпособКодированияСтроки.КодировкаURL);
	Ответ  =  МетодыApiСайта.GET_ПроверитьПеченье(Данные);
	Возврат Ответ;

КонецФункции

Функция BookList(Знач Данные) Экспорт
	
	Данные = РаскодироватьСтроку(Данные, СпособКодированияСтроки.КодировкаURL);
    Ответ  =  МетодыApiСайта.GET_СписокЧтения(Данные);
	Возврат Ответ;

КонецФункции

Функция UserProgress(Знач Данные) Экспорт
	
	Данные = РаскодироватьСтроку(Данные, СпособКодированияСтроки.КодировкаURL);
	Ответ  = МетодыApiСайта.GET_ПрогрессПользователя(Данные);
	Возврат Ответ;
	
КонецФункции