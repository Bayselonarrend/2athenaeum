#Область ПрограммныйИнтерфейс 

// Обработать входящее сообщение.
// 
// Параметры:
//  СтруктураПараметров - См. МетодыApiСайта.ШаблонСтруктурыПараметровТелеграм
Процедура ОбработатьВходящееСообщение(Знач СтруктураПараметров) Экспорт

    ТекстСообщения                = СтруктураПараметров["ТекстСообщения"];
    ВидСоцСети                    = СтруктураПараметров["ВидСоцСети"];
    Секрет                        = СтруктураПараметров["Секрет"];
    
    МассивСообщений               = Новый Массив;
    ЗапрашиваемыйТекст            = Справочники.Произведения.НайтиПоКоду(вРег(ТекстСообщения));
    Смайлы                        = Ложь;
    НовыйПользователь             = Ложь;
    СоцСетьVK                     = Перечисления.СоцСети.VK;
    СоцСетьTG                     = Перечисления.СоцСети.Telegram;
    ПользовательИБ                = Неопределено;
    ПоследнийТекст                = Неопределено;
    СекретВК                      = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(
    Справочники.Сообщества.Athenaeum, "ВК_communitysecret");
    
    Если ВидСоцСети = СоцСетьVK И Не СекретВК = Секрет Тогда
        Возврат;
    КонецЕсли;
    
    ПолучитьПользователяИТекст(СтруктураПараметров, ПользовательИБ, ПоследнийТекст, Смайлы, НовыйПользователь);

    РегистрыСведений.Диалоги.ЗаписатьСообщениеДиалога(ПользовательИБ, Справочники.Пользователи.Ферапонт, ВидСоцСети,
        ТекстСообщения);

    Если СтрНайти(ТекстСообщения, "/start") > 0 И ВидСоцСети = СоцСетьTG Тогда

        МассивСообщений = ОбработатьНачалоТелеграм(СтруктураПараметров, ПользовательИБ, НовыйПользователь);

    ИначеЕсли (ТекстСообщения = "Начать" Или ТекстСообщения = "Start") И ВидСоцСети = СоцСетьVK Тогда

        МассивСообщений = ОбработатьНачалоВК(ПользовательИБ, ПоследнийТекст);

    ИначеЕсли ТекстСообщения = "Ежедневно" Или ТекстСообщения = "Еженедельно" Или ТекстСообщения = "Не напоминать" Тогда

        МассивСообщений =  ОбработатьИзменениеОповещений(ПользовательИБ, ВидСоцСети, ТекстСообщения);

    ИначеЕсли (ТекстСообщения = "->" Или ТекстСообщения = "<-") Тогда

        МассивСообщений = ОтправитьНовуюСтраницу(СтруктураПараметров, ПоследнийТекст, ПользовательИБ, Смайлы);

    ИначеЕсли ЗначениеЗаполнено(ЗапрашиваемыйТекст) Тогда

        МассивСообщений = ОтправитьНовуюКнигу(ЗапрашиваемыйТекст, ПользовательИБ, Смайлы);

    Иначе

        МассивСообщений = ОтправитьОшибкуНеНайдено(ПользовательИБ, Смайлы);

    КонецЕсли;
    
    Если Не МассивСообщений.Количество() = 0 Тогда
        РассылкаОтветов(ВидСоцСети, ПользовательИБ, МассивСообщений);
    КонецЕсли;

КонецПроцедуры

// Авторизовать пользователя на сайте.
// 
// Параметры:
//  Токен - Строка - Временный токен для получения данных о пользователе
//  Печенька - Строка - Печенька из параметров авторизации
//  КодКниги - Строка -  Код книги
// 
// Возвращаемое значение:
//  Число -  Числовой код ответа HTTP - 200 или 302
Функция АвторизоватьПользователяНаСайте(Знач Токен, Знач Печенька, Знач КодКниги = "") Экспорт
    
    URL = "https://api.athenaeum.digital/u/hs/bot/vklogin?uuid=" 
        + Печенька 
        + ?(ЗначениеЗаполнено(КодКниги), "_" + КодКниги, "");
    
    ДанныеПользователя    = ПолучитьДанныеПользователя(Токен, URL);   
    Заполнение            = Ложь;      
    ИД                    = ДанныеПользователя["id"];
    Имя                   = ДанныеПользователя["first_name"] + " " + ДанныеПользователя["last_name"];    
    ПользовательИБ        = Справочники.Пользователи.НайтиПоРеквизиту("VK", Строка(ДанныеПользователя["id"]));
    
    Если ЗначениеЗаполнено(ПользовательИБ) 
            И ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПользовательИБ, "Наименование") = "Новый" Тогда
                
        СуществующийПользователь = ПользовательИБ.ПолучитьОбъект();
        СуществующийПользователь.Наименование = Имя;
        СуществующийПользователь.Записать();
    КонецЕсли;
    
    ПользовательПоПеченью   = МетодыApiСайта.ВернутьПользователяПоCookie(Печенька);
    ПользовательПоVK        = ПользовательИБ;
    ПользовательИБ          = ?(ЗначениеЗаполнено(ПользовательПоПеченью)
    , ПользовательПоПеченью
    , ПользовательИБ);
        
    Если Не ЗначениеЗаполнено(ПользовательИБ) Тогда
        
        НовыйПользователь     = Справочники.Пользователи.СоздатьЭлемент();
        
        НовыйПользователь.ПерсональныеНастройки  = Справочники.ПерсональныеНастройки.Инициализировать(Имя);
        НовыйПользователь.VK                     = ИД;
        НовыйПользователь.Наименование           = Имя;
        НовыйПользователь.ДатаРегистрации        = ТекущаяДатаСеанса();
        НовыйПользователь.Записать();
        
        ПользовательИБ = НовыйПользователь.Ссылка;
        
    Иначе
        
        Если Не ЗначениеЗаполнено(ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПользовательИБ, "VK")) Тогда

            СуществующийПользователь = ПользовательИБ.ПолучитьОбъект();

            Если ЗначениеЗаполнено(ПользовательПоVK) Тогда
                ОшибочныйПользователь = ПользовательПоVK.ПолучитьОбъект();
                СуществующийПользователь.РазрешилПисатьVK = ОшибочныйПользователь.РазрешилПисатьVK;
                ОшибочныйПользователь.Удалить();
            КонецЕсли;

            СуществующийПользователь.VK = ИД;
            СуществующийПользователь.Записать();
            Заполнение = Истина;

        КонецЕсли;
        
    КонецЕсли;       
        
    СоздатьСеанс(Заполнение, Печенька, ПользовательИБ);
    Возврат ОтправитьКнигуСПроверкойРазрешенияВК(КодКниги, ПользовательИБ);
    
КонецФункции

// Получить данные пользователя ВК.
// 
// Параметры:
//  Код - Строка -  Код из авторизации на сайте или id пользователя
//  URL - Строка -  Redirect URL (если используется код авторизации, для получения по id не нужен)
// 
// Возвращаемое значение:
// Структура - Ответ ВК:
// *first_name - Строка - Имя пользователя
// *last_name - Строка - Фамилия пользователя
// *id - Строка - id пользователя 
Функция ПолучитьДанныеПользователя(Знач Код, Знач URL = "") Экспорт
	
	Линк          = "https://api.vk.com/method/users.get";
    Параметры     = Новый Структура;
    RU            = "redirect_url";
    RC            = "response_code";
    ДлинаID       = 9;
    
    client_id         = "client_id";
    client_secret     = "client_secret";
    
	ЗаполнитьСтандартныеПараметры(Справочники.Сообщества.Athenaeum, Параметры);
	
	Если СтрДлина(Строка(Код)) = ДлинаID Тогда
		
		Параметры.Вставить("user_ids", Код);
	Иначе
		
		Параметры.Вставить("response_code"   , Код);
		Параметры.Вставить("redirect_url"    , КодироватьСтроку(URL, СпособКодированияСтроки.КодировкаURL));
			
		ТокенПользователя = КодироватьСтроку("https://oauth.vk.com/access_token?client_id=" 
		+ Параметры[client_id] 
		+ "&client_secret="
		+ Параметры[client_secret] 
		+ "&redirect_uri=" 
		+ Параметры[RU] 
		+ "&code=" 
		+ Параметры[RC], СпособКодированияСтроки.URLВКодировкеURL);
		
		ПараметрыОтвета = МетодыРаботыHttp.Get(ТокенПользователя, Параметры);
		Параметры.Вставить("access_token", ПараметрыОтвета["access_token"]);
				
	КонецЕсли;
	
	Ответ = МетодыРаботыHttp.Get(Линк, Параметры);
	
	Возврат Ответ["response"][0];

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область Общие

Процедура ПолучитьПользователяИТекст(Знач СтруктураПараметров
    , ПользовательИБ
    , ПоследнийТекст
    , Смайлы
    , НовыйПользователь)
    
    ИдентификаторПользователя    = Строка(СтруктураПараметров["ИдентификаторПользователя"]);
    ИмяПользователя              = СтруктураПараметров["ИмяПользователя"];
    ВидСоцСети                   = СтруктураПараметров["ВидСоцСети"];
    Никнейм                      = СтруктураПараметров["Никнейм"];
    СоцСетьVK                    = Перечисления.СоцСети.VK;
    СоцСетьTG                    = Перечисления.СоцСети.Telegram;
    
    Если ЗначениеЗаполнено(ИдентификаторПользователя) Тогда

        Если ВидСоцСети = СоцСетьVK Тогда
            
            ПользовательИБ    = Справочники.Пользователи.НайтиПоРеквизиту("VK", ИдентификаторПользователя);
            Смайлы            = Ложь;

        ИначеЕсли ВидСоцСети = СоцСетьTG Тогда
            
            ПользовательИБ    = Справочники.Пользователи.НайтиПоРеквизиту("Telegram", ИдентификаторПользователя);
            Смайлы            = Истина;
            
        Иначе 
            
            Возврат;
            
        КонецЕсли;

    КонецЕсли;

    Если ЗначениеЗаполнено(ПользовательИБ) Тогда
        ПоследнийТекст    = ВернутьПоследнийТекст(ПользовательИБ);
    Иначе
        НовыйПользователь                         = Справочники.Пользователи.СоздатьЭлемент();
        НовыйПользователь.ПерсональныеНастройки   = Справочники.ПерсональныеНастройки.Инициализировать(ИмяПользователя);
        НовыйПользователь.Telegram                = ?(ВидСоцСети = СоцСетьTG, ИдентификаторПользователя, "");
        НовыйПользователь.VK                      = ?(ВидСоцСети = СоцСетьVK, ИдентификаторПользователя, "");
        НовыйПользователь.РазрешилПисатьVK        = ?(ВидСоцСети = СоцСетьVK, Истина, Ложь);
        НовыйПользователь.Наименование            = ИмяПользователя;
        НовыйПользователь.ДатаРегистрации         = ТекущаяДатаСеанса();
        НовыйПользователь.Никнейм                 = Никнейм;
        НовыйПользователь.Записать();
        
        ПользовательИБ                            = НовыйПользователь.Ссылка;
        ПоследнийТекст                            = Неопределено;
        НовыйПользователь                         = Истина;        
    КонецЕсли;
    
    Если ВидСоцСети = СоцСетьVK Тогда
        ЗаписатьРазрешениеВК(ПользовательИБ);
    КонецЕсли;
    
КонецПроцедуры

Процедура ОбработатьЗаписьНовогоБлока(Знач СтруктураПараметров, ТекстСообщения)
    
    ПользовательИБ    = СтруктураПараметров["ПользовательИБ"];
    Текст             = СтруктураПараметров["Текст"];
    НовыйБлок         = СтруктураПараметров["НовыйБлок"];
    ТекущаяСтраница   = СтруктураПараметров["ТекущаяСтраница"];
    СтраницВсего      = СтруктураПараметров["СтраницВсего"];
    Направление       = СтруктураПараметров["Направление"];
    ОднаСтраница      = СтруктураПараметров["ОднаСтраница"];
    НеОтнимать        = СтруктураПараметров["НеОтнимать"];
    ЭтоТГ             = СтруктураПараметров["ЭтоТГ"];
    ПоследнийТекст    = СтруктураПараметров["ПоследнийТекст"];
    
    МЗ = РегистрыСведений.ПотоковоеЧтение.СоздатьМенеджерЗаписи();
    МЗ.Пользователь         = ПользовательИБ;
    МЗ.Текст                = Текст;
    МЗ.Прочитать();
    МЗ.Пользователь         = ПользовательИБ;
    МЗ.Текст                = Текст;
    МЗ.Дата                 = ТекущаяДатаСеанса();
        
    Если ЗначениеЗаполнено(ТекстСообщения) Тогда
        
        ЧтениеНовых = НовыйБлок > МЗ.МаксимумСлов;
        
        ТекстСообщения = ТекстСообщения 
            + Символы.ПС 
            + Символы.ПС 
            + Строка(ТекущаяСтраница) 
            + "/" 
            + Строка(СтраницВсего) 
            + " | " 
            + Текст.Код;
            
        МЗ.Слов                = НовыйБлок;
        МЗ.МаксимумСлов        = ?(ЧтениеНовых, НовыйБлок, МЗ.МаксимумСлов);
        СловКПрогрессу         = ?(Направление = "->", ОднаСтраница, -ОднаСтраница);
        СловКПрогрессу         = ?(НеОтнимать, 0, СловКПрогрессу);
        
        ДП = РегистрыСведений.ДневнойПрогресс.СоздатьМенеджерЗаписи();
        ДП.Пользователь     =  ПользовательИБ;
        ДП.ДеньНедели       =  ИнструментарийВызовСервера.ВернутьДеньНедели();
        ДП.Прочитать();
        ДП.Пользователь     =  ПользовательИБ;
        ДП.ДеньНедели       =  ИнструментарийВызовСервера.ВернутьДеньНедели();
        
        Если ЧтениеНовых Тогда
            ДП.КоличествоСлов     = ?(ДП.Дата = НачалоДня(ТекущаяДатаСеанса())
                , ДП.КоличествоСлов + СловКПрогрессу
                , СловКПрогрессу);
        КонецЕсли;
        
        ДП.Дата = НачалоДня(ТекущаяДатаСеанса());
        ДП.Записать(Истина);
                
    Иначе
        
        Если ЭтоТГ Тогда 
            МетодыРаботыTelegram.ОтправитьСообщение(ПользовательИБ.Telegram, "%F0%9F%98%AE"); 
        КонецЕсли;
        
        ТекстСообщения = "Ого! Вы только что закончили читать «" 
            + ПоследнийТекст.Текст.Наименование 
            + "»!"
            + Символы.ПС
            + Символы.ПС
            + "Эта книга помечена как прочитанная в вашем списке чтения. "
            + "Ну а сейчас, похоже, самое время выбирать новое произведение!";
                
        МЗ.Слов          = 0;
        МЗ.Завершена     = Истина;
        
    КонецЕсли;
    
    МЗ.Записать(Истина);
    
