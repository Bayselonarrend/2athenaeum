#Область ПрограммныйИнтерфейс

// Выполнение регламентных заданий по расписанию из спр. Расписание
Процедура ВыполнениеПоРасписанию() Экспорт
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    Расписание.Часы КАК Часы,
        |    Расписание.Минуты КАК Минуты,
        |    Расписание.Ссылка КАК Ссылка,
        |    Расписание.Метод КАК Метод,
        |    Расписание.Сообщество КАК Сообщество
        |ИЗ
        |    Справочник.Расписание КАК Расписание
        |        ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ВыполнениеРасписания КАК ВыполнениеРасписания
        |        ПО (ВыполнениеРасписания.Пункт = Расписание.Ссылка)
        |        И (НАЧАЛОПЕРИОДА(ДОБАВИТЬКДАТЕ(ВыполнениеРасписания.ПоследнееВыполнение, ДЕНЬ, Расписание.Периодичность),
        |            ДЕНЬ) <= НАЧАЛОПЕРИОДА(&ТекущаяДата, ДЕНЬ))
        |        И (НАЧАЛОПЕРИОДА(ВыполнениеРасписания.ПоследнееВыполнение, ДЕНЬ) <> НАЧАЛОПЕРИОДА(&ТекущаяДата, ДЕНЬ))
        |ГДЕ
        |    НЕ Расписание.ПометкаУдаления";
    
    ТД = ТекущаяДатаСеанса();

    Запрос.УстановитьПараметр("ТекущаяДата", ТД);
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи   = РезультатЗапроса.Выбрать();
    Метод                    = "";
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        
        Час         = Час(ТД);
        Минута      = Минута(ТД);
        КВыполнению = Час > ВыборкаДетальныеЗаписи.Часы Или 
            (Час = ВыборкаДетальныеЗаписи.Часы И Минута >= ВыборкаДетальныеЗаписи.Минуты);
        
        Если КВыполнению Тогда 

            Метод   = ВыборкаДетальныеЗаписи.Метод;
            Часы    = ВыборкаДетальныеЗаписи.Часы;
            Минуты  = ВыборкаДетальныеЗаписи.Минуты;
            Ссылка  = ВыборкаДетальныеЗаписи.Ссылка;
            Прервать;
            
        КонецЕсли;
        
    КонецЦикла;
    
    Если ЗначениеЗаполнено(Метод) Тогда
            
        ВызватьМетодПоИмени(Метод);
        
        ЕдиницаВремени = 60;
        
        МЗ = РегистрыСведений.ВыполнениеРасписания.СоздатьМенеджерЗаписи();
        МЗ.Пункт                 = Ссылка;
        МЗ.ПоследнееВыполнение   = НачалоДня(ТД) + (Часы * ЕдиницаВремени * ЕдиницаВремени) + (Минуты * ЕдиницаВремени);
        МЗ.Записать(Истина);
        
    КонецЕсли;
        
КонецПроцедуры

