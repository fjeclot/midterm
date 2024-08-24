create database if not exists contacts_friendship;

use contacts_friendship;

create table People (
	person_id int auto_increment primary key,
	name varchar(50),
	last_name varchar(50),
	email varchar(100)
);

create table Phones (
	phone_id int auto_increment primary key,
	number varchar(15),
	person_id int,
	foreign key (person_id) references people(person_id)
);

create table Address (
	address_id int auto_increment primary key,
	street varchar(100),
	city varchar(50),
	country varchar(50),
	person_id int,
	foreign key(person_id) references People(person_id)
);

create table Hobbies (
	hobby_id int auto_increment primary key,
	description varchar(100)
);

create table People_Hobbies (
	hobby_id int,
	person_id int,
	primary key (person_id, hobby_id),
	foreign key (person_id) references People(person_id),
	foreign key (hobby_id) references Hobbies(hobby_id)
);

alter table People add column birth_date date;

insert into People (name, last_name, email, birth_date) values
	('Juan', 'Perez', 'juan.perez@example.com', '1990-01-01'),
	('Maria', 'Lopez', 'maria.lopez@example.com', '1992-02-02'),
	('Carlos', 'Garcia', 'carlos.garcia@example.com', '1991-03-03'),
	('Ana', 'Martinez', 'ana.martinez@example.com', '1989-04-04'),
	('Luis', 'Hernandez', 'luis.hernandez@example.com', '1993-05-05'),
	('Elena', 'Gomez', 'elena.gomez@example.com', '1994-06-06'),
	('Pedro', 'Diaz', 'pedro.diaz@example.com', '1995-07-07'),
	('Laura', 'Fernandez', 'laura.fernandez@example.com', '1996-08-08'),
	('Jose', 'Sanchez', 'jose.sanchez@example.com', '1997-09-09'),
	('Lucia', 'Ramirez', 'lucia.ramirez@example.com', '1998-10-10');

insert into Phones (number, person_id) values
	('623456789', 1),
	('634567890', 2),
	('645678901', 3),
	('656789012', 4),
	('667890123', 5),
	('678901234', 6),
	('689012345', 7),
	('690123456', 8),
	('601234567', 9),
	('612345678', 10);

insert into Address (street, city, country, person_id) values
	('Calle Falsa 123', 'Madrid', 'España', 1),
	('Avenida Siempre Viva 742', 'Barcelona', 'España', 2),
	('Calle Luna 45', 'Valencia', 'España', 3),
	('Calle Sol 89', 'Sevilla', 'España', 4),
	('Calle Estrella 67', 'Bilbao', 'España', 5),
	('Avenida Estrella 98', 'Zaragoza', 'España', 6),
	('Calle Cometa 12', 'Malaga', 'España', 7),
	('Avenida Meteoro 34', 'Murcia', 'España', 8),
	('Calle Rayo 56', 'Palma', 'España', 9),
	('Avenida Relampago 78', 'Las Palmas', 'España', 10);

insert into Hobbies (description) values
	('Futbol'),
	('Lectura'),
	('Cine'),
	('Musica'),
	('Viajar'),
	('Cocina'),
	('Deportes'),
	('Baile'),
	('Pintura'),
	('Fotografia');

insert into People_Hobbies (person_id, hobby_id) values
	(1, 1),
	(1, 2),
	(2, 3),
	(2, 4),
	(3, 5),
	(3, 6),
	(4, 7),
	(4, 8),
	(5, 9),
	(5, 10),
	(6, 1),
	(6, 2),
	(7, 3),
	(7, 4),
	(8, 5),
	(8, 6),
	(9, 7),
	(9, 8),
	(10, 9),
	(10, 10);	

-- BASIC SEARCHES 

select * from People;

select * from People where person_id = 1;

select * from People where person_id % 2 = 0;

select * from People order by last_name;

select * from People limit 5;

select * from Phones where number like '6%' and number not like '%3%';

select * from People where birth_date between '1900-01-01' and '1995-01-01';

select * from People where name like 'J%';

select * from People where birth_date is null;

select count(*) from People where last_name = 'Garcia';

-- ADVANCED SEARCHES

-- People with more than one phone number

select person_id, name, last_name
from people 
where person_id in (
	select person_id
	from phones 
	group by person_id
	having count(*) > 1
);

-- Query between several tables: people and their phones

select p.name, p.last_name, ph.number
from People p
join Phones ph on p.person_id = ph.person_id;

