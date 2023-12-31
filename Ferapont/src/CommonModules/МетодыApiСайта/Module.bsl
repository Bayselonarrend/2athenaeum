#Область ПрограммныйИнтерфейс

// Возвращает пользователя активного сеанса по Cookie
// 
// Параметры:
//  Печенька - Строка - Печенька
// 
// Возвращаемое значение:
//  СправочникСсылка.Пользователи -  пользователь сеанса
Функция ВернутьПользователяПоCookie(Знач Печенька) Экспорт
	
	Если Печенька = "null" Тогда
		Возврат Справочники.Пользователи.ПустаяСсылка();
	КонецЕсли;
	
    Запрос = Новый Запрос;
    Запрос.Текст = 
    "ВЫБРАТЬ
    |    АктивныеСеансы.Пользователь КАК Пользователь
    |ИЗ
    |    РегистрСведений.АктивныеСеансы КАК АктивныеСеансы
    |ГДЕ
    |    АктивныеСеансы.Cookie = &Печенька";
    
    Запрос.УстановитьПараметр("Печенька", Печенька);
    
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Если ВыборкаДетальныеЗаписи.Следующий() Тогда
        Возврат ВыборкаДетальныеЗаписи.Пользователь;
    Иначе
        Возврат Справочники.Пользователи.ПустаяСсылка();
    КонецЕсли;
    
КонецФункции

// Получить общее число прочитанных слов пользователя.
// 
// Параметры:
//  Пользователь - СправочникСсылка.Пользователи - Пользователь
// 
// Возвращаемое значение:
//  Число -  общее число слов
Функция ПолучитьОбщееЧислоСлов(Знач Пользователь) Экспорт
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    СУММА(ВЫБОР
        |            КОГДА ЕСТЬNULL(ПотоковоеЧтение.Завершена, ЛОЖЬ)
        |                ТОГДА ЕСТЬNULL(ПотоковоеЧтение.Текст.Слов, 0)
        |            ИНАЧЕ ЕСТЬNULL(ПотоковоеЧтение.МаксимумСлов, 0)
        |        КОНЕЦ) КАК Слов
        |ИЗ
        |    РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
        |ГДЕ
        |    ПотоковоеЧтение.Пользователь = &Пользователь";
    
    Запрос.УстановитьПараметр("Пользователь", Пользователь);
    
    РезультатЗапроса       = Запрос.Выполнить();
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Если ВыборкаДетальныеЗаписи.Следующий() И Не ВыборкаДетальныеЗаписи.Слов = NULL Тогда
        Возврат ВыборкаДетальныеЗаписи.Слов;
    Иначе
        Возврат 0;
    КонецЕсли;

КонецФункции