// Получить статистику по сообществам 
Процедура ПолучитьСтатистику() Экспорт
    
    ЕдиницаВремени  = 60;
    ЧасовВСутках    = 24;
    ВчерашнийДень   = ТекущаяДатаСеанса() - ЕдиницаВремени * ЕдиницаВремени * ЧасовВСутках;    
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
    "ВЫБРАТЬ
    |    Сообщества.Ссылка КАК Сообщество
    |ИЗ
    |    Справочник.Сообщества КАК Сообщества
    |ГДЕ
    |    Сообщества.СобиратьСтатистику";
    
    РезультатЗапроса       = Запрос.Выполнить();
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        
        //@skip-check query-in-loop
        МетодыРаботыVK.ПолучитьСтатистикуПостов(ВыборкаДетальныеЗаписи.Сообщество, ВернутьМассивНомеровПостов(500));
        
        Статистика = МетодыРаботыVK.ПолучитьСтатистику(ВыборкаДетальныеЗаписи.Сообщество
            , НачалоДня(ВчерашнийДень)
            , КонецДня(ВчерашнийДень)).Получить("response");
                
        Если ЗначениеЗаполнено(Статистика) Тогда
            
            ЗаписатьСтруктуруСтатистики(Статистика, ВыборкаДетальныеЗаписи.Сообщество);
            
        КонецЕсли;
        
    КонецЦикла;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура Запостить(Сообщество, УровеньПоста)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|    ДокументПост.Ссылка КАК Ссылка,
	|    ДокументПост.ПометкаУдаления КАК ПометкаУдаления,
	|    ДокументПост.Номер КАК Номер,
	|    ВЫБОР
	|        КОГДА ПорядокПостов.Опубликован = ЛОЖЬ
	|            ТОГДА ПорядокПостов.Дата
	|        ИНАЧЕ ПорядокПостов.ДатаПубликации
	|    КОНЕЦ КАК Период,
	|    ДокументПост.Проведен КАК Проведен,
	|    ДокументПост.Содержание КАК Содержание,
	|    ДокументПост.Картинка КАК Картинка,
	|    ДокументПост.МоментВремени КАК МоментВремени,
	|    ВЫБОР
	|        КОГДА ЕСТЬNULL(ДокументПост.Содержание.Автор, НЕОПРЕДЕЛЕНО) = НЕОПРЕДЕЛЕНО
	|            ТОГДА ВЫБОР
	|                КОГДА ДокументПост.Содержание.ПроизведениеАвтор ССЫЛКА Справочник.Произведения
	|                    ТОГДА ДокументПост.Содержание.ПроизведениеАвтор.Автор
	|                ИНАЧЕ ВЫБОР
	|                    КОГДА ДокументПост.Содержание ССЫЛКА Справочник.Колонки
	|                        ТОГДА ДокументПост.Содержание.Наименование
	|                    ИНАЧЕ ДокументПост.Содержание.ПроизведениеАвтор
	|                КОНЕЦ
	|            КОНЕЦ
	|        ИНАЧЕ ДокументПост.Содержание.Автор
	|    КОНЕЦ КАК Автор,
	|    ВЫБОР
	|        КОГДА ЕСТЬNULL(ДокументПост.Содержание.Автор, НЕОПРЕДЕЛЕНО) = НЕОПРЕДЕЛЕНО
	|            ТОГДА ВЫБОР
	|                КОГДА ДокументПост.Содержание.ПроизведениеАвтор ССЫЛКА Справочник.Произведения
	|                    ТОГДА ""Отрывок""
	|                ИНАЧЕ ВЫБОР
	|                    КОГДА ДокументПост.Содержание ССЫЛКА Справочник.Колонки
	|                        ТОГДА ""Колонка""
	|                    ИНАЧЕ ""Цитата""
	|                КОНЕЦ
	|            КОНЕЦ
	|        ИНАЧЕ ""Произведение""
	|    КОНЕЦ КАК Вид,
	|    ЕСТЬNULL(ДокументПост.Содержание.ПроизведениеАвтор, ДокументПост.Содержание.Наименование) КАК Источник,
	|    ПорядокПостов.Опубликован КАК Опубликован,
	|    ДокументПост.Сообщество.Статус КАК СообществоСтатус,
	|    ДокументПост.Уровень КАК Уровень,
	|    ДокументПост.Сообщество КАК Сообщество,
	|    ДокументПост.Сообщество.СсылкаVK КАК СсылкаVK
	|ПОМЕСТИТЬ Основной
	|ИЗ
	|    РегистрСведений.ПорядокПостов КАК ПорядокПостов
	|        ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Пост КАК ДокументПост
	|        ПО ПорядокПостов.Пост = ДокументПост.Ссылка
	|ГДЕ
	|    ДокументПост.Проведен = ИСТИНА
	|    И ДокументПост.Сообщество = &Сообщество
	|    И (ДокументПост.Уровень = &Уровень
	|    ИЛИ ДокументПост.Уровень = ЗНАЧЕНИЕ(Перечисление.УровниПостов.Любой))
	|
	|УПОРЯДОЧИТЬ ПО
	|    Опубликован,
	|    Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    Основной.Ссылка КАК Ссылка,
	|    Основной.ПометкаУдаления КАК ПометкаУдаления,
	|    Основной.Номер КАК Номер,
	|    Основной.Период КАК Период,
	|    Основной.Проведен КАК Проведен,
	|    Основной.Содержание КАК Содержание,
	|    Основной.Картинка КАК Картинка,
	|    Основной.МоментВремени КАК МоментВремени,
	|    Основной.Автор КАК Автор,
	|    Основной.Вид КАК Вид,
	|    Основной.Источник КАК Источник,
	|    Основной.Опубликован КАК Опубликован,
	|    Основной.Уровень КАК Уровень,
	|    Основной.Сообщество КАК Сообщество,
	|    Основной.СсылкаVK КАК СсылкаVK
	|ИЗ
	|    Основной КАК Основной
	|ГДЕ
	|    ВЫБОР Основной.СообществоСтатус
	|        КОГДА ЗНАЧЕНИЕ(Перечисление.СтатусыСообществ.Автономно)
	|            ТОГДА ИСТИНА
	|        КОГДА ЗНАЧЕНИЕ(Перечисление.СтатусыСообществ.Ведется)
	|            ТОГДА Основной.Опубликован = ЛОЖЬ
	|        ИНАЧЕ ЛОЖЬ
	|    КОНЕЦ";
	
	Запрос.УстановитьПараметр("Сообщество", Сообщество);
	Запрос.УстановитьПараметр("Уровень"   , УровеньПоста);
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		
		Содержание 	= ВыборкаДетальныеЗаписи.Содержание;
		Ссылка		= ВыборкаДетальныеЗаписи.Ссылка;
		Автор		= ВыборкаДетальныеЗаписи.Автор;
		Вид			= ВыборкаДетальныеЗаписи.Вид;
		Период		= ВыборкаДетальныеЗаписи.Период;
		СсылкаВК	= ВыборкаДетальныеЗаписи.СсылкаVK;
		
		Если ТипЗнч(Содержание) = Тип("СправочникСсылка.Сложнопост") Тогда
			СсылкаФормирования = Содержание;	
		Иначе
			СсылкаФормирования = Ссылка;
		КонецЕсли;
			
		МетодыФормированияПостов.СформироватьПост(СсылкаФормирования);
		
		Запись = РегистрыСведений.ПорядокПостов.СоздатьМенеджерЗаписи();
		Запись.Автор            = Автор;
		Запись.Пост             = Ссылка;
		Запись.Вид              = Вид;
		Запись.ДатаПубликации   = ТекущаяДатаСеанса();
		Запись.Опубликован      = Истина;
		Запись.Период           = Период;
		Запись.Записать(Истина);  
		
		Если ВыборкаДетальныеЗаписи.Уровень = Перечисления.УровниПостов.I  Тогда
			
			ДД = Ссылка.КартинкаДвоичные.Получить();		
			СоздатьИсторию(Содержание, Сообщество, СсылкаВК, ДД);	
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ВызватьМетодПоИмени(Метод)

    Если Метод = "Автопостинг()" Тогда
        Автопостинг();
    ИначеЕсли Метод = "АвтопостингУтро()" Тогда
        АвтопостингУтро();
    ИначеЕсли Метод = "АвтопостингОбед()" Тогда
        АвтопостингОбед();
	ИначеЕсли Метод = "АвтопостингНочь()" Тогда
		АвтопостингНочь();
    ИначеЕсли Метод = "ПостДняРождения()" Тогда
        ПостДняРождения();
    ИначеЕсли Метод = "СоздатьОпросПоПисателям()" Тогда
        СоздатьОпросПоПисателям();
    ИначеЕсли Метод = "РегулярныйПостинг()" Тогда
        РегулярныйПостинг();
    ИначеЕсли Метод = "ПостКнигДекады()" Тогда
        ПостКнигДекады();
    ИначеЕсли Метод = "ПостРекламыКниги()" Тогда
        ПостРекламыКниги();
    Иначе
        Возврат;
    КонецЕсли;
    
