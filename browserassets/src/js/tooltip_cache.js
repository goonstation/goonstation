const CACHE_VERSION = {{CDN_VERSION}};
const CURRENT_CACHES = {
	tooltips: "tooltips-cache-v" + CACHE_VERSION,
};

self.addEventListener("activate", (event) => {
	const expectedCacheNamesSet = new Set(Object.values(CURRENT_CACHES));
	event.waitUntil(
		(async () => {
			for (const cacheName of await caches.keys()) {
				if (!expectedCacheNamesSet.has(cacheName)) {
					await caches.delete(cacheName);
				}
			}
		})(),
	);
});

self.addEventListener("fetch", (event) => {
	if (!event.request.url.endsWith(".eta")) return;

	event.respondWith(
		(async () => {
			const cache = await caches.open(CURRENT_CACHES.tooltips);
			let response = await cache.match(event.request);
			if (response) return response;

			response = await fetch(event.request.clone());
			if (response.ok) cache.put(event.request, response.clone());
			return response;
		})(),
	);
});
