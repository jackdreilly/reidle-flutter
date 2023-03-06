import * as firebase from "firebase-functions";
import * as sendgrid from "@sendgrid/mail";

const email = "jackdreilly@gmail.com";
const to = "reidle@googlegroups.com";
const secrets = {secrets: ["SENDGRID_API_KEY"]};
/**
 * Setup sendgrid secret.
 */
function setup() {
  sendgrid.setApiKey(process.env.SENDGRID_API_KEY ?? "");
}

/**
 * firestore function to send a sendgrid email on new item added to
 * "submissions" collection.
 */
export const onNewSubmission = firebase
  .runWith(secrets)
  .firestore.document("submissions/{submissionId}")
  .onCreate(async (snapshot) => {
    setup();
    const {name, time, error, submissionTime} = snapshot.data() ?? {};
    const subject = submissionTime.substring(0, 10);
    let seconds = time / 1e6;
    const minutes = Math.floor(time / 60);
    seconds -= minutes * 60;
    const lost = (error?.length ?? 0) > 0;
    const text = `${name}: ${minutes}:${seconds}${lost ? " (lost)" : ""}`;
    await sendgrid.send({
      to,
      from: {name, email},
      subject,
      text,
    });
  });

export const onNewChat = firebase
  .runWith(secrets)
  .firestore.document("chats/{chatId}")
  .onCreate(async (snapshot) => {
    setup();
    const {name, message} = snapshot.data() ?? {};
    const text = `${name}: ${message}`;
    const subject = text;
    await sendgrid.send({
      to,
      from: {name, email},
      subject,
      text,
    });
  });
