# MySQL Terminal Login Guide

## Quick Login Steps

### Method 1: Login with Password Prompt (Recommended)
```bash
mysql -u root -p
```
Then enter your password when prompted.

### Method 2: Login with Password in Command (Less Secure)
```bash
mysql -u root -pYOUR_PASSWORD
```

### Method 3: Login Directly to Specific Database
```bash
mysql -u root -p intellect
```
This will connect you directly to the `intellect` database.

### Method 4: Login with All Connection Details
```bash
mysql -h localhost -P 3306 -u root -p
```

---

## Using Your Project Credentials

Based on your `.env` file, use:

```bash
mysql -h localhost -P 3306 -u root -p
```

Or if you want to connect directly to the `intellect` database:

```bash
mysql -h localhost -P 3306 -u root -p intellect
```

**Note:** Replace `root` with your actual `DB_USER` if different, and enter your `DB_PASS` when prompted.

---

## Common MySQL Commands After Login

### Show All Databases
```sql
SHOW DATABASES;
```

### Use/Select a Database
```sql
USE intellect;
```

### Show All Tables
```sql
SHOW TABLES;
```

### Describe Table Structure
```sql
DESCRIBE users;
-- or
DESC users;
```

### View All Data in Users Table
```sql
SELECT * FROM users;
```

### View Specific Columns
```sql
SELECT id, email, name, isVerified, mpinSet FROM users;
```

### Count Users
```sql
SELECT COUNT(*) FROM users;
```

### Exit MySQL
```sql
EXIT;
-- or
QUIT;
-- or press Ctrl+D
```

---

## Troubleshooting

### Error: "Access denied for user 'root'@'localhost'"

**Solution 1:** Make sure you're using the correct password
```bash
mysql -u root -p
```

**Solution 2:** If you forgot the password, reset it:
```bash
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'your_new_password';
FLUSH PRIVILEGES;
EXIT;
```

**Solution 3:** Try without password (if MySQL allows it):
```bash
mysql -u root
```

### Error: "Can't connect to local MySQL server"

**Check if MySQL is running:**
```bash
# macOS
brew services list | grep mysql

# Or check process
ps aux | grep mysql
```

**Start MySQL:**
```bash
# macOS with Homebrew
brew services start mysql

# Or
sudo /usr/local/mysql/support-files/mysql.server start
```

### Error: "Unknown database 'intellect'"

**Create the database:**
```sql
CREATE DATABASE intellect;
```

---

## Quick Reference Commands

### Create Database
```sql
CREATE DATABASE intellect;
```

### Drop Database (Careful!)
```sql
DROP DATABASE intellect;
```

### Create Table (if needed manually)
```sql
CREATE TABLE users (
  id VARCHAR(36) PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(20) UNIQUE,
  name VARCHAR(255),
  otp VARCHAR(6),
  otpExpiry DATETIME,
  mpin VARCHAR(255),
  mpinSet BOOLEAN DEFAULT FALSE,
  isVerified BOOLEAN DEFAULT FALSE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### View Table Structure
```sql
SHOW CREATE TABLE users;
```

### Delete All Users (Testing)
```sql
DELETE FROM users;
```

### Reset Auto Increment (if using auto-increment IDs)
```sql
ALTER TABLE users AUTO_INCREMENT = 1;
```

---

## One-Line Commands (Without Interactive Shell)

### Execute SQL Command Directly
```bash
mysql -u root -pYOUR_PASSWORD -e "SHOW DATABASES;"
```

### Execute SQL File
```bash
mysql -u root -p intellect < script.sql
```

### Export Database
```bash
mysqldump -u root -p intellect > backup.sql
```

### Import Database
```bash
mysql -u root -p intellect < backup.sql
```

---

## Example Session

```bash
# 1. Login to MySQL
$ mysql -u root -p
Enter password: ********

# 2. You're now in MySQL prompt
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| intellect         |
| mysql              |
| performance_schema|
| sys                |
+--------------------+

mysql> USE intellect;
Database changed

mysql> SHOW TABLES;
+-------------------+
| Tables_in_intellect|
+-------------------+
| users             |
+-------------------+

mysql> SELECT * FROM users;
+----+-------------------+-------------+-----------+------+-----------+------+---------+------------+---------------------+---------------------+
| id | email             | phone       | name      | otp  | otpExpiry | mpin | mpinSet | isVerified | createdAt           | updatedAt           |
+----+-------------------+-------------+-----------+------+-----------+------+---------+------------+---------------------+---------------------+
| ...| john@example.com | +1234567890 | John Doe  | NULL | NULL      | ...  | 1       | 1          | 2025-11-11 01:00:00 | 2025-11-11 01:00:00 |
+----+-------------------+-------------+-----------+------+-----------+------+---------+------------+---------------------+---------------------+

mysql> EXIT;
Bye
```

---

## Security Tips

1. **Never put password in command line** - Use `-p` without password to be prompted
2. **Use strong passwords** - Especially for root user
3. **Create specific users** - Don't always use root for applications
4. **Limit privileges** - Grant only necessary permissions

---

## Creating Application User (Optional but Recommended)

Instead of using root, create a dedicated user:

```sql
-- Login as root first
mysql -u root -p

-- Create user
CREATE USER 'barber_app'@'localhost' IDENTIFIED BY 'secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON intellect.* TO 'barber_app'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

-- Test new user
EXIT;
mysql -u barber_app -p intellect
```

Then update your `.env`:
```
DB_USER=barber_app
DB_PASS=secure_password
```

