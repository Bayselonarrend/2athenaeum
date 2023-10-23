#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Объект.Код) Тогда
		
		Объект.Код 		= ИнструментарийВызовСервера.ГенерацияСлучайногоСимвола();
		Существующий 	= Справочники.Произведения.НайтиПоКоду(Объект.Код);
		
		Пока ЗначениеЗаполнено(Существующий) Цикл
			Объект.Код 		= ИнструментарийВызовСервера.ГенерацияСлучайногоСимвола();
			Существующий 	= Справочники.Произведения.НайтиПоКоду(Объект.Код);
		КонецЦикла;
		
	КонецЕсли;

	УстановитьПорядковыйНомер();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура КартинкаОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка 	= Ложь;
	Диалог 					= Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок 		= Строка("Выберите файл");
	ОповещениеЗавершения 	= Новый ОписаниеОповещения("ВыборФайлаЗавершение", ЭтотОбъект);
	Диалог.Показать(ОповещениеЗавершения);
	
КонецПроцедуры

&НаКлиенте
Процедура НаСайтеПриИзменении(Элемент)
	УстановитьПорядковыйНомер();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗагрузитьТекст(Команда)
	
		Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
		ОповещениеЗавершения = Новый ОписаниеОповещения("ПриВыбореФайла", ЭтотОбъект);
		Диалог.Показать(ОповещениеЗавершения);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьНаСайт(Команда)
	Записать();
	//@skip-check unknown-method-property
	ЗагрузитьНаСайтНаСервере(Объект.Ссылка);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыборФайлаЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда
		
		Объект.Картинка = ВыбранныеФайлы[0];
		ЗаписатьДвоичныеДанныеКартинки(Новый ДвоичныеДанные(Объект.Картинка));
		
		Закрыть();
	 	ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));

	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриВыбореФайла(ВыбФайлы, ДополнительныеПараметры) Экспорт

#Если НЕ ВебКлиент Тогда
	
  Если ВыбФайлы <> Неопределено Тогда
  	
      Путь 				= ВыбФайлы[0];
	  ТекстВременный 	= Новый ЧтениеТекста(Путь);
	  МаксимальныйНомер = 999;
	  
	  ТекстСтрокой = ТекстВременный.Прочитать();
	  
	  Для Н = 0 По МаксимальныйНомер Цикл
	  	
	  	ПредыдущийНомер = Строка(МаксимальныйНомер - Н);
	  	
		ТекстСтрокой = СтрЗаменить(ТекстСтрокой, "&#" 	+ ПредыдущийНомер + ";", "");
		
		ТекстСтрокой = СтрЗаменить(ТекстСтрокой, Символы.ПС 
			+ Символы.ПС 
			+ "[" 	
			+ ПредыдущийНомер 
			+ "]" 
			+ Символы.ПС 
			+ Символы.ПС, "");
			
		ТекстСтрокой = СтрЗаменить(ТекстСтрокой, Символы.ПС + "[" 	+ ПредыдущийНомер + "]" + Символы.ПС, "");
		ТекстСтрокой = СтрЗаменить(ТекстСтрокой, "[" 	+ ПредыдущийНомер + "]", "");
		
	КонецЦикла;
	
	  
	  ТекстФайла 		= СтрРазделить(ТекстСтрокой, " ", Ложь);
	  
	  Записать();
	  //@skip-check unknown-method-property
	  ЗаписатьТекстНаСервере(ТекстФайла, Объект.Ссылка);
	  
	  Закрыть();
	  ПерейтиПоНавигационнойСсылке(ПолучитьНавигационнуюСсылку(ЭтотОбъект));
	  
  КонецЕсли;
  
 #КонецЕсли  

КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗаписатьТекстНаСервере(ТекстФайла, СсылкаТекст)
	 
	Об 				= СсылкаТекст.ПолучитьОбъект();
	Об.ТекстМассив 	= Новый ХранилищеЗначения(ТекстФайла, Новый СжатиеДанных(9));
	Об.Текст		= "Загружен: " + Строка(ТекстФайла.Количество()) + " слов";
	Об.Слов			= ТекстФайла.Количество();
	Об.Записать();
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДвоичныеДанныеКартинки(ДД)
	
	Записать();
	ОбъектПост 					= Объект.Ссылка.ПолучитьОбъект();
	ОбъектПост.КартинкаДвоичные = Новый ХранилищеЗначения(ДД);
	ОбъектПост.Записать();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗагрузитьНаСайтНаСервере(Книга)
	МетодыСтатикиСайта.ОбновитьКнигу(Книга);
КонецПроцедуры

&НаСервере
Процедура УстановитьПорядковыйНомер()
	
	Если Не ЗначениеЗаполнено(Объект.ПорядковыйНомер) И Объект.НаСайте Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	МАКСИМУМ(Произведения.ПорядковыйНомер) КАК ПорядковыйНомер
		|ИЗ
		|	Справочник.Произведения КАК Произведения
		|ГДЕ
		|	Произведения.НаСайте = ИСТИНА";
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		
		Если ВыборкаДетальныеЗаписи.Следующий() Тогда
			МаксимальноеЧисло = ВыборкаДетальныеЗаписи.ПорядковыйНомер;
		Иначе 
			МаксимальноеЧисло = 1;
		КонецЕсли;
		
		Объект.ПорядковыйНомер = МаксимальноеЧисло + 1;
		
	КонецЕсли;

КонецПроцедуры

#КонецОбласти


