
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		
		КартинкаДР = МетодыОбработкиИзображений.СформироватьКартинкуДняРождения(Объект.Ссылка);
		
		ПутьККартинке = ПоместитьВоВременноеХранилище(
			Новый ДвоичныеДанные(КартинкаДР)
			, Новый УникальныйИдентификатор);
			
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура КартинкаОткрытие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка 	= Ложь;
	ВыборФайлаНачало(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ПортретОткрытие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка 	= Ложь;
	ВыборФайлаНачало(ЭтотОбъект);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыборФайлаНачало(Элемент)
		
	Диалог 					= Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок 		= "Выбирите файл";
	ОповещениеЗавершения 	= Новый ОписаниеОповещения(Строка("ВыборФайлаЗавершение"), Элемент);
	Диалог.Показать(ОповещениеЗавершения);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборФайлаЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда
		
		Если ТекущийЭлемент.Имя = "Фото" Тогда
			
			Объект.ПутьКФото = ВыбранныеФайлы[0];
			ЗаписатьДвоичныеДанныеКартинки(Новый ДвоичныеДанные(Объект.ПутьКФото), "Фото");

		ИначеЕсли ТекущийЭлемент.Имя = "Портрет" Тогда
			
			Объект.Портрет = ВыбранныеФайлы[0];
			ЗаписатьДвоичныеДанныеКартинки(Новый ДвоичныеДанные(Объект.Портрет), "КартинкаДвоичные");
		
		Иначе
				Возврат;
		КонецЕсли;
		
		Закрыть();
	  	ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДвоичныеДанныеКартинки(ДД, Реквизит)
	
	Записать();
	ОбъектПост 					= Объект.Ссылка.ПолучитьОбъект();
	ОбъектПост[Реквизит] = Новый ХранилищеЗначения(ДД);
	ОбъектПост.Записать();
	
КонецПроцедуры

#КонецОбласти
