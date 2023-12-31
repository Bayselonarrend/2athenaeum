#Если НаСервере Тогда
	
#Область ОбработчикиСобытий

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
     Возврат;
	КонецЕсли;
	
	Попытка
		
		ДН				= ДеньНедели(ТекущаяДатаСеанса());
		Набор 			= РегистрыСведений.ДневнойПрогресс.СоздатьНаборЗаписей();
		ЭлементОтбора 	= Набор.Отбор.Пользователь;	
		ДнейВНеделе		= 7;
		ЕдиницаВремени	= 60;
		ЧасовВСутках	= 24;
		
		ЭлементОтбора.ВидСравнения = ВидСравнения.Равно;
		ЭлементОтбора.Установить(Ссылка);
		Набор.Прочитать();
		
		Если Набор.Количество() = 0 Тогда
			
			Для Н = 0 По 6 Цикл		
				ЗаполняемыйДень = ?(ДН - Н < 1, ДН - Н + ДнейВНеделе, ДН - Н); 
				НоваяЗапись = Набор.Добавить();
				НоваяЗапись.Дата = НачалоДня(ТекущаяДатаСеанса()) - (ЕдиницаВремени * ЕдиницаВремени * ЧасовВСутках * Н);
				НоваяЗапись.День = ИнструментарийВызовСервера.ВернутьДеньНедели(ЗаполняемыйДень);
				НоваяЗапись.КоличествоСлов = 0;
				НоваяЗапись.Пользователь = Ссылка;
				Набор.Записать(Истина);
			КонецЦикла;
					
		КонецЕсли;
		
	Исключение
		
		ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
		
	КонецПопытки;
		
КонецПроцедуры

Процедура ПередУдалением(Отказ)

Если ОбменДанными.Загрузка Тогда
     Возврат;
КонецЕсли;

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДневнойПрогресс.Пользователь КАК Пользователь,
		|	ДневнойПрогресс.День КАК День
		|ПОМЕСТИТЬ ДневнойПрогресс
		|ИЗ
		|	РегистрСведений.ДневнойПрогресс КАК ДневнойПрогресс
		|ГДЕ
		|	ДневнойПрогресс.Пользователь = &Пользователь
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	АктивныеСеансы.Cookie КАК Cookie,
		|	АктивныеСеансы.Пользователь КАК Пользователь
		|ПОМЕСТИТЬ АктивныеСеансы
		|ИЗ
		|	РегистрСведений.АктивныеСеансы КАК АктивныеСеансы
		|ГДЕ
		|	АктивныеСеансы.Пользователь = &Пользователь
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ПотоковоеЧтение.Пользователь КАК Пользователь,
		|	ПотоковоеЧтение.Текст КАК Текст
		|ПОМЕСТИТЬ ПотоковоеЧтение
		|ИЗ
		|	РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
		|ГДЕ
		|	ПотоковоеЧтение.Пользователь = &Пользователь";
	
	Запрос.УстановитьПараметр("Пользователь", Ссылка);
	
	РезультатыЗапроса 	= Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	СоответствиеПакетов	= Новый Соответствие;
	Счетчик			 	= 0;
	
	СоответствиеПакетов.Вставить(0, "ДневнойПрогресс" );
	СоответствиеПакетов.Вставить(1, "АктивныеСеансы" );
	СоответствиеПакетов.Вставить(2, "ПотоковоеЧтение" );
	
	Для Каждого РезультатЗапроса Из РезультатыЗапроса Цикл
		
		ВыборкаДетальныеЗаписи 	= РезультатЗапроса.Выбрать();
		ТекущийРегистр			= СоответствиеПакетов.Получить(Счетчик);
		
		Если ТекущийРегистр = Неопределено Тогда
			Прервать;
		КонецЕсли;
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			
			МЗ = РегистрыСведений[ТекущийРегистр].СоздатьМенеджерЗаписи();
			ЗаполнитьЗначенияСвойств(МЗ, ВыборкаДетальныеЗаписи);
			МЗ.Удалить();
			
		КонецЦикла;
		
		Счетчик = Счетчик + 1;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Пользователи.ПерсональныеНастройки КАК Ссылка
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	Пользователи.Ссылка = &Пользователь ";
	
	Запрос.УстановитьПараметр("Пользователь", Ссылка);
	
	РезультатЗапроса 	= Запрос.Выполнить();
	МассивСсылок		= Новый Массив;
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		МассивСсылок.Добавить(ВыборкаДетальныеЗаписи.Ссылка);
	КонецЦикла;
	
	УдалитьОбъекты(МассивСсылок);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли