#Область ПрограммныйИнтерфейс

// Обновить информацию о книге на сайте
// 
// Параметры:
//  Книга - СправочникСсылка.Произведения - Книга для обновления
Процедура ОбновитьКнигу(Книга) Экспорт
    
    Автор = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Книга, "Автор");
    
    МассивКниги = Новый Массив;
    МассивКниги.Добавить(Книга);
    ОбновитьСтраницыКниг(МассивКниги);
    
    МассивАвтора = Новый Массив;
    МассивАвтора.Добавить(Автор);
    ОбновитьСтраницыАвторов(МассивАвтора);
    
    СформироватьIndex();
    СформироватьСайтмап();
    
КонецПроцедуры

// Обновить страницы книг.
// 
// Параметры:
//  СписокКниг - Массив из СправочникСсылка.Произведения - Список книг
Процедура ОбновитьСтраницыКниг(СписокКниг) Экспорт 
    
    КаталогСайта = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Справочники.Сайты.Athenaeum, "ПапкаДанныхСайта");
    
    Для Каждого Книга Из СписокКниг Цикл
        
        ПоляКниги  = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Книга
            , "Наименование,Автор,Описание,Код,НаСайте");
   
        ПоляАвтора = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(ПоляКниги.Автор
            , "Имя,Фамилия,Код");
        

        Если Не ПоляКниги.НаСайте Тогда
            Продолжить;    
        КонецЕсли;
        
        СтруктураКниги = Новый Структура;
        СтруктураКниги.Вставить("title"         , ПоляКниги.Наименование);
        СтруктураКниги.Вставить("author"        , ПоляАвтора.Имя + " " + ПоляАвтора.Фамилия);
        СтруктураКниги.Вставить("description"   , СтрЗаменить(ПоляКниги.Описание, Символы.ПС, "<br/>"));
        СтруктураКниги.Вставить("id"            , ПоляКниги.Код);
        СтруктураКниги.Вставить("author_id"     , ПоляАвтора.Код);
        
        ПутьККниге       = КаталогСайта + "\books\" + ПоляКниги.Код;
        КаталогКниги     = Новый Файл(ПутьККниге);
        
        Если Не КаталогКниги.Существует() Тогда
            СоздатьКаталог(ПутьККниге);
        КонецЕсли;
        
        ДД = Книга.КартинкаДвоичные.Получить();
        ДД.Записать(КаталогКниги.ПолноеИмя + "\0.webp");
        
        МетодыОбработкиИзображений.СоздатьКарточки(КаталогКниги.ПолноеИмя + "\0.webp");
        ИнструментарийВызовСервера.JSONВФайл(СтруктураКниги, ПутьККниге + "\data.json"); 

    КонецЦикла;
    
КонецПроцедуры

