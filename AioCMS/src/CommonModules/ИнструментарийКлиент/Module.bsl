#Область СлужебныйПрограммныйИнтерфейс

Процедура ЗаписатьФайлВРеквизит(Знач Ссылка, Форма, Знач РеквизитДД, Знач РеквизитПути = "") Экспорт
	
	Если Форма.Модифицированность Тогда
		Форма.Записать();
	КонецЕсли;

	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Ссылка"  , Ссылка);
	ДополнительныеПараметры.Вставить("Реквизит", РеквизитДД);
	ДополнительныеПараметры.Вставить("Путь"    , РеквизитПути);
	ДополнительныеПараметры.Вставить("Форма"   , Форма);
	
	Диалог 					= Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок 		= "Выберите файл";
	ОповещениеЗавершения 	= Новый ОписаниеОповещения("ВыборФайлаЗавершение"
		, ЭтотОбъект
		, ДополнительныеПараметры);
		
	Диалог.Показать(ОповещениеЗавершения);
	
КонецПроцедуры

Процедура ВыборФайлаЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда
		
		Форма = ДополнительныеПараметры["Форма"];
		ДополнительныеПараметры.Удалить("Форма");
		
		ИнструментарийВызовСервера.ЗаписатьФайлВРеквизиты(ВыбранныеФайлы[0], ДополнительныеПараметры);
		
		Форма.Закрыть();
	  	ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(Форма));

	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти