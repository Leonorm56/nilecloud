import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import createRunner from "./Runner.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const farmers = {};

const vendorFarmersDir = path.join(
  __dirname,
  "../vendor/shared/farmers",
);
const localFarmersDir = __dirname;

const farmerFiles = [];

// Scan vendor farmers
if (fs.existsSync(vendorFarmersDir)) {
  farmerFiles.push(
    ...fs.readdirSync(vendorFarmersDir).filter((file) => file.endsWith(".js")).map((f) => path.join(vendorFarmersDir, f)),
  );
}

// Scan local farmers
farmerFiles.push(
  ...fs.readdirSync(localFarmersDir).filter((file) => file.endsWith(".js") && file !== "index.js" && file !== "Runner.js").map((f) => path.join(localFarmersDir, f)),
);

for (const file of farmerFiles) {
  const FarmerClass = await import(file).then(
    (m) => m.default,
  );

  if (FarmerClass.published) {
    farmers[FarmerClass.id] = createRunner(FarmerClass);
  }
}

export default farmers;
