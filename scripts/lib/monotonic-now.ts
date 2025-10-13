import { Temporal } from "temporal-ponyfill";

/** Millisecond precision. Equivalent to:
 *
 *     Temporal.Instant.fromEpochMilliseconds(Math.floor(performance.now()))
 *
 */
export function monotonicNow(): Temporal.Instant {
  return Temporal.Instant.fromEpochMilliseconds(Math.floor(performance.now()));
}
