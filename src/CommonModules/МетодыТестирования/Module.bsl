#Область СлужебныйПрограммныйИнтерфейс

Процедура ЗаписатьТест(Запрос, Метод) Экспорт
	
	Попытка
		
		Если Не Константы.ЗаписыватьТесты.Получить() Тогда
			Возврат;
		КонецЕсли;
		
		UID = Строка(Новый УникальныйИдентификатор);
		
		НовыйТест = Справочники.АвтотестыСервисов.СоздатьЭлемент();
		НовыйТест.Код					= UID;
		НовыйТест.Наименование 			= "Тест " + UID;
		НовыйТест.ВходнойJSON			= Запрос.ПолучитьТелоКакСтроку();
		НовыйТест.ХранилищеЗаголовков 	= Новый ХранилищеЗначения(Запрос.Заголовки);
		НовыйТест.ХранилищеПараметров 	= Новый ХранилищеЗначения(Запрос.ПараметрыЗапроса);
		НовыйТест.Метод 				= Метод;
		НовыйТест.URL					= Запрос.БазовыйURL + Запрос.ОтносительныйURL;
		НовыйТест.Записать();
		
	Исключение
		ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры

Процедура ЗапускТеста(Тест, UIDГруппы = "") Экспорт
	
	РеквизитыТеста 	= ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Тест, "ВходнойJSON,Метод,URL,Определитель");
	JSONЗапроса		= РеквизитыТеста.ВходнойJSON;
	URL				= РеквизитыТеста.URL;
	UID				= Строка(Новый УникальныйИдентификатор);
	Определитель	= РеквизитыТеста.Определитель;
	ДопПараметры	= Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	АвтотестыСервисовЗаменяемыеПараметры.Параметр КАК Параметр,
		|	АвтотестыСервисовЗаменяемыеПараметры.Значение КАК Значение
		|ИЗ
		|	Справочник.АвтотестыСервисов.ЗаменяемыеПараметры КАК АвтотестыСервисовЗаменяемыеПараметры
		|ГДЕ
		|	АвтотестыСервисовЗаменяемыеПараметры.Ссылка = &Тест";
	
	Запрос.УстановитьПараметр("Тест", Тест);
	
	РезультатЗапроса 		= Запрос.Выполнить();	
	ВыборкаДетальныеЗаписи 	= РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		JSONЗапроса = СтрЗаменить(JSONЗапроса, "@" + ВыборкаДетальныеЗаписи.Параметр, ВыборкаДетальныеЗаписи.Значение);  
	КонецЦикла;
	
	ВыполнитьПредобработку(Определитель, JSONЗапроса,  ДопПараметры);
	
	Заголовки 			= Тест.ХранилищеЗаголовков.Получить();	
	ПараметрыЗапроса 	= Тест.ХранилищеПараметров.Получить();	
	
	Ответ = МетодыРаботыHttp.ЗапросПоПараметрамСервиса(Заголовки, ПараметрыЗапроса, URL, JSONЗапроса); 
	
	МЗ = РегистрыСведений.ВыполнениеТестов.СоздатьМенеджерЗаписи();
	МЗ.Период		= ТекущаяДатаСеанса();
	МЗ.UID 			= UID;
	МЗ.UIDГруппы 	= UIDГруппы;
	МЗ.Тест			= Тест;
	МЗ.Пройден		= ВыполнитьПостОбработку(Определитель, Ответ, ДопПараметры);
	МЗ.Записать(Истина);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОсновныеМетоды

Процедура ВыполнитьПредобработку(Знач Определитель, ТелоЗапроса, ДопПараметры)
	
	ОТ = Справочники.ОпределителиТестов;
	
	Если Определитель = ОТ.РегистрацияТелеграм  Тогда		
		РегистрацияТелеграм_Пред(ТелоЗапроса, ДопПараметры);		
	Иначе
		Возврат;
	КонецЕсли;
		
КонецПроцедуры

Функция ВыполнитьПостобработку(Знач Определитель, Ответ, ДопПараметры)
	
	ОТ 		= Справочники.ОпределителиТестов;
	Пройден = Ложь;
	
	Если Определитель = ОТ.РегистрацияТелеграм  Тогда
		Пройден = РегистрацияТелеграм_Пост(Ответ, ДопПараметры);		
	Иначе
		Пройден = Истина;
	КонецЕсли;
	
	Возврат Пройден;
	
КонецФункции

#КонецОбласти

#Область МетодыОбработки

Процедура РегистрацияТелеграм_Пред(ТелоЗапроса, ДопПараметры)
	
	Актор = Справочники.Пользователи.ЭтотПользователь;
	
	ПользовательТестирования = Актор.ПолучитьОбъект();
	
	ДопПараметры.Вставить("Telegram", ПользовательТестирования.Telegram);
	
	ПользовательТестирования.Telegram = "";
	ПользовательТестирования.Записать();
	
КонецПроцедуры

Функция РегистрацияТелеграм_Пост(Ответ, ДопПараметры)
	
	Пройден = Ложь; 
	
	Телеграм				= ДопПараметры.Получить("Telegram");
	
	Если Не ЗначениеЗаполнено(Телеграм) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ПользовательПоТелеграм 	= Справочники.Пользователи.НайтиПоРеквизиту("Telegram", Телеграм);  
	
	Если ЗначениеЗаполнено(ПользовательПоТелеграм) Тогда
		ПользовательПоТелеграм.ПолучитьОбъект().Удалить();
		
		ПользовательТестирования = Справочники.Пользователи.ЭтотПользователь.ПолучитьОбъект();
		ПользовательТестирования.Telegram = Телеграм;
		ПользовательТестирования.Записать();
		Пройден = Истина;
		
	КонецЕсли;
	
	Возврат Пройден;

КонецФункции

#КонецОбласти

#КонецОбласти