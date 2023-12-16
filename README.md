![2athenaeum](https://github.com/Bayselonarrend/2athenaeum/raw/master/info/athenaeum.webp)

# Two-Digit Athenaeum

>VK: [https://vk.com/aioniotis](https://vk.com/aioniotis)<br>
>Telegram: [https://t.me/aioniotis](https://t.me/aioniotis)<br>
>Сайт: [https://athenaeum.digital/](https://athenaeum.digital/)

*Two-Digit Athenaeum* - это облачная онлайн библиотека, расположенная по адресу https://athenaeum.digital. Книги в ней распространяются посредством отправки ботом сообщений в ВК и Telegram. Она состоит из:

1. Сайта (html/css + js (ajax))
2. Бэка (API и статика)
3. CMS Для VK и Telegram
4. Чат-бота для VK и Telegram

При этом, все, внезапно, реализовано на 1С:Enterprise и представляет из себя две базы/проекта EDT.
Подобные разрозненные, на первый взгляд, механизмы, на самом деле, крепко связаны вокруг предметной области: 

1. Пользователь находит группу ВК (Телеграм), которая ведется из базы CMS
2. Пользователь узнает о сайте / видит рекламу книги в группе  
3. Пользователь авторизуется на сайте и выбирает книгу   
4. Чат-бот ему её отправляет  
5. Чат-бот находится в группе ВК или Telegram

Всё это и есть Two-Digit Athenaeum

## Для разработчиков в поиске решения своих задач ##

Репозиторий не представляет из себя универсальные механизмы - реализация местами может быть заточена сугубо под конкретные задачи базы, однако в нем все равно представлено много решений, которые можно использовать с минимальными переработками:
Как уже было упомянуто ранее, проект состоит из 2-х баз

### Aioniotis CMS - проект управления контентом для группы ВК и канала Telegram

[![Статус порога качества](https://api.athenaeum.digital/Sonar/api/project_badges/measure?project=AioniotisCMS&metric=alert_status)](https://api.athenaeum.digital/Sonar/dashboard?id=AioniotisCMS)
[![Строки кода](https://api.athenaeum.digital/Sonar/api/project_badges/measure?project=AioniotisCMS&metric=ncloc)](https://api.athenaeum.digital/Sonar/dashboard?id=AioniotisCMS)

Данная база отвечает за медийную часть проекта. Основной целью было создать систему управления контентом, которая могла бы минимизировать мое участие в ведении группы. Весь реализованный функционал нацелен на автоматизацию всего, что можно автоматизировать в жизни админа и криейтера: создание постов из сырых данных, очередь и планирование публикаций во времени, регулярные посты (вроде дней рождений писателей, повторяющихся каждый год), создание постов на основе генератора случайных чисел (как, например, опросы о любимом авторе по нескольким случайным авторам из справочника) и пр.

В этом проекте реализованы:

1. Методы VK и Telegram API

    Модули МетодыРаботыVK, МетодыРаботыTelegram
  
     На основе наработок данного проекта были созданы библиотеки [VKEnterprise](https://github.com/Bayselonarrend/VKEnterprise) и [TelegramEnterprise](https://github.com/Bayselonarrend/TelegramEnterprise). Для непосредественного использования гораздо удобнее взять сразу эти решения, однако здесь можно посмотреть на их использование:
     
     - Постинг
     - Создание опросов (VK)
     - Получение статистики (общей и по постам) (VK)
     - Публикация историй (VK)
     - Лайки и репосты (VK)
     - Авторизация пользователей на сайте
     - Работа с рекламным кабинетом (VK)
     - Сокращение ссылок через VK.CC
     - Некоторые иные мелкие механизмы

___
  
2. Работа с ImageMagick (Статья [на Инфостарте](https://infostart.ru/1c/articles/1923036/))

   Модуль МетодыОбработкиИзображений
   
   - Формирование карточек разных размеров по изображению
   - Текст на картинках
   - Наложение одной картинки на другую
   - Создание комплексных пано на основе нескольких картинок, теней, текста

3. Непосредственно сам бизнес-процесс

    Модуль МетодыРегламентныхЗаданий, МетодыОбработкиИзображений, МетодыФормированияПостов
    
   - Очередь постов и расписание постинга с автоматической публикацией
   - Простые посты картинка + текст и сложные посты из нескольких картинок с обработкой ImageMagick - этакие пайплайны, превращающие текст и двоичные данные из справочников/документов непосредственно в цепочки запросов к TG и VK с нужными данными
   - Посты с аудиовложениями

___ 

### Ferapont - интерактивная часть Two-Digit Athenaeum: бот и сайт

[![Статус порога качества](https://api.athenaeum.digital/Sonar/api/project_badges/measure?project=Ferapont&metric=alert_status)](https://api.athenaeum.digital/Sonar/dashboard?id=Ferapont)
[![Строки кода](https://api.athenaeum.digital/Sonar/api/project_badges/measure?project=Ferapont&metric=ncloc)](https://api.athenaeum.digital/Sonar/dashboard?id=Ferapont)

Ферапонт - имя телеграм бота, рассылающего книги из библиотеки, однако помимо бота в этот проект еще вошли методы для работы сайта. Для уменьшения нагрузки на сервер (1С все-таки) была выбрана следующая схема веб-приложения
- Сам сайт непосредственно располагается на neocities (это такой сервис, позволяющий публиковать сатические веб-сайты. Нечто вроде GitHub Pages). Есть несколько статических страниц и ajax скрипты
- Вся информация, которая не изменяется во времени (или изменяется крайне редко), хранится тоже там - в виде json файлов. Эти json файлы формирует по алгоритму 1С на основе информации из справочников и заливает в каталог сайта на neocities в нужной структуре. Т.е., например, есть статичная страница book.html (для показа книг), загружающая нужную книгу при помощи ajax. Просто обращается этот ajax не к моему серверу - к бэку, а запрашивает статический json у того же neocitites. ... PROFIT
- Все, что статикой заменить никак нельзя, т.е. профиль и авторизацию, обрабатывает 1С совими методами, вызываемыми цепочкой nginx -> node.js -> COM-соединение (раньше это были 1Сные http-сервисы с IIS - последняя такая версия есть в релизах). Профиль обрабатывается ajax запросами непосредственно к api, авторизация работает через Telegram и VK - к 1С обращаются уже они.

В этом проекте реализованы:

1. Небольшие примеры использования 1С как RestAPI

   Модуль МетодыApiСайта

   - Формирование json для ajax
   - Авторизация через Телеграм и ВК
   - Профили пользователей и статистика

___ 

2. Бот (единый механизм для VK и ТГ, ветвящийся на отправке сообщений)

    Модуль МетодыБота

   - Отправка текста и смайлов
   - Работа с клавиатурами
   - Рассылка напоминаний

___

3. Автотесты http-сервисов

    Модуль МетодыТестирования
   
   Моя попытка в автоматизированное тестирование. Обусловленно жесточайщей необходимостью - трястись после каждой правки в механизм бота и проверять 20+ пунктов, начиная от регистрации нового пользователя в каждую соц. сеть (что требует миллион телодвижений), заканчивая отправкой книги по коду, просто невыносимо. Выглядит это тестирование так:

   - Есть константа ЗаписыватьТесты. Когда она Истина - все сервисы, где прописано условие проверки этой константы, начинают записывать свои запросы в специальный справочник как:
       - Имя Метода
       - JSON тела, если есть (Строкой)
       - Заголовки (как есть из HttpСервисЗапрос - в ХранилищеЗначений)
       - Параметры запроса (как есть из HttpСервисЗапрос - в ХранилищеЗначений)
    - После записи этот тест можно запустить. В процессе запуска он проходит 3 этапа
       - Процедура предобработки - специально написанная процедура, добавленная в перечень процедур предобработки для конкретного теста. В нее попадают записанные в Спр. данные и их можно обработать. Можно обработать и что-нибудь другое. Так, например, при запуске теста регистрации, данная процедура чистит Telegram ID у моего пользователя, чтобы зарегистрировался новый, сохраняя его в доп. параметры для последющей сверки.
       - Общая процедура отправки запроса на свой сервис, создающая запрос из сохраненных (и, возможно, подредактированных в предыдущем пункте) данных
       - Процедура постобработки - специально написанная процедура, добавленная в перечень процедур предобработки для конкретного теста. В нее попадает Ответ от сервиса и доп. параметры из пред. обработки. Если вернуться к примеру с регистрацией, то тут я достаю сохраненный ранее ID, ищу в базе, создался ли новый пользователь с таким, после чего удаляю этого нового пользователя и возвращаю ID своему. Ошибку в прохождении теста я определяею Если Тогда ВызватьИсключение.

    Информация о выполнении или невыполнении пишется в РС

4. nginx + Node.JS + COM

   Каталог nodejs

   Однажды стандартная схема была заменена на вот это. О приницпе действия можно подробнее узнать в [статье на Инфостарте](https://infostart.ru/1c/articles/1996431/). Если кратко:
   - Есть простой node.js сервер, связанный с внешним миром через nginx
   - Внутри скрипта сервера при его старте поднимается COM соединение (V83.ComConnector) с 1С. Делается это посредством библиотеки [winax (node-activex)](https://github.com/durs/node-activex)
   - Как только на сервер поступает запрос, node.js через COM вызывает метод 1С, передавая туда полученные данные в качестве параметра.

   Это просто работает быстрее и стабильнее стандартных http-сервисов на IIS, даже при все дурной славе COM-соединения
   
## Для разработчиков, которые хотят поучаствовать ##

Если у вас есть интересные идеи или вы пользуетесь билиотекой, но вам чего-то не хватает - присылайте. Помимо GitHub, у нас есть та самая [группа ВК](https://vk.com/aioniotis) - можно писать в обсуждения.
<br>
<hr>

>![Infostart](https://github.com/Bayselonarrend/TelegramEnterprise/raw/main/infostart.svg)
>
>Все статьи из недр проекта на Инфостарте: <br>
>[https://infostart.ru/1c/articles/1982182/](https://infostart.ru/1c/articles/1982182/)<br>
>[https://infostart.ru/1c/articles/1996431/](https://infostart.ru/1c/articles/1996431/)<br>
>[https://infostart.ru/1c/articles/1923036/](https://infostart.ru/1c/articles/1923036/)<br>

<br>
<hr>
<br>

## Что используется в проекте ##

Библиотеки TelegramEnterprise и VKEnterprise использют некоторые функции из проекта Коннектора

>Copyright 2017-2023 Vladimir Bondarevskiy под Apache License, Version 2.0
>https://github.com/vbondarevsky/Connector/

Используются методы HMAC SHA-256 и некоторые другие из БСП

>Copyright (c) 2019, ООО 1С-Софт
>Все права защищены. Эта программа и сопроводительные материалы предоставляются 
>в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
>Текст лицензии доступен по ссылке:
>https://creativecommons.org/licenses/by/4.0/legalcode

Для поднятия COM-соединения с 1С из node.js используется node-activex/winax 

>Copyright (c) 2023 Yuri Dursin под MIT<br>
>https://github.com/durs/node-activex<br>
>https://www.npmjs.com/package/winax




