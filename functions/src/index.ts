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
    const minutes = Math.floor(seconds / 60);
    seconds -= minutes * 60;
    const fullSeconds = Math.floor(seconds + 1e-5);
    const milliseconds = Math.floor(
      Math.abs((seconds - fullSeconds) % 1) * 1000);
    const lost = (error?.length ?? 0) > 0;
    const secondsString = fullSeconds.toString().padStart(2, "0");
    const millisString = milliseconds.toString().padStart(3, "0");
    const timeString = `${minutes}:${secondsString}.${millisString}`;
    const lostString = lost ? " (lost)" : "";
    const text = `${name}: ${timeString}${lostString}`;
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