// Вернуть данные пользователя по Cookie.
// 
// Параметры:
//  Печенька - Строка - Печенька
// 
// Возвращаемое значение:
//  Строка, Структура - Вернуть данные пользователя:
// * name - Строка - Имя
// * id - Строка - Идентификатор
// * status - Строка - ok/not_found
// * days - Массив из Строка - Массив дней недели
// * data - Массив из Число - Массив слов по дням
// * week - Число - Слов за неделю
// * target - Массив из Число - Массив целей по словам
// * total - Число - Слов за все время
// * VK - Булево - подключен ВК
// * Telegram - Булево - подключен ТГ
// * regdate - Дата - Дата регистрации
// * fin - Число - Количесво прочитанных книг
// * alert - Строка - Периодичность оповещений
Функция ВернутьДанныеПользователя(Знач Печенька) Экспорт
    
    Попытка
        
    НомерДняНедели = ДеньНедели(ТекущаяДатаСеанса());
    ДеньНедели     = ИнструментарийВызовСервера.ВернутьДеньНедели(НомерДняНедели);
    МассивПоДням   = Новый Массив;
    МассивДней     = Новый Массив;
    МассивЦелей    = Новый Массив;
    СловЗаНеделю   = 0;

    ЗапросБД = Новый Запрос(       
    "ВЫБРАТЬ
    |    АктивныеСеансы.Пользователь КАК Пользователь,
    |    АктивныеСеансы.Пользователь.Наименование КАК ПользовательНаименование,
    |    АктивныеСеансы.Пользователь.Код КАК ПользовательКод,
    |    АктивныеСеансы.Дата КАК Период,
    |    АктивныеСеансы.Пользователь.VK КАК ПользовательVK,
    |    АктивныеСеансы.Пользователь.Telegram КАК ПользовательTelegram,
    |    АктивныеСеансы.Пользователь.ДатаРегистрации КАК ПользовательДатаРегистрации,
    |    СУММА(ВЫБОР
    |        КОГДА ПотоковоеЧтение.Пользователь ЕСТЬ NULL
    |            ТОГДА 0
    |        ИНАЧЕ 1
    |    КОНЕЦ) КАК Завершенные,
    |    АктивныеСеансы.Пользователь.ПерсональныеНастройки.ДневнаяЦель КАК Цель,
    |    АктивныеСеансы.Пользователь.ПерсональныеНастройки.Оповещения КАК Оповещания
    |ПОМЕСТИТЬ ВТ_Пользователь
    |ИЗ
    |    РегистрСведений.АктивныеСеансы КАК АктивныеСеансы
    |        ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
    |        ПО АктивныеСеансы.Пользователь = ПотоковоеЧтение.Пользователь
    |        И ПотоковоеЧтение.Завершена
    |ГДЕ
    |    АктивныеСеансы.Cookie = &Cookie
    |СГРУППИРОВАТЬ ПО
    |    АктивныеСеансы.Пользователь,
    |    АктивныеСеансы.Дата,
    |    АктивныеСеансы.Пользователь.Наименование,
    |    АктивныеСеансы.Пользователь.Код,
    |    АктивныеСеансы.Пользователь.VK,
    |    АктивныеСеансы.Пользователь.Telegram,
    |    АктивныеСеансы.Пользователь.ДатаРегистрации,
    |    АктивныеСеансы.Пользователь.ПерсональныеНастройки.ДневнаяЦель,
    |    АктивныеСеансы.Пользователь.ПерсональныеНастройки.Оповещения
    |;
    |
    |////////////////////////////////////////////////////////////////////////////////
    |ВЫБРАТЬ ПЕРВЫЕ 7
    |    ЕСТЬNULL(ДневнойПрогресс.КоличествоСлов, 0) КАК КоличествоСлов,
    |    ЕСТЬNULL(ДневнойПрогресс.День, &ДеньНедели) КАК День,
    |    ЕСТЬNULL(ДневнойПрогресс.Дата, &ТекущаяДата) КАК Дата,
    |    ВТ_Пользователь.Цель КАК Цель
    |ПОМЕСТИТЬ ВТ_Неделя
    |ИЗ
    |    ВТ_Пользователь КАК ВТ_Пользователь
    |        ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ДневнойПрогресс КАК ДневнойПрогресс
    |        ПО ВТ_Пользователь.Пользователь = ДневнойПрогресс.Пользователь
    |
    |УПОРЯДОЧИТЬ ПО
    |    ДневнойПрогресс.Дата УБЫВ");
    
    ЗапросБД.УстановитьПараметр("Cookie"        , Печенька);
    ЗапросБД.УстановитьПараметр("ТекущаяДата"   , ТекущаяДатаСеанса());
    ЗапросБД.УстановитьПараметр("ДеньНедели"    , ДеньНедели);
    
    РезультатЗапроса             = ЗапросБД.ВыполнитьПакетСПромежуточнымиДанными();    
    ВыборкаДетальныеЗаписи       = РезультатЗапроса[0].Выбрать();
    ВыборкаПоДням                = РезультатЗапроса[1].Выбрать();
    
    Пока ВыборкаПоДням.Следующий() Цикл
        
        МассивДней.Вставить(0        , ВыборкаПоДням.День);    
        МассивПоДням.Вставить(0      , ВыборкаПоДням.КоличествоСлов);
        
        СловЗаНеделю = СловЗаНеделю + ВыборкаПоДням.КоличествоСлов;
        
        Если Не ВыборкаПоДням.Цель = 0 Тогда
            МассивЦелей.Вставить(0, ВыборкаПоДням.Цель);
        КонецЕсли;
        
    КонецЦикла;
    
    Если ВыборкаДетальныеЗаписи.Следующий() Тогда
        
        ЕстьVK = ?(ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ПользовательVK), Истина, Ложь);
        ЕстьTG = ?(ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ПользовательTelegram), Истина, Ложь);
                
        СтруктураПользователя = Новый Структура;
        СтруктураПользователя.Вставить("name"        , ВыборкаДетальныеЗаписи.ПользовательНаименование);
        СтруктураПользователя.Вставить("id"          , ВыборкаДетальныеЗаписи.ПользовательКод);
        СтруктураПользователя.Вставить("status"      , "ok");
        СтруктураПользователя.Вставить("days"        , МассивДней);
        СтруктураПользователя.Вставить("data"        , МассивПоДням);
        СтруктураПользователя.Вставить("week"        , СловЗаНеделю);
        СтруктураПользователя.Вставить("target"      , МассивЦелей);
        СтруктураПользователя.Вставить("total"       , ПолучитьОбщееЧислоСлов(ВыборкаДетальныеЗаписи.Пользователь));
        СтруктураПользователя.Вставить("VK"          , ЕстьVK);
        СтруктураПользователя.Вставить("Telegram"    , ЕстьTG);
        СтруктураПользователя.Вставить("regdate"     , ВыборкаДетальныеЗаписи.ПользовательДатаРегистрации);
        СтруктураПользователя.Вставить("fin"         , ВыборкаДетальныеЗаписи.Завершенные);
        СтруктураПользователя.Вставить("alert"       , Строка(ВыборкаДетальныеЗаписи.Оповещания));
        
    Иначе
                
        СтруктураПользователя = Новый Структура;
        СтруктураПользователя.Вставить("name"        , "");
        СтруктураПользователя.Вставить("id"          , "");
        СтруктураПользователя.Вставить("status"      , "not_found");    
        
    КонецЕсли;
    
    Возврат СтруктураПользователя;
    
    Исключение
        ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
        Возврат "";
    КонецПопытки;
    
