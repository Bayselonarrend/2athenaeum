#Область ПрограммныйИнтерфейс 

Функция ОбработатьВходящееСообщение(Знач СтруктураПараметров) Экспорт

	ИдентификаторПользователя 	= СтруктураПараметров["ИдентификаторПользователя"];
	ИдентификаторЧата			= СтруктураПараметров["ИдентификаторЧата"];
	ТекстСообщения				= СтруктураПараметров["ТекстСообщения"];
	ВидСоцСети 					= СтруктураПараметров["ВидСоцСети"];
	ИмяПользователя				= СтруктураПараметров["ИмяПользователя"];
	Секрет						= СтруктураПараметров["Секрет"];
	Никнейм						= СтруктураПараметров["Никнейм"];
	ЗапрашиваемыйТекст			= Справочники.Произведения.НайтиПоКоду(вРег(ТекстСообщения));
	МассивСообщений				= Новый Массив;
	Клавиатура					= Истина;
	Смайлы						= Ложь;
	НовыйПользователь			= Ложь;
	СоцСетьVK					= Перечисления.СоцСети.VK;
	СоцСетьTG					= Перечисления.СоцСети.Telegram;
	СекретВК 					= ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(
		Справочники.Сообщества.Athenaeum, "ВК_communitysecret");

	ПользовательИБ 		= Неопределено;

	Если ЗначениеЗаполнено(ИдентификаторПользователя) Тогда

		Если ВидСоцСети = СоцСетьVK Тогда

			Если Не СекретВК = Секрет Тогда Возврат Ложь КонецЕсли;
			ПользовательИБ = Справочники.Пользователи.НайтиПоРеквизиту("VK", Строка(ИдентификаторПользователя));

		ИначеЕсли ВидСоцСети = СоцСетьTG Тогда
			
			ПользовательИБ 	= Справочники.Пользователи.НайтиПоРеквизиту("Telegram", Строка(ИдентификаторПользователя));
			Смайлы 			= Истина;
			
		Иначе
			Возврат Ложь;
		КонецЕсли;

	КонецЕсли;

	Если ЗначениеЗаполнено(ПользовательИБ) Тогда
		ПоследнийТекст	= ВернутьПоследнийТекст(ПользовательИБ);
	Иначе
		НовыйПользователь 						= Справочники.Пользователи.СоздатьЭлемент();
		НовыйПользователь.ПерсональныеНастройки	= Справочники.ПерсональныеНастройки.Инициализировать(ИмяПользователя);
		НовыйПользователь.Telegram 				= ?(ВидСоцСети = СоцСетьTG, ИдентификаторПользователя, "");
		НовыйПользователь.VK 					= ?(ВидСоцСети = СоцСетьVK, ИдентификаторПользователя, "");
		НовыйПользователь.РазрешилПисатьVK		= ?(ВидСоцСети = СоцСетьVK, Истина, Ложь);
		НовыйПользователь.Наименование 			= ИмяПользователя;
		НовыйПользователь.ДатаРегистрации 		= ТекущаяДатаСеанса();
		НовыйПользователь.Никнейм				= Никнейм;
		НовыйПользователь.Записать();
		ПользовательИБ 							= НовыйПользователь.Ссылка;
		ПоследнийТекст							= Неопределено;
		НовыйПользователь						= Истина;
	КонецЕсли;
	
	Если Не ПользовательИБ.РазрешилПисатьVK И ВидСоцСети = СоцСетьVK Тогда
		ПользовательОбъект = ПользовательИБ.ПолучитьОбъект();
		ПользовательОбъект.РазрешилПисатьVK = Истина;
		ПользовательОбъект.Записать();
	КонецЕсли;

	РегистрыСведений.Диалоги.ЗаписатьСообщениеДиалога(ПользовательИБ, Справочники.Пользователи.Ферапонт, ВидСоцСети,
		ТекстСообщения);

	//--Начало диалога----------------------------------------------------------------------
	Если СтрНайти(ТекстСообщения, "/start") > 0 И ВидСоцСети = СоцСетьTG Тогда

		Если ЗначениеЗаполнено(СтрЗаменить(ТекстСообщения, "/start", "")) Тогда
			Возврат ОбработкаАвторизацииТелеграм(ТекстСообщения, ПользовательИБ, ИмяПользователя,
				ИдентификаторПользователя, Никнейм, НовыйПользователь);
		Иначе

			МассивСообщений.Добавить("%F0%9F%98%83");
			МассивСообщений.Добавить("Добро пожаловать! 
									 |Отправьте мне код книги или авторизуйтесь на athenaeum.digital чтобы начать читать книги в нашей онлайн библиотеке!");

			Возврат РассылкаОтветов(ВидСоцСети, ПользовательИБ, ИдентификаторЧата, МассивСообщений, Клавиатура);

		КонецЕсли;

	ИначеЕсли (ТекстСообщения = "Начать" Или ТекстСообщения = "Start") И ВидСоцСети = СоцСетьVK Тогда

		Возврат ОтправитьНачалоВК(ПользовательИБ, ПоследнийТекст);

	ИначеЕсли ТекстСообщения = "Ежедневно" Или ТекстСообщения = "Еженедельно" Или ТекстСообщения = "Не напоминать" Тогда

		ТекстОтвета = ОбработатьИзменениеОповещений(ИдентификаторПользователя, ВидСоцСети, ТекстСообщения);
		МассивСообщений.Добавить(ТекстОтвета);

	ИначеЕсли (ТекстСообщения = "->" Или ТекстСообщения = "<-") Тогда

		Если ЗначениеЗаполнено(ПоследнийТекст) Тогда
			МассивСообщений.Добавить(ВернутьБлок(ПоследнийТекст, ТекстСообщения, ПользовательИБ, Смайлы));
			Клавиатура = Истина;
		Иначе
			Если Смайлы Тогда
				МассивСообщений.Добавить("%F0%9F%A4%AF");
			КонецЕсли;
			МассивСообщений.Добавить(
				"Не может быть! Кажется, я забыл, что вы читали. Ужас! Пожалуйста, выберите нужную книгу еще раз на https://athenaeum.digital");
		КонецЕсли;

	ИначеЕсли ЗначениеЗаполнено(ЗапрашиваемыйТекст) Тогда

		ОтправитьНовуюКнигу(ЗапрашиваемыйТекст, ПользовательИБ, Смайлы, МассивСообщений);

	Иначе

		Если Смайлы Тогда
			МассивСообщений.Добавить("%F0%9F%A4%94");
		КонецЕсли;
		МассивСообщений.Добавить(
				"Хммм... Нет, такой книги у меня нет. Попробуйте ввести другой код книги с https://athenaeum.digital");

	КонецЕсли;

	Возврат РассылкаОтветов(ВидСоцСети, ПользовательИБ, ИдентификаторЧата, МассивСообщений, Клавиатура);

КонецФункции

Функция ОбработатьИзменениеОповещений(Знач ID, Знач СоцСеть, Знач Текст) Экспорт
	
	ID 		= МетодыРаботыHttp.ЧислоВСтроку(ID);
	Текст 	= нРег(СокрЛП(Текст));
		
	Если СоцСеть = Перечисления.СоцСети.Telegram Тогда
		Пользователь = Справочники.Пользователи.НайтиПоРеквизиту("Telegram", ID);
	Иначе
		Пользователь = Справочники.Пользователи.НайтиПоРеквизиту("VK", ID);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Пользователь) Тогда
		
		РегистрыСведений.Диалоги.ЗаписатьСообщениеДиалога(Пользователь
			, Справочники.Пользователи.Ферапонт
			, СоцСеть
			, Текст);

		НайтройкиПользователя 	= ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Пользователь, "ПерсональныеНастройки");
		ОбъектНастроек 			= НайтройкиПользователя.ПолучитьОбъект();
		
		Если Текст = "ежедневно" Тогда
			ПеречислениеПериод = Перечисления.ПериодичностьУведомлений.Ежедневно;
		ИначеЕсли Текст = "еженедельно" Тогда
			ПеречислениеПериод = Перечисления.ПериодичностьУведомлений.Еженедельно;
		Иначе 
			ПеречислениеПериод = Перечисления.ПериодичностьУведомлений.Нет;
		КонецЕсли;
		
		ОбъектНастроек.Оповещения = ПеречислениеПериод;
		ОбъектНастроек.Записать();
		
		ТекстОтвета = "%E2%9C%8C Периодичность уведомлений изменена на *" + Текст + "*";
		
	Иначе
		ТекстОтвета = "Не удалось изменить периодичность уведомлений. Попробуйте позже";
		
	КонецЕсли;
	
	Возврат ТекстОтвета;
	
