import fs from "fs";
import path from "path";
import * as cheerio from "cheerio";
import * as recast from "recast";
import * as babelParser from "@babel/parser";

// ---------- Patch Functions ----------

function patchHTML() {
  const htmlPath = path.resolve("src/app.html");
  if (!fs.existsSync(htmlPath)) throw new Error("HTML file not found");

  const html = fs.readFileSync(htmlPath, "utf8");
  const $ = cheerio.load(html, { decodeEntities: false });
  const script = $("head > script").first();

  let scriptContent = script.html();
  if (!scriptContent) throw new Error("No script tag found in HTML");

  let applied = false;

  if (!scriptContent.includes('localStorage.setItem("theme", "light");')) {
    scriptContent = scriptContent.replace(
      /try\s*{/,
      `try {\n\tlocalStorage.setItem("theme", "light");`
    );
    script.html(scriptContent);
    applied = true;
    console.log("Applied HTML script patch");
  }

  if ($("head > style:contains('nav.grid > div:nth-child(3)')").length === 0) {
    $("head").append(`
      <style>
        nav.grid > div:nth-child(3) {
          display: none !important;
        }
      </style>
    `);
    applied = true;
    console.log("Applied HTML style patch");
  }

  if (applied) fs.writeFileSync(htmlPath, $.html(), "utf8");
  return applied;
}

function patchEnv() {
  const envPath = path.resolve(".env");
  let envContent = fs.existsSync(envPath)
    ? fs.readFileSync(envPath, "utf8")
    : "";
  const envVars = {
    PUBLIC_APP_NAME: `"Kairos AI"`,
    PUBLIC_APP_TITLE: `"Kairos AI - Trading Mentor"`,
    PUBLIC_APP_DESCRIPTION: `"Identify optimal market opportunities with AI intelligence"`,
  };

  let applied = false;

  for (const [key, value] of Object.entries(envVars)) {
    if (!envContent.includes(`${key}=${value}`)) {
      const regex = new RegExp(`^${key}=.*$`, "m");
      if (regex.test(envContent))
        envContent = envContent.replace(regex, `${key}=${value}`);
      else
        envContent +=
          (envContent.endsWith("\n") ? "" : "\n") + `${key}=${value}\n`;
      applied = true;
      console.log(`Applied .env variable patch: ${key}`);
    }
  }

  if (applied) fs.writeFileSync(envPath, envContent.trimEnd() + "\n", "utf8");
  return applied;
}

function patchEnvLocal() {
  const envLocalPath = path.resolve(".env.local");
  let envLocalContent = fs.existsSync(envLocalPath)
    ? fs.readFileSync(envLocalPath, "utf8")
    : "";
  const localVars = {
    MONGODB_URL: `"mongodb://localhost:27017/"`,
  };

  let applied = false;

  for (const [key, value] of Object.entries(localVars)) {
    if (!envLocalContent.includes(`${key}=${value}`)) {
      const regex = new RegExp(`^${key}=.*$`, "m");
      if (regex.test(envLocalContent))
        envLocalContent = envLocalContent.replace(regex, `${key}=${value}`);
      else
        envLocalContent +=
          (envLocalContent.endsWith("\n") ? "" : "\n") + `${key}=${value}\n`;
      applied = true;
      console.log(`Applied .env.local variable patch: ${key}`);
    }
  }

  if (applied)
    fs.writeFileSync(envLocalPath, envLocalContent.trimEnd() + "\n", "utf8");
  return applied;
}

function patchViteConfig() {
  const viteConfigPath = path.resolve("vite.config.ts");
  if (!fs.existsSync(viteConfigPath))
    throw new Error("vite.config.ts not found");

  const viteCode = fs.readFileSync(viteConfigPath, "utf8");

  const ast = recast.parse(viteCode, {
    parser: {
      parse(source) {
        return babelParser.parse(source, {
          sourceType: "module",
          plugins: ["typescript", "jsx"],
        });
      },
    },
  });

  let applied = false;

  recast.types.visit(ast, {
    visitObjectExpression(path) {
      path.node.properties.forEach((prop) => {
        if (
          prop.type === "ObjectProperty" &&
          prop.key.type === "Identifier" &&
          prop.key.name === "server" &&
          prop.value.type === "ObjectExpression"
        ) {
          const keys = prop.value.properties.map((p) =>
            p.type === "ObjectProperty" && p.key.type === "Identifier"
              ? p.key.name
              : ""
          );
          if (!keys.includes("cors")) {
            prop.value.properties.push(
              recast.types.builders.objectProperty(
                recast.types.builders.identifier("cors"),
                recast.types.builders.objectExpression([
                  recast.types.builders.objectProperty(
                    recast.types.builders.identifier("origin"),
                    recast.types.builders.stringLiteral("http://localhost:3001")
                  ),
                  recast.types.builders.objectProperty(
                    recast.types.builders.identifier("methods"),
                    recast.types.builders.arrayExpression(
                      ["GET", "POST", "PUT", "DELETE", "OPTIONS"].map((m) =>
                        recast.types.builders.stringLiteral(m)
                      )
                    )
                  ),
                ])
              )
            );

            prop.value.properties.push(
              recast.types.builders.objectProperty(
                recast.types.builders.identifier("headers"),
                recast.types.builders.objectExpression([
                  recast.types.builders.objectProperty(
                    recast.types.builders.stringLiteral("X-Frame-Options"),
                    recast.types.builders.stringLiteral(
                      "ALLOW-FROM http://localhost:3001"
                    )
                  ),
                  recast.types.builders.objectProperty(
                    recast.types.builders.stringLiteral(
                      "Content-Security-Policy"
                    ),
                    recast.types.builders.stringLiteral(
                      "frame-ancestors http://localhost:3001"
                    )
                  ),
                ])
              )
            );

            applied = true;
            console.log("Applied vite.config.ts patch");
          }
        }
      });
      this.traverse(path);
    },
  });

  if (applied) fs.writeFileSync(viteConfigPath, recast.print(ast).code, "utf8");
  return applied;
}

// ---------- Main Flow ----------

try {
  patchHTML();
  patchEnv();
  patchEnvLocal();
  patchViteConfig();

  console.log("✅ Full Patch applied successfully");
} catch (err) {
  console.error("❌ Failed to apply patch");
  process.exit(1);
}
