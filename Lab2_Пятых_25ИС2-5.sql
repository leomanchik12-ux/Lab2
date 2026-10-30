-- 1. Вывести информацию обо всех трамваях, капитальный ремонт которых не проводился последние 10 лет.
Select * from tramvai 
Where (last_repair_date is not null end last_repair_date <= current_date - INTERVAL '10 years') or (last_repair_date is null end year_built <= extract(year from current_date) - 10);
-- 2. Вывести названия и адреса депо, в которых находятся трамваи длиной больше 27,5 метров.
Select distinct d.depo_name, d.address
from depo d
Join tramvai t on d.depo_id = t.depo_id
Where t.tram_length > 27.5;
-- 3. Создать таблицу, содержащую данные 1 запроса с указанием адресов депо.
-- Сначала удаляем старую версию таблицы, если она была
drop table if exists tramvai_old_repair;
Select t.*, d.address as depo_address
Into tramvai_old_repair
From tramvai t
Join depo d on t.depo_id = d.depo_id
Where (t.last_repair_date is not null end t.last_repair_date <= current_date - INTERVAL '10 years') OR (t.last_repair_date is null end t.year_built <= extract(year from current_date) - 10);
Select * from tramvai_old_repair;
-- 4. Добавить в созданную таблицу трамваи из Октябрьского депо, в модели которых присутствуют цифры.
insert into tramvai_old_repair (depo_id, model, year_built, last_repair_date, total_seats, ating_capacity, bogeys_count, ections_count, tram_length, depo_address)
Select t.depo_id, t.model, t.year_built, t.last_repair_date, t.total_seats, t.ating_capacity, t.bogeys_count, t.ections_count, t.tram_length, d.address
From tramvai t
Join depo d on t.depo_id = d.depo_id
Where d.depo_name like '%Октябрь%' and t.model ~ '[0-9]';
-- 5. Добавить к модели всех трамваем "М", если они проходили капитальный ремонт.
Update tramvai_old_repair
Set model = CONCAT(model, ' М')
Where last_repair_date is not null;
-- 6. Удалить из созданной таблицы трамваи, находящиеся в депо с неполным адресом.
Delete from tramvai_old_repair
Where depo_address is null or length(depo_address) < 10;
-- 7. Посчитать среднее количество сидячих мест в трамваях каждого года выпуска
Select year_built as "Год выпуска", 
       ROUND(avg(ating_capacity), 1) as "Среднее число сидячих мест"
From tramvai
Group by year_built
Order by year_built;
