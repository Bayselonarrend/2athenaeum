
Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
     Возврат;
	КонецЕсли;
	
	Попытка
		
		ДН				= ДеньНедели(ТекущаяДатаСеанса());
		Набор 			= РегистрыСведений.ДневнойПрогресс.СоздатьНаборЗаписей();
		ЭлементОтбора 	= Набор.Отбор.Пользователь;	
		ЭлементОтбора.ВидСравнения = ВидСравнения.Равно;
		ЭлементОтбора.Установить(Ссылка);
		Набор.Прочитать();
		
		Если Набор.Количество() = 0 Тогда
			Для Н = 0 По 6 Цикл
				
				ЗаполняемыйДень = ?(ДН - Н < 1, ДН - Н + 7, ДН - Н); 
				НоваяЗапись = Набор.Добавить();
				НоваяЗапись.Дата = НачалоДня(ТекущаяДатаСеанса()) - (60 * 60 * 24 * Н);
				НоваяЗапись.ДеньНедели = ИнструментарийВызовСервера.ВернутьДеньНедели(ЗаполняемыйДень);
				НоваяЗапись.КоличествоСлов = 0;
				НоваяЗапись.Пользователь = Ссылка;
				Набор.Записать(Истина);
			КонецЦикла;
			
			
		КонецЕсли;
		
	Исключение
		
		ИнструментарийВызовСервера.ЗаписьВЖурналИсключений(ОписаниеОшибки());
		
	КонецПопытки;

		
КонецПроцедуры