КонецФункции	

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОбработкаАвторизацииТелеграм(Знач ТекстСообщения, Знач ПользовательИБ, Знач ИмяПользователя, Знач ИдентификаторПользователя, Знач Никнейм, Знач НовыйПользователь)
	
	Попытка
		
		Печенька 				= СтрЗаменить(ТекстСообщения, "/start ", "");
		Печенька 				= СтрЗаменить(Печенька		, "/start", "");
		
		МассивЗапрос 			= Новый Массив;
		КодКниги				= "";
		
		Если СтрНайти(Печенька, "_")  > 0 Тогда
			
			МассивЗапрос 	= СтрРазделить(Печенька, "_", Истина);
			Печенька		= МассивЗапрос[0];
			КодКниги		= МассивЗапрос[1];
			
		КонецЕсли;
		
		ПользовательПоПеченью 	= МетодыApiСайта.ВернутьПользователяПоCookie(Печенька);
		ПользовательПоTG		= ПользовательИБ;
		Заполнение				= Ложь;
		ПользовательИБ			= ?(ЗначениеЗаполнено(ПользовательПоПеченью)
		, ПользовательПоПеченью
		, ПользовательИБ);
		
		ТекстОтвет = 		
		"Добро пожаловать обратно - вы авторизованы!";				
		Смайл = "%F0%9F%91%8B";
		
		Если Не ЗначениеЗаполнено(ПользовательИБ) Или НовыйПользователь Тогда
			
			Если Не ЗначениеЗаполнено(ПользовательИБ) Тогда
				
				НовыйПользователь = Справочники.Пользователи.СоздатьЭлемент();
				
				НовыйПользователь.ПерсональныеНастройки	= Справочники.ПерсональныеНастройки.Инициализировать(ИмяПользователя);
				НовыйПользователь.Telegram 				= ИдентификаторПользователя;
				НовыйПользователь.Наименование 			= ИмяПользователя;
				НовыйПользователь.ДатаРегистрации 		= ТекущаяДатаСеанса();
				НовыйПользователь.Никнейм				= Никнейм;
				НовыйПользователь.Записать();
				
				ПользовательИБ 							= НовыйПользователь.Ссылка;

			КонецЕсли;
			
			ТекстОтвет =
			
			"Привет! Я - Ферапонт, хранитель библиотеки Two-Digit Athenaeum. 
			|У меня вы можете получить интересующие вас произведения из архива по кодам или нажав на кнопку отправки со страницы книги: тексты я присылаю небольшими частями в этом чате. 
			|
			|Когда прочитаете страницу, просто нажмите кнопку и получите следующую. Одновременно можно читать сколько угодно текстов: я запомню, где вы остановились, если вдруг решите вернуться к произведению позже. Удачи!";
							
		ИначеЕсли Не ЗначениеЗаполнено(ПользовательИБ.Telegram) Тогда
			
			ОшибочныйПользователь 				= ПользовательПоTG.ПолучитьОбъект();
			ОшибочныйПользователь.Удалить();
			
			СуществующийПользователь 			= ПользовательИБ.ПолучитьОбъект();
			СуществующийПользователь.Telegram 	= ИдентификаторПользователя;
			СуществующийПользователь.Записать();
			
			Заполнение 							= Истина;
			
			Смайл		= "%F0%9F%91%8C";
			ТекстОтвет 	= "Ваш аккаунт Telegram привязан и вы можете продолжить пользоваться библиотекой. Спасибо, что остаетесь с нами!";			
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Печенька) И Не Заполнение Тогда
			МЗ = РегистрыСведений.АктивныеСеансы.СоздатьМенеджерЗаписи();
			МЗ.Cookie 		= Печенька;
			МЗ.Дата 		= ТекущаяДатаСеанса();
			МЗ.Пользователь	= ПользовательИБ;
			МЗ.Записать(Истина);
		КонецЕсли;
		
		Назначение = МетодыРаботыHttp.ЧислоВСтроку(ПользовательИБ.Telegram);
		
		МетодыРаботыTelegram.ОтправитьСообщение(Назначение, Смайл);
		МетодыРаботыTelegram.ОтправитьСообщение(Назначение, ТекстОтвет);
		
		Если ЗначениеЗаполнено(КодКниги)  Тогда
			
			ОтправитьКнигу(КодКниги, ПользовательИБ, Назначение);
			
		КонецЕсли;
					
		Возврат Истина;
		
	Исключение
		
		ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
		Возврат Ложь;
		
	КонецПопытки;
	
