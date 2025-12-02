select
	actor_id ActorIden,
	actor_id as Actor,
	actor_id "ActorIden",
	actor_id as "ActorIden"
from 
	actor;

select
	amount,
	amount + 2,
	amount - 3,
	amount * 1.5,
	amount / 3,
	amount ^ 2,
	amount % 4,
	mod(amount, 4), -- Остаток от деления amount / 4
	div(amount, 2), -- целочисленное деление 
	round(amount / 2, 0), -- округление до 0 знака
	floor(amount /2), -- округление в меньшую сторону
	ceil(amount / 2) -- округление в большую сторону
from
	public.payment;

select
	first_name,
	last_name,
	concat(TRIM(REPLACE(first_name, ' ', '')), ' ' ,TRIM(REPLACE(last_name, ' ', ''))),
	first_name || ' ' || last_name,
	CHAR_LENGTH(first_name || ' ' || last_name), -- выводит длину строки
	trim(leading ' ' || first_name || ' '), -- удаляет пробелы с начала строки
	regexp_replace(first_name, '\s+$', ''),
	TRIM(REPLACE(first_name, ' ', '')), -- удаляет пробелы до имени и после
	substring(first_name, 1, 3), -- первые 3 буквы выводить
	upper(first_name), -- верхний регистр
	lower(first_name) -- нижний регистр
from
	public.actor;

select
	email,
	substring(email, 1, strpos(email, '@') - 1), -- разделяем строку от первого символа до @ -1
	strpos(email, '@')
from
	staff;

select
	*
from
	rental
where
	rental_date between '2005-05-26' and '2005-05-28';

select
	*
from
	film
where
	title like '%Airport%';

select
	*
from
	film
where
	description not like '%Epic%';

select
	*
from
	public.payment
where 
	amount > 7
	and payment_date between '2007-02-02' and '2007-03-31';

select
	*
from
	public.payment
where
	amount between 3.3 and 5.5
	or amount > 7;

select
	*
from
	public.payment
where
	mod (payment_id, 10) = 1; -- id заканчивается на 1 (остаток от деления 1)

-- Сортировка
select
	*
from
	actor
where
	first_name like '%a%'
order by
	first_name asc,
	last_name desc; -- asc по возрастанию desc(убывание)

select
	*
from
	address
order by
	address2 nulls first; -- сначала значения null

select length, rental_duration, title, length / rental_duration
from public.film
order by length / rental_duration desc;

-- Удаление дублей
select
	distinct rental_rate -- вывести уникальные значения
from
	film;

select
	distinct last_name,	first_name -- Выводит уникальную пару
from
	actor;

select distinct on (inventory_id) -- Уникальные значения из этого столбца
	rental_id,
	rental_date,
	inventory_id,
	customer_id,
	return_date,
	staff_id,
	last_update
from rental
order by inventory_id, rental_date desc; -- Так как мы отсортировали дату первую попавшуюся он и выводит

-- Объединение таблиц
select *
from film f
left join inventory i
		using (film_id)	-- right join, full join, cross join
where i.inventory_id is null;

select first_name || ' ' || last_name, title -- всех актеров снявшихся в этом фильме
from film_actor fa
join actor a
	using(actor_id)
join film f
	using(film_id)
where title like 'Chamber Italian';

select rating, 
	count(*) films_count, -- количество фильмов 
	sum(length), -- сумма каждой группы по этому столбцу
	max(length), -- максимальное значение в этой группе
	avg(length), -- avg средняя продолжительность
	bool_and(length < 200), -- условие если для каждой строки длина меньше 200	
	bool_or(length < 185), -- если хотя бы один раз удовлетворяет условию
	string_agg(title, '; ')  -- передаем строчку и разделитель и он выводит все фильммы этой группы разделяемм нашим разделителем
from film
group by rating;

select -- тут сначала сгруппировали все фильмы с одним id в инвентаре, после сложили количество строк, а после join чтобы вывести название фильмов и количество на складе
	title,
	count(*)
from
	inventory i
join film f
	using(film_id)
group by
	film_id;

select -- Выведит имя актера и количество фильмов в которых он снялся и количество уникальных категорий
	a.first_name || ' ' || a.last_name as actor_name,
	count(*) as film_count,
	count(distinct fc.category_id) as category_count
from
	actor a
join film_actor fa
		using(actor_id)
join film_category fc
		using(film_id)
group by 
	a.first_name || ' ' || a.last_name;

select
	a.first_name || ' ' || a.last_name as actor_name,
	count(f.film_id) as count_G_film
from
	actor a