КонецФункции

// Вернуть список чтения.
// 
// Параметры:
//  ПользовательИБ - СправочникСсылка.Пользователи - Пользователь ИБ
//  Количество - Число - Количество книг
//  Книга - СправочникСсылка.Произведения - Книга (если нужна конкретная)
// 
// Возвращаемое значение:
// СправочникСсылка.Произведения, Массив Из СправочникСсылка.Произведения - список или одиночная книга 
Функция ВернутьСписокЧтения(Знач ПользовательИБ, Знач Количество = "", Знач Книга = "") Экспорт
    
    МассивКниг        = Новый Массив;
    НоваяКнига        = Новый Структура;
    ОдиночнаяКнига    = Ложь;
    
    Если Не ЗначениеЗаполнено(Книга) Тогда
        Книга = Справочники.Произведения.ПустаяСсылка();
    Иначе
        ОдиночнаяКнига = Истина;
    КонецЕсли;
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
    "ВЫБРАТЬ РАЗЛИЧНЫЕ" + ?(ЗначениеЗаполнено(Количество), " Первые " + Строка(Количество), "") + "
    |    ПотоковоеЧтение.Текст.Наименование КАК Текст,
    |    ПотоковоеЧтение.Текст.Автор.Наименование КАК Автор,
    |    ПотоковоеЧтение.Текст.Автор.Код Как КодАвтора,
    |    ПотоковоеЧтение.Текст.Код Как ИД,
    |    ПотоковоеЧтение.Текст.Слов Как ВсегоСлов,
    |    ПотоковоеЧтение.Слов Как ПрочитаноСлов,
    |    ПотоковоеЧтение.Дата Как Дата,
    |    ПотоковоеЧтение.Завершена Как Завершена
    |ИЗ
    |    РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
    |ГДЕ
    |    ПотоковоеЧтение.Пользователь = &Пользователь 
    |    И Не ПотоковоеЧтение.Текст = Значение(Справочник.Произведения.Оповещение)
    |    И Выбор Когда &ОпределеннаяКнига = Значение(Справочник.Произведения.ПустаяСсылка) Тогда Истина
    |    Иначе &ОпределеннаяКнига = ПотоковоеЧтение.Текст Конец
    |
    |УПОРЯДОЧИТЬ ПО
    |    ПотоковоеЧтение.Завершена,
    |    ПотоковоеЧтение.Дата УБЫВ";
    
    Запрос.УстановитьПараметр("Пользователь", ПользовательИБ);
    Запрос.УстановитьПараметр("ОпределеннаяКнига", Книга);
    
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        
        НоваяКнига = Новый Структура;
        НоваяКнига.Вставить("author"    , ВыборкаДетальныеЗаписи.Автор);
        НоваяКнига.Вставить("author_id" , ВыборкаДетальныеЗаписи.КодАвтора);
        НоваяКнига.Вставить("name"      , ВыборкаДетальныеЗаписи.Текст);
        НоваяКнига.Вставить("id"        , ВыборкаДетальныеЗаписи.ИД);
        НоваяКнига.Вставить("amount"    , МетодыРаботыHttp.ЧислоВСтроку(ВыборкаДетальныеЗаписи.ПрочитаноСлов));
        НоваяКнига.Вставить("total"     , МетодыРаботыHttp.ЧислоВСтроку(ВыборкаДетальныеЗаписи.ВсегоСлов));
        НоваяКнига.Вставить("fin"       , ВыборкаДетальныеЗаписи.Завершена);
        МассивКниг.Добавить(НоваяКнига);
        
    КонецЦикла;
    
    Если Не ОдиночнаяКнига Тогда
        Возврат МассивКниг;
    Иначе
        Возврат НоваяКнига;
    КонецЕсли;
    
