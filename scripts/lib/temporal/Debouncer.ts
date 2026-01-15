import { Temporal } from "temporal-ponyfill";
import { monotonicNow } from "./monotonicNow";

const BEFORE = -1;

// TODO: falling edge?
export function debounce(
  // We place the duration first, because it places it ahead of a potentially
  // long function definition (which is good practice to inline if it should
  // never be called undebounced). This makes it easier to notice if the
  // duration is misconfigured when
  duration: Temporal.Duration,
  fn: (() => Promise<void>) | (() => void),
  options?: {
    onSkip?: (() => Promise<void>) | (() => void);
  },
): () => Promise<void> {
  const debouncer = new Debouncer(duration);
  return async () => {
    if (debouncer.lease()) {
      await fn();
    } else {
      await options?.onSkip?.();
    }
  };
}

export class Debouncer {
  private lastRun: Temporal.Instant | undefined;
  constructor(private duration: Temporal.Duration) {}

  /**
   * Usage example:
   *
   *     if (debouncer.lease()) {
   *       // perform work
   *     } else {
   *       console.log("skipping work");
   *     }
   *
   * Or as a guard:
   *
   *     const debouncer = new Debouncer(Temporal.Duration.from({ minutes: 5 }));
   *     function fn() {
   *       if (!debouncer.lease()) {
   *         return;
   *       }
   *       // do work
   *     }
   *
   */
  lease(): boolean {
    const now = monotonicNow();
    if (
      this.lastRun &&
      Temporal.Instant.compare(now, this.lastRun.add(this.duration)) === BEFORE
    ) {
      return false;
    } else {
      this.lastRun = now;
      return true;
    }
  }
}
