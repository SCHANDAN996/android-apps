import os
import time
import json
import queue
import threading
import requests
from flask import Flask, render_template, jsonify, Response, request
from smsmobileapi import SMSSender

app = Flask(__name__, template_folder='templates')

CONFIG_FILE = 'config.json'

class PrankSession:
    def __init__(self):
        self.lock = threading.Lock()
        self.active_thread = None
        self.stop_requested = False
        self.log_queue = queue.Queue()
        self.running = False

    def start(self, api_key, targets, message, count, delay, send_sms, send_wa):
        with self.lock:
            if self.running:
                return False, "A prank session is already running!"
            
            self.stop_requested = False
            self.running = True
            # Clear queue
            while not self.log_queue.empty():
                try:
                    self.log_queue.get_nowait()
                except queue.Empty:
                    break
            
            self.active_thread = threading.Thread(
                target=self._run_bombing,
                args=(api_key, targets, message, count, delay, send_sms, send_wa)
            )
            self.active_thread.daemon = True
            self.active_thread.start()
            return True, "Started"

    def stop(self):
        with self.lock:
            if self.running:
                self.stop_requested = True
                return True, "Stop request sent."
            return False, "No active session is running."

    def log(self, text, status="info"):
        timestamp = time.strftime("%H:%M:%S")
        self.log_queue.put({
            "time": timestamp,
            "message": text,
            "status": status,
            "running": self.running
        })

    def _run_bombing(self, api_key, targets, message, count, delay, send_sms, send_wa):
        try:
            self.log("Initializing SMS Mobile API connection...", "info")
            try:
                sms_client = SMSSender(api_key=api_key)
            except Exception as e:
                self.log(f"Failed to initialize API client: {str(e)}", "error")
                return

            self.log(f"Target count: {len(targets)} | Messages per target: {count} | Delay: {delay}s", "info")
            
            sendsms_val = 1 if send_sms else 0
            sendwa_val = 1 if send_wa else 0

            for i in range(count):
                if self.stop_requested:
                    self.log("Prank aborted by user.", "warning")
                    break

                self.log(f"Starting cycle {i+1} of {count}...", "info")

                for idx, phone in enumerate(targets):
                    if self.stop_requested:
                        break

                    clean_phone = phone.strip()
                    if not clean_phone:
                        continue

                    mode_desc = []
                    if send_sms: mode_desc.append("SMS")
                    if send_wa: mode_desc.append("WhatsApp")
                    mode_str = " + ".join(mode_desc)

                    self.log(f"Sending prank via {mode_str} to {clean_phone}...", "pending")
                    
                    try:
                        # Call SMS Mobile API
                        response = sms_client.send_message(
                            to=clean_phone,
                            message=message,
                            sendwa=sendwa_val,
                            sendsms=sendsms_val
                        )
                        
                        # Interpret response
                        # Typical responses: {"status": "success", ...} or similar, let's display the outcome
                        if isinstance(response, dict) and "error" in response:
                            self.log(f"Error for {clean_phone}: {response['error']}", "error")
                        else:
                            resp_str = json.dumps(response)
                            if "success" in resp_str.lower() or "sent" in resp_str.lower() or ("status" in response and response["status"] is True):
                                self.log(f"SUCCESS: Message queued/sent to {clean_phone} - {resp_str}", "success")
                            else:
                                self.log(f"RESPONSE from {clean_phone}: {resp_str}", "info")
                                
                    except Exception as e:
                        self.log(f"Failed to send to {clean_phone}: {str(e)}", "error")

                    # Apply delay between messages if it's not the last one in the target list
                    # or if there are more cycles
                    if idx < len(targets) - 1 or i < count - 1:
                        # Wait in small increments to respond quickly to cancel requests
                        for _ in range(int(delay * 10)):
                            if self.stop_requested:
                                break
                            time.sleep(0.1)

            if self.stop_requested:
                self.log("Prank bombing process stopped by user.", "warning")
            else:
                self.log("Prank bombing process completed successfully! 🎉", "success")

        except Exception as e:
            self.log(f"Unexpected error in background thread: {str(e)}", "error")
        finally:
            with self.lock:
                self.running = False
            # Send end signal to queue
            self.log_queue.put(None)

