#Область ПрограммныйИнтерфейс

// Сформировать пост.
// 
// Параметры:
//  Пост - ДокументСсылка.Пост, СправочникСсылка.Сложнопост, Структура - Пост
//  ЭтоРеклама - Булево -  Это реклама
//  Сеть - ПеречислениеСсылка.СоцСети -  Сеть
//	Отправить - Булево - Отправить сформированный пост или вернуть его структуру
// 
// Возвращаемое значение:
//  Число,Структура из Строка,ДвоичныеДанные -  Если отправить = Истина - номер поста ВК, иначе структура данных поста
Функция СформироватьПост(Знач Пост, Знач ЭтоРеклама = Ложь, Знач Сеть = "", Знач Отправить = Истина) Экспорт
    
    Попытка 
        
        Если Не ЗначениеЗаполнено(Сеть) Тогда
            Сеть = Перечисления.СоцСети.VKT;
        КонецЕсли;
        
        Параметры        = Новый Структура;
        МассивКартинок   = Новый Массив;
        ВложениеКонст    = "Вложение";
		Вложение		 = "";
        Линк             = "";
            
        Если ТипЗнч(Пост) = Тип("ДокументСсылка.Пост") Тогда
            
            //@skip-check reading-attribute-from-database
            ДД                    = Пост.КартинкаДвоичные.Получить();
            РеквизитыПоста        = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Пост
                , "Содержание,Сообщество,ВидКартинки");
            
            Сообщество            = РеквизитыПоста.Сообщество;
            ТекстПоста            = СформироватьТекстПоста(РеквизитыПоста.Содержание);
            МассивКартинок        = СформироватьКартинкиОбычногоПоста(РеквизитыПоста.ВидКартинки
                , ДД
                , РеквизитыПоста.Содержание
                , РеквизитыПоста.Сообщество);
			Вложение			  = СформироватьВложение(РеквизитыПоста.Содержание);
                
        ИначеЕсли ТипЗнч(Пост) = Тип("СправочникСсылка.Сложнопост") Тогда
            
            РеквизитыПоста     = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Пост
                , "Текст,Сообщество");
            
            Сообщество            = РеквизитыПоста.Сообщество;
            ТекстПоста            = РеквизитыПоста.Текст;
            ТекстПоста            = ?(ТекстПоста = "", " ", ТекстПоста);
            МассивКартинок        = СформироватьКартинкиСложногоПоста(Пост);
            
        ИначеЕсли ТипЗнч(Пост) = Тип("Структура") Тогда
            
            Сообщество = Пост.Сообщество;
            ТекстПоста = Пост.Текст;
            МассивКартинок.Добавить(Пост.Картинка);    
            
            Если Пост.Свойство("Линк") Тогда
                //@skip-check wrong-string-literal-content
                Линк = Пост["Линк"];
			КонецЕсли;
			
			Если Пост.Свойство(ВложениеКонст) Тогда
				//@skip-check wrong-string-literal-content
				Вложение = Пост[ВложениеКонст];
			КонецЕсли;
			
        Иначе
            
            Возврат 0;
            
        КонецЕсли;
            
        Параметры.Вставить("message", ТекстПоста);    
        
        СтруктураПараметров = Новый Структура;
        СтруктураПараметров.Вставить("Сеть"				, Сеть);
        СтруктураПараметров.Вставить("Сообщество"		, Сообщество);
        СтруктураПараметров.Вставить("ТекстПоста"		, ТекстПоста);
        СтруктураПараметров.Вставить("МассивКартинок"	, МассивКартинок);
        СтруктураПараметров.Вставить("ЭтоРеклама"		, ЭтоРеклама);
        СтруктураПараметров.Вставить("Линк"				, Линк);             
        СтруктураПараметров.Вставить("Пост"				, Пост);
		СтруктураПараметров.Вставить(ВложениеКонст		, Вложение);
		
		Если Отправить Тогда
        	НомерПостаВК = ОтправитьСформированныйПост(СтруктураПараметров);
        	Возврат НомерПостаВК;
		Иначе
			Возврат СтруктураПараметров;
		КонецЕсли;
        
    Исключение    
        ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
        Возврат 0;
    КонецПопытки;
    
КонецФункции

