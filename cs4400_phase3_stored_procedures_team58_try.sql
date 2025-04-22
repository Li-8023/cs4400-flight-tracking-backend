-- CS4400: Introduction to Database Systems: Monday, March 3, 2025
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like the model and the engine.  
Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS add_airplane;
DELIMITER //

CREATE PROCEDURE add_airplane (
    IN ip_airlineID VARCHAR(50),
    IN ip_tail_num VARCHAR(50),
    IN ip_seat_capacity INT,
    IN ip_speed INT,
    IN ip_locationID VARCHAR(50),
    IN ip_plane_type VARCHAR(100),
    IN ip_maintenanced BOOLEAN,
    IN ip_model VARCHAR(50),
    IN ip_neo BOOLEAN
)
sp_main: BEGIN

    IF NOT EXISTS (  
        SELECT 1 FROM airline  
        WHERE airlineID = ip_airlineID  
    ) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Airline does not exist';
    END IF;

    IF EXISTS (  
        SELECT 1 FROM airplane  
        WHERE airlineID = ip_airlineID  
          AND tail_num = ip_tail_num  
    ) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The tail number already exists for this airline';
    END IF;

    IF (ip_seat_capacity <= 0 OR ip_speed <= 0) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat capacity and speed must be greater than 0';
    END IF;

    IF ip_plane_type IS NOT NULL AND ip_plane_type NOT IN ('Boeing', 'Airbus', 'Generic') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid airplane type';
    END IF;

    IF ip_locationID IS NOT NULL THEN
        IF EXISTS (
            SELECT 1 FROM location WHERE locationID = ip_locationID
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Location ID already exists';
        ELSE
            INSERT INTO location(locationID) VALUES (ip_locationID);
        END IF;
    END IF;

    INSERT INTO airplane (
        airlineID, tail_num, seat_capacity, speed,
        locationID, plane_type, maintenanced, model,neo
    ) VALUES (
        ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed,
        ip_locationID, ip_plane_type, ip_maintenanced, NULLIF(ip_model, ''),  ip_neo
    );

END;
//
DELIMITER ;


-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin
	  
    IF EXISTS (  
        SELECT 1 FROM airport  
        WHERE airportID = ip_airportID  
    ) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Airport ID already exists';  
        -- LEAVE sp_main;
    END IF;  

  IF ip_locationID IS NOT NULL THEN    
    IF EXISTS (  
        SELECT 1 FROM location  
        WHERE locationID = ip_locationID  
    ) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Location ID already exists';  
	ELSE
		INSERT INTO location(locationID) VALUES(ip_locationID);
    END IF;  
END IF; 

    
    
    INSERT INTO airport(  
        airportID, airport_name, city, state, country, locationID  
    ) VALUES(  
        ip_airportID,  NULLIF(ip_airport_name, ''),ip_city, ip_state, ip_country, ip_locationID  
    );  
    
END;  
//  
DELIMITER ;  



-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin
	
    IF EXISTS (  
        SELECT 1 FROM person  
        WHERE personID = ip_personID  
    ) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Person ID already exists';  
        -- LEAVE sp_main;
    END IF;  

    
    IF NOT EXISTS (  
        SELECT 1 FROM location  
        WHERE locationID = ip_locationID  
    ) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Location ID does not exist';  
        -- LEAVE sp_main;
    END IF;  

 
    IF (ip_first_name IS NULL OR ip_first_name = '') THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'First name is required';  
        -- LEAVE sp_main;
    END IF;  

    
    IF (ip_taxID IS NOT NULL AND ip_taxID <> '') THEN  
     
        IF ip_experience IS NULL THEN  
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Experience level is required for pilots';  
            -- LEAVE sp_main;
        END IF;  
        
        IF ip_miles IS NOT NULL OR ip_funds IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pilot cannot have miles or funds';
        END IF;
     
        INSERT INTO person(personID, first_name, last_name, locationID)  
        VALUES(ip_personID, ip_first_name, NULLIF(ip_last_name, ''), ip_locationID);  

   
        INSERT INTO pilot(personID, taxID, experience, commanding_flight)  
        VALUES(ip_personID, ip_taxID, ip_experience, NULL);  

    ELSE  
        
        IF (ip_miles IS NULL OR ip_funds IS NULL) THEN  
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Miles and funds are required for passengers'; 
            -- LEAVE sp_main;
        END IF;  
        
        IF ip_taxID IS NOT NULL AND ip_taxID <> '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Passenger cannot have taxID';
        END IF;

        INSERT INTO person(personID, first_name, last_name, locationID)  
        VALUES(ip_personID, ip_first_name, NULLIF(ip_last_name, ''), ip_locationID);  

        INSERT INTO passenger(personID, miles, funds)  
        VALUES(ip_personID, ip_miles, ip_funds);  
    END IF;  

end //
delimiter ;

-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it aready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
    IF NOT EXISTS (  
        SELECT 1 FROM pilot  
        WHERE personID = ip_personID  
    ) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pilot does not exist';  
        -- LEAVE sp_main;
    END IF;  
 
    IF EXISTS (  
        SELECT 1 FROM pilot_licenses  
        WHERE personID = ip_personID  
          AND license = ip_license  
    ) THEN  
        DELETE FROM pilot_licenses  
        WHERE personID = ip_personID  
          AND license = ip_license;  
    ELSE  
        INSERT INTO pilot_licenses(personID, license)  
        VALUES(ip_personID, ip_license);  
    END IF;  

end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin
	 DECLARE route_len INT DEFAULT 0;
    IF NOT EXISTS (  
        SELECT 1 FROM route  
        WHERE routeID = ip_routeID  
    ) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Route does not exist';  
        -- LEAVE sp_main;
    END IF;  

    SELECT COUNT(*) INTO route_len  
    FROM route_path  
    WHERE routeID = ip_routeID;  

    IF route_len = 0 THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Route has no segments';
    END IF;  

    IF ip_progress >= route_len THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Progress cannot be at the end of the route';
    END IF;  

    IF (ip_support_airline IS NOT NULL AND ip_support_tail IS NOT NULL  
        AND ip_support_airline <> '' AND ip_support_tail <> '') THEN  

        IF NOT EXISTS (  
            SELECT 1 FROM airplane  
            WHERE airlineID = ip_support_airline  
              AND tail_num  = ip_support_tail  
        ) THEN  
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Specified airplane does not exist';
        END IF;  

        IF EXISTS (  
            SELECT 1 FROM flight  
            WHERE support_airline = ip_support_airline  
              AND support_tail    = ip_support_tail  
              AND airplane_status <> 'ended'  
        ) THEN  
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Airplane is currently in use by another flight';
        END IF;  
    END IF;  


    IF EXISTS (  
        SELECT 1 FROM flight  
        WHERE flightID = ip_flightID  
    ) THEN  
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight ID already exists';
    END IF;  

    INSERT INTO flight(  
        flightID, routeID, support_airline, support_tail,  
        progress, airplane_status, next_time, cost  
    ) VALUES(  
        ip_flightID, ip_routeID, ip_support_airline, ip_support_tail,  
        ip_progress, 'on_ground', ip_next_time, ip_cost  
    );  

end //
delimiter ;

-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin
	declare flight_miles INT;
    declare seq INT;
    declare leg_no varchar(64);
    declare flight_route varchar(64);
    declare airline_id varchar(64);
    declare flight_tailnum varchar(6);
    declare flight_loc varchar(64);
    
	if not exists (select flightID from flight where flightID = ip_flightID) THEN
        leave sp_main;
		end if;
		if (select airplane_status from flight where flightID = ip_flightID) != 'in_flight' then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight is on ground';
		END IF;
            
		update pilot set experience = experience + 1 where commanding_flight = ip_flightID;
		set seq = (select progress from flight where flightID = ip_flightID);
		set flight_route = (select routeID from flight where flightID = ip_flightID);
		set leg_no = (select legID from route_path where routeID = flight_route and sequence = seq);
		set flight_miles = (select distance from leg where legID = leg_no);
		set airline_id = (select support_airline from flight where flightID = ip_flightID);
		set flight_tailnum = (select support_tail from flight where flightID = ip_flightID);
		set flight_loc = (select locationID from airplane where airlineID = airline_id and tail_num = flight_tailnum);
		
        update passenger p
		join person per on p.personID = per.personID
		join airplane a on per.locationID = a.locationID
		set p.miles = p.miles + flight_miles
		where a.airlineID = airline_id and a.tail_num = flight_tailnum;
		update flight set airplane_status = 'on_ground' where flightID = ip_flightID;
		update flight set next_time = addtime(next_time, '01:00:00') where flightID = ip_flightID;
            
	-- Ensure that the flight exists
    -- Ensure that the flight is in the air
    
    -- Increment the pilot's experience by 1
    -- Increment the frequent flyer miles of all passengers on the plane
    -- Update the status of the flight and increment the next time to 1 hour later
		-- Hint: use addtime()

end //
delimiter ;


-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that Airbus and general planes have at least one pilot
assigned, while Boeing must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS flight_takeoff;
DELIMITER //

CREATE PROCEDURE flight_takeoff (
  IN ip_flightID VARCHAR(50)
)
sp_main: BEGIN
  DECLARE seq INT;
  DECLARE numlegs INT;
  DECLARE airplane_type VARCHAR(64);
  DECLARE airline_id VARCHAR(64);
  DECLARE flight_tailnum VARCHAR(6);
  DECLARE num_pilots INT;
  DECLARE flight_time FLOAT;
  DECLARE flight_leg VARCHAR(64);
  DECLARE flight_miles INT;

  -- 航班必须存在
  IF NOT EXISTS (SELECT 1 FROM flight WHERE flightID = ip_flightID) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight ID does not exist';
  END IF;

  -- 必须在地面才能起飞
  IF (SELECT airplane_status FROM flight WHERE flightID = ip_flightID) = 'in_flight' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight is already in the air';
  END IF;

  -- 获取当前 progress 和航段总数
  SET seq = (SELECT progress FROM flight WHERE flightID = ip_flightID);
  SET numlegs = (
    SELECT COUNT(*) FROM route_path
    WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID)
  );

  IF seq = 0 THEN
    SET seq = seq + 1;
  END IF;

  -- 检查是否超出航段
  IF seq >= numlegs THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No remaining legs to fly';
  END IF;

  -- 获取飞机类型、所属 airline 和 tail number
  SET airline_id = (SELECT support_airline FROM flight WHERE flightID = ip_flightID);
  SET flight_tailnum = (SELECT support_tail FROM flight WHERE flightID = ip_flightID);
  SET airplane_type = (
    SELECT plane_type FROM airplane
    WHERE airlineID = airline_id AND tail_num = flight_tailnum
  );

  -- 计算该航班当前的 pilot 数量
  SET num_pilots = (SELECT COUNT(*) FROM pilot WHERE commanding_flight = ip_flightID);

  -- 检查 pilot 是否足够
  IF (airplane_type = 'Boeing' AND num_pilots < 2) OR
     ((airplane_type = 'Airbus' OR airplane_type = 'Generic') AND num_pilots < 1) THEN
    -- 不足 pilot，延迟 30 分钟
    UPDATE flight
    SET next_time = ADDTIME(next_time, '00:30:00')
    WHERE flightID = ip_flightID;
    LEAVE sp_main;
  END IF;

  -- 更新 progress、状态
  UPDATE flight SET progress = progress + 1 WHERE flightID = ip_flightID;
  UPDATE flight SET airplane_status = 'in_flight' WHERE flightID = ip_flightID;

  -- 获取当前 leg 和距离
  SET flight_leg = (
    SELECT legID FROM route_path
    WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID)
      AND sequence = seq
  );

  SET flight_miles = (SELECT distance FROM leg WHERE legID = flight_leg);

  -- 获取飞机速度，计算时间（小时），换算成秒
  SET flight_time = flight_miles / (
    SELECT speed FROM airplane
    WHERE airlineID = airline_id AND tail_num = flight_tailnum
  );

  -- 更新 next_time = 当前 + 飞行时间（小时 * 3600 秒）
  UPDATE flight
  SET next_time = ADDTIME(next_time, SEC_TO_TIME(flight_time * 3600))
  WHERE flightID = ip_flightID;