# Global session instance
session = PrankSession()

def load_config():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, 'r') as f:
                return json.load(f)
        except Exception:
            pass
    return {
        "api_key": "",
        "targets": "",
        "message": "Aapki lottery lagi hai! 😜",
        "count": 5,
        "delay": 3,
        "send_sms": True,
        "send_wa": False
    }

def save_config(config_data):
    try:
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config_data, f, indent=4)
    except Exception:
        pass

@app.route('/')
def home():
    config = load_config()
    return render_template('index.html', config=config)

@app.route('/api/test-key', methods=['POST'])
def test_key():
    data = request.json or {}
    api_key = data.get('api_key', '')
    if not api_key:
        return jsonify({"success": False, "message": "API key is required."})

    try:
        # Check by attempting to fetch received messages
        sms_client = SMSSender(api_key=api_key)
        response = sms_client.get_received_messages()
        
        if isinstance(response, dict) and "error" in response:
            return jsonify({"success": False, "message": f"Connection failed: {response['error']}"})
        
        # If response is a list or doesn't throw a direct error, API key is likely valid
        return jsonify({"success": True, "message": "Connection test successful! Device linked.", "data": response})
    except Exception as e:
        return jsonify({"success": False, "message": f"Error: {str(e)}"})

@app.route('/api/start', methods=['POST'])
def start_prank():
    data = request.json or {}
    api_key = data.get('api_key', '').strip()
    targets_str = data.get('targets', '').strip()
    message = data.get('message', '').strip()
    count = int(data.get('count', 5))
    delay = float(data.get('delay', 3.0))
    send_sms = bool(data.get('send_sms', True))
    send_wa = bool(data.get('send_wa', False))

    if not api_key:
        return jsonify({"success": False, "message": "API Key is required!"})
    if not targets_str:
        return jsonify({"success": False, "message": "At least one target phone number is required!"})
    if not message:
        return jsonify({"success": False, "message": "Prank message content cannot be empty!"})
    if not send_sms and not send_wa:
        return jsonify({"success": False, "message": "Please select at least one sending method (SMS or WhatsApp)!"})

    # Save to config for persistence
    save_config({
        "api_key": api_key,
        "targets": targets_str,
        "message": message,
        "count": count,
        "delay": delay,
        "send_sms": send_sms,
        "send_wa": send_wa
    })

    # Parse target list
    targets = [p.strip() for p in targets_str.replace('\n', ',').split(',') if p.strip()]

    success, msg = session.start(api_key, targets, message, count, delay, send_sms, send_wa)
    return jsonify({"success": success, "message": msg})

@app.route('/api/stop', methods=['POST'])
def stop_prank():
    success, msg = session.stop()
    return jsonify({"success": success, "message": msg})

@app.route('/api/stream')
def stream_logs():
    def event_generator():
        while True:
            try:
                # Wait for up to 10 seconds for logs
                log_item = session.log_queue.get(timeout=10)
                if log_item is None:
                    # Session finished
                    break
                yield f"data: {json.dumps(log_item)}\n\n"
            except queue.Empty:
                # Send a ping to keep connection alive if no logs
                yield f"data: {json.dumps({'ping': True, 'running': session.running})}\n\n"
            except Exception as e:
                yield f"data: {json.dumps({'time': time.strftime('%H:%M:%S'), 'message': f'Stream error: {str(e)}', 'status': 'error', 'running': session.running})}\n\n"
                break
        
    return Response(event_generator(), mimetype='text/event-stream')

if __name__ == '__main__':
    print("Starting SMS Prank App on http://127.0.0.1:5000")
    app.run(debug=True, port=5000)