left join film_actor fa
	on fa.actor_id = a.actor_id
left join film f
	on f.film_id = fa.film_id
	and f.rating = 'G'
group by
	actor_name;

select -- По каждому фильму выручка
	f.title as film_title,
	sum(p.amount) as amount
from
	film f
join inventory i
	on
	i.film_id = f.film_id
join rental r
	on r.inventory_id = i.inventory_id
join payment p
	on p.rental_id = r.rental_id
group by
	film_title
order by
	amount desc;

select
	a.first_name || ' ' || a.last_name as actor_name,
	count(fa.film_id) as count_film
from
	actor a
left join film_actor fa
	on
	fa.actor_id = a.actor_id
group by
	actor_name
having count(fa.film_id) > 20; -- условие накладывается на выходные значения

select --  Если имя длинне 15 символов берем первые 7 из имени и первые 7 фамилии
	case
		when length(a.first_name || ' ' || a.last_name) > 15
		then substring (a.first_name, 1, 7) || ' ' || substring(a.last_name, 1, 7)
		else a.first_name || ' ' || a.last_name
	end as short_name
from
	actor a
where substring(case
		when length(a.first_name || ' ' || a.last_name) > 15
		then substring (a.first_name, 1, 7) || ' ' || substring(a.last_name, 1, 7)
		else a.first_name || ' ' || a.last_name
	end, 1, 2) = 'Ca'
order by short_name;

select
	f.title,
	l."name",
	f.language_id,
	l.language_id,
	case
		l."name" -- Если при каждом запросе обращаемся к одному столбцу его можно вынести
		when 'English' then 'Английский'
		when 'German' then 'Немецкий'
		when 'Mandarin' then 'Китайский'
		when 'Japanes' then 'Японский'
		when 'French' then 'Французкий'
		when 'Italian' then 'Итальянский'
	end
from
		film f
join "language" l
on
	case
		when f.rating = 'G' then 2
		else f.language_id
	end = l.language_id; -- Если рейтинг G то присоединяется language_id=2 независимо какой у него язык

select -- Разбиваем на категории
	f.title,
	sum(p.amount) as total_sum,
	case
		when sum(p.amount) >= 150 then 'Top amount'
		when sum(p.amount) >= 100 then 'Middle amount'
		else 'Low amount'
	end as amount_rating
	from
		film f
	join inventory i
			using(film_id)
	join rental r
			using(inventory_id)
	join payment p
			using(rental_id)
	group by
		f.title;

select -- Так можно обойти деление на 0 
	case
		when div(f.rental_rate, 1) = 0 then 0  -- Целочисленное деление если оно равно 0 просто выводим 0
		else 1 / div(f.rental_rate, 1) -- иначе выполняем это действие
	end
from
	film f;

select
	f.title,
	f.rating,
	f.length
from
	film f
where
	case
		when f.rating = 'G' then f.length * 2
		else f.length
	end > 120
	and f.length > 120;

select -- меняем категорию
	f.title,
	c."name",
	fc.category_id,
	c.category_id 
from
	film f
join film_category fc on
		f.film_id = fc.film_id
join category c on
	c.category_id = 
	case
		when fc.category_id = 5 then 1
		else fc.category_id
	end;

select
	title
from
	film
order by
	title
limit 50 -- Выводим всего 50 строк limin null/all - ограничения не накладывает
offset 50 -- начиная с 50. Получается вторые 50 выводим

select
	a.first_name || ' ' || a.last_name as actor_name,
	count(*) as film_cnt
from
	actor a
join film_actor fa on
		fa.actor_id = a.actor_id
group by
	actor_name,
	a.actor_id -- Обязательно группировать по id чтобы не суммировать актеров однофамильцев
order by
	film_cnt desc,
	actor_name
limit 5
offset 5;

select
	f.title,
	'amount' as src -- Это для того чтобы понять из какой таблицы наша строчка
from
	film f
join inventory i
		using (film_id)
join rental r
		using (inventory_id)
join payment p
		using (rental_id)
group by
	f.title
having sum(p.amount) > 150

union -- union all - чтобы оставить дубликаты, еще он производительнее 
/* Условия объединения столбцов
1. Количество столбцов одинаковое
2. Типв столбцов должны быть сопоставимы
3. Выводится название столбцов верхнего запроса
*/
select
	f.title,
	'rental' as src
from
	film f
where
	f.rental_rate > 4;

select -- Тут вывели фильмы в которых снимался гранд но категория не G
	f.title
from
	film f
join film_actor fa
		using(film_id)
join actor a
		using(actor_id)
where
	a.last_name = 'Grant'
