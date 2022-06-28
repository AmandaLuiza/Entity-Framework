--
-- Table structure for table actor
--

CREATE TABLE actor (
  actor_id int NOT NULL IDENTITY ,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update DATETIME NOT NULL,
  CONSTRAINT pk_actor PRIMARY KEY NONCLUSTERED (actor_id)
  )
GO
 ALTER TABLE actor ADD CONSTRAINT [df_actor_last_update] DEFAULT (getdate()) FOR last_update
GO
 CREATE  INDEX idx_actor_last_name ON actor(last_name) 
GO

--
-- Table structure for table language
--

CREATE TABLE language (
  language_id TINYINT NOT NULL IDENTITY,
  name CHAR(20) NOT NULL,
  last_update DATETIME NOT NULL,
  CONSTRAINT pk_language PRIMARY KEY NONCLUSTERED (language_id)
)
GO
 ALTER TABLE language ADD CONSTRAINT [df_language_last_update] DEFAULT (getdate()) FOR last_update
GO

--
-- Table structure for table category
--

CREATE TABLE category (
  category_id TINYINT NOT NULL IDENTITY,
  name VARCHAR(25) NOT NULL,
  last_update DATETIME NOT NULL,
  CONSTRAINT pk_category PRIMARY KEY NONCLUSTERED (category_id)
)
GO
 ALTER TABLE category ADD CONSTRAINT [df_category_last_update] DEFAULT (getdate()) FOR last_update
GO

--
-- Table structure for table customer
--

CREATE TABLE customer (
  customer_id tinyint NOT NULL IDENTITY ,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  active bit NOT NULL DEFAULT 'Y',
  create_date DATETIME NOT NULL,
  last_update DATETIME NOT NULL,
  CONSTRAINT pk_customer PRIMARY KEY NONCLUSTERED (customer_id)
)
GO
 ALTER TABLE customer ADD CONSTRAINT [df_customer_last_update] DEFAULT (getdate()) FOR last_update
GO
 ALTER TABLE customer ADD CONSTRAINT [df_customer_create_date] DEFAULT (getdate()) FOR create_date
GO
 CREATE  INDEX idx_last_name ON customer(last_name) 
GO

--
-- Table structure for table film
--

CREATE TABLE film (
  film_id int NOT NULL IDENTITY ,
  title VARCHAR(255) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year VARCHAR(4) NULL,
  language_id TINYINT NOT NULL,
  original_language_id TINYINT DEFAULT NULL,
  length SMALLINT DEFAULT NULL,
  rating VARCHAR(10) DEFAULT 'G',
  last_update DATETIME NOT NULL,
  CONSTRAINT pk_film PRIMARY KEY NONCLUSTERED (film_id),
  CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES language (language_id) ,
  CONSTRAINT fk_film_language_original FOREIGN KEY (original_language_id) REFERENCES language (language_id) 
)
GO

ALTER TABLE film ADD CONSTRAINT check_rating CHECK(rating in ('G','PG','PG-13','R','NC-17'))
GO
ALTER TABLE film ADD CONSTRAINT [df_film_last_update] DEFAULT (getdate()) FOR last_update
GO
CREATE  INDEX idx_fk_language_id ON film(language_id) 
GO
CREATE  INDEX idx_fk_original_language_id ON film(original_language_id) 
GO


--
-- Table structure for table film_actor
--

CREATE TABLE film_actor (
  actor_id INT NOT NULL,
  film_id  INT NOT NULL,
  last_update DATETIME NOT NULL,
  CONSTRAINT pk_film_actor PRIMARY KEY NONCLUSTERED (actor_id,film_id),
  CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO
 ALTER TABLE film_actor ADD CONSTRAINT [df_film_actor_last_update] DEFAULT (getdate()) FOR last_update
GO
 CREATE  INDEX idx_fk_film_actor_film ON film_actor(film_id) 
GO
 CREATE  INDEX idx_fk_film_actor_actor ON film_actor(actor_id) 
GO

--
-- Table structure for table film_category
--

CREATE TABLE film_category (
  film_id INT NOT NULL,
  category_id TINYINT  NOT NULL,
  last_update DATETIME NOT NULL,
  CONSTRAINT pk_film_category PRIMARY KEY NONCLUSTERED (film_id, category_id),
  CONSTRAINT fk_film_category_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO
 ALTER TABLE film_category ADD CONSTRAINT [DF_film_category_last_update] DEFAULT (getdate()) FOR last_update
GO
 CREATE  INDEX idx_fk_film_category_film ON film_category(film_id) 
GO
 CREATE  INDEX idx_fk_film_category_category ON film_category(category_id) 
GO

--
-- Table structure for table staff
--

CREATE TABLE staff (
  staff_id TINYINT NOT NULL IDENTITY,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  active BIT NOT NULL DEFAULT 1,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(40) DEFAULT NULL,
  last_update DATETIME NOT NULL,
  CONSTRAINT pk_staff PRIMARY KEY NONCLUSTERED (staff_id)
)
GO
 ALTER TABLE staff ADD CONSTRAINT [df_staff_last_update] DEFAULT (getdate()) FOR last_update
GO


--
-- Structure for view top5_most_starred_actors
--
CREATE VIEW top5_most_starred_actors
AS
	select top 5 a.actor_id, a.first_name, a.last_name, count(fa.film_id) as total
	from actor a
		inner join film_actor fa on fa.actor_id = a.actor_id
	group by a.actor_id, a.first_name, a.last_name
	order by total desc
GO

--
-- Structure for sp total_actors_from_given_category
--
CREATE PROCEDURE total_actors_from_given_category
	@category_name varchar(25),
	@total_actors int OUT
AS
BEGIN
	SET @total_actors = (SELECT count(distinct a.actor_id)
	from dbo.actor a
	  inner join film_actor fa on fa.actor_id = a.actor_id
	  inner join film f on f.film_id = fa.film_id
	  inner join film_category fc on fc.film_id = f.film_id
	  inner join category c on c.category_id = fc.category_id
	where c.name = @category_name);
END
GO