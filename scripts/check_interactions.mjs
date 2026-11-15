#!/usr/bin/env node

/** Exercise every Observable input on the rendered model pages.
 *
 * Run after `quarto render`:
 *
 *   node scripts/check_interactions.mjs
 *   node scripts/check_interactions.mjs models/sir-model.html
 *   node scripts/check_interactions.mjs --base=https://example.netlify.app
 *
 * The existing check_pages.py catches errors at the default settings. This
 * checker also tries the minimum and maximum of sliders, every select/radio
 * option, and both states of toggles. It uses Chrome's DevTools protocol and
 * only Node built-ins, so it has no package dependencies.
 */

import {spawn} from "node:child_process";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import process from "node:process";
import {fileURLToPath} from "node:url";

const ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const SITE = path.join(ROOT, "_site");
const TIMEOUT = 20_000;
const SLOW_INTERACTION = 1_000;
const baseArgument = process.argv.find((arg) => arg.startsWith("--base="));
const REMOTE_BASE = baseArgument ? baseArgument.slice("--base=".length).replace(/\/$/, "") : null;

function chromePath() {
  const candidates = [
    process.env.CHROME,
    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/usr/bin/google-chrome",
    "/usr/bin/chromium",
  ].filter(Boolean);
  const found = candidates.find((candidate) => fs.existsSync(candidate));
  if (!found) throw new Error("Chrome not found. Set the CHROME environment variable.");
  return found;
}

function pagesFromArgs() {
  const requested = process.argv.slice(2).filter((arg) => !arg.startsWith("--"));
  if (requested.length) return requested.map((page) => page.replaceAll("\\", "/"));
  return fs.readdirSync(path.join(SITE, "models"))
    .filter((name) => name.endsWith(".html"))
    .sort()
    .map((name) => `models/${name}`);
}

const MIME = new Map([
  [".css", "text/css; charset=utf-8"],
  [".csv", "text/csv; charset=utf-8"],
  [".html", "text/html; charset=utf-8"],
  [".ico", "image/x-icon"],
  [".jpeg", "image/jpeg"],
  [".jpg", "image/jpeg"],
  [".js", "text/javascript; charset=utf-8"],
  [".json", "application/json; charset=utf-8"],
  [".png", "image/png"],
  [".svg", "image/svg+xml"],
  [".wasm", "application/wasm"],
  [".woff", "font/woff"],
  [".woff2", "font/woff2"],
]);

function startServer() {
  const siteRoot = path.resolve(SITE);
  const server = http.createServer((request, response) => {
    let pathname;
    try {
      pathname = decodeURIComponent(new URL(request.url, "http://localhost").pathname);
    } catch {
      response.writeHead(400).end("Bad request");
      return;
    }
    if (pathname.endsWith("/")) pathname += "index.html";
    const target = path.resolve(siteRoot, `.${pathname}`);
    if (target !== siteRoot && !target.startsWith(`${siteRoot}${path.sep}`)) {
      response.writeHead(403).end("Forbidden");
      return;
    }
    fs.readFile(target, (error, data) => {
      if (error) {
        response.writeHead(error.code === "ENOENT" ? 404 : 500).end(error.message);
        return;
      }
      response.writeHead(200, {"Content-Type": MIME.get(path.extname(target)) || "application/octet-stream"});
      response.end(data);
    });
  });
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => resolve(server));
  });
}

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function waitForFile(filename, timeout = TIMEOUT) {
  const deadline = Date.now() + timeout;
  while (Date.now() < deadline) {
    if (fs.existsSync(filename)) return;
    await delay(50);
  }
  throw new Error(`Timed out waiting for ${filename}`);
}

async function waitForProcess(child, timeout = 5_000) {
  if (child.exitCode !== null) return;
  await Promise.race([
    new Promise((resolve) => child.once("exit", resolve)),
    delay(timeout),
  ]);
}

async function removeProfile(profile) {
  for (let attempt = 0; attempt < 10; attempt++) {
    try {
      fs.rmSync(profile, {recursive: true, force: true});
      return;
    } catch (error) {
      if (error.code !== "EPERM" || attempt === 9) throw error;
      await delay(200);
    }
  }
}