except -- исключает из первой таблицы все что во второй
select
	f.title
from
	film f
where
	f.rating = 'G';

select
	f.title
from
	film f
join inventory i
		using (film_id)
join rental r
		using (inventory_id)
join payment p
		using (rental_id)
group by
	f.title
having sum(p.amount) > 150

intersect -- Выводит все что есть и в первой и во второй

select
	f.title
from
	film f
where
	f.rating = 'G';
/* Приоритет
union all
union
except

intersect
 */

select
	f.title
from
	film f
where
	f.rating = 'G'
union all -- intersect тогда останутся фильмы в которых снимался Гранд у которых рейтинг G пересечение получается
select
	f.title
from
	film f
join film_actor fa
		using(film_id)
join actor a
		using(actor_id)
where
	a.last_name = 'Grant';

select
	f.rating,
	count(*), -- сколько всего фильмов каждого рейтинга
	count(*) filter (where length > 120) -- сколько всего фильмов каждого рейтинга длина больше 120
from
	film f
group by
	f.rating;

select *
from address a
where not exists(select 1
				 from customer c
				 where c.address_id = a.address_id); -- Подзапрос который не равно этому равенству
				
select -- Сначала посчитали в какой категории больше 70 фильмов и вывели все эти фильмы
	f.title,
	c."name" as category_name
from
	film f
	join film_category fc2 using(film_id)
	join category c using(category_id)
where
	c.category_id in (select
					  fc.category_id
					  from
					  	film_category fc
					  group by
					  	fc.category_id
					  having
					  	count(*) > 70);
/*
Коррелирующий подзапрос - ссылается на внешнюю таблицу (не рекомендуется т.к. производительность проседает)
Старайтесь писать некоррелирующий подзапрос
 */
select 1 in (1, 2); -- true
select 1 in (2, 3); -- false
select 1 in (null, 1, 2); -- true
select 1 in (null, 2, 3); --null
select null in (1, 2, null); -- если мы ищем null всегда будет null независимо есть он в значениях

select -- Фильмы в которых снялось больше 10 актеров 
	f.title
from
	film f
where
	10 < (
	select
		count(*)
	from
		film_actor fa
	where
		fa.film_id = f.film_id); -- эта конструкция оставляет только те фильмы в которых снялось больше 10 актеров

select
	f.title
from
	film f
where film_id in (select fa.film_id
				  from film_actor fa
				  join actor a using(actor_id)
				  where a.last_name like 'Chase%');

select f.title, (select l."name" from "language" l where l.language_id = f.language_id) -- название фильма и язык через подзапрос
from film f;

/*
CTE(common table expression) - для удобства чтения запроса
with name_alias as(function), next_alias as materialized (function_2) наз. общее табличное выражение второй запрос создаст временную таблицу
select * from some_db join name_alias using(some_column)
как функция выводит его в отдельную переменную и можно ссылаться
Они существуют в рамках этого запроса в след. нельзя на них ссылаться
Если не писать про материализацию, то след. алгоритм действия если она вызывается один раз не материализуется если два и более материализуется
 */
	
with total_sum as (	
					select
						f.film_id,
						sum(p.amount) as total_sum1
					from
						film f
					join inventory i
							using(film_id)
					join rental r
							using(inventory_id)
					join payment p
							using(rental_id)
					group by f.film_id)
select
	f1.title,
	count(a.first_name || ' ' || a.last_name) as count_actor,
	total_sum1
from
	film f1
join film_actor fa
		using(film_id)
join actor a
		using(actor_id)
right join total_sum on
	total_sum.film_id = f1.film_id
group by 
		f1.film_id, total_sum1;
		
with film_amount as ( -- продажи с каждого фильма
					select
						i.film_id,
						sum(p.amount) as amount
					from
						inventory i
					join rental r
							using(inventory_id)
					join payment p
							using(rental_id)
					group by
						i.film_id
					),
total_amount as ( -- сумма продаж со всех фильмов
					select
						sum(fa.amount) as total_amount
					from
						film_amount fa
				 )
select
	f.title,
	fa.amount,
	fa.amount / ta.total_amount * 100 as percent_amount -- доля с общей продажи
from
	film f
left join film_amount fa
		using(film_id)
cross join total_amount ta;
			
select f.title, f.rating, f.length
from film f;