// Промт для Midjourney
// 
// Параметры:
//  Пост - ДокументСсылка.Пост - Пост
// 
// Возвращаемое значение:
//  Строка -  Новый промт
Функция НовыйПромт(Знач Пост) Экспорт
    
    Текст  = "";
    
    Запрос = Новый Запрос;
    Запрос.Текст =
    	"ВЫБРАТЬ
    	|	ПостТэги.Тэг.Английский КАК Тэг
    	|ИЗ
    	|	Документ.Пост.Тэги КАК ПостТэги
    	|ГДЕ
    	|	ПостТэги.Ссылка = &Пост";
	
	Запрос.УстановитьПараметр("Пост", Пост);
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
    	Текст = Текст + " " + ВыборкаДетальныеЗаписи.Тэг;
    КонецЦикла;
    
    Возврат "/imagine prompt:black and white neoclassical style contour drawing abstract surrealistic "
    + СокрЛП(Текст)
    + " metaphor realistic";
    
КонецФункции

// Сформировать текст поста.
// 
// Параметры:
//  Произведение - Произвольный -  значение реквизита Содержание документа Пост
// 
// Возвращаемое значение:
//  Строка -  Сформировать текст поста
Функция СформироватьТекстПоста(Знач Произведение) Экспорт
    
    Если Не ЗначениеЗаполнено(Произведение) Тогда
        Возврат "";    
	КонецЕсли;
	
	ПСтр    	= Символы.ПС + Символы.ПС;
	ТекстПоста 	= "";
        
    Если ТипЗнч(Произведение) = Тип("СправочникСсылка.Цитаты") Тогда
        
        ПроизведениеАвтор = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "ПроизведениеАвтор");
            
        ТекстПоста = ?(ТипЗнч(ПроизведениеАвтор) = Тип("СправочникСсылка.Люди")
            , СформироватьЦитату(Произведение)
            , СформироватьОтрывок(Произведение));
			
		ТекстПоста = ТекстПоста + ПСтр + "#Философия #Литература #Цитата";
        
    ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.Произведения") Тогда
        
        ТекстПоста = СформироватьТекст(Произведение);	
		ТекстПоста = ТекстПоста + ПСтр + "#Философия #Литература #Поэзия";
        
    ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.Колонки") Тогда
        
        ТекстПоста = СформироватьКолонку(Произведение);	
		ТекстПоста = ТекстПоста + ПСтр + "#Философия #Литература #Понятие";
        
    ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.События") Тогда
        
        ТекстПоста = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Описание");
		ТекстПоста = ТекстПоста + ПСтр + "#Философия #Литература #История";
		
	ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.Аудиозаписи") Тогда
		
		ТекстПоста = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Описание")
			+ Символы.ПС
			+ Символы.ПС
			+ "Другие лекции вы можете найти в аудиозаписях сообщества в ВК или по хэштегу #Лекция в Телеграм-канале."
			+ Символы.ПС
			+ "Приятного прослушивания!";
		
		ТекстПоста			= ТекстПоста + ПСтр + "#Философия #Литература #Лекция ";
		ИсточникАудиозаписи = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение
			, "Источник");
		Хэштег				= ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ИсточникАудиозаписи
			, "Хэштэг");
			
		ТекстПоста 			= ТекстПоста + Хэштег;	
		
	ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.Биографии") Тогда
		
		РеквизитыБиографии = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Произведение, "Наименование,Биография");
		ТекстПоста = РеквизитыБиографии.Наименование
			+ Символы.ПС
			+ Символы.ПС
			+ РеквизитыБиографии.Биография
			+ Символы.ПС
			+ Символы.ПС
			+ "#Мыслители #Идеи #Философия";
			
    Иначе
        
        ТекстПоста = " ";
        
	КонецЕсли;
	
	Возврат ТекстПоста;
    
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОтправитьСформированныйПост(Знач СтруктураПараметров)
    
    Сеть             = СтруктураПараметров["Сеть"];
    Сообщество       = СтруктураПараметров["Сообщество"];
    ТекстПоста       = СтруктураПараметров["ТекстПоста"];
    МассивКартинок   = СтруктураПараметров["МассивКартинок"];
    ЭтоРеклама       = СтруктураПараметров["ЭтоРеклама"];
    Линк             = СтруктураПараметров["Линк"];
    Пост             = СтруктураПараметров["Пост"];
	
	ДопПараметры	 = СтруктураДополнительныхПараметров(СтруктураПараметров);
    
    Если Сеть = Перечисления.СоцСети.VK Или Сеть = Перечисления.СоцСети.VKT Тогда
        
        Ответ = МетодыРаботыVK.СоздатьПост(Сообщество
			, ТекстПоста
			, МассивКартинок
			, ЭтоРеклама
			, Линк
			, ДопПараметры);
			
        НомерПостаВК = Ответ["response"]["post_id"];
        МетодыРаботыVK.ПоставитьЛайк(Сообщество, НомерПостаВК);
        
    КонецЕсли;

    Если Сеть = Перечисления.СоцСети.Telegram Или Сеть = Перечисления.СоцСети.VKT Тогда

        Если МассивКартинок.Количество() = 1 Тогда
            Ответ        = МетодыРаботыTelegram.ОтправитьКартинку(Сообщество, ТекстПоста, МассивКартинок[0]);
            НомерПостаТГ = Ответ["result"]["message_id"];

        Иначе
            Ответ        = МетодыРаботыTelegram.ОтправитьГруппуКартинок(Сообщество, ТекстПоста, МассивКартинок);
            НомерПостаТГ = Ответ["result"][0]["message_id"];
			
		КонецЕсли;
		
		ОтправитьДругиеВложения(ДопПараметры, Сообщество);

    КонецЕсли;

    Если ТипЗнч(Пост) = Тип("ДокументСсылка.Пост") Тогда
        ОбъектПост = Пост.ПолучитьОбъект();
        ОбъектПост.ВК_НомерПоста = ?(ЗначениеЗаполнено(НомерПостаВК), Число(НомерПостаВК), ОбъектПост.ВК_НомерПоста);
        ОбъектПост.ТГ_НомерПоста = ?(ЗначениеЗаполнено(НомерПостаТГ), Число(НомерПостаТГ), ОбъектПост.ТГ_НомерПоста);
        ОбъектПост.Записать();
    КонецЕсли;

    Возврат НомерПостаВК;

