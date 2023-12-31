#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыполнитьВсе(Команда)
	ВыполнитьВсеНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура НачатьЗапись(Команда)
	ИзменитьРежим(Истина);
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьЗапись(Команда)
	ИзменитьРежим(Ложь);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура ИзменитьРежим(Включение)
	Константы.ЗаписыватьТесты.Установить(Включение);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВыполнитьВсеНаСервере()
	
	Выборка = Справочники.АвтотестыСервисов.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ИнструментарийВызовСервера.Ожидание(2);
		МетодыТестирования.ЗапускТеста(Выборка.Ссылка);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти