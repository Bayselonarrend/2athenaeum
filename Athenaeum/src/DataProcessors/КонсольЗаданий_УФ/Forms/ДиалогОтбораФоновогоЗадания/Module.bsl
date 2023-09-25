#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Регламентные = РегламентныеЗадания.ПолучитьРегламентныеЗадания();
	СписокВыбора = Элементы.Регламентное.СписокВыбора;
	Для Каждого РегламентноеЗадание из Регламентные Цикл
		Если СписокВыбора.НайтиПоЗначению(РегламентноеЗадание.Метаданные.Имя) = Неопределено Тогда
			СписокВыбора.Добавить(РегламентноеЗадание.Метаданные.Имя, РегламентноеЗадание.Метаданные.Представление());
		КонецЕсли;
	КонецЦикла;
	
	Активно = Ложь;
	Завершено = Ложь;
	ЗавершеноАварийно = Ложь;
	Отменено = Ложь;
	
	Если Параметры.Отбор <> Неопределено Тогда
		Отбор = Параметры.Отбор.Получить();
		Для Каждого Свойство из Отбор Цикл
			Если Свойство.Ключ = "Начало" Тогда
				Начало = Свойство.Значение;
			ИначеЕсли Свойство.Ключ = "Конец" Тогда
				Конец = Свойство.Значение;
			ИначеЕсли Свойство.Ключ = "Ключ" Тогда
				Ключ = Свойство.Значение;
			ИначеЕсли Свойство.Ключ = "Наименование" Тогда
				Наименование = Свойство.Значение;	
			ИначеЕсли Свойство.Ключ = "ИмяМетода" Тогда
				Метод = Свойство.Значение;	
			ИначеЕсли Свойство.Ключ = "Ключ" Тогда
				Ключ = Свойство.Значение;	
			ИначеЕсли Свойство.Ключ = "РегламентноеЗадание" Тогда
				Регламентное = Свойство.Значение.Метаданные.Имя;

			ИначеЕсли Свойство.Ключ = "Состояние" Тогда
				Для Каждого СостояниеЗадания из Свойство.Значение Цикл
					Если СостояниеЗадания = СостояниеФоновогоЗадания.Активно Тогда
						Активно = Истина;
					ИначеЕсли СостояниеЗадания = СостояниеФоновогоЗадания.Завершено Тогда
						Завершено = Истина;	
					ИначеЕсли СостояниеЗадания = СостояниеФоновогоЗадания.ЗавершеноАварийно Тогда
						ЗавершеноАварийно = Истина;		
					ИначеЕсли СостояниеЗадания = СостояниеФоновогоЗадания.Отменено Тогда
						Отменено = Истина;		
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;		
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	Отбор = ПолучитьОтбор();
	
	Закрыть(Отбор);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучитьОтбор()
	Отбор = Новый Структура;
	
	Если Не ПустаяДата(Начало) Тогда
		Отбор.Вставить("Начало", Начало);
	КонецЕсли;
	
	Если Не ПустаяДата(Конец) Тогда
		Отбор.Вставить("Конец", Конец);
	КонецЕсли;
	
	Если Не ПустаяСтрока(Ключ) Тогда
		Отбор.Вставить("Ключ", Ключ);
	КонецЕсли;
	
	Если Не ПустаяСтрока(Наименование) Тогда
		Отбор.Вставить("Наименование", Наименование);
	КонецЕсли;
	
	Если Не ПустаяСтрока(Метод) Тогда
		Отбор.Вставить("ИмяМетода", Метод);
	КонецЕсли;
	
	Если Регламентное <> "" Тогда
		МассивРегламентных = РегламентныеЗадания.ПолучитьРегламентныеЗадания(Новый Структура("Метаданные", Регламентное));
		Если МассивРегламентных.Количество() > 0 Тогда
			Отбор.Вставить("РегламентноеЗадание", МассивРегламентных[0]);
		КонецЕсли;
	КонецЕсли;
	
	Массив = Новый Массив;
	
	Если Активно Тогда
		Массив.Добавить(СостояниеФоновогоЗадания.Активно);
	КонецЕсли;
	
	Если Завершено Тогда
		Массив.Добавить(СостояниеФоновогоЗадания.Завершено);
	КонецЕсли;
	
	Если ЗавершеноАварийно Тогда
		Массив.Добавить(СостояниеФоновогоЗадания.ЗавершеноАварийно);
	КонецЕсли;
	
	Если Отменено Тогда
		Массив.Добавить(СостояниеФоновогоЗадания.Отменено);
	КонецЕсли;
	
	Если Массив.Количество() > 0 ТОгда
		Отбор.Вставить("Состояние", Массив);
	КонецЕсли;
	
	Возврат Новый ХранилищеЗначения(Отбор);
КонецФункции

&НаСервере
Функция ПустаяДата(Дата)
	Если Дата = '00010101' Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции

#КонецОбласти


