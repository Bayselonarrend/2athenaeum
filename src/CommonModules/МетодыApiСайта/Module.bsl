#Область ПрограммныйИнтерфейс

Функция ВернутьПользователяПоCookie(Знач Печенька) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	АктивныеСеансы.Пользователь КАК Пользователь
	|ИЗ
	|	РегистрСведений.АктивныеСеансы КАК АктивныеСеансы
	|ГДЕ
	|	АктивныеСеансы.Cookie = &Печенька";
	
	Запрос.УстановитьПараметр("Печенька", Печенька);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Возврат ВыборкаДетальныеЗаписи.Пользователь;
	Иначе
		Возврат Справочники.Пользователи.ПустаяСсылка();
	КонецЕсли;
	
	
КонецФункции

Функция ПолучитьОбщееЧислоСлов(Знач Пользователь) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СУММА(ВЫБОР
		|			КОГДА ЕСТЬNULL(ПотоковоеЧтение.Завершена, ЛОЖЬ)
		|				ТОГДА ЕСТЬNULL(ПотоковоеЧтение.Текст.Слов, 0)
		|			ИНАЧЕ ЕСТЬNULL(ПотоковоеЧтение.МаксимумСлов, 0)
		|		КОНЕЦ) КАК Слов
		|ИЗ
		|	РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
		|ГДЕ
		|	ПотоковоеЧтение.Пользователь = &Пользователь";
	
	Запрос.УстановитьПараметр("Пользователь", Пользователь);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() И Не ВыборкаДетальныеЗаписи.Слов = NULL Тогда
		Возврат ВыборкаДетальныеЗаписи.Слов;
	Иначе
		Возврат 0;
	КонецЕсли;

КонецФункции

Функция ВернутьДанныеПользователя(Знач Печенька) Экспорт
	
	Попытка
	МассивПоДням 				= Новый Массив;
	МассивДней					= Новый Массив;
	МассивЦелей					= Новый Массив;
	СловЗаНеделю				= 0;

	ЗапросБД = Новый Запрос(       
	"ВЫБРАТЬ
	|	АктивныеСеансы.Пользователь КАК Пользователь,
	|	АктивныеСеансы.Пользователь.Наименование КАК ПользовательНаименование,
	|	АктивныеСеансы.Пользователь.Код КАК ПользовательКод,
	|	АктивныеСеансы.Дата КАК Период,
	|	АктивныеСеансы.Пользователь.VK КАК ПользовательVK,
	|	АктивныеСеансы.Пользователь.Telegram КАК ПользовательTelegram,
	|	АктивныеСеансы.Пользователь.ДатаРегистрации КАК ПользовательДатаРегистрации,
	|	СУММА(ВЫБОР
	|		КОГДА ПотоковоеЧтение.Пользователь ЕСТЬ NULL
	|			ТОГДА 0
	|		ИНАЧЕ 1
	|	КОНЕЦ) КАК Завершенные,
	|	АктивныеСеансы.Пользователь.ПерсональныеНастройки.ДневнаяЦель КАК Цель,
	|	АктивныеСеансы.Пользователь.ПерсональныеНастройки.Оповещения КАК Оповещания
	|ПОМЕСТИТЬ ВТ_Пользователь
	|ИЗ
	|	РегистрСведений.АктивныеСеансы КАК АктивныеСеансы
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
	|		ПО АктивныеСеансы.Пользователь = ПотоковоеЧтение.Пользователь
	|		И ПотоковоеЧтение.Завершена
	|ГДЕ
	|	АктивныеСеансы.Cookie = &Cookie
	|СГРУППИРОВАТЬ ПО
	|	АктивныеСеансы.Пользователь,
	|	АктивныеСеансы.Дата,
	|	АктивныеСеансы.Пользователь.Наименование,
	|	АктивныеСеансы.Пользователь.Код,
	|	АктивныеСеансы.Пользователь.VK,
	|	АктивныеСеансы.Пользователь.Telegram,
	|	АктивныеСеансы.Пользователь.ДатаРегистрации,
	|	АктивныеСеансы.Пользователь.ПерсональныеНастройки.ДневнаяЦель,
	|	АктивныеСеансы.Пользователь.ПерсональныеНастройки.Оповещения
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 7
	|	ЕСТЬNULL(ДневнойПрогресс.КоличествоСлов, 0) КАК КоличествоСлов,
	|	ЕСТЬNULL(ДневнойПрогресс.ДеньНедели, &ДеньНедели) КАК ДеньНедели,
	|	ЕСТЬNULL(ДневнойПрогресс.Дата, &ТекущаяДата) КАК Дата,
	|	ВТ_Пользователь.Цель КАК Цель
	|ПОМЕСТИТЬ ВТ_Неделя
	|ИЗ
	|	ВТ_Пользователь КАК ВТ_Пользователь
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ДневнойПрогресс КАК ДневнойПрогресс
	|		ПО ВТ_Пользователь.Пользователь = ДневнойПрогресс.Пользователь
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДневнойПрогресс.Дата УБЫВ");
	
	ЗапросБД.УстановитьПараметр("Cookie"		, Печенька);
	ЗапросБД.УстановитьПараметр("ТекущаяДата"	, ТекущаяДатаСеанса());
	ЗапросБД.УстановитьПараметр("ДеньНедели"	, ИнструментарийВызовСервера.ВернутьДеньНедели(ДеньНедели(ТекущаяДатаСеанса())));
	
	РезультатЗапроса 			= ЗапросБД.ВыполнитьПакетСПромежуточнымиДанными();	
	ВыборкаДетальныеЗаписи 		= РезультатЗапроса[0].Выбрать();
	ВыборкаПоДням				= РезультатЗапроса[1].Выбрать();
	
	Пока ВыборкаПоДням.Следующий() Цикл
		
		МассивДней.Вставить(0		, Строка(ВыборкаПоДням.ДеньНедели));	
		МассивПоДням.Вставить(0		, ВыборкаПоДням.КоличествоСлов);
		СловЗаНеделю = СловЗаНеделю + ВыборкаПоДням.КоличествоСлов;
		
		Если Не ВыборкаПоДням.Цель = 0 Тогда
			МассивЦелей.Вставить(0, ВыборкаПоДням.Цель);
		КонецЕсли;
		
	КонецЦикла;
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
				
		СтруктураПользователя = Новый Структура;
		СтруктураПользователя.Вставить("name"		, ВыборкаДетальныеЗаписи.ПользовательНаименование);
		СтруктураПользователя.Вставить("id"			, ВыборкаДетальныеЗаписи.ПользовательКод);
		СтруктураПользователя.Вставить("status"		, "ok");
		СтруктураПользователя.Вставить("days"		, МассивДней);
		СтруктураПользователя.Вставить("data"		, МассивПоДням);
		СтруктураПользователя.Вставить("week"		, СловЗаНеделю);
		СтруктураПользователя.Вставить("target"		, МассивЦелей);
		СтруктураПользователя.Вставить("total"      , ПолучитьОбщееЧислоСлов(ВыборкаДетальныеЗаписи.Пользователь));
		СтруктураПользователя.Вставить("VK"			, ?(ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ПользовательVK), Истина, Ложь));
		СтруктураПользователя.Вставить("Telegram"	, ?(ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ПользовательTelegram), Истина, Ложь));
		СтруктураПользователя.Вставить("regdate"	, ВыборкаДетальныеЗаписи.ПользовательДатаРегистрации);
		СтруктураПользователя.Вставить("fin"		, ВыборкаДетальныеЗаписи.Завершенные);
		СтруктураПользователя.Вставить("alert"		, Строка(ВыборкаДетальныеЗаписи.Оповещания));
		
	Иначе
				
		СтруктураПользователя = Новый Структура;
		СтруктураПользователя.Вставить("name"		, "");
		СтруктураПользователя.Вставить("id"			, "");
		СтруктураПользователя.Вставить("status"		, "not_found");	
		
	КонецЕсли;
	
	Возврат СтруктураПользователя
	
	Исключение
		ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
	КонецПопытки;
	