КонецФункции

Функция СформироватьКартинкиОбычногоПоста(Знач ВидКартинки, Знач ДД, Знач Содержание, Знач Сообщество)
    
    МассивКартинок = Новый Массив;
    
    Если ВидКартинки = Перечисления.ВидыКартинок.Галерея Тогда
        
        МассивКартинок = МетодыОбработкиИзображений.СформироватьГалерею(ДД);    
        
    ИначеЕсли ВидКартинки = Перечисления.ВидыКартинок.Термин Тогда    
        
        МассивКартинок.Добавить(МетодыОбработкиИзображений.СформироватьТермин(Содержание));
        
    ИначеЕсли ВидКартинки = Перечисления.ВидыКартинок.Событие Тогда
        
        МассивКартинок.Добавить(МетодыОбработкиИзображений.СформироватьСобытие(Содержание, Сообщество));
		
	ИначеЕсли ВидКартинки = Перечисления.ВидыКартинок.Лекция Тогда
		
		МассивКартинок.Добавить(МетодыОбработкиИзображений.СформироватьЛекцию(Содержание));
		
	ИначеЕсли ВидКартинки = Перечисления.ВидыКартинок.Биография Тогда
		
		МассивКартинок.Добавить(МетодыОбработкиИзображений.СформироватьБиографию(Содержание));
		
    Иначе
        
        МассивКартинок.Добавить(ДД);
        
    КонецЕсли;
    
    Возврат МассивКартинок;
    
КонецФункции

Функция СформироватьКартинкиСложногоПоста(Знач Пост) 
    
    МассивКартинок     = Новый Массив;
    Ресурсы            = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Пост, "Ресурсы").Выгрузить();
    
    Для Каждого Ресурс Из Ресурсы Цикл
        
        ИВФ = ПолучитьИмяВременногоФайла("png");
        
        СтруктураМедиа = Новый Структура;
        СтруктураМедиа.Вставить("МедиаДД",     Ресурс.МедиаДД.Получить());
        СтруктураМедиа.Вставить("Медиа",    Ресурс.Медиа);
        СтруктураМедиа.Вставить("ТекстА",    Ресурс.ТекстА);
        СтруктураМедиа.Вставить("ТекстБ",    Ресурс.ТекстБ);
        СтруктураМедиа.Вставить("ТекстВ",    Ресурс.ТекстВ);
        
        Медиа = МетодыОбработкиИзображений.ОбработатьКартинкуПоШаблону(Ресурс.ВидОбработки, СтруктураМедиа);
        МассивКартинок.Добавить(Медиа);
        
        УдалитьФайлы(ИВФ);
        
    КонецЦикла;
    
    Возврат МассивКартинок;
    