END;
//
DELIMITER ;


-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS passengers_board;
DELIMITER //

CREATE PROCEDURE passengers_board (
  IN ip_flightID VARCHAR(50)
)
sp_main: BEGIN
  DECLARE next_dest VARCHAR(64);
  DECLARE flight_leg VARCHAR(64);
  DECLARE num_passengers INT;
  DECLARE seq INT;
  DECLARE numlegs INT;
  DECLARE curr_loc VARCHAR(50);
  DECLARE ap VARCHAR(64);
  DECLARE tn VARCHAR(6);

  -- 检查航班是否存在
  IF NOT EXISTS (SELECT 1 FROM flight WHERE flightID = ip_flightID) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight ID does not exist';
  END IF;

  -- 检查航班是否在地面
  IF (SELECT airplane_status FROM flight WHERE flightID = ip_flightID) = 'in_flight' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight is already in the air';
  END IF;

  -- 获取航段位置
  SET seq = (SELECT progress FROM flight WHERE flightID = ip_flightID) + 1;

  SET numlegs = (
    SELECT COUNT(*) FROM route_path
    WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID)
  );

  IF seq >= numlegs THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight has no remaining legs';
  END IF;

  -- 获取飞机信息
  SET ap = (SELECT support_airline FROM flight WHERE flightID = ip_flightID);
  SET tn = (SELECT support_tail FROM flight WHERE flightID = ip_flightID);

  -- 获取当前航段
  SET flight_leg = (
    SELECT legID FROM route_path
    WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID)
      AND sequence = seq
  );

  SET curr_loc = (
    SELECT locationID FROM airport
    WHERE airportID = (SELECT departure FROM leg WHERE legID = flight_leg)
  );

  SET next_dest = (
    SELECT arrival FROM leg WHERE legID = flight_leg
  );

  -- 选出符合条件的乘客
  CREATE TEMPORARY TABLE passenger_set2 AS
    SELECT personID FROM person
    WHERE locationID = curr_loc
      AND personID IN (
        SELECT personID FROM passenger_vacations WHERE airportID = next_dest
      )
      AND personID IN (
        SELECT personID FROM passenger
        WHERE funds >= (SELECT cost FROM flight WHERE flightID = ip_flightID)
      );

  SET num_passengers = (SELECT COUNT(*) FROM passenger_set2);

  -- 检查座位容量
  IF (
    SELECT seat_capacity FROM airplane
    WHERE airlineID = ap AND tail_num = tn
  ) < num_passengers THEN
    DROP TEMPORARY TABLE passenger_set2;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough seats for passengers';
  END IF;

  -- 登机：扣钱、更新 locationID
  UPDATE passenger
  SET funds = funds - (
    SELECT cost FROM flight WHERE flightID = ip_flightID
  )
  WHERE personID IN (SELECT personID FROM passenger_set2);

  UPDATE person
  SET locationID = (
    SELECT locationID FROM airplane
    WHERE airlineID = ap AND tail_num = tn
  )
  WHERE personID IN (SELECT personID FROM passenger_set2);

  DROP TEMPORARY TABLE passenger_set2;

