# Complete Application Testing Guide

Now that everything is connected, let's test your entire application step-by-step!

---

## Prerequisites Checklist

Before testing, make sure:

- [x] ✅ MySQL is running and connected
- [x] ✅ Database `absence` has data
- [x] ✅ Node-RED is running with flows deployed
- [x] ✅ MQTT broker is running
- [x] ✅ All MySQL nodes in Node-RED are configured and working
- [x] ✅ Flutter app compiles without errors

---

## Part 1: Prepare Test Data

### Get Test IDs from Database

**Open MySQL Workbench and run:**

```sql
USE absence;

-- Get Professor IDs
SELECT idprof, name, prenom FROM professeur;
-- Example: idprof = 1 (Karoui Sami)

-- Get Student IDs (carte_id is what you scan)
SELECT idetudiant, nom, prenom, carte_id FROM etudiant;
-- Example: carte_id = 1001 (Hamdi Yassine)
```

**Write down:**
- Professor ID: `1` (or any professor ID)
- Student ID: `1001` (or any student carte_id)

---

## Part 2: Start All Services

### Terminal 1: MySQL (if not running as service)
```cmd
net start MySQL80
```

### Terminal 2: MQTT Broker
```cmd
mosquitto -c mosquitto.conf
```
Or if using Node-RED built-in broker, make sure it's deployed.

### Terminal 3: Node-RED
```cmd
node-red
```
Or if already running, just open `http://localhost:1880`

### Terminal 4: Flutter App
```cmd
cd C:\Users\mouhib\Desktop\vabrini\vabrini
flutter run
```

**All services should be running now!** ✅

---

## Part 3: Test Professor Login Flow

### Step 1: Open Flutter App
1. Launch your Flutter app (on emulator or phone)
2. You should see the **Login Screen** with:
   - Radio buttons: Professor / Student
   - "Scan QR Code" button
   - "Login" button

### Step 2: Login as Professor
1. Select **Professor** (radio button)
2. Click **"Scan QR Code"** button
3. **Option A:** If you have a QR code, scan it
   **Option B:** For testing, you can manually enter the ID:
   - The scanner might allow manual entry, or
   - You'll need to create a QR code with the professor ID
4. Enter professor ID: `1` (or your test professor ID)
5. You should see: **"Scanned ID: 1"**
6. Click **"Login"** button

### Step 3: Verify MQTT Connection
1. Check Flutter console/logs - should see "Connected"
2. Check Node-RED debug panel - should see message on `vabrih` topic
3. App should navigate to **Professor Interface**

### Step 4: Load Professor Data
**Important:** Your Node-RED flow requires manual trigger from dashboard!

1. Open Node-RED dashboard: `http://localhost:1880/ui`
2. Go to **"Professors"** tab/group
3. You should see a table with professors
4. **Click on the professor** you logged in with (e.g., "Karoui Sami")
5. This triggers the database query

### Step 5: Verify Data in Flutter App
1. Go back to your Flutter app
2. In **Professor Interface**, you should see:
   - Professor name at the top
   - Grid of class cards showing:
     - Class name (e.g., "IOT3A")
     - Subject (e.g., "Microcontrollers")
3. If you see classes → **✅ Professor flow works!**

---

## Part 4: Test Class Selection

### Step 1: Select a Class
1. In Professor Interface, **tap on a class card**
2. App should navigate to **Class Students Screen**

### Step 2: Verify MQTT Message
1. Check Node-RED debug panel
2. Should see message on `this_is_the_class` topic with:
   ```json
   {
     "idprof": "1",
     "classe_name": "IOT3A",
     "matiere_name": "Microcontrollers"
   }
   ```

### Step 3: Verify Students List
1. In Class Students Screen, you should see:
   - App bar: "IOT3A - Microcontrollers"
   - List of students (currently static, shows "Absent" for each)
2. Check Node-RED - it should query students and publish to `<classe>/give_me_etudiant`

**✅ Class selection works!**

---

## Part 5: Test Student Login Flow

### Step 1: Go Back to Login
1. Close the app or navigate back to Login Screen
2. Select **Student** (radio button)

### Step 2: Login as Student
1. Click **"Scan QR Code"**
2. Enter student ID: `1001` (or your test student carte_id)
3. You should see: **"Scanned ID: 1001"**
4. Click **"Login"** button

### Step 3: Verify Student Interface
1. App should navigate to **Student Interface**
2. You should see:
   - App bar: "Student - 1001"
   - Card showing "Total Absences: 0" (or actual count)
   - List of subjects with absence counts (if data exists)

**Note:** Currently, Node-RED doesn't automatically calculate absences, so the list might be empty. This is expected.

**✅ Student login works!**

---

## Part 6: Test Add Class (Professor)

### Step 1: Go to Professor Interface
1. Login as professor (from Part 3)

### Step 2: Add a New Class
1. Click the **+ (plus)** floating action button
2. Dialog should open:
   - "Class Name" field
   - "Subject" field
3. Enter:
   - Class Name: `TEST_CLASS`
   - Subject: `Test Subject`
4. Click **"Add"** button

