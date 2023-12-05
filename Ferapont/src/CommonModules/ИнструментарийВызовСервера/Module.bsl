#Область ПрограммныйИнтерфейс

// JSONВФайл.
// 
// Параметры:
//  Данные - Произвольный - Данные, которые можно записать в JSON
//  Путь - Строка - Путь, по которому будет записан JSON
Процедура JSONВФайл(Знач Данные, Знач Путь) Экспорт
    
    НоваяЗапись     = Новый ЗаписьJSON;
    ПараметрыЗаписи = Новый ПараметрыЗаписиJSON();
    
    НоваяЗапись.ОткрытьФайл(Путь, , , ПараметрыЗаписи);
    ЗаписатьJSON(НоваяЗапись, Данные);
    НоваяЗапись.Закрыть(); 

КонецПроцедуры

// Запись в журнал исключений.
// 
// Параметры:
//  ОписаниеОшибки - Строка - Описание ошибки
//  ДопИнформация - Строка -  Доп информация
Процедура ЗаписьВЖурналИсключений(Знач ОписаниеОшибки, Знач ДопИнформация = "") Экспорт
    
    МЗ                  = РегистрыСведений.ЖурналИсключений.СоздатьМенеджерЗаписи();
    МЗ.Период           = ТекущаяДатаСеанса();
    МЗ.UID              = Строка(Новый УникальныйИдентификатор);
    МЗ.ОписаниеОшибки   = ОписаниеОшибки;
    МЗ.ДопИнформация    = ДопИнформация;
    МЗ.Записать(Истина);
    
КонецПроцедуры

// Генерация случайного кода для произведения (5 символов, латинские букви и цифры).
// 
// Возвращаемое значение:
//  Строка - Код произведения
Функция ГенерацияСлучайногоСимвола() Экспорт

    ГСЧ = Новый ГенераторСлучайныхЧисел(ТекущаяУниверсальнаяДатаВМиллисекундах());
    СлучайнаяСтрока = "";

    Для Сч = 1 По 5 Цикл

        Набор = ГСЧ.СлучайноеЧисло(1, 3);
        Цифра = 1; 
        Буква = 2;

        Если Набор = Цифра Тогда
            СлучайныйСимвол = Строка(ГСЧ.СлучайноеЧисло(0, 9));
        ИначеЕсли Набор = Буква Тогда
            СлучайныйСимвол = Символ(ГСЧ.СлучайноеЧисло(65, 90));
        Иначе
            СлучайныйСимвол = Символ(ГСЧ.СлучайноеЧисло(97, 122));
        КонецЕсли;

        СлучайнаяСтрока = СлучайнаяСтрока + СлучайныйСимвол;

    КонецЦикла;

    Возврат (ВРег(СлучайнаяСтрока));

КонецФункции

// Возвращает перечисление дня недели по порядковому номеру дня
// 
// Параметры:
//  Номер - Число -  Номер дня недели
// 
// Возвращаемое значение:
//  ПеречислениеСсылка.ДниНедели, Произвольный -  Вернуть день недели
Функция ВернутьДеньНедели(Знач Номер = 0) Экспорт
    
    Если Номер = 0 Тогда        
        Номер = ДеньНедели(ТекущаяДатаСеанса());        
    КонецЕсли;
    
    СоответствиеДней = Новый Соответствие;
    СоответствиеДней.Вставить(1, "Пн");
    СоответствиеДней.Вставить(2, "Вт");
    СоответствиеДней.Вставить(3, "Ср");
    СоответствиеДней.Вставить(4, "Чт");
    СоответствиеДней.Вставить(5, "Пт");
    СоответствиеДней.Вставить(6, "Сб");
    СоответствиеДней.Вставить(7, "Вс");
    
    Возврат СоответствиеДней.Получить(Номер);
    
КонецФункции

// Позвращает реквизиты по ссылке.
// 
// Параметры:
//  Ссылка - ЛюбаяСсылка - ссылка на объект
//  Реквизиты - Строка - Реквизиты через запятую
//  ВыбратьРазрешенные - Булево -  Выбрать разрешенные
// 
// Возвращаемое значение:
//  Булево, Структура -  Значения реквизитов объекта
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

