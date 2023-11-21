#Область ПрограммныйИнтерфейс

// Рассылка уведомлений пользователям по их настройкам оповещений
Процедура РассылкаУведомлений() Экспорт
        
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    Пользователи.Ссылка КАК Ссылка,
        |    ВТПерсональныеНастройки.Оповещения КАК Оповещения,
        |    МАКСИМУМ(ПотоковоеЧтение.Дата) КАК Дата,
        |    Пользователи.Telegram КАК Telegram,
        |    Пользователи.VK КАК VK,
        |    Пользователи.ТГ_БотОстановлен КАК ТГ_БотОстановлен
        |ПОМЕСТИТЬ Основа
        |ИЗ
        |    Справочник.Пользователи КАК Пользователи
        |        ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПерсональныеНастройки КАК ВТПерсональныеНастройки
        |        ПО Пользователи.ПерсональныеНастройки = ВТПерсональныеНастройки.Ссылка
        |        ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПотоковоеЧтение КАК ПотоковоеЧтение
        |        ПО (ПотоковоеЧтение.Пользователь = Пользователи.Ссылка)
        |
        |СГРУППИРОВАТЬ ПО
        |    Пользователи.Ссылка,
        |    ВТПерсональныеНастройки.Оповещения,
        |    Пользователи.Telegram,
        |    Пользователи.VK,
        |    Пользователи.ТГ_БотОстановлен
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |    Основа.Ссылка КАК Пользователь,
        |    ВЫБОР
        |        КОГДА Основа.Оповещения = ЗНАЧЕНИЕ(Перечисление.ПериодичностьУведомлений.Нет)
        |                ИЛИ Основа.Оповещения = ЗНАЧЕНИЕ(Перечисление.ПериодичностьУведомлений.ПустаяСсылка)
        |            ТОГДА ЛОЖЬ
        |        ИНАЧЕ РАЗНОСТЬДАТ(НАЧАЛОПЕРИОДА(Основа.Дата, ДЕНЬ), НАЧАЛОПЕРИОДА(&ТекущаяДата, ДЕНЬ), ДЕНЬ) >= ВЫБОР Основа.Оповещения
        |                КОГДА ЗНАЧЕНИЕ(Перечисление.ПериодичностьУведомлений.Ежедневно)
        |                    ТОГДА 1
        |                КОГДА ЗНАЧЕНИЕ(Перечисление.ПериодичностьУведомлений.Еженедельно)
        |                    ТОГДА 7
        |            КОНЕЦ
        |    КОНЕЦ КАК Отправка,
        |    Основа.Telegram КАК Telegram,
        |    Основа.VK КАК VK,
        |    Основа.ТГ_БотОстановлен КАК Остановлен,
        |    Основа.Оповещения КАК Оповещения
        |ПОМЕСТИТЬ Финал
        |ИЗ
        |    Основа КАК Основа
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |    Финал.Пользователь КАК Пользователь,
        |    Финал.Отправка КАК Отправка,
        |    Финал.Telegram КАК Telegram,
        |    Финал.VK КАК VK,
        |    Финал.Остановлен КАК Остановлен,
        |    Финал.Оповещения КАК Оповещения
        |ИЗ
        |    Финал КАК Финал
        |ГДЕ
        |    Финал.Отправка = ИСТИНА";
    
    Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса());
    
    РезультатЗапроса        = Запрос.Выполнить();
    МассивНапоминаний       = ПолучитьМассивНапоминаний();
    ГСЧ                     = Новый ГенераторСлучайныхЧисел;
    КоличествоНапоминаний   = МассивНапоминаний.ВГраница();    
    ВыборкаДетальныеЗаписи  = РезультатЗапроса.Выбрать();

    МассивКнопок = Новый Массив;
    
    МассивКнопок.Добавить("Ежедневно");
    МассивКнопок.Добавить("Еженедельно");
    МассивКнопок.Добавить("Не напоминать");
                
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        
        СлучайноеЧисло     = ГСЧ.СлучайноеЧисло(0,  КоличествоНапоминаний);
        Напоминание        = МассивНапоминаний[СлучайноеЧисло];
        Отправлено         = Ложь;
                    
        Напоминание = "Знали ли вы?"
            + Символы.ПС
            + Символы.ПС
            + "*"
            + Напоминание
            + "*"
            + Символы.ПС
            + Символы.ПС
            + "Вы ведь " 
            + ?(ВыборкаДетальныеЗаписи.Оповещения = Перечисления.ПериодичностьУведомлений.Ежедневно
                , "сегодня"
                , "на этой неделе")
            + " еще ничего не читали! "
            + "Нужно наверстать упущенное, а ниже можно выбрать, как часто будут приходить такие напоминания";
        
        Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.Telegram) И Не ВыборкаДетальныеЗаписи.Остановлен Тогда
            
            КлавиатураТелеграм = МетодыРаботыTelegram.СформироватьКлавиатуруПоМассивуКнопок(МассивКнопок, Истина);

            МетодыРаботыTelegram.ОтправитьСообщение(ВыборкаДетальныеЗаписи.Telegram
                , Напоминание
                , КлавиатураТелеграм);
                
            Отправлено     = Истина;
            
        ИначеЕсли ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.VK) Тогда
            
            КлавиатураВК    = МетодыРаботыVK.СформироватьКлавиатуру(МассивКнопок, Истина, Истина);
            Напоминание     = СтрЗаменить(Напоминание, "*", """");
            МетодыБота.ОтправитьОтвет(ВыборкаДетальныеЗаписи.Пользователь, Напоминание, КлавиатураВК);
            
            Отправлено      = Истина;
            
        Иначе 
            
            Отправлено		= Ложь;
            Продолжить;
            
        КонецЕсли;
        
        Если Отправлено Тогда
            
            МЗ = РегистрыСведений.ПотоковоеЧтение.СоздатьМенеджерЗаписи();
            МЗ.Пользователь = ВыборкаДетальныеЗаписи.Пользователь;
            МЗ.Текст        = Справочники.Произведения.Оповещение;
            МЗ.Дата         = ТекущаяДатаСеанса();
            МЗ.Записать(Истина);
            
        КонецЕсли;
        
        ИнструментарийВызовСервера.Ожидание(5);
        
    КонецЦикла;

КонецПроцедуры

// Обнуляет число слов дня недели для диаграмы в профиле пользователя
Процедура УстановитьЧислоСловНачалаДня() Экспорт
    
    Попытка
        
        ТД        = НачалоДня(ТекущаяДатаСеанса());
        ДН        = ДеньНедели(ТекущаяДатаСеанса());
        Набор     = РегистрыСведений.ДневнойПрогресс.СоздатьНаборЗаписей();
        
        ЭлементОтбора = Набор.Отбор.День;    
        ЭлементОтбора.ВидСравнения = ВидСравнения.Равно;
        ЭлементОтбора.Установить(ИнструментарийВызовСервера.ВернутьДеньНедели(ДН));
        
        Набор.Прочитать();
        
        Для Каждого Запись Из Набор Цикл
            
            Если Не Запись.Дата = ТД Тогда
                
                Запись.Дата             = ТД;
                Запись.КоличествоСлов   = 0;
                
            КонецЕсли;
            
        КонецЦикла;
                
        Набор.Записать(Истина);
        
    Исключение
        ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());    
    КонецПопытки;
    
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьМассивНапоминаний() 
    
    МассивНапоминаний = Новый Массив;
    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |    ТекстыНапоминаний.Текст КАК Текст
        |ИЗ
        |    Справочник.ТекстыНапоминаний КАК ТекстыНапоминаний";
    
    РезультатЗапроса = Запрос.Выполнить();
    
    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
    
    Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
        МассивНапоминаний.Добавить(ВыборкаДетальныеЗаписи.Текст);    
    КонецЦикла;
    
    Возврат МассивНапоминаний;
    
КонецФункции

#КонецОбласти
