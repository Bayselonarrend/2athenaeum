#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Автообновление = Параметры.Автообновление;
	ПериодАвтообновления = Параметры.ПериодАвтообновления;
	Если ПериодАвтообновления < 5 Тогда
		ПериодАвтообновления = 5;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	Если ПериодАвтообновления < 5 Тогда
		ПериодАвтообновления = 5;
	КонецЕсли;
	Результат = Новый Структура("Автообновление, ПериодАвтообновления", Автообновление, ПериодАвтообновления);
	Закрыть(Результат);
КонецПроцедуры

#КонецОбласти