### Step 3: Verify
1. Check Node-RED debug panel
2. Should see message on `professor/{prof_id}/addClass` topic
3. **Note:** Your Node-RED flow doesn't handle this yet, but the message is sent

**✅ Add class button works!**

---

## Part 7: Test Delete Mode (Professor)

### Step 1: Enable Delete Mode
1. In Professor Interface, click the **trash/delete** floating action button
2. Class cards should change appearance (might show delete icon)

### Step 2: Delete a Class
1. Tap on a class card
2. Check Node-RED debug panel
3. Should see message on `professor/{prof_id}/removeClass` topic with class name

**✅ Delete mode works!**

---

## Part 8: Complete End-to-End Test

### Full Flow Test:

1. **Start Fresh:**
   - Close Flutter app
   - Restart if needed

2. **Professor Login:**
   - Login as professor (ID: `1`)
   - Go to Node-RED dashboard, click professor
   - Verify classes appear

3. **Select Class:**
   - Tap a class
   - Verify students screen opens
   - Check Node-RED receives `this_is_the_class` message

4. **Go Back:**
   - Navigate back to professor interface

5. **Student Login:**
   - Go back to login
   - Login as student (ID: `1001`)
   - Verify student interface shows

6. **Test Add/Delete:**
   - Go back to professor
   - Test add class
   - Test delete mode

---

## Troubleshooting During Testing

### Issue: Flutter app shows "Connecting to MQTT..."
**Fix:**
- Check MQTT broker is running
- Check Flutter `mqtt.dart` uses correct IP (`localhost` or your IP)
- Check Node-RED MQTT broker config matches

### Issue: Professor data doesn't load
**Fix:**
- Make sure you clicked professor in Node-RED dashboard
- Check Node-RED debug panel for `${prof_id}/give_me_class` message
- Verify MySQL query returns data

### Issue: No classes appear
**Fix:**
- Check Node-RED debug panel for errors
- Verify professor has classes in database:
  ```sql
  SELECT p.name, c.classe_name, m.matiere_name
  FROM professeur p
  JOIN relation_prof_matiere_classe r ON p.idprof = r.prof_id
  JOIN classe c ON r.class_id = c.idclasse
  JOIN matiere m ON r.mati_id = m.idmatiere
  WHERE p.idprof = 1;
  ```

### Issue: Can't scan QR code
**Fix:**
- For testing, you might need to create QR codes
- Or modify the app to allow manual ID entry
- Or use a QR code generator online with the ID

### Issue: App crashes or freezes
**Fix:**
- Check Flutter console for errors
- Check Node-RED debug panel for MQTT errors
- Verify all services are running

---

## Expected Results Summary

### ✅ Successful Test Results:

1. **Login Screen:**
   - Can select Professor/Student
   - Can scan/enter ID
   - Can login

2. **Professor Interface:**
   - Shows professor name
   - Shows classes grid (after clicking in Node-RED dashboard)
   - Can tap classes to open students
   - Can add/delete classes

3. **Class Students Screen:**
   - Shows class name and subject
   - Shows list of students
   - Node-RED receives `this_is_the_class` message

4. **Student Interface:**
   - Shows student ID
   - Shows total absences
   - Shows subject list (if data exists)

5. **MQTT Communication:**
   - Flutter publishes to `vabrih` on login
   - Node-RED receives messages
   - Node-RED publishes to `${prof_id}/give_me_class`
   - Flutter receives and displays data

---

## Quick Test Checklist

Run through this checklist:

- [ ] Flutter app opens and shows login screen
- [ ] Can select Professor/Student
- [ ] Can scan/enter ID and login
- [ ] Professor interface appears after login
- [ ] Click professor in Node-RED dashboard
- [ ] Classes appear in Flutter app
- [ ] Can tap a class to see students
- [ ] Can login as student
- [ ] Student interface shows
- [ ] MQTT messages appear in Node-RED debug panel
- [ ] No errors in Flutter console
- [ ] No errors in Node-RED debug panel

---

## Next Steps After Testing

Once everything works:

1. **Create Real QR Codes:**
   - Generate QR codes for each professor and student
   - Use their IDs from the database

2. **Test on Real Device:**
   - Install Flutter app on phone/tablet
   - Update MQTT IP to your computer's IP (not `localhost`)
   - Test with real QR codes

3. **Add Missing Features (Optional):**
   - Student absences calculation in Node-RED
   - Real-time student list updates
   - Add/remove class functionality in Node-RED

---

## Test Data Reference

**Quick reference for testing:**

```sql
-- Professors
idprof = 1 → Karoui Sami
idprof = 2 → Ben Ali Mouna
idprof = 3 → Trabelsi Omar

-- Students (use carte_id for scanning)
carte_id = 1001 → Hamdi Yassine
carte_id = 1002 → Gharbi Nour
carte_id = 2001 → Sassi Malek
carte_id = 2002 → Ayadi Ahmed

-- Classes
IOT3A, GLSI3B

-- Subjects
Microcontrollers, IoT Networks, Web Development, Databases, Embedded Linux
```

---

**Follow these steps and your application will be fully tested!** 🎉

Start with Part 3 (Professor Login) - that's the main flow. Good luck! 🚀