КонецФункции

// Шаблон структуры параметров телеграм.
// 
// Возвращаемое значение:
//  Структура -  Шаблон структуры параметров телеграм:
// * ИдентификаторПользователя - Строка - Идентификатор телеграм
// * ИдентификаторЧата - Строка - Идентификатор конкретного чата с пользователем (как правило = ИП)
// * ТекстСообщения - Строка - Сообщение
// * ИмяПользователя - Строка - Имя из телеграм
// * Никнейм - Строка - Никнейм из телеграм 
// * Секрет - Строка - Поле для совместимости с механизмом обработки сообщений ВК, в котором секрет используется
// * ВидСоцСети - ПеречислениеСсылка.СоцСети - Определитель телеграма
Функция ШаблонСтруктурыПараметровТелеграм() Экспорт
    
    СтруктураПараметров = Новый Структура;
    
    СтруктураПараметров.Вставить("ИдентификаторПользователя", "");
    СтруктураПараметров.Вставить("ИдентификаторЧата"        , "");
    СтруктураПараметров.Вставить("ТекстСообщения"           , "");
    СтруктураПараметров.Вставить("ИмяПользователя"          , "");
    СтруктураПараметров.Вставить("Никнейм"                  , "");
    СтруктураПараметров.Вставить("Секрет"                   , "");
    СтруктураПараметров.Вставить("ВидСоцСети"               
        , ПредопределенноеЗначение("Перечисление.СоцСети.Telegram"));
    
    Возврат СтруктураПараметров;
    
КонецФункции

