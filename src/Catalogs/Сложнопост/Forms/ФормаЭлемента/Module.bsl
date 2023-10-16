#Область ОбработчикиСобытийЭлементовТаблицыФормыРесурсы

&НаКлиенте
Процедура КартинкаОткрытие(Элемент, СтандартнаяОбработка)
	
	Если ТипЗнч(Элементы.Ресурсы.ТекущиеДанные.Медиа) = Тип("Строка") Тогда
		СтандартнаяОбработка 	= Ложь;
		Диалог 					= Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
		Диалог.Заголовок 		= "Выбирите файл";
		ОповещениеЗавершения 	= Новый ОписаниеОповещения("ВыборФайлаЗавершение", ЭтотОбъект);
		Диалог.Показать(ОповещениеЗавершения);	
	КонецЕсли;

КонецПроцедуры

#КонецОбласти



#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьОтображениеКартинки(Команда)
	
	ТД = Элементы.Ресурсы.ТекущиеДанные;
	ОбновитьКартинкуСервер(ТД.ВидОбработки, СформироватьСтруктуруПоСтроке());
	
	
КонецПроцедуры

&НаКлиенте
Процедура Запостить(Команда)
	ЗапоститьНаСервере();
КонецПроцедуры

#КонецОбласти



#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбновитьКартинкуСервер(ВидОбработки, СтруктураОбработки)	
	ДД 			= МетодыОбработкиИзображений.ОбработатьКартинкуПоШаблону(ВидОбработки, СтруктураОбработки, Истина);
	Картинка 	= ПоместитьВоВременноеХранилище(ДД, Новый УникальныйИдентификатор);	
КонецПроцедуры

&НаКлиенте
Функция СформироватьСтруктуруПоСтроке()
	
	ТД = Элементы.Ресурсы.ТекущиеДанные;
	СтруктураРесурсов = Новый Структура;
	
	СтруктураРесурсов.Вставить("МедиаДД", ПолучитьМедиаДД(Элементы.Ресурсы.ТекущаяСтрока));
	СтруктураРесурсов.Вставить("Медиа"	, ТД.Медиа);	
	СтруктураРесурсов.Вставить("ТекстА"	, ТД.ТекстА);
	СтруктураРесурсов.Вставить("ТекстБ"	, ТД.ТекстБ);
	СтруктураРесурсов.Вставить("ТекстВ"	, ТД.ТекстВ);
	
	Возврат СтруктураРесурсов;
	
	
КонецФункции

&НаСервере
Функция ПолучитьМедиаДД(ИД)
	
	Записать();
	ОбъектПост 	= Объект.Ссылка.ПолучитьОбъект();
	Возврат ОбъектПост.Ресурсы[ИД].МедиаДД.Получить();
	
КонецФункции

&НаСервере
Процедура ЗапоститьНаСервере()
	
	Записать();
	МетодыФормированияПостов.СформироватьПост(Объект.Ссылка);

КонецПроцедуры

&НаКлиенте
Процедура ВыборФайлаЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда	
		
		Элементы.Ресурсы.ТекущиеДанные.Медиа = ВыбранныеФайлы[0];
		ЗаписатьДвоичныеДанныеКартинки(Новый ДвоичныеДанные(Элементы.Ресурсы.ТекущиеДанные.Медиа), Элементы.Ресурсы.ТекущаяСтрока);	
		Закрыть();
	  	ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));

	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДвоичныеДанныеКартинки(ДД, ИД)
	
	Записать();
	ОбъектПост 												= Объект.Ссылка.ПолучитьОбъект();
	ОбъектПост.Ресурсы[ИД].МедиаДД 	= Новый ХранилищеЗначения(ДД);
	ОбъектПост.Записать();
	
КонецПроцедуры

#КонецОбласти

