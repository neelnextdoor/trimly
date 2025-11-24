-- Complete Database Setup Script for Barber Application
-- This script creates the database, all tables, and seeds initial data

-- Create Database
CREATE DATABASE IF NOT EXISTS barber CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE barber;

-- Drop tables if they exist (in reverse dependency order)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Analytics_Event;
DROP TABLE IF EXISTS Audit_Log;
DROP TABLE IF EXISTS Webhook;
DROP TABLE IF EXISTS Notification;
DROP TABLE IF EXISTS Device;
DROP TABLE IF EXISTS Media;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Payout;
DROP TABLE IF EXISTS Refund;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Tax_Rate;
DROP TABLE IF EXISTS Appointment_Promo;
DROP TABLE IF EXISTS Promo;
DROP TABLE IF EXISTS Queue_Ticket;
DROP TABLE IF EXISTS Booking_Lock;
DROP TABLE IF EXISTS Appointment_Audit;
DROP TABLE IF EXISTS Appointment_Item;
DROP TABLE IF EXISTS Appointment;
DROP TABLE IF EXISTS Service_Addon;
DROP TABLE IF EXISTS Worker_Service;
DROP TABLE IF EXISTS Outlet_Service;
DROP TABLE IF EXISTS Service_Category;
DROP TABLE IF EXISTS Service;
DROP TABLE IF EXISTS Worker_Timeoff;
DROP TABLE IF EXISTS Worker_Schedule;
DROP TABLE IF EXISTS Worker;
DROP TABLE IF EXISTS Outlet_Closure;
DROP TABLE IF EXISTS Outlet_Business_Hours;
DROP TABLE IF EXISTS Outlet;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS OTP;
DROP TABLE IF EXISTS User_Role;
DROP TABLE IF EXISTS Role_Permission;
DROP TABLE IF EXISTS Permission;
DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS User;
SET FOREIGN_KEY_CHECKS = 1;

-- Create User table
CREATE TABLE User (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    mpin_hash VARCHAR(255),
    dob DATE,
    pic_url VARCHAR(500),
    country VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT,
    updated_by INT,
    role_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES User(id),
    FOREIGN KEY (updated_by) REFERENCES User(id)
);

-- Create Role table
CREATE TABLE Role (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

-- Create Permission table
CREATE TABLE Permission (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

-- Create Role_Permission junction table
CREATE TABLE Role_Permission (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES Role(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES Permission(id) ON DELETE CASCADE
);

-- Create User_Role table
CREATE TABLE User_Role (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    scope_type ENUM('GLOBAL', 'OUTLET') NOT NULL,
    outlet_id INT NULL,
    PRIMARY KEY (user_id, role_id, scope_type),
    UNIQUE KEY unique_user_role_outlet (user_id, role_id, scope_type, outlet_id),
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES Role(id) ON DELETE CASCADE
);

-- Create OTP table
CREATE TABLE OTP (
    id INT PRIMARY KEY AUTO_INCREMENT,
    phone_number VARCHAR(20) NOT NULL,
    otp_code VARCHAR(10) NOT NULL,
    expiry_at DATETIME NOT NULL,
    consumed_at DATETIME NULL,
    meta JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_phone_expiry (phone_number, expiry_at)
);

-- Create Address table
CREATE TABLE Address (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    label VARCHAR(100),
    line1 VARCHAR(255) NOT NULL,
    line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    pincode VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE
);

-- Create Outlet table
CREATE TABLE Outlet (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    image_url VARCHAR(500),
    description TEXT,
    address_id INT,
    location POINT SRID 4326 NOT NULL,
    phone_number VARCHAR(20),
    insta VARCHAR(255),
    fb VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (address_id) REFERENCES Address(id),
    SPATIAL INDEX idx_location (location)
);

-- Create Outlet_Business_Hours table
CREATE TABLE Outlet_Business_Hours (
    id INT PRIMARY KEY AUTO_INCREMENT,
    outlet_id INT NOT NULL,
    day_of_week TINYINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    break_from TIME NULL,
    break_to TIME NULL,
    timezone VARCHAR(50) DEFAULT 'UTC',
    is_closed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id) ON DELETE CASCADE,
    UNIQUE KEY unique_outlet_day (outlet_id, day_of_week)
);

-- Create Outlet_Closure table
CREATE TABLE Outlet_Closure (
    id INT PRIMARY KEY AUTO_INCREMENT,
    outlet_id INT NOT NULL,
    date DATE NOT NULL,
    reason VARCHAR(255),
    full_day BOOLEAN DEFAULT TRUE,
    from_time TIME NULL,
    to_time TIME NULL,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id) ON DELETE CASCADE,
    UNIQUE KEY unique_outlet_date (outlet_id, date)
);

-- Create Worker table
CREATE TABLE Worker (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    default_outlet_id INT,
    bio TEXT,
    rating_avg DECIMAL(3,2) DEFAULT 0.00,
    active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE,
    FOREIGN KEY (default_outlet_id) REFERENCES Outlet(id)
);

-- Create Worker_Schedule table
CREATE TABLE Worker_Schedule (
    worker_id INT NOT NULL,
    outlet_id INT NOT NULL,
    day_of_week TINYINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    capacity_parallel INT DEFAULT 1,
    effective_from DATE NOT NULL,
    effective_to DATE NULL,
    PRIMARY KEY (worker_id, outlet_id, day_of_week, effective_from),
    FOREIGN KEY (worker_id) REFERENCES Worker(id) ON DELETE CASCADE,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id) ON DELETE CASCADE
);

