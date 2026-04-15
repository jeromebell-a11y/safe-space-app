import * as admin from "firebase-admin";

const GEOHASH_PREFIX_LENGTH = 5;

const SEVERITY_WEIGHTS: Record<number, number> = {
  5: 3.0,
  4: 2.5,
  3: 2.0,
  2: 1.0,
};

function recencyWeight(ageMs: number): number {
  const hours = ageMs / (1000 * 60 * 60);
  if (hours < 6) return 1.0;
  if (hours < 24) return 0.5;
  return 0.2;
}

export interface SafetyZoneData {
  geohashPrefix: string;
  riskScore: number;
  incidentCount: number;
  lastUpdated: string;
}

export function geohashPrefix(geohash: string): string {
  return geohash.substring(0, GEOHASH_PREFIX_LENGTH);
}

export async function deriveZone(
  db: admin.firestore.Firestore,
  prefix: string
): Promise<SafetyZoneData> {
  const end =
    prefix.substring(0, prefix.length - 1) +
    String.fromCharCode(prefix.charCodeAt(prefix.length - 1) + 1);

  const snapshot = await db
    .collection("incidents")
    .where("geohash", ">=", prefix)
    .where("geohash", "<", end)
    .orderBy("geohash")
    .limit(50)
    .get();

  if (snapshot.empty) {
    return {
      geohashPrefix: prefix,
      riskScore: 0,
      incidentCount: 0,
      lastUpdated: new Date().toISOString(),
    };
  }

  const now = Date.now();
  let riskScore = 0;
  let mostRecent = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const createdAt = new Date(data.createdAt as string).getTime();
    const age = now - createdAt;
    const severity = (data.severity as number) ?? 2;
    const sw = SEVERITY_WEIGHTS[severity] ?? 1.0;
    riskScore += recencyWeight(age) * sw;

    if (createdAt > mostRecent) {
      mostRecent = createdAt;
    }
  }

  return {
    geohashPrefix: prefix,
    riskScore: Math.round(riskScore * 100) / 100,
    incidentCount: snapshot.size,
    lastUpdated: new Date(mostRecent).toISOString(),
  };
}