async function connectCdp(webSocketUrl) {
  const socket = new WebSocket(webSocketUrl);
  await new Promise((resolve, reject) => {
    socket.addEventListener("open", resolve, {once: true});
    socket.addEventListener("error", reject, {once: true});
  });
  let nextId = 0;
  const pending = new Map();
  socket.addEventListener("message", (event) => {
    const message = JSON.parse(String(event.data));
    if (!message.id || !pending.has(message.id)) return;
    const {resolve, reject} = pending.get(message.id);
    pending.delete(message.id);
    if (message.error) reject(new Error(message.error.message));
    else resolve(message.result);
  });
  const call = (method, params = {}) => new Promise((resolve, reject) => {
    const id = ++nextId;
    pending.set(id, {resolve, reject});
    socket.send(JSON.stringify({id, method, params}));
  });
  return {socket, call};
}

async function evaluated(call, expression) {
  const result = await call("Runtime.evaluate", {
    expression,
    awaitPromise: true,
    returnByValue: true,
  });
  if (result.exceptionDetails) {
    const message = result.exceptionDetails.exception?.description || result.exceptionDetails.text;
    throw new Error(message);
  }
  return result.result.value;
}

async function waitForExpression(call, expression, timeout = TIMEOUT) {
  const deadline = Date.now() + timeout;
  while (Date.now() < deadline) {
    try {
      if (await evaluated(call, expression)) return;
    } catch {
      // Navigation can destroy the execution context between polls.
    }
    await delay(100);
  }
  throw new Error(`Timed out waiting for: ${expression}`);
}

const errorExpression = `Array.from(document.querySelectorAll(".observablehq--error"))
  .map((node) => node.textContent.replace(/\\s+/g, " ").trim()).filter(Boolean)`;

const controlsExpression = `(() => {
  const controls = Array.from(document.querySelectorAll(
    "main .observablehq input, main .observablehq select"
  )).filter((node) => !["button", "hidden", "submit"].includes(node.type));
  return controls.map((node, index) => {
    node.dataset.ojsCheck = String(index);
    const label = node.getAttribute("aria-label") || node.labels?.[0]?.textContent ||
      node.closest("label")?.textContent || node.name || node.tagName + " " + (index + 1);
    return {
      index,
      label: label.replace(/\\s+/g, " ").trim(),
      type: node.tagName === "SELECT" ? "select" : node.type,
      value: node.value,
      checked: node.checked,
      min: node.min,
      max: node.max,
      options: node.tagName === "SELECT" ? Array.from(node.options, (option) => option.value) : [],
    };
  });
})()`;

function statesFor(control) {
  if (control.type === "range") {
    return [...new Set([control.min, control.max].filter((value) => value !== "" && value !== control.value))]
      .map((value) => ({value}));
  }
  if (control.type === "select") {
    return control.options.filter((value) => value !== control.value).map((value) => ({value}));
  }
  if (control.type === "checkbox") {
    return [{checked: !control.checked}];
  }
  if (control.type === "radio" && !control.checked) return [{checked: true}];
  return [];
}

function actionExpression(control, state) {
  const selector = `[data-ojs-check="${control.index}"]`;
  const assignment = control.type === "checkbox" || control.type === "radio"
    ? `node.checked = ${Boolean(state.checked)};`
    : `node.value = ${JSON.stringify(state.value)};`;
  return `(async () => {
    const node = document.querySelector(${JSON.stringify(selector)});
    if (!node) return {changed: false, elapsed: 0};
    ${assignment}
    const start = performance.now();
    node.dispatchEvent(new Event("input", {bubbles: true}));
    await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    return {changed: true, elapsed: performance.now() - start};
  })()`;
}

function stateName(state) {
  return Object.hasOwn(state, "checked") ? String(state.checked) : JSON.stringify(state.value);
}

async function settle(call) {
  await evaluated(call, `new Promise((resolve) =>
    requestAnimationFrame(() => requestAnimationFrame(() => resolve(true))))`);
  await delay(50);
}

