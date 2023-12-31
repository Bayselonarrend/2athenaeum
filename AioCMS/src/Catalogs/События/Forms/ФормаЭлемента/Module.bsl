#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОбновитьКартинку();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПутьОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ИнструментарийКлиент.ЗаписатьФайлВРеквизит(Объект.Ссылка, ЭтотОбъект, "КартинкаДД", "Картинка");

КонецПроцедуры

&НаКлиенте
Процедура ОтступМаркиПриИзменении(Элемент)
	Записать();
	Закрыть();
	ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбновитьКартинку()
	
	Попытка
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда	
		КартинкаСобытия = 
			ПоместитьВоВременноеХранилище(
				МетодыОбработкиИзображений.СформироватьСобытие(Объект.Ссылка, Объект.Сообщество)
				, Новый УникальныйИдентификатор);
	КонецЕсли;
	Исключение 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ("Нет картинки");
		Сообщение.Сообщить();
	КонецПопытки;

КонецПроцедуры

#КонецОбласти