КонецПроцедуры

Процедура ЗаписатьСтруктуруСтатистики(Знач Статистика, Знач Сообщество)

    ОТЧ = Новый ОписаниеТипов("Число");
    
    Для Каждого ДеньСтатистики Из Статистика Цикл

        МЗ                = РегистрыСведений.Статистика.СоздатьМенеджерЗаписи();
        МЗ.Сообщество     = Сообщество;
        МЗ.Период         = Дата(1970, 1, 1, 1, 0, 0) + ДеньСтатистики["period_to"];

        Если МЗ.Период > ТекущаяДатаСеанса() Тогда
            Продолжить;
        КонецЕсли;

        Если ДеньСтатистики.Получить("visitors") <> Неопределено Тогда

            Посетители     = ДеньСтатистики["visitors"];
            МЗ.Посетителей = ОТЧ.ПривестиЗначение(Посетители.Получить("visitors"));
            МЗ.Просмотров  = ОТЧ.ПривестиЗначение(Посетители.Получить("views"));

        КонецЕсли;

        Если ДеньСтатистики.Получить("reach") <> Неопределено Тогда

            Охват = ДеньСтатистики["reach"];
            МЗ.Охват                = ОТЧ.ПривестиЗначение(Охват.Получить("reach"));
            МЗ.ОхватПодписчиков     = ОТЧ.ПривестиЗначение(Охват.Получить("reach_subscribers"));

        КонецЕсли;

        Если ДеньСтатистики.Получить("activity") <> Неопределено Тогда

            Активность = ДеньСтатистики["activity"];
            МЗ.Комментарии    = ОТЧ.ПривестиЗначение(Активность.Получить("comments"));
            МЗ.Репосты        = ОТЧ.ПривестиЗначение(Активность.Получить("copies"));
            МЗ.Скрытия        = ОТЧ.ПривестиЗначение(Активность.Получить("hidden"));
            МЗ.Лайки          = ОТЧ.ПривестиЗначение(Активность.Получить("likes"));
            МЗ.Подписки       = ОТЧ.ПривестиЗначение(Активность.Получить("subscribed"));
            МЗ.Отписки        = ОТЧ.ПривестиЗначение(Активность.Получить("unsubscribed "));

        КонецЕсли;

        Если ЗначениеЗаполнено(МЗ.Охват) Тогда
            МЗ.Записать(Истина);
        КонецЕсли;

    КонецЦикла;
    
КонецПроцедуры

Процедура Автопостинг()
    
	АвтопостингПоКоличеству(1, Перечисления.УровниПостов.I);
    
КонецПроцедуры

Процедура АвтопостингУтро()
    
    Если ПолучитьДеньРождения().Пустой() Тогда
    	АвтопостингПоКоличеству(4, Перечисления.УровниПостов.IV);
    КонецЕсли;
    
КонецПроцедуры

Процедура АвтопостингОбед()
    
	АвтопостингПоКоличеству(2, Перечисления.УровниПостов.II);
	
КонецПроцедуры

