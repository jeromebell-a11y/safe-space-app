import * as admin from "firebase-admin";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { deriveZone, geohashPrefix } from "./zone-derivation";

admin.initializeApp();

const db = admin.firestore();

export const onIncidentCreated = onDocumentCreated(
  "incidents/{incidentId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const geohash = data.geohash as string | undefined;
    if (!geohash || geohash.length < 5) return;

    const prefix = geohashPrefix(geohash);
    const zone = await deriveZone(db, prefix);

    await db.collection("safety_zones").doc(prefix).set(zone, { merge: true });
  }
);
