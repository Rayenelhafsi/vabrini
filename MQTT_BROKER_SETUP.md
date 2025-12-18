# How to Set Up and Connect MQTT Broker at 192.168.137.1:1883

This guide shows you how to:
1. Install and run an MQTT broker
2. Configure it to run on `192.168.137.1:1883`
3. Connect Node-RED and your Flutter app to it

---

## Option 1: Using Mosquitto MQTT Broker (Recommended)

### Step 1: Install Mosquitto

**On Windows:**
1. Download Mosquitto from: https://mosquitto.org/download/
2. Or use Chocolatey: `choco install mosquitto`
3. Or download installer: https://mosquitto.org/files/binary/win64/mosquitto-2.0.18-install-windows-x64.exe

**On Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install mosquitto mosquitto-clients
```

**On Mac:**
```bash
brew install mosquitto
```

### Step 2: Configure Mosquitto

**On Windows:**
1. Navigate to Mosquitto installation folder (usually `C:\Program Files\mosquitto\`)
2. Open `mosquitto.conf` in a text editor (as Administrator)
3. Add or modify these lines:
   ```
   listener 1883
   allow_anonymous true
   bind_address 192.168.137.1
   ```
4. Save the file

**On Linux/Mac:**
1. Edit the config file:
   ```bash
   sudo nano /etc/mosquitto/mosquitto.conf
   ```
2. Add these lines:
   ```
   listener 1883
   allow_anonymous true
   bind_address 192.168.137.1
   ```
3. Save (Ctrl+X, then Y, then Enter)

### Step 3: Start Mosquitto

**On Windows:**
1. Open Command Prompt as Administrator
2. Navigate to Mosquitto folder:
   ```cmd
   cd "C:\Program Files\mosquitto"
   ```
3. Start broker:
   ```cmd
   mosquitto -c mosquitto.conf
   ```
   Or install as Windows service:
   ```cmd
   mosquitto install
   net start mosquitto
   ```

**On Linux:**
```bash
sudo systemctl start mosquitto
sudo systemctl enable mosquitto  # Start on boot
```

**On Mac:**
```bash
brew services start mosquitto
```

### Step 4: Verify Broker is Running

Open a new terminal/command prompt and test:
```bash
# Subscribe to test topic
mosquitto_sub -h 192.168.137.1 -p 1883 -t test

# In another terminal, publish a message
mosquitto_pub -h 192.168.137.1 -p 1883 -t test -m "Hello MQTT"
```

If you see "Hello MQTT" in the subscribe window, your broker is working! ✅

---

## Option 2: Using Node-RED Built-in MQTT Broker

If you're already using Node-RED, you can use its built-in broker:

### Step 1: Install MQTT Broker Node
1. Open Node-RED (`http://localhost:1880`)
2. Go to **Menu** (☰) → **Manage palette**
3. Click **Install** tab
4. Search for: `node-red-contrib-aedes`
5. Click **Install**

### Step 2: Add MQTT Broker Node
1. In Node-RED, drag an **aedes broker** node onto the canvas
2. Double-click it to configure
3. Set:
   - **Port**: `1883`
   - **Host**: `192.168.137.1` (or `0.0.0.0` to listen on all interfaces)
4. Click **Done**
5. Click **Deploy**

---

## Option 3: Using Docker (Advanced)

If you have Docker installed:

```bash
docker run -it -p 1883:1883 -p 9001:9001 \
  -v mosquitto.conf:/mosquitto/config/mosquitto.conf \
  eclipse-mosquitto
```

Create `mosquitto.conf`:
```
listener 1883
allow_anonymous true
```

---

## Configure Node-RED to Connect to Your Broker

### Step 1: Find MQTT Broker Config in Node-RED
1. Open Node-RED (`http://localhost:1880`)
2. Look for any **MQTT in** or **MQTT out** nodes in your flow
3. Double-click one to open configuration
4. Click the **pencil icon** (✏️) next to "Broker" dropdown

### Step 2: Configure Broker Settings
1. In the broker configuration window, set:
   - **Server**: `192.168.137.1`
   - **Port**: `1883`
   - **Client ID**: Leave default or set custom name
   - **Keepalive**: `60` seconds
2. If your broker requires authentication:
   - Check **Use secure connection (TLS)**: ❌ (uncheck for now)
   - **Username**: (leave empty if `allow_anonymous true`)
   - **Password**: (leave empty if `allow_anonymous true`)
3. Click **Update**
4. Click **Done**

### Step 3: Update All MQTT Nodes
1. Find ALL **MQTT in** and **MQTT out** nodes in your flow
2. Make sure they all use the same broker configuration
3. Click **Deploy**

