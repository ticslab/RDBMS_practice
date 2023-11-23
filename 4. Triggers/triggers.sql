-- Тема 3: Триггеры

/*
Триггер выполнятся при наступлении некоторого события в базе данных.
Такое событие должно быть связано с одной из следующих команд: INSERT, UPDATE или DELETE.

Создание триггера:

CREATE TRIGGER trigger_name
{BEFORE | AFTER} { событие } -- Когда будет срабатывать триггер: BEFORE — перед событием. AFTER — после события.
ON table_name  -- Для какой таблицы
[FOR [EACH] { ROW | STATEMENT }] -- Уровня строки или оператора
EXECUTE FUNCTION trigger_function -- Что будет выполняться при активации триггера


Немного про триггеры, если ничего не понятно:
https://sql-ex.ru/blogs/?/Rukovodstvo_po_triggeram_v_SQL_nastrojka_otsleZhivaniJa_bazy_dannyh_v_PostgreSQL.html&ysclid=lp8e8k976c71217248
https://w3resource.com/PostgreSQL/postgresql-triggers.php
*/

/*
Рассмотрим пример триггера для базы данных Sakila.
Триггер будет вызываться перед вставкой новой записи в таблицу film_actor.
Если film_id или actor_id не существует в соответствующих таблицах,
то будет вызвано исключение, и вставка будет отклонена.
Если оба идентификатора существуют, вставка будет успешно завершена.
*/

-- шаг 1. Создание триггерной функции. 
CREATE OR REPLACE FUNCTION check_film_actor_insert() -- Триггерная функция не имеет аргументов
RETURNS TRIGGER AS $$ -- Возвращаемое значение имеет тип trigger
BEGIN
    -- Проверка наличия film_id в таблице film
    IF NOT EXISTS (SELECT 1 FROM film WHERE film_id = NEW.film_id) THEN
        RAISE EXCEPTION 'film_id % не существует в таблице film', NEW.film_id;
    END IF;

    -- Проверка наличия actor_id в таблице actor
    IF NOT EXISTS (SELECT 1 FROM actor WHERE actor_id = NEW.actor_id) THEN
        RAISE EXCEPTION 'actor_id % не существует в таблице actor', NEW.actor_id;
    END IF;

    -- Если проверки прошли успешно, то возвращаем без изменений
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*
Что такое NEW?

NEW - это специальная переменная, предоставляемая в теле триггера,
которая содержит новые значения, которые будут вставлены, обновлены или удалены.
Эта переменная используется, чтобы обращаться к данным,
которые собираются быть внесены в таблицу в результате операции триггера.

Ещё есть специальная переменная OLD, которая содержит старые значения.

Т.е. OLD и NEW представляют состояния строки в таблице до или после триггерного события.
*/

-- шаг 2. Создание триггера на таблице film_actor
CREATE TRIGGER check_film_actor_insert_trigger
BEFORE INSERT ON film_actor
FOR EACH ROW
EXECUTE FUNCTION check_film_actor_insert();

-- Можно проверить работу триггера.
INSERT INTO film_actor(film_id,actor_id) VALUES(35,21);
INSERT INTO film_actor(film_id,actor_id) VALUES(1355,21);
INSERT INTO film_actor(film_id,actor_id) VALUES(35,2211);

-- Задание 1. Доработайте пример, добавив проверку того, существует ли уже такая запись в таблице



/*
Задание 2. В таблице film есть поле last_update, отвечающее за то, когда запись о фильме последний раз была обновлена.
Напишите триггер автоматически обновляющий время (на текущее) при внесении изменений в запись этой таблицы.
*/



/*
Задание 3. В таблице film есть поле rental_duration, которое отвечает за то, на какой срок можно взять фильм в аренду.
Напишите триггер, срабатывающий, когда клиент возвращает взятый в аренду фильм, и проверяющий не просрочил ли он срок аренды. 
Используйте для этого таблицу rental.
*/