КонецФункции

Функция ВернутьПоследнийТекст(Знач ПользовательИБ) Экспорт
	
	ПоследнийТекст = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ПотоковоеЧтениеСрезПоследних.Текст КАК Текст,
	|	ПотоковоеЧтениеСрезПоследних.Слов КАК Слов
	|ИЗ
	|	РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтениеСрезПоследних
	|ГДЕ
	|	ПотоковоеЧтениеСрезПоследних.Пользователь = &Чат
	|	И ПотоковоеЧтениеСрезПоследних.Текст <> ЗНАЧЕНИЕ(Справочник.Произведения.Оповещение)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ПотоковоеЧтениеСрезПоследних.Дата УБЫВ";
	
	Запрос.УстановитьПараметр("Чат", ПользовательИБ);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		ПоследнийТекст = Новый Структура;
		ПоследнийТекст.Вставить("Текст", ВыборкаДетальныеЗаписи.Текст);
		ПоследнийТекст.Вставить("Слов", ВыборкаДетальныеЗаписи.Слов);
	КонецЕсли;
	
	Возврат ПоследнийТекст;

КонецФункции

Функция ВернутьБлок(Знач ПоследнийТекст, Знач Направление, Знач ПользовательИБ, Знач ЭтоТГ = Ложь) Экспорт
	
	Текст 			= Справочники.Произведения.ПустаяСсылка();
	ТекстСообщения  = "";
	Слов			= 0;
	НеОтнимать		= Ложь;
	
	Если ЗначениеЗаполнено(ПоследнийТекст) Тогда
		
		Текст			= ПоследнийТекст.Текст;
		Слов			= ?(Направление = "->", ПоследнийТекст.Слов, ПоследнийТекст.Слов - 140);
		НеОтнимать		= (Слов < 0);
		Слов			= ?(Слов > 0, Слов, 0); 
		НовыйБлок		= Слов + 70;
		ТекущаяСтраница = НовыйБлок / 70;
		ТекстСтр		= Текст.ТекстМассив.Получить();
		СтраницВсего	= Цел(ТекстСтр.Количество() / 70) + 1;

	
		Н = Слов;
		
		Пока Н <> НовыйБлок	Цикл
			Если Н > ТекстСтр.Количество() - 1 Тогда
				Прервать;
			КонецЕсли;
			ТекстСообщения = ТекстСообщения + " " + ТекстСтр[Н];	
			Н = Н +  1; 
			
		КонецЦикла;
		
		МЗ = РегистрыСведений.ПотоковоеЧтение.СоздатьМенеджерЗаписи();
		МЗ.Пользователь 		= ПользовательИБ;
		МЗ.Текст 				= Текст;
		МЗ.Прочитать();
		МЗ.Пользователь			= ПользовательИБ;
		МЗ.Текст				= Текст;
		МЗ.Дата		= ТекущаяДатаСеанса();
						
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстСообщения) Тогда
		
		ЧтениеНовых = НовыйБлок > МЗ.МаксимумСлов;
		
		ТекстСообщения 		= ТекстСообщения + Символы.ПС + Символы.ПС + Строка(ТекущаяСтраница) + "/" + Строка(СтраницВсего) + " | " + Текст.Код;
		МЗ.Слов				= НовыйБлок;
		МЗ.МаксимумСлов		= ?(ЧтениеНовых, НовыйБлок, МЗ.МаксимумСлов);
		СловКПрогрессу 		= ?(Направление = "->", 70, -70);
		СловКПрогрессу		= ?(НеОтнимать, 0, СловКПрогрессу);
		
		ДП = РегистрыСведений.ДневнойПрогресс.СоздатьМенеджерЗаписи();
		ДП.Пользователь 	=  ПользовательИБ;
		ДП.ДеньНедели		=  ИнструментарийВызовСервера.ВернутьДеньНедели();
		ДП.Прочитать();
		ДП.Пользователь 	=  ПользовательИБ;
		ДП.ДеньНедели		=  ИнструментарийВызовСервера.ВернутьДеньНедели();
		Если ЧтениеНовых Тогда
			ДП.КоличествоСлов 	= ?(ДП.Дата = НачалоДня(ТекущаяДатаСеанса()), ДП.КоличествоСлов + СловКПрогрессу, СловКПрогрессу);
		КонецЕсли;
		ДП.Дата 			= НачалоДня(ТекущаяДатаСеанса());
		ДП.Записать(Истина);
		
		
	Иначе
		
		Если ЭтоТГ Тогда 
			МетодыРаботыTelegram.ОтправитьСообщение(ПользовательИБ.Telegram, "%F0%9F%98%AE"); 
		КонецЕсли;
		
		ТекстСообщения = "Ого! Вы только что закончили читать «" 
			+ ПоследнийТекст.Текст.Наименование 
			+"»!"
			+ Символы.ПС
			+ Символы.ПС
			+ "Эта книга помечена как прочитанная в вашем списке чтения. Ну а сейчас, похоже, самое время выбирать новое произведение!";
				
		МЗ.Слов			= 0;
		МЗ.Завершена 	= Истина;
	КонецЕсли;
	
	МЗ.Записать(Истина);
	
	МассивЗапрещенныхСимволов = Новый Соответствие;  
	МассивЗапрещенныхСимволов.Вставить("&#", "-");
	МассивЗапрещенныхСимволов.Вставить("„", """");
	МассивЗапрещенныхСимволов.Вставить("“", """");
	МассивЗапрещенныхСимволов.Вставить("_", "-");
	МассивЗапрещенныхСимволов.Вставить("+", " ");
	МассивЗапрещенныхСимволов.Вставить("*", ".");
	МассивЗапрещенныхСимволов.Вставить("~", ".");
	МассивЗапрещенныхСимволов.Вставить("`", ".");
	МассивЗапрещенныхСимволов.Вставить("<", "(");
	МассивЗапрещенныхСимволов.Вставить(">", ")");
	МассивЗапрещенныхСимволов.Вставить("#", ".");
	МассивЗапрещенныхСимволов.Вставить("=", "-");
	МассивЗапрещенныхСимволов.Вставить("{", "(");
	МассивЗапрещенныхСимволов.Вставить("}", ")");
	МассивЗапрещенныхСимволов.Вставить("&", "8");
	МассивЗапрещенныхСимволов.Вставить("°", "o");
	МассивЗапрещенныхСимволов.Вставить("[", "(");
	МассивЗапрещенныхСимволов.Вставить("]", ")");
	
	Для Каждого ЗапрещенныйСимвол Из МассивЗапрещенныхСимволов Цикл
		ТекстСообщения = СтрЗаменить(ТекстСообщения, ЗапрещенныйСимвол.Ключ, ЗапрещенныйСимвол.Значение);
	КонецЦикла;
		
	Возврат ТекстСообщения; 
	
КонецФункции

Функция ВернутьМестоВТексте(Знач ПользовательИБ, Знач Текст) Экспорт
	
	Слов = 0;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПотоковоеЧтение.Слов КАК Слов
		|ИЗ
		|	РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
		|ГДЕ
		|	ПотоковоеЧтение.Пользователь = &ИдентификаторЧата
		|	И ПотоковоеЧтение.Текст = &Текст";
	
	Запрос.УстановитьПараметр("ИдентификаторЧата", ПользовательИБ);
	Запрос.УстановитьПараметр("Текст", Текст);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Слов = ВыборкаДетальныеЗаписи.Слов;
	КонецЕсли;
	
	Возврат Слов;
	
КонецФункции

Функция РассылкаОтветов(Знач ВидСоцСети, Знач ПользовательИБ, Знач ИдентификаторЧата, Знач МассивСообщений, Знач ОтправлятьКлавиатуру)
	
	Попытка 
		
		Для Каждого Сообщение Из МассивСообщений Цикл
			
			Если ВидСоцСети = Перечисления.СоцСети.VK Тогда
				
				ОтправитьОтвет(ПользовательИБ, Сообщение);
				
			ИначеЕсли 	ВидСоцСети = Перечисления.СоцСети.Telegram Тогда
				
				МетодыРаботыTelegram.ОтправитьСообщение(ИдентификаторЧата, Сообщение);	
				
			КонецЕсли;
			
		КонецЦикла;	
		
		Возврат Истина;
		
	Исключение		
		ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

Функция ПолучитьДанныеПользователя(Знач Код, Знач URL) Экспорт
	
	Параметры = Новый Структура;
	ЗаполнитьСтандартныеПараметры(Параметры, Справочники.Сообщества.Athenaeum);
	Параметры.Вставить("response_code"	, Код);
	Параметры.Вставить("redirect_url"	, КодироватьСтроку(URL, СпособКодированияСтроки.КодировкаURL));
	
	Линк = "https://api.vk.com/method/users.get";

	ПараметрыОтвета = МетодыРаботыHttp.Get(getUserToken(Параметры), Параметры);
	Параметры.Вставить("access_token", ПараметрыОтвета["access_token"]);

	Ответ = МетодыРаботыHttp.Get(Линк, Параметры);


	Возврат Ответ;

	
КонецФункции

Функция АвторизоватьПользователяНаСайте(Знач Токен, Знач Печенька, Знач КодКниги = "") Экспорт
	
	ДанныеПользователя 	= ПолучитьДанныеПользователя(Токен, "https://api.athenaeum.digital/u/hs/bot/vklogin?uuid=" 
	+ Печенька 
	+ ?(ЗначениеЗаполнено(КодКниги), "_" + КодКниги, ""));
	ДанныеПользователя 	= ДанныеПользователя["response"][0];
	Заполнение			= Ложь;	 
	
	ИД				= ДанныеПользователя["id"];
	Имя				= ДанныеПользователя["first_name"] + " " + ДанныеПользователя["last_name"];	
	ПользовательИБ	= Справочники.Пользователи.НайтиПоРеквизиту("VK", Строка(ДанныеПользователя["id"]));
	
	Если ЗначениеЗаполнено(ПользовательИБ) 
			И ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПользовательИБ, "Наименование") = "Новый" Тогда
				
		СуществующийПользователь = ПользовательИБ.ПолучитьОбъект();
		СуществующийПользователь.Наименование = Имя;
		СуществующийПользователь.Записать();
	КонецЕсли;
	
	ПользовательПоПеченью 	= МетодыApiСайта.ВернутьПользователяПоCookie(Печенька);
	ПользовательПоVK		= ПользовательИБ;
	ПользовательИБ			= ?(ЗначениеЗаполнено(ПользовательПоПеченью)
	, ПользовательПоПеченью
	, ПользовательИБ);
	
	
	Если Не ЗначениеЗаполнено(ПользовательИБ) Тогда
		
		НовыйПользователь 	= Справочники.Пользователи.СоздатьЭлемент();
		
		НовыйПользователь.ПерсональныеНастройки	= Справочники.ПерсональныеНастройки.Инициализировать(Имя);
		НовыйПользователь.VK 					= ИД;
		НовыйПользователь.Наименование 			= Имя;
		НовыйПользователь.ДатаРегистрации 		= ТекущаяДатаСеанса();
		НовыйПользователь.Записать();
		
		ПользовательИБ = НовыйПользователь.Ссылка;
		
	ИначеЕсли Не ЗначениеЗаполнено(ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПользовательИБ, "VK")) Тогда
		
		Если ЗначениеЗаполнено(ПользовательПоVK) Тогда
			ОшибочныйПользователь = ПользовательПоVK.ПолучитьОбъект();
			ОшибочныйПользователь.Удалить();
		КонецЕсли;
		
		СуществующийПользователь = ПользовательИБ.ПолучитьОбъект();
		СуществующийПользователь.VK = ИД;
		СуществующийПользователь.Записать();
		Заполнение = Истина;
		
	КонецЕсли;       
	
	Если ЗначениеЗаполнено(Печенька) И Не Заполнение Тогда
		МЗ = РегистрыСведений.АктивныеСеансы.СоздатьМенеджерЗаписи();
		МЗ.Cookie 		= Печенька;
		МЗ.Дата 		= ТекущаяДатаСеанса();
		МЗ.Пользователь	= ПользовательИБ;
		МЗ.Записать(Истина);
	КонецЕсли;
	
	Если ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПользовательИБ, "РазрешилПисатьVK") Тогда
		
		Если ЗначениеЗаполнено(КодКниги)  Тогда
			
			ЗапрашиваемыйТекст	= Справочники.Произведения.НайтиПоКоду(вРег(КодКниги));
			
			Если ЗначениеЗаполнено(ЗапрашиваемыйТекст) Тогда
				
				ТекстОтвета 	= "Вы авторизованы! А вот и ваше произведение - " 
				+ "«" 
				+ ЗапрашиваемыйТекст.Наименование 
				+ "», " 
				+ ЗапрашиваемыйТекст.Автор
				+ "!";
				
				МестоВТексте	= ВернутьМестоВТексте(ПользовательИБ, ЗапрашиваемыйТекст);
				ПоследнийТекст 	= Новый Структура;

				ПоследнийТекст.Вставить("Текст"	, ЗапрашиваемыйТекст);
				ПоследнийТекст.Вставить("Слов"	, МестоВТексте);
				
				Если МестоВТексте = 0 Тогда				
					Блок = ВернутьБлок(ПоследнийТекст, "->", ПользовательИБ, Ложь);				
				Иначе				
					Блок = ВернутьБлок(ПоследнийТекст, "<-", ПользовательИБ, Ложь);						
				КонецЕсли;
				
				ОтправитьОтвет(ПользовательИБ, ТекстОтвета);
				ОтправитьОтвет(ПользовательИБ, Блок);
				
			КонецЕсли;
			
		КонецЕсли;
		
		
		Возврат 200
	Иначе
		
		Если ЗначениеЗаполнено(КодКниги)  Тогда
			
			ЗапрашиваемыйТекст	= Справочники.Произведения.НайтиПоКоду(вРег(КодКниги));
			
			Если ЗначениеЗаполнено(ЗапрашиваемыйТекст) Тогда
				
				МЗ = РегистрыСведений.ПотоковоеЧтение.СоздатьМенеджерЗаписи();
				МЗ.Пользователь = ПользовательИБ;
				МЗ.Текст 		= ЗапрашиваемыйТекст;
				МЗ.Прочитать();
				
				МЗ.Дата = ТекущаяДатаСеанса();
				
				МЗ.Пользователь = ПользовательИБ;
				МЗ.Текст 		= ЗапрашиваемыйТекст;
				
				МЗ.НачалоВК = Истина;
				МЗ.Записать();
				
			КонецЕсли;
			
		КонецЕсли;
		
		Возврат 302
	КонецЕсли;
	