// Обновить страницы авторов.
// 
// Параметры:
//  СписокАвторов - Массив из СправочникСсылка.Люди -  Список авторов
Процедура ОбновитьСтраницыАвторов(СписокАвторов) Экспорт
    
    Произведения = ПолучитьСписокКнигАвторов(СписокАвторов);
    КаталогСайта = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Справочники.Сайты.Athenaeum, "ПапкаДанныхСайта");
    
    Для Каждого Автор Из СписокАвторов Цикл
        
        Отбор = Новый Структура;
        Отбор.Вставить("Автор", Автор);
        
        ПоляАвтора          = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Автор, "Имя,Фамилия,Код,ДР");
        КаталогАвтора       = Новый Файл(КаталогСайта + "\authors\" + ПоляАвтора.Код);
        ПроизведенияАвтора  = Произведения.НайтиСтроки(Отбор);
        СтруктураАвтора     = Новый Структура;
        ВерсткаБио          = Новый ТекстовыйДокумент;
        
        Если Не КаталогАвтора.Существует() Тогда
            СоздатьКаталог(КаталогАвтора.ПолноеИмя);
        КонецЕсли;
                
        ДД = Автор.КартинкаДвоичные.Получить();
        ДД.Записать(КаталогАвтора.ПолноеИмя + "\0.webp");
        
        СтруктураАвтора.Вставить("author"  , ПоляАвтора.Имя + " " + ПоляАвтора.Фамилия);
        СтруктураАвтора.Вставить("date"    , Формат(ПоляАвтора.ДР, "ДЛФ=DD"));
        
        Для Каждого ОписаниеАвтора Из Автор.Абзацы Цикл    
            ВерсткаБио.ДобавитьСтроку("<h4>"    + ОписаниеАвтора.Заголовок  + ":</h4>");
            ВерсткаБио.ДобавитьСтроку("<p>"     + ОписаниеАвтора.Содержание + "</p>");        
        КонецЦикла;
        
        ВерсткаБио.ДобавитьСтроку("<h4>Произведения:</h4><div class=""books-list"">");
    
        Для Каждого ПроизведениеАвтора Из ПроизведенияАвтора Цикл        
            ВерсткаБио.ДобавитьСтроку("<a href=""/book?id="
                + ПроизведениеАвтора.Код 
                + """ class=""list-group-item list-group-item-action"">"
                + "<div class=""result"">"
                + "<span class=""oi oi-book result-oi"">"
                + "</span><span class=""result-text"">" 
                + ПроизведениеАвтора.Наименование 
                + "</span></div></a>");
        КонецЦикла;
        
        ВерсткаБио.ДобавитьСтроку("</div>");
    
        ИнструментарийВызовСервера.JSONВФайл(СтруктураАвтора, КаталогАвтора.ПолноеИмя + "\data.json"); 
        ВерсткаБио.Записать(КаталогАвтора.ПолноеИмя + "\description.html");
        
    КонецЦикла;
    
    ОбновитьКаталогАвторов();
    
КонецПроцедуры

// Сформировать index поиска по сайту.
Процедура СформироватьIndex() Экспорт
    
    МассивКниг     = Новый Массив;    
    Запрос         = Новый Запрос(
        "ВЫБРАТЬ
        |    Произведения.Код КАК Код,
        |    Произведения.Наименование КАК Наименование,
        |    Произведения.Автор.Имя КАК АвторИмя,
        |    Произведения.Автор.Фамилия КАК АвторФамилия
        |ИЗ
        |    Справочник.Произведения КАК Произведения
        |ГДЕ
        |    Произведения.НаСайте = ИСТИНА");
    
    ВыборкаДетальныеЗаписи = Запрос.Выполнить().Выбрать();
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        
        СтруктураКниги = Новый Структура;
        СтруктураКниги.Вставить("title"      , ВыборкаДетальныеЗаписи.Наименование);
        СтруктураКниги.Вставить("name"       , ВыборкаДетальныеЗаписи.АвторИмя);
        СтруктураКниги.Вставить("surname"    , ВыборкаДетальныеЗаписи.АвторФамилия);
        СтруктураКниги.Вставить("url"        , "/book?id=" + ВыборкаДетальныеЗаписи.Код);
        
        МассивКниг.Добавить(СтруктураКниги);
        
    КонецЦикла;
    
    ПапкаДанныхСайта = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Справочники.Сайты.Athenaeum
        , "ПапкаДанныхСайта");
        
    ИнструментарийВызовСервера.JSONВФайл(МассивКниг, ПапкаДанныхСайта + "\search.json"); 
        
КонецПроцедуры

// Сформировать сайтмап.
Процедура СформироватьСайтмап() Экспорт
    
    Дата = Формат(УниверсальноеВремя(ТекущаяДатаСеанса()), "ДФ=yyyy-MM-ddThh:mm:ss+00:00");
    
    Текст = 
    "<?xml version=""1.0"" encoding=""UTF-8""?>
    |<urlset
    |xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9""
    |xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""
    |>";
    
    Запрос  = Новый Запрос(ПолучитьСписокСтраниц());
    Выборка = Запрос.Выполнить().Выбрать();
    
    Пока Выборка.Следующий() Цикл
        
        Текст = Текст 
            + Символы.ПС
            + "<url>"
            + Символы.ПС
            + "<loc>"
            + Выборка.URL
            + "</loc>"
            + Символы.ПС
            + "<lastmod>"
            + Дата
            + "</lastmod>"
            + Символы.ПС
            + "</url>";
            
    КонецЦикла;
    
    Текст = Текст + "</urlset>";
    
    КореньСайта = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Справочники.Сайты.Athenaeum, "КореньСайта");
    Сайтмап     = Новый ТекстовыйДокумент;
    Сайтмап.ДобавитьСтроку(Текст);
    Сайтмап.Записать(КореньСайта + "sitemap.xml");
        
КонецПроцедуры

// Анализирует католог с подгаталогами сайта и собирает все файлы в справочник в той же структуре
// 
// Параметры:
//  ПапкаСайта - Строка - Путь к каталогу сайта
Процедура СобратьСайт(ПапкаСайта) Экспорт
    
    ИсключаемыеКаталоги = Новый Массив;
    ИсключаемыеКаталоги.Добавить(".scannerwork");
    ИсключаемыеКаталоги.Добавить("static");
    
    Если Не СтрЗаканчиваетсяНа(ПапкаСайта, "\") Тогда
        ПапкаСайта = ПапкаСайта + "\";    
    КонецЕсли;
    
    ОчиститьСправочникСтруктурыСайта();
    
    Корень                 = НайтиФайлы(ПапкаСайта, "*", Истина);
    СоответствиеКаталогов  = Новый Соответствие;

    УдалитьКаталогиИзВыборки(Корень, ИсключаемыеКаталоги);
    ЗаписатьКаталогиВСправочник(Корень, ПапкаСайта, СоответствиеКаталогов);
    ЗаписатьФайлыВСправочник(Корень, ПапкаСайта, СоответствиеКаталогов);
                                         
КонецПроцедуры

// Разворачивает сайт из заранее собранной структуры
Процедура ВысадитьСайт() Экспорт
    
    МассивКаталоговВысадки    = Новый Массив;
    ВыборкаКаталоговВысадки   = Справочники.КаталогиВысадки.Выбрать();

    Пока ВыборкаКаталоговВысадки.Следующий() Цикл

        Если Не СтрЗаканчиваетсяНа(ВыборкаКаталоговВысадки.Наименование, "\") Тогда
            ТекущийКаталог = ВыборкаКаталоговВысадки.Наименование + "\";
        Иначе
            ТекущийКаталог = ВыборкаКаталоговВысадки.Наименование;
        КонецЕсли;

        МассивКаталоговВысадки.Добавить(ТекущийКаталог);

    КонецЦикла;

    Запрос = Новый Запрос;
    Запрос.Текст =
    "ВЫБРАТЬ
    |    СтруктураСайта.Путь КАК Путь,
    |    СтруктураСайта.Хранилище КАК Хранилище
    |ИЗ
    |    Справочник.СтруктураСайта КАК СтруктураСайта
    |ГДЕ
    |    НЕ СтруктураСайта.ЭтоГруппа";

    РезультатЗапроса = Запрос.Выполнить();

    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();

    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        Для Каждого КаталогВыгрузки Из МассивКаталоговВысадки Цикл
            ДД = ВыборкаДетальныеЗаписи.Хранилище.Получить();
            ДД.Записать(КаталогВыгрузки + ВыборкаДетальныеЗаписи.Путь);
        КонецЦикла;
    КонецЦикла;
        
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьСписокКнигАвторов(СписокАвторов)
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    Произведения.Автор КАК Автор,
        |    Произведения.Ссылка КАК Книга,
        |    Произведения.Код КАК Код,
        |    Произведения.Наименование КАК Наименование
        |ИЗ
        |    Справочник.Произведения КАК Произведения
        |ГДЕ
        |    Произведения.Автор В(&СписокАвторов)
        |    И Произведения.НаСайте";
    
    Запрос.УстановитьПараметр("СписокАвторов", СписокАвторов);
    
    Возврат Запрос.Выполнить().Выгрузить();
    
КонецФункции

Функция ПолучитьСписокСтраниц() 
    
        Возврат    "ВЫБРАТЬ
                   |    ""https://athenaeum.digital/book?id="" + Произведения.Код КАК URL,
                   |    Произведения.Автор КАК Автор
                   |ПОМЕСТИТЬ Произведения
                   |ИЗ
                   |    Справочник.Произведения КАК Произведения
                   |ГДЕ
                   |    Произведения.НаСайте = ИСТИНА
                   |;
                   |
                   |////////////////////////////////////////////////////////////////////////////////
                   |ВЫБРАТЬ РАЗЛИЧНЫЕ
                   |    ""https://athenaeum.digital/author?id="" + Произведения.Автор.Код КАК URL
                   |ПОМЕСТИТЬ Авторы
                   |ИЗ
                   |    Произведения КАК Произведения
                   |;
                   |
                   |////////////////////////////////////////////////////////////////////////////////
                   |ВЫБРАТЬ
                   |    Произведения.URL КАК URL
                   |ИЗ
                   |    Произведения КАК Произведения
                   |
                   |ОБЪЕДИНИТЬ ВСЕ
                   |
                   |ВЫБРАТЬ
                   |    Авторы.URL
                   |ИЗ
                   |    Авторы КАК Авторы
                   |
                   |ОБЪЕДИНИТЬ ВСЕ
                   |
                   |ВЫБРАТЬ
                   |    СтандартныеСтраницы.Наименование
                   |ИЗ
                   |    Справочник.СтандартныеСтраницы КАК СтандартныеСтраницы";
    
КонецФункции

Процедура ОбновитьКаталогАвторов()
    
    Запрос       = Новый Запрос;
    КаталогСайта = ИнструментарийВызовСервера.ЗначениеРеквизитаОбъекта(Справочники.Сайты.Athenaeum, "ПапкаДанныхСайта");

    Запрос.Текст = 
        "ВЫБРАТЬ РАЗЛИЧНЫЕ
        |    Произведения.Автор КАК Автор,
        |    Произведения.Автор.Имя КАК АвторИмя,
        |    Произведения.Автор.Фамилия КАК АвторФамилия,
        |    Произведения.Автор.Код КАК АвторКод
        |ИЗ
        |    Справочник.Произведения КАК Произведения
        |ГДЕ
        |    Произведения.НаСайте";
    
    РезультатЗапроса         = Запрос.Выполнить();    
    ВыборкаДетальныеЗаписи   = РезультатЗапроса.Выбрать();
    МассивАвторов            = Новый Массив;
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        
        СтруктураАвтора = Новый Структура;
        СтруктураАвтора.Вставить("name"       , ВыборкаДетальныеЗаписи.АвторИмя);
        СтруктураАвтора.Вставить("surname"    , ВыборкаДетальныеЗаписи.АвторФамилия);
        СтруктураАвтора.Вставить("url"        , "/author?id=" + ВыборкаДетальныеЗаписи.АвторКод);
        
        МассивАвторов.Добавить(СтруктураАвтора);
        
    КонецЦикла;

    ИнструментарийВызовСервера.JSONВФайл(МассивАвторов, КаталогСайта + "\authors.json");
    
КонецПроцедуры

Процедура ОчиститьСправочникСтруктурыСайта()
    
    Выборка     = Справочники.СтруктураСайта.Выбрать();
    МассивСайта = Новый Массив;
    
    Пока Выборка.Следующий() Цикл
        МассивСайта.Добавить(Выборка.Ссылка);
    КонецЦикла;
    
    УдалитьОбъекты(МассивСайта);    
    
КонецПроцедуры

Процедура УдалитьКаталогиИзВыборки(Корень, ИсключаемыеКаталоги)
    
    МассивИсключаемыхИндексов   = Новый Массив;
    Счетчик                     = 0;
    
    Для Каждого ЭлементКорня Из Корень Цикл
        
        Для Каждого ИсключаемоеИмя Из ИсключаемыеКаталоги Цикл
            Если СтрНайти(ЭлементКорня.ПолноеИмя, ИсключаемоеИмя) > 0 Тогда
                МассивИсключаемыхИндексов.Вставить(0, Счетчик);         
            КонецЕсли;            
        КонецЦикла;
        
        Счетчик = Счетчик + 1;
    КонецЦикла;
    
    Для Каждого ИсключаемыИндекс Из МассивИсключаемыхИндексов Цикл
        Корень.Удалить(ИсключаемыИндекс);
    КонецЦикла;
    
КонецПроцедуры

Процедура ЗаписатьКаталогиВСправочник(Корень, ПапкаСайта, СоответствиеКаталогов)
    
    Для Каждого Каталог Из Корень Цикл
        
        Если ЗначениеЗаполнено(Каталог.Расширение) И ЗначениеЗаполнено(Каталог.ИмяБезРасширения)  Тогда 
            Продолжить;
        КонецЕсли;
        
        ПутьКаталога            = СтрЗаменить(Каталог.ПолноеИмя, ПапкаСайта, "");
        МассивПодкаталогов      = СтрРазделить(ПутьКаталога, "\", Ложь);
        ПредыдущийПодкаталог    = "";
        
        Счетчик                    = 0;

        Для Каждого Подкаталог Из МассивПодкаталогов Цикл

            СоздатьЗаписьКаталога(Счетчик
                , МассивПодкаталогов
                , СоответствиеКаталогов
                , Подкаталог
                , ПредыдущийПодкаталог);

        КонецЦикла;

    КонецЦикла;
        
КонецПроцедуры

Процедура СоздатьЗаписьКаталога(Счетчик, МассивПодкаталогов, СоответствиеКаталогов, Подкаталог, ПредыдущийПодкаталог)

    ПолныйПутьКаталога = "";
    
    Для Н = 0 По Счетчик Цикл

        ПолныйПутьКаталога = ПолныйПутьКаталога + МассивПодкаталогов[Н] + "\";

    КонецЦикла;

    СуществующийКаталог = СоответствиеКаталогов.Получить(ПолныйПутьКаталога);

    Если СуществующийКаталог <> Неопределено Тогда
        ПредыдущийПодкаталог = СуществующийКаталог;
    Иначе
        НовыйПодкаталог = Справочники.СтруктураСайта.СоздатьГруппу();
        НовыйПодкаталог.Наименование    = Подкаталог;
        НовыйПодкаталог.Родитель        = ?(ЗначениеЗаполнено(ПредыдущийПодкаталог), ПредыдущийПодкаталог,
            Справочники.СтруктураСайта.ПустаяСсылка());
        НовыйПодкаталог.Записать();

        ПредыдущийПодкаталог            = НовыйПодкаталог.Ссылка;

        СоответствиеКаталогов.Вставить(ПолныйПутьКаталога, ПредыдущийПодкаталог);

    КонецЕсли;
    
    Счетчик = Счетчик + 1;
    
КонецПроцедуры

Процедура ЗаписатьФайлыВСправочник(Корень, ПапкаСайта, СоответствиеКаталогов)

    Для Каждого Файл Из Корень Цикл
        Если Не ЗначениеЗаполнено(Файл.Расширение) Или Не ЗначениеЗаполнено(Файл.ИмяБезРасширения)  Тогда 
            Продолжить;
        Иначе
            ПутьБезКорня = СтрЗаменить(Файл.Путь, ПапкаСайта, "");
            
            НовыйФайл = Справочники.СтруктураСайта.СоздатьЭлемент();
            НовыйФайл.Наименование = Файл.Имя; 
            
            Если ЗначениеЗаполнено(ПутьБезКорня) Тогда
                НовыйФайл.Родитель = СоответствиеКаталогов.Получить(ПутьБезКорня);
            КонецЕсли;
                    
            НовыйФайл.Путь      = СтрЗаменить(Файл.ПолноеИмя, ПапкаСайта, "");
            НовыйФайл.Хранилище = Новый ХранилищеЗначения(Новый ДвоичныеДанные(Файл.ПолноеИмя), Новый СжатиеДанных(9));
            
            НовыйФайл.Записать();
        КонецЕсли;
    КонецЦикла;
        
КонецПроцедуры

#КонецОбласти
