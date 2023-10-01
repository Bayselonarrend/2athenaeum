#Область ПрограммныйИнтерфейс

Функция JSONСтрокой(Знач Данные) Экспорт
	
	ПараметрыJSON    				= Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, " " , Истина, ЭкранированиеСимволовJSON.Нет, Ложь, Ложь, Ложь, Ложь);
	ЗаписьJSON        				= Новый ЗаписьJSON;
	ЗаписьJSON.ПроверятьСтруктуру 	= Истина;
	ЗаписьJSON.УстановитьСтроку(ПараметрыJSON);
	
	ЗаписатьJSON(ЗаписьJSON, Данные);
	Возврат ЗаписьJSON.Закрыть();

КонецФункции

Процедура JSONВФайл(Знач Данные, Знач Путь) Экспорт
	
	ИндексСайта 	= Новый ЗаписьJSON;
	ПараметрыЗаписи = Новый ПараметрыЗаписиJSON();
	
	ИндексСайта.ОткрытьФайл(Путь,,,ПараметрыЗаписи);
	ЗаписатьJSON(ИндексСайта, Данные);
	ИндексСайта.Закрыть();

КонецПроцедуры

Функция ГенерацияСлучайногоСимвола() Экспорт

	ГСЧ = Новый ГенераторСлучайныхЧисел(ТекущаяУниверсальнаяДатаВМиллисекундах());
	СлучайнаяСтрока = "";

	Для Сч = 1 По 5 Цикл

		Набор = ГСЧ.СлучайноеЧисло(1, 3);

		Если Набор = 1 Тогда
			СлучайныйСимвол = Строка(ГСЧ.СлучайноеЧисло(0, 9));
		ИначеЕсли Набор = 2 Тогда
			СлучайныйСимвол = Символ(ГСЧ.СлучайноеЧисло(65, 90));
		ИначеЕсли Набор = 3 Тогда
			СлучайныйСимвол = Символ(ГСЧ.СлучайноеЧисло(97, 122));
		КонецЕсли;

		СлучайнаяСтрока = СлучайнаяСтрока + СлучайныйСимвол;

	КонецЦикла;

	Возврат (ВРег(СлучайнаяСтрока));

КонецФункции

Функция ВернутьДеньНедели(Знач Номер = 0) Экспорт
	
	Если Номер = 0 Тогда		
		Номер = ДеньНедели(ТекущаяДатаСеанса());		
	КонецЕсли;
	
	СоответствиеДней = Новый Соответствие;
	СоответствиеДней.Вставить(1, Перечисления.ДниНедели.Пн);
	СоответствиеДней.Вставить(2, Перечисления.ДниНедели.Вт);
	СоответствиеДней.Вставить(3, Перечисления.ДниНедели.Ср);
	СоответствиеДней.Вставить(4, Перечисления.ДниНедели.Чт);
	СоответствиеДней.Вставить(5, Перечисления.ДниНедели.Пт);
	СоответствиеДней.Вставить(6, Перечисления.ДниНедели.Сб);
	СоответствиеДней.Вставить(7, Перечисления.ДниНедели.Вс);
	
	Возврат СоответствиеДней.Получить(Номер);
	
КонецФункции

Процедура ЗаписьВЖурналИсключений(Знач ОписаниеОшибки, Знач ДопИнформация = "") Экспорт
	
	МЗ 					= РегистрыСведений.ЖурналИсключений.СоздатьМенеджерЗаписи();
	МЗ.Период 			= ТекущаяДатаСеанса();
	МЗ.UID 				= Строка(Новый УникальныйИдентификатор);
	МЗ.ОписаниеОшибки 	= ОписаниеОшибки;
	МЗ.ДопИнформация	= ДопИнформация;
	МЗ.Записать(Истина);
	
КонецПроцедуры

Процедура ЗаписьВОтветыАпи(Знач Ответ, Знач СоцСеть, Знач Запрос) Экспорт
	
	МЗ = РегистрыСведений.ОбращенияКАпи.СоздатьМенеджерЗаписи();
	МЗ.UID 		= Строка(Новый УникальныйИдентификатор);
	МЗ.Апи 		= СоцСеть;
	МЗ.Ответ 	= ?(ТипЗнч(Ответ) = Тип("Строка"), Ответ, JSONСтрокой(Ответ));
	МЗ.Период 	= ТекущаяДатаСеанса();
	МЗ.Запрос 	= Запрос;
	МЗ.Записать();
	
