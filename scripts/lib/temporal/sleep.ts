import type { Temporal } from "temporal-ponyfill";

export async function sleepDuration(
  duration: Temporal.Duration,
): Promise<void> {
  await new Promise((resolve) =>
    setTimeout(resolve, duration.total({ unit: "milliseconds" })),
  );
}