-- Create Worker_Timeoff table
CREATE TABLE Worker_Timeoff (
    worker_id INT NOT NULL,
    outlet_id INT NOT NULL,
    date DATE NOT NULL,
    from_time TIME NULL,
    to_time TIME NULL,
    reason VARCHAR(255),
    PRIMARY KEY (worker_id, outlet_id, date),
    FOREIGN KEY (worker_id) REFERENCES Worker(id) ON DELETE CASCADE,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id) ON DELETE CASCADE
);

-- Create Service_Category table
CREATE TABLE Service_Category (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 0
);

-- Create Service table
CREATE TABLE Service (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    default_duration_min INT NOT NULL,
    category_id INT,
    gender ENUM('MALE', 'FEMALE', 'UNISEX') DEFAULT 'UNISEX',
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES Service_Category(id)
);

-- Create Outlet_Service table
CREATE TABLE Outlet_Service (
    outlet_id INT NOT NULL,
    service_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    min_price DECIMAL(10,2) NOT NULL,
    max_price DECIMAL(10,2) NOT NULL,
    duration_min INT NOT NULL,
    PRIMARY KEY (outlet_id, service_id),
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES Service(id) ON DELETE CASCADE
);

-- Create Worker_Service table
CREATE TABLE Worker_Service (
    worker_id INT NOT NULL,
    service_id INT NOT NULL,
    level VARCHAR(50),
    duration_min INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (worker_id, service_id),
    FOREIGN KEY (worker_id) REFERENCES Worker(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES Service(id) ON DELETE CASCADE
);

-- Create Service_Addon table
CREATE TABLE Service_Addon (
    id INT PRIMARY KEY AUTO_INCREMENT,
    service_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    duration_min INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (service_id) REFERENCES Service(id) ON DELETE CASCADE,
    UNIQUE KEY unique_service_addon (service_id, name)
);

-- Create Appointment table
CREATE TABLE Appointment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    outlet_id INT NOT NULL,
    customer_id INT NOT NULL,
    worker_id INT NOT NULL,
    start_at DATETIME NOT NULL,
    end_at DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW') DEFAULT 'PENDING',
    source VARCHAR(50) DEFAULT 'APP',
    notes TEXT,
    totals JSON,
    currency VARCHAR(10) DEFAULT 'INR',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id),
    FOREIGN KEY (customer_id) REFERENCES User(id),
    FOREIGN KEY (worker_id) REFERENCES Worker(id),
    INDEX idx_outlet_start (outlet_id, start_at),
    INDEX idx_worker_start (worker_id, start_at),
    INDEX idx_customer_start (customer_id, start_at)
);

