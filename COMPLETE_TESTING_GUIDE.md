# Complete Testing Guide - Fix Database Connection & Test Everything

This guide will help you:
1. ✅ Fix Node-RED database connection
2. ✅ Test each component step-by-step
3. ✅ Verify the entire application works

---

## Part 1: Fix Database Connection in Node-RED

### Step 1: Verify MySQL is Running

**Windows:**
```cmd
net start MySQL80
```
If it says "already started", MySQL is running ✅

**Check if MySQL is listening:**
```cmd
netstat -an | findstr :3306
```
You should see `0.0.0.0:3306` or `127.0.0.1:3306`

### Step 2: Verify Database Exists

1. Open **MySQL Workbench**
2. Connect to your server
3. In left panel, check if **`absence`** database exists
4. If not, import `fay9ni.sql` (see `MYSQL_WORKBENCH_IMPORT.md`)

### Step 3: Test MySQL Connection Manually

**In MySQL Workbench:**
1. Click **SQL Editor** tab
2. Type:
   ```sql
   USE absence;
   SELECT * FROM professeur LIMIT 1;
   ```
3. Click **Execute** (⚡)
4. You should see professor data

**If this works, MySQL is fine!** ✅

### Step 4: Configure Node-RED MySQL Node

1. Open Node-RED (`http://localhost:1880`)
2. Find **ALL MySQL nodes** in your flow (database icon)
3. For EACH MySQL node:
   - Double-click to open
   - Click **pencil icon** (✏️) next to "Database"
   - Configure:
     - **Host**: `localhost`
     - **Port**: `3306`
     - **Database**: `absence` (exact name, case-sensitive)
     - **User ID**: `root` (or your MySQL username)
     - **Password**: Your MySQL root password
   - Click **Update** → **Done**

4. Click **Deploy** button (top right)

### Step 5: Test MySQL Node Directly

1. In Node-RED, create a simple test flow:
   - Drag **inject** node
   - Drag **MySQL** node
   - Drag **debug** node
   - Connect: inject → MySQL → debug

2. Configure MySQL node:
   - Database: Your configured `absence` database
   - Operation: `query`
   - SQL Query: `SELECT * FROM professeur LIMIT 1`

3. Click **Deploy**
4. Click the inject button (left side)
5. Check **debug panel** (right sidebar)

**Expected Result:** You should see professor data in debug panel

**If you see data:** Database connection works! ✅
**If you see error:** Continue to troubleshooting below

---

## Part 2: Troubleshooting Database Connection

### Error: "Access denied for user 'root'@'localhost'"

**Fix:**
1. Verify MySQL root password in MySQL Workbench
2. Try connecting in MySQL Workbench with same credentials
3. If MySQL Workbench works but Node-RED doesn't:
   - Check password has no special characters that need escaping
   - Try creating a new MySQL user for Node-RED:
     ```sql
     CREATE USER 'nodered'@'localhost' IDENTIFIED BY 'your_password';
     GRANT ALL PRIVILEGES ON absence.* TO 'nodered'@'localhost';
     FLUSH PRIVILEGES;
     ```
   - Use `nodered` / `your_password` in Node-RED

### Error: "Unknown database 'absence'"

**Fix:**
1. Check database name is exactly `absence` (not `faya9ni` or `fay9ni`)
2. In MySQL Workbench, run:
   ```sql
   SHOW DATABASES;
   ```
3. If `absence` doesn't exist, create it:
   ```sql
   CREATE DATABASE absence;
   ```
4. Then import `fay9ni.sql` again

### Error: "Can't connect to MySQL server"

**Fix:**
1. Make sure MySQL service is running
2. Check host is `localhost` (not `127.0.0.1` or IP address)
3. Check port is `3306`
4. Try `127.0.0.1` instead of `localhost` if `localhost` doesn't work

### Error: "Connection timeout"

**Fix:**
1. Increase timeout in MySQL node config to `30000` (30 seconds)
2. Check Windows Firewall isn't blocking MySQL
3. Verify MySQL is actually running

### Still Not Working? Get Exact Error

1. In Node-RED, check **debug panel** for exact error message
2. Check Node-RED logs (terminal where you started Node-RED)
3. Try this test query in MySQL Workbench:
   ```sql
   SELECT * FROM absence.professeur;
   ```
   If this works, the issue is Node-RED configuration, not MySQL

---

## Part 3: Test MQTT Connection

### Step 1: Start MQTT Broker

**If using Mosquitto:**
```cmd
mosquitto -c mosquitto.conf
```

**If using Node-RED built-in broker:**
- Make sure aedes broker node is deployed

### Step 2: Test MQTT from Command Line

**Terminal 1 (Subscribe):**
```bash
mosquitto_sub -h localhost -p 1883 -t test -v
```

**Terminal 2 (Publish):**
```bash
mosquitto_pub -h localhost -p 1883 -t test -m "Hello MQTT"
```

**Expected:** You should see "Hello MQTT" in Terminal 1

### Step 3: Test MQTT in Node-RED

1. Create test flow:
   - **inject** → **MQTT out** (topic: `test`, broker: your configured broker)
   - **MQTT in** (topic: `test`, broker: same) → **debug**

2. Click **Deploy**
3. Click inject button
4. Check debug panel - should see message

---

## Part 4: Test Complete Application Flow

### Test 1: Professor Login Flow

**Step 1: Prepare**
1. Make sure MySQL is running
2. Make sure MQTT broker is running
3. Make sure Node-RED is running with flows deployed
4. Database connection works (tested in Part 1)

**Step 2: Get Professor ID**
1. In MySQL Workbench:
   ```sql
   USE absence;
   SELECT idprof, name, prenom FROM professeur;
   ```
2. Note a professor ID (e.g., `1` for "Karoui Sami")

**Step 3: Test in Node-RED**
1. In Node-RED, find the flow that handles professor data
2. Look for `function 1` node (queries professor data)
3. Manually trigger it or use inject node with professor ID
4. Check debug panel - should see professor data

**Step 4: Test from Flutter App**
1. Run Flutter app
2. Select "Professor"
3. Scan QR code with professor ID (or manually enter ID)
4. Click "Login"
5. App should navigate to Professor Interface
6. **Important:** Go to Node-RED dashboard, click on that professor in "Professors Table"
7. Flutter app should receive data on `${prof_id}/give_me_class` topic
8. Classes should appear in the app

### Test 2: Student Login Flow

**Step 1: Get Student ID**
```sql
USE absence;
SELECT idetudiant, nom, prenom, carte_id FROM etudiant;
```
Note a student ID (e.g., `1001` for "Hamdi Yassine")

