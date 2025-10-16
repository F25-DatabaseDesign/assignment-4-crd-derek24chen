
-- DChen-Assign4-PLUS.sql
-- United Helpers Database - Assignment 4 (MySQL 8.0+)
-- Includes Extra Credit: Data Integrity TRIGGERS + Helpful VIEWS
-- Generated on 2025-10-16 10:35:28

-- =========================================================
-- Clean slate
-- =========================================================
DROP DATABASE IF EXISTS united_helpers;
CREATE DATABASE united_helpers CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE united_helpers;

-- =========================================================
-- Core Schema (same as baseline, with inline comments)
-- =========================================================

-- 1) volunteer
CREATE TABLE volunteer (
  volunteerId INT PRIMARY KEY AUTO_INCREMENT,
  volunteerName VARCHAR(100) NOT NULL,
  volunteerAddress VARCHAR(200) NOT NULL,
  volunteerTelephone VARCHAR(25) NOT NULL
);

-- 2) task_type
CREATE TABLE task_type (
  taskTypeId INT PRIMARY KEY AUTO_INCREMENT,
  taskTypeName VARCHAR(50) NOT NULL UNIQUE
);

-- 3) task_status
CREATE TABLE task_status (
  taskStatusId INT PRIMARY KEY AUTO_INCREMENT,
  taskStatusName VARCHAR(50) NOT NULL UNIQUE
);

-- 4) packing_list
CREATE TABLE packing_list (
  packingListId INT PRIMARY KEY AUTO_INCREMENT,
  packingListName VARCHAR(100) NOT NULL,
  packingListDescription TEXT NOT NULL
);

-- 5) task
CREATE TABLE task (
  taskCode INT PRIMARY KEY AUTO_INCREMENT,
  packingListId INT NULL,
  taskTypeId INT NOT NULL,
  taskStatusId INT NOT NULL,
  taskDescription VARCHAR(255) NOT NULL,
  CONSTRAINT fk_task_type FOREIGN KEY (taskTypeId) REFERENCES task_type(taskTypeId),
  CONSTRAINT fk_task_status FOREIGN KEY (taskStatusId) REFERENCES task_status(taskStatusId),
  CONSTRAINT fk_task_packlist FOREIGN KEY (packingListId) REFERENCES packing_list(packingListId)
);

-- 6) assignment
CREATE TABLE assignment (
  volunteerId INT NOT NULL,
  taskCode INT NOT NULL,
  startDateTime DATETIME NOT NULL,
  endDateTime DATETIME NULL,
  PRIMARY KEY (volunteerId, taskCode, startDateTime),
  CONSTRAINT fk_assign_vol FOREIGN KEY (volunteerId) REFERENCES volunteer(volunteerId),
  CONSTRAINT fk_assign_task FOREIGN KEY (taskCode) REFERENCES task(taskCode)
);

-- 7) package_type
CREATE TABLE package_type (
  packageTypeId INT PRIMARY KEY AUTO_INCREMENT,
  packageTypeName VARCHAR(50) NOT NULL UNIQUE
);

-- 8) package
CREATE TABLE package (
  packageId INT PRIMARY KEY AUTO_INCREMENT,
  taskCode INT NOT NULL,
  packageTypeId INT NOT NULL,
  packageCreateDate DATE NOT NULL,
  packageWeight DECIMAL(6,2) NOT NULL CHECK (packageWeight > 0),
  CONSTRAINT fk_package_task FOREIGN KEY (taskCode) REFERENCES task(taskCode),
  CONSTRAINT fk_package_type FOREIGN KEY (packageTypeId) REFERENCES package_type(packageTypeId)
);

-- 9) item (inventory)
CREATE TABLE item (
  itemId INT PRIMARY KEY AUTO_INCREMENT,
  itemDescription VARCHAR(100) NOT NULL,
  itemValue DECIMAL(8,2) NOT NULL CHECK (itemValue >= 0),
  quantityOnHand INT NOT NULL CHECK (quantityOnHand >= 0)
);

-- 10) package_contents (items inside packages)
CREATE TABLE package_contents (
  itemId INT NOT NULL,
  packageId INT NOT NULL,
  itemQuantity INT NOT NULL CHECK (itemQuantity > 0),
  PRIMARY KEY (itemId, packageId),
  CONSTRAINT fk_pc_item FOREIGN KEY (itemId) REFERENCES item(itemId),
  CONSTRAINT fk_pc_package FOREIGN KEY (packageId) REFERENCES package(packageId)
);

-- =========================================================
-- Lookup / Seed Data
-- =========================================================
INSERT INTO task_type (taskTypeName) VALUES
 ('packing'),
 ('recurring'),
 ('field');

INSERT INTO task_status (taskStatusName) VALUES
 ('open'),
 ('ongoing'),
 ('closed'),
 ('cancelled');

INSERT INTO package_type (packageTypeName) VALUES
 ('basic medical'),
 ('child-care'),
 ('food'),
 ('hygiene'),
 ('water');

-- Packing lists
INSERT INTO packing_list (packingListName, packingListDescription) VALUES
 ('Medical Response v1', 'Prepare basic medical kits with bandages, antiseptic, gauze, aspirin. Avoid food items.'),
 ('Child Care v1', 'Assemble child-care kits: diapers, wipes, toys, baby formula.'),
 ('Food Parcel v1', 'Build non-perishable food kits: rice, beans, canned veggies, cooking oil. No meat products.'),
 ('Hygiene v1', 'Soap, toothbrush, toothpaste, sanitary pads. No medicine.'),
 ('Water Kit v1', 'Bottled water and water purification tablets.');

-- Volunteers (10)
INSERT INTO volunteer (volunteerName, volunteerAddress, volunteerTelephone) VALUES
 ('Ava Li', '12 River St, Albany, NY', '518-555-0101'),
 ('Ben Gomez', '44 Oak Ave, Newark, NJ', '973-555-0102'),
 ('Chloe Park', '91 Maple Rd, Queens, NY', '718-555-0103'),
 ('Daniel Chen', '7 Bay Way, Brooklyn, NY', '347-555-0104'),
 ('Ethan Patel', '301 Pine St, Jersey City, NJ', '201-555-0105'),
 ('Fatima Khan', '88 Cedar Blvd, Hoboken, NJ', '201-555-0106'),
 ('Grace Miller', '5 Fifth Ave, New York, NY', '212-555-0107'),
 ('Hector Ruiz', '73 Grove St, Ridgewood, NY', '929-555-0108'),
 ('Ivy Nguyen', '410 Elm St, Yonkers, NY', '914-555-0109'),
 ('Jamal Brown', '22 Park Pl, Newark, NJ', '973-555-0110');

-- Tasks (12, mix of packing/non-packing)
INSERT INTO task (packingListId, taskTypeId, taskStatusId, taskDescription) VALUES
 (3, 1, 1, 'Prepare 100 food parcels for Riverside Shelter'),
 (1, 1, 2, 'Assemble 50 basic medical kits for Field Team Alpha'),
 (2, 1, 1, 'Build 80 child-care kits for Family Center'),
 (NULL, 2, 2, 'Answer hotline phones (week 42)'),
 (4, 1, 1, 'Assemble 60 hygiene kits for West District'),
 (NULL, 3, 1, 'Field assessment in North County'),
 (5, 1, 1, 'Prepare 120 water kits for Evacuation Site A'),
 (NULL, 2, 1, 'Warehouse inventory count (Q4 cycle)'),
 (NULL, 2, 1, 'Volunteer orientation and training'),
 (3, 1, 1, 'Prepare 150 food parcels for East Haven'),
 (1, 1, 1, 'Assemble 75 basic medical kits for Clinic B'),
 (2, 1, 1, 'Build 90 child-care kits for Community Center');

-- Items (18)
INSERT INTO item (itemDescription, itemValue, quantityOnHand) VALUES
 ('Bandages (roll)', 1.25, 2000),
 ('Antiseptic wipes (10pk)', 2.50, 1800),
 ('Gauze pads (10pk)', 1.80, 1600),
 ('Aspirin (bottle 50ct)', 3.75, 1200),
 ('Diapers (pack of 20)', 8.99, 900),
 ('Baby wipes (pack of 40)', 3.25, 1100),
 ('Toy (small plush)', 2.10, 700),
 ('Infant formula (tin)', 12.00, 600),
 ('Rice (1kg)', 2.20, 2200),
 ('Beans (1kg)', 2.00, 2100),
 ('Canned vegetables (400g)', 1.40, 2300),
 ('Cooking oil (1L)', 4.10, 1500),
 ('Soap bar', 0.90, 1900),
 ('Toothbrush', 0.75, 2000),
 ('Toothpaste (100ml)', 1.10, 1950),
 ('Sanitary pads (10pk)', 2.60, 1700),
 ('Bottled water (1.5L)', 1.00, 5000),
 ('Water purification tablets (10ct)', 3.00, 1400);

