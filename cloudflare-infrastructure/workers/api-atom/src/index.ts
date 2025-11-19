/**
 * ATOM Trail Query API Worker
 * ATOM: ATOM-WORKER-20251116-001
 *
 * Provides REST API for querying ATOM trails from D1 database
 */

export interface Env {
	DB: D1Database;
	SESSIONS: KVNamespace;
}

export default {
	async fetch(request: Request, env: Env): Promise<Response> {
		const url = new URL(request.url);
		const path = url.pathname;

		// CORS headers
		const corsHeaders = {
			'Access-Control-Allow-Origin': '*',
			'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
			'Access-Control-Allow-Headers': 'Content-Type, Authorization',
		};

		if (request.method === 'OPTIONS') {
			return new Response(null, { headers: corsHeaders });
		}

		try {
			// Route handling
			if (path === '/api/atom/recent') {
				return handleRecentTrails(env, corsHeaders);
			} else if (path === '/api/atom/search') {
				return handleSearch(url, env, corsHeaders);
			} else if (path.startsWith('/api/atom/tag/')) {
				const tag = path.split('/').pop();
				return handleGetByTag(tag!, env, corsHeaders);
			} else if (path === '/api/atom/stats') {
				return handleStats(env, corsHeaders);
			} else {
				return new Response('Not Found', { status: 404, headers: corsHeaders });
			}
		} catch (error) {
			return new Response(`Error: ${(error as Error).message}`, {
				status: 500,
				headers: corsHeaders,
			});
		}
	},
};

/**
 * Get recent ATOM trails (last 100)
 */
async function handleRecentTrails(env: Env, headers: Record<string, string>): Promise<Response> {
	const result = await env.DB.prepare(
		'SELECT * FROM v_recent_atom_trails'
	).all();

	return new Response(JSON.stringify(result.results), {
		headers: { ...headers, 'Content-Type': 'application/json' },
	});
}

/**
 * Search ATOM trails by keyword
 */
async function handleSearch(url: URL, env: Env, headers: Record<string, string>): Promise<Response> {
	const query = url.searchParams.get('q');
	if (!query) {
		return new Response('Missing query parameter', { status: 400, headers });
	}

	const result = await env.DB.prepare(
		'SELECT tag, type, timestamp, description FROM atom_trails WHERE description LIKE ? ORDER BY timestamp DESC LIMIT 50'
	).bind(`%${query}%`).all();

	return new Response(JSON.stringify(result.results), {
		headers: { ...headers, 'Content-Type': 'application/json' },
	});
}

/**
 * Get ATOM trail by tag
 */
async function handleGetByTag(tag: string, env: Env, headers: Record<string, string>): Promise<Response> {
	const result = await env.DB.prepare(
		'SELECT * FROM atom_trails WHERE tag = ?'
	).bind(tag).first();

	if (!result) {
		return new Response('Not Found', { status: 404, headers });
	}

	return new Response(JSON.stringify(result), {
		headers: { ...headers, 'Content-Type': 'application/json' },
	});
}

/**
 * Get ATOM trail statistics
 */
async function handleStats(env: Env, headers: Record<string, string>): Promise<Response> {
	const totalResult = await env.DB.prepare(
		'SELECT COUNT(*) as total FROM atom_trails'
	).first();

	const byTypeResult = await env.DB.prepare(
		'SELECT type, COUNT(*) as count FROM atom_trails GROUP BY type'
	).all();

	const recentFailuresResult = await env.DB.prepare(
		'SELECT COUNT(*) as count FROM v_failed_operations'
	).first();

	const stats = {
		total: totalResult?.total || 0,
		by_type: byTypeResult.results,
		recent_failures: recentFailuresResult?.count || 0,
	};

	return new Response(JSON.stringify(stats), {
		headers: { ...headers, 'Content-Type': 'application/json' },
	});
}