КонецФункции

Функция ВернутьСписокЧтения(Знач ПользовательИБ, Знач Количество = "", Знач Книга = "") Экспорт
	
	МассивКниг		= Новый Массив;
	НоваяКнига 		= Новый Структура;
	ОдиночнаяКнига	= Ложь;
	
	Если Не ЗначениеЗаполнено(Книга) Тогда
		Книга = Справочники.Произведения.ПустаяСсылка();
	Иначе
		ОдиночнаяКнига = Истина;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ" + ?(ЗначениеЗаполнено(Количество), " Первые " + Строка(Количество), "") + "
	|	ПотоковоеЧтение.Текст.Наименование КАК Текст,
	|	ПотоковоеЧтение.Текст.Автор.Наименование КАК Автор,
	|	ПотоковоеЧтение.Текст.Автор.Код Как КодАвтора,
	|	ПотоковоеЧтение.Текст.Код Как ИД,
	|	ПотоковоеЧтение.Текст.Слов Как ВсегоСлов,
	|	ПотоковоеЧтение.Слов Как ПрочитаноСлов,
	|	ПотоковоеЧтение.Дата Как Дата,
	|	ПотоковоеЧтение.Завершена Как Завершена
	|ИЗ
	|	РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
	|ГДЕ
	|	ПотоковоеЧтение.Пользователь = &Пользователь 
	|	И Не ПотоковоеЧтение.Текст = Значение(Справочник.Произведения.Оповещение)
	|	И Выбор Когда &ОпределеннаяКнига = Значение(Справочник.Произведения.ПустаяСсылка) Тогда Истина
	|	Иначе &ОпределеннаяКнига = ПотоковоеЧтение.Текст Конец
	|
	|УПОРЯДОЧИТЬ ПО
	|	ПотоковоеЧтение.Завершена,
	|	ПотоковоеЧтение.Дата УБЫВ";
	
	Запрос.УстановитьПараметр("Пользователь", ПользовательИБ);
	Запрос.УстановитьПараметр("ОпределеннаяКнига", Книга);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		НоваяКнига = Новый Структура;
		НоваяКнига.Вставить("author"	, ВыборкаДетальныеЗаписи.Автор);
		НоваяКнига.Вставить("author_id"	, ВыборкаДетальныеЗаписи.КодАвтора);
		НоваяКнига.Вставить("name"		, ВыборкаДетальныеЗаписи.Текст);
		НоваяКнига.Вставить("id"		, ВыборкаДетальныеЗаписи.ИД);
		НоваяКнига.Вставить("amount"	, МетодыРаботыHttp.ЧислоВСтроку(ВыборкаДетальныеЗаписи.ПрочитаноСлов));
		НоваяКнига.Вставить("total"		, МетодыРаботыHttp.ЧислоВСтроку(ВыборкаДетальныеЗаписи.ВсегоСлов));
		НоваяКнига.Вставить("fin"		, ВыборкаДетальныеЗаписи.Завершена);
		МассивКниг.Добавить(НоваяКнига);
		
	КонецЦикла;
	
	Если Не ОдиночнаяКнига Тогда
		Возврат МассивКниг;
	Иначе
		Возврат НоваяКнига;
	КонецЕсли;
	
КонецФункции

#КонецОбласти