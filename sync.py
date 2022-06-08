import firebase_admin
import firebase_admin.firestore
import typer
from firebase_admin import credentials
from google.cloud import firestore

firebase_admin.initialize_app(
    credentials.Certificate("reidle-d39c2-firebase-adminsdk-g9dyy-dfeec38c43.json")
)

client: firestore.Client = firebase_admin.firestore.client()
main, test = (client.collection(k) for k in ("submissions", "submissions-test"))
with typer.progressbar(test.get()) as p:
    for d in p:
        d.reference.delete()
with typer.progressbar(main.get()) as p:
    for d in p:
        test.add(d.to_dict())