КонецФункции

Функция ОтправитьОтвет(Знач Пользователь, Знач Текст, Знач Клавиатура = "") Экспорт
	
	Атеней				= Справочники.Сообщества.Athenaeum;
	ВКПользователя  	= ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Пользователь, "VK").VK;
	СоздатьКлавиатуру   = Ложь;
	
	Если Не ЗначениеЗаполнено(Клавиатура) Тогда
		СоздатьКлавиатуру = Истина;		
	КонецЕсли;
	
	Если СоздатьКлавиатуру Тогда
		
		МассивДействий = Новый Массив;
		МассивДействий.Добавить("<-");
		МассивДействий.Добавить("->");
		
		Клавиатура = МетодыРаботыVK.СформироватьКлавиатуру(МассивДействий);

	КонецЕсли;
	
	МетодыРаботыVK.НаписатьСообщение(Атеней
			, Текст
			, МетодыРаботыHttp.ЧислоВСтроку(ВКПользователя)
			, ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Атеней, "ВК_communitytoken")
			, Клавиатура);
	
	РегистрыСведений.Диалоги.ЗаписатьСообщениеДиалога(
	Справочники.Пользователи.Ферапонт
	, Пользователь
	, Перечисления.СоцСети.VK
	, Текст);
	
	Возврат Истина;
	
