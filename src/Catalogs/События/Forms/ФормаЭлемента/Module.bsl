&НаКлиенте
Процедура ПутьОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка 	= Ложь;
	Диалог 					= Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок 		= "Выбирите файл";
	Диалог.Каталог			= "C:\GDrive\Aioniotis\Images";
	ОповещениеЗавершения 	= Новый ОписаниеОповещения("ВыборФайлаЗавершение", ЭтотОбъект);
	Диалог.Показать(ОповещениеЗавершения);

КонецПроцедуры

&НаКлиенте
Процедура ВыборФайлаЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда	
		Объект.Картинка = ВыбранныеФайлы[0];
		ЗаписатьДвоичныеДанныеФайла(Новый ДвоичныеДанные(Объект.Картинка));	
		
		Закрыть();
		ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДвоичныеДанныеФайла(ДД)
	
	Записать();
	ОбъектПост 				= Объект.Ссылка.ПолучитьОбъект();
	ОбъектПост.КартинкаДД 	= Новый ХранилищеЗначения(ДД);
	ОбъектПост.Записать();
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОбновитьКартинку();
КонецПроцедуры

&НаСервере
Процедура ОбновитьКартинку()
	
	Попытка
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда	
		КартинкаСобытия = ПоместитьВоВременноеХранилище(МетодыОбработкиИзображений.СформироватьСобытие(Объект.Ссылка, Объект.Сообщество), Новый УникальныйИдентификатор);
	КонецЕсли;
	Исключение 
		Сообщить("Нет картинки");
	КонецПопытки;

КонецПроцедуры

&НаКлиенте
Процедура ОтступМаркиПриИзменении(Элемент)
	Записать();
	Закрыть();
	ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));
КонецПроцедуры
