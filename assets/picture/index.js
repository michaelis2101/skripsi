/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


// The Cloud Functions for Firebase SDK to setup triggers and logging.
// import { onRequest } from "firebase-functions/v2/https";
// import { onValueCreated } from "firebase-functions/v2/database";
// import { logger } from "firebase-functions";

const admin = require("firebase-admin");

// import { createClient } from '@supabase/supabase-js'

const createClient = require("@supabase/supabase-js").createClient;

const functions = require('firebase-functions');
const db = require('firebase-admin/database');


// The Firebase Admin SDK to access the Firebase Realtime Database.
// import { initializeApp } from "firebase-admin";
admin.initializeApp();

const supabase = createClient('https://wweyukblyptkrbhwhcaw.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3ZXl1a2JseXB0a3JiaHdoY2F3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTIwNDg3MDMsImV4cCI6MjAyNzYyNDcwM30.3RpcktL4y6V0Yv_Y6YByAgXJRnPqJZzGg8wah5UjWjI');


const deviceLogRef = db.ref('device_log');

exports.listeningDevicesValue = functions.database.ref('devices').onWrite((change, context) => {
    const snapshot = change.after;

    snapshot.forEach((deviceSnapshot) => {
        const deviceId = deviceSnapshot.key;
        const deviceData = deviceSnapshot.val();

        if (deviceData.hasOwnProperty('value')) {
            const deviceValue = deviceData.value;

            const timestamp = admin.database.ServerValue.TIMESTAMP;

            const rtdbPushTask = deviceLogRef.push({
             deviceId,
             data: deviceValue,
             timestamp,
           });

           //const supabasePushLog = supabase.from('device_log').insert({device_name: deviceData.deviceName, value: deviceValue});
           
           const supabasePushTask = supabase
          .from('device_log')
          .insert({
            device_name: deviceData.deviceName,
            device_id: deviceId,
            data: deviceValue,
            timestamp,
          });

            Promise.all([rtdbPushTask, supabasePushLog]).then(([rtdbResult, supabaseResult]) => {
                console.log('Data pushed to RTDB:', rtdbResult);
            console.log('Data pushed to Supabase:', supabaseResult);
            } ).catch((error) => {})
            console.error(error);
        }
    });
})