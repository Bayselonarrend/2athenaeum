#Область ОбработчикиСобытийЭлементовТаблицыФормыСписокКниг

&НаКлиенте
Процедура СписокКнигЗначениеПриИзменении(Элемент)
	СформироватьСписокАвторов();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьДанные(Команда)
	ОбновитьДанныеНаСервере();	
КонецПроцедуры

&НаКлиенте
Процедура АвторыКниг(Команда)
	СформироватьСписокАвторов();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбновитьДанныеНаСервере()
	
	МассивАвторов = Новый Массив;
	Для Каждого Автор Из СписокАвторов Цикл
		МассивАвторов.Добавить(Автор.Значение);
	КонецЦикла;
	
	МетодыСтатикиСайта.ОбновитьСтраницыАвторов(МассивАвторов);
	
	МассивКниг = Новый Массив;
	Для Каждого Книга Из СписокКниг Цикл
		МассивКниг.Добавить(Книга.Значение);
	КонецЦикла;
	
	МетодыСтатикиСайта.ОбновитьСтраницыКниг(МассивКниг);
	МетодыСтатикиСайта.СформироватьIndex();
	МетодыСтатикиСайта.СформироватьСайтмап();

КонецПроцедуры

&НаСервере
Процедура СформироватьСписокАвторов() 
	
	СписокАвторов.Очистить();
	СоответствиеАвторов = Новый Соответствие;
	
	Для Каждого Книга Из СписокКниг Цикл
		
		Автор = Книга.Значение.Автор;
		
		Если СоответствиеАвторов.Получить(Автор) = Неопределено Тогда
			СписокАвторов.Добавить(Автор);
			СоответствиеАвторов.Вставить(Автор, Истина);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
