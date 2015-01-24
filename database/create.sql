CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	login varchar(100) NOT NULL,
	pass varchar(100) NOT NULL,
	salt varchar(30) NOT NULL);
CREATE UNIQUE INDEX index_login ON users (login);