// Обработать данные TMA.
// 
// Параметры:
//  СтруктураДанных - Структура из Строка - Структура входных данных
// 
// Возвращаемое значение:
//  Соответствие из Строка- Данные пользователя Telegram
Функция ОбработатьДанныеTMA(СтруктураДанных) Экспорт
	
	Ключ  = "WebAppData";
	Хэш   = "";
	Токен = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Справочники.Сообщества.Athenaeum
		, "TGB_token");
		
	Результат = ИнструментарийВызовСервера.HMACSHA256(
		ПолучитьДвоичныеДанныеИзСтроки(Ключ)
		, ПолучитьДвоичныеДанныеИзСтроки(Токен)); 
		
	ТЗ 			 = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("Ключ");
	ТЗ.Колонки.Добавить("Значение");
	
	Для Каждого Данные Из СтруктураДанных Цикл
		
		Если Не Данные.Ключ = "cookie" Тогда	
			НоваяСтрока 	= ТЗ.Добавить();		
			НоваяСтрока.Ключ 		= Данные.Ключ;
			НоваяСтрока.Значение 	= Данные.Значение;
		КонецЕсли;
		
	КонецЦикла;
	
	ТЗ.Сортировать("Ключ");
	
	СоответствиеВозврата = Новый Соответствие;
	DCS 			  	= "";
	
	Для Каждого СтрокаТЗ Из ТЗ Цикл
		
		Если СтрокаТЗ.Ключ <> "hash" Тогда
			DCS = DCS + СтрокаТЗ.Ключ + "=" + СтрокаТЗ.Значение + Символы.ПС;
			СоответствиеВозврата.Вставить(СтрокаТЗ.Ключ, СтрокаТЗ.Значение); 
		Иначе
			Хэш = СтрокаТЗ.Значение;
		КонецЕсли;
		
	КонецЦикла;
	
	DCS 	= Лев(DCS, СтрДлина(DCS) - 1);
	Подпись = ИнструментарийВызовСервера.HMACSHA256(Результат, ПолучитьДвоичныеДанныеИзСтроки(DCS));
	
	Финал = ПолучитьHexСтрокуИзДвоичныхДанных(Подпись);
		
	Если Финал = вРег(Хэш) Тогда
		Ответ = Истина;
	Иначе
		Ответ = Ложь;
	КонецЕсли;

	СоответствиеВозврата.Вставить("passed", Ответ);
	
	Возврат СоответствиеВозврата;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция tgbotlogIn(Запрос) Экспорт    
    
    МетодыТестирования.ЗаписатьТест(Запрос, "tgbotlogIn");
    
    Ответ = Новый HTTPСервисОтвет(200);
    
    Попытка
        
    СтруктураПараметров       = ШаблонСтруктурыПараметровТелеграм();
    Ответ                     = Новый HTTPСервисОтвет(200);
    ТелоСтрока                = Запрос.ПолучитьТелоКакСтроку();
    
    ЧтениеJSON     = Новый ЧтениеJSON;
    ЧтениеJSON.УстановитьСтроку(ТелоСтрока);
    ОтветОбъект = ПрочитатьJSON(ЧтениеJSON);
    
    Если ОтветОбъект.Свойство("message") Тогда
        
        ПолучитьСтруктуруПараметровИзСообщения(ОтветОбъект, СтруктураПараметров);
                
    ИначеЕсли ОтветОбъект.Свойство("callback_query") Тогда
        
        ПолучитьСтруктуруПараметровИзКлавиатуры(ОтветОбъект, СтруктураПараметров);
        
    ИначеЕсли  ОтветОбъект.Свойство("my_chat_member") Тогда
        
        ПолучитьСтруктуруПараметровИзСтатуса(ОтветОбъект, СтруктураПараметров);
        Возврат Ответ;    
                                    
    Иначе
        
         ИнструментарийВызовСервера.ЗаписьВЖурналИсключений("Не message и не my_chat_memebr в запросе от Telegram"
             , ТелоСтрока);
         Возврат Ответ;
        
    КонецЕсли;
	
    МетодыБота.ОбработатьВходящееСообщение(СтруктураПараметров);
        
    Исключение
    ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки(), ТелоСтрока);
    КонецПопытки;
                  
    Возврат Ответ;
    
КонецФункции

Функция vklogintakeData(Запрос) Экспорт
	
	МетодыТестирования.ЗаписатьТест(Запрос, "vklogintakeData");
	
    Ответ = Новый HTTPСервисОтвет(307);
    Ответ.Заголовки.Вставить("Location", "https://athenaeum.digital/profile"); 

    Попытка
    Токен       = Запрос.ПараметрыЗапроса.Получить("code");
    Печенька    = Запрос.ПараметрыЗапроса.Получить("uuid");
    КодКниги    = "";
    
    Если СтрНайти(Печенька, "_") > 0 Тогда
        
        МассивПараметра = СтрРазделить(Печенька, "_", Истина);
        Печенька        = МассивПараметра[0];
        КодКниги        = ?(МассивПараметра.Количество() > 1, МассивПараметра[1], "");
        
    КонецЕсли;
    
    КодВК       = МетодыБота.АвторизоватьПользователяНаСайте(Токен, Печенька, КодКниги);
    Редирект    = 302;
    
    Если КодВК = Редирект Тогда
        Ответ.Заголовки.Вставить("Location", "https://vk.com/im?sel=-218704372"); 
    КонецЕсли;
        
    Исключение
    ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
    КонецПопытки;
    
    Возврат Ответ;
    
КонецФункции

