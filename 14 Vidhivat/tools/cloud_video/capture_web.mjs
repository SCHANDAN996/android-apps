import { chromium } from 'playwright';
import { readdir, rename } from 'node:fs/promises';

const outputDir = process.env.RECORDING_DIR || 'recording';
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  viewport: { width: 360, height: 640 },
  deviceScaleFactor: 2,
  recordVideo: {
    dir: outputDir,
    size: { width: 720, height: 1280 },
  },
});

const page = await context.newPage();
await page.goto('http://127.0.0.1:8080', { waitUntil: 'networkidle' });
await page.waitForTimeout(2500);

const skipLocation = page.getByRole('button', { name: 'अभी नहीं' });
if (await skipLocation.count()) {
  await skipLocation.click();
}
await page.waitForTimeout(8000);

await page.close();
await context.close();
await browser.close();

const videos = (await readdir(outputDir)).filter((file) => file.endsWith('.webm'));
if (videos.length !== 1) {
  throw new Error(`Expected one web recording, found: ${videos.join(', ') || 'none'}`);
}
await rename(`${outputDir}/${videos[0]}`, `${outputDir}/vidhivat-web-emulator.webm`);
