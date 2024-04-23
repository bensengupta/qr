const WASM_FILE = "web/qr.wasm";

function renderQRCode(matrix, size) {
  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d");

  const canvasScale = 10;
  const canvasSize = canvasScale * size;

  canvas.width = canvasSize;
  canvas.height = canvasSize;

  ctx.scale(canvasScale, canvasScale);

  ctx.fillStyle = "white";
  ctx.fillRect(0, 0, size, size);

  ctx.fillStyle = "black";

  for (let r = 0; r < size; r++) {
    for (let c = 0; c < size; c++) {
      if (matrix[r * size + c] === 1) {
        ctx.fillRect(c, r, 1, 1);
      }
    }
  }

  const img = document.getElementById("qr-code");
  img.src = canvas.toDataURL("image/png");
  img.style.display = "block";
}

let qrResponse = { ptr: undefined, size: undefined };

function createQRCodeCallback(ptr, size) {
  qrResponse = { ptr, size };
}

async function initWasm() {
  const wasmImports = { env: { createQRCodeCallback } };
  const wasm = await WebAssembly.instantiateStreaming(
    fetch(WASM_FILE),
    wasmImports,
  );
  return wasm;
}

const wasmPromise = initWasm();

async function generateQRCode(message, ecLevel, qzoneSize) {
  const ecLevelInt = ["M", "L", "H", "Q"].indexOf(ecLevel);
  if (ecLevelInt === -1) {
    throw new Error(`Invalid error correction level: ${ecLevel}`);
  }

  const wasm = await wasmPromise;
  const { memory, createQRCode, allocUint8, freeUint8 } = wasm.instance.exports;

  const buffer = new TextEncoder().encode(message);
  const messagePtr = allocUint8(buffer.length + 1);
  const slice = new Uint8Array(memory.buffer, messagePtr, buffer.length + 1);
  slice.set(buffer);
  slice[buffer.length] = 0;

  createQRCode(messagePtr, ecLevelInt, qzoneSize);
  // createQRCodeCallback is called by the wasm module

  const matrix = new Uint8Array(
    memory.buffer,
    qrResponse.ptr,
    qrResponse.size * qrResponse.size,
  );
  renderQRCode(matrix, qrResponse.size);

  freeUint8(messagePtr, message.length);
  freeUint8(qrResponse.ptr, qrResponse.size * qrResponse.size);
}

function onSubmitForm(event) {
  event.preventDefault();
  const formData = new FormData(event.target);

  const message = formData.get("text");
  const ecLevel = formData.get("ec-level");
  const quietZoneSize = parseInt(formData.get("quiet-zone"));

  generateQRCode(message, ecLevel, quietZoneSize).catch(console.error);
}

const form = document.getElementById("qr-form");
form.addEventListener("submit", onSubmitForm);
