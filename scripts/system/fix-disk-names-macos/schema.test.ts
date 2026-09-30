import { expect, test } from "bun:test";
import { toJSONSchema } from "zod/mini";
import type { ZodStandardJSONSchemaPayload } from "zod/v4/core";
import { DiskMetadataSchema, SCHEMA_PATH } from "./schema";

test("Schema is up to date.", async () => {
  expect(await SCHEMA_PATH.readJSON()).toEqual<
    ZodStandardJSONSchemaPayload<typeof DiskMetadataSchema>
  >(toJSONSchema(DiskMetadataSchema));
});