-- Create Appointment_Item table
CREATE TABLE Appointment_Item (
    id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    service_id INT NOT NULL,
    addon_id INT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    duration_min INT NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES Appointment(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES Service(id),
    FOREIGN KEY (addon_id) REFERENCES Service_Addon(id)
);

-- Create Appointment_Audit table
CREATE TABLE Appointment_Audit (
    appointment_id INT NOT NULL,
    changed_by INT NOT NULL,
    from_status VARCHAR(50),
    to_status VARCHAR(50) NOT NULL,
    changed_at DATETIME NOT NULL,
    reason VARCHAR(255),
    PRIMARY KEY (appointment_id, changed_at),
    FOREIGN KEY (appointment_id) REFERENCES Appointment(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES User(id)
);

-- Create Booking_Lock table
CREATE TABLE Booking_Lock (
    worker_id INT NOT NULL,
    outlet_id INT NOT NULL,
    start_at DATETIME NOT NULL,
    end_at DATETIME NOT NULL,
    hold_token VARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (worker_id, outlet_id, start_at, end_at),
    FOREIGN KEY (worker_id) REFERENCES Worker(id) ON DELETE CASCADE,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id) ON DELETE CASCADE,
    INDEX idx_expires_at (expires_at)
);

-- Create Queue_Ticket table
CREATE TABLE Queue_Ticket (
    id INT PRIMARY KEY AUTO_INCREMENT,
    outlet_id INT NOT NULL,
    customer_id INT NOT NULL,
    party_size INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('WAITING', 'CALLED', 'SERVED', 'CANCELLED') DEFAULT 'WAITING',
    eta_min INT,
    position INT,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id),
    FOREIGN KEY (customer_id) REFERENCES User(id),
    INDEX idx_outlet_status (outlet_id, status)
);

-- Create Promo table
CREATE TABLE Promo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    type ENUM('AMOUNT', 'PERCENTAGE') NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    max_discount DECIMAL(10,2),
    min_subtotal DECIMAL(10,2),
    start_at DATE NOT NULL,
    end_at DATE NOT NULL,
    usage_limit INT,
    per_user_limit INT DEFAULT 1,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Appointment_Promo table
CREATE TABLE Appointment_Promo (
    appointment_id INT NOT NULL,
    promo_id INT NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (appointment_id, promo_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointment(id) ON DELETE CASCADE,
    FOREIGN KEY (promo_id) REFERENCES Promo(id)
);

-- Create Tax_Rate table
CREATE TABLE Tax_Rate (
    id INT PRIMARY KEY AUTO_INCREMENT,
    country VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    city VARCHAR(100),
    rate_percent DECIMAL(5,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE NULL,
    INDEX idx_location (country, state, city)
);

-- Create Payment table
CREATE TABLE Payment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    method VARCHAR(50) NOT NULL,
    provider VARCHAR(100),
    provider_ref VARCHAR(255),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    status ENUM('PENDING', 'CAPTURED', 'FAILED', 'REFUNDED') DEFAULT 'PENDING',
    paid_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES Appointment(id),
    INDEX idx_appointment (appointment_id)
);

-- Create Refund table
CREATE TABLE Refund (
    payment_id INT NOT NULL PRIMARY KEY,
    amount DECIMAL(10,2) NOT NULL,
    reason VARCHAR(255),
    status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING',
    processed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payment_id) REFERENCES Payment(id)
);

-- Create Payout table
CREATE TABLE Payout (
    id INT PRIMARY KEY AUTO_INCREMENT,
    outlet_id INT NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('PENDING', 'PAID', 'FAILED') DEFAULT 'PENDING',
    paid_at DATETIME,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id)
);

-- Create Review table
CREATE TABLE Review (
    id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    outlet_id INT NOT NULL,
    worker_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    images JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (appointment_id) REFERENCES Appointment(id),
    FOREIGN KEY (customer_id) REFERENCES User(id),
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id),
    FOREIGN KEY (worker_id) REFERENCES Worker(id),
    INDEX idx_outlet_rating (outlet_id, rating),
    INDEX idx_worker_rating (worker_id, rating)
);

-- Create Media table
CREATE TABLE Media (
    id INT PRIMARY KEY AUTO_INCREMENT,
    outlet_id INT,
    worker_id INT,
    url VARCHAR(500) NOT NULL,
    type ENUM('IMAGE', 'VIDEO') DEFAULT 'IMAGE',
    caption VARCHAR(255),
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id) ON DELETE CASCADE,
    FOREIGN KEY (worker_id) REFERENCES Worker(id) ON DELETE CASCADE
);

-- Create Device table
CREATE TABLE Device (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    fcm_token VARCHAR(255) NOT NULL,
    platform ENUM('ANDROID', 'IOS', 'WEB') NOT NULL,
    last_seen_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_token (user_id, fcm_token)
);

-- Create Notification table
CREATE TABLE Notification (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSON,
    status ENUM('PENDING', 'SENT', 'FAILED') DEFAULT 'PENDING',
    sent_at DATETIME,
    read_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE,
    INDEX idx_user_status (user_id, status)
);

-- Create Webhook table
CREATE TABLE Webhook (
    id INT PRIMARY KEY AUTO_INCREMENT,
    url VARCHAR(500) NOT NULL,
    secret VARCHAR(255),
    event_types JSON NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    last_success_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Audit_Log table
CREATE TABLE Audit_Log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(50) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id INT,
    diff JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE SET NULL,
    INDEX idx_entity (entity, entity_id),
    INDEX idx_user_created (user_id, created_at)
);

-- Create Analytics_Event table
CREATE TABLE Analytics_Event (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    outlet_id INT,
    name VARCHAR(100) NOT NULL,
    properties JSON,
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE SET NULL,
    FOREIGN KEY (outlet_id) REFERENCES Outlet(id) ON DELETE SET NULL,
    INDEX idx_name_occurred (name, occurred_at),
    INDEX idx_outlet_occurred (outlet_id, occurred_at)
);

-- ============================================
-- SEED DATA
-- ============================================

-- Insert Roles
INSERT INTO Role (id, name, description)
VALUES (1, 'Customer', 'General user'), (2, 'Worker', 'Performs services'), (3, 'Owner', 'Owns outlets');

-- Insert Permissions
INSERT INTO Permission (id, name, description)
VALUES (1, 'CREATE_APPOINTMENT', 'Create new appointments'), (2, 'MANAGE_OUTLET', 'Manage outlet details');

-- Insert Role_Permission
INSERT INTO Role_Permission (role_id, permission_id)
VALUES (1, 1), (3, 2);

-- Insert User
INSERT INTO User (id, first_name, last_name, email, phone_number, mpin_hash, dob, pic_url, country, state, city, is_active, created_by, updated_by, role_id)
VALUES (1, 'Aryan', 'Sharma', 'aryan@example.com', '+911234567890', 'hashed_mpin1', '1993-08-14', 'https://host/1.jpg', 'India', 'Delhi', 'New Delhi', TRUE, 1, 1, 2);

-- Insert User_Role
INSERT INTO User_Role (user_id, role_id, scope_type, outlet_id)
VALUES (1, 3, 'GLOBAL', NULL);

-- Insert OTP
INSERT INTO OTP (id, phone_number, otp_code, expiry_at, consumed_at, meta)
VALUES (1, '+911234567890', '123456', '2025-11-25 01:03:00', NULL, '{}');

