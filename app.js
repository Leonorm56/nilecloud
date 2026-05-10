import "./config/env.js";
import "./startup.js";
import "./cron.js";

import AutoLoad from "@fastify/autoload";
import Fastify from "fastify";
import cors from "@fastify/cors";
import { fileURLToPath } from "node:url";
import jwt from "@fastify/jwt";
import path from "node:path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const fastify = Fastify({ logger: process.env.NODE_ENV !== "production" });

fastify.register(jwt, {
  secret: process.env.JWT_SECRET_KEY,
});

if (process.env.NODE_ENV !== "production") {
  await fastify.register(cors);
}

fastify.register(AutoLoad, {
  dir: path.join(__dirname, "plugins"),
  options: {},
});

fastify.register(AutoLoad, {
  dir: path.join(__dirname, "routes"),
  options: {},
});

await fastify.ready();
await fastify.listen({
  port: process.env.PORT || 3000,
  host: process.env.HOST || "0.0.0.0",
});
