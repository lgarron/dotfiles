import { expect, spyOn, test } from "bun:test";
import { Temporal } from "temporal-ponyfill";
import { Debouncer, debounce } from "./Debouncer";

const DEBOUNCE_DURATION = Temporal.Duration.from({ milliseconds: 5 });

test.serial("Debouncer", () => {
  const mock = spyOn(globalThis.performance, "now");
  mock.mockReturnValue(0);
  const debouncer = new Debouncer(DEBOUNCE_DURATION);
  expect(debouncer.lease()).toBe(true);
  expect(debouncer.lease()).toBe(false);
  mock.mockReturnValue(4);
  expect(debouncer.lease()).toBe(false);
  mock.mockReturnValue(5);
  expect(debouncer.lease()).toBe(true);
  expect(debouncer.lease()).toBe(false);
  mock.mockReturnValue(9);
  expect(debouncer.lease()).toBe(false);
  mock.mockReturnValue(10);
  expect(debouncer.lease()).toBe(true);
  expect(debouncer.lease()).toBe(false);
  expect(debouncer.lease()).toBe(false);
  mock.mockReturnValue(25);
  expect(debouncer.lease()).toBe(true);
  mock.mockRestore();
});

test.serial("debounce(…)", async () => {
  const mock = spyOn(globalThis.performance, "now");
  const counters = {
    ran: 0,
    skipped: 0,
  };
  const fn = debounce(
    DEBOUNCE_DURATION,
    () => {
      counters.ran++;
    },
    {
      onSkip() {
        counters.skipped++;
      },
    },
  );

  mock.mockReturnValue(0);

  await fn();
  expect(counters).toEqual({ ran: 1, skipped: 0 });
  await fn();
  expect(counters).toEqual({ ran: 1, skipped: 1 });

  mock.mockReturnValue(4);

  await fn();
  expect(counters).toEqual({ ran: 1, skipped: 2 });

  mock.mockReturnValue(5);

  await fn();
  expect(counters).toEqual({ ran: 2, skipped: 2 });
  await fn();
  expect(counters).toEqual({ ran: 2, skipped: 3 });

  mock.mockReturnValue(9);

  await fn();
  expect(counters).toEqual({ ran: 2, skipped: 4 });

  mock.mockReturnValue(10);

  await fn();
  expect(counters).toEqual({ ran: 3, skipped: 4 });
  await fn();
  expect(counters).toEqual({ ran: 3, skipped: 5 });
  await fn();
  expect(counters).toEqual({ ran: 3, skipped: 6 });

  mock.mockReturnValue(25);

  await fn();
  expect(counters).toEqual({ ran: 4, skipped: 6 });

  mock.mockRestore();
});
