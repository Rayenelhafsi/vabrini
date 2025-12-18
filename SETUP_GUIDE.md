# Complete Setup Guide for Vabrini Attendance App

This guide shows you how to:
1. Import the SQL database into MySQL Workbench
2. Connect your Flutter app to the existing Node-RED flow (without changing Node-RED)
3. Make everything work together

---

## Part 1: Import SQL File into MySQL Workbench

### Step 1: Open MySQL Workbench
1. Launch **MySQL Workbench** on your computer
2. Connect to your MySQL server (usually `localhost` with your root password)

### Step 2: Create the Database
1. In MySQL Workbench, click on the **SQL Editor** tab (or press `Ctrl+Shift+E`)
2. In the query window, type:
   ```sql
   CREATE DATABASE IF NOT EXISTS absence CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
   USE absence;
   ```
3. Click the **Execute** button (lightning bolt icon) or press `Ctrl+Enter`
4. You should see "Query OK" messages

### Step 3: Import the SQL File
**Method 1: Using SQL Editor (Recommended)**
1. In MySQL Workbench, go to **File** → **Open SQL Script**
2. Navigate to your `fay9ni.sql` file (located at `C:\Users\mouhib\Desktop\vabrini\fay9ni.sql`)
3. Click **Open**
4. The SQL script will load in the editor
5. Make sure you're connected to the `absence` database (check the dropdown at the top)
6. Click **Execute** (lightning bolt) or press `Ctrl+Shift+Enter` to run the entire script
7. Wait for "Query OK" messages - this may take a few seconds

**Method 2: Using Data Import Wizard**
1. In MySQL Workbench, go to **Server** → **Data Import**
2. Select **Import from Self-Contained File**
3. Browse to `C:\Users\mouhib\Desktop\vabrini\fay9ni.sql`
4. Under **Default Target Schema**, select **absence** (or create it if it doesn't exist)
5. Click **Start Import**
6. Wait for the import to complete

### Step 4: Verify the Import
1. In MySQL Workbench, expand **Schemas** in the left panel
2. Expand **absence** database
3. You should see these tables:
   - `classe`
   - `departement`
   - `etudiant`
   - `matiere`
   - `presence`
   - `professeur`
   - `relation_prof_matiere_classe`
4. Right-click on any table → **Select Rows** to verify data exists

---

## Part 2: Node-RED Setup (No Changes Needed!)

Your existing `flows (2).json` already has:
- ✅ MySQL connection to `absence` database
- ✅ MQTT broker at `192.168.137.1:1883`
- ✅ Flow for professor data: `${prof_id}/give_me_class`
- ✅ Flow for class students: `this_is_the_class` → `<classe>/give_me_etudiant`
- ✅ Flow for student ID: `vabrih` → `vabrini`

**What you need to do:**
1. Import `flows (2).json` into Node-RED (if not already done)
2. Make sure MySQL node is configured to connect to `localhost:3306` with your MySQL credentials
3. Make sure MQTT broker is running at `192.168.137.1:1883`

---

## Part 3: How the App Works with Existing Node-RED

### Professor Login Flow:
1. **Flutter app**: User scans professor QR code → publishes professor ID to `vabrih` topic
2. **Node-RED**: Receives on `vabrih`, echoes to `vabrini`
3. **To get full professor data**: You need to manually trigger from Node-RED dashboard:
   - Open Node-RED dashboard
   - Click on a professor in the "Professors Table"
   - This triggers `function 1` which queries the database
   - Node-RED publishes JSON to `${prof_id}/give_me_class`
4. **Flutter app**: Already subscribed to `${prof_id}/give_me_class`, receives data and displays classes

### Student Login Flow:
1. **Flutter app**: User scans student QR code → publishes student ID to `vabrih` topic
2. **Node-RED**: Receives on `vabrih`, echoes to `vabrini`
3. **Note**: Your existing Node-RED flow doesn't calculate absences automatically. The app subscribes to `students/{studentId}/absences` but Node-RED doesn't publish there yet.

### Class Selection Flow:
1. **Flutter app**: Professor taps a class → publishes to `this_is_the_class` (now lowercase, matches Node-RED)
2. **Node-RED**: Receives on `this_is_the_class`, queries students in that class
3. **Node-RED**: Publishes student list to `<classe>/give_me_etudiant`
4. **Flutter app**: Currently shows static list, but can be extended to subscribe to `<classe>/give_me_etudiant`

---

## Part 4: Testing

### Test Database:
```sql
-- Check professors
SELECT * FROM professeur;

-- Check students
SELECT * FROM etudiant;

-- Check classes
SELECT * FROM classe;

-- Check professor-class relationships
SELECT p.name, p.prenom, c.classe_name, m.matiere_name
FROM professeur p
JOIN relation_prof_matiere_classe r ON p.idprof = r.prof_id
JOIN classe c ON r.class_id = c.idclasse
JOIN matiere m ON r.mati_id = m.idmatiere;
```

### Test MQTT Connection:
1. Make sure MQTT broker is running at `192.168.137.1:1883`
2. Run your Flutter app
3. Check Node-RED debug panel for MQTT messages

### Test Professor Flow:
1. Scan professor QR code (e.g., ID `1` for "Karoui Sami")
2. App navigates to Professor Interface
3. **Important**: Go to Node-RED dashboard and click on that professor in the "Professors Table"
4. App should receive data on `${prof_id}/give_me_class` and display classes

### Test Student Flow:
1. Scan student QR code (e.g., ID `1001` for "Hamdi Yassine")
2. App navigates to Student Interface
3. Currently shows empty absences (Node-RED doesn't calculate yet)

---

## Part 5: Important Notes

### Current Limitations (No Node-RED Changes):
1. **Professor login**: Requires manual trigger from Node-RED dashboard to get full data
2. **Student absences**: Node-RED doesn't automatically calculate and publish absences
3. **Add/Remove class**: Flutter publishes but Node-RED doesn't listen to these topics yet

### To Make Everything Fully Automatic:
You would need to add these flows to Node-RED (but you said no changes):
- MQTT in `professor/login` → trigger `function 1`
- MQTT in `student/login` → calculate absences → publish to `students/{id}/absences`

But since you want no Node-RED changes, the app works with the existing flow as described above.

---

## Troubleshooting

### Database Connection Issues:
- Check MySQL is running: `net start MySQL80` (Windows) or `sudo systemctl start mysql` (Linux)
- Verify credentials in Node-RED MySQL node
- Check database name is `absence` (not `faya9ni`)

### MQTT Connection Issues:
- Verify MQTT broker is running at `192.168.137.1:1883`
- Check firewall allows port 1883
- Test with MQTT client tool (like MQTT.fx)

### No Data in App:
- Check Node-RED debug panel for incoming messages
- Verify topic names match exactly (case-sensitive)
- Check MySQL queries return data

---

## Quick Reference: MQTT Topics Used

| Topic | Direction | Purpose |
|-------|-----------|---------|
| `vabrih` | Flutter → Node-RED | Student/Professor ID (login) |
| `vabrini` | Node-RED → Flutter | Echo of ID |
| `${prof_id}/give_me_class` | Node-RED → Flutter | Professor classes data |
| `this_is_the_class` | Flutter → Node-RED | Class selection |
| `<classe>/give_me_etudiant` | Node-RED → Flutter | Students in class |
| `students/{id}/absences` | Node-RED → Flutter | Student absences (not implemented yet) |

---

**You're all set!** The app will work with your existing Node-RED flow. Just remember to trigger professor data from the Node-RED dashboard after login.



