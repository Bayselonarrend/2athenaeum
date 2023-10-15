#Область ПрограммныйИнтерфейс

Функция СформироватьПост(Знач Пост, Знач ЭтоРеклама = Ложь, Знач Сеть = "") Экспорт
	
	Если Не ЗначениеЗаполнено(Сеть) Тогда
		Сеть = Перечисления.СоцСети.VKT;
	КонецЕсли;
	
	Параметры 			= Новый Структура;
	МассивКартинок 		= Новый Массив;
	
		
	Если ТипЗнч(Пост) = Тип("ДокументСсылка.Пост") Тогда
		
		//@skip-check reading-attribute-from-database
		ДД				= Пост.КартинкаДвоичные.Получить();
		РеквизитыПоста 	= ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Пост, "Содержание,Сообщество,ВидКартинки");
		
		Сообщество			= РеквизитыПоста.Сообщество;
		ТекстПоста			= СформироватьТекстПоста(Пост);
		МассивКартинок		= СформироватьКартинкиОбычногоПоста(РеквизитыПоста.ВидКартинки
																	, ДД
																	, РеквизитыПоста.Содержание
																	, РеквизитыПоста.Сообщество);
	ИначеЕсли ТипЗнч(Пост) = Тип("СправочникСсылка.Сложнопост") Тогда

		РеквизитыПоста 	= ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Пост, "Текст,Сообщество");

		Сообщество			= РеквизитыПоста.Сообщество;
		ТекстПоста			= РеквизитыПоста.Текст;
		ТекстПоста			= ?(ТекстПоста = "", " ", ТекстПоста);
		МассивКартинок		= СформироватьКартинкиСложногоПоста(Пост);
		
	ИначеЕсли ТипЗнч(Пост) = Тип("Структура") Тогда
		
		Сообщество = Пост.Сообщество;
		ТекстПоста = Пост.Текст;
		МассивКартинок.Добавить(Пост.Картинка);		

	КонецЕсли;
	
	
	Параметры.Вставить("message", ТекстПоста);	
	
	НомерПостаВК 	= "";
	НомерПостаТГ 	= "";
	
	Если Сеть = Перечисления.СоцСети.VK Или Сеть = Перечисления.СоцСети.VKT Тогда 		
		Ответ 			= МетодыРаботыVK.СоздатьПост(Сообщество, ТекстПоста, МассивКартинок, ЭтоРеклама);	
		НомерПостаВК  	= Ответ["response"]["post_id"];
		МетодыРаботыVK.ПоставитьЛайк(Сообщество, НомерПостаВК);
	КонецЕсли;
	
	
	Если Сеть = Перечисления.СоцСети.Telegram Или Сеть = Перечисления.СоцСети.VKT Тогда
		
		Если МассивКартинок.Количество() = 1 Тогда
			Ответ = МетодыРаботыTelegram.ОтправитьКартинку(Сообщество, ТекстПоста, МассивКартинок[0]);
		Иначе
			Ответ = МетодыРаботыTelegram.ОтправитьГруппуКартинок(Сообщество, ТекстПоста, МассивКартинок);
		КонецЕсли;
		
		НомерПостаТГ = Ответ["result"]["message_id"];
		
	КонецЕсли;
		
	Если ТипЗнч(Пост) = Тип("ДокументСсылка.Пост") Тогда
		ОбъектПост = Пост.ПолучитьОбъект();
		ОбъектПост.ВК_НомерПоста = Число(НомерПостаВК);
		ОбъектПост.ТГ_НомерПоста = Число(НомерПостаТГ);
		ОбъектПост.Записать();
	КонецЕсли;
	
	Возврат НомерПостаВК;

КонецФункции

Функция НовыйПромт(Знач Пост) Экспорт
	
	Тэги			= Пост.Тэги;
	Текст 			= "";
	
	Для Каждого Тэг Из Тэги Цикл
		Текст = Текст + " " + Тэг.Тэг.Английский;
	КонецЦикла;
	
	Возврат "/imagine prompt:black and white neoclassical style contour drawing abstract surrealistic "
	+ СокрЛП(Текст)
	+ " metaphor realistic";

КонецФункции

Функция СформироватьТекстПоста(Знач Пост) Экспорт
	
	Если Не ЗначениеЗаполнено(Пост) Тогда
		Возврат "";	
	КонецЕсли;
		
	Произведение = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Пост, "Содержание");
	
	Если ТипЗнч(Произведение) = Тип("СправочникСсылка.Цитаты") Тогда
		
		ПроизведениеАвтор = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "ПроизведениеАвтор");

		
		Возврат ?(ТипЗнч(ПроизведениеАвтор) = Тип("СправочникСсылка.Люди")
						, СформироватьЦитату(Произведение)
						, СформироватьОтрывок(Произведение));
		
	ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.Произведения") Тогда
		
		Возврат СформироватьТекст(Произведение);
		
	ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.Колонки") Тогда
		
		Возврат СформироватьКолонку(Произведение);
						
	ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.События") Тогда
		
		Возврат ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Описание");
		
	Иначе
		
		Возврат "";
	КонецЕсли;
	
КонецФункции

#КонецОбласти




#Область СлужебныеПроцедурыИФункции

