/**
 * Centralized Logging Worker
 * ATOM: ATOM-WORKER-20251116-002
 *
 * Logs all ATOM trail entries to Analytics Engine for querying
 */

export interface Env {
	ANALYTICS: AnalyticsEngineDataset;
	DB: D1Database;
}

export default {
	async fetch(request: Request, env: Env): Promise<Response> {
		if (request.method !== 'POST') {
			return new Response('Method Not Allowed', { status: 405 });
		}

		try {
			const body = await request.json<ATOMLogEntry>();

			// Validate required fields
			if (!body.tag || !body.type || !body.description) {
				return new Response('Missing required fields', { status: 400 });
			}

			// Write to Analytics Engine
			env.ANALYTICS.writeDataPoint({
				blobs: [
					body.tag,           // blob1: ATOM tag
					body.type,          // blob2: type (CFG, DEPLOY, etc.)
					body.description,   // blob3: description
					body.user || '',    // blob4: username
				],
				doubles: [
					Date.now(),         // double1: timestamp
					body.exit_code || 0, // double2: exit code
				],
				indexes: [body.type], // index1: for filtering by type
			});

			// Also write to D1 for persistence
			await env.DB.prepare(
				`INSERT INTO atom_trails (
					tag, type, date, sequence, timestamp, user, hostname,
					description, command, validation_status, exit_code, hash
				) VALUES (?, ?, ?, ?, datetime('now'), ?, ?, ?, ?, 'executed', ?, ?)`
			).bind(
				body.tag,
				body.type,
				body.date || new Date().toISOString().split('T')[0],
				body.sequence || 1,
				body.user || 'system',
				body.hostname || 'unknown',
				body.description,
				body.command || '',
				body.exit_code || 0,
				body.hash || ''
			).run();

			return new Response('Logged', { status: 200 });
		} catch (error) {
			return new Response(`Error: ${(error as Error).message}`, { status: 500 });
		}
	},
};

interface ATOMLogEntry {
	tag: string;
	type: string;
	date?: string;
	sequence?: number;
	description: string;
	command?: string;
	user?: string;
	hostname?: string;
	exit_code?: number;
	hash?: string;
}
