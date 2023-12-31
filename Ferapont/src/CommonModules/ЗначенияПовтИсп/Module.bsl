#Область СлужебныйПрограммныйИнтерфейс

Функция КэшируемоеСоединение(Знач Линк) Экспорт
	Возврат Новый HTTPСоединение(Линк, 443, , , , 60, Новый ЗащищенноеСоединениеOpenSSL);
КонецФункции

Функция КэшируемаяКлавиатура(Знач МассивКнопок, Знач ПодСообщением) Экспорт
	
	Строки = Новый Массив;
        
    Для Каждого Кнопка Из МассивКнопок Цикл
        
        Кнопки = Новый Массив;
        Кнопка = КодироватьСтроку(МетодыРаботыHttp.ЧислоВСтроку(Кнопка), СпособКодированияСтроки.КодировкаURL);
        Кнопки.Добавить(Новый Структура("text,callback_data", Кнопка, Кнопка));
        Строки.Добавить(Кнопки);

    КонецЦикла;
    
    Если ПодСообщением Тогда
        СтруктураПараметра = Новый Структура("inline_keyboard,rows", Строки, 1);
    Иначе
        СтруктураПараметра = Новый Структура("keyboard,resize_keyboard", Строки, Истина);
    КонецЕсли;
        
    ЗаписьJSON    = Новый ЗаписьJSON;
    ПЗJSON        = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, , , ЭкранированиеСимволовJSON.СимволыВнеASCII);
    ЗаписьJSON.УстановитьСтроку(ПЗJSON);
        
    ЗаписатьJSON(ЗаписьJSON, СтруктураПараметра);
    
    Возврат ЗаписьJSON.Закрыть();
    
КонецФункции

Функция КэшируемаяКлавиатураПереходов() Экспорт
	
	Строки = Новый Массив;
	Кнопки = Новый Массив;

	Кнопки.Добавить(Новый Структура("text,callback_data", "<-", "<-"));
	Кнопки.Добавить(Новый Структура("text,callback_data", "->", "->"));

	Строки.Добавить(Кнопки);

	ЗаписьJSON    = Новый ЗаписьJSON;
	ПЗJSON        = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, , , ЭкранированиеСимволовJSON.СимволыВнеASCII);
	ЗаписьJSON.УстановитьСтроку(ПЗJSON);

	ЗаписатьJSON(ЗаписьJSON, Новый Структура("keyboard,resize_keyboard", Строки, Истина));

	Клавиатура = ЗаписьJSON.Закрыть();
	
	Возврат Клавиатура;
	
КонецФункции

Функция КэшируемыеПараметрыСообществаВК(Знач Параметры = "", Знач Сообщество = "") Экспорт
	
	Если Не ЗначениеЗаполнено(Сообщество) Тогда
        Сообщество = ПредопределенноеЗначение("Справочник.Сообщества.Athenaeum");    
    КонецЕсли;
    
    _Параметры = Новый Структура;
    
    РеквизитыСообщества = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Сообщество,
        "ВК_V,ВК_owner_id,ВК_group_id,ВК_access_token,ВК_client_id"); 
    
    owner = ?(СтрНачинаетсяС(РеквизитыСообщества.ВК_owner_id, "-")
        , РеквизитыСообщества.ВК_owner_id
        , "-" + РеквизитыСообщества.ВК_owner_id);
    
    _Параметры.Вставить("access_token"  , РеквизитыСообщества.ВК_access_token);
    _Параметры.Вставить("from_group"    , "1");
    _Параметры.Вставить("owner_id"      , owner);
    _Параметры.Вставить("v"             , РеквизитыСообщества.ВК_V);
    _Параметры.Вставить("app_id"        , РеквизитыСообщества.ВК_client_id);
    _Параметры.Вставить("group_id"      , РеквизитыСообщества.ВК_group_id);
    
    Если ТипЗнч(Параметры) = Тип("Структура") Тогда
        Для Каждого ПереданныйПараметр Из Параметры Цикл
            _Параметры.Вставить(ПереданныйПараметр.Ключ, МетодыРаботыHttp.ЧислоВСтроку(ПереданныйПараметр.Значение));
        КонецЦикла;
    КонецЕсли;

    Возврат _Параметры;
    
КонецФункции

Функция КэшируемыеПараметрыСообществаТелеграм(Знач Сообщество) Экспорт
	
	Возврат ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Сообщество, "ТГ_token,ТГ_chat_id,ТГ_КаналАрхив");
		
КонецФункции

Функция КэшируемыйТокенБотаТелеграм(Знач Сообщество) Экспорт
	
	Возврат ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Сообщество, "TGB_token");
	
КонецФункции

Функция КэшируемаяКнига(Знач КодКниги) Экспорт
	
	Возврат Справочники.Произведения.НайтиПоКоду(КодКниги);
	
КонецФункции

Функция КэшируемыеЗначенияКонстант(Знач Константа) Экспорт
	Возврат Константы[Константа].Получить();
КонецФункции

#КонецОбласти
