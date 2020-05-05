import * as functions from 'firebase-functions';

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// watches vote options to see if it should be enabled
exports.updatevotestatus = functions.firestore
    .document('votes/{id}')
    .onUpdate((change, context) => {
        const newData = change.after.data();
        let isEnabled: boolean = false;

        if (newData != null) {
            isEnabled = newData.topic.length > 0 && newData.groupId.length > 0 && newData.groupId.length > 0;
        }

        return change.after.ref.set({
            enabled: isEnabled
        }, { merge: true });
    });