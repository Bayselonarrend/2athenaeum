
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура НайтиСовпадения(Команда)
	НайтиНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ВывестиТекст(Команда)
	ВывестиТекстНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
	СохранитьНаСервере();
КонецПроцедуры

#КонецОбласти





#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВывестиТекстНаСервере()
	
	ТекстОбъект = Текст.ПолучитьОбъект();
	СтрокаТекст = ТекстОбъект.ТекстМассив.Получить();
	
	
	ТекстСтрока = СтрСоединить(СтрокаТекст, " ");
	
КонецПроцедуры



&НаСервере
Процедура СохранитьНаСервере()
	ТекстФайла 		= СтрРазделить(ТекстСтрока, " ", Ложь);
	ЗаписатьТекстНаСервере(ТекстФайла, Текст);
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
Процедура НайтиНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Произведения.Ссылка КАК Ссылка,
		|	Произведения.Наименование КАК Наименование
		|ИЗ
		|	Справочник.Произведения КАК Произведения
		|ГДЕ
		|	(НЕ &ВЭтом
		|			ИЛИ Произведения.Ссылка = &Текущий)
		|	И Произведения.НаСайте";
	
	Запрос.УстановитьПараметр("ВЭтом", ВЭтом);
	Запрос.УстановитьПараметр("Текущий", Текст);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		ОбъектТекст = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
		МассивТекст = ОбъектТекст.ТекстМассив.Получить();
				
		Если ТипЗнч(МассивТекст) = Тип("Массив") Тогда
			Для Каждого Слово Из МассивТекст Цикл
				Для Каждого ТПоиск Из Поиск Цикл
					Если СтрНайти(нРег(Слово), нРег(СокрЛП(ТПоиск.Значение))) <> 0 Тогда
						
						Лог = Лог 
						+ Слово 
						+ " в тексте:   " 
						+ Строка(ВыборкаДетальныеЗаписи.Ссылка) 
						+ " (" 
						+ ВыборкаДетальныеЗаписи.Наименование 
						+ ") " 
						+ Символы.ПС
						+ Символы.ПС
						+ "-------------------------------------"
						+ Символы.ПС;
						
						
					КонецЕсли;
				КонецЦикла;
				
			КонецЦикла;
		КонецЕсли;
		
	КонецЦикла;
		
		
КонецПроцедуры

#КонецОбласти
