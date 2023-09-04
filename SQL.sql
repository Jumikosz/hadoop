-- Criação de databases:

create database if not exists vendas comment "Database com informações de clientes, vendas e lojas";

create database if not exists netflix comment "Database com informações de filmes da Netflix";

-- Criação de tabelas:

CREATE TABLE clientes (id INT, nome STRING, ativo INT, genero STRING, city STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE;

CREATE TABLE transacoes (Id INT, loja INT, cliente INT, valor INT, datahora DATE)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE;

CREATE TABLE lojas (Id INT, ativo INT, cidade STRING, data_instalacao DATE)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE;

CREATE TABLE filme (movie_id INT, year INT, name STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

CREATE TABLE avaliacao (user_id INT, rating INT, movie_id INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Consultas:

SELECT c.id, c.nome, COUNT(*) AS total_transacoes
FROM clientes c
LEFT JOIN transacoes t ON c.id = t.cliente
GROUP BY c.id, c.nome
ORDER BY total_transacoes DESC
LIMIT 20;

SELECT l.cidade, COUNT(t.id) AS total_vendas
FROM lojas l
LEFT JOIN transacoes t ON l.id = t.loja
GROUP BY l.cidade
ORDER BY total_vendas DESC;

SELECT c.id, c.nome, SUM(t.valor) AS valor_total_compras
FROM clientes c
LEFT JOIN transacoes t ON c.id = t.cliente
GROUP BY c.id, c.nome
ORDER BY valor_total_compras DESC
LIMIT 20;

SELECT l.id, l.cidade, COUNT(DISTINCT c.id) AS clientes_ativos
FROM lojas l
LEFT JOIN transacoes t ON l.id = t.loja
LEFT JOIN clientes c ON t.cliente = c.id
WHERE c.ativo = 1
GROUP BY l.id, l.cidade
ORDER BY clientes_ativos DESC;

SELECT l.cidade, COUNT(DISTINCT c.id) AS clientes_ativos
FROM lojas l
LEFT JOIN transacoes t ON l.id = t.loja
LEFT JOIN clientes c ON t.cliente = c.id
WHERE c.ativo = 1
GROUP BY l.cidade
ORDER BY clientes_ativos DESC;


WITH VendasPorLojaPorMes AS (
    SELECT 
        l.id AS id_loja, 
        l.cidade AS cidade, 
        EXTRACT(MONTH FROM t.datahora) AS mes, 
        SUM(t.valor) AS total_vendas,
        DENSE_RANK() OVER (PARTITION BY EXTRACT(MONTH FROM t.datahora) ORDER BY SUM(t.valor) DESC) AS ranking
    FROM lojas l
    LEFT JOIN transacoes t ON l.id = t.loja
    WHERE l.id IS NOT NULL AND EXTRACT(MONTH FROM t.datahora) IS NOT NULL
    GROUP BY EXTRACT(MONTH FROM t.datahora), l.id, l.cidade
)
SELECT id_loja, cidade, mes, total_vendas
FROM VendasPorLojaPorMes
WHERE ranking <= 3
   AND mes IS NOT NULL
ORDER BY mes, ranking;


SELECT l.cidade, c.genero, COUNT(DISTINCT c.id) AS total_clientes
FROM lojas l
LEFT JOIN transacoes t ON l.id = t.loja
LEFT JOIN clientes c ON t.cliente = c.id
WHERE c.genero IS NOT NULL AND c.genero IN ('F', 'M')
GROUP BY l.cidade, c.genero;

SELECT f.name AS filme, AVG(a.rating) AS media_avaliacao
FROM filme f
LEFT JOIN avaliacao a ON f.movie_id = a.movie_id
WHERE a.rating IS NOT NULL
GROUP BY f.name
ORDER BY media_avaliacao DESC;

SELECT f.name AS filme, AVG(a.rating) AS media_avaliacao
FROM filme f
LEFT JOIN avaliacao a ON f.movie_id = a.movie_id
GROUP BY f.name
HAVING AVG(a.rating) >= 4.5
ORDER BY media_avaliacao DESC;

SELECT f.name AS filme, f.year AS ano_lancamento, MAX(a.rating) AS rating
FROM filme f
LEFT JOIN avaliacao a ON f.movie_id = a.movie_id
WHERE f.year = 2005
GROUP BY f.name, f.year
ORDER BY rating DESC;

SELECT f.name AS filme, COUNT(a.rating) AS num_avaliacoes
FROM filme f
LEFT JOIN avaliacao a ON f.movie_id = a.movie_id
GROUP BY f.name
HAVING COUNT(a.rating) > 0
ORDER BY num_avaliacoes DESC;

SELECT f.year AS ano_lancamento, AVG(a.rating) AS media_avaliacao
FROM filme f
LEFT JOIN avaliacao a ON f.movie_id = a.movie_id
WHERE a.rating IS NOT NULL
GROUP BY f.year
HAVING AVG(a.rating) IS NOT NULL
ORDER BY f.year;






