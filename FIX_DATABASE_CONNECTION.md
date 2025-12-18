# Fix "Database Not Connected" Error in Node-RED

This guide will help you fix the MySQL database connection issue in Node-RED.

---

## Step 1: Verify MySQL is Running

### On Windows:
1. Open **Command Prompt** as Administrator
2. Run: `net start MySQL80` (or `MySQL` if your service name is different)
3. If it says "The requested service has already been started", MySQL is running ✅

### On Linux/Mac:
```bash
sudo systemctl status mysql
# or
sudo service mysql status
```

If MySQL is not running, start it:
```bash
sudo systemctl start mysql
# or
sudo service mysql start
```

---

## Step 2: Verify Database Exists

1. Open **MySQL Workbench**
2. Connect to your MySQL server
3. In the left panel, check if you see the **`absence`** database
4. If you don't see it, you need to import the SQL file first (see `MYSQL_WORKBENCH_IMPORT.md`)

---

## Step 3: Test MySQL Connection from Command Line

### On Windows (Command Prompt):
```cmd
mysql -u root -p
```
Enter your MySQL root password when prompted.

If this works, you'll see `mysql>` prompt. Type:
```sql
USE absence;
SHOW TABLES;
```
You should see 7 tables. Type `exit;` to quit.

If you get "Access denied" or "Can't connect", your MySQL credentials are wrong.

---

## Step 4: Configure MySQL Node in Node-RED

### Find the MySQL Node:
1. Open **Node-RED** in your browser (usually `http://localhost:1880`)
2. Look for any **MySQL** nodes in your flow (they have a database icon)
3. Double-click on a MySQL node to open its configuration

### Configure the Connection:
1. Click the **pencil icon** (✏️) next to "Database" dropdown
2. A configuration window will open

### Enter These Settings:

**Server:**
- **Host**: `localhost` (or `127.0.0.1`)
- **Port**: `3306` (default MySQL port)

**Database:**
- **Database**: `absence` (exactly this name, case-sensitive)

**User:**
- **User ID**: `root` (or your MySQL username)
- **Password**: Your MySQL root password

**Other Settings:**
- **Connection timeout**: `10000` (10 seconds)
- **Keep connection alive**: ✅ Check this box

3. Click **Update** to save the configuration
4. Click **Done** to close the node configuration

---

## Step 5: Test the Connection

1. In Node-RED, click the **Deploy** button (top right)
2. Look at the **debug panel** (right sidebar) for any error messages
3. If you see "Database not connected" or similar errors, continue to Step 6

---

## Step 6: Common Issues and Solutions

### Issue 1: "Access denied for user"
**Problem**: Wrong username or password

**Solution**:
1. Verify your MySQL root password in MySQL Workbench
2. Update the MySQL node configuration with correct credentials
3. Make sure you're using `root` as username (or your actual MySQL username)

### Issue 2: "Unknown database 'absence'"
**Problem**: Database doesn't exist or wrong name

**Solution**:
1. Open MySQL Workbench
2. Check if database is named `absence` (not `faya9ni` or `fay9ni`)
3. If it doesn't exist, create it:
   ```sql
   CREATE DATABASE absence;
   ```
4. Then import your `fay9ni.sql` file (see `MYSQL_WORKBENCH_IMPORT.md`)

### Issue 3: "Can't connect to MySQL server"
**Problem**: MySQL service not running or wrong host/port

**Solution**:
1. Make sure MySQL is running (Step 1)
2. Check the host is `localhost` (not `192.168.137.1`)
3. Check the port is `3306` (default MySQL port)
4. Try `127.0.0.1` instead of `localhost` if `localhost` doesn't work

### Issue 4: "Connection timeout"
**Problem**: MySQL is slow to respond or firewall blocking

**Solution**:
1. Increase timeout to `30000` (30 seconds)
2. Check Windows Firewall isn't blocking MySQL
3. Make sure MySQL is actually running

### Issue 5: Node-RED can't find MySQL node module
**Problem**: `node-red-node-mysql` package not installed

**Solution**:
1. In Node-RED, go to **Menu** (☰) → **Manage palette**
2. Click **Install** tab
3. Search for: `node-red-node-mysql`
4. Click **Install**
5. Wait for installation, then **Deploy**

---

## Step 7: Verify Connection Works

### Test with a Simple Query:
1. In Node-RED, add an **inject** node
2. Add a **MySQL** node
3. Configure MySQL node (use the same config from Step 4)
4. In MySQL node, set **Operation** to: `query`
5. Set **SQL Query** to: `SELECT * FROM professeur LIMIT 1`
6. Add a **debug** node
7. Connect: inject → MySQL → debug
8. Click **Deploy**
9. Click the inject button (left side of inject node)
10. Check debug panel - you should see professor data

If you see data, your connection works! ✅

---

## Step 8: Update All MySQL Nodes

Your `flows (2).json` has multiple MySQL nodes. You need to configure ALL of them:

1. Look for all MySQL nodes in your flow (they have a database icon)
2. Double-click each one
3. Make sure they all use the same database configuration:
   - Database: `absence`
   - Host: `localhost`
   - Port: `3306`
   - User: `root` (or your MySQL username)
   - Password: Your MySQL password

4. Click **Done** on each node
5. Click **Deploy**

---

## Quick Checklist

Before asking for help, verify:
- [ ] MySQL service is running
- [ ] Database `absence` exists in MySQL Workbench
- [ ] You can connect to MySQL from command line
- [ ] All MySQL nodes in Node-RED are configured with:
  - [ ] Host: `localhost`
  - [ ] Port: `3306`
  - [ ] Database: `absence`
  - [ ] Correct username and password
- [ ] `node-red-node-mysql` package is installed
- [ ] You clicked **Deploy** after making changes

---

## Still Not Working?

### Get More Details:
1. In Node-RED, check the **debug panel** for exact error messages
2. Check Node-RED logs (usually in terminal where you started Node-RED)
3. Try connecting from MySQL Workbench with the same credentials

### Common Error Messages:

**"ER_ACCESS_DENIED_ERROR"**
→ Wrong username or password

**"ER_BAD_DB_ERROR"**
→ Database `absence` doesn't exist

**"ECONNREFUSED"**
→ MySQL service not running or wrong host/port

**"ETIMEDOUT"**
→ MySQL is too slow or firewall blocking

---

## Alternative: Test Connection from MySQL Workbench First

1. Open MySQL Workbench
2. Create a new connection:
   - Connection Name: `Test`
   - Hostname: `localhost`
   - Port: `3306`
   - Username: `root`
   - Password: (your password)
3. Click **Test Connection**
4. If this works, use the same credentials in Node-RED
5. If this doesn't work, fix MySQL first before configuring Node-RED

---

**Once the connection works, your Node-RED flows will be able to query the database!** 🎉



