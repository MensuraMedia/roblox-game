#!/usr/bin/env node
// =============================================================================
// Roblox Open Cloud API Helper
// =============================================================================
// Provides programmatic access to Roblox Open Cloud API operations.
// Reads credentials from ../.env (gitignored).
//
// Usage:
//   node tools/roblox-api.js publish              # Publish game
//   node tools/roblox-api.js get-place-info        # Get place metadata
//   node tools/roblox-api.js list-versions         # List place versions
//   node tools/roblox-api.js get-universe-info     # Get universe metadata
//   node tools/roblox-api.js datastore-list        # List DataStores
//   node tools/roblox-api.js datastore-get <name> <key>  # Get DataStore entry
//   node tools/roblox-api.js datastore-set <name> <key> <value>  # Set DataStore entry
//
// All API key handling is secure — read from .env, never logged.
// =============================================================================

const fs = require("fs");
const path = require("path");
const https = require("https");

const PROJECT_ROOT = path.resolve(__dirname, "..");
const ENV_FILE = path.join(PROJECT_ROOT, ".env");
const BUILD_FILE = path.join(PROJECT_ROOT, "build", "game.rbxl");

// Load .env
function loadEnv() {
	if (!fs.existsSync(ENV_FILE)) {
		console.error("[ERROR] .env file not found at", ENV_FILE);
		process.exit(1);
	}
	const lines = fs.readFileSync(ENV_FILE, "utf8").split("\n");
	for (const line of lines) {
		const trimmed = line.trim();
		if (trimmed && !trimmed.startsWith("#")) {
			const eqIdx = trimmed.indexOf("=");
			if (eqIdx > 0) {
				const key = trimmed.substring(0, eqIdx).trim();
				const value = trimmed.substring(eqIdx + 1).trim();
				process.env[key] = value;
			}
		}
	}
}

function getEnv(key, required = true) {
	const val = process.env[key];
	if (!val && required) {
		console.error(`[ERROR] ${key} not set in .env`);
		process.exit(1);
	}
	return val;
}

// HTTPS request helper
function apiRequest(method, urlStr, headers = {}, body = null) {
	return new Promise((resolve, reject) => {
		const url = new URL(urlStr);
		const options = {
			hostname: url.hostname,
			port: 443,
			path: url.pathname + url.search,
			method: method,
			headers: {
				"x-api-key": getEnv("ROBLOX_OPEN_CLOUD_API_KEY"),
				...headers,
			},
		};

		const req = https.request(options, (res) => {
			let data = "";
			res.on("data", (chunk) => (data += chunk));
			res.on("end", () => {
				resolve({
					status: res.statusCode,
					headers: res.headers,
					body: data,
				});
			});
		});

		req.on("error", reject);
		if (body) req.write(body);
		req.end();
	});
}

