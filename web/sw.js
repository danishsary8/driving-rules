// Offline cache for the installed (Add to Home Screen) app.
//
// After one visit with internet, the app opens and works with no connection:
// every file of the build is cached when this worker installs, and requests
// are then served from the cache.
//
// `tool/build_service_worker.dart` fills in VERSION and PRECACHE after
// `flutter build web`. Each deploy gets a new VERSION, so browsers install the
// new worker, cache the new files in a fresh cache and delete the old one.
// Unfilled (e.g. `flutter run`), the worker does nothing.

const VERSION = '__SW_VERSION__';
const PRECACHE = /* __SW_PRECACHE__ */ [];

const CACHE = `driving-rules-${VERSION}`;
const ENABLED = !VERSION.startsWith('__');

// The rendering engine ships in several builds (one per browser family) under
// canvaskit/. Only the one this browser uses is cached: the page reports what it
// loaded, and a new version re-fetches whatever the previous one had.
const isEngineFile = (url) => new URL(url).pathname.includes('/canvaskit/');

self.addEventListener('install', (event) => {
  if (!ENABLED) return;
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE);
      // `reload` skips the HTTP cache so a deploy never mixes old and new files.
      await cache.addAll(PRECACHE.map((path) => new Request(path, { cache: 'reload' })));
      await cache.addAll(await engineFilesFromOlderCaches());
      await self.skipWaiting();
    })(),
  );
});

self.addEventListener('activate', (event) => {
  if (!ENABLED) return;
  event.waitUntil(
    (async () => {
      const names = await caches.keys();
      // Also removes the caches of Flutter's old, deprecated service worker.
      await Promise.all(names.filter((n) => n !== CACHE).map((n) => caches.delete(n)));
      await self.clients.claim();
    })(),
  );
});

self.addEventListener('fetch', (event) => {
  if (!ENABLED) return;
  const { request } = event;
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) return;

  // Pages: try the network first so an online visit sees the latest version,
  // fall back to the cached app shell when offline.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request).catch(async () => (await caches.match(request)) ?? caches.match('./')),
    );
    return;
  }

  // Everything else: cache first, then network (and keep a copy).
  event.respondWith(
    (async () => {
      const cached = await caches.match(request, { ignoreSearch: true });
      if (cached) return cached;
      const response = await fetch(request);
      if (response.ok) {
        const cache = await caches.open(CACHE);
        await cache.put(request, response.clone());
      }
      return response;
    })(),
  );
});

// The page sends the same-origin files it loaded (see index.html), so the
// engine build this browser actually uses is cached for offline starts.
self.addEventListener('message', (event) => {
  if (!ENABLED || event.data?.type !== 'cache-urls') return;
  const urls = (event.data.urls ?? []).filter(
    (u) => typeof u === 'string' && new URL(u).origin === self.location.origin,
  );
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE);
      for (const url of urls) {
        if (await cache.match(url, { ignoreSearch: true })) continue;
        try {
          const response = await fetch(url, { cache: 'reload' });
          if (response.ok) await cache.put(url, response);
        } catch (_) {
          // Offline right now: it is cached on a later online visit.
        }
      }
    })(),
  );
});

/** Engine files the previous version had cached, to fetch fresh for this one. */
async function engineFilesFromOlderCaches() {
  const urls = new Set();
  for (const name of await caches.keys()) {
    if (name === CACHE || !name.startsWith('driving-rules-')) continue;
    const old = await caches.open(name);
    for (const request of await old.keys()) {
      if (isEngineFile(request.url)) urls.add(request.url);
    }
  }
  return [...urls].map((u) => new Request(u, { cache: 'reload' }));
}
