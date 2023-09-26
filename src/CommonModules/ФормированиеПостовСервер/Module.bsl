
#Область ПрограммныйИнтерфейс

Функция СформироватьТекстПоста(Знач Пост) Экспорт
	
	Произведение 		= Пост.Содержание;
	
	Если ТипЗнч(Произведение) = Тип("СправочникСсылка.Цитаты") Тогда
		
		ПроизведениеАвтор 	= Произведение.ПроизведениеАвтор;

		
		Возврат ?(ТипЗнч(ПроизведениеАвтор) = Тип("СправочникСсылка.Люди")
						, СформироватьЦитату(Произведение)
						, СформироватьОтрывок(Произведение));
		
	ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.Произведения") Тогда
		
		Возврат СформироватьТекст(Произведение);
		
	ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.Колонки") Тогда
		
		Возврат СформироватьКолонку(Произведение);
				
	//ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.Термины") Тогда
	//	
	//	Возврат "";  
		
	ИначеЕсли ТипЗнч(Произведение) = Тип("СправочникСсылка.События") Тогда
		
		Возврат Произведение.Описание;
		
	Иначе
		
		Возврат "";
	КонецЕсли;
	
КонецФункции

Функция СформироватьТекстTwitter(Знач Пост) Экспорт
	
	Если Не ТипЗнч(Пост.Содержание) = Тип("СправочникСсылка.Произведения") 
		И Не ТипЗнч(Пост.Содержание) = Тип("СправочникСсылка.Колонки") Тогда
		Произведение 		= Пост.Содержание;
		ПроизведениеАвтор 	= Произведение.ПроизведениеАвтор;
		Текст			= "";
		
		Если ТипЗнч(Произведение) = Тип("СправочникСсылка.Цитаты") Тогда
			
			Текст = ?(ТипЗнч(ПроизведениеАвтор) = Тип("СправочникСсылка.Люди")
			, СформироватьЦитату(Произведение	, Истина)
			, СформироватьОтрывок(Произведение	, Истина));
		Иначе
			Возврат ""					
		КонецЕсли;
		
		Текст = Текст + Символы.ПС + Символы.ПС;
		
		//Для Каждого Тэг Из Пост.НаборТэгов.Тэги Цикл
		//	Текст = Текст + "#" + Тэг.Значение + " ";
		//КонецЦикла;
		//
		//Текст = Текст + "#" + ?(ТипЗнч(ПроизведениеАвтор) = Тип("СправочникСсылка.Люди")
		//, ПроизведениеАвтор.Фамилия
		//, ПроизведениеАвтор.Автор.Фамилия);
		
		Возврат Текст;
	Иначе
		Возврат ""
	КонецЕсли;

КонецФункции

Функция НовыйПромт(Знач Пост) Экспорт
	
	Произведение 	= Пост.Содержание;
	Тэги			= Пост.Тэги;
	Текст 			= "";
	Н 				= 0;
	
	Для Каждого Тэг Из Тэги Цикл
		Текст = Текст + " " + Тэг.Тэг.Английский;
	КонецЦикла;
	
	Возврат "/imagine prompt:black and white neoclassical style contour drawing abstract surrealistic "
	+ СокрЛП(Текст)
	+ " metaphor realistic";

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции


Функция СформироватьОтрывок(Знач Произведение, Знач ТолькоШапка = Ложь) 
	
	Текст 		= "";
	Библиотека 	= "";
	
	//@skip-check reading-attribute-from-database
	ПроизведениеАвтор 	= Произведение.ПроизведениеАвтор;
	//@skip-check reading-attribute-from-database
	Автор				= ПроизведениеАвтор.Автор;
	
	Если Не ТолькоШапка Тогда
		
		//@skip-check reading-attribute-from-database
		ПроизведениеТекст = Произведение.Текст;
		
		Текст = Текст
		+ "«" 
		+ СокрЛП(ПроизведениеТекст)
		+ "»"
		+ Символы.ПС
		+ Символы.ПС;
		
		Если ПроизведениеАвтор.НаСайте Тогда
			Библиотека = Символы.ПС
			+ Символы.ПС
			+ "Кстати, это произведение есть в нашей электронной библиотеке по коду "
			+ ПроизведениеАвтор.Код 
			+ " или по ссылке "
			+ "https://athenaeum.digital/book?id="
			+ ПроизведениеАвтор.Код
			+ Символы.ПС
			+ Символы.ПС
			+ "Если вы еще не знакомы с нашей библиотекой, то подробнее можно узнать по кнопке «Библиотека» в меню сообщества"; 
		КонецЕсли;
		
	КонецЕсли;
	
	//@skip-check reading-attribute-from-database
	Текст = Текст
	+ СокрЛП(Автор.Имя)
	+ " "
	+ СокрЛП(Автор.Фамилия)
	+ ", «"
	+ СокрЛП(ПроизведениеАвтор.Наименование)
	+ "», "
	+ СокрЛП(ПроизведениеАвтор.Дата)
	+ Библиотека;
	
	
	Возврат Текст
	
КонецФункции

Функция СформироватьЦитату(Знач Произведение, Знач ТолькоШапка = Ложь) 
	
	Текст = "";
	
	Если Не ТолькоШапка Тогда
		//@skip-check reading-attribute-from-database
		Текст = Текст 
		+ "«" 
		+ Произведение.Текст
		+ "»"
		+ Символы.ПС
		+ Символы.ПС
		
	КонецЕсли;
	
	//@skip-check reading-attribute-from-database
	Текст = Текст 
	+ СокрЛП(Произведение.ПроизведениеАвтор.Имя)
	+ " "
	+ СокрЛП(Произведение.ПроизведениеАвтор.Фамилия)
	+ " — "
	+ СокрЛП(Произведение.ПроизведениеАвтор.КраткоеОписание);

	Возврат Текст
	
КонецФункции

Функция СформироватьТекст (Знач Произведение)
	
	//@skip-check reading-attribute-from-database
	Текст = СокрЛП(Произведение.Текст)
	+ Символы.ПС
	+ Символы.ПС
	+ СокрЛП(Произведение.Автор.Имя)
	+ " "
	+ СокрЛП(Произведение.Автор.Фамилия)
	+ " — «"
	+ СокрЛП(Произведение.Наименование)
	+ "»";
	
	Возврат Текст

КонецФункции

Функция СформироватьКолонку (Знач Произведение)
	
	Возврат СокрЛП(Произведение.Текст)

КонецФункции

#КонецОбласти