-- Packages (12)
INSERT INTO package (taskCode, packageTypeId, packageCreateDate, packageWeight) VALUES
 (1, 3, '2025-10-01', 6.50),
 (1, 3, '2025-10-01', 6.45),
 (1, 3, '2025-10-01', 6.60),
 (2, 1, '2025-10-02', 1.20),
 (2, 1, '2025-10-02', 1.25),
 (3, 2, '2025-10-03', 3.10),
 (5, 4, '2025-10-03', 2.20),
 (7, 5, '2025-10-04', 3.00),
 (10, 3, '2025-10-05', 6.70),
 (10, 3, '2025-10-05', 6.55),
 (11, 1, '2025-10-06', 1.30),
 (12, 2, '2025-10-06', 3.20);

-- Package contents (multiple items per relevant package)
INSERT INTO package_contents (itemId, packageId, itemQuantity) VALUES
 -- Food packages: rice, beans, canned veg, oil
 (9, 1, 2), (10, 1, 1), (11, 1, 2), (12, 1, 1),
 (9, 2, 2), (10, 2, 1), (11, 2, 2), (12, 2, 1),
 (9, 3, 1), (10, 3, 2), (11, 3, 2), (12, 3, 1),
 -- Medical packages: bandages, antiseptic, gauze, aspirin
 (1, 4, 3), (2, 4, 1), (3, 4, 2), (4, 4, 1),
 (1, 5, 3), (2, 5, 1), (3, 5, 2), (4, 5, 1),
 -- Child-care packages: diapers, wipes, toy, formula
 (5, 6, 1), (6, 6, 1), (7, 6, 1), (8, 6, 1),
 -- Hygiene packages: soap, toothbrush, toothpaste, sanitary pads
 (13, 7, 2), (14, 7, 2), (15, 7, 1), (16, 7, 1),
 -- Water packages: bottles & tablets
 (17, 8, 4), (18, 8, 1),
 -- Food again (task 10)
 (9, 9, 2), (10, 9, 1), (11, 9, 2), (12, 9, 1),
 (9,10, 2), (10,10, 1), (11,10, 2), (12,10, 1),
 -- Medical again
 (1, 11, 3), (2, 11, 1), (3, 11, 2), (4, 11, 1),
 -- Child-care again
 (5, 12, 1), (6, 12, 1), (7, 12, 1), (8, 12, 1);

-- Assignments (13 rows)
INSERT INTO assignment (volunteerId, taskCode, startDateTime, endDateTime) VALUES
 (1, 1, '2025-10-01 09:00:00', '2025-10-01 12:00:00'),
 (1,10, '2025-10-05 09:00:00', '2025-10-05 13:30:00'),
 (2, 1, '2025-10-01 09:00:00', '2025-10-01 12:00:00'),
 (2, 2, '2025-10-02 09:00:00', '2025-10-02 11:30:00'),
 (3, 3, '2025-10-03 10:00:00', '2025-10-03 14:00:00'),
 (3,12, '2025-10-06 09:30:00', '2025-10-06 12:30:00'),
 (4, 4, '2025-10-01 08:00:00', '2025-10-01 16:00:00'),
 (5, 5, '2025-10-03 09:00:00', '2025-10-03 12:00:00'),
 (6, 7, '2025-10-04 09:00:00', '2025-10-04 12:30:00'),
 (7, 8, '2025-10-02 13:00:00', '2025-10-02 17:00:00'),
 (8, 9, '2025-10-02 09:00:00', '2025-10-02 11:00:00'),
 (9,10, '2025-10-05 09:00:00', '2025-10-05 13:30:00'),
 (10,11, '2025-10-06 09:00:00', '2025-10-06 11:30:00');

-- =========================================================
-- EXTRA CREDIT: Integrity TRIGGERS (inventory + allowed items)
-- =========================================================

DELIMITER $$
CREATE TRIGGER bi_package_contents
BEFORE INSERT ON package_contents
FOR EACH ROW
BEGIN
  DECLARE v_pkg_type INT;
  DECLARE v_qty_on_hand INT;

  SELECT packageTypeId INTO v_pkg_type
  FROM package WHERE packageId = NEW.packageId;

  IF v_pkg_type = 3 AND NEW.itemId NOT IN (9,10,11,12) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only food items allowed in FOOD packages';
  ELSEIF v_pkg_type = 1 AND NEW.itemId NOT IN (1,2,3,4) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only medical items allowed in BASIC MEDICAL packages';
  ELSEIF v_pkg_type = 2 AND NEW.itemId NOT IN (5,6,7,8) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only child-care items allowed in CHILD-CARE packages';
  ELSEIF v_pkg_type = 4 AND NEW.itemId NOT IN (13,14,15,16) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only hygiene items allowed in HYGIENE packages';
  ELSEIF v_pkg_type = 5 AND NEW.itemId NOT IN (17,18) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only water items allowed in WATER packages';
  END IF;

  SELECT quantityOnHand INTO v_qty_on_hand FROM item WHERE itemId = NEW.itemId;
  IF v_qty_on_hand IS NULL OR v_qty_on_hand < NEW.itemQuantity THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient inventory for this item';
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER ai_package_contents
AFTER INSERT ON package_contents
FOR EACH ROW
BEGIN
  UPDATE item
  SET quantityOnHand = quantityOnHand - NEW.itemQuantity
  WHERE itemId = NEW.itemId;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER bu_package_contents