Процедура АвтопостингНочь()
	
	АвтопостингПоКоличеству(3, Перечисления.УровниПостов.III);
	
КонецПроцедуры

Процедура АвтопостингПоКоличеству(Знач ПостовВДень, Знач Уровень)
	
	Попытка
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|    Сообщества.Ссылка КАК Ссылка
		|ИЗ
		|    Справочник.Сообщества КАК Сообщества
		|ГДЕ
		|    Сообщества.ПостовВДень >= &Количество";
		
		Запрос.УстановитьПараметр("Количество", ПостовВДень);
		РезультатЗапроса  = Запрос.Выполнить();  
		ВыборкаСообщество = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаСообщество.Следующий() Цикл
			//@skip-check query-in-loop
			Запостить(ВыборкаСообщество.Ссылка, Уровень);
		КонецЦикла;    
		
	Исключение
		ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());    
	КонецПопытки;

КонецПроцедуры

Процедура ПостКнигДекады()
    
    ТекущаяДата     = КонецДня(ТекущаяДатаСеанса());
    ПерваяДекада    = 10;
    ВтораяДекада    = 20;
    
    Если День(ТекущаяДата) = ПерваяДекада Тогда
        СтрокаДаты = "Первая декада, ";
    ИначеЕсли День(ТекущаяДата) = ВтораяДекада Тогда
        СтрокаДаты = "Вторая декада, ";
    ИначеЕсли ТекущаяДата = КонецМесяца(ТекущаяДатаСеанса()) Тогда
        СтрокаДаты = "Третья декада, ";
    Иначе 
        Возврат;
    КонецЕсли;
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
    "ВЫБРАТЬ
    |    МАКСИМУМ(Произведения.ПорядковыйНомер) КАК ПорядковыйНомер
    |ИЗ
    |    Справочник.Произведения КАК Произведения
    |ГДЕ
    |    Произведения.НаСайте = ИСТИНА";
    
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Если ВыборкаДетальныеЗаписи.Следующий() Тогда
        МаксимальноеЧисло = ВыборкаДетальныеЗаписи.ПорядковыйНомер;
    Иначе
        Возврат;
    КонецЕсли;
    
    ГСЧ                    = Новый ГенераторСлучайныхЧисел();
    МассивСлучайныхЧисел   = Новый Массив;
    
    Для Н = 1 По 4 Цикл
        
        ТекущееЧисло = ГСЧ.СлучайноеЧисло(1, МаксимальноеЧисло);
        
        Пока МассивСлучайныхЧисел.Найти(ТекущееЧисло) <> Неопределено Цикл
            ТекущееЧисло = ГСЧ.СлучайноеЧисло(1, МаксимальноеЧисло);
        КонецЦикла;
        
        МассивСлучайныхЧисел.Добавить(ТекущееЧисло);
        
    КонецЦикла;
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
    "ВЫБРАТЬ 
    |    Произведения.Код КАК Код,
    |    Произведения.Наименование КАК Книга,
    |    Произведения.Автор.Представление КАК Автор
    |ИЗ
    |    Справочник.Произведения КАК Произведения
    |ГДЕ
    |    Произведения.ПорядковыйНомер В(&МассивСлучайныхЧисел)
    |    И Произведения.НеИспользоватьВПодборках = ЛОЖЬ";
    
    Запрос.УстановитьПараметр("МассивСлучайныхЧисел", МассивСлучайныхЧисел);
    
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
        
    ПрямаяЧерта = "|";
    ТекстПоста = "Новая подборка произведений!"
    + Символы.ПС
    + Символы.ПС
    + "Спешим напомнить вам, что познакомиться с классикой мировой литературы в нашем сообществе можно не только "
    + "через отрывки и цитаты! В [" 
    + "https://vk.com/@aioniotis-biblioteka-two-digit-athenaeum"
    + ПрямаяЧерта
    + "библиотеке Two-Digit Athenaeum] всегда найдутся интересные и увлекательные произведения на любой вкус. "
    + "Вот некоторые из них:"
    + Символы.ПС
    + Символы.ПС;
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        
        ТекстПоста = ТекстПоста 
        + ВыборкаДетальныеЗаписи.Код
        + " - "
        + ВыборкаДетальныеЗаписи.Автор
        + " «"
        + ВыборкаДетальныеЗаписи.Книга
        + "» "
        + Символы.ПС
        + "Ссылка - "
        + "https://athenaeum.digital/book?id=" + ВыборкаДетальныеЗаписи.Код
        + Символы.ПС 
        + Символы.ПС;
        
    КонецЦикла;
    
    ТекстПоста = ТекстПоста 
    + "P.S. Если у вас возникли проблемы при использовании библиотеки или появились интересные предложения - "
    + "обязательно напишите об этом в одном из наших обсуждений (либо в комментарии под этой записью) "
    + "Спасибо за ваш вклад!";     
    
    СоответствиеМесяцев = Новый Соответствие;
    СоответствиеМесяцев.Вставить(1    , "I");
    СоответствиеМесяцев.Вставить(2    , "II");
    СоответствиеМесяцев.Вставить(3    , "III");
    СоответствиеМесяцев.Вставить(4    , "IV");
    СоответствиеМесяцев.Вставить(5    , "V");
    СоответствиеМесяцев.Вставить(6    , "VI");
    СоответствиеМесяцев.Вставить(7    , "VII");
    СоответствиеМесяцев.Вставить(8    , "VIII");
    СоответствиеМесяцев.Вставить(9    , "IX");
    СоответствиеМесяцев.Вставить(10   , "X");
    СоответствиеМесяцев.Вставить(11   , "XI");
    СоответствиеМесяцев.Вставить(12   , "XII");
    
    СтрокаДаты     = СтрокаДаты + СоответствиеМесяцев.Получить(Месяц(ТекущаяДата)) + "/" + Строка(Год(ТекущаяДата));
    ДД             = Справочники.Файлы.КнигиДекады.ПолучитьОбъект().Файл.Получить();
    
    ИВФ = ПолучитьИмяВременногоФайла("png");
    ДД.Записать(ИВФ);
    
    ИмяСкрипта     = ПолучитьИмяВременногоФайла(".ps1");
    ТекстСкрипта   = Новый ТекстовыйДокумент();
    ТекстСкрипта.УстановитьТекст(
    "magick """ 
    + ИВФ  
    + """ -pointsize 48 -fill white  -annotate +762+468 '"
    + СтрокаДаты
    + "' """
    + ИВФ
    + """");
    
    ТекстСкрипта.Записать(ИмяСкрипта, КодировкаТекста.UTF8);
    
    КодВозврата = 0;
    ЗапуститьПриложение("powershell -file " + ИмяСкрипта + " -noexit", , Истина, КодВозврата);
    
    СтруктураЗаписи = Новый Структура;
    СтруктураЗаписи.Вставить("Текст"        , ТекстПоста);
    СтруктураЗаписи.Вставить("Картинка"     , ИВФ);
    СтруктураЗаписи.Вставить("Сообщество"   , Справочники.Сообщества.Athenaeum);
    
    МетодыФормированияПостов.СформироватьПост(СтруктураЗаписи, Истина, Перечисления.СоцСети.VK);
    
    ТекстПоста = СтрЗаменить(ТекстПоста, "[", "");
    ТекстПоста = СтрЗаменить(ТекстПоста, "|", " ");
    ТекстПоста = СтрЗаменить(ТекстПоста, "]", "");
    ТекстПоста = СтрЗаменить(ТекстПоста
        , "https://vk.com/@aioniotis-biblioteka-two-digit-athenaeum"
        , "");
    
    СтруктураЗаписи.Вставить("Текст", ТекстПоста);
    МетодыФормированияПостов.СформироватьПост(СтруктураЗаписи, Истина, Перечисления.СоцСети.Telegram);
    
    УдалитьФайлы(ИВФ);
    УдалитьФайлы(ИмяСкрипта);
    
КонецПроцедуры

Процедура ПостДняРождения()
    
	РезультатЗапроса       = ПолучитьДеньРождения();
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Если ВыборкаДетальныеЗаписи.Следующий() Тогда
        
        КартинкаДД  = МетодыОбработкиИзображений.СформироватьКартинкуДняРождения(ВыборкаДетальныеЗаписи.Ссылка);
        
        Текст = Формат(ВыборкаДетальныеЗаписи.ДР, "ДЛФ=DD") 
        + " родился " 
        + ВыборкаДетальныеЗаписи.Имя 
        + " " 
        + ВыборкаДетальныеЗаписи.Фамилия 
        + " - " 
        + ВыборкаДетальныеЗаписи.КраткоеОписание
        + Символы.ПС
        + Символы.ПС
        + ВыборкаДетальныеЗаписи.РасширенноеОписание;
        
        СтруктураЗаписи = Новый Структура;
        СтруктураЗаписи.Вставить("Текст"     , Текст);
        СтруктураЗаписи.Вставить("Картинка"  , КартинкаДД);
        СтруктураЗаписи.Вставить("Сообщество", ВыборкаДетальныеЗаписи.ОсновноеСообщество);
    
        МетодыФормированияПостов.СформироватьПост(СтруктураЗаписи);
        
    КонецЕсли;
        
КонецПроцедуры 

Процедура ПостРекламыКниги()
    
    Попытка
    
    МаксимальнаяДлинаНазвания = 19;    
    Запрос = Новый Запрос(
        "ВЫБРАТЬ
        |    Произведения.Ссылка КАК Ссылка,
        |    Произведения.Наименование КАК Наименование
        |ИЗ
        |    Справочник.Произведения КАК Произведения
        |ГДЕ
        |    Произведения.НаСайте = ИСТИНА
        |    И Произведения.НеИспользоватьВПодборках = ЛОЖЬ");
    
    Выборка     = Запрос.Выполнить().Выбрать();
    МассивКниг  = Новый Массив;
    
    Пока Выборка.Следующий() Цикл
        
        Если СтрДлина(Выборка.Наименование) < МаксимальнаяДлинаНазвания Тогда
            МассивКниг.Добавить(Выборка.Ссылка);
        КонецЕсли;
        
    КонецЦикла;
    
    ГСЧ             = Новый ГенераторСлучайныхЧисел;
    СлучайноеЧисло  = ГСЧ.СлучайноеЧисло(0, МассивКниг.ВГраница());
    СлучайнаяКнига  = МассивКниг[СлучайноеЧисло];
    
    Текст = "«"
        + СлучайнаяКнига.Наименование
        + "», "
        + СлучайнаяКнига.Автор.Имя
        + " "
        + СлучайнаяКнига.Автор.Фамилия
        + Символы.ПС
        + Символы.ПС
        + СлучайнаяКнига.Описание
        + Символы.ПС
        + Символы.ПС
        + "А познакомится с полным текстом данного произведения в нашей библиотеке - проще простого! Отправьте код "
        + СлучайнаяКнига.Код
        + " нашему боту в ВК или Telegram. Он отправит вам начало книги, а переключаться между страницами можно при "
        + "помощи кнопок <- и -> под полем сообщения!"
        + Символы.ПС
        + Символы.ПС
        + "ВКонтакте: https://vk.me/aioniotis"
        + Символы.ПС
        + "Telegram: https://t.me/AioniotisBot"
        + Символы.ПС
        + "Другие книги: https://athenaeum.digital";
        
    КартинкаДД          = МетодыОбработкиИзображений.СформироватьРекламуКниги(СлучайнаяКнига);
	
	СтруктураЗаписи = Новый Структура;
    СтруктураЗаписи.Вставить("Картинка"     , КартинкаДД);    
    СтруктураЗаписи.Вставить("Текст"        , Текст);
    СтруктураЗаписи.Вставить("Линк"         , "https://vk.me/aioniotis");
    СтруктураЗаписи.Вставить("Сообщество"   , Справочники.Сообщества.Athenaeum);
    
    МетодыФормированияПостов.СформироватьПост(СтруктураЗаписи, Истина);
    
    Исключение
        ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
    КонецПопытки;
    
КонецПроцедуры

Процедура СоздатьОпросПоПисателям()
    
    ГСЧ                     = Новый ГенераторСлучайныхЧисел();
    СоответствиеВеков       = Новый Соответствие;
    СоответствиеВеков.Вставить(19, "XIX");
    СоответствиеВеков.Вставить(20, "XX");
    
    Век = СоответствиеВеков.Получить(ГСЧ.СлучайноеЧисло(19, 20));
        
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Люди.Ссылка) КАК Ссылка
        |ИЗ
        |    Справочник.Люди КАК Люди
        |ГДЕ
        |    Люди.ВидАвтора = ЗНАЧЕНИЕ(Перечисление.ВидыАвторов.Писатель)
        |    И Люди.Век = &Век";
    
    Запрос.УстановитьПараметр("Век", Век);
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Если ВыборкаДетальныеЗаписи.Следующий() Тогда
        МаксимальноеЧисло = ВыборкаДетальныеЗаписи.Ссылка - 1;
    КонецЕсли;    
    
    МассивСлучайныхЧисел = Новый Массив;
    
    Для Н = 1 По 3 Цикл
        
        ТекущееЧисло = ГСЧ.СлучайноеЧисло(1, МаксимальноеЧисло);
        
        Пока МассивСлучайныхЧисел.Найти(ТекущееЧисло) <> Неопределено Цикл
            ТекущееЧисло = ГСЧ.СлучайноеЧисло(1, МаксимальноеЧисло);
        КонецЦикла;
        
        МассивСлучайныхЧисел.Добавить(ТекущееЧисло);
        
    КонецЦикла;
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    Люди.Имя КАК Имя,
        |    Люди.Фамилия КАК Фамилия,
        |    АВТОНОМЕРЗАПИСИ() КАК ПорядковыйНомер
        |ПОМЕСТИТЬ ВТ
        |ИЗ
        |    Справочник.Люди КАК Люди
        |ГДЕ
        |    Люди.ВидАвтора = ЗНАЧЕНИЕ(Перечисление.ВидыАвторов.Писатель)
        |    И Люди.Век = &Век
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |    ВТ.Имя КАК Имя,
        |    ВТ.Фамилия КАК Фамилия,
        |    ВТ.ПорядковыйНомер КАК ПорядковыйНомер
        |ИЗ
        |    ВТ КАК ВТ
        |ГДЕ
        |    ВТ.ПорядковыйНомер В(&МассивНомеров)";
    
    Запрос.УстановитьПараметр("Век"           , Век);
    Запрос.УстановитьПараметр("МассивНомеров" , МассивСлучайныхЧисел);
    
    РезультатЗапроса  = Запрос.Выполнить();
    МассивОтветов     = Новый Массив;
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Н = 1;
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        МассивОтветов.Добавить(Строка(Н) + ". " + ВыборкаДетальныеЗаписи.Имя + " " + ВыборкаДетальныеЗаписи.Фамилия);
        Н = Н + 1;
    КонецЦикла;
    
    ТекстВопроса = "Творчество какого писателя " + Век + " века вам более близко?";
    
    //@skip-check reading-attribute-from-database
    МетодыРаботыVK.СоздатьОпрос(Справочники.Сообщества.Athenaeum
        , ТекстВопроса
        , МассивОтветов
        , Справочники.Файлы.ОпросАтеней.Файл.Получить());
    
КонецПроцедуры

Процедура РегулярныйПостинг() 
    
    ТД               = ТекущаяДатаСеанса();
    День             = НачалоДня(ТД);
    ЕдиницаВремени   = 60;
    ЧасовВСутках     = 24;
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    РегулярныеПосты.Сообщество КАК Сообщество,
        |    РегулярныеПосты.Текст КАК Текст,
        |    РегулярныеПосты.Ссылка КАК Ссылка,
        |    РегулярныеПосты.Периодичность КАК Периодичность,
        |    РегулярныеПосты.ВК_ID КАК ВК_ID,
        |    РегулярныеПосты.ЭтоРеклама КАК ЭтоРеклама,
        |    ВЫБОР
        |        КОГДА РегулярныеПосты.ДатаУдаления = &День
        |            ТОГДА ИСТИНА
        |        ИНАЧЕ ЛОЖЬ
        |    КОНЕЦ КАК Удаление,
        |    РегулярныеПосты.ВремяЖизни КАК ВремяЖизни,
        |    РегулярныеПосты.ОсновнаяСсылка КАК ОсновнаяСсылка
        |ИЗ
        |    Справочник.РегулярныеПосты КАК РегулярныеПосты
        |ГДЕ
        |    (РегулярныеПосты.СледующаяПубликация = &День
        |            ИЛИ РегулярныеПосты.ДатаУдаления = &День)";
    
    Запрос.УстановитьПараметр("День", День);
    
    РезультатЗапроса = Запрос.Выполнить();

    ВыборкаДетальныеЗаписи    = РезультатЗапроса.Выбрать();
    СообществаПостинга        = Новый Соответствие;
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        
        ПостОбъект     = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
        
        Если Не ВыборкаДетальныеЗаписи.Удаление Тогда            
            Если СообществаПостинга.Получить(ВыборкаДетальныеЗаписи.Сообщество) = Неопределено Тогда
                
                Путь   = ПолучитьИмяВременногоФайла("png");    
                ДД     = ПостОбъект.КартинкаДвоичные.Получить();
                ДД.Записать(Путь);
                        
                СтруктураЗаписи = Новый Структура;
                СтруктураЗаписи.Вставить("Текст"        , ВыборкаДетальныеЗаписи.Текст);
                СтруктураЗаписи.Вставить("Картинка"     , Путь);
                СтруктураЗаписи.Вставить("Сообщество"   , ВыборкаДетальныеЗаписи.Сообщество);
                    
                Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ОсновнаяСсылка) Тогда
                    СтруктураЗаписи.Вставить("Ссылка"   , ВыборкаДетальныеЗаписи.ОсновнаяСсылка);
                КонецЕсли;
                
                ПостОбъект.ВК_ID = МетодыФормированияПостов.СформироватьПост(СтруктураЗаписи
                                                        , ВыборкаДетальныеЗаписи.ЭтоРеклама
                                                        , Перечисления.СоцСети.VK);
                
                ПостОбъект.СледующаяПубликация = НачалоДня(ТекущаяДатаСеанса()) 
                + (ЕдиницаВремени * ЕдиницаВремени * ЧасовВСутках * ВыборкаДетальныеЗаписи.Периодичность);
                
                ПостОбъект.ДатаУдаления =  НачалоДня(ТекущаяДатаСеанса())
                + (ЕдиницаВремени * ЕдиницаВремени * ЧасовВСутках * ВыборкаДетальныеЗаписи.ВремяЖизни);

                УдалитьФайлы(Путь);
                
                СообществаПостинга.Вставить(ВыборкаДетальныеЗаписи.Сообщество, 1);
                
            Иначе
                
                ПостОбъект.СледующаяПубликация = НачалоДня(ТекущаяДатаСеанса()) 
                + (ЕдиницаВремени * ЕдиницаВремени * ЧасовВСутках);
                
            КонецЕсли;
        Иначе
            
            ПостОбъект.ДатаУдаления = '00010101';
            
            Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ВК_ID) Тогда
                МетодыРаботыVK.УдалитьПост(ВыборкаДетальныеЗаписи.Сообщество, ВыборкаДетальныеЗаписи.ВК_ID);
            КонецЕсли;

        КонецЕсли;
        
        ПостОбъект.Записать();
        
    КонецЦикла;
    
КонецПроцедуры

Процедура СоздатьИсторию(Знач Содержание, Знач Сообщество, Знач СсылкаВК, Знач ДД)
		                 	
	Если Сообщество = ПредопределенноеЗначение("Справочник.Сообщества.Athenaeum") Тогда
		
		ТекстСодержания = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(
		Содержание
		, "Текст");
		
		КартинкаСТекстом = МетодыОбработкиИзображений.СформироватьИзображениеСТекстом(
		Содержание
		, ТекстСодержания
		, ВернутьАвтора(Содержание)
		, ДД
		, Истина);    
		
		Если ЗначениеЗаполнено(КартинкаСТекстом) Тогда    
			МетодыРаботыVK.СоздатьИсторию(Сообщество
			, КартинкаСТекстом
			, СсылкаВК);
		КонецЕсли;
		
	Иначе        
		МетодыРаботыVK.СоздатьИсторию(Сообщество
		, ДД
		, СсылкаВК);
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьДеньРождения()

    ТД       = ТекущаяДатаСеанса();
    День     = День(ТД);
    Месяц    = Месяц(ТД);
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
    "ВЫБРАТЬ ПЕРВЫЕ 1
    |    Люди.Ссылка КАК Ссылка,
    |    Люди.ОсновноеСообщество КАК ОсновноеСообщество,
    |    Люди.Имя КАК Имя,
    |    Люди.Фамилия КАК Фамилия,
    |    Люди.КраткоеОписание КАК КраткоеОписание,
    |    Люди.РасширенноеОписание КАК РасширенноеОписание,
    |    Люди.Фото КАК Фото,
    |    Люди.ДР КАК ДР
    |ИЗ
    |    Справочник.Люди КАК Люди
    |ГДЕ
    |    Люди.СоздаватьПостНаДр = ИСТИНА
    |    И ДЕНЬ(Люди.ДР) = &День
    |    И МЕСЯЦ(Люди.ДР) = &Месяц
    |
    |УПОРЯДОЧИТЬ ПО
    |    Ссылка";
    
    Запрос.УстановитьПараметр("День"    , День);
    Запрос.УстановитьПараметр("Месяц"   , Месяц);
    
    Возврат Запрос.Выполнить();
    	
КонецФункции

Функция ВернутьАвтора(Знач Содержание)
    
    ССП                = "СправочникСсылка.Произведения";
    ССЦ                = "СправочникСсылка.Цитаты";
    ССЛ                = "СправочникСсылка.Люди";

    Автор              = "";
    ПроизведениеАвтор  = Неопределено;
    
    Если ТипЗнч(Содержание) = Тип(ССЦ)
        Или ТипЗнч(Содержание) = Тип(ССП) Тогда
                
        Если ТипЗнч(Содержание) = Тип(ССЦ) Тогда
            
            ПроизведениеАвтор = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Содержание, "ПроизведениеАвтор");
            
            Если ТипЗнч(ПроизведениеАвтор) = Тип(ССП) Тогда
                
                СсылкаАвтор     = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПроизведениеАвтор, "Автор");
                РеквизитыАвтора = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(СсылкаАвтор, "Имя,Фамилия");        
                Автор           = РеквизитыАвтора.Имя + " " + РеквизитыАвтора.Фамилия;
                
            ИначеЕсли ТипЗнч(ПроизведениеАвтор) = Тип(ССЛ) Тогда
                
                РеквизитыАвтора = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(ПроизведениеАвтор
                    , "Имя,Фамилия");
                            
                Автор = РеквизитыАвтора.Имя + " " + РеквизитыАвтора.Фамилия;
                
            Иначе 
                
                Автор = "";
                
            КонецЕсли;
            
        ИначеЕсли ТипЗнч(Содержание) = Тип(ССП) Тогда
            
            СсылкаАвтор     = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Содержание, "Автор");
            РеквизитыАвтора = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(СсылкаАвтор, "Имя,Фамилия");
            
            Автор = РеквизитыАвтора.Имя + " " + РеквизитыАвтора.Фамилия;
            
        Иначе
            
            Автор = "";
            
        КонецЕсли;
        
    КонецЕсли;
    
    Возврат Автор;
    
КонецФункции

Функция ВернутьМассивНомеровПостов(Знач Дней) 
    
    ЕдиницаВремени  = 60;
    ЧасовВСутках    = 24;
	КрайняяДата		= НачалоДня(ТекущаяДатаСеанса()) - Дней * ЕдиницаВремени * ЕдиницаВремени * ЧасовВСутках;
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    ПорядокПостов.Пост КАК Пост,
        |    ПорядокПостов.Пост.ВК_НомерПоста КАК НомерПоста
        |ИЗ
        |    РегистрСведений.ПорядокПостов КАК ПорядокПостов
        |ГДЕ
        |    ПорядокПостов.Опубликован
        |    И ПорядокПостов.ДатаПубликации >= &КрайняяДата
        |    И ПорядокПостов.Пост.ВК_НомерПоста <> 0";
    
    Запрос.УстановитьПараметр("КрайняяДата", КрайняяДата);
    
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи  = РезультатЗапроса.Выбрать();
    МассивПостов            = Новый Массив;
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        
        МассивПостов.Добавить(ВыборкаДетальныеЗаписи.НомерПоста);
        
    КонецЦикла;
    
    Возврат МассивПостов;

КонецФункции

#КонецОбласти