// Commands
const commands = {
	async publish() {
		const universeId = getEnv("ROBLOX_UNIVERSE_ID");
		const placeId = getEnv("ROBLOX_PLACE_ID");

		if (!fs.existsSync(BUILD_FILE)) {
			console.error("[ERROR] Build file not found. Run: rojo build -o build/game.rbxl");
			process.exit(1);
		}

		const fileData = fs.readFileSync(BUILD_FILE);
		console.log(`[INFO] Publishing ${BUILD_FILE} (${fileData.length} bytes)`);
		console.log(`[INFO] Universe: ${universeId} | Place: ${placeId}`);

		const res = await apiRequest(
			"POST",
			`https://apis.roblox.com/universes/v1/${universeId}/places/${placeId}/versions?versionType=Published`,
			{ "Content-Type": "application/octet-stream" },
			fileData
		);

		if (res.status === 200) {
			console.log("[OK] Published successfully!");
			console.log("[INFO]", res.body);
		} else {
			console.error(`[ERROR] Publish failed (HTTP ${res.status})`);
			console.error("[ERROR]", res.body);
			process.exit(1);
		}
	},

	async "get-place-info"() {
		const universeId = getEnv("ROBLOX_UNIVERSE_ID");
		const placeId = getEnv("ROBLOX_PLACE_ID");

		const res = await apiRequest(
			"GET",
			`https://apis.roblox.com/universes/v1/${universeId}/places/${placeId}`
		);

		console.log(`[HTTP ${res.status}]`);
		try {
			console.log(JSON.stringify(JSON.parse(res.body), null, 2));
		} catch {
			console.log(res.body);
		}
	},

	async "list-versions"() {
		const universeId = getEnv("ROBLOX_UNIVERSE_ID");
		const placeId = getEnv("ROBLOX_PLACE_ID");

		const res = await apiRequest(
			"GET",
			`https://apis.roblox.com/universes/v1/${universeId}/places/${placeId}/versions?sortOrder=Desc&limit=10`
		);

		console.log(`[HTTP ${res.status}]`);
		try {
			console.log(JSON.stringify(JSON.parse(res.body), null, 2));
		} catch {
			console.log(res.body);
		}
	},

	async "get-universe-info"() {
		const universeId = getEnv("ROBLOX_UNIVERSE_ID");

		const res = await apiRequest(
			"GET",
			`https://apis.roblox.com/universes/v1/${universeId}`
		);

		console.log(`[HTTP ${res.status}]`);
		try {
			console.log(JSON.stringify(JSON.parse(res.body), null, 2));
		} catch {
			console.log(res.body);
		}
	},

	async "datastore-list"() {
		const universeId = getEnv("ROBLOX_UNIVERSE_ID");

		const res = await apiRequest(
			"GET",
			`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores?limit=100`
		);

		console.log(`[HTTP ${res.status}]`);
		try {
			console.log(JSON.stringify(JSON.parse(res.body), null, 2));
		} catch {
			console.log(res.body);
		}
	},

	async "datastore-get"() {
		const universeId = getEnv("ROBLOX_UNIVERSE_ID");
		const datastoreName = process.argv[3];
		const key = process.argv[4];

		if (!datastoreName || !key) {
			console.error("Usage: node roblox-api.js datastore-get <datastore-name> <key>");
			process.exit(1);
		}

		const res = await apiRequest(
			"GET",
			`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${encodeURIComponent(datastoreName)}&entryKey=${encodeURIComponent(key)}`
		);

		console.log(`[HTTP ${res.status}]`);
		try {
			console.log(JSON.stringify(JSON.parse(res.body), null, 2));
		} catch {
			console.log(res.body);
		}
	},

	async "datastore-set"() {
		const universeId = getEnv("ROBLOX_UNIVERSE_ID");
		const datastoreName = process.argv[3];
		const key = process.argv[4];
		const value = process.argv[5];

		if (!datastoreName || !key || !value) {
			console.error("Usage: node roblox-api.js datastore-set <datastore-name> <key> <json-value>");
			process.exit(1);
		}

		const res = await apiRequest(
			"POST",
			`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${encodeURIComponent(datastoreName)}&entryKey=${encodeURIComponent(key)}`,
			{ "Content-Type": "application/json" },
			value
		);

		console.log(`[HTTP ${res.status}]`);
		try {
			console.log(JSON.stringify(JSON.parse(res.body), null, 2));
		} catch {
			console.log(res.body);
		}
	},
};

// Main
async function main() {
	loadEnv();
	const command = process.argv[2] || "help";

	if (command === "help" || !commands[command]) {
		console.log("Roblox Open Cloud API Helper");
		console.log("============================");
		console.log("Available commands:");
		Object.keys(commands).forEach((cmd) => console.log(`  ${cmd}`));
		if (!commands[command] && command !== "help") {
			console.error(`\nUnknown command: ${command}`);
			process.exit(1);
		}
		return;
	}

	await commands[command]();
}

main().catch((err) => {
	console.error("[ERROR]", err.message);
	process.exit(1);
});