select
	f.title,
	min(f.length) over w as ratiin_lenght,
	row_number() over(partition by f.rating order by f.length) as rm, -- partition by тождественно равно group by
	rank() over(partition by f.rating order by f.length) as rk,
	dense_rank() over(partition by f.rating order by f.length) as drk, -- чтобы понять смс вывод
	lag(f.length, 1) over(partition by f.rating order by f.length) as prev_length, -- Работаем со столбцом length берем одно значение выше и заполняем таблицу
	lead(f.length, 1) over(partition by f.rating order by f.length) as lead_length -- Берем значение на один ниже
from
	film f
window w as (partition by f.rating order by f.length);
-- Оконные функции: После чего-то после пишем over после пишем или название оконной функции или внутри скобки логику функции

select
	c."name",
	c.category_id,
	ntile(8) over() as group_id -- ntile(n) делит на равные части наши категории на n групп 
from
	category c;

select
	r.rental_date::date, -- сбрасывает время до 00
	count(*) cnt,
	lag(count(*), 1) over(order by r.rental_date::date) as prev_cnt, -- Подставляем значение предыдущего дня
	count(*) - lag(count(*), 1) over(order by r.rental_date::date) as diff_cnt -- выводим разницу сегоднешнего с предыдущим
from
	rental r
group by
	r.rental_date::date	-- обязательно и тут указывать
order by
	r.rental_date::date;
/*
В оконных функциях можно использовать аггрегатные функции обратно нельзя
 */

with rent_day as (
	select
		r.rental_date::date as rent_day,
		-- сбрасывает время до 00
		count(*) cnt
	from
		rental r
	group by
		r.rental_date::date
)
select
	r.rent_day,
	r.cnt,
	sum(r.cnt) over (order by r.rent_day rows between 2 preceding and current row) as three_days_cnt,
	-- суммирует сегодняшний и два предыдущих после between пишем какие строки хотим брать
	sum(r.cnt) over (order by r.rent_day rows between 3 preceding and 3 following) as week_cnt, -- 3 дня до сегодняшний и 3 дня после
	sum(r.cnt) over (order by r.rent_day rows between unbounded preceding and current row) as all_cnt
	-- Накопительный итог(Все предыдущие дни до сегодняшнего суммируются)
from
	rent_day r;

select
	f.title,
	f.rating,
	f.length,
	sum(f.length) over(partition by f.rating order by f.length range between unbounded preceding and current row) as three_days_cnt
	-- сначала берем значения до и еще суммируем и родственные т.е. значение которые равны текущему
	-- Если сортировка не задана то считаем сумму на те группы котоыре мы разделили 
	-- Если сортировка задана но размер окна нет то он считает что мы имели ввиду это(range between unbounded preceding and current row)
from
	film f;

select
	f.title,
	f.rating,
	f.length,
	first_value(f.length) over (partition by f.rating order by f.length) as frst_length -- первое значение длины каждого рейтинга и заполняем
from
	film f;

select distinct -- Разбиваем на группы и считаем количество фильмов с таким rental_duration
	f.rental_duration,
	count(*) over(partition by f.rental_duration)
from film f;

select -- индекс каждого рейтинга начинается с 1
	f.title,
	f.rental_duration,
	f.length,
	row_number() over(partition by f.rental_duration order by f.length desc, f.title asc) as rm
from
	film f;

with all_amount as ( -- Тут сумма платежей за каждый день их было несколько мы сложили
	select
		p.payment_date::date as amount_day, -- сбрасывает время до 00
		sum(p.amount) as sum_for_this_day
	from
		payment p
	group by
		p.payment_date::date
	order by 
		p.payment_date::date
)
select
	a.amount_day,
	a.sum_for_this_day,
	sum(a.sum_for_this_day) over (order by a.amount_day) as amount_all
	-- Накопительный итог(Все предыдущие дни до сегодняшнего суммируются)
from
	all_amount a;
/*
Порядок выполнения запроса
1. with (Общее табличное выражение)
2. from
3. where
4. group by
5. having
6. select
7. distinct
8. order by
9. offset/limit
 */
drop table internet_customer; -- удаление таблицы

-- создание таблицы
create table internet_customer ( -- вместо int можно написать serial он сам пронумерует каждую строчку убрали not null т.к ПК гарантирует(уникальность,не пустоты)
	internet_customer_id serial primary key, --Значения не могут быть пустыми если не указывать или написать null они могут быть пустыми
	login varchar(20) not null check(length(login) >= 6 and login <> first_name) unique, -- проверяет чтобы лоигн был больше 6 
	first_name varchar(20) not null, -- и чтобы это не было его именем и чтобы каждый логин был уникален
	last_name varchar(20) primary key, -- Этот ключ задает пользователь а id мы или в конце после unique можно написать pk и в скобках перечислить колонки pk
	rating float default(0) not null,
	birthday date null,
	registering timestamp default(now()) not null,
	deleted bool default(false) not null,
	constraint internet_customer_rating check(rating >= 0), -- проверки можно делать после всех колонок через запятую и тут мы явно задали название ошибки
	unique(login, first_name) -- уникальными будет пара имя и логин
); -- или все проверки можно в один чек через and перечислять