КонецПроцедуры

Процедура ЗаписьВЗапросыыАпи(Знач Текст) Экспорт
	
	МЗ = РегистрыСведений.ОбращенияКАпи.СоздатьМенеджерЗаписи();
	МЗ.UID 			= Строка(Новый УникальныйИдентификатор);
	МЗ.ТекстЗапроса = ?(ТипЗнч(Текст) = Тип("Строка"), Текст, JSONСтрокой(Текст));
	МЗ.Период 		= ТекущаяДатаСеанса();
	МЗ.Записать();
	
КонецПроцедуры

Функция ЗначенияРеквизитовОбъекта(Ссылка, Знач Реквизиты, ВыбратьРазрешенные = Ложь) Экспорт 
     
    // Если передано имя предопределенного. 
    Если ТипЗнч(Ссылка) = Тип("Строка") Тогда 
         
        ПолноеИмяПредопределенногоЭлемента = Ссылка; 
         
        // Вычисление ссылки по имени предопределенного. 
        // - дополнительно выполняет проверку метаданных предопределенного, выполняется предварительно. 
        Попытка 
            Ссылка = ПредопределенноеЗначение(ПолноеИмяПредопределенногоЭлемента); 
        Исключение 
            ТекстОшибки = ""; 
            ВызватьИсключение ТекстОшибки; 
        КонецПопытки; 
         
        // Разбор полного имени предопределенного. 
        ЧастиПолногоИмени = СтрРазделить(ПолноеИмяПредопределенногоЭлемента, "."); 
        ПолноеИмяОбъектаМетаданных = ЧастиПолногоИмени[0] + "." + ЧастиПолногоИмени[1]; 
         
        // Если предопределенный не создан в ИБ, то требуется выполнить проверку доступа к объекту. 
        // В других сценариях проверка доступа выполняется в момент исполнения запроса. 
        Если Ссылка = Неопределено Тогда 
            МетаданныеОбъекта = Метаданные.НайтиПоПолномуИмени(ПолноеИмяОбъектаМетаданных); 
			Если Не ПравоДоступа("Чтение", МетаданныеОбъекта) Тогда 
				Возврат Ложь;
            КонецЕсли; 
        КонецЕсли; 
         
    Иначе // Если передана ссылка. 
         
        Попытка 
            ПолноеИмяОбъектаМетаданных = Ссылка.Метаданные().ПолноеИмя(); 
        Исключение 
			Возврат Ложь;	
		КонецПопытки; 
         
    КонецЕсли; 
     
    // Разбор реквизитов, если второй параметр Строка. 
    Если ТипЗнч(Реквизиты) = Тип("Строка") Тогда 
        Если ПустаяСтрока(Реквизиты) Тогда 
            Возврат Новый Структура; 
        КонецЕсли; 
         
        // Удаление пробелов. 
        Реквизиты = СтрЗаменить(Реквизиты, " ", ""); 
        // Преобразование параметра в массив полей. 
        Реквизиты = СтрРазделить(Реквизиты, ","); 
    КонецЕсли; 
     
    // Приведение реквизитов к единому формату. 
    СтруктураПолей = Новый Структура; 
    Если ТипЗнч(Реквизиты) = Тип("Структура") 
        Или ТипЗнч(Реквизиты) = Тип("ФиксированнаяСтруктура") Тогда 
         
        СтруктураПолей = Реквизиты; 
         
    ИначеЕсли ТипЗнч(Реквизиты) = Тип("Массив") 
        Или ТипЗнч(Реквизиты) = Тип("ФиксированныйМассив") Тогда 
         
        Для Каждого Реквизит Из Реквизиты Цикл 
             
            Попытка 
                ПсевдонимПоля = СтрЗаменить(Реквизит, ".", ""); 
                СтруктураПолей.Вставить(ПсевдонимПоля, Реквизит); 
            Исключение 
              
                Возврат Ложь;
            КонецПопытки; 
        КонецЦикла; 
    Иначе 
		Возврат Ложь;	
	КонецЕсли; 
     
    // Подготовка результата (после выполнения запроса переопределится). 
    Результат = Новый Структура; 
     
    // Формирование текста запроса к выбираемым полям. 
    ТекстЗапросаПолей = ""; 
    Для каждого КлючИЗначение Из СтруктураПолей Цикл 
         
        ИмяПоля = ?(ЗначениеЗаполнено(КлючИЗначение.Значение), 
                        КлючИЗначение.Значение, 
                        КлючИЗначение.Ключ); 
        ПсевдонимПоля = КлючИЗначение.Ключ; 
         
        ТекстЗапросаПолей = 
            ТекстЗапросаПолей + ?(ПустаяСтрока(ТекстЗапросаПолей), "", ",") + " 
            |    " + ИмяПоля + " КАК " + ПсевдонимПоля; 
         
         
        // Предварительное добавление поля по псевдониму в возвращаемый результат. 
        Результат.Вставить(ПсевдонимПоля); 
         
    КонецЦикла; 
     
    // Если предопределенного нет в ИБ. 
    // - приведение результата к отсутствию объекта в ИБ или передаче пустой ссылки. 
    Если Ссылка = Неопределено Тогда 
        Возврат Результат; 
    КонецЕсли; 
     
    ТекстЗапроса = 
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ 
        |&ТекстЗапросаПолей 
        |ИЗ 
        |    &ПолноеИмяОбъектаМетаданных КАК Таблица 
        |ГДЕ 
        |    Таблица.Ссылка = &Ссылка"; 
     
    Если Не ВыбратьРазрешенные Тогда 
        ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "РАЗРЕШЕННЫЕ", ""); 
    КонецЕсли; 
     
    ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ТекстЗапросаПолей", ТекстЗапросаПолей); 
    ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ПолноеИмяОбъектаМетаданных", ПолноеИмяОбъектаМетаданных); 
     
    // Выполнение запроса. 
    Запрос = Новый Запрос; 
    Запрос.УстановитьПараметр("Ссылка", Ссылка); 
    Запрос.Текст = ТекстЗапроса; 
     
    Попытка 
        Выборка = Запрос.Выполнить().Выбрать(); 
    Исключение 
         
        // Если реквизиты были переданы строкой, то они уже конвертированы в массив. 
        // Если реквизиты - массив, оставляем без изменений. 
        // Если реквизиты - структура - конвертируем в массив. 
        // В остальных случаях уже было бы выброшено исключение. 
        Если Тип("Структура") = ТипЗнч(Реквизиты) Тогда 
            Реквизиты = Новый Массив; 
            Для каждого КлючИЗначение Из СтруктураПолей Цикл 
                ИмяПоля = ?(ЗначениеЗаполнено(КлючИЗначение.Значение), 
                            КлючИЗначение.Значение, 
                            КлючИЗначение.Ключ); 
                Реквизиты.Добавить(ИмяПоля); 
            КонецЦикла; 
        КонецЕсли; 
         
		Возврат Ложь;
         
    КонецПопытки; 
     
    // Заполнение реквизитов. 
    Если Выборка.Следующий() Тогда 
        ЗаполнитьЗначенияСвойств(Результат, Выборка); 
    КонецЕсли; 
     
    Возврат Результат; 
     
