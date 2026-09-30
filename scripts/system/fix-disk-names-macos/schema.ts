import { Path } from "path-class";
import { object, string, toJSONSchema, type infer as zodInfer } from "zod/mini";

export const SCHEMA_PATH = Path.resolve(
  "./disk-metadata.schema.json",
  import.meta.url,
);

export const DiskMetadataSchema = object({
  $schema: string(),
  name: string(),
});

export type DiskMetadata = zodInfer<typeof DiskMetadataSchema>;

if (import.meta.main) {
  await SCHEMA_PATH.writeJSON(toJSONSchema(DiskMetadataSchema));
}
