SELECT * FROM rides_data LIMIT 1000; --All datas for the last 12 months, I imported all csv files to the rides-data table


SELECT * FROM rides_data --I'm checking the dates
ORDER BY ended_at ASC
LIMIT 1000;

SELECT ride_id, ended_at FROM rides_data --checking data
ORDER BY ended_at ASC;
LIMIT 1000;

SELECT ride_id, ended_at FROM rides_data --checking data, 5.9 million records
ORDER BY ended_at ASC;

PRAGMA table_info(rides_data); --checking table info, i think i need to change type of dates

--Creating new table
CREATE TABLE rides (
ride_id TEXT,
rideable_type TEXT,
started_at TEXT,
ended_at TEXT,
start_station_name TEXT,
start_station_id TEXT,
end_station_name TEXT,
end_station_id TEXT,
start_lat REAL, -- Decimal number for latitude and longitude (REAL)
start_lng REAL,
end_lat REAL,
end_lng REAL,
member_casual TEXT
);


PRAGMA table_info(rides); --checking new table

--Copying all datas to new table
INSERT INTO rides C
ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
start_station_id,
end_station_name,
end_station_id,
start_lat,
start_lng,
end_lat,
end_lng,
member_casual
)
SELECT
ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
start_station_id,
end_station_name,
end_station_id,
start_lat,
start_lng,
end_lat,
end_lng,
member_casual
FROM rides_data;


SELECT ride_id FROM rides; --checking new table, 5.9 million records

DROP TABLE rides_data; --Deleting the old table

SELECT ride_id, COUNT(*) AS count --Checking duplicates records 211 records
FROM rides
GROUP BY ride_id
HAVING COUNT(*) > 1;


DELETE FROM rides --Cleaning duplicates values
WHERE rowid NOT IN (
SELECT MIN(rowid)
	FROM rides
	GROUP BY ride_id
);

SELECT * --Checking empty values and there is no empty values
FROM rides
WHERE started_at = "" OR ended_at = "" OR ride_id = "";

SELECT * FROM rides --Checking date lenght
WHERE LENGTH(started_at) > 19
LIMIT 100;

UPDATE rides --Updating date format
SET started_at = strftime('%Y-%m-%d %H:%M:%S', started_at),
	ended_at = strftime '%Y-%m-%d %H:%M:%S', ended_at);
	
ALTER TABLE rides ADD COLUMN ride_length REAL; --Adding new column

UPDATE rides --Calculating the values in the new column in minutes
SET ride_length = (julianday(ended_at) - julianday(started_at)) * 24 * 60;

SELECT --Checking max values of ride lenght (1559 minutes)
	ride_id,
	started_at,
	ended_at,
	MAX(ride_length) AS max_ride_length
FROM rides;

SELECT --Checking min values of ride length (-2748 minutes)
	ride_id,
	started_at,
	ended_at,
	MIN(ride_length) AS min_ride_length
FROM rides;

DELETE FROM rides --Deleting minus or zero values (778 rows affected)
WHERE started_at > ended_at OR started_at = ended_at;

CREATE VIEW avg_ride_length_by_member AS --Creating a view for average ride lenght by member type 
SELECT member_casual, AVG(ride_length) AS average_ride_length
FROM rides
GROUP BY member_casual;

SELECT * FROM avg_ride_length_by_member; --Checking the view, casual - 25.1 minutes, member 12.8 min


UPDATE rides --Creating new column as day of week, 0-Sunday, 1-Monday....
SET day_of_week = CAST(strftime('%w', started_at) AS INTEGER);

SELECT ride_id, started_at, ended_at, ride_length, day_of_week FROM rides LIMIT 1000; --Checking the new table


CREATE VIEW avg_ride_length_by_day_and_member AS --Creating a view for average ride length by day and member
SELECT day_of_week, member_casual, AVG(ride_length) AS average_ride_length
FROM rides
GROUP BY day_of_week, member_casual
ORDER BY day_of_week, member_casual;

SELECT * FROM avg_ride_length_by_day_and_member LIMIT 1000; --Checking the new view, 7 days by casual, 7 days by member


CREATE VIEW ride_count_by_day_and_member AS --Creating a view for ride count by day and member
SELECT day_of_week, member_casual, COUNT(ride_id) AS ride_count
FROM rides
GROUP BY day_of_week, member_casual
ORDER BY day_of_week, member_casual;

SELECT * FROM ride_count_by_day_and_member LIMIT 1000; --Checking the view


