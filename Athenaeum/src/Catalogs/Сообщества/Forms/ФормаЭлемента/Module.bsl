#Область ОбработчикиКомандФормы


&НаКлиенте
Процедура Авторизовать(Команда)
	АвторизоватьНаСервере();
КонецПроцедуры

#КонецОбласти



&НаСервере
Процедура АвторизоватьНаСервере()
	
	ПараметрыАвторизации = Новый Соответствие;
	ПараметрыАвторизации.Вставить("client_id"		, Объект.ВК_client_id);
	
	СсылкаАвторизации = ВК_Апи.autorize(ПараметрыАвторизации);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция СоздатьКомпаниюНаСервере(Сообщество)
	Возврат ВК_Действия.СоздатьРекламнуюКомпанию(Сообщество);
КонецФункции

&НаКлиенте
Процедура СоздатьКомпанию(Команда)
	Объект.ВК_НомерКомпании = СоздатьКомпаниюНаСервере(Объект.Ссылка);
	Записать();
КонецПроцедуры

&НаКлиенте
Процедура ПутьОткрытие(Команда)
	
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
		Путь = ВыбранныеФайлы[0];
		ЗаписатьДвоичныеДанныеФайла(Новый ДвоичныеДанные(Путь));	
		
		Закрыть();
		ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДвоичныеДанныеФайла(ДД)
	
	Записать();
	ОбъектПост 				= Объект.Ссылка.ПолучитьОбъект();
	ОбъектПост.Лого 	= Новый ХранилищеЗначения(ДД);
	ОбъектПост.Записать();
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	КартинкаЛого = ПолучитьНавигационнуюСсылку(Объект.Ссылка, "Лого");
КонецПроцедуры
