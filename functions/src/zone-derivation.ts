import * as admin from "firebase-admin";

const GEOHASH_PREFIX_LENGTH = 5;

const HOURS_MS = 1000 * 60 * 60;
const DAYS_MS = HOURS_MS * 24;

const SEVERITY_WEIGHTS: Record<number, number> = {
  5: 3.0,
  4: 2.5,
  3: 2.0,
  2: 1.0,
};

/**
 * Aggressive time-decay buckets.
 * - < 6h:  full weight (active situation)
 * - < 24h: half weight (recent but cooling)
 * - < 7d:  low weight (historical context)
 * - >= 7d: near-zero (stale, minimal influence)
 */
function recencyWeight(ageMs: number): number {
  if (ageMs < 6 * HOURS_MS) return 1.0;
  if (ageMs < 24 * HOURS_MS) return 0.5;
  if (ageMs < 7 * DAYS_MS) return 0.15;
  return 0.03;
}

export type FreshnessLevel = "active" | "recent" | "aging" | "stale";

export interface SafetyZoneData {
  geohashPrefix: string;
  riskScore: number;
  incidentCount: number;
  lastUpdated: string;
  mostRecentIncidentAt: string | null;
  freshnessLevel: FreshnessLevel;
}

export function geohashPrefix(geohash: string): string {
  return geohash.substring(0, GEOHASH_PREFIX_LENGTH);
}

/**
 * Classify zone freshness based on the age of the most recent incident.
 */
function classifyFreshness(mostRecentMs: number, nowMs: number): FreshnessLevel {
  const age = nowMs - mostRecentMs;
  if (age < 6 * HOURS_MS) return "active";
  if (age < 24 * HOURS_MS) return "recent";
  if (age < 7 * DAYS_MS) return "aging";
  return "stale";
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

  const now = Date.now();

  if (snapshot.empty) {
    return {
      geohashPrefix: prefix,
      riskScore: 0,
      incidentCount: 0,
      lastUpdated: new Date().toISOString(),
      mostRecentIncidentAt: null,
      freshnessLevel: "stale",
    };
  }

  let riskScore = 0;
  let mostRecentMs = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const createdAt = new Date(data.createdAt as string).getTime();
    const age = now - createdAt;
    const severity = (data.severity as number) ?? 2;
    const sw = SEVERITY_WEIGHTS[severity] ?? 1.0;
    riskScore += recencyWeight(age) * sw;

    if (createdAt > mostRecentMs) {
      mostRecentMs = createdAt;
    }
  }

  return {
    geohashPrefix: prefix,
    riskScore: Math.round(riskScore * 100) / 100,
    incidentCount: snapshot.size,
    lastUpdated: new Date().toISOString(),
    mostRecentIncidentAt: new Date(mostRecentMs).toISOString(),
    freshnessLevel: classifyFreshness(mostRecentMs, now),
  };
}
