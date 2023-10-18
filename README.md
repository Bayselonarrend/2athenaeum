![2athenaeum](https://github.com/Bayselonarrend/2athenaeum/raw/master/info/athenaeum.webp)

# Two-Digit Athenaeum

[![Статус порога качества](https://api.athenaeum.digital/Sonar/api/project_badges/measure?project=Aioniotis&metric=alert_status)](https://api.athenaeum.digital/Sonar/dashboard?id=Aioniotis)
[![Строки кода](https://api.athenaeum.digital/Sonar/api/project_badges/measure?project=Aioniotis&metric=ncloc)](https://api.athenaeum.digital/Sonar/dashboard?id=Aioniotis)

*Two-Digit Athenaeum* - это облачная онлайн библиотека, расположенная по адресу https://athenaeum.digital. Книги в ней распространяются посредством отправки ботом сообщений в ВК и Telegram. Она состоит из:

1. Сайта (html/css + js (ajax))
2. Бэка (API и статика)
3. CMS Для VK и Telegram
4. Чат-бота для VK и Telegram

При этом, все, внезапно, реализовано на 1С:Enterprise и это все одна база. Теперь я знаю, что это возможно.

Подобные разрозненные механизмы, на самом деле, крепко связаны вокруг предметной области: 

1. Пользователь находит группу ВК (Телеграм), которая ведется из этой базы 
2. Пользователь узнает о сайте / видит рекламу книги в группе  
3. Пользователь авторизуется на сайте и выбирает книгу   
4. Чат-бот ему её отправляет  
5. Чат-бот находится в группе ВК

Всё это и есть Two-Digit Athenaeum

## Для разработчиков в поиске решения своих задач ##

Репозиторий не представляет из себя универсальные механизмы - реализация местами может быть заточена сугубо под конкретные задачи базы, однако в нем все равно представлено много решений, которые можно использовать с минимальными переработками:

Все http реализовано на основе Коннектора HTTP https://github.com/vbondarevsky/Connector

1. Реализация методов VK и Telegram API

    Модули МетодыРаботыVK, МетодыРаботыTelegram
  
     На основе наработок данного проекта были созданы библиотеки [VKEnterprise](https://github.com/Bayselonarrend/VKEnterprise) и [TelegramEnterprise](https://github.com/Bayselonarrend/TelegramEnterprise). Для непосредественного использования гораздо удобнее взять сразу эти рещения, однако здесь можно посмотреть на их использование:
     
     - Постинг
     - Отправка и прием сообщений ботом
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

___
  
3. Небольшие примеры использования 1С как RestAPI

   Модуль МетодыСайта и модули http-сервисов

   - Работа с Cookie
   - Формирование json для ajax
   - Авторизация через Телеграм и ВК
   - Профили пользователей и статистика

## Для разработчиков, которые хотят поучаствовать ##

Если у вас есть интересные идеи или вы пользуетесь билиотекой, но вам чего-то не хватает - присылайте. Помимо GitHub, у нас есть та самая [группа ВК](https://vk.com/aioniotis) - можно писать в обсуждения.