Функция vkbottakeData(Запрос) Экспорт
	
	МетодыТестирования.ЗаписатьТест(Запрос, "vkbottakeData");

	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки("ok");

	Попытка

		СтрокаЗапроса = Запрос.ПолучитьТелоКакСтроку();

		ЧтениеJSON    = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(СтрокаЗапроса);
		ОтветОбъект   = ПрочитатьJSON(ЧтениеJSON);

		Откуда  = Строка(ОтветОбъект.object.message.from_id);
		Куда    = Строка(ОтветОбъект.object.message.peer_id);

		Если Откуда <> Куда Тогда
			Возврат Ответ;
		КонецЕсли;

		ИдентификаторПользователя     = Строка(ОтветОбъект.object.message.from_id);
		ИдентификаторЧата             = ОтветОбъект.object.message.conversation_message_id;
		ТекстСообщения                = СокрЛП(ОтветОбъект.object.message.text);
		Секрет                        = ОтветОбъект.secret;

		Попытка
			ДанныеПользователя      = МетодыБота.ПолучитьДанныеПользователя(ИдентификаторПользователя);
			ИмяПользователя			= ДанныеПользователя["first_name"] + " " + ДанныеПользователя["last_name"];
		Исключение
			ИмяПользователя         = "Новый";
		КонецПопытки;

		СтруктураПараметров           = Новый Структура;
		СтруктураПараметров.Вставить("ИдентификаторПользователя", ИдентификаторПользователя);
		СтруктураПараметров.Вставить("ИдентификаторЧата"		, ИдентификаторЧата);
		СтруктураПараметров.Вставить("ТекстСообщения"			, ТекстСообщения);
		СтруктураПараметров.Вставить("ВидСоцСети"				, ПредопределенноеЗначение("Перечисление.СоцСети.VK"));
		СтруктураПараметров.Вставить("ИмяПользователя"			, ИмяПользователя);
		СтруктураПараметров.Вставить("Секрет"					, Секрет);
		СтруктураПараметров.Вставить("Никнейм"					, "");

		МетодыБота.ОбработатьВходящееСообщение(СтруктураПараметров);

	Исключение
		ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки(), СтрокаЗапроса);
	КонецПопытки;

	Возврат Ответ;
    
КонецФункции

Функция takeStartsendData(Запрос) Экспорт
	
	МетодыТестирования.ЗаписатьТест(Запрос, "takeStartsendData");
	
    Ответ = Новый HTTPСервисОтвет(200);
    
    Попытка
        
    Печенька             = Запрос.ПараметрыЗапроса.Получить("cookie");
    Количество           = Запрос.ПараметрыЗапроса.Получить("book");
    Назначение           = Запрос.ПараметрыЗапроса.Получить("social");
    ПользовательИБ       = ВернутьПользователяПоCookie(Печенька);
    
    ПоляПользователя     = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(ПользовательИБ
        , "Telegram,VK,РазрешилПисатьVK");
    
    ЗапретТГ = (Назначение = "tg" 
        И Не ЗначениеЗаполнено(ПоляПользователя.Telegram));
    ЗапретВК = (Назначение = "vk" 
        И (Не ЗначениеЗаполнено(ПоляПользователя.VK) Или Не ПоляПользователя.РазрешилПисатьVK));
    
    Если ЗапретТГ ИЛИ ЗапретВК Тогда        
        Ответ = Новый HTTPСервисОтвет(400);
        Возврат Ответ;
    КонецЕсли;
    
    СтруктураПараметров            = Новый Структура;
    СтруктураПараметров.Вставить("ИмяПользователя"      , "Новый");
    СтруктураПараметров.Вставить("ТекстСообщения"       , Количество);
    СтруктураПараметров.Вставить("Никнейм"              , "");
    СтруктураПараметров.Вставить("Секрет"               
        , ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Справочники.Сообщества.Athenaeum, "ВК_communitysecret"));
    
    Если Назначение = "tg" Тогда
        
        Telegram = МетодыРаботыHttp.ЧислоВСтроку(ПоляПользователя.Telegram);
        
        СтруктураПараметров.Вставить("ИдентификаторПользователя", Telegram);
        СтруктураПараметров.Вставить("ИдентификаторЧата"        , Telegram);    
        СтруктураПараметров.Вставить("ВидСоцСети"               
        	, ПредопределенноеЗначение("Перечисление.СоцСети.Telegram"));
        
    ИначеЕсли Назначение = "vk" Тогда
        
        VK = МетодыРаботыHttp.ЧислоВСтроку(ПоляПользователя.VK); 
        
        СтруктураПараметров.Вставить("ИдентификаторПользователя", VK);
        СтруктураПараметров.Вставить("ИдентификаторЧата"        , VK);    
        СтруктураПараметров.Вставить("ВидСоцСети"               
        	, ПредопределенноеЗначение("Перечисление.СоцСети.VK"));
        
    Иначе
        
        ИнструментарийВызовСервера.ЗаписьВЖурналИсключений("SendBook без Social"
            , МетодыРаботыHttp.JSONСтрокой(Запрос.ПараметрыЗапроса));
            
        Ответ = Новый HTTPСервисОтвет(400);
        Возврат Ответ;
        
    КонецЕсли;

    МетодыБота.ОбработатьВходящееСообщение(СтруктураПараметров);
    
    Исключение
    ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
    КонецПопытки;

    Возврат Ответ;
    
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПолучитьСтруктуруПараметровИзСообщения(Знач ОтветОбъект, СтруктураПараметров)

    Никнейм    = ?(ОтветОбъект.message.from.Свойство("username"), ОтветОбъект.message.from.username, "");

    ИдентификаторПользователя     = ОтветОбъект.message.from.id;
    ИдентификаторЧата             = ОтветОбъект.message.chat.id;
    ТекстСообщения                = ?(ОтветОбъект.message.Свойство("text"), ОтветОбъект.message.text, "Шляпадата");
    ИмяПользователя               = 
        ?(ОтветОбъект.message.from.Свойство("first_name"), ОтветОбъект.message.from.first_name + " ", "") 
        + ?(ОтветОбъект.message.from.Свойство("last_name"), ОтветОбъект.message.from.last_name, "");

    СтруктураПараметров.Вставить("ИдентификаторПользователя", ИдентификаторПользователя);
    СтруктураПараметров.Вставить("ИдентификаторЧата"        , ИдентификаторЧата);
    СтруктураПараметров.Вставить("ТекстСообщения"           , ТекстСообщения);
    СтруктураПараметров.Вставить("ИмяПользователя"          , ИмяПользователя);
    СтруктураПараметров.Вставить("Никнейм"                  , Никнейм);