КонецФункции

Процедура ЗаполнитьСтандартныеПараметры(Параметры = "", Сообщество)
	
	Если ТипЗнч(Параметры) <> Тип("Структура") Тогда
		Параметры = Новый Структура;
	КонецЕсли; 
	
	РеквизитыСообщества = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Сообщество, "ВК_access_token,ВК_owner_id,ВК_V,ВК_client_id");
	
	Параметры.Вставить("access_token"	, РеквизитыСообщества.ВК_access_token);
	Параметры.Вставить("from_group"		, "1");
	Параметры.Вставить("owner_id"		, РеквизитыСообщества.ВК_owner_id);
	Параметры.Вставить("v"				, РеквизитыСообщества.ВК_V);
	Параметры.Вставить("app_id"			, РеквизитыСообщества.ВК_client_id);
	
КонецПроцедуры

Функция getUserToken(Параметры) Экспорт

	Параметры.Вставить("client_id"		, "51654824");
	Параметры.Вставить("client_secret"	, "g9E89rlrU2Qzw6fj7b24");

	RU = "redirect_url";
	RC = "response_code";

	Возврат КодироватьСтроку("https://oauth.vk.com/access_token?client_id=" + Параметры["client_id"] + "&client_secret="
		+ Параметры["client_secret"] + "&redirect_uri=" + Параметры[RU] + "&code=" + Параметры[RC], СпособКодированияСтроки.URLВКодировкеURL);
		
