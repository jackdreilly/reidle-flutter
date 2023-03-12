# %%
import json
import psycopg2
import psycopg2.extras
import firebase_admin
import firebase_admin.firestore
from firebase_admin import credentials
from google.cloud import firestore

firebase_admin.initialize_app(
    credentials.Certificate("reidle-d39c2-firebase-adminsdk-g9dyy-317b12e808.json")
)

client: firestore.Client = firebase_admin.firestore.client()


def connect():
    return psycopg2.connect(
        "postgres://postgres:q3zbKbcZzs6L5UG@db.kyxziusgsizkedxitbez.supabase.co:5432/postgres"
    )


# %%
cursor.close()
connection.close()
# %%
connection = connect()
cursor = connection.cursor()
# %%
cursor.execute("truncate submissions")

psycopg2.extras.execute_values(
    cursor,
    """
INSERT INTO
    submissions (
        word,
        created_at,
        time,
        penalty,
        name,
        paste,
        playback,
        rank,
        score,
        day
    )
VALUES
    %s""",
    [
        (
            x.get("answer", "").upper(),
            x["submissionTime"],
            x.get("time", 0) / 1e6,
            int(x.get("penalty", 0) / 1e6),
            x.get("name", ""),
            x.get("paste", ""),
            json.dumps(x.get("events", [])),
            1,
            1,
            x.get("submissionTime", "")[:10],
        )
        for x in {
            (x.get("submissionTime", "")[:10], x.get("name")): x
            for x in [x._data for x in client.collection("submissions").get()]
        }.values()
    ],
    page_size=10000,
)

connection.commit()
# %%
cursor.execute("truncate messages")

psycopg2.extras.execute_values(
    cursor,
    """
INSERT INTO
    messages (
        name,
        created_at,
        message
    )
VALUES
    %s""",
    [
        (
            x.get("name", ""),
            x.get("date"),
            x.get("message"),
        )
        for x in (x._data for x in client.collection("chats").get())
    ],
    page_size=10000,
)

connection.commit()
