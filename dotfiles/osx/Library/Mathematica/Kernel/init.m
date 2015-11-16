(** User Mathematica initialization file **)

Copy[text_] := With[
  {tempClipboardFile = FileNameJoin[{$TemporaryDirectory, "mathematica_clipboard_temp.txt"}]},
  Export[tempClipboardFile, text, "text"];
  Run["cat " <> tempClipboardFile <> " | pbcopy"];
  DeleteFile[tempClipboardFile];
  text
]