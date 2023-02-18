<h1 align="center">ПОДГОТОВКА ДАННЫХ ДЛЯ АНАЛИЗА ПРОДАЖ В МАГАЗИНАХ ПРОКАТА DVD</h1>


<p align="center">
  <img src="https://github.com/KlyapkoV/DVD_RENTAL_STORE/blob/main/images/logo.png">
</p>


## _`ИСПОЛЬЗУЕМАЯ СУБД`:_
**PostgreSQL**

## _`ОБЪЕКТЫ БАЗЫ ДАННЫХ:`_
> - **15 таблиц**
> - **13 последовательностей**
> - **8 функций**
> - **7 представлений**
> - **1 триггер**
> - **1 домен**

## _`ОПИСАНИЕ ТАБЛИЦ БАЗЫ ДАННЫХ:`_
| Наименование таблицы | Описание |
|--------------|:-----|
| **actor** | данные об актеров (включая имя и фамилию) |
| **film** | данные о фильме (название, год выпуска, продолжительность, рейтинг и т.д.) |
| **film_actor** | взаимосвязи между фильмами и актёрами |
| **category** | данные о категориях фильма |
| **language** | языки фильмов |
| **film_category** | взаимосвязи между фильмами и категориями |
| **store** | сведения о магазине (включая персонал, менеджера и адрес) |
| **inventory** | данные по инвентаризации |
| **rental** | данные об аренде |
| **payment** | данные о платежах клиента |
| **staff** | данные о персонале |
| **customer** | данные о клиенте|
| **address** | адреса персонала и клиентов |
| **city** | названия городов |
| **country** | названия стран |

&nbsp;

# РАЗВЁРТЫВАНИЕ БАЗЫ ДАННЫХ:
- ## [Инструкция по развёртыванию базы данных](https://www.postgresqltutorial.com/postgresql-getting-started/load-postgresql-sample-database)
- ## [Архив с файлами для развёртывания базы данных](https://github.com/KlyapkoV/DVD_RENTAL_STORE/blob/main/dvdrental.zip)
- ## [ER-диаграмма](https://github.com/KlyapkoV/DVD_RENTAL_STORE/blob/main/ER-diagram.pdf)

&nbsp;

# [SQL-СКРИПТ ВЫПОЛНЕНИЯ ТЕХНИЧЕСКОГО ЗАДАНИЯ](https://github.com/KlyapkoV/DVD_RENTAL_STORE/blob/main/script.sql)