create table internet_order (
	internet_order_id serial primary key,
	-- в этом поле мы указали что тут могут быть только те значения из таблицы internet_customer(internet_customer_id)
	internet_customer_id int references internet_customer(internet_customer_id), 
	film varchar(50)
)

-- добавление колонок
alter table internet_customer add column confirmed bool default(false) not null;

-- delete column
alter table internet_customer drop column confirmed;

-- delete строчки
delete from internet_customer -- если ничего не указав напишем удалятся все значения
where last_name = 'Guiness';

-- редактирование записей
update internet_customer
set login = 'testlogin' -- указываем столбец который хотим заменить
where last_name = 'c'; -- если не укажем условие то поменяется у всех эта колонка

-- добавление значений
insert into internet_customer (internet_customer_id, login, first_name,	last_name, birthday)
	values (1, 'login1', 'A', 'c', '2002-02-01'),
	(2, 'login2', 'B', null, '2002-02-01'),
	(3, 'login', 'C', null, null);

select * from internet_customer;

/*
smallint
int
bigingt
char(20) хранит строку длинной 20 само значение может быть меньше просто остальное будет заполнено пробелами
varchar, varying какой длины строка такую и хранит
text большие тексты можно хранить
varchar - 4 байт ( только латтиница)
nvarchar - 8 байт (все символы юникода. другие языки)
float float4 real - 4 byte
double precision float8 - 8 byte
numeric(n, m) decimal(n, m) n(сколько всего цифр) m (сколько цифр после запятой) - n+1 byte
date - только гг.мм.дд
timestamp - + время
time - только время
interval - интервал времени
explane aanlize перед запросом покажет время выполнения запроса
 */

-- Добавление значений из одной таблицы в другую
-- если не указывать в () название колонок подразумевается что они идут в том порядке в котором создавались
insert into internet_customer (internet_customer_id, login, first_name,	last_name, birthday)
select
	row_number() over() + 3, -- т.к. актеров 200 начинаем с 3 до 203
	substring(first_name, 1, 1) || '.' || last_name, -- логин будет первая буква имени.фамилия
	a.first_name,
	a.last_name,
	null -- количество колонок на выходе должно быть столько же сколько и на входной таблице
from actor a;

select
	f.rental_rate,
	cast(f.rental_rate as varchar(10))	-- f.rental_rate::varchar(10) можно и так
	-- меняем тип данных f.rental_rate на varchar(это явное преобразование)
from
	film f;

with cte as (
	select 1 as field
	union all
	select 1.5 as field -- не явное преобразование
)
select field, pg_typeof(field) from cte -- выводит тип поля

select now()
select to_char(now(), 'yyyy-MM-dd HH-mi') -- преобразование времени	
select to_char(now(), 'yy-MON-dd HH24-mi')
select to_char(now(), 'dd/Month/yy HH24:mi:ss')

select cast('2021-01-22' as date);
select to_date('21/01/21', 'yy/MM/dd'); 
select cast('2021-01-22 12:34' as timestamp);
select to_timestamp('2021-01-22 12:34', 'yyyy-MM-dd HH24:mi');

-- Создаем view как бы отдельную таблицу
create view film_1 as
select * from film;
-- Сейчас используется не материализованное представление это значит что фактически вместо film_1 подставляется тот запрос после as
-- А мат. представление один раз выполняется и сохраняется таблица и если вызовем это облегчает процесс
-- refresh materialized name_view -- чтобы обновдить данные в этой таблицу
select * from film_1;

create view film_cnt_actor as ( -- создаем представление которое считает количество актеров которые снялись в этом фильме
select
	film_id,
	count(*) as count_actor
from
	film_actor fa
group by
	film_id
)
select
	f.title,
	f.film_id,
	fa.count_actor
from
	film f
join film_cnt_actor fa on
	f.film_id = fa.film_id;

drop view film_cnt_actor; -- удаляем представление

-- Дальше тема оптимизации запроса
create index film_length_idx on film(rental_duration); -- Создание индекса для таблицы film для колонки length индекс может быть по нескольким полям
drop index film_length_idx; -- удаление
explain analyze -- просто explain строит план запроса analyze еще и делает запрос
select *
from film
where rental_duration = 7;