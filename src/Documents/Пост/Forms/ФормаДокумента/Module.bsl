#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Объект.ВидКартинки) Тогда
		Объект.ВидКартинки = Перечисления.ВидыКартинок.Одиночная;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Объект.Уровень) Тогда
		Объект.Уровень = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Объект.Сообщество, "СтандартныйУровеньПоста");	
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Пост.Сообщество КАК Сообщество,
		|	Пост.ВидКартинки КАК ВидКартинки,
		|	Пост.Уровень КАК Уровень
		|ИЗ
		|	Документ.Пост КАК Пост
		|
		|УПОРЯДОЧИТЬ ПО
		|	Пост.Дата УБЫВ";
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Если ВыборкаДетальныеЗаписи.Следующий() Тогда
			Объект.Сообщество = ВыборкаДетальныеЗаписи.Сообщество;
			Объект.ВидКартинки = ВыборкаДетальныеЗаписи.ВидКартинки;
			Объект.Уровень = ВыборкаДетальныеЗаписи.Уровень;
		КонецЕсли;
		
		
	КонецЕсли;
	
	Попытка
		Если Не ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.Термины") 
			И Не  ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.События")
			И Не ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.Цитаты") Тогда
			
			КартинкаПоста = ПолучитьНавигационнуюСсылку(Объект.Ссылка, "КартинкаДвоичные");
			ТекстПоста = МетодыФормированияПостов.СформироватьТекстПоста(Объект.Ссылка);
			
		ИначеЕсли ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.Термины") Тогда
			ТекстПоста = Объект.Содержание.Описание;
			КартинкаПоста = ПоместитьВоВременноеХранилище(МетодыОбработкиИзображений.СформироватьТермин(Объект.Содержание), Новый УникальныйИдентификатор);
			
		ИначеЕсли  ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.События") Тогда
			ТекстПоста = МетодыФормированияПостов.СформироватьТекстПоста(Объект.Ссылка);
			КартинкаПоста = ПоместитьВоВременноеХранилище(МетодыОбработкиИзображений.СформироватьСобытие(Объект.Содержание, Объект.Сообщество), Новый УникальныйИдентификатор);
			
		ИначеЕсли  ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.Цитаты") Тогда
			
			
			ДокументОбъект 	= Объект.Ссылка.ПолучитьОбъект();
			ДД				= ДокументОбъект.КартинкаДвоичные.Получить();
			
			КартинкаПоста = ПоместитьВоВременноеХранилище(
			Новый ДвоичныеДанные(МетодыОбработкиИзображений.СформироватьИзображениеСТекстом(Объект.Содержание
					, Объект.Содержание.Текст
					, ?(ТипЗнч(Объект.Содержание.ПроизведениеАвтор) = Тип("СправочникСсылка.Люди")
								, Объект.Содержание.ПроизведениеАвтор
								, ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Объект.Содержание.ПроизведениеАвтор, "Автор"))
					, ДД
					, Истина))
					
				, Новый УникальныйИдентификатор);
					
		КонецЕсли;
	Исключение
		ТекстПоста = "";
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти




#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура КартинкаОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка 	= Ложь;
	Диалог 					= Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок 		= "Выбирите файл";
	Диалог.Каталог			= "Z:\GDrive\Aioniotis\Images";
	ОповещениеЗавершения 	= Новый ОписаниеОповещения("ВыборФайлаЗавершение", ЭтотОбъект);
	Диалог.Показать(ОповещениеЗавершения);

КонецПроцедуры

&НаКлиенте
Процедура СодержаниеПриИзменении(Элемент)
	СодержаниеПриИзмененииНаСервере();
КонецПроцедуры

#КонецОбласти




#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Промт(Команда)
	ПромтНаСервере();
КонецПроцедуры

#КонецОбласти




#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыборФайлаЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда	
		
		Объект.Картинка = ВыбранныеФайлы[0];
		ЗаписатьДвоичныеДанныеКартинки(Новый ДвоичныеДанные(Объект.Картинка));
		Закрыть();
	  	ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));

	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДвоичныеДанныеКартинки(ДД)
	
	Записать();
	ОбъектПост 					= Объект.Ссылка.ПолучитьОбъект();
	ОбъектПост.КартинкаДвоичные = Новый ХранилищеЗначения(ДД);
	ОбъектПост.Записать();
	
КонецПроцедуры

&НаСервере
Процедура ПромтНаСервере()	
	Записать();
	Midjourney = МетодыФормированияПостов.НовыйПромт(Объект.Ссылка);	
КонецПроцедуры

&НаСервере
Процедура СодержаниеПриИзмененииНаСервере()
	
	Записать();
	
	Если ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.Термины") Тогда
		Объект.ВидКартинки = Перечисления.ВидыКартинок.Термин;
		Объект.Уровень = Перечисления.УровниПостов.II;
	ИначеЕсли ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.События") Тогда
		Объект.ВидКартинки = Перечисления.ВидыКартинок.Событие;
		Объект.Уровень = Перечисления.УровниПостов.II;
	
	КонецЕсли;

	ТекстПоста = МетодыФормированияПостов.СформироватьТекстПоста(Объект.Ссылка);

КонецПроцедуры

#КонецОбласти