**Step 2: Test from Flutter**
1. Run Flutter app
2. Select "Student"
3. Scan QR code with student ID
4. Click "Login"
5. App should navigate to Student Interface
6. Currently shows empty absences (Node-RED doesn't calculate yet)

### Test 3: Class Selection Flow

**Step 1: From Professor Interface**
1. After professor login and data loads
2. Tap on a class card
3. App should navigate to ClassStudentsScreen
4. Check Node-RED debug panel - should see message on `this_is_the_class` topic

**Step 2: Verify Node-RED Receives**
1. In Node-RED, check debug panel
2. Should see message with `classe_name` and `matiere_name`
3. Node-RED should query students and publish to `<classe>/give_me_etudiant`

---

## Part 5: Complete System Checklist

Before testing, verify everything:

### ✅ Database
- [ ] MySQL service is running
- [ ] Database `absence` exists
- [ ] Tables have data (check in MySQL Workbench)
- [ ] Can query data manually in MySQL Workbench
- [ ] Node-RED MySQL nodes are configured correctly
- [ ] Test query in Node-RED works (returns data)

### ✅ MQTT Broker
- [ ] MQTT broker is running
- [ ] Can publish/subscribe from command line
- [ ] Node-RED MQTT nodes are configured
- [ ] Test MQTT flow in Node-RED works

### ✅ Node-RED
- [ ] Node-RED is running
- [ ] All flows are deployed
- [ ] No red error indicators on nodes
- [ ] MySQL nodes show green (connected)
- [ ] MQTT nodes show green (connected)

### ✅ Flutter App
- [ ] App compiles without errors
- [ ] MQTT connection works (check logs)
- [ ] Can scan QR codes
- [ ] Can navigate between screens

---

## Part 6: Step-by-Step Complete Test

### Full End-to-End Test:

**1. Start Everything:**
```cmd
# Terminal 1: MySQL (if not running as service)
net start MySQL80

# Terminal 2: MQTT Broker
mosquitto -c mosquitto.conf

# Terminal 3: Node-RED
node-red
```

**2. Verify Connections:**
- MySQL Workbench: Connect and query `SELECT * FROM professeur;`
- Node-RED: Test MySQL node returns data
- MQTT: Test publish/subscribe works

**3. Test Professor Flow:**
1. Open Flutter app
2. Select Professor
3. Scan/enter professor ID: `1`
4. Click Login
5. In Node-RED dashboard, click professor in "Professors Table"
6. Flutter app should show classes

**4. Test Class Selection:**
1. In Flutter app, tap a class
2. Should navigate to students screen
3. Check Node-RED debug - should see `this_is_the_class` message

**5. Test Student Flow:**
1. Go back to login
2. Select Student
3. Scan/enter student ID: `1001`
4. Click Login
5. Should show student interface (absences empty for now)

---

## Part 7: Common Issues & Quick Fixes

### Issue: "Database not connected" in Node-RED

**Quick Fix:**
1. Check MySQL is running: `net start MySQL80`
2. Verify database exists: `SHOW DATABASES;` in MySQL Workbench
3. Test connection in MySQL Workbench with same credentials
4. Update MySQL node in Node-RED:
   - Host: `localhost`
   - Port: `3306`
   - Database: `absence`
   - User: `root`
   - Password: (your MySQL password)
5. Click **Deploy**

### Issue: MQTT not connecting

**Quick Fix:**
1. Start MQTT broker
2. Test with: `mosquitto_sub -h localhost -p 1883 -t test`
3. Update Flutter `mqtt.dart` to use `localhost:1883`
4. Update Node-RED MQTT broker config to `localhost:1883`

### Issue: No data in Flutter app

**Quick Fix:**
1. Check Node-RED debug panel for incoming messages
2. Verify topic names match exactly (case-sensitive)
3. Check MySQL queries return data
4. Make sure flows are deployed in Node-RED

### Issue: Professor data doesn't load

**Quick Fix:**
1. After login, manually trigger from Node-RED dashboard
2. Click professor in "Professors Table"
3. This triggers `function 1` which queries database
4. Data should appear in Flutter app

---

## Part 8: Debugging Tips

### Enable Debugging:

**In Node-RED:**
1. Add **debug** nodes after each important step
2. Check debug panel for message flow
3. Look for error messages

**In Flutter:**
1. Check console/logs for MQTT connection status
2. Print statements show what's happening
3. Check if `mqttService.isConnected` is true

**In MySQL:**
1. Test queries directly in MySQL Workbench
2. Verify data exists before testing in Node-RED

### Check Message Flow:

1. **Flutter publishes** → Check Flutter logs
2. **MQTT broker receives** → Test with `mosquitto_sub`
3. **Node-RED receives** → Check Node-RED debug panel
4. **Node-RED queries MySQL** → Check MySQL node output
5. **Node-RED publishes** → Check MQTT out node
6. **Flutter receives** → Check Flutter logs

---

## Quick Reference: Test Commands

```sql
-- Test MySQL
USE absence;
SELECT * FROM professeur;
SELECT * FROM etudiant;
```

```bash
# Test MQTT
mosquitto_sub -h localhost -p 1883 -t test -v
mosquitto_pub -h localhost -p 1883 -t test -m "test"
```

```cmd
# Check services
net start MySQL80
netstat -an | findstr :3306
netstat -an | findstr :1883
```

---

**Follow this guide step-by-step, and your application will work!** 🎯

Start with Part 1 (Fix Database Connection) - that's usually the main issue.


