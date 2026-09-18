import { chromium } from 'playwright';
import { readdir, rename } from 'node:fs/promises';

const outputDir = process.env.RECORDING_DIR || 'recording';
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  viewport: { width: 720, height: 1280 },
  deviceScaleFactor: 1,
  recordVideo: {
    dir: outputDir,
    size: { width: 720, height: 1280 },
  },
});

const page = await context.newPage();
await page.goto('http://127.0.0.1:8080', { waitUntil: 'networkidle' });
await page.waitForTimeout(2500);

// Flutter web paints this dialog on a canvas. The upper-right text is “अभी नहीं”.
await page.mouse.click(610, 680);
await page.waitForTimeout(3000);

// Open the featured puja card to give the recording a visible app transition.
await page.mouse.click(190, 298);
await page.waitForTimeout(8000);

await page.close();
await context.close();
await browser.close();

const videos = (await readdir(outputDir)).filter((file) => file.endsWith('.webm'));
if (videos.length !== 1) {
  throw new Error(`Expected one web recording, found: ${videos.join(', ') || 'none'}`);
}
await rename(`${outputDir}/${videos[0]}`, `${outputDir}/vidhivat-web-emulator.webm`);
