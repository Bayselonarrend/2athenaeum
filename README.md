# 2athenaeum

## О проекте
Two-Digit Athenaeum - это облачная онлайн библиотека, расположенная по адресу https://athenaeum.digital. Книги в ней распространяются посредством отправки ботом сообщений в ВК и Telegram. Она состоит из:

1. Сайта (html/css + js (ajax))
2. Бэка (как REST API и фабрика статики)
3. CMS Для VK и Telegram
4. Чат-бота для VK и Telegram

При этом, все, внезапно, реализовано на 1С:Enterprise и это все одна база. Теперь я знаю, что это возможно.

Подобные разрозненные механизмы, на самом деле, крепко связаны вокруг предметной области: 

Пользователь находит группу ВК (Телеграм), которая ведется из этой базы -> 
Пользователь узнает о сайте / видит рекламу книги в группе -> 
Пользователь авторизуется на сайте и выбирает книгу ->  
Чат-бот ему её отправляет -> 
Чат-бот находится в группе ВК

Всё это и есть Two-Digit Athenaeum

##Для разработчиков в поиске решения своих задач:

Репозиторий не представляет из себя универсальные механизмы - реализация местами может быть заточена сугубо под конкретные задачи базы, однако в нем все равно представлено много решений, которые можно использовать с минимальными переработками:

Все http реализовано на основе Коннектора HTTP https://github.com/vbondarevsky/Connector

1. Реализация методов VK и Telegram API

  Модули ВК_Апи, ТГ_Апи, ВК_Действия, ТГ_Действия
   
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
  
2. Работа с ImageMagick (Статья https://infostart.ru/1c/articles/1923036/)

   Модули РаботаССистемойСервер, МетодыОбработкиИзображений
   
   - Формирование карточек разных размеров по изображению
   - Текст на картинках
   - Наложение одной картинки на другую
  
3. Небольшие примеры использования 1С как RestAPI

   Сайт_Апи и Модули http-сервисов

   - Работа с Cookie
   - Формирование json для ajax

##Для разработчиков, которые хотят поучаствовать

Если у вас есть интересные идеи или вы пользуетесь билиотекой, но вам чего-то не хватает - присылайте. Помимо GitHub, у нас есть та самая группа ВК (vk.com/aioniotis) - можно писать в обсуждения.