---

## Verify Connection Works

### Test from Node-RED:
1. Add an **inject** node
2. Add an **MQTT out** node
3. Configure MQTT out:
   - Broker: Your configured broker (`192.168.137.1:1883`)
   - Topic: `test/connection`
   - QoS: `0`
4. Add an **MQTT in** node
5. Configure MQTT in:
   - Broker: Same broker
   - Topic: `test/connection`
   - QoS: `0`
6. Add a **debug** node
7. Connect: inject → MQTT out
8. Connect: MQTT in → debug
9. Click **Deploy**
10. Click inject button
11. Check debug panel - you should see the message

### Test from Flutter App:
1. Run your Flutter app
2. The app should connect automatically (it's already configured in `mqtt.dart`)
3. Check Node-RED debug panel for incoming messages

---

## Troubleshooting

### Issue 1: "Connection refused" or "Can't connect"
**Problem**: Broker not running or wrong IP address

**Solution**:
1. Check if broker is running:
   ```bash
   # Windows
   netstat -an | findstr 1883
   
   # Linux/Mac
   netstat -an | grep 1883
   ```
2. Verify IP address is correct: `192.168.137.1`
3. Check firewall allows port 1883
4. Try `localhost` or `127.0.0.1` if broker is on same machine

### Issue 2: "Connection timeout"
**Problem**: Firewall blocking or wrong network

**Solution**:
1. Check Windows Firewall:
   - Go to **Windows Defender Firewall** → **Advanced settings**
   - Add inbound rule for port 1883
2. Make sure your device is on the same network as `192.168.137.1`
3. Try pinging the IP: `ping 192.168.137.1`

### Issue 3: "Not authorized"
**Problem**: Broker requires authentication

**Solution**:
1. Check `mosquitto.conf` has `allow_anonymous true`
2. Or add username/password in Node-RED broker config
3. Restart Mosquitto after changing config

### Issue 4: Broker starts but can't bind to IP
**Problem**: IP address `192.168.137.1` not available on your machine

**Solution**:
1. Check your actual IP address:
   ```bash
   # Windows
   ipconfig
   
   # Linux/Mac
   ifconfig
   # or
   ip addr
   ```
2. Use your actual IP address instead of `192.168.137.1`
3. Or use `0.0.0.0` to listen on all interfaces
4. Update Flutter `mqtt.dart` and Node-RED config to match

### Issue 5: Port 1883 already in use
**Problem**: Another MQTT broker or service using port 1883

**Solution**:
1. Find what's using the port:
   ```bash
   # Windows
   netstat -ano | findstr :1883
   
   # Linux/Mac
   lsof -i :1883
   ```
2. Stop the other service or use a different port
3. If using different port, update all configs (Node-RED, Flutter)

---

## Quick Setup Checklist

- [ ] MQTT broker installed (Mosquitto or Node-RED built-in)
- [ ] Broker configured to listen on `192.168.137.1:1883`
- [ ] Broker is running (check with `mosquitto_sub` test)
- [ ] Node-RED MQTT nodes configured with:
  - [ ] Server: `192.168.137.1`
  - [ ] Port: `1883`
- [ ] Flutter app already configured (in `mqtt.dart`)
- [ ] Firewall allows port 1883
- [ ] Test connection works from Node-RED

---

## Alternative: Use localhost if Same Machine

If Node-RED, Flutter app, and MQTT broker are all on the same computer:

1. **Configure broker to listen on `localhost` or `0.0.0.0`**:
   ```
   listener 1883
   allow_anonymous true
   bind_address 0.0.0.0
   ```

2. **Update Flutter `mqtt.dart`**:
   Change `'192.168.137.1:1883'` to `'localhost:1883'` or `'127.0.0.1:1883'`

3. **Update Node-RED broker config**:
   - Server: `localhost` or `127.0.0.1`
   - Port: `1883`

This is simpler if everything runs on one machine!

---

## Verify Everything Works

### Test 1: Broker is Running
```bash
mosquitto_sub -h 192.168.137.1 -p 1883 -t test -v
```

### Test 2: Node-RED Can Publish
- Use inject → MQTT out → check with `mosquitto_sub` above

### Test 3: Node-RED Can Subscribe
- Use MQTT in → debug, publish from command line:
```bash
mosquitto_pub -h 192.168.137.1 -p 1883 -t test -m "Hello"
```

### Test 4: Flutter App Connects
- Run Flutter app, check Node-RED debug panel for messages

---

**Once your broker is running and connected, your entire system will work!** 🎉


