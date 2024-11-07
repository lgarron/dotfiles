#!/usr/bin/env bun

import { Glob, argv } from "bun";
import { JSDOM } from "jsdom";

const dom = new JSDOM(
  `<!DOCTYPE html>
<html>

<head>
  <meta charset="utf8">
  <title>Index</title>
  <!-- From: https://github.com/lgarron/minimal-html-style (v1.0.0) -->
  <meta name="viewport" content="width=device-width, initial-scale=0.75">
  <style>
    :root {
      color-scheme: light dark;
    }

    html {
      font-family: -apple-system, Roboto, Ubuntu, Tahoma, sans-serif;
      font-size: 1.25rem;
      padding: 2em;
      display: grid;
      justify-content: center;
    }

    body {
      width: 100%;
      max-width: 40em;
      margin: 0;
    }

    table a:not(:hover) {
      text-decoration: none;
    }

    td {
        border: 1px solid;
        padding: 0.5em;
    }

    table {
      border-collapse: collapse;
    }
  </style>
</head>

<body>
  <!--h1></h1-->
  <p>Files</p>
  <table>
    <thead>
      <tr>
        <th>File</th>
        <th>Size</th>
      </tr>
    </thead>
    <tbody></tbody>
  </table>
  <br>
  <p>Files are encoded using HEVC. <a href="https://lgarron-public-media.s3.amazonaws.com/about/HEVC.html">See here for more details.</a></p>
</body>

</html>
`,
);

const { document, XMLSerializer } = dom.window;

const GiB = 1024 ** 3;
function showGiB(bytes: number): string {
  const deciGiB = Math.floor((bytes / GiB) * 10);
  return `${Math.floor(deciGiB / 10)}.${Math.floor(deciGiB % 10)}\xa0GiB`;
}

const tbody = document.querySelector("tbody");
// The list of movie extensions is hardcoded for now.
// TODO: warn on less compatible extensions.
for await (const fileName of new Glob("*.{mov,mp4}").scan()) {
  const tr = tbody.appendChild(document.createElement("tr"));
  const filenameTD = tr.appendChild(document.createElement("td"));
  const a = filenameTD.appendChild(document.createElement("a"));
  a.href = encodeURI(fileName);
  a.download = fileName;
  const code = a.appendChild(document.createElement("code"));
  code.textContent = fileName;
  tbody.append("\n");
  const fileSizeTD = tr.appendChild(document.createElement("td"));
  fileSizeTD.append(showGiB(Bun.file(fileName).size));
}

console.log(new XMLSerializer().serializeToString(document));