КонецПроцедуры

Процедура УдалитьЗапрещенныеСимволы(Текст)
    
    МассивЗапрещенныхСимволов = Новый Соответствие;  
    МассивЗапрещенныхСимволов.Вставить("&#", "-");
    МассивЗапрещенныхСимволов.Вставить("„" , """");
    МассивЗапрещенныхСимволов.Вставить("“" , """");
    МассивЗапрещенныхСимволов.Вставить("_" , "-");
    МассивЗапрещенныхСимволов.Вставить("+" , " ");
    МассивЗапрещенныхСимволов.Вставить("*" , ".");
    МассивЗапрещенныхСимволов.Вставить("~" , ".");
    МассивЗапрещенныхСимволов.Вставить("`" , ".");
    МассивЗапрещенныхСимволов.Вставить("<" , "(");
    МассивЗапрещенныхСимволов.Вставить(">" , ")");
    МассивЗапрещенныхСимволов.Вставить("#" , ".");
    МассивЗапрещенныхСимволов.Вставить("=" , "-");
    МассивЗапрещенныхСимволов.Вставить("{" , "(");
    МассивЗапрещенныхСимволов.Вставить("}" , ")");
    МассивЗапрещенныхСимволов.Вставить("&" , "8");
    МассивЗапрещенныхСимволов.Вставить("°" , "o");
    МассивЗапрещенныхСимволов.Вставить("[" , "(");
    МассивЗапрещенныхСимволов.Вставить("]" , ")");
    
    Для Каждого ЗапрещенныйСимвол Из МассивЗапрещенныхСимволов Цикл
        Текст = СтрЗаменить(Текст, ЗапрещенныйСимвол.Ключ, ЗапрещенныйСимвол.Значение);
    КонецЦикла;
    
КонецПроцедуры

Процедура СоздатьСеанс(Знач Заполнение, Знач Печенька, Знач ПользовательИБ)
    
    Если ЗначениеЗаполнено(Печенька) И Не Заполнение Тогда
        МЗ = РегистрыСведений.АктивныеСеансы.СоздатьМенеджерЗаписи();
        МЗ.Cookie          = Печенька;
        МЗ.Дата            = ТекущаяДатаСеанса();
        МЗ.Пользователь    = ПользовательИБ;
        МЗ.Записать(Истина);
    КонецЕсли;
    
КонецПроцедуры

Процедура ПолучитьОтветПоКниге(Знач КодКниги, Знач ПользовательИБ, МассивСообщений)

    ЗапрашиваемыйТекст = Справочники.Произведения.НайтиПоКоду(вРег(КодКниги));

    Если ЗначениеЗаполнено(ЗапрашиваемыйТекст) Тогда

        ТекстОтвета = "А вот и ваше произведение - " 
        + "«" 
        + ЗапрашиваемыйТекст.Наименование 
        + "», "
        + ЗапрашиваемыйТекст.Автор 
        + "!";

        МестоВТексте    = ВернутьМестоВТексте(ПользовательИБ, ЗапрашиваемыйТекст);
        ПоследнийТекст  = Новый Структура;

        ПоследнийТекст.Вставить("Текст", ЗапрашиваемыйТекст);
        ПоследнийТекст.Вставить("Слов", МестоВТексте);

        Если МестоВТексте = 0 Тогда
            Блок = ВернутьБлок(ПоследнийТекст, "->", ПользовательИБ, Истина);
        Иначе
            Блок = ВернутьБлок(ПоследнийТекст, "<-", ПользовательИБ, Истина);
        КонецЕсли;
        
        МассивСообщений.Добавить(ТекстОтвета);
        МассивСообщений.Добавить(Блок);

    КонецЕсли;
    
КонецПроцедуры

Процедура РассылкаОтветов(Знач ВидСоцСети, Знач ПользовательИБ, Знач МассивСообщений)
    
    Попытка
        
        Если ВидСоцСети = Перечисления.СоцСети.VK Тогда
            
            Для Каждого Сообщение Из МассивСообщений Цикл
                ОтправитьОтвет(ПользовательИБ, Сообщение);
            КонецЦикла;

        ИначеЕсли ВидСоцСети = Перечисления.СоцСети.Telegram Тогда
            
            ИдентификаторЧата = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПользовательИБ, "Telegram");
            
            Для Каждого Сообщение Из МассивСообщений Цикл
                МетодыРаботыTelegram.ОтправитьСообщение(ИдентификаторЧата, Сообщение);
            КонецЦикла;
            
        Иначе

            ВызватьИсключение "МетодыБота.РассылкаОтветов: Не ВК и не Телеграм!";

        КонецЕсли;
        
    Исключение
        ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
    КонецПопытки;
    