КонецФункции 

Функция ЗапуститьФоновоеВыполнение(ТекстПроцедуры,СтруктураПараметров=Неопределено) Экспорт
	
	УникальныйИдентификатор = Новый УникальныйИдентификатор;
    ПараметрыВыполнения = Новый Массив;
    ПараметрыВыполнения.Добавить(ТекстПроцедуры);
    ПараметрыВыполнения.Добавить(СтруктураПараметров);
    
    ФоновыеЗадания.Выполнить("ИнструментарийВызовСервера.ФоноваяПроцедура",ПараметрыВыполнения,УникальныйИдентификатор);
    Возврат УникальныйИдентификатор;
	
КонецФункции

Процедура ФоноваяПроцедура(ТекстМодуля,ПараметрыВыполнения) Экспорт
	
	ПолныйТекстМодуля = "";
	
    Для Каждого ТекПараметр Из ПараметрыВыполнения Цикл
        ПолныйТекстМодуля = ПолныйТекстМодуля+ТекПараметр.Ключ + " = ПараметрыВыполнения." + ТекПараметр.Ключ + ";" + Символы.ПС;
	КонецЦикла;
	
    ПолныйТекстМодуля = ПолныйТекстМодуля + ТекстМодуля;
    //@skip-check server-execution-safe-mode
    Выполнить(ПолныйТекстМодуля);
	
КонецПроцедуры

#КонецОбласти