КонецФункции

Функция СформироватьОтрывок(Знач Произведение, Знач ТолькоШапка = Ложь) 
    
    Текст         = "";
    Библиотека    = "";
    
    Если Не ЗначениеЗаполнено(Произведение) Тогда
        Возврат "";
    КонецЕсли;
    
    ПроизведениеАвтор     = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение
        , "ПроизведениеАвтор");
        
    ПроизведениеАвтор    = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(ПроизведениеАвтор
        , "Автор,Код,НаСайте,Наименование,Дата");
        
    Автор = ПроизведениеАвтор.Автор;
    
    Если Не ТолькоШапка Тогда
            
        ПроизведениеТекст = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Текст");
        
        Текст = Текст
        + "«" 
        + СокрЛП(ПроизведениеТекст)
        + "»"
        + Символы.ПС
        + Символы.ПС;
                
    КонецЕсли;
    
    Текст = Текст
    + СокрЛП(Автор.Имя)
    + " "
    + СокрЛП(Автор.Фамилия)
    + ", «"
    + СокрЛП(ПроизведениеАвтор.Наименование)
    + "», "
    + СокрЛП(ПроизведениеАвтор.Дата)
    + Библиотека;
    
    Возврат Текст;
    
КонецФункции

Функция СформироватьЦитату(Знач Произведение, Знач ТолькоШапка = Ложь) 
    
    Текст                 = "";
    ПроизведениеАвтор     = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение
        , "ПроизведениеАвтор");
        
    ПроизведениеАвтор    = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(ПроизведениеАвтор
        , "Имя,Фамилия,КраткоеОписание");
    
    Если Не ТолькоШапка Тогда
        
        Текст = Текст 
        + "«" 
        + ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Текст")
        + "»"
        + Символы.ПС
        + Символы.ПС;
        
    КонецЕсли;
    
    Текст = Текст 
    + СокрЛП(ПроизведениеАвтор.Имя)
    + " "
    + СокрЛП(ПроизведениеАвтор.Фамилия)
    + " "
    + Символ(8212)
    + " "
    + СокрЛП(ПроизведениеАвтор.КраткоеОписание);
    
    Возврат Текст;
    
КонецФункции

Функция СформироватьТекст (Знач Произведение)
    
    Автор           = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Автор");
    Автор           = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Автор, "Имя,Фамилия");
    Произведение    = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Произведение, "Текст,Наименование");
    
    Текст = СокрЛП(Произведение.Текст)
    + Символы.ПС
    + Символы.ПС
    + СокрЛП(Автор.Имя)
    + " "
    + СокрЛП(Автор.Фамилия)
    + " "
    + Символ(8212)
    + " «"
    + СокрЛП(Произведение.Наименование)
    + "»";
    
    Возврат Текст;
    
КонецФункции

Функция СформироватьКолонку (Знач Произведение)
    
    Возврат СокрЛП(ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Текст"));
    
КонецФункции

Функция СтруктураДополнительныхПараметров(Знач СтруктураВходныхПараметров)
	
	СтруктураВозврата = Новый Структура;
	ВложениеКонст     = "Вложение";
	
	Если СтруктураВходныхПараметров.Свойство(ВложениеКонст) Тогда
		
		Вложение = СтруктураВходныхПараметров[ВложениеКонст];
		
		Если ТипЗнч(Вложение) = Тип("СправочникСсылка.Аудиозаписи") Тогда
			
			РеквизитыАудио = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Вложение
				, "ВК_Объект,ТГ_Ссылка");
				
			СтруктураВозврата.Вставить("АудиоВК", РеквизитыАудио.ВК_Объект);
			СтруктураВозврата.Вставить("АудиоТГ", РеквизитыАудио.ТГ_Ссылка); 
					
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат СтруктураВозврата;
	
КонецФункции

Функция СформироватьВложение(Содержание) 
	
	Вложение = "";
	
	Если ТипЗнч(Содержание) = Тип("СправочникСсылка.Аудиозаписи") Тогда
		Вложение = Содержание;
	КонецЕсли;
	
	Возврат Вложение;
	
КонецФункции

Процедура ОтправитьДругиеВложения(Знач Параметры, Знач Сообщество)
	
	Если Параметры.Свойство("АудиоТГ") Тогда
		
		ID = Параметры["АудиоТГ"];
		
		МетодыРаботыTelegram.ПереслатьСообщение(Сообщество, ID);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
