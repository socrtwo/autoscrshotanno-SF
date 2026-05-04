"use strict";

const imgCanvas = document.getElementById("imgCanvas");
const drawCanvas = document.getElementById("drawCanvas");
const stage = document.getElementById("stage");
const emptyState = document.getElementById("emptyState");
const logPanel = document.getElementById("logPanel");
const logEntries = document.getElementById("logEntries");
const colorPicker = document.getElementById("colorPicker");
const strokeWidthInput = document.getElementById("strokeWidth");

const imgCtx = imgCanvas.getContext("2d");
const drawCtx = drawCanvas.getContext("2d");

const state = {
  baseImage: null,
  shapes: [],
  redo: [],
  tool: "select",
  drawing: false,
  start: null,
  current: null,
  log: [],
};

function setTool(tool) {
  state.tool = tool;
  document.querySelectorAll("#drawTools button[data-tool]").forEach(b => {
    b.classList.toggle("active", b.dataset.tool === tool);
  });
  drawCanvas.style.cursor = tool === "select" ? "default" : (tool === "text" ? "text" : "crosshair");
}

document.querySelectorAll("#drawTools button[data-tool]").forEach(b => {
  b.addEventListener("click", () => setTool(b.dataset.tool));
});

function logEvent(msg) {
  const ts = new Date().toLocaleTimeString();
  state.log.push({ ts, msg });
  const entry = document.createElement("div");
  entry.className = "entry";
  entry.innerHTML = `<span class="ts">${ts}</span>${escapeHtml(msg)}`;
  logEntries.prepend(entry);
  logPanel.classList.remove("hidden");
}

function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, c => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  }[c]));
}

async function captureScreen() {
  if (!navigator.mediaDevices || !navigator.mediaDevices.getDisplayMedia) {
    alert("Screen capture not supported in this browser. Try opening or pasting an image instead.");
    return;
  }
  try {
    const stream = await navigator.mediaDevices.getDisplayMedia({
      video: { cursor: "always" },
      audio: false,
    });
    const track = stream.getVideoTracks()[0];
    const video = document.createElement("video");
    video.srcObject = stream;
    await video.play();
    await new Promise(r => setTimeout(r, 100));
    const w = video.videoWidth;
    const h = video.videoHeight;
    const tmp = document.createElement("canvas");
    tmp.width = w; tmp.height = h;
    tmp.getContext("2d").drawImage(video, 0, 0, w, h);
    track.stop();
    const img = new Image();
    img.onload = () => loadImage(img);
    img.src = tmp.toDataURL("image/png");
    logEvent(`Captured screen (${w}×${h})`);
  } catch (err) {
    if (err.name !== "NotAllowedError") {
      console.error(err);
      alert("Capture failed: " + err.message);
    }
  }
}

function loadImage(img) {
  state.baseImage = img;
  state.shapes = [];
  state.redo = [];
  const maxW = window.innerWidth - 60;
  const maxH = window.innerHeight - 160;
  let w = img.naturalWidth;
  let h = img.naturalHeight;
  const scale = Math.min(1, maxW / w, maxH / h);
  const dispW = Math.round(w * scale);
  const dispH = Math.round(h * scale);
  imgCanvas.width = dispW; imgCanvas.height = dispH;
  drawCanvas.width = dispW; drawCanvas.height = dispH;
  stage.style.width = dispW + "px";
  stage.style.height = dispH + "px";
  imgCtx.drawImage(img, 0, 0, dispW, dispH);
  emptyState.style.display = "none";
  stage.style.display = "block";
  redrawAnnotations();
}

function loadFromFile(file) {
  const reader = new FileReader();
  reader.onload = e => {
    const img = new Image();
    img.onload = () => {
      loadImage(img);
      logEvent(`Loaded image: ${file.name}`);
    };
    img.src = e.target.result;
  };
  reader.readAsDataURL(file);
}

document.getElementById("fileInput").addEventListener("change", e => {
  const f = e.target.files[0];
  if (f) loadFromFile(f);
});

document.getElementById("btnCapture").addEventListener("click", captureScreen);

document.getElementById("btnPaste").addEventListener("click", async () => {
  try {
    const items = await navigator.clipboard.read();
    for (const item of items) {
      for (const type of item.types) {
        if (type.startsWith("image/")) {
          const blob = await item.getType(type);
          const img = new Image();
          img.onload = () => {
            loadImage(img);
            logEvent("Pasted image from clipboard");
          };
          img.src = URL.createObjectURL(blob);
          return;
        }
      }
    }
    alert("No image found in clipboard.");
  } catch (err) {
    alert("Clipboard read failed. Try copying an image first, or use Ctrl+V on the page.");
  }
});

