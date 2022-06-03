import * as firebase from "firebase-functions";
import * as sendgrid from "@sendgrid/mail";

/**
 * firestore function to send a sendgrid email on new item added to
 * "submissions" collection.
 */

export const onNewSubmission = firebase
  .runWith({secrets: ["SENDGRID_API_KEY"]})
  .firestore.document("submissions/{submissionId}")
  .onCreate(async (snap) => {
    sendgrid.setApiKey(process.env.SENDGRID_API_KEY ?? "");
    const data = snap.data() ?? {};
    await sendgrid.send({
      to: "reidle@googlegroups.com",
      from: "jackdreilly@gmail.com",
      subject: "Update",
      text: `
Name: ${data.name}
Date: ${data.submissionTime}
Time: ${data.time / 1e6}
Penalty: ${(data.penalty ?? 0) / 1e6}
Lost: ${(data.error?.length ?? 0) == 0 ? "no" : "yes"}
`,
    });
  });
