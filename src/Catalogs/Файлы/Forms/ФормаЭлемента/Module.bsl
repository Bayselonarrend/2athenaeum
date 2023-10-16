#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПутьОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка 	= Ложь;
	Диалог 					= Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок 		= "Выбирите файл";
	ОповещениеЗавершения 	= Новый ОписаниеОповещения("ВыборФайлаЗавершение", ЭтотОбъект);
	Диалог.Показать(ОповещениеЗавершения);

КонецПроцедуры

#КонецОбласти




#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыборФайлаЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда	
		Объект.Путь = ВыбранныеФайлы[0];
		ЗаписатьДвоичныеДанныеФайла(Новый ДвоичныеДанные(Объект.Путь));	
		
		Закрыть();
		ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДвоичныеДанныеФайла(ДД)
	
	Записать();
	ОбъектПост 		= Объект.Ссылка.ПолучитьОбъект();
	ОбъектПост.Файл = Новый ХранилищеЗначения(ДД);
	ОбъектПост.Записать();
	
КонецПроцедуры

#КонецОбласти