window.addEventListener("paste", e => {
  const items = e.clipboardData?.items || [];
  for (const it of items) {
    if (it.type.startsWith("image/")) {
      const blob = it.getAsFile();
      const img = new Image();
      img.onload = () => {
        loadImage(img);
        logEvent("Pasted image from clipboard");
      };
      img.src = URL.createObjectURL(blob);
      e.preventDefault();
      return;
    }
  }
});

function getPointerPos(e) {
  const rect = drawCanvas.getBoundingClientRect();
  const t = e.touches ? e.touches[0] : e;
  return {
    x: (t.clientX - rect.left) * (drawCanvas.width / rect.width),
    y: (t.clientY - rect.top) * (drawCanvas.height / rect.height),
  };
}

drawCanvas.addEventListener("pointerdown", e => {
  if (!state.baseImage) return;
  if (state.tool === "select") return;
  drawCanvas.setPointerCapture(e.pointerId);
  state.drawing = true;
  const p = getPointerPos(e);
  state.start = p;
  state.current = p;
  if (state.tool === "pen") {
    state.shapes.push({
      type: "pen",
      points: [p],
      color: colorPicker.value,
      width: parseInt(strokeWidthInput.value, 10),
    });
  } else if (state.tool === "text") {
    const txt = prompt("Text:");
    if (txt) {
      state.shapes.push({
        type: "text",
        x: p.x, y: p.y, text: txt,
        color: colorPicker.value,
        size: parseInt(strokeWidthInput.value, 10) * 6 + 12,
      });
      state.redo = [];
      redrawAnnotations();
    }
    state.drawing = false;
  }
});

drawCanvas.addEventListener("pointermove", e => {
  if (!state.drawing) return;
  const p = getPointerPos(e);
  state.current = p;
  if (state.tool === "pen") {
    state.shapes[state.shapes.length - 1].points.push(p);
  }
  redrawAnnotations(true);
});

drawCanvas.addEventListener("pointerup", () => {
  if (!state.drawing) return;
  if (state.tool === "rect" || state.tool === "ellipse" || state.tool === "arrow" || state.tool === "blur") {
    state.shapes.push({
      type: state.tool,
      x1: state.start.x, y1: state.start.y,
      x2: state.current.x, y2: state.current.y,
      color: colorPicker.value,
      width: parseInt(strokeWidthInput.value, 10),
    });
  }
  state.drawing = false;
  state.redo = [];
  redrawAnnotations();
});

function redrawAnnotations(includeLive = false) {
  drawCtx.clearRect(0, 0, drawCanvas.width, drawCanvas.height);
  const shapes = includeLive && state.drawing && state.tool !== "pen"
    ? [...state.shapes, {
        type: state.tool,
        x1: state.start.x, y1: state.start.y,
        x2: state.current.x, y2: state.current.y,
        color: colorPicker.value,
        width: parseInt(strokeWidthInput.value, 10),
      }]
    : state.shapes;

  for (const s of shapes) {
    drawCtx.strokeStyle = s.color || "#ff2e93";
    drawCtx.fillStyle = s.color || "#ff2e93";
    drawCtx.lineWidth = s.width || 3;
    drawCtx.lineCap = "round";
    drawCtx.lineJoin = "round";
    if (s.type === "pen") {
      drawCtx.beginPath();
      s.points.forEach((p, i) => i === 0 ? drawCtx.moveTo(p.x, p.y) : drawCtx.lineTo(p.x, p.y));
      drawCtx.stroke();
    } else if (s.type === "rect") {
      drawCtx.strokeRect(Math.min(s.x1, s.x2), Math.min(s.y1, s.y2), Math.abs(s.x2 - s.x1), Math.abs(s.y2 - s.y1));
    } else if (s.type === "ellipse") {
      drawCtx.beginPath();
      drawCtx.ellipse((s.x1 + s.x2) / 2, (s.y1 + s.y2) / 2, Math.abs(s.x2 - s.x1) / 2, Math.abs(s.y2 - s.y1) / 2, 0, 0, Math.PI * 2);
      drawCtx.stroke();
    } else if (s.type === "arrow") {
      drawArrow(s.x1, s.y1, s.x2, s.y2, s.width);
    } else if (s.type === "text") {
      drawCtx.font = `bold ${s.size}px Inter, system-ui, sans-serif`;
      drawCtx.textBaseline = "top";
      drawCtx.fillText(s.text, s.x, s.y);
    } else if (s.type === "blur") {
      const x = Math.min(s.x1, s.x2);
      const y = Math.min(s.y1, s.y2);
      const w = Math.abs(s.x2 - s.x1);
      const h = Math.abs(s.y2 - s.y1);
      if (w > 2 && h > 2) {
        const tile = Math.max(8, Math.floor(Math.min(w, h) / 12));
        const data = imgCtx.getImageData(x, y, w, h);
        const tmp = document.createElement("canvas");
        tmp.width = w; tmp.height = h;
        tmp.getContext("2d").putImageData(data, 0, 0);
        drawCtx.imageSmoothingEnabled = false;
        drawCtx.drawImage(tmp, 0, 0, w, h, x, y, Math.ceil(w / tile), Math.ceil(h / tile));
        drawCtx.drawImage(drawCanvas, x, y, Math.ceil(w / tile), Math.ceil(h / tile), x, y, w, h);
        drawCtx.imageSmoothingEnabled = true;
      }
    }
  }
}

