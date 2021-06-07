import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {messaging} from "firebase-admin";


const serviceAccount = require("../service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://test-edfab-default-rtdb.europe-west1.firebasedatabase.app/",
});

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const updateTest = functions.database.ref("test/again")
    .onUpdate(async (change, context) => {
      if (!change.after.exists || change.after.val() == change.before.val()) {
        // Ignore
        return;
      }
      const newValue = change.after.val();
      // console.log(`Updating the full name for user with ID
      // ${context.params.again}`);
      // Update the full_name field (Without touching first_name and last_name)

      // return change.after.ref.update(`cloud Test: ${newValue}`,
      // );
      const title = "This is a Test";
      const body = "Wow! " + newValue;
      const list: Array<any> = [];
      list.push(change.before.ref.parent?.parent?.
        child("Tokens").child("token"));
      // const apptoken ="edZe0d8ulFg:APA91bFQyIkt3j0WBNY9cwVZMNXvpkD_" +
      // "ZPGoTUVgFqrIqBh9ZRgzZLIlxt661lAs-ACG5dQywxQOtKlGvsaQPYwxF5" +
      // "2unECEqawRZq6TkxwVQLPMn18RTyk_Y4KhtLyUl43Z9Ru7E8zv";
      //list.push(apptoken);
      // const tokensList = await change.before.ref.parent?.
      // parent?.child("Tokens").get();
      // tokensList?.forEach((element) => {
      //   list.push(element);
      // });
      const mytokens = list;
      const message = {
        notification: {
          title: title,
          body: body,
        },
        tokens: mytokens,
      } as unknown as messaging.MulticastMessage;// messaging.DataMessagePayload 
      // Send a message to devices subscribed to the provided topic.
      const response = await admin.messaging().sendMulticast(message);
      // const response = await admin.messaging().sendToDevice(apptoken, message);
      // Response is a message ID string.
      console.log("Successfully sent message:", response);

      return change.after.ref.parent?.ref.child("status").ref
          .set(`cloud Test: ${newValue}`,
      );
    });