-- Insert Address
INSERT INTO Address (id, user_id, label, line1, line2, city, state, country, pincode, is_default)
VALUES (1, 1, 'Home', '12A, Sector 7', '', 'New Delhi', 'Delhi', 'India', '110001', TRUE);

-- Insert Outlet
INSERT INTO Outlet (id, name, image_url, description, address_id, location, phone_number, insta, fb, is_active)
VALUES (1, 'Urban Cuts', 'https://host/outlet1.jpg', 'Modern barbershop', 1, ST_GeomFromText('POINT(77.216721 28.644800)', 4326), '+911111111111', 'urbancuts.insta', 'fb.com/urbancuts', TRUE);

-- Insert Outlet_Business_Hours
INSERT INTO Outlet_Business_Hours (id, outlet_id, day_of_week, open_time, close_time, break_from, break_to, timezone, is_closed)
VALUES (1, 1, 1, '10:00', '21:00', '13:30', '14:00', 'Asia/Kolkata', FALSE);

-- Insert Outlet_Closure
INSERT INTO Outlet_Closure (id, outlet_id, date, reason, full_day, from_time, to_time)
VALUES (1, 1, '2025-12-25', 'Christmas', TRUE, NULL, NULL);

-- Insert Worker
INSERT INTO Worker (id, user_id, default_outlet_id, bio, rating_avg, active)
VALUES (1, 1, 1, 'Experienced stylist', 4.8, TRUE);

-- Insert Worker_Schedule
INSERT INTO Worker_Schedule (worker_id, outlet_id, day_of_week, start_time, end_time, capacity_parallel, effective_from, effective_to)
VALUES (1, 1, 1, '10:00', '18:00', 2, '2025-11-25', NULL);

-- Insert Worker_Timeoff
INSERT INTO Worker_Timeoff (worker_id, outlet_id, date, from_time, to_time, reason)
VALUES (1, 1, '2025-12-31', '15:00', '17:00', 'Personal');

-- Insert Service_Category
INSERT INTO Service_Category (id, name, sort_order)
VALUES (1, 'Hair', 1);

-- Insert Service
INSERT INTO Service (id, name, description, default_duration_min, category_id, gender, image_url, is_active)
VALUES (1, 'Haircut', 'Classic haircut for men', 30, 1, 'MALE', 'https://host/haircut.jpg', TRUE);

-- Insert Outlet_Service
INSERT INTO Outlet_Service (outlet_id, service_id, is_active, min_price, max_price, duration_min)
VALUES (1, 1, TRUE, 300, 500, 30);

-- Insert Worker_Service
INSERT INTO Worker_Service (worker_id, service_id, level, duration_min, price, currency, is_active)
VALUES (1, 1, 'Senior', 30, 400, 'INR', TRUE);

-- Insert Service_Addon
INSERT INTO Service_Addon (id, service_id, name, duration_min, price, currency, is_active)
VALUES (1, 1, 'Beard Trim', 15, 150, 'INR', TRUE);

-- Insert Appointment
INSERT INTO Appointment (id, outlet_id, customer_id, worker_id, start_at, end_at, status, source, notes, totals, currency)
VALUES (1, 1, 1, 1, '2025-11-26 14:00', '2025-11-26 14:30', 'CONFIRMED', 'APP', 'N/A', '{"subtotal":400,"discount":0,"tax":72,"tip":50,"total":522}', 'INR');

-- Insert Appointment_Item
INSERT INTO Appointment_Item (id, appointment_id, service_id, addon_id, quantity, unit_price, duration_min, line_total)
VALUES (1, 1, 1, NULL, 1, 400, 30, 400);

-- Insert Appointment_Audit
INSERT INTO Appointment_Audit (appointment_id, changed_by, from_status, to_status, changed_at, reason)
VALUES (1, 1, 'PENDING', 'CONFIRMED', '2025-11-25 01:10', 'Auto-confirmed');

