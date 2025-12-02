-- CREATING TABLE

drop table netflix;
CREATE TABLE netflix(
					show_id	varchar(15),
					type varchar(25),
					title varchar(250),
					director varchar(600),
					casting varchar(1500),
					country	varchar(650),
					date_added date,
					release_year int,
					rating	varchar(20),
					duration varchar(25),
					listed_in varchar(500),
					description varchar(2500)
);

select * from netflix;