async function checkPage(call, base, page) {
  const url = `${base}/${page}`;
  await call("Page.navigate", {url});
  const expectedPath = `/${page}`;
  await waitForExpression(call, `location.pathname === ${JSON.stringify(expectedPath)} &&
    document.readyState === "complete" &&
    (document.querySelector("main svg[aria-label], main canvas[aria-label]") ||
     document.querySelector(".observablehq--error"))`);
  await settle(call);

  const problems = [];
  const defaults = await evaluated(call, errorExpression);
  for (const error of defaults) problems.push({label: "default settings", state: "default", error});
  if (defaults.length) return problems;

  const controls = await evaluated(call, controlsExpression);
  if (!controls.length) {
    problems.push({
      label: "page",
      state: "controls",
      error: "no Observable inputs were found",
    });
    return problems;
  }
  for (const control of controls) {
    for (const state of statesFor(control)) {
      const result = await evaluated(call, actionExpression(control, state));
      if (!result.changed) {
        problems.push({label: control.label, state: stateName(state), error: "control disappeared"});
        break;
      }
      if (result.elapsed > SLOW_INTERACTION) {
        problems.push({
          label: control.label,
          state: stateName(state),
          error: `interaction blocked rendering for ${Math.round(result.elapsed)} ms`,
        });
      }
      await settle(call);
      const errors = await evaluated(call, errorExpression);
      for (const error of errors) {
        problems.push({label: control.label, state: stateName(state), error});
      }
    }
    // Reloading restores all defaults and isolates the next control from the
    // boundary values tested above.
    if (statesFor(control).length) {
      await call("Page.navigate", {url});
      await waitForExpression(call, `location.pathname === ${JSON.stringify(expectedPath)} &&
        document.readyState === "complete" &&
        (document.querySelector("main svg[aria-label], main canvas[aria-label]") ||
         document.querySelector(".observablehq--error"))`);
      await settle(call);
      await evaluated(call, controlsExpression);
    }
  }
  return problems;
}

async function main() {
  if (!REMOTE_BASE && !fs.existsSync(SITE)) {
    throw new Error(`${SITE} not found. Run quarto render first.`);
  }
  const pages = pagesFromArgs();
  const server = REMOTE_BASE ? null : await startServer();
  const address = server?.address();
  const base = REMOTE_BASE || `http://127.0.0.1:${address.port}`;
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), "check-interactions-"));
  const chrome = spawn(chromePath(), [
    "--headless=new",
    "--disable-background-networking",
    "--disable-gpu",
    "--no-first-run",
    "--no-sandbox",
    "--remote-debugging-port=0",
    `--user-data-dir=${profile}`,
    "about:blank",
  ], {stdio: "ignore", windowsHide: true});

  let cdp;
  try {
    const portFile = path.join(profile, "DevToolsActivePort");
    await waitForFile(portFile);
    const [port] = fs.readFileSync(portFile, "utf8").split(/\r?\n/);
    const targets = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
    const target = targets.find((item) => item.type === "page");
    if (!target) throw new Error("Chrome did not create a page target");
    cdp = await connectCdp(target.webSocketDebuggerUrl);
    await cdp.call("Page.enable");
    await cdp.call("Runtime.enable");

    let failed = 0;
    for (const page of pages) {
      let problems;
      try {
        problems = await checkPage(cdp.call, base, page);
      } catch (error) {
        problems = [{label: "page", state: "load", error: error.message}];
      }
      if (problems.length) {
        failed++;
        console.log(`FAIL ${page}`);
        for (const problem of problems) {
          console.log(`     ${problem.label} = ${problem.state}: ${problem.error.slice(0, 300)}`);
        }
      } else {
        console.log(`ok   ${page}`);
      }
    }
    console.log(`${pages.length} pages interaction-checked, ${failed} with problems`);
    process.exitCode = failed ? 1 : 0;
  } finally {
    if (cdp) {
      try {
        await cdp.call("Browser.close");
      } catch {
        // Chrome may close the socket before acknowledging Browser.close.
      }
      cdp.socket.close();
    }
    if (server) await new Promise((resolve) => server.close(resolve));
    await waitForProcess(chrome);
    if (chrome.exitCode === null) {
      chrome.kill();
      await waitForProcess(chrome);
    }
    await removeProfile(profile);
  }
}

main().catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
