#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Объект.ВидКартинки) Тогда
		Объект.ВидКартинки = Перечисления.ВидыКартинок.Одиночная;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Объект.Уровень) Тогда
		Объект.Уровень = Объект.Сообщество.СтандартныйУровеньПоста;	
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
			И Не  ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.События") Тогда
			
			КартинкаПоста = ПолучитьНавигационнуюСсылку(Объект.Ссылка, "КартинкаДвоичные");
			ТекстПоста = ФормированиеПостовСервер.СформироватьТекстПоста(Объект.Ссылка);
			
		ИначеЕсли ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.Термины") Тогда
			ТекстПоста = Объект.Содержание.Описание;
			КартинкаПоста = ПоместитьВоВременноеХранилище(РаботаССистемойСервер.СформироватьТермин(Объект.Содержание, Истина), Новый УникальныйИдентификатор);
			
		ИначеЕсли  ТипЗнч(Объект.Содержание) = Тип("СправочникСсылка.События") Тогда
			ТекстПоста = ФормированиеПостовСервер.СформироватьТекстПоста(Объект.Ссылка);
			КартинкаПоста = ПоместитьВоВременноеХранилище(РаботаССистемойСервер.СформироватьСобытие(Объект.Содержание, Объект.Сообщество, Истина), Новый УникальныйИдентификатор);
		
		КонецЕсли;
	Исключение
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

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Промт(Команда)
	ПромтНаСервере();
КонецПроцедуры

#Если Не ВебКлиент Тогда
&НаКлиенте
Процедура СформироватьИзображениеСТекстом(Команда) 
	
	Записать();
	
	ИВФ 		= ПолучитьИмяВременногоФайла("png");
	ДД			= ПолучитьДД();
	
	ДД.Записать(ИВФ);	
	
	КартинкаСТекстом = РаботаССистемойСервер.СформироватьИзображениеСТекстом(
			Объект.Содержание
			, ВернутьТекст(Объект.Содержание)
			, ВернутьАвтора(Объект.Содержание)
			, ИВФ
			, Истина);	
			
			СоздатьИсторию(КартинкаСТекстом, Объект.Сообщество);
			
	УдалитьФайлы(ИВФ);
КонецПроцедуры
#КонецЕсли

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучитьДД()
	ОбъектПост 	= Объект.Ссылка.ПолучитьОбъект();
	Возврат ОбъектПост.КартинкаДвоичные.Получить();	
КонецФункции

&НаСервереБезКонтекста
Процедура СоздатьИсторию(Фото, Сообщество)
	ВК_Действия.СоздатьИсторию(Фото, Сообщество);
КонецПроцедуры


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
	Midjourney = ФормированиеПостовСервер.НовыйПромт(Объект.Ссылка);	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ВернутьАвтора(Знач Содержание)
	
	Автор 				= "";
	ПроизведениеАвтор	= Неопределено;
	
	Если ТипЗнч(Содержание) = Тип("СправочникСсылка.Цитаты")
			Или ТипЗнч(Содержание) = Тип("СправочникСсылка.Произведения") Тогда
		
		//@skip-check reading-attribute-from-database
			
	
		Если ТипЗнч(Содержание) = Тип("СправочникСсылка.Цитаты") Тогда
			
			ПроизведениеАвтор = Содержание.ПроизведениеАвтор;	
			
			Если ТипЗнч(ПроизведениеАвтор) = Тип("СправочникСсылка.Произведения") Тогда
				//@skip-check reading-attribute-from-database
				Автор = ПроизведениеАвтор.Автор.Имя + " " + ПроизведениеАвтор.Автор.Фамилия;
			ИначеЕсли ТипЗнч(ПроизведениеАвтор) = Тип("СправочникСсылка.Люди") Тогда
				//@skip-check reading-attribute-from-database
				//@skip-check unknown-method-property
				Автор = ПроизведениеАвтор.Имя + " " + ПроизведениеАвтор.Фамилия;
			КонецЕсли;
			
		ИначеЕсли ТипЗнч(Содержание) = Тип("СправочникСсылка.Произведения") Тогда
			
			//@skip-check reading-attribute-from-database
			Автор = Содержание.Автор.Имя + " " + Содержание.Автор.Фамилия;
			
		КонецЕсли;
	
	КонецЕсли;
	
	Возврат Автор;
КонецФункции

&НаСервереБезКонтекста
Функция ВернутьТекст(Знач Содержание)
	//@skip-check reading-attribute-from-database
	Возврат Содержание.Текст;
КонецФункции

&НаСервереБезКонтекста
Процедура СоздатьОбъявлениеНаСервере(Пост)
	ВК_Действия.СоздатьРекламноеОбъявление(Пост);
КонецПроцедуры

&НаКлиенте
Процедура СоздатьОбъявление(Команда)
	Записать();
	СоздатьОбъявлениеНаСервере(Объект.Ссылка);
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
	
	Попытка
	ТекстПоста = ФормированиеПостовСервер.СформироватьТекстПоста(Объект.Ссылка);
	Исключение
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура СодержаниеПриИзменении(Элемент)
	СодержаниеПриИзмененииНаСервере();
КонецПроцедуры

#КонецОбласти







