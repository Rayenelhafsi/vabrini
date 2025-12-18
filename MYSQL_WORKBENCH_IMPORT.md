# How to Import fay9ni.sql into MySQL Workbench

## Quick Visual Guide

### Method 1: Using SQL Editor (Easiest)

1. **Open MySQL Workbench** and connect to your server
   - Enter your root password
   - Click "OK"

2. **Create the database** (if it doesn't exist):
   - Click on the **SQL Editor** tab (or press `Ctrl+Shift+E`)
   - Type this in the query window:
     ```sql
     CREATE DATABASE IF NOT EXISTS absence;
     USE absence;
     ```
   - Click the **Execute** button (⚡ lightning bolt) or press `Ctrl+Enter`

3. **Open your SQL file**:
   - Go to **File** → **Open SQL Script...**
   - Navigate to: `C:\Users\mouhib\Desktop\vabrini\fay9ni.sql`
   - Click **Open**

4. **Execute the script**:
   - Make sure `absence` is selected in the schema dropdown (top left)
   - Click **Execute** (⚡) or press `Ctrl+Shift+Enter`
   - Wait for "Query OK" messages

5. **Verify import**:
   - In the left panel, expand **Schemas** → **absence**
   - You should see 7 tables:
     - `classe`
     - `departement`
     - `etudiant`
     - `matiere`
     - `presence`
     - `professeur`
     - `relation_prof_matiere_classe`

---

### Method 2: Using Data Import Wizard

1. **Open Data Import**:
   - Go to **Server** → **Data Import**

2. **Select import source**:
   - Choose **Import from Self-Contained File**
   - Click **Browse...** and select `fay9ni.sql`

3. **Select target schema**:
   - Under **Default Target Schema**, click **New...**
   - Name it: `absence`
   - Click **OK**

4. **Start import**:
   - Click **Start Import** button
   - Wait for "Import completed successfully"

---

## Verify Your Data

Run these queries to check your data:

```sql
-- Check professors
SELECT idprof, name, prenom FROM professeur;
-- Should show: Karoui Sami, Ben Ali Mouna, Trabelsi Omar

-- Check students
SELECT idetudiant, nom, prenom, carte_id FROM etudiant;
-- Should show: Hamdi Yassine (1001), Gharbi Nour (1002), etc.

-- Check classes
SELECT * FROM classe;
-- Should show: IOT3A, GLSI3B

-- Check professor-class relationships
SELECT 
    p.name, 
    p.prenom, 
    c.classe_name, 
    m.matiere_name
FROM professeur p
JOIN relation_prof_matiere_classe r ON p.idprof = r.prof_id
JOIN classe c ON r.class_id = c.idclasse
JOIN matiere m ON r.mati_id = m.idmatiere;
```

---

## Troubleshooting

### Error: "Unknown database 'absence'"
**Solution**: Create the database first:
```sql
CREATE DATABASE absence;
USE absence;
```

### Error: "Table already exists"
**Solution**: The SQL file has `DROP TABLE IF EXISTS`, so this shouldn't happen. If it does:
```sql
DROP DATABASE IF EXISTS absence;
CREATE DATABASE absence;
USE absence;
```
Then re-import.

### Error: "Access denied"
**Solution**: Make sure you're connected as root or a user with CREATE/DROP privileges.

### Import seems stuck
**Solution**: Wait a bit longer. The import creates tables and inserts data, which can take 10-30 seconds.

---

## Next Steps

After importing:
1. ✅ Database is ready
2. ✅ Configure Node-RED MySQL node to connect to `localhost:3306`, database `absence`
3. ✅ Run your Flutter app
4. ✅ Test with QR codes from your database

**Your database is now ready!** 🎉


