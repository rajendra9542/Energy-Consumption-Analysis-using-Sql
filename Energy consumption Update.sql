CREATE DATABASE ENERGYDATABASE;
USE ENERGYDATABASE;


-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);
select * from country;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
	energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
	 consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;



-- Data Analysis Questions
--  General & Comparative Analysis

-- What is the total emission per country for the most recent year available?
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)

GROUP BY country;

-- What are the top 5 countries by GDP in the most recent year?
SELECT country, Value AS gdp
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY gdp DESC
LIMIT 5;


-- Compare energy production and consumption by country and year.
SELECT 
    prod.country,
    prod.year,
    consum.energy_type,
    prod.production,
    consum.consumption
FROM production as prod
JOIN consumption as consum 
  ON prod.country = consum.country 
  AND prod.year = consum.year 
  AND prod.energy_type = consum.energy_type;


-- Which energy types contribute most to emissions across all countries?
select energy_type,sum(emission) from emission_3 group by energy_type order by sum(emission) desc;

--  Trend Analysis Over Time
-- How have global emissions changed year over year?
SELECT year, SUM(emission) AS global_emission
FROM emission_3 GROUP BY year ORDER BY year;

-- What is the trend in GDP for each country over the given years?
SELECT country, year, Value AS gdp
FROM gdp_3
ORDER BY country, year;


-- How has population growth affected total emissions in each country?
SELECT 
    p.countries AS country,
    p.year,
    p.Value AS population,
    SUM(e.emission) AS total_emission
FROM population p
JOIN emission_3 e ON p.countries = e.country AND p.year = e.year
GROUP BY p.countries, p.year, p.Value
ORDER BY p.countries, p.year;



-- Has energy consumption increased or decreased over the years for major economies?
SELECT country, year, SUM(consumption) AS total_consumption
FROM consumption
WHERE country IN ('United States', 'China', 'India', 'Germany', 'Japan')
GROUP BY country, year
ORDER BY country, year;




-- What is the average yearly change in emissions per capita for each country?
SELECT country, ROUND(AVG(per_capita_emission), 7) AS avg_yearly_per_capita_emission
FROM emission_3
GROUP BY country;



-- Ratio & Per Capita Analysis
-- What is the emission-to-GDP ratio for each country by year?
SELECT 
    e.country,
    e.year,
    SUM(e.emission) / NULLIF(SUM(g.Value), 0) AS emission_to_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g ON e.country = g.Country AND e.year = g.year
GROUP BY e.country, e.year;



-- What is the energy consumption per capita for each country over the last decade?
SELECT 
    c.country,
    c.year,
    c.consumption / NULLIF(p.Value, 0) AS consumption_per_capita
FROM consumption c
JOIN population p ON c.country = p.countries AND c.year = p.year
WHERE c.year BETWEEN 2014 AND 2024
ORDER BY c.country, c.year;



-- How does energy production per capita vary across countries?
SELECT 
    pr.country,
    pr.year,
    pr.production / NULLIF(p.Value, 0) AS production_per_capita
FROM production pr
JOIN population p ON pr.country = p.countries AND pr.year = p.year
ORDER BY pr.country, pr.year;



-- Which countries have the highest energy consumption relative to GDP?
SELECT 
    c.country,
    c.year,
    round(SUM(c.consumption) / NULLIF(SUM(g.Value), 0),4) AS consumption_to_gdp_ratio
FROM consumption c
JOIN gdp_3 g ON c.country = g.Country AND c.year = g.year
GROUP BY c.country, c.year
ORDER BY consumption_to_gdp_ratio DESC;



-- What is the correlation between GDP growth and energy production growth?
SELECT 
    g.Country,
    g.year,
    g.Value AS GDP,
    p.production
FROM gdp_3 g
JOIN production p ON g.Country = p.country AND g.year = p.year
ORDER BY g.Country, g.year;



--  Global Comparisons

-- What are the top 10 countries by population and how do their emissions compare?
SELECT 
    p.countries AS country,
    p.year,
    p.Value AS population,
    SUM(e.emission) AS total_emission
FROM population p
JOIN emission_3 e ON p.countries = e.country AND p.year = e.year
GROUP BY p.countries, p.year, p.Value
ORDER BY population DESC
LIMIT 10;



-- Which countries have improved (reduced) their per capita emissions the most over the last decade?

SELECT 
    e1.country,
    e1.per_capita_emission AS emission_2022,
    e2.per_capita_emission AS emission_2023,
    (e1.per_capita_emission - e2.per_capita_emission) AS reduction
FROM emission_3 e1
JOIN emission_3 e2 ON e1.country = e2.country
WHERE e1.year = 2022 or e2.year = 2023
  AND (e1.per_capita_emission - e2.per_capita_emission) > 0
ORDER BY reduction DESC
LIMIT 10;





-- What is the global share (%) of emissions by country?
SELECT 
    country,
    SUM(emission) * 100.0 / (SELECT SUM(emission) FROM emission_3) AS emission_share_percent
FROM emission_3
GROUP BY country
ORDER BY emission_share_percent DESC;



-- What is the global average GDP, emission, and population by year?
SELECT 
    g.year,
    AVG(g.Value) AS avg_gdp,
    (SELECT AVG(emission) FROM emission_3 e WHERE e.year = g.year) AS avg_emission,
    (SELECT round(AVG(Value),3) FROM population p WHERE p.year = g.year) AS avg_population
FROM gdp_3 g
GROUP BY g.year
ORDER BY g.year;




