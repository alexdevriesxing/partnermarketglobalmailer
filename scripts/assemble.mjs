import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('..', import.meta.url));

async function assemble(sourceDirectory, outputFile) {
  const sourcePath = resolve(root, sourceDirectory);
  const outputPath = resolve(root, outputFile);
  const parts = (await readdir(sourcePath))
    .filter((name) => name.endsWith('.part'))
    .sort((a, b) => a.localeCompare(b, 'en', { numeric: true }));

  if (!parts.length) throw new Error(`No source parts found in ${sourceDirectory}`);
  const contents = await Promise.all(parts.map((part) => readFile(resolve(sourcePath, part), 'utf8')));
  await mkdir(dirname(outputPath), { recursive: true });
  await writeFile(outputPath, contents.join(''), 'utf8');
  console.log(`Assembled ${parts.length} parts → ${outputFile}`);
}

await assemble('source-parts/worker', 'src/index.ts');
await assemble('source-parts/browser', 'public/app.js');
