#Область СлужебныйПрограммныйИнтерфейс
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
Функция СведенияОВнешнейОбработке() Экспорт	
	Возврат Неопределено;	
КонецФункции

Функция ПолучитьОбъектРегламентногоЗадания(УникальныйНомерЗадания) Экспорт
	
	Попытка
		
		Если НЕ ПустаяСтрока(УникальныйНомерЗадания) Тогда
			УникальныйИдентификаторЗадания = Новый УникальныйИдентификатор(УникальныйНомерЗадания);
			ТекущееРегламентноеЗадание = РегламентныеЗадания.НайтиПоУникальномуИдентификатору(УникальныйИдентификаторЗадания);
		Иначе
			ТекущееРегламентноеЗадание = Неопределено;
		КонецЕсли;
		
	Исключение
		ТекущееРегламентноеЗадание = Неопределено;
    КонецПопытки;
	
	Возврат ТекущееРегламентноеЗадание;
	
КонецФункции

Функция ПолучитьОбъектФоновогоЗадания(УникальныйНомерЗадания) Экспорт
	
	Попытка
		
		Если НЕ ПустаяСтрока(УникальныйНомерЗадания) Тогда
			УникальныйИдентификаторЗадания = Новый УникальныйИдентификатор(УникальныйНомерЗадания);
			ТекущееФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(УникальныйИдентификаторЗадания);
		Иначе
			ТекущееФоновоеЗадание = Неопределено;
		КонецЕсли;
		
	Исключение
		ТекущееФоновоеЗадание = Неопределено;
    КонецПопытки;
	
	Возврат ТекущееФоновоеЗадание;
	
КонецФункции

#КонецЕсли
#КонецОбласти