-- Insert Booking_Lock
INSERT INTO Booking_Lock (worker_id, outlet_id, start_at, end_at, hold_token, expires_at)
VALUES (1, 1, '2025-11-26 14:00', '2025-11-26 14:30', 'abcdef123456', '2025-11-26 13:55');

-- Insert Queue_Ticket
INSERT INTO Queue_Ticket (id, outlet_id, customer_id, party_size, created_at, status, eta_min, position)
VALUES (1, 1, 1, 2, '2025-11-25 13:45', 'WAITING', 20, 3);

-- Insert Promo
INSERT INTO Promo (id, code, description, type, value, max_discount, min_subtotal, start_at, end_at, usage_limit, per_user_limit, active)
VALUES (1, 'WELCOME100', 'Flat 100 off for new users', 'AMOUNT', 100, 100, 500, '2025-11-01', '2025-12-31', 500, 1, TRUE);

-- Insert Appointment_Promo
INSERT INTO Appointment_Promo (appointment_id, promo_id, discount_amount)
VALUES (1, 1, 100);

-- Insert Tax_Rate
INSERT INTO Tax_Rate (id, country, state, city, rate_percent, effective_from, effective_to)
VALUES (1, 'India', 'Delhi', 'New Delhi', 18.0, '2025-01-01', NULL);

-- Insert Payment
INSERT INTO Payment (id, appointment_id, method, provider, provider_ref, amount, currency, status, paid_at)
VALUES (1, 1, 'UPI', 'Paytm', 'TXN1234', 522, 'INR', 'CAPTURED', '2025-11-26 14:29');

-- Insert Refund
INSERT INTO Refund (payment_id, amount, reason, status, processed_at)
VALUES (1, 522, 'Customer cancelled', 'SUCCESS', '2025-11-27 10:11');

-- Insert Payout
INSERT INTO Payout (id, outlet_id, period_start, period_end, amount, status, paid_at, notes)
VALUES (1, 1, '2025-11-01', '2025-11-30', 10000, 'PAID', '2025-12-02 12:00', 'Monthly settlement');

-- Insert Review
INSERT INTO Review (id, appointment_id, customer_id, outlet_id, worker_id, rating, comment, images, created_at, is_public)
VALUES (1, 1, 1, 1, 1, 5, 'Great experience!', '[]', '2025-11-26 15:30', TRUE);

-- Insert Media
INSERT INTO Media (id, outlet_id, worker_id, url, type, caption, sort_order)
VALUES (1, 1, NULL, 'https://host/media1.jpg', 'IMAGE', 'Entrance', 1);

-- Insert Device
INSERT INTO Device (id, user_id, fcm_token, platform, last_seen_at)
VALUES (1, 1, 'abcdef-token', 'ANDROID', '2025-11-25 00:00');

-- Insert Notification
INSERT INTO Notification (id, user_id, type, title, body, data, status, sent_at, read_at)
VALUES (1, 1, 'APPOINTMENT_CONFIRMED', 'Booking Confirmed', 'Your slot is booked.', '{}', 'SENT', '2025-11-25 01:12', NULL);

-- Insert Webhook
INSERT INTO Webhook (id, url, secret, event_types, active, last_success_at)
VALUES (1, 'https://example.com/webhook', 'secret123', '["APPOINTMENT_CREATED"]', TRUE, '2025-11-25 01:00');

-- Insert Audit_Log
INSERT INTO Audit_Log (id, user_id, action, entity, entity_id, diff, created_at, ip)
VALUES (1, 1, 'UPDATE', 'Appointment', 1, '{"status":"CONFIRMED"}', '2025-11-25 01:12', '1.1.1.1');

-- Insert Analytics_Event
INSERT INTO Analytics_Event (id, user_id, outlet_id, name, properties, occurred_at)
VALUES (1, 1, 1, 'APPOINTMENT_BOOKED', '{"source":"app"}', '2025-11-25 01:13');

