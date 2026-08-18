import time
from smsmobileapi import SMSSender

API_KEY = "cc0c4fca803ea5a3bd7762afa36274bacf874ae8e34e51aa"
TARGET = "9103289434"

sms = SMSSender(api_key=API_KEY)
print(f"Starting test blast of 10 messages to {TARGET}...\n")

for i in range(10):
    msg = f"Prank Blaster Test SMS #{i+1} of 10! 😜🚀"
    print(f"[{i+1}/10] Sending message...")
    response = sms.send_message(to=TARGET, message=msg)
    print(f"[{i+1}/10] API Response: {response}")
    time.sleep(3)

print("\nFinished blasting all 10 messages!")
