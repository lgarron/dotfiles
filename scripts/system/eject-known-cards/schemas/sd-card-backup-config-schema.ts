import {
  array,
  boolean,
  type infer as zodInfer,
  object as zodObject,
  optional as zodOptional,
  string as zodString,
} from "zod/mini";
import { zodPath } from "../../../lib/zod/zodPath";

export const SDCardBackupConfigSchema = zodObject({
  destination_root: zodPath,
  sd_card_mount_point: zodPath,
  sd_card_names: array(zodString()),
  folder_mapping: array(
    zodObject({
      source: zodPath,
      destination: zodPath,
    }),
  ),
  command_to_run_before: zodOptional(array(zodString())),
  commandline_options: zodOptional(
    zodObject({
      dry_run: zodOptional(boolean()),
      skip_videos: zodOptional(boolean()),
      reveal_path_urls: zodOptional(boolean()),
    }),
  ),
});
export type SDCardBackupConfig = zodInfer<typeof SDCardBackupConfigSchema>;