-- Query with aggregations: Count how many people there are

select count(*) as total_people
from People;

-- Query with aggregations: Average birth year

select avg(year(birth_date)) as average_birth_year
from People;

-- Query with aggregations: Most recent and oldest year of birth

select min(birth_date) as oldest_year_birth, max(birth_date) as recent_year_birth
from People;

-- Group results and apply aggregation functions. Number of telephones per person

select p.name, p.last_name, count(ph.phone_id) as number_telephones
from People p
join Phones ph on p.person_id = ph.person_id 
group by p.person_id, p.name, p.last_name;

-- Filter group results. People with more than one phone

select p.name, p.last_name, count(ph.phone_id) as number_telephones
from People p
join Phones ph on p.person_id = ph.person_id
group by p.person_id, p.name, p.last_name 
having count(ph.phone_id) > 1;

-- Query with JOINs combinations and subqueries: People and recent hobbies

select p.name, p.last_name, h.description
from People p
join People_Hobbies ph on p.person_id = ph.person_id 
join Hobbies h on ph.hobby_id = h.hobby_id 
where ph.hobby_id = (
	select max(ph2.hobby_id)
	from people_hobbies ph2
	where ph2.person_id = p.person_id 
);

-- Query with correlated subqueries: People without hobbies

select p.name, p.last_name
from People p
where not exists (
	select 1
	from people_hobbies ph
	where ph.person_id = p.person_id
);

-- Query with subquery: People who have hobbies that others also have

select distinct p.name, p.last_name
from People p
where p.person_id in (
	select ph1.person_id
	from people_hobbies ph1
	join people_hobbies ph2 on ph1.hobby_id = ph2.hobby_id
	where ph1.person_id != ph2.person_id
);

-- TRIGGER

alter table People add column modification_date datetime default current_timestamp;

-- Trigger to update the modification date of a record in the People table.
-- This trigger is activated before a record in the People table is update and update the modification_date column with the current date and time.

delimiter //
create trigger before_person_update
before update on People
for each row 
begin
	set new.modification_date = now();
end//
delimiter;

-- Trigger to prevent the insertion of duplicate phone numbers.
-- This trigger is activated before a record is inserted into the Phones table and checks if the number already exists. If the number already exists, it generates and error to prevent the insertion.

delimiter //
create trigger before_phone_insert
before insert on Phones
for each row 
begin 
	declare existing_number int;

	select count(*) into existing_number
	from phones 
	where number = new.number;

	if existing_number > 0 then
		signal sqlstate '45000'
		set message_text = 'The phone number already exists'
	end if;
end//
delimiter;


-- TRANSACTION 
-- Suppose we are going to insert a new person, his address and some hobbies for that person.

alter table people_hobbies
add constraint unique_person_hobby unique (person_id, hobby_id);

start transaction;

	insert into People (name, last_name, email, birth_date) values
		('Javier', 'Campos', 'jcamposd90@gmail.com', '1990-09-12');

	set @person_id = last_insert_id();

	insert into Address (person_id, street, city, country)
	values (@person_id, 'Calle Vinyals 12', 'Barcelona', 'España');

	insert ignore into People_Hobbies (person_id, hobby_id)
	values (@person_id, 1),
		   (@person_id, 2);

commit;

-- Handle errors and roll back the transaction in case of failure

declare continue handler for sqlexception
begin
	rollback;
	signal sqlstate '45000' set message_text = 'Error in the transaction, all changes have been reverted';
end;

-- FUNCTIONS
-- This function calculates the age of a person from their date of birth.

delimiter //

create function age_calculate(birth_date date)
returns int
deterministic
begin
	declare age int;
	set age = timestampdiff(year, birth_date, curdate());
	return age;
end //

delimiter;

select age_calculate('1992-07-15') as age;

-- This function concatenates the first and last name of a person.

delimiter //

create function full_name(name varchar(50), last_name varchar(50))
returns varchar(101)
deterministic
begin
	return concat(name, '', last_name);
end //

delimiter;

select full_name('Carlos', 'Hernandez') as full_name;

-- This function counts how many hobbies a specific person has.

delimiter //

create function count_hobbies_person(person_id int)
returns int
deterministic
begin
	declare count int;
	select count(*) into count
	from people_hobbies 
	where person_id = person_id;
	return count;
end //

delimiter;

select count_hobbies_person(1) as number_hobbies;