КонецФункции

Процедура ОтправитьКнигу(Знач КодКниги, Знач ПользовательИБ, Знач Назначение)

	ЗапрашиваемыйТекст	= Справочники.Произведения.НайтиПоКоду(вРег(КодКниги));

	Если ЗначениеЗаполнено(ЗапрашиваемыйТекст) Тогда

		ТекстОтвета 	= "А вот и ваше произведение - " + "«" + ЗапрашиваемыйТекст.Наименование + "», "
			+ ЗапрашиваемыйТекст.Автор + "!";

		МестоВТексте	= ВернутьМестоВТексте(ПользовательИБ, ЗапрашиваемыйТекст);
		ПоследнийТекст 	= Новый Структура;

		ПоследнийТекст.Вставить("Текст", ЗапрашиваемыйТекст);
		ПоследнийТекст.Вставить("Слов", МестоВТексте);

		Если МестоВТексте = 0 Тогда
			Блок = ВернутьБлок(ПоследнийТекст, "->", ПользовательИБ, Истина);
		Иначе
			Блок = ВернутьБлок(ПоследнийТекст, "<-", ПользовательИБ, Истина);
		КонецЕсли;
		МетодыРаботыTelegram.ОтправитьСообщение(Назначение, ТекстОтвета);
		МетодыРаботыTelegram.ОтправитьСообщение(Назначение, Блок);

	КонецЕсли;
	