function drawArrow(x1, y1, x2, y2, width) {
  const headLen = Math.max(10, width * 4);
  const angle = Math.atan2(y2 - y1, x2 - x1);
  drawCtx.beginPath();
  drawCtx.moveTo(x1, y1);
  drawCtx.lineTo(x2, y2);
  drawCtx.stroke();
  drawCtx.beginPath();
  drawCtx.moveTo(x2, y2);
  drawCtx.lineTo(x2 - headLen * Math.cos(angle - Math.PI / 6), y2 - headLen * Math.sin(angle - Math.PI / 6));
  drawCtx.lineTo(x2 - headLen * Math.cos(angle + Math.PI / 6), y2 - headLen * Math.sin(angle + Math.PI / 6));
  drawCtx.closePath();
  drawCtx.fill();
}

document.getElementById("btnUndo").addEventListener("click", undo);
document.getElementById("btnClear").addEventListener("click", () => {
  if (state.shapes.length && confirm("Clear all annotations?")) {
    state.redo = state.shapes.slice();
    state.shapes = [];
    redrawAnnotations();
  }
});

function undo() {
  if (state.shapes.length) {
    state.redo.push(state.shapes.pop());
    redrawAnnotations();
  }
}

function flatten() {
  const out = document.createElement("canvas");
  out.width = imgCanvas.width;
  out.height = imgCanvas.height;
  const c = out.getContext("2d");
  c.drawImage(imgCanvas, 0, 0);
  c.drawImage(drawCanvas, 0, 0);
  return out;
}

document.getElementById("btnDownload").addEventListener("click", () => {
  if (!state.baseImage) return;
  const out = flatten();
  out.toBlob(blob => {
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = `screenshot-${Date.now()}.png`;
    a.click();
    URL.revokeObjectURL(a.href);
    logEvent("Saved annotated PNG");
  }, "image/png");
});

document.getElementById("btnCopy").addEventListener("click", async () => {
  if (!state.baseImage) return;
  try {
    const out = flatten();
    out.toBlob(async blob => {
      await navigator.clipboard.write([new ClipboardItem({ "image/png": blob })]);
      logEvent("Copied to clipboard");
    }, "image/png");
  } catch (err) {
    alert("Clipboard write failed: " + err.message);
  }
});

document.getElementById("btnExportLog").addEventListener("click", () => {
  if (!state.baseImage && state.log.length === 0) {
    alert("Nothing to export yet.");
    return;
  }
  const out = flatten();
  const dataUrl = out.toDataURL("image/png");
  const html = `<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Screenshot Log</title>
<style>body{font-family:system-ui,sans-serif;max-width:900px;margin:40px auto;padding:20px;background:#0f0322;color:#f5f3ff}
h1{background:linear-gradient(90deg,#ff2e93,#22d3ee);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
img{max-width:100%;border-radius:8px;box-shadow:0 10px 30px rgba(0,0,0,.5);margin:20px 0}
.entry{padding:8px 0;border-bottom:1px solid rgba(255,255,255,.1)}
.ts{color:#22d3ee;font-family:monospace;margin-right:10px}</style></head>
<body><h1>Screenshot Log</h1>
<p>Generated ${new Date().toLocaleString()}</p>
<img src="${dataUrl}" alt="screenshot">
<h2>Events</h2>
${state.log.map(e => `<div class="entry"><span class="ts">${e.ts}</span>${escapeHtml(e.msg)}</div>`).join("")}
</body></html>`;
  const blob = new Blob([html], { type: "text/html" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = `screenshot-log-${Date.now()}.html`;
  a.click();
  URL.revokeObjectURL(a.href);
  logEvent("Exported HTML log");
});

document.addEventListener("keydown", e => {
  const mod = e.ctrlKey || e.metaKey;
  if (!mod) return;
  if (e.key === "z" || e.key === "Z") { e.preventDefault(); undo(); }
  else if (e.key === "s" || e.key === "S") { e.preventDefault(); document.getElementById("btnDownload").click(); }
  else if ((e.key === "c" || e.key === "C") && e.altKey) { e.preventDefault(); captureScreen(); }
});

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("service-worker.js").catch(() => {});
  });
}