КонецПроцедуры

Функция ОбработатьИзменениеОповещений(Знач ПользовательИБ, Знач ВидСоцСети, Знач Текст)
    
    МассивСообщений = Новый Массив; 
    Текст           = нРег(СокрЛП(Текст));
    
    Если ЗначениеЗаполнено(ПользовательИБ) Тогда
        
        РегистрыСведений.Диалоги.ЗаписатьСообщениеДиалога(ПользовательИБ
            , Справочники.Пользователи.Ферапонт
            , ВидСоцСети
            , Текст);

        НастройкиПользователя     = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПользовательИБ
            , "ПерсональныеНастройки");
        ОбъектНастроек            = НастройкиПользователя.ПолучитьОбъект();
        
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
    
    МассивСообщений.Добавить(ТекстОтвета);
    Возврат МассивСообщений;
    
КонецФункции    

Функция ОтправитьНовуюСтраницу(Знач СтруктураПараметров, Знач ПоследнийТекст, Знач ПользовательИБ, Знач Смайлы)
    
    МассивСообщений       = Новый Массив;
    ТекстСообщения        = СтруктураПараметров["ТекстСообщения"];
    
    Если ЗначениеЗаполнено(ПоследнийТекст) Тогда
        МассивСообщений.Добавить(ВернутьБлок(ПоследнийТекст, ТекстСообщения, ПользовательИБ, Смайлы));
    Иначе
        
        Если Смайлы Тогда
            МассивСообщений.Добавить("%F0%9F%A4%AF");
        КонецЕсли;
        
        МассивСообщений.Добавить(
            "Не может быть! Кажется, я забыл, что вы читали. Ужас! "
            + "Пожалуйста, выберите нужную книгу еще раз на https://athenaeum.digital");
    КонецЕсли;

    Возврат МассивСообщений;
    
КонецФункции

Функция ОтправитьНовуюКнигу(Знач ЗапрашиваемыйТекст, Знач ПользовательИБ, Знач Смайлы)
    
    МассивСообщений = Новый Массив;
    
    ТекстОтвета     = "Да, я знаю такую книгу!" + " Это «" + ЗапрашиваемыйТекст.Наименование + "», "
        + ЗапрашиваемыйТекст.Автор + ". ";
    МестоВТексте    = ВернутьМестоВТексте(ПользовательИБ, ЗапрашиваемыйТекст);
    ПоследнийТекст     = Новый Структура;
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
            
    Возврат МассивСообщений;
    
КонецФункции

Функция ОтправитьОшибкуНеНайдено(Знач ПользовательИБ, Знач Смайлы)

    МассивСообщений = Новый Массив;
        
    Если Смайлы Тогда
        МассивСообщений.Добавить("%F0%9F%A4%94");
    КонецЕсли;
    
    МассивСообщений.Добавить(
                "Хммм... Нет, такой книги у меня нет. Попробуйте ввести другой код книги с https://athenaeum.digital");

    Возврат МассивСообщений;
    
КонецФункции