BEFORE UPDATE ON package_contents
FOR EACH ROW
BEGIN
  DECLARE v_pkg_type INT;
  DECLARE v_qty_on_hand INT;
  DECLARE v_delta INT;

  SELECT packageTypeId INTO v_pkg_type
  FROM package WHERE packageId = NEW.packageId;

  IF v_pkg_type = 3 AND NEW.itemId NOT IN (9,10,11,12) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only food items allowed in FOOD packages';
  ELSEIF v_pkg_type = 1 AND NEW.itemId NOT IN (1,2,3,4) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only medical items allowed in BASIC MEDICAL packages';
  ELSEIF v_pkg_type = 2 AND NEW.itemId NOT IN (5,6,7,8) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only child-care items allowed in CHILD-CARE packages';
  ELSEIF v_pkg_type = 4 AND NEW.itemId NOT IN (13,14,15,16) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only hygiene items allowed in HYGIENE packages';
  ELSEIF v_pkg_type = 5 AND NEW.itemId NOT IN (17,18) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only water items allowed in WATER packages';
  END IF;

  SET v_delta = NEW.itemQuantity - OLD.itemQuantity;
  IF v_delta > 0 THEN
    SELECT quantityOnHand INTO v_qty_on_hand FROM item WHERE itemId = NEW.itemId;
    IF v_qty_on_hand IS NULL OR v_qty_on_hand < v_delta THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient inventory for update';
    END IF;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER au_package_contents
AFTER UPDATE ON package_contents
FOR EACH ROW
BEGIN
  UPDATE item
  SET quantityOnHand = quantityOnHand - (NEW.itemQuantity - OLD.itemQuantity)
  WHERE itemId = NEW.itemId;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER ad_package_contents
AFTER DELETE ON package_contents
FOR EACH ROW
BEGIN
  UPDATE item
  SET quantityOnHand = quantityOnHand + OLD.itemQuantity
  WHERE itemId = OLD.itemId;
END$$
DELIMITER ;

-- =========================================================
-- EXTRA CREDIT: Helpful VIEWS
-- =========================================================

CREATE OR REPLACE VIEW vw_task_package_counts AS
SELECT
  t.taskCode,
  t.taskDescription,
  tt.taskTypeName,
  ts.taskStatusName,
  COUNT(p.packageId) AS packageCount
FROM task t
LEFT JOIN task_type tt ON tt.taskTypeId = t.taskTypeId
LEFT JOIN task_status ts ON ts.taskStatusId = t.taskStatusId
LEFT JOIN package p ON p.taskCode = t.taskCode
GROUP BY t.taskCode, t.taskDescription, tt.taskTypeName, ts.taskStatusName;

CREATE OR REPLACE VIEW vw_package_breakdown AS
SELECT
  p.packageId,
  p.taskCode,
  pt.packageTypeName,
  p.packageCreateDate,
  p.packageWeight,
  i.itemId,
  i.itemDescription,
  pc.itemQuantity,
  i.itemValue,
  (pc.itemQuantity * i.itemValue) AS lineValue
FROM package p
JOIN package_type pt ON pt.packageTypeId = p.packageTypeId
JOIN package_contents pc ON pc.packageId = p.packageId
JOIN item i ON i.itemId = pc.itemId;

CREATE OR REPLACE VIEW vw_volunteer_load AS
SELECT
  v.volunteerId,
  v.volunteerName,
  COUNT(DISTINCT a.taskCode) AS distinctTasks,
  COUNT(*) AS totalAssignments,
  MAX(a.endDateTime) AS lastEndTime
FROM volunteer v
LEFT JOIN assignment a ON a.volunteerId = v.volunteerId
GROUP BY v.volunteerId, v.volunteerName;

-- =========================================================
-- Optional verification queries (commented)
-- =========================================================
-- SELECT * FROM vw_task_package_counts ORDER BY packageCount DESC, taskCode;
-- SELECT * FROM vw_package_breakdown ORDER BY packageId, itemId;
-- SELECT * FROM vw_volunteer_load ORDER BY distinctTasks DESC, volunteerName;

-- End of PLUS script
