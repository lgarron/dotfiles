import { monotonicNow } from "../../lib/temporal/monotonicNow.ts";

function digitalHMMSS(duration: Temporal.Duration): string {
  return duration
    .round({ largestUnit: "hour", smallestUnit: "second" })
    .toLocaleString("en", {
      style: "digital",
    });
}

function D(d: Temporal.DurationLike): Temporal.Duration {
  return Temporal.Duration.from(d);
}

export type BackoffDelayPeriod = {
  untilElapsed: Temporal.Duration;
  backoffDelay: Temporal.Duration;
};
const DEFAULT_BACKOFF_DELAY_PERIODS: BackoffDelayPeriod[] = [
  { untilElapsed: D({ seconds: 10 }), backoffDelay: D({ seconds: 1 }) },
  { untilElapsed: D({ minutes: 1 }), backoffDelay: D({ seconds: 5 }) },
  { untilElapsed: D({ minutes: 10 }), backoffDelay: D({ seconds: 15 }) },
  { untilElapsed: D({ hours: 24 }), backoffDelay: D({ minutes: 1 }) },
];

export function getBackoffDelay(
  pollStartTime: Temporal.Instant,
  options?: { backoffDelays?: BackoffDelayPeriod[] },
): Temporal.Duration {
  const now = monotonicNow();
  globalThis.process.stdout.write(
    `Polled for ${digitalHMMSS(now.since(pollStartTime))} so far. `,
  );
  for (const { untilElapsed, backoffDelay } of options?.backoffDelays ??
    DEFAULT_BACKOFF_DELAY_PERIODS) {
    if (Temporal.Instant.compare(now, pollStartTime.add(untilElapsed)) <= 0) {
      return backoffDelay;
    }
  }
  throw new Error(
    "Polling has taken more than the maximum time (" +
      // biome-ignore lint/style/noNonNullAssertion: TypeScript is not powerful enough.
      digitalHMMSS(DEFAULT_BACKOFF_DELAY_PERIODS.at(-1)!.untilElapsed) +
      "). Aborting.",
  );
}
