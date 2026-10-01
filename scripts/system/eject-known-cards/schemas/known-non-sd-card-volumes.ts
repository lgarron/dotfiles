import {
  array,
  record,
  type infer as zodInfer,
  object as zodObject,
  string as zodString,
} from "zod/mini";

export const KnownNonSDCardVolumesConfigSchema = zodObject({
  volumes: record(zodString(), array(zodString())),
  commandToRunBefore: array(zodString()),
});
export type KnownNonSDCardVolumesConfig = zodInfer<
  typeof KnownNonSDCardVolumesConfigSchema
>;