Функция СформироватьКартинкиОбычногоПоста(Знач ВидКартинки, Знач ДД, Знач Содержание, Знач Сообщество)

	МассивКартинок = Новый Массив;
	
	Если ВидКартинки = Перечисления.ВидыКартинок.Одиночная
		Или ВидКартинки = Перечисления.ВидыКартинок.ПустаяСсылка() Тогда
		
		МассивКартинок.Добавить(ДД);
		
	ИначеЕсли ВидКартинки = Перечисления.ВидыКартинок.Галерея Тогда
		
		МассивКартинок 	= МетодыОбработкиИзображений.СформироватьГалерею(ДД);	
		
	ИначеЕсли ВидКартинки = Перечисления.ВидыКартинок.Термин Тогда    
		
		МассивКартинок.Добавить(МетодыОбработкиИзображений.СформироватьТермин(Содержание));
		
	ИначеЕсли ВидКартинки = Перечисления.ВидыКартинок.Событие Тогда
		
		МассивКартинок.Добавить(МетодыОбработкиИзображений.СформироватьСобытие(Содержание, Сообщество));
				
	КонецЕсли;

	Возврат МассивКартинок;
	
КонецФункции

Функция СформироватьКартинкиСложногоПоста(Знач Пост) 
	
	МассивКартинок 	= Новый Массив;
	Ресурсы			= ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Пост, "Ресурсы");
	
	Для Каждого Ресурс Из Ресурсы Цикл
		
		ИВФ = ПолучитьИмяВременногоФайла("png");
		
		СтруктураМедиа = Новый Структура;
		СтруктураМедиа.Вставить("МедиаДД", 	Ресурс.МедиаДД.Получить());
		СтруктураМедиа.Вставить("Медиа",	Ресурс.Медиа);
		СтруктураМедиа.Вставить("ТекстА",	Ресурс.ТекстА);
		СтруктураМедиа.Вставить("ТекстБ",	Ресурс.ТекстБ);
		СтруктураМедиа.Вставить("ТекстВ",	Ресурс.ТекстВ);
		
		Медиа = МетодыОбработкиИзображений.ОбработатьКартинкуПоШаблону(Ресурс.ВидОбработки, СтруктураМедиа, Истина);
		МассивКартинок.Добавить(Медиа);
		
		УдалитьФайлы(ИВФ);
		
	КонецЦикла;
	
	Возврат МассивКартинок;
	
КонецФункции

Функция СформироватьОтрывок(Знач Произведение, Знач ТолькоШапка = Ложь) 
	
	Текст 		= "";
	Библиотека 	= "";
	
	Если Не ЗначениеЗаполнено(Произведение) Тогда
		Возврат "";
	КонецЕсли;
	
	ПроизведениеАвтор 	= ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "ПроизведениеАвтор");
	ПроизведениеАвтор	= ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(ПроизведениеАвтор, "Автор,Код,НаСайте,Наименование,Дата");
	Автор				= ПроизведениеАвтор.Автор;
	
	
	Если Не ТолькоШапка Тогда
		
		
		ПроизведениеТекст = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Текст");
		
		Текст = Текст
		+ "«" 
		+ СокрЛП(ПроизведениеТекст)
		+ "»"
		+ Символы.ПС
		+ Символы.ПС;
		
		Если ПроизведениеАвтор.НаСайте Тогда
			Библиотека = Символы.ПС
			+ Символы.ПС
			+ "Кстати, это произведение есть в нашей электронной библиотеке по коду "
			+ ПроизведениеАвтор.Код 
			+ " или по ссылке "
			+ "https://athenaeum.digital/book?id="
			+ ПроизведениеАвтор.Код
			+ Символы.ПС
			+ Символы.ПС
			+ "Если вы еще не знакомы с нашей библиотекой, то подробнее можно узнать по кнопке «Библиотека» в меню сообщества"; 
		КонецЕсли;
		
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
	
	
	Возврат Текст
	
КонецФункции

Функция СформироватьЦитату(Знач Произведение, Знач ТолькоШапка = Ложь) 
	
	Текст 				= "";
	ПроизведениеАвтор 	= ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "ПроизведениеАвтор");
	ПроизведениеАвтор	= ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(ПроизведениеАвтор, "Имя,Фамилия,КраткоеОписание");
	
	Если Не ТолькоШапка Тогда
		
		Текст = Текст 
		+ "«" 
		+ ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Текст")
		+ "»"
		+ Символы.ПС
		+ Символы.ПС
		
	КонецЕсли;
	
	
	Текст = Текст 
	+ СокрЛП(ПроизведениеАвтор.Имя)
	+ " "
	+ СокрЛП(ПроизведениеАвтор.Фамилия)
	+ " — "
	+ СокрЛП(ПроизведениеАвтор.КраткоеОписание);

	Возврат Текст
	
КонецФункции

Функция СформироватьТекст (Знач Произведение)
	
	Автор 			= ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Автор");
	Автор 			= ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Автор, "Имя,Фамилия");
	Произведение	= ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Произведение, "Текст,Наименование");
	
	Текст = СокрЛП(Произведение.Текст)
	+ Символы.ПС
	+ Символы.ПС
	+ СокрЛП(Автор.Имя)
	+ " "
	+ СокрЛП(Автор.Фамилия)
	+ " — «"
	+ СокрЛП(Произведение.Наименование)
	+ "»";
	
	Возврат Текст

КонецФункции

Функция СформироватьКолонку (Знач Произведение)
	
	Возврат СокрЛП(ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Произведение, "Текст"))

КонецФункции

#КонецОбласти
