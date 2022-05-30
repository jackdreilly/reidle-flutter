from datetime import datetime
import json
from pathlib import Path
import firebase_admin
import firebase_admin.firestore
from firebase_admin import credentials
from google.cloud import firestore

firebase_admin.initialize_app(
    credentials.Certificate("reidle-d39c2-firebase-adminsdk-g9dyy-dfeec38c43.json")
)

client: firestore.Client = firebase_admin.firestore.client()

collection = client.collection("submissions")

for item in collection.get():
    item.reference.delete()
for item in json.loads(Path("dump.json").read_text())["items"]:
    if not item.get("wordle_paste"):
        continue
    paste = item["wordle_paste"].replace("⬛", "⬜")
    while paste and paste[0] not in "⬜🟨⬛🟩":
        paste = paste[1:]
    if not paste:
        continue
    error = item.get("failure", None)
    if error == "No":
        error = None
    collection.add(
        {
            "name": item.get("name", "..."),
            "time": item.get("seconds", 100) * 1e6,
            "submissionTime": item.get("date", datetime.utcnow().isoformat()),
            "error": error,
            "paste": paste,
        }
    )
