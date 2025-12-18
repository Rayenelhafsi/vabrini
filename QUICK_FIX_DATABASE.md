# Quick Fix: Node-RED Database Connection

## ⚡ 5-Minute Fix Guide

### Step 1: Check MySQL is Running (30 seconds)

**Windows Command Prompt:**
```cmd
net start MySQL80
```

**If it says "already started"** → MySQL is running ✅
**If it says "service started"** → MySQL is now running ✅
**If it says "access denied"** → Run Command Prompt as Administrator

### Step 2: Verify Database Exists (1 minute)

1. Open **MySQL Workbench**
2. Connect (enter your root password)
3. In left panel, look for **`absence`** database
4. If you see it → ✅ Database exists
5. If you DON'T see it → Import `fay9ni.sql` first (see `MYSQL_WORKBENCH_IMPORT.md`)

### Step 3: Test MySQL Works (1 minute)

**In MySQL Workbench SQL Editor:**
```sql
USE absence;
SELECT * FROM professeur;
```

**If you see professor data** → ✅ MySQL works perfectly!
**If you see error** → Database doesn't exist or wrong name

### Step 4: Fix Node-RED MySQL Node (2 minutes)

1. Open Node-RED: `http://localhost:1880`

2. Find **ALL MySQL nodes** (they have a database icon 📊)

3. For EACH MySQL node:
   - **Double-click** the node
   - Click the **pencil icon** (✏️) next to "Database" dropdown
   - Enter these EXACT values:
     ```
     Host: localhost
     Port: 3306
     Database: absence
     User ID: root
     Password: [YOUR MYSQL ROOT PASSWORD]
     ```
   - Click **Update**
   - Click **Done**

4. Click **Deploy** button (top right corner)

### Step 5: Test Connection (30 seconds)

1. In Node-RED, create a quick test:
   - Drag **inject** node
   - Drag **MySQL** node  
   - Drag **debug** node
   - Connect them: inject → MySQL → debug

2. Configure MySQL node:
   - Database: Select your configured `absence` database
   - Operation: `query`
   - SQL Query: `SELECT * FROM professeur LIMIT 1`

3. Click **Deploy**
4. Click the **inject button** (left side of inject node)
5. Check **debug panel** (right sidebar)

**✅ SUCCESS:** You see professor data in debug panel
**❌ ERROR:** See troubleshooting below

---

## 🔧 Common Errors & Fixes

### Error: "Access denied for user 'root'@'localhost'"

**Problem:** Wrong password

**Fix:**
1. Open MySQL Workbench
2. Try connecting with your password
3. If MySQL Workbench works, use the SAME password in Node-RED
4. If MySQL Workbench doesn't work, reset MySQL password

### Error: "Unknown database 'absence'"

**Problem:** Database doesn't exist or wrong name

**Fix:**
1. In MySQL Workbench, run:
   ```sql
   SHOW DATABASES;
   ```
2. Look for `absence` in the list
3. If it's not there:
   ```sql
   CREATE DATABASE absence;
   ```
4. Then import `fay9ni.sql` (see `MYSQL_WORKBENCH_IMPORT.md`)

### Error: "Can't connect to MySQL server"

**Problem:** MySQL not running or wrong host

**Fix:**
1. Make sure MySQL is running: `net start MySQL80`
2. Check host is `localhost` (not `127.0.0.1` or IP address)
3. Try `127.0.0.1` instead of `localhost` if needed

### Error: Node shows red dot or "disconnected"

**Problem:** Connection failed

**Fix:**
1. Double-check all settings in MySQL node config
2. Make sure you clicked **Update** and **Done**
3. Click **Deploy** after making changes
4. Check Node-RED debug panel for exact error message

---

## ✅ Verification Checklist

Before testing your app, make sure:

- [ ] MySQL service is running (`net start MySQL80`)
- [ ] Database `absence` exists (check in MySQL Workbench)
- [ ] Can query data in MySQL Workbench (`SELECT * FROM professeur;`)
- [ ] All MySQL nodes in Node-RED are configured
- [ ] Test query in Node-RED returns data
- [ ] Clicked **Deploy** in Node-RED

---

## 🚀 Once Database Works, Test Your App

1. **Start MQTT broker:**
   ```cmd
   mosquitto -c mosquitto.conf
   ```

2. **Start Node-RED** (if not already running)

3. **Run Flutter app**

4. **Test Professor Login:**
   - Scan professor ID (e.g., `1`)
   - Go to Node-RED dashboard
   - Click professor in "Professors Table"
   - Flutter app should show classes

5. **Test Student Login:**
   - Scan student ID (e.g., `1001`)
   - Should show student interface

---

## 📞 Still Not Working?

**Get the exact error:**
1. In Node-RED, check **debug panel** (right sidebar)
2. Look for red error messages
3. Copy the exact error text
4. Check Node-RED terminal/console for more details

**Most common issue:** Wrong password or database name

**Quick test:**
- If MySQL Workbench works → Problem is Node-RED config
- If MySQL Workbench doesn't work → Problem is MySQL itself

---

**Follow these steps in order - the database connection will work!** 🎯