КонецПроцедуры

Функция ОтправитьНачалоВК(Знач ПользовательИБ, Знач ПоследнийТекст)
	
			Блок   = "";
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ПотоковоеЧтение.Текст КАК Текст,
		|	ПотоковоеЧтение.Слов КАК Слов
		|ИЗ
		|	РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
		|ГДЕ
		|	ПотоковоеЧтение.Пользователь = &Пользователь
		|	И ПотоковоеЧтение.НачалоВК = ИСТИНА";

		Запрос.УстановитьПараметр("Пользователь", ПользовательИБ);

		РезультатЗапроса       = Запрос.Выполнить();
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();

		Если ВыборкаДетальныеЗаписи.Следующий() Тогда

			ЗапрашиваемыйТекст 	= ВыборкаДетальныеЗаписи.Текст;
			МестоВТексте		= ВыборкаДетальныеЗаписи.Слов;

			МЗ = РегистрыСведений.ПотоковоеЧтение.СоздатьМенеджерЗаписи();
			МЗ.Пользователь = ПользовательИБ;
			МЗ.Текст 		= ЗапрашиваемыйТекст;
			МЗ.Прочитать();

			Если Не МЗ.Выбран() Тогда
				МЗ.Слов = 0;
				МЗ.Дата = ТекущаяДатаСеанса();
			КонецЕсли;

			МЗ.НачалоВК = Ложь;
			МЗ.Записать();

			Если МестоВТексте = 0 Тогда
				Блок = ВернутьБлок(ПоследнийТекст, "->", ПользовательИБ, Ложь);
			Иначе
				Блок = ВернутьБлок(ПоследнийТекст, "<-", ПользовательИБ, Ложь);
			КонецЕсли;

		КонецЕсли;

		ОтветВК = ОтправитьОтвет(ПользовательИБ, "Добро пожаловать в библиотеку Two-Digit Athenaeum!");
		ОтветВК = ОтправитьОтвет(ПользовательИБ, "В этот диалог будут приходить книги, выбранные вами на сайте библиотеки. Для перехода между страницами используйте кнопки в нижней части экрана.
												 |Узнать больше: https://vk.com/@aioniotis-biblioteka-two-digit-athenaeum
												 |
												 |Если же вы хотите связаться с администрацией проекта - пишите сюда:
												 |https://vk.com/sichee");

		Если ЗначениеЗаполнено(Блок) Тогда

			ТекстОтветаПроизведение 	= "А вот и ваше произведение - " + "«" + ЗапрашиваемыйТекст.Наименование + "», "
				+ ЗапрашиваемыйТекст.Автор + "!";

			ОтправитьОтвет(ПользовательИБ, ТекстОтветаПроизведение);
			ОтправитьОтвет(ПользовательИБ, Блок);

		КонецЕсли;

		Возврат ОтветВК
	
КонецФункции

Процедура ОтправитьНовуюКнигу(Знач ЗапрашиваемыйТекст, Знач ПользовательИБ, Знач Смайлы, МассивСообщений)
	
	ТекстОтвета 	= "Да, я знаю такую книгу!" + " Это «" + ЗапрашиваемыйТекст.Наименование + "», "
		+ ЗапрашиваемыйТекст.Автор + ". ";
	МестоВТексте	= ВернутьМестоВТексте(ПользовательИБ, ЗапрашиваемыйТекст);
	ПоследнийТекст 	= Новый Структура;
	ПоследнийТекст.Вставить("Текст", ЗапрашиваемыйТекст);
	ПоследнийТекст.Вставить("Слов", МестоВТексте);

	Если МестоВТексте = 0 Тогда
		Дополнение = "Вы еще не читали эту книгу. Самое время начать!";
		Блок = ВернутьБлок(ПоследнийТекст, "->", ПользовательИБ, Смайлы);
	Иначе
		Дополнение = "Сейчас поищем, где мы остановились в прошлый раз...";
		Блок = ВернутьБлок(ПоследнийТекст, "<-", ПользовательИБ, Смайлы);
	КонецЕсли;

	Если Смайлы Тогда
		МассивСообщений.Добавить("%F0%9F%A7%90");
	КонецЕсли;

	МассивСообщений.Добавить(ТекстОтвета + Дополнение);
	МассивСообщений.Добавить(Блок);
			
КонецПроцедуры

#КонецОбласти