Функция ВернутьБлок(Знач ПоследнийТекст
    , Знач Направление
    , Знач ПользовательИБ
    , Знач ЭтоТГ = Ложь)
    
    Текст           = Справочники.Произведения.ПустаяСсылка();
    ТекстСообщения  = "";
    Слов            = 0;
    ОднаСтраница    = 70;
    ПрошлаяСтраница = 140;
    НеОтнимать      = Ложь;
    
    Если ЗначениеЗаполнено(ПоследнийТекст) Тогда
        
        Текст           = ПоследнийТекст.Текст;
        Слов            = ?(Направление = "->", ПоследнийТекст.Слов, ПоследнийТекст.Слов - ПрошлаяСтраница);
        НеОтнимать      = (Слов < 0);
        Слов            = ?(Слов > 0, Слов, 0); 
        НовыйБлок       = Слов + ОднаСтраница;
        ТекущаяСтраница = НовыйБлок / ОднаСтраница;
        ТекстСтр        = Текст.ТекстМассив.Получить();
        СтраницВсего    = Цел(ТекстСтр.Количество() / ОднаСтраница) + 1;
        
        Н = Слов;
        
        Пока Н <> НовыйБлок    Цикл
            Если Н > ТекстСтр.Количество() - 1 Тогда
                Прервать;
            КонецЕсли;
            ТекстСообщения = ТекстСообщения + " " + ТекстСтр[Н];    
            Н = Н +  1; 
            
        КонецЦикла;
        
        СтруктураПараметров = Новый Структура;
        СтруктураПараметров.Вставить("ПользовательИБ"   , ПользовательИБ);
        СтруктураПараметров.Вставить("Текст"            , Текст);
        СтруктураПараметров.Вставить("НовыйБлок"        , НовыйБлок);
        СтруктураПараметров.Вставить("ТекущаяСтраница"  , ТекущаяСтраница);
        СтруктураПараметров.Вставить("СтраницВсего"     , СтраницВсего);
        СтруктураПараметров.Вставить("Направление"      , Направление);
        СтруктураПараметров.Вставить("ОднаСтраница"     , ОднаСтраница);
        СтруктураПараметров.Вставить("НеОтнимать"       , НеОтнимать);
        СтруктураПараметров.Вставить("ЭтоТГ"            , ЭтоТГ);
        СтруктураПараметров.Вставить("ПоследнийТекст"   , ПоследнийТекст);
        
    Иначе 
        
        Возврат "";
                        
    КонецЕсли;
    
    ОбработатьЗаписьНовогоБлока(СтруктураПараметров, ТекстСообщения);    
    УдалитьЗапрещенныеСимволы(ТекстСообщения);
        
    Возврат ТекстСообщения; 
    
КонецФункции

Функция ВернутьМестоВТексте(Знач ПользовательИБ, Знач Текст)
    
    Слов = 0;
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    ПотоковоеЧтение.Слов КАК Слов
        |ИЗ
        |    РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
        |ГДЕ
        |    ПотоковоеЧтение.Пользователь = &ИдентификаторЧата
        |    И ПотоковоеЧтение.Текст = &Текст";
    
    Запрос.УстановитьПараметр("ИдентификаторЧата", ПользовательИБ);
    Запрос.УстановитьПараметр("Текст", Текст);
    
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Если ВыборкаДетальныеЗаписи.Следующий() Тогда
        Слов = ВыборкаДетальныеЗаписи.Слов;
    КонецЕсли;
    
    Возврат Слов;
    
КонецФункции

#КонецОбласти

#Область VK

Процедура ЗаполнитьСтандартныеПараметры(Сообщество, Параметры = "")
    
    Если ТипЗнч(Параметры) <> Тип("Структура") Тогда
        Параметры = Новый Структура;
    КонецЕсли; 
    
    РеквизитыСообщества = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Сообщество
        , "ВК_access_token,ВК_owner_id,ВК_V,ВК_client_id,ВК_bot_secret,ВК_bot_id");
    
    Параметры.Вставить("access_token"    , РеквизитыСообщества.ВК_access_token);
    Параметры.Вставить("from_group"      , "1");
    Параметры.Вставить("owner_id"        , РеквизитыСообщества.ВК_owner_id);
    Параметры.Вставить("v"               , РеквизитыСообщества.ВК_V);
    Параметры.Вставить("app_id"          , РеквизитыСообщества.ВК_client_id);
    Параметры.Вставить("client_secret"   , РеквизитыСообщества.ВК_bot_secret);
    Параметры.Вставить("client_id"       , РеквизитыСообщества.ВК_bot_id);
    
КонецПроцедуры

Процедура ЗаписатьРазрешениеВК(Знач ПользовательИБ)
    
    Если Не ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПользовательИБ, "РазрешилПисатьVK") Тогда
        ПользовательОбъект = ПользовательИБ.ПолучитьОбъект();
        ПользовательОбъект.РазрешилПисатьVK = Истина;
        ПользовательОбъект.Записать();
    КонецЕсли;
    
КонецПроцедуры

