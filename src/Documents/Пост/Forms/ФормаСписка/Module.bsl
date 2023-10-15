#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Список1.Параметры.УстановитьЗначениеПараметра("Автор", Неопределено);
КонецПроцедуры

#КонецОбласти




#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СообществоПриИзменении(Элемент)
	СообществоПриИзмененииНаСервере();
КонецПроцедуры

#КонецОбласти




#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок1

&НаКлиенте
Процедура Список1Выбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	#Если Не ВебКлиент Тогда
		ОО = Новый ОписаниеОповещения();		
		ПоказатьЗначение(ОО, Элементы.Список1.ТекущиеДанные.Ссылка);
	#КонецЕсли
	КонецПроцедуры

#КонецОбласти




#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок

&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	ТД = Элементы.Список.ТекущиеДанные;
	
	Если Не ТД = Неопределено Тогда
		Список1.Параметры.УстановитьЗначениеПараметра("Автор", Элементы.Список.ТекущиеДанные.Автор);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти




#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Обновить(Команда)
	Элементы.Список1.Обновить();
КонецПроцедуры

#Если Не ВебКлиент Тогда
&НаКлиенте
Процедура Запостить(Команда)
	
	ТД = Элементы.Список1.ТекущиеДанные;
	
	ПоляЗаписи = Новый Структура;
	ПоляЗаписи.Вставить("Дата"		, ТД.Период);
	ПоляЗаписи.Вставить("Пост"		, ТД.Ссылка); 
	ПоляЗаписи.Вставить("Автор"		, ТД.Автор);
	ПоляЗаписи.Вставить("Вид"		, ТД.Вид);
	
	ЗапоститьНаСервере(ПоляЗаписи);
	
	ОО = Новый ОписаниеОповещения();		
	ПоказатьЗначение(ОО, ПоляЗаписи.Пост);
		
КонецПроцедуры

#КонецЕсли


&НаКлиенте
Процедура ВОчередь(Команда)
	ВОчередьНаСервере(Элементы.Список.ТекущиеДанные.Ссылка);
	Элементы.Список1.Обновить();
	Элементы.Список.Обновить();
КонецПроцедуры

&НаКлиенте
Процедура ЗапоститьВК(Команда)
	
	ТД = Элементы.Список1.ТекущиеДанные;
	
	ПоляЗаписи = Новый Структура;
	ПоляЗаписи.Вставить("Дата"		, ТД.Период);
	ПоляЗаписи.Вставить("Пост"		, ТД.Ссылка); 
	ПоляЗаписи.Вставить("Автор"		, ТД.Автор);
	ПоляЗаписи.Вставить("Вид"		, ТД.Вид);
	
	ЗапоститьНаСервере(ПоляЗаписи, Истина);

КонецПроцедуры

&НаКлиенте
Процедура ЗапоститьТГ(Команда)
	
	ТД = Элементы.Список1.ТекущиеДанные;
	
	ПоляЗаписи = Новый Структура;
	ПоляЗаписи.Вставить("Дата"		, ТД.Период);
	ПоляЗаписи.Вставить("Пост"		, ТД.Ссылка); 
	ПоляЗаписи.Вставить("Автор"		, ТД.Автор);
	ПоляЗаписи.Вставить("Вид"		, ТД.Вид);
	
	ЗапоститьНаСервере(ПоляЗаписи,, Истина);

КонецПроцедуры

&НаКлиенте
Процедура УбратьИзОчереди(Команда)
	УбратьИзОчередиНаСервере(Элементы.Список1.ТекущиеДанные.Ссылка);
КонецПроцедуры

#КонецОбласти




#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗапоститьНаСервере(ПоляЗаписи, ТолькоВК = Ложь, ТолькоТГ = Ложь)
	
	
	Запись = РегистрыСведений.ПорядокПостов.СоздатьМенеджерЗаписи();
	ЗаполнитьЗначенияСвойств(Запись, ПоляЗаписи);
	Запись.ДатаПубликации = ТекущаяДатаСеанса();
	Запись.Опубликован = Истина;
	Запись.Записать(Истина);  
	
	Если Не ТолькоТГ Тогда
		МетодыФормированияПостов.СформироватьПост(ПоляЗаписи.Пост,,Перечисления.СоцСети.VK);
	КонецЕсли;
	
	Если Не ТолькоВК Тогда
		МетодыФормированияПостов.СформироватьПост(ПоляЗаписи.Пост,,Перечисления.СоцСети.Telegram);
	КонецЕсли;
		
КонецПроцедуры


&НаСервереБезКонтекста
Процедура ВОчередьНаСервере(Пост)
	
	ОбъектПост = Пост.ПолучитьОбъект();
	ОбъектПост.Дата = ТекущаяДатаСеанса();
	ОбъектПост.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Оперативный);
	
КонецПроцедуры


&НаСервере
Процедура СообществоПриИзмененииНаСервере()
	
	Список.Отбор.Элементы.Очистить();
	Список1.Отбор.Элементы.Очистить();
	
	ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Сообщество");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.Использование = Истина;
	ЭлементОтбора.ПравоеЗначение = Сообщество;  
	
	ЭлементОтбора = Список1.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Сообщество");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.Использование = Истина;
	ЭлементОтбора.ПравоеЗначение = Сообщество;   
КонецПроцедуры

&НаСервере
Процедура УбратьИзОчередиНаСервере(Документ)
	
	МЗ = РегистрыСведений.ПорядокПостов.СоздатьМенеджерЗаписи();
	МЗ.Пост = Документ;
	МЗ.Прочитать();
	МЗ.Удалить();
	
	Документ.ПолучитьОбъект().Записать(РежимЗаписиДокумента.ОтменаПроведения);
	
	Элементы.Список.Обновить();
	Элементы.Список1.Обновить();
	
КонецПроцедуры


#КонецОбласти



