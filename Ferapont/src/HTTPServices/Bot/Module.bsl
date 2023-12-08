#Область ОбработчикиСобытий

Функция tgbotlogIn(Запрос)    
    
    Возврат МетодыApiСайта.tgbotlogIn(Запрос);
    
КонецФункции

Функция vklogintakeData(Запрос)
        
    Возврат МетодыApiСайта.vklogintakeData(Запрос);
    
КонецФункции

Функция vkbottakeData(Запрос)
    
    Возврат МетодыApiСайта.vkbottakeData(Запрос);
    
КонецФункции

Функция takeStartsendData(Запрос)
    
    Возврат МетодыApiСайта.takeStartsendData(Запрос);
    
КонецФункции

Функция vkbotcallBack(Запрос)    
    Ответ = Новый HTTPСервисОтвет(200);
    Возврат Ответ;    
КонецФункции

Функция tgbotgetLog(Запрос)
    Ответ = Новый HTTPСервисОтвет(200);
    Возврат Ответ;
КонецФункции

Функция takeStartcallBack(Запрос)
    Ответ = Новый HTTPСервисОтвет(200);
    Возврат Ответ;
КонецФункции

Функция tgbotcallBack(Запрос)
    Ответ = Новый HTTPСервисОтвет(200);
    Возврат Ответ;
КонецФункции

Функция vklogincallBack(Запрос)
    Ответ = Новый HTTPСервисОтвет(200);
    Возврат Ответ;
КонецФункции

Функция vkbotcors(Запрос)
    Ответ = Новый HTTPСервисОтвет(200);
    Возврат Ответ;
КонецФункции

Функция miniAppwriteNewSession(Запрос)
	
	Попытка
		
		Ответ 				= Новый HTTPСервисОтвет(200);	
		Печенька     		= Запрос.ПараметрыЗапроса.Получить("cookie");		
		ДанныеПользователя 	= МетодыApiСайта.ОбработатьДанныеTMA(Запрос.ПараметрыЗапроса);
		
		Если ДанныеПользователя["passed"] Тогда
			
			ИнформацияПользователя = ДанныеПользователя["user"];
			ИнформацияПользователя = МетодыРаботыHttp.JsonВСтруктуру(
			ПолучитьДвоичныеДанныеИзСтроки(ИнформацияПользователя));
			
			ID 			    = МетодыРаботыHttp.ЧислоВСтроку(ИнформацияПользователя["id"]);	
			ПользовательИБ 	= Справочники.Пользователи.НайтиПоРеквизиту("Telegram", ID);
			
			Если Не ЗначениеЗаполнено(ПользовательИБ) И ЗначениеЗаполнено(ID) Тогда
				
				ИмяПользователя = ИнформацияПользователя["first_name"] 
				+ " " 
				+ ИнформацияПользователя["last_name"];
				
				НовыйПользователь                         = Справочники.Пользователи.СоздатьЭлемент();
				НовыйПользователь.ПерсональныеНастройки   = Справочники.ПерсональныеНастройки.Инициализировать(ИмяПользователя);
				НовыйПользователь.Telegram                = ID;
				НовыйПользователь.Наименование            = ИмяПользователя;
				НовыйПользователь.ДатаРегистрации         = ТекущаяДатаСеанса();
				НовыйПользователь.Никнейм                 = ИнформацияПользователя["username"];
				НовыйПользователь.Записать();
				
				ПользовательИБ = НовыйПользователь.Ссылка;
				
			КонецЕсли;
			
			Если ЗначениеЗаполнено(ПользовательИБ) Тогда
				
				МЗ = РегистрыСведений.АктивныеСеансы.СоздатьМенеджерЗаписи();
				МЗ.Cookie       = Печенька;
				МЗ.Пользователь = ПользовательИБ;
				МЗ.Дата         = ТекущаяДатаСеанса();
				МЗ.Записать(Истина);
				
			КонецЕсли;
				
		КонецЕсли;
			
	Исключение
		
		ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
		
	КонецПопытки;
	
	Возврат Ответ;
	
КонецФункции

Функция miniAppCORSCallback(Запрос)
	Ответ = Новый HTTPСервисОтвет(200);
	Возврат Ответ;
КонецФункции

#КонецОбласти