END;
//
DELIMITER ;

-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS passengers_disembark;
DELIMITER //

CREATE PROCEDURE passengers_disembark (
  IN ip_flightID VARCHAR(50)
)
sp_main: BEGIN
  DECLARE ap VARCHAR(64);
  DECLARE tn VARCHAR(6);
  DECLARE plane_loc VARCHAR(50);
  DECLARE airport_idnum CHAR(3);
  DECLARE airport_loc VARCHAR(50);
  DECLARE curr_legID VARCHAR(50);
  DECLARE seq INT;

  -- 检查航班是否存在
  IF NOT EXISTS (SELECT 1 FROM flight WHERE flightID = ip_flightID) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight ID does not exist';
  END IF;

  -- 检查是否已落地
  IF (SELECT airplane_status FROM flight WHERE flightID = ip_flightID) = 'in_flight' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight is still in the air';
  END IF;

  -- 获取航班飞机信息和位置
  SET ap = (SELECT support_airline FROM flight WHERE flightID = ip_flightID);
  SET tn = (SELECT support_tail FROM flight WHERE flightID = ip_flightID);
  SET plane_loc = (
    SELECT locationID FROM airplane
    WHERE airlineID = ap AND tail_num = tn
  );

  -- 获取当前航段和目的地机场
  SET seq = (SELECT progress FROM flight WHERE flightID = ip_flightID);
  SET curr_legID = (
    SELECT legID FROM route_path
    WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID)
      AND sequence = seq
  );
  SET airport_idnum = (
    SELECT arrival FROM leg WHERE legID = curr_legID
  );
  SET airport_loc = (
    SELECT locationID FROM airport WHERE airportID = airport_idnum
  );

  -- 找到要下机的乘客
  CREATE TEMPORARY TABLE passenger_set AS 
    SELECT personID
    FROM passenger_vacations
    WHERE sequence = 1
      AND airportID = airport_idnum
      AND personID IN (
        SELECT personID FROM person WHERE locationID = plane_loc
      );

  -- 更新这些乘客的地点
  UPDATE person
  SET locationID = airport_loc
  WHERE personID IN (SELECT personID FROM passenger_set);

  -- 修改乘客的 vacation plan
  UPDATE passenger_vacations
  SET sequence = sequence - 1
  WHERE sequence > 1
    AND personID IN (SELECT personID FROM passenger_set);

  DELETE FROM passenger_vacations
  WHERE sequence = 1
    AND personID IN (SELECT personID FROM passenger_set);

  DROP TEMPORARY TABLE passenger_set;