Функция ВернутьПоследнийТекст(Знач ПользовательИБ)
    
    ПоследнийТекст = Неопределено;
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
    "ВЫБРАТЬ ПЕРВЫЕ 1
    |    ПотоковоеЧтениеСрезПоследних.Текст КАК Текст,
    |    ПотоковоеЧтениеСрезПоследних.Слов КАК Слов
    |ИЗ
    |    РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтениеСрезПоследних
    |ГДЕ
    |    ПотоковоеЧтениеСрезПоследних.Пользователь = &Чат
    |    И ПотоковоеЧтениеСрезПоследних.Текст <> ЗНАЧЕНИЕ(Справочник.Произведения.Оповещение)
    |
    |УПОРЯДОЧИТЬ ПО
    |    ПотоковоеЧтениеСрезПоследних.Дата УБЫВ";
    
    Запрос.УстановитьПараметр("Чат", ПользовательИБ);
    
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Если ВыборкаДетальныеЗаписи.Следующий() Тогда
        ПоследнийТекст = Новый Структура;
        ПоследнийТекст.Вставить("Текст", ВыборкаДетальныеЗаписи.Текст);
        ПоследнийТекст.Вставить("Слов" , ВыборкаДетальныеЗаписи.Слов);
    КонецЕсли;
    
    Возврат ПоследнийТекст;

КонецФункции

Функция ОтправитьОтвет(Знач Пользователь, Знач Текст, Знач Клавиатура = "") Экспорт
    
    Атеней              = Справочники.Сообщества.Athenaeum;
    ВКПользователя      = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Пользователь, "VK");
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

