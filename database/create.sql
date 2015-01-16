CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	login varchar(100) NOT NULL,
	pass varchar(100) NOT NULL,
	salt varchar(10) NOT NULL);