END;
//
DELIMITER ;


-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS assign_pilot;
DELIMITER //

CREATE PROCEDURE assign_pilot (
  IN ip_flightID VARCHAR(50),
  IN ip_personID VARCHAR(50)
)
sp_main: BEGIN
  DECLARE seq INT;
  DECLARE numlegs INT;
  DECLARE airplane_type VARCHAR(100);
  DECLARE airline_name VARCHAR(50);
  DECLARE tn VARCHAR(50);
  DECLARE curr_legID VARCHAR(50);
  DECLARE curr_loc VARCHAR(50);

  -- 检查航班是否存在
  IF NOT EXISTS (SELECT 1 FROM flight WHERE flightID = ip_flightID) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight ID does not exist';
  END IF;

  -- 航班必须在地面
  IF (SELECT airplane_status FROM flight WHERE flightID = ip_flightID) = 'in_flight' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight is already in the air';
  END IF;

  -- 获取进度和航段数量
  SET seq = (SELECT progress FROM flight WHERE flightID = ip_flightID);
  SET numlegs = (
    SELECT COUNT(*) FROM route_path
    WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID)
  );

  IF seq = 0 THEN
    SET seq = seq + 1;
  END IF;

  -- 无更多航段可飞
  IF seq >= numlegs THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight has no remaining legs';
  END IF;

  -- 检查 pilot 是否存在
  IF NOT EXISTS (SELECT 1 FROM pilot WHERE personID = ip_personID) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pilot does not exist';
  END IF;

  -- 检查 pilot 是否已经被分配航班
  IF (SELECT commanding_flight FROM pilot WHERE personID = ip_personID) IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pilot is already assigned to another flight';
  END IF;

  -- 获取飞机信息
  SET airline_name = (SELECT support_airline FROM flight WHERE flightID = ip_flightID);
  SET tn = (SELECT support_tail FROM flight WHERE flightID = ip_flightID);

  -- 获取飞机类型
  SET airplane_type = (
    SELECT plane_type FROM airplane
    WHERE airlineID = airline_name AND tail_num = tn
  );

  -- 检查是否持有该类型飞机 license
  IF airplane_type NOT IN (
    SELECT license FROM pilot_licenses
    WHERE personID = ip_personID
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pilot does not have license for this aircraft type';
  END IF;

  -- 获取当前航段出发地对应 location
  SET curr_legID = (
    SELECT legID FROM route_path
    WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID)
      AND sequence = seq
  );

  SET curr_loc = (
    SELECT locationID FROM airport
    WHERE airportID = (SELECT departure FROM leg WHERE legID = curr_legID)
  );

  -- pilot 必须在这个 location 才能登机
  IF (
    SELECT locationID FROM person WHERE personID = ip_personID
  ) != curr_loc THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pilot is not at the departure location';
  END IF;

  -- 分配 flight、移动到飞机所在位置
  UPDATE pilot
  SET commanding_flight = ip_flightID
  WHERE personID = ip_personID;

  UPDATE person
  SET locationID = (
    SELECT locationID FROM airplane
    WHERE airlineID = airline_name AND tail_num = tn
  )
  WHERE personID = ip_personID;