КонецПроцедуры

Процедура ПолучитьСтруктуруПараметровИзСтатуса(Знач ОтветОбъект, СтруктураПараметров)

    FromID              = МетодыРаботыHttp.ЧислоВСтроку(ОтветОбъект.my_chat_member.from.id);
    НовыйСтатус         = ОтветОбъект.my_chat_member.new_chat_member.status;
    ПользовательИБ      = Справочники.Пользователи.НайтиПоРеквизиту("Telegram", FromID);

    ОбъектПользователь  = ПользовательИБ.ПолучитьОбъект();

    Если НовыйСтатус = "kicked" Тогда
        ОбъектПользователь.ТГ_БотОстановлен = Истина;
    Иначе
        ОбъектПользователь.ТГ_БотОстановлен = Ложь;
    КонецЕсли;

    ОбъектПользователь.Записать();

КонецПроцедуры

Процедура ПолучитьСтруктуруПараметровИзКлавиатуры(Знач ОтветОбъект, СтруктураПараметров)

    Никнейм    = ?(ОтветОбъект.callback_query.from.Свойство("username"), ОтветОбъект.callback_query.from.username, "");

    ИдентификаторПользователя     = ОтветОбъект.callback_query.from.id;
    ИдентификаторЧата             = ОтветОбъект.callback_query.message.chat.id;
    ТекстСообщения                = ОтветОбъект.callback_query.data;
    ИмяПользователя               = ?(ОтветОбъект.callback_query.from.Свойство("first_name"),
        ОтветОбъект.callback_query.from.first_name + " ", "") + ?(ОтветОбъект.callback_query.from.Свойство("last_name"),
        ОтветОбъект.callback_query.from.last_name, "");

    СтруктураПараметров.Вставить("ИдентификаторПользователя", ИдентификаторПользователя);
    СтруктураПараметров.Вставить("ИдентификаторЧата"        , ИдентификаторЧата);
    СтруктураПараметров.Вставить("ТекстСообщения"           , ТекстСообщения);
    СтруктураПараметров.Вставить("ИмяПользователя"          , ИмяПользователя);
    СтруктураПараметров.Вставить("Никнейм"                  , Никнейм);
    
КонецПроцедуры

#КонецОбласти