Функция ОбработатьНачалоВК(Знач ПользовательИБ, Знач ПоследнийТекст)
    
        МассивСообщений     = Новый Массив;
        Блок               = "";
        
        Запрос = Новый Запрос;
        Запрос.Текст =
        "ВЫБРАТЬ
        |    ПотоковоеЧтение.Текст КАК Текст,
        |    ПотоковоеЧтение.Слов КАК Слов
        |ИЗ
        |    РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
        |ГДЕ
        |    ПотоковоеЧтение.Пользователь = &Пользователь
        |    И ПотоковоеЧтение.НачалоВК = ИСТИНА";

        Запрос.УстановитьПараметр("Пользователь", ПользовательИБ);

        РезультатЗапроса       = Запрос.Выполнить();
        ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();

        Если ВыборкаДетальныеЗаписи.Следующий() Тогда

            ЗапрашиваемыйТекст  = ВыборкаДетальныеЗаписи.Текст;
            МестоВТексте        = ВыборкаДетальныеЗаписи.Слов;

            МЗ = РегистрыСведений.ПотоковоеЧтение.СоздатьМенеджерЗаписи();
            МЗ.Пользователь = ПользовательИБ;
            МЗ.Текст        = ЗапрашиваемыйТекст;
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

        МассивСообщений.Добавить("Добро пожаловать в библиотеку Two-Digit Athenaeum!");
        МассивСообщений.Добавить( 
            "В этот диалог будут приходить книги, выбранные вами на сайте библиотеки. "
            + "Для перехода между страницами используйте кнопки в нижней части экрана.
            |Узнать больше: https://vk.com/@aioniotis-biblioteka-two-digit-athenaeum
            |
            |Если же вы хотите связаться с администрацией проекта - пишите сюда:
            |https://vk.com/sichee");

        Если ЗначениеЗаполнено(Блок) Тогда

            ТекстОтветаПроизведение     = "А вот и ваше произведение - " 
                + "«" 
                + ЗапрашиваемыйТекст.Наименование 
                + "», "
                + ЗапрашиваемыйТекст.Автор 
                + "!";

            МассивСообщений.Добавить(ТекстОтветаПроизведение);
            МассивСообщений.Добавить(Блок);

        КонецЕсли;

        Возврат МассивСообщений;
    
КонецФункции

Функция ОтправитьКнигуСПроверкойРазрешенияВК(Знач КодКниги, Знач ПользовательИБ)
    
    Если ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(ПользовательИБ, "РазрешилПисатьVK") Тогда
        
        МассивСообщений = Новый Массив; 
        ПеречислениеВК    = ПредопределенноеЗначение("Перечисление.СоцСети.VK");
        
        ПолучитьОтветПоКниге(КодКниги, ПользовательИБ, МассивСообщений);        
        РассылкаОтветов(ПеречислениеВК, ПользовательИБ, МассивСообщений);
        Возврат 200;
        
    Иначе
        
        Если ЗначениеЗаполнено(КодКниги)  Тогда
            
            ЗапрашиваемыйТекст    = Справочники.Произведения.НайтиПоКоду(вРег(КодКниги));
            
            Если ЗначениеЗаполнено(ЗапрашиваемыйТекст) Тогда
                
                МЗ = РегистрыСведений.ПотоковоеЧтение.СоздатьМенеджерЗаписи();
                МЗ.Пользователь  = ПользовательИБ;
                МЗ.Текст         = ЗапрашиваемыйТекст;
                МЗ.Прочитать();
                
                МЗ.Дата = ТекущаяДатаСеанса();
                
                МЗ.Пользователь  = ПользовательИБ;
                МЗ.Текст         = ЗапрашиваемыйТекст;
                
                МЗ.НачалоВК = Истина;
                МЗ.Записать();
                
            КонецЕсли;
            
        КонецЕсли;
        
        Возврат 302;
        
        КонецЕсли;
        
КонецФункции

#КонецОбласти

#Область Telegram

Функция ОбработатьНачалоТелеграм(СтруктураПараметров, ПользовательИБ, НовыйПользователь)
    
    МассивСообщений             = Новый Массив;
    ИдентификаторПользователя   = СтруктураПараметров["ИдентификаторПользователя"];
    ТекстСообщения              = СтруктураПараметров["ТекстСообщения"];
    ИмяПользователя             = СтруктураПараметров["ИмяПользователя"];
    Никнейм                     = СтруктураПараметров["Никнейм"];

    Если ЗначениеЗаполнено(СтрЗаменить(ТекстСообщения, "/start", "")) Тогда
        Возврат ОбработкаАвторизацииТелеграм(ТекстСообщения, ПользовательИБ, ИмяПользователя,
            ИдентификаторПользователя, Никнейм, НовыйПользователь);
    Иначе

        МассивСообщений.Добавить("%F0%9F%98%83");
        МассивСообщений.Добавить("Добро пожаловать! 
                                 |Отправьте мне код книги или авторизуйтесь на athenaeum.digital "
            + "чтобы начать читать книги в нашей онлайн библиотеке!");

        Возврат МассивСообщений;

    КонецЕсли;
    
КонецФункции

Функция ОбработкаАвторизацииТелеграм(Знач ТекстСообщения
        , Знач ПользовательИБ
        , Знач ИмяПользователя
        , Знач ИдентификаторПользователя
        , Знач Никнейм
        , Знач НовыйПользователь)
    
    Попытка
        
        Печенька                 = СтрЗаменить(ТекстСообщения  , "/start ", "");
        Печенька                 = СтрЗаменить(Печенька        , "/start", "");
        
        МассивСообщений          = Новый Массив;
        МассивЗапрос             = Новый Массив;
        Смайл                    = "";
        ТекстОтвет               = "";
        КодКниги                 = "";
        
        Если СтрНайти(Печенька, "_")  > 0 Тогда
            
            МассивЗапрос    = СтрРазделить(Печенька, "_", Истина);
            Печенька        = МассивЗапрос[0];
            КодКниги        = МассивЗапрос[1];
            
        КонецЕсли;
        
        ПользовательПоПеченью   = МетодыApiСайта.ВернутьПользователяПоCookie(Печенька);
        ПользовательПоTG        = ПользовательИБ;
        Заполнение              = Ложь;
        ПользовательИБ          = ?(ЗначениеЗаполнено(ПользовательПоПеченью)
        , ПользовательПоПеченью
        , ПользовательИБ);
                
        Если НовыйПользователь И Не ЗначениеЗаполнено(ПользовательПоПеченью) Тогда
            
            Смайл = "%F0%9F%91%8B";
            ТекстОтвет =
            "Привет! Я - Ферапонт, хранитель библиотеки Two-Digit Athenaeum. 
            |У меня вы можете получить интересующие вас произведения из архива по кодам или нажав на кнопку "
            + "отправки со страницы книги: тексты я присылаю небольшими частями в этом чате. 
            |
            |Когда прочитаете страницу, просто нажмите кнопку и получите следующую. "
            + "Одновременно можно читать сколько угодно текстов: я запомню, где вы остановились, если вдруг "
            + "решите вернуться к произведению позже. Удачи!";
                            
        ИначеЕсли Не ЗначениеЗаполнено(ПользовательИБ.Telegram) Тогда
            
            ОшибочныйПользователь                = ПользовательПоTG.ПолучитьОбъект();
            ОшибочныйПользователь.Удалить();
            
            СуществующийПользователь             = ПользовательИБ.ПолучитьОбъект();
            СуществующийПользователь.Telegram    = ИдентификаторПользователя;
            СуществующийПользователь.Записать();
            
            Заполнение = Истина;
            
            Смайл        = "%F0%9F%91%8C";
            ТекстОтвет   = "Ваш аккаунт Telegram привязан и вы можете продолжить пользоваться библиотекой. "
            + "Спасибо, что остаетесь с нами!";            
            
        Иначе
            
            Смайл        = "%F0%9F%91%8B";            
            ТекстОтвет   = "Добро пожаловать обратно - вы авторизованы!";                
                        
        КонецЕсли;
        
        МассивСообщений.Добавить(Смайл);
        МассивСообщений.Добавить(ТекстОтвет);
        
        СоздатьСеанс(Заполнение, Печенька, ПользовательИБ);
        ПолучитьОтветПоКниге(КодКниги, ПользовательИБ, МассивСообщений);
                
        Возврат МассивСообщений;
        
    Исключение
        
        ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
        Возврат МассивСообщений;
        
    КонецПопытки;
    
КонецФункции

#КонецОбласти

#КонецОбласти