END;
//
DELIMITER ;

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS recycle_crew;
DELIMITER //

CREATE PROCEDURE recycle_crew (
  IN ip_flightID VARCHAR(50)
)
sp_main: BEGIN

  -- 航班必须存在且必须已在地面
  IF NOT EXISTS (
    SELECT 1 FROM flight 
    WHERE flightID = ip_flightID 
      AND airplane_status = 'on_ground'
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight is not on the ground';
  END IF;

  -- 航班必须飞完所有航段
  IF (
    SELECT progress FROM flight WHERE flightID = ip_flightID
  ) < (
    SELECT MAX(sequence) FROM route_path
    WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight still has remaining legs';
  END IF;

  -- 飞机上不能有非 pilot 的乘客
  IF EXISTS (
    SELECT 1 FROM person 
    WHERE locationID IN (
      SELECT locationID FROM airplane 
      WHERE tail_num = (
        SELECT support_tail FROM flight WHERE flightID = ip_flightID
      )
    )
    AND personID NOT IN (SELECT personID FROM pilot)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Passengers are still on the airplane';
  END IF;

  -- 清除 pilot 分配的航班任务
  UPDATE pilot 
  SET commanding_flight = NULL
  WHERE commanding_flight = ip_flightID;

  -- 将 pilot 移至飞机所在的目的机场
  UPDATE person
  SET locationID = (
    SELECT airport.locationID
    FROM flight f
    JOIN route_path rp ON f.routeID = rp.routeID AND f.progress = rp.sequence
    JOIN leg l ON rp.legID = l.legID
    JOIN airport ON airport.airportID = l.arrival
    WHERE f.flightID = ip_flightID
  )
  WHERE locationID IN (
    SELECT locationID FROM airplane
    WHERE tail_num = (
      SELECT support_tail FROM flight WHERE flightID = ip_flightID
    )
  );

END;
//
DELIMITER ;

-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS retire_flight;
DELIMITER //

CREATE PROCEDURE retire_flight (
  IN ip_flightID VARCHAR(50)
)
sp_main: BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM flight 
    WHERE flightID = ip_flightID 
      AND airplane_status = 'on_ground'
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight must be on the ground to be retired';
  END IF;

  IF (
    SELECT progress FROM flight WHERE flightID = ip_flightID
  ) NOT IN (
    0,
    (SELECT MAX(sequence) 
     FROM route_path 
     WHERE routeID = (
       SELECT routeID FROM flight WHERE flightID = ip_flightID
     ))
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight must be at the start or end of its route';
  END IF;

  IF EXISTS (
    SELECT 1 FROM person 
    WHERE locationID = (
      SELECT locationID 
      FROM airplane 
      WHERE tail_num = (
        SELECT support_tail FROM flight WHERE flightID = ip_flightID
      )
    )
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are still people on this flight';
  END IF;

  DELETE FROM flight 
  WHERE flightID = ip_flightID;

END;
//
DELIMITER ;


-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS simulation_cycle;
DELIMITER //

CREATE PROCEDURE simulation_cycle ()
sp_main: BEGIN

  DECLARE next_flight VARCHAR(50);
  DECLARE next_status VARCHAR(50);
  DECLARE route_id VARCHAR(50);
  DECLARE progress INT;
  DECLARE max_seq INT;
  DECLARE action_taken VARCHAR(50);

  -- ❗️使用 EXIT HANDLER 避免继续执行
  DECLARE EXIT HANDLER FOR NOT FOUND
  BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No available flight to process in simulation cycle';
  END;

  -- 获取下一航班
  SELECT flightID, airplane_status INTO next_flight, next_status
  FROM flight 
  ORDER BY next_time ASC, 
           (CASE WHEN airplane_status = 'in_flight' THEN 1 ELSE 2 END), 
           flightID ASC 
  LIMIT 1;

  IF next_status = 'in_flight' THEN
    CALL flight_landing(next_flight);
    CALL passengers_disembark(next_flight);

    SET route_id = (SELECT routeID FROM flight WHERE flightID = next_flight);
    SET progress = (SELECT progress FROM flight WHERE flightID = next_flight);
    SET max_seq = (SELECT MAX(sequence) FROM route_path WHERE routeID = route_id);

    IF progress = max_seq THEN
      CALL recycle_crew(next_flight);
      CALL retire_flight(next_flight);
      SET action_taken = 'Retired'; 
    ELSE
      SET action_taken = 'Landed'; 
    END IF;

  ELSE
    CALL passengers_board(next_flight);
    CALL flight_takeoff(next_flight);
    SET action_taken = 'Took off';
  END IF;


  SELECT next_flight AS flight_id, action_taken AS action;

END;
//
DELIMITER ;

-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. 
We need to display what airports these flights are departing from, what airports 
they are arriving at, the number of flights that are flying between the 
departure and arrival airport, the list of those flights (ordered by their 
flight IDs), the earliest and latest arrival times for the destinations and the 
list of planes (by their respective flight IDs) flying these flights. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
SELECT 
    l.departure, 
 l.arrival,
    COUNT(f.flightID),
    GROUP_CONCAT(f.flightID ORDER BY f.flightID ASC),
    MIN(f.next_time),
    MAX(f.next_time),
    GROUP_CONCAT(ap.locationID ORDER BY f.flightID ASC)
FROM flight f
JOIN route_path rp ON rp.sequence = f.progress AND f.routeID = rp.routeID
JOIN leg l ON l.legID = rp.legID
JOIN airplane ap ON ap.tail_num = f.support_tail
WHERE f.airplane_status = 'in_flight' 
GROUP BY l.departure, l.arrival;

-- [15] flights_on_the_ground()
-- ------------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are 
located. We need to display what airports these flights are departing from, how 
many flights are departing from each airport, the list of flights departing from 
each airport (ordered by their flight IDs), the earliest and latest arrival time 
amongst all of these flights at each airport, and the list of planes (by their 
respective flight IDs) that are departing from each airport.*/
-- ------------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
select
departure as departing_from,
COUNT(*) as num_flights,
GROUP_CONCAT(DISTINCT temp.flightID ORDER BY temp.flightID SEPARATOR ',') as flight_list,
MIN(temp.next_time) as earliest_arrival,
MAX(temp.next_time) as latest_arrival,
GROUP_CONCAT(DISTINCT airplane.locationId ORDER BY temp.flightID SEPARATOR ',') as airplane_list
from 
(
select arrival as departure,
flight.flightId as flightID,
flight.next_time as next_time,
flight.support_tail as support_tail
from flight
join route_path join leg
on leg.legId = route_path.legId and flight.routeId = route_path.routeId
where airplane_status = 'on_ground' and progress = sequence and progress <> sequence - 1
union
select departure as departure,
flight.flightId as flightID,
flight.next_time as next_time,
flight.support_tail as support_tail from flight join route_path join leg 
on leg.legId = route_path.legId and flight.routeId = route_path.routeId 
where airplane_status = 'on_ground' and progress = sequence - 1 and progress <> sequence
)
as temp join airplane on temp.support_tail = airplane.tail_num
group by departure;


-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. We 
need to display what airports these people are departing from, what airports 
they are arriving at, the list of planes (by the location id) flying these 
people, the list of flights these people are on (by flight ID), the earliest 
and latest arrival times of these people, the number of these people that are 
pilots, the number of these people that are passengers, the total number of 
people on the airplane, and the list of these people by their person id. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
select
leg.departure as departing_from, 
leg.arrival as arriving_at,
COUNT(DISTINCT flight.flightId) as num_airplanes,
GROUP_CONCAT(DISTINCT airplane.locationID ORDER BY airplane.locationID ASC) as flight_list, 
GROUP_CONCAT(DISTINCT flight.flightID ORDER BY flight.flightID ASC) as airplane_list,
min(flight.next_time) as earliest_arrival, 
max(flight.next_time) as latest_arrival,
COUNT(pilot.personId) as num_pilots,
COUNT(passenger.personId) as num_passengers,
COUNT(*) as joint_pilots_passengers, 
GROUP_CONCAT(DISTINCT person.personId ORDER BY person.personId SEPARATOR ',') as person_list
FROM flight
JOIN route_path ON route_path.sequence = flight.progress AND flight.routeID = route_path.routeID
JOIN leg ON leg.legID = route_path.legID
JOIN airplane ON airplane.tail_num = flight.support_tail
join person on person.locationId = airplane.locationId and airplane.locationId is not null
left join pilot on person.personId = pilot.personId
left join passenger on person.personId = passenger.personId
WHERE flight.airplane_status = 'in_flight'
group by leg.departure, leg.arrival;

-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground and in an 
airport are located. We need to display what airports these people are departing 
from by airport id, location id, and airport name, the city and state of these 
airports, the number of these people that are pilots, the number of these people 
that are passengers, the total number people at the airport, and the list of 
these people by their person id. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select
airport.airportId as departing_from,
airport.locationId as airport,
airport.airport_name as airport_name,
airport.city as city,
airport.state as state,
airport.country as country,
COUNT(pilot.personId) as num_pilots,
COUNT(passenger.personId) as num_passengers,
COUNT(*) as joint_pilots_passengers,
GROUP_CONCAT(DISTINCT person.personId ORDER BY person.personId SEPARATOR ',') as person_list
from 
person join airport on person.locationId = airport.locationId
left join pilot on person.personId = pilot.personId
left join passenger on person.personId = passenger.personId
group by airport.airportId;

-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view will give a summary of every route. This will include the routeID, 
the number of legs per route, the legs of the route in sequence, the total 
distance of the route, the number of flights on this route, the flightIDs of 
those flights by flight ID, and the sequence of airports visited by the route. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select 
route.routeID as route,
COUNT(DISTINCT leg.legID) as num_legs,
GROUP_CONCAT(DISTINCT leg.legID order by route_path.sequence SEPARATOR ',') as leg_sequence,
(
	SELECT SUM(l2.distance)
	FROM route_path rp2
	JOIN leg l2 ON rp2.legID = l2.legID
	WHERE rp2.routeID = route.routeID
) as route_length,
COUNT(distinct flight.flightID) as num_flights,
GROUP_CONCAT(DISTINCT flight.flightID SEPARATOR ',') as flight_list,
GROUP_CONCAT(DISTINCT CONCAT(leg.departure, '->', leg.arrival) order by route_path.sequence SEPARATOR ',') as airport_sequence
from route
join route_path on route.routeID = route_path.routeID 
join leg on leg.legID = route_path.legID
left join flight on flight.routeID = route.routeID
group by route.routeID;

-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. It should 
specify the city, state, the number of airports shared, and the lists of the 
airport codes and airport names that are shared both by airport ID. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
select
a1.city as city,
a1.state as state,
a1.country as country,
COUNT(DISTINCT a1.airportID) as num_airports,
GROUP_CONCAT(DISTINCT a1.airportID order by a1.airportID SEPARATOR ',') as airport_code_list,
GROUP_CONCAT(DISTINCT a1.airport_name order by a1.airportID SEPARATOR ',') as airport_name_list
from
airport a1 join airport a2 on a1.city = a2.city and a1.state = a2.state and a1.country = a2.country and a1.airportID <> a2.airportID
group by a1.city, a1.state, a1.country;