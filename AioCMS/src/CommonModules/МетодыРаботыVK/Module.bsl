#Область ПрограммныйИнтерфейс

#Область РаботаСГруппой

// Создать пост.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  Текст - Строка - Текст
//  МассивКартинок - Массив из ДвоичныеДанные - Массив картинок для поста
//  Рекламный - Булево -  Рекламный
//  СсылкаПодЗаписью - Строка -  Ссылка под записью
//  Параметры - Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Разобранный JSON ответа
Функция СоздатьПост(Знач Сообщество
    , Знач Текст
    , Знач МассивКартинок
    , Знач Рекламный = Ложь
    , Знач СсылкаПодЗаписью = ""
    , Знач Параметры = "") Экспорт
        
    _Параметры      = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    СтрокаВложений  = "";    
    photo           = "photo";
    hash            = "hash";
    srv             = "server";
	Текст			= СтрЗаменить(Текст, "#", "%23");
        
    Для Каждого КартинкаПоста Из МассивКартинок Цикл
        
        Файлы = Новый Соответствие;
        Файлы.Вставить(photo, 
            ?(ТипЗнч(КартинкаПоста) = Тип("Строка"), Новый ДвоичныеДанные(КартинкаПоста), КартинкаПоста));
        
        Ответ     = МетодыРаботыHttp.Get("api.vk.com/method/photos.getWallUploadServer", _Параметры);
        URL       = Ответ["response"]["upload_url"];
        
        _Параметры.Вставить("upload_url", URL);
                
        Ответ        = МетодыРаботыHttp.Post(URL, _Параметры, Файлы);
        СерверФото   = МетодыРаботыHttp.ЧислоВСтроку(Ответ[srv]);
        
        _Параметры.Вставить(hash     , Ответ[hash]);
        _Параметры.Вставить(photo    , Ответ[photo]);
        _Параметры.Вставить(srv      , СерверФото);
        
        ИнструментарийВызовСервера.Ожидание(2);
        Ответ               = МетодыРаботыHttp.Get("api.vk.com/method/photos.saveWallPhoto", _Параметры);
        ОтветСоответствие   = Ответ.Получить("response")[0];
   
        _Параметры.Удалить(hash);
        _Параметры.Удалить(photo);
        _Параметры.Удалить(srv);
        
        ФотоID = photo 
        +  МетодыРаботыHttp.ЧислоВСтроку(ОтветСоответствие.Получить("owner_id"))
        + "_" 
        +     МетодыРаботыHttp.ЧислоВСтроку(ОтветСоответствие.Получить("id"));
        
        СтрокаВложений = СтрокаВложений + ФотоID + ",";
        
	КонецЦикла;
	
	ОбработатьДругиеВложения(СтрокаВложений, _Параметры); 

    СтрокаВложений = СтрокаВложений + СсылкаПодЗаписью;
    
    _Параметры.Вставить("message"            , Текст);
    _Параметры.Вставить("attachments"        , СтрокаВложений);
    _Параметры.Вставить("mark_as_ads"        , ?(Рекламный, 1, 0));
    _Параметры.Вставить("close_comments"     , ?(Рекламный, 1, 0));

    ИнструментарийВызовСервера.Ожидание(2);
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/wall.post", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Удалить пост.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  ID - Строка,Число - ID
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Удалить пост
Функция УдалитьПост(Знач Сообщество, Знач ID, Знач Параметры = "") Экспорт
    
    _Параметры  = ПолучитьСтандартныеПараметры(Параметры, Сообщество);    
    _Параметры.Вставить("post_id", МетодыРаботыHttp.ЧислоВСтроку(ID));
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/wall.delete", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Создать опрос.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  Вопрос - Строка - Вопрос
//  МассивОтветов - Массив из Строка - Массив ответов
//  Картинка - Строка, ДвоичныеДанные -  Картинка
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Создать опрос
Функция СоздатьОпрос(Знач Сообщество, Знач Вопрос, Знач МассивОтветов, Знач Картинка = "", Знач Параметры = "") Экспорт
    
    photo       = "photo";
    hash        = "hash";
    response    = "response";
    
    _Параметры  = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    Ответ       = МетодыРаботыHttp.Get("api.vk.com/method/polls.getPhotoUploadServer", _Параметры);
    URL         = Ответ[response]["upload_url"];    
  
    _Параметры.Вставить("upload_url", URL);

    Если Не Картинка = "" Тогда
        
        Если ТипЗнч(Картинка) = Тип("Строка") Тогда
            Картинка = Новый ДвоичныеДанные(Картинка);
        КонецЕсли;
        
        Файлы = Новый Соответствие;
        Файлы.Вставить(photo, Картинка);
        
    КонецЕсли;
    
    Ответ = МетодыРаботыHttp.Post(URL, _Параметры, Файлы);
     
    _Параметры.Вставить(hash       , Ответ[hash]);
    _Параметры.Вставить(photo      , Ответ[photo]);
    
    Ответ                  = МетодыРаботыHttp.Get("api.vk.com/method/polls.savePhoto", _Параметры);
    ОтветСоответствие      = Ответ.Получить(response)["id"];
    
    _Параметры.Вставить("is_anonymous"    , 1);
    _Параметры.Вставить("is_multiple"     , 0);
        
    Ответы     = "[";
    Первый     = Истина;
    
    Для Каждого Ответ Из МассивОтветов Цикл
        
        Если Первый Тогда 
            Первый = Ложь; 
        Иначе 
            Ответы = Ответы + ", "; 
        КонецЕсли;
        
        Ответы = Ответы + """" + Ответ + """";
        
    КонецЦикла;
    
    Ответы = Ответы + "]";
    
    _Параметры.Вставить("add_answers"     , Ответы);
    _Параметры.Вставить("photo_id"        , МетодыРаботыHttp.ЧислоВСтроку(ОтветСоответствие));
    _Параметры.Вставить("question"        , Вопрос);
    
    Опрос                 = МетодыРаботыHttp.Get("api.vk.com/method/polls.create", _Параметры);
    ОпросСоответствие     = Опрос.Получить(response);
    
    ОпросID = "poll"
    +     МетодыРаботыHttp.ЧислоВСтроку(ОпросСоответствие.Получить("owner_id"))
    +     "_" 
    +     МетодыРаботыHttp.ЧислоВСтроку(ОпросСоответствие.Получить("id"));
  
    _Параметры.Вставить("attachments", ОпросID);
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/wall.post", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Создать альбом.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  Наименование - Строка - Наименование
//  Описание - Строка -  Описание
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Создать альбом
Функция СоздатьАльбом(Знач Сообщество, Знач Наименование, Знач Описание = "", Знач Параметры = "") Экспорт
    
    _Параметры      = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    
    _Параметры.Вставить("title"                , Наименование);
    _Параметры.Вставить("description"          , Описание);
    _Параметры.Вставить("upload_by_admins_only", 1);
    
    Ответ    = МетодыРаботыHttp.Get("api.vk.com/method/photos.createAlbum", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Создать историю.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  Картинка - Строка,ДвоичныеДанные - Картинка
//  URL - Строка -  URL
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Создать историю
Функция СоздатьИсторию(Знач Сообщество, Знач Картинка, Знач URL = "", Знач Параметры = "") Экспорт
        
    _Параметры      = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    _Параметры.Вставить("link_text"        , "more");
    _Параметры.Вставить("link_url"         , URL);
    _Параметры.Вставить("add_to_news"      , "1");
    
    Ответ    = МетодыРаботыHttp.Get("api.vk.com/method/stories.getPhotoUploadServer", _Параметры);    
    URL      = Ответ["response"]["upload_url"];
        
    _Параметры.Вставить("upload_url", URL);
    
    Если Не ТипЗнч(Картинка) = Тип("ДвоичныеДанные") Тогда
        Картинка = Новый ДвоичныеДанные(Картинка);
    КонецЕсли;
    
    Файлы = Новый Соответствие;
    Файлы.Вставить("photo", Картинка);

    Ответ = МетодыРаботыHttp.Post(URL, _Параметры, Файлы);    
    _Параметры.Вставить("upload_results", Ответ["response"]["upload_result"]);
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/stories.save", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Сохранить картинку в альбом.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDАльбома - Число,Строка - IDАльбома
//  Картинка - Строка,ДвоичныеДанные - Картинка
//  Описание - Строка -  Описание
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Сохранить картинку в альбом
Функция СохранитьКартинкуВАльбом(Знач Сообщество
    , Знач IDАльбома
    , Знач Картинка
    , Знач Описание = ""
    , Знач Параметры = "") Экспорт
    
    _Параметры      = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    
    _Параметры.Вставить("album_id"        , МетодыРаботыHttp.ЧислоВСтроку(IDАльбома));
    _Параметры.Вставить("caption"         , Описание);
    
    Ответ     = МетодыРаботыHttp.Get("api.vk.com/method/photos.getUploadServer", _Параметры);
    URL       = Ответ["response"]["upload_url"];
    
    Если Не ТипЗнч(Картинка) = Тип("ДвоичныеДанные") Тогда
        Картинка = Новый ДвоичныеДанные(Картинка);
    КонецЕсли;
    
    Файлы = Новый Соответствие;
    Файлы.Вставить("photo", Картинка);

    ОтветАльбома = МетодыРаботыHttp.Post(URL, _Параметры, Файлы);    

    _Параметры.Вставить("server"          , МетодыРаботыHttp.ЧислоВСтроку(ОтветАльбома["server"]));
    _Параметры.Вставить("photos_list"     , ОтветАльбома["photos_list"]);
    _Параметры.Вставить("hash"            , ОтветАльбома["hash"]);
    _Параметры.Вставить("aid"             , ОтветАльбома["aid"]);
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/photos.save", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Удалить картинку.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDКартинки - Строка,ДвоичныеДанные - IDКартинки
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Удалить картинку
Функция УдалитьКартинку(Знач Сообщество, Знач IDКартинки, Знач Параметры = "") Экспорт
    
    _Параметры  = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    _Параметры.Вставить("photo_id", МетодыРаботыHttp.ЧислоВСтроку(IDКартинки));
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/photos.delete", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

#КонецОбласти

#Область РаботаСОбсуждениями

// Создать обсуждение.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  Наименование - Строка - Наименование
//  ТекстПервогоСообщения - Строка - Текст первого сообщения
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Создать обсуждение
Функция СоздатьОбсуждение(Знач Сообщество, Знач Наименование, Знач ТекстПервогоСообщения, Знач Параметры = "") Экспорт
    
    _Параметры = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    _Параметры.Вставить("title"    , Наименование);
    _Параметры.Вставить("text"     , ТекстПервогоСообщения);
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/board.addTopic", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Закрыть обсуждение.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDОбсуждения - Число,Строка - ID обсуждения
//  УдалитьПолностью - Булево -  Удалить полностью
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Закрыть обсуждение
Функция ЗакрытьОбсуждение(Знач Сообщество, Знач IDОбсуждения, Знач УдалитьПолностью = Ложь, Знач Параметры = "") Экспорт
    
    _Параметры  = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    _Параметры.Вставить("topic_id", МетодыРаботыHttp.ЧислоВСтроку(IDОбсуждения));
    
    Метод = ?(УдалитьПолностью, "deleteTopic", "closeTopic");
     
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/board." + Метод, _Параметры);
    
    Возврат Ответ;

КонецФункции

// Открыть обсуждение.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDОбсуждения - Число,Строка - ID обсуждения
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Открыть обсуждение
Функция ОткрытьОбсуждение(Знач Сообщество, Знач IDОбсуждения, Знач Параметры = "") Экспорт
    
    _Параметры  = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    _Параметры.Вставить("topic_id", МетодыРаботыHttp.ЧислоВСтроку(IDОбсуждения));
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/board.openTopic", _Параметры);
    
    Возврат Ответ;

КонецФункции

// Написать в обсуждение.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDОбсуждения - Число,Строка - ID обсуждения
//  Текст - Строка - Текст
//  Параметры - Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Написать в обсуждение
Функция НаписатьВОбсуждение(Знач Сообщество, Знач IDОбсуждения, Знач Текст, Знач Параметры = "") Экспорт
    
    _Параметры  = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    _Параметры.Вставить("topic_id"    , МетодыРаботыHttp.ЧислоВСтроку(IDОбсуждения));
    _Параметры.Вставить("message"     , Текст);
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/board.createComment", _Параметры);
    
    Возврат Ответ;

КонецФункции

#КонецОбласти

#Область ИнтерактивныеДействия

// Поставить лайк.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDПоста - Число,Строка - IDПоста
//  IDСтены - Строка -  IDСтены
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Поставить лайк
Функция ПоставитьЛайк(Знач Сообщество, Знач IDПоста, Знач IDСтены = "", Знач Параметры = "") Экспорт
    
    _Параметры      = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    IDСтены         = ?(ЗначениеЗаполнено(IDСтены), IDСтены, _Параметры["group_id"]);
    ОбъектВК        = "wall-" + МетодыРаботыHttp.ЧислоВСтроку(IDСтены) + "_" + МетодыРаботыHttp.ЧислоВСтроку(IDПоста);
    
    _Параметры.Вставить("from_group"    , "0");
    _Параметры.Вставить("type"          , "post");
    _Параметры.Вставить("object"        , ОбъектВК);
    _Параметры.Вставить("item_id"       , МетодыРаботыHttp.ЧислоВСтроку(IDПоста));
    _Параметры.Вставить("owner_id"      , МетодыРаботыHttp.ЧислоВСтроку(IDСтены));
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/likes.add", _Параметры);
    
    Возврат Ответ;

КонецФункции

// @skip-check method-too-many-params
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDПоста - Строка, Число - ID поста
//  IDСтены - Строка - IDСтены
//  ЦелеваяСтена - Строка - Целевая стена
//  Рекламный - Булево - Рекламный
//  Параметры - Структура Из Строка - Параметры
// 
// Возвращаемое значение:
//  Произвольный - Сделать репост
Функция СделатьРепост(Знач Сообщество
    , Знач IDПоста
    , Знач IDСтены = ""
    , Знач ЦелеваяСтена = ""
    , Знач Рекламный = Ложь
    , Знач Параметры = "") Экспорт
    
    _Параметры  = ПолучитьСтандартныеПараметры(Параметры, Сообщество);

    Источник = ?(ЗначениеЗаполнено(IDСтены)        
        , МетодыРаботыHttp.ЧислоВСтроку(IDСтены)
        , МетодыРаботыHttp.ЧислоВСтроку(_Параметры["owner_id"]));
        
    Приемник = ?(ЗначениеЗаполнено(ЦелеваяСтена)
        , СтрЗаменить(МетодыРаботыHttp.ЧислоВСтроку(ЦелеваяСтена), "-", "")
        , МетодыРаботыHttp.ЧислоВСтроку(_Параметры["group_id"]));

    _Параметры.Вставить("object"          , "wall" + Источник + "_" + МетодыРаботыHttp.ЧислоВСтроку(IDПоста));
    _Параметры.Вставить("group_id"        , Приемник);
    _Параметры.Вставить("mark_as_ads"     , ?(Рекламный, 1, 0));
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/wall.repost", _Параметры);
    
    Возврат Ответ;

КонецФункции

// Написать комментарий.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDПоста - Число, Строка - ID поста
//  Текст - Строка - Текст
//  IDСтены - Строка -  IDСтены
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Написать комментарий
Функция НаписатьКомментарий(Знач Сообщество, Знач IDПоста, Знач Текст, Знач IDСтены = "", Знач Параметры = "") Экспорт
    
    _Параметры = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    
    Если ЗначениеЗаполнено(IDСтены) Тогда
        _Параметры.Вставить("owner_id", МетодыРаботыHttp.ЧислоВСтроку(IDСтены));
    КонецЕсли;
    
    _Параметры.Вставить("from_group" , МетодыРаботыHttp.ЧислоВСтроку(_Параметры["group_id"]));
    _Параметры.Вставить("post_id"    , МетодыРаботыHttp.ЧислоВСтроку(IDПоста));
    _Параметры.Вставить("message"    , Текст);
    
    _Параметры.Удалить("group_id");
    
    Ответ    = МетодыРаботыHttp.Get("api.vk.com/method/wall.createComment", _Параметры);
    
    Возврат Ответ;

КонецФункции

#КонецОбласти

#Область Статистика

// Получить статистику.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  ДатаНачала - Дата - Дата начала
//  ДатаОкончания - Дата - Дата окончания
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Получить статистику
Функция ПолучитьСтатистику(Знач Сообщество, Знач ДатаНачала, Знач ДатаОкончания, Знач Параметры = "") Экспорт
    
    _Параметры         = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    
    ДатаНачала         = Формат(ДатаНачала        - Дата(1970, 1, 1, 1, 0, 0), "ЧГ=0");
    ДатаОкончания      = Формат(ДатаОкончания     - дата(1970, 1, 1, 1, 0, 0), "ЧГ=0");
    
    _Параметры.Вставить("timestamp_from"      , ДатаНачала);
    _Параметры.Вставить("timestamp_to"        , ДатаОкончания);
    _Параметры.Вставить("stats_groups"        , "visitors, reach, activity");
    
    Ответ    = МетодыРаботыHttp.Get("api.vk.com/method/stats.get", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Получить статистику постов.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  МассивIDПостов - Массив Из Число,Строка - Массив IDПостов
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Массив Из Структура -  Получить статистику постов
Функция ПолучитьСтатистикуПостов(Знач Сообщество, Знач МассивIDПостов, Знач Параметры = "") Экспорт
    
    _Параметры          = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    МассивОтветов       = Новый Массив;
    МассивНабора        = Новый Массив;
    МаксимумПостов      = 30;
    
    Для Каждого Пост Из МассивIDПостов Цикл
        
        МассивНабора.Добавить(МетодыРаботыHttp.ЧислоВСтроку(Пост));
        
        Если МассивНабора.Количество() = МаксимумПостов Тогда
            
            СтрокаНомеров = СтрСоединить(МассивНабора, ",");
            _Параметры.Вставить("post_ids", СтрокаНомеров);
            
            Статистика             = МетодыРаботыHttp.Get("api.vk.com/method/stats.getPostReach", _Параметры);
            МассивСтатистики       = Статистика["response"];
            
            Для Каждого ЭлементСтатистики Из МассивСтатистики Цикл
                МассивОтветов.Добавить(ЭлементСтатистики);
            КонецЦикла;
            
            МассивНабора = Новый Массив;
            
        КонецЕсли;
        
    КонецЦикла;
    
    СтрокаНомеров = СтрСоединить(МассивНабора, ",");
    _Параметры.Вставить("post_ids", СтрокаНомеров);
    
    Статистика             = МетодыРаботыHttp.Get("api.vk.com/method/stats.getPostReach", _Параметры);
    МассивСтатистики       = Статистика["response"];
    
    Для Каждого ЭлементСтатистики Из МассивСтатистики Цикл
        МассивОтветов.Добавить(ЭлементСтатистики);
    КонецЦикла;

    Возврат МассивОтветов;
    
КонецФункции
        
#КонецОбласти

#Область РаботаСРекламнымКабинетом

// Создать рекламную кампанию.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDКабинета - Число,Строка - ID кабинета
//  Наименование - Строка - Наименование
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Создать рекламную кампанию
Функция СоздатьРекламнуюКампанию(Знач Сообщество, Знач IDКабинета, Знач Наименование, Знач Параметры = "") Экспорт
    
    КрайняяДата     = '2120.01.01';
    _Параметры      = ПолучитьСтандартныеПараметры(Параметры, Сообщество);    
    _Параметры.Вставить("account_id", МетодыРаботыHttp.ЧислоВСтроку(IDКабинета));
      
    МассивСтруктур = Новый Массив;
    
    СтруктураКампании = Новый Структура;
    СтруктураКампании.Вставить("type"            , "promoted_posts");
    СтруктураКампании.Вставить("name"            , Наименование);
    СтруктураКампании.Вставить("day_limit"       , 0);
    СтруктураКампании.Вставить("all_limit"       , 0);
    СтруктураКампании.Вставить("start_time"      , Формат(ТекущаяДатаСеанса() - Дата(1970, 1, 1, 1, 0, 0), "ЧГ=0"));
    СтруктураКампании.Вставить("stop_time"       , Формат(КрайняяДата - Дата(1970, 1, 1, 1, 0, 0), "ЧГ=0"));
    СтруктураКампании.Вставить("status"          , 1);
    
    МассивСтруктур.Добавить(СтруктураКампании);
    
    JSONДата = МетодыРаботыHttp.JSONСтрокой(МассивСтруктур);
    
    _Параметры.Вставить("data", JSONДата);
    
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/ads.createCampaigns", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Создать рекламное объявление.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  НомерКампании - Число,Строка - Номер кампании
//  ДневнойЛимит - Число - Дневной лимит
//  НомерКатегории - Число - Номер категории
//  IDПоста - Число,Строка - IDПоста
//  IDКабинета - Число,Строка - IDКабинета
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Создать рекламное объявление
Функция СоздатьРекламноеОбъявление(Знач Сообщество
    , Знач НомерКампании
    , Знач ДневнойЛимит
    , Знач НомерКатегории
    , Знач IDПоста
    , Знач IDКабинета
    , Знач Параметры = "") Экспорт
    
    _Параметры              = ПолучитьСтандартныеПараметры(Параметры, Сообщество);   
    МассивСтруктур          = Новый Массив;    
    СтруктураКампании       = Новый Структура;
    Линк                    = "https://vk.com/wall-" 
        + _Параметры["group_id"] 
        + "_" 
        + МетодыРаботыHttp.ЧислоВСтроку(IDПоста);
    
    СтруктураКампании.Вставить("campaign_id"                , МетодыРаботыHttp.ЧислоВСтроку(НомерКампании));
    СтруктураКампании.Вставить("ad_format"                  , 9);
    СтруктураКампании.Вставить("conversion_event_id"        , 1);
    СтруктураКампании.Вставить("autobidding"                , 1);
    СтруктураКампании.Вставить("cost_type"                  , 3);
    СтруктураКампании.Вставить("goal_type"                  , 2);
    СтруктураКампании.Вставить("ad_platform"                , "all");
    СтруктураКампании.Вставить("publisher_platforms"        , "vk");
    СтруктураКампании.Вставить("publisher_platforms_auto"   , "1");
    СтруктураКампании.Вставить("day_limit"                  , МетодыРаботыHttp.ЧислоВСтроку(ДневнойЛимит));
    СтруктураКампании.Вставить("all_limit"                  , "0");
    СтруктураКампании.Вставить("category1_id"               , МетодыРаботыHttp.ЧислоВСтроку(НомерКатегории));
    СтруктураКампании.Вставить("age_restriction"            , 0);
    СтруктураКампании.Вставить("status"                     , 1);
    СтруктураКампании.Вставить("name"                       , "Объявление");
    СтруктураКампании.Вставить("link_url"                   , Линк);
    
    МассивСтруктур.Добавить(СтруктураКампании);
    
    JSONДата = МетодыРаботыHttp.JSONСтрокой(МассивСтруктур);
    
    _Параметры.Вставить("data"        , JSONДата);
    _Параметры.Вставить("account_id"  , МетодыРаботыHttp.ЧислоВСтроку(IDКабинета));
    
    Ответ    = МетодыРаботыHttp.Get("api.vk.com/method/ads.createAds", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Приостановить рекламное объявление.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDКабинета - Число,Строка - ID кабинета
//  IDОбъявления - Число,Строка - ID объявления
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Приостановить рекламное объявление
Функция ПриостановитьРекламноеОбъявление(Знач Сообщество
    , Знач IDКабинета
    , Знач IDОбъявления
    , Знач Параметры = "") Экспорт
    
    _Параметры = ПолучитьСтандартныеПараметры(Параметры, Сообщество);

    _Параметры.Вставить("account_id", МетодыРаботыHttp.ЧислоВСтроку(IDКабинета));
    
    МассивСтруктур         = Новый Массив;    
    СтруктураКампании      = Новый Структура;
    СтруктураКампании.Вставить("ad_id"  , МетодыРаботыHttp.ЧислоВСтроку(IDОбъявления));
    СтруктураКампании.Вставить("status" , 0);
    
    МассивСтруктур.Добавить(СтруктураКампании);
    
    JSONДата = МетодыРаботыHttp.JSONСтрокой(МассивСтруктур);
    
    _Параметры.Вставить("data", JSONДата);
        
    Ответ = МетодыРаботыHttp.Get("api.vk.com/method/ads.updateAds", _Параметры);
    
    Возврат Ответ;
    
КонецФункции

// Изменить запись рекламного объявления.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  IDПоста - Число,Строка - ID поста
//  IDКабинета - Число,Строка - ID кабинета
//  IDОбъявления - Число,Строка - ID объявления
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
//  Произвольный -  Изменить запись рекламного объявления
Функция ИзменитьЗаписьРекламногоОбъявления(Знач Сообщество
    , Знач IDПоста
    , Знач IDКабинета
    , Знач IDОбъявления
    , Знач Параметры = "") Экспорт
    
    _Параметры  = ПолучитьСтандартныеПараметры(Параметры, Сообщество);
    Линк        = "https://vk.com/wall-" + _Параметры["group_id"] + "_" + МетодыРаботыHttp.ЧислоВСтроку(IDПоста);
    
    _Параметры.Вставить("account_id", МетодыРаботыHttp.ЧислоВСтроку(IDКабинета));
    
    МассивСтруктур         = Новый Массив;    
    СтруктураКампании      = Новый Структура;
    СтруктураКампании.Вставить("ad_id"         , МетодыРаботыHttp.ЧислоВСтроку(IDОбъявления));
    СтруктураКампании.Вставить("status"        , 1);
    СтруктураКампании.Вставить("link_url"      , Линк);
    
    МассивСтруктур.Добавить(СтруктураКампании);
    
    JSONДата = МетодыРаботыHttp.JSONСтрокой(МассивСтруктур);
    
    _Параметры.Вставить("data", JSONДата);
    
    Ответ    = МетодыРаботыHttp.Get("api.vk.com/method/ads.updateAds", _Параметры);
    
    Возврат Ответ;
   
КонецФункции

#КонецОбласти

#Область Прочие

// Сократить ссылку.
// 
// Параметры:
//  Сообщество - СправочникСсылка.Сообщества - Сообщество
//  URL - Строка - URL
//  Параметры - Структура Из Строка -  Параметры
// 
// Возвращаемое значение:
// Строка - Краткая ссылка 
Функция СократитьСсылку(Знач Сообщество, Знач URL, Знач Параметры = "") Экспорт
    
    _Параметры = Новый Структура;
    _Параметры = ПолучитьСтандартныеПараметры(Параметры, Сообщество);    
    _Параметры.Вставить("url", URL);
    
    Ответ = МетодыРаботыHttp.Get("https://api.vk.com/method/utils.getShortLink", _Параметры);
    
    Возврат Ответ["response"]["short_url"];
    
КонецФункции

#КонецОбласти

#Область ПолучениеТокена

// Создать ссылку получения токена.
// 
// Параметры:
//  app_id - Число,Строка - App id
// 
// Возвращаемое значение:
// Строка - URL 
Функция СоздатьСсылкуПолученияТокена(Знач app_id) Экспорт
    
    // access_token нужно будет забрать из параметра в строке адреса браузера
    Возврат "https://oauth.vk.com/authorize?client_id=" + app_id
        + "&scope=offline,wall,groups,photos,stats,stories,ads&v=5.131&response_type=token"
        + "&redirect_uri=https://api.vk.com/blank.html";
        
КонецФункции
 
#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьСтандартныеПараметры(Знач Параметры = "", Знач Сообщество = "")
    
    Если Не ЗначениеЗаполнено(Сообщество) Тогда
        Сообщество = Справочники.Сообщества.Athenaeum;    
    КонецЕсли;
    
    _Параметры = Новый Структура;
    
    РеквизитыСообщества = ИнструментарийВызовСервера.ЗначенияРеквизитовОбъекта(Сообщество,
        "ВК_V,ВК_owner_id,ВК_group_id,ВК_access_token,ВК_client_id"); 
    
    owner = ?(СтрНачинаетсяС(РеквизитыСообщества.ВК_owner_id, "-")
        , РеквизитыСообщества.ВК_owner_id
        , "-" + РеквизитыСообщества.ВК_owner_id);
    
    _Параметры.Вставить("access_token"  , РеквизитыСообщества.ВК_access_token);
    _Параметры.Вставить("from_group"    , "1");
    _Параметры.Вставить("owner_id"      , owner);
    _Параметры.Вставить("v"             , РеквизитыСообщества.ВК_V);
    _Параметры.Вставить("app_id"        , РеквизитыСообщества.ВК_client_id);
    _Параметры.Вставить("group_id"      , РеквизитыСообщества.ВК_group_id);
    
    Если ТипЗнч(Параметры) = Тип("Структура") Тогда
        Для Каждого ПереданныйПараметр Из Параметры Цикл
            _Параметры.Вставить(ПереданныйПараметр.Ключ, МетодыРаботыHttp.ЧислоВСтроку(ПереданныйПараметр.Значение));
        КонецЦикла;
    КонецЕсли;

    Возврат _Параметры;

КонецФункции

Процедура ОбработатьДругиеВложения(СтрокаВложений, Знач Параметры)
	
	Если Параметры.Свойство("АудиоВК") Тогда
		//@skip-check wrong-string-literal-content
		СтрокаВложений = СтрокаВложений + Параметры["АудиоВК"] + ",";
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