// Значение реквизита объекта.
// 
// Параметры:
//  Ссылка - ЛюбаяСсылка - Ссылка на объект
//  ИмяРеквизита - Строка - Имя реквизита
//  ВыбратьРазрешенные - Булево -  Выбрать разрешенные
// 
// Возвращаемое значение:
//  Произвольный - Значение реквизита
Функция ЗначениеРеквизитаОбъекта(Ссылка, ИмяРеквизита, ВыбратьРазрешенные = Ложь) Экспорт
    
    Если ПустаяСтрока(ИмяРеквизита) Тогда 
        ВызватьИсключение 
            НСтр("ru = 'Неверный второй параметр ИмяРеквизита в функции ОбщегоНазначения.ЗначениеРеквизитаОбъекта: 
                       |- Имя реквизита должно быть заполнено'");
    КонецЕсли;
    
    Результат = ЗначенияРеквизитовОбъекта(Ссылка, ИмяРеквизита, ВыбратьРазрешенные);
    Возврат Результат[СтрЗаменить(ИмяРеквизита, ".", "")];
    
КонецФункции 

// Универсальная пауза
// 
// Параметры:
//  Секунды - Число - Число секунд
Процедура Ожидание(Знач Секунды) Экспорт

    Если Секунды <> 0 Тогда

		ПустойIP = "127" + ".0.0.0";
        НастройкиProxy = Новый ИнтернетПрокси(Ложь);
        НастройкиProxy.НеИспользоватьПроксиДляЛокальныхАдресов = Истина;
        НастройкиProxy.НеИспользоватьПроксиДляАдресов.Добавить(ПустойIP);

        Попытка
            СоединениеHTTP = Новый HTTPСоединение(ПустойIP, , , , НастройкиProxy, Секунды);
            СоединениеHTTP.Получить(Новый HTTPЗапрос());
        Исключение
            Возврат;
        КонецПопытки;

    КонецЕсли;
 
КонецПроцедуры

// Выполнить фоном.
// 
// Параметры:
//  Метод - Строка - Вызваемый метод
//  МассивПараметров - Массив Из Произвольный - Массив параметров для вызова метода
Процедура ВыполнитьФоном(Знач Метод, Знач МассивПараметров) Экспорт
	
	Ключ = Строка(Новый УникальныйИдентификатор);
	ФоновыеЗадания.Выполнить(Метод, МассивПараметров, Ключ);
	
КонецПроцедуры

// Заменяет U-коды \uXXXX в символы (Unicode escape)
// 
// Параметры:
//  ИсходнаяСтрока - Строка - Исходная строка
// 
// Возвращаемое значение:
//  Строка -  Обработанная строка
Функция UnicodeEscape(Знач ИсходнаяСтрока) Экспорт
	
	ИсходнаяСтрока	   = СтрЗаменить(ИсходнаяСтрока, "\u", "###");
	МассивСтроки       = СтрРазделить(ИсходнаяСтрока, "###", Ложь);
	Первый		       = Истина;
	ОбработаннаяСтрока = "";
	ДлинаКода          = 4;
	
	Для Каждого ЭлементСтроки Из МассивСтроки Цикл
		
		Если Первый Тогда
			Первый = Ложь;
			Продолжить;
		КонецЕсли;
		
		ТекущийЭлемент = ЭлементСтроки;
		Символов	   = СтрДлина(ТекущийЭлемент);
		НачалоСтроки   = Лев(ТекущийЭлемент, 4);
		НомерСимвола   = ПереводВДесятичнуюСистему(вРег(НачалоСтроки), 16);
		ТекущийЭлемент = Прав(ТекущийЭлемент, Символов - ДлинаКода);
		ТекущийЭлемент = Символ(НомерСимвола) + ТекущийЭлемент;
		ОбработаннаяСтрока = ОбработаннаяСтрока + ТекущийЭлемент;
		
	КонецЦикла;
	
	Возврат ОбработаннаяСтрока;
	
КонецФункции

// Перевод числа в десятичную сиситему.
// 
// Параметры:
//  Значение - Строка -  Значение
//  Основание - Число -  Основание
// 
// Возвращаемое значение:
//  Число -  Число в десятичной
Функция ПереводВДесятичнуюСистему(Знач Значение, Знач Основание) Экспорт
	
 Результат = 0;
 Длина     = СтрДлина(Значение);
 
 Для ТекущийСимвол = 1 По СтрДлина(Значение) Цикл
	 
	 Множитель = 1;
	 
	 Для Счет = 1 По Длина - ТекущийСимвол Цикл 
		 Множитель = Множитель * Основание;
	 КонецЦикла;
	 
	 Результат = Результат 
	   + (СтрНайти("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", Сред(Значение, ТекущийСимвол, 1)) - 1) 
	   * Множитель;
	 
 КонецЦикла;
 
 Возврат Окр(Результат);
 
КонецФункции

// HMACSHA256.
// 
// Параметры:
//  Ключ - Строка - Ключ
//  Данные - ДвоичныеДанные - Данные
// 
// Возвращаемое значение:
//  Число, ДвоичныеДанные -  HMACSHA256
Функция HMACSHA256(Знач Ключ, Знач Данные) Экспорт
	
	Возврат HMAC(Ключ, Данные, ХешФункция.SHA256, 64);
	
КонецФункции

Функция СтрокаВДвоичныеДанные(Знач Значение) Экспорт
	
	ИВФ = ПолучитьИмяВременногоФайла("txt");
	ТД	= Новый ТекстовыйДокумент;
	ТД.УстановитьТекст(Значение);
	ТД.Записать(ИВФ);
	
	ДД = Новый ДвоичныеДанные(ИВФ);
	УдалитьФайлы(ИВФ);
	
	Возврат ДД;
	
КонецФункции

Функция ДвоичныеДанныеВСтроку(Знач Значение) Экспорт
	
	ИВФ = ПолучитьИмяВременногоФайла("txt");
	Значение.Записать(ИВФ);
	
	Текст = Новый ЧтениеТекста(ИВФ);
	Результат = Текст.Прочитать();
	Текст.Закрыть();
	
	УдалитьФайлы(ИВФ);
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция Хеш(ДвоичныеДанные, Тип)
	
	Хеширование = Новый ХешированиеДанных(Тип);
	Хеширование.Добавить(ДвоичныеДанные);
	
	Возврат Хеширование.ХешСумма;
		
КонецФункции

Функция HMAC(Знач Ключ, Знач Данные, Тип, РазмерБлока)
	
	Если Ключ.Размер() > РазмерБлока Тогда
		Ключ = Хеш(Ключ, Тип);
	КонецЕсли;
	
	Если Ключ.Размер() <= РазмерБлока Тогда
		Ключ = ПолучитьHexСтрокуИзДвоичныхДанных(Ключ);
		Ключ = Лев(Ключ + ПовторитьСтроку("00", РазмерБлока), РазмерБлока * 2);
	КонецЕсли;
	
	Ключ = ПолучитьБуферДвоичныхДанныхИзДвоичныхДанных(ПолучитьДвоичныеДанныеИзHexСтроки(Ключ));
	
	ipad = ПолучитьБуферДвоичныхДанныхИзHexСтроки(ПовторитьСтроку("36", РазмерБлока));
	opad = ПолучитьБуферДвоичныхДанныхИзHexСтроки(ПовторитьСтроку("5c", РазмерБлока));
	
	ipad.ЗаписатьПобитовоеИсключительноеИли(0, Ключ);
	ikeypad = ПолучитьДвоичныеДанныеИзБуфераДвоичныхДанных(ipad);
	
	opad.ЗаписатьПобитовоеИсключительноеИли(0, Ключ);
	okeypad = ПолучитьДвоичныеДанныеИзБуфераДвоичныхДанных(opad);
	
	Возврат Хеш(СклеитьДвоичныеДанные(okeypad, Хеш(СклеитьДвоичныеДанные(ikeypad, Данные), Тип)), Тип);
	
КонецФункции

Функция СклеитьДвоичныеДанные(ДвоичныеДанные1, ДвоичныеДанные2)
	
	МассивДвоичныхДанных = Новый Массив;
	МассивДвоичныхДанных.Добавить(ДвоичныеДанные1);
	МассивДвоичныхДанных.Добавить(ДвоичныеДанные2);
	
	Возврат СоединитьДвоичныеДанные(МассивДвоичныхДанных);
	
КонецФункции

Функция ПовторитьСтроку(Строка, Количество)
	
	Части = Новый Массив(Количество);
	Для к = 1 По Количество Цикл
		Части.Добавить(Строка);
	КонецЦикла;
	
	Возврат СтрСоединить(Части, "");
	
КонецФункции

#КонецОбласти