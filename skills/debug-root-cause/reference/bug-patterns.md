# Bug patterns: where to look first

Match the symptom, then test the listed suspects in order. They're ordered roughly cheapest-to-check first.

## "It worked yesterday"

1. Run `scripts/what_changed.sh "2 days ago"` and read the commits, dependency bumps and config changes.
2. Look for a lockfile change without a matching code change: a transitive dependency moved.
3. Check env vars and secrets changed in the deploy platform, which git doesn't show.
4. If you have a good commit and a bad one, use `git bisect start; git bisect bad; git bisect good <sha>`.

## Works locally, fails in CI (or the other way round)

- **Versions:** compare Node/Python/etc. and the lockfile. Is CI using `npm ci` while you use `npm install`?
- **Env:** a variable set in your shell or `.env` but missing in CI.
- **OS:** case-sensitive paths (`Button.tsx` vs `button.tsx` passes on macOS, fails on Linux), line endings, `/tmp`.
- **Time zone and locale:** CI runs in UTC with an English locale.
- **Order and state:** tests pass alone but fail together because of shared DB rows, globals or a leftover file.
- **Network:** CI can't reach a service, or rate limits kick in.

## Flaky test (sometimes passes)

- Run it in a loop until it fails: `for i in $(seq 50); do <test cmd> || break; done`.
- **Timing:** `sleep`, fixed timeouts, or not awaiting a promise. Wait for the condition instead.
- **Order:** run with a random or reversed order and look for shared state between tests.
- **Time:** `new Date()` near midnight, month ends, DST. Freeze the clock in tests.
- **Randomness:** unseeded random data, or unordered results from a DB query with no `ORDER BY`.
- **Parallelism:** two workers using the same port, file or DB.

## Wrong number, total or price

- **Units:** piasters vs pounds, cents vs dollars, ms vs s, bytes vs KB.
- **Floats:** `0.1 + 0.2 !== 0.3`. Use integer minor units or a decimal type for money.
- **Rounding:** rounding at each line vs once on the total, and which rounding mode.
- **Types:** `"10" + 5 === "105"`. Check types at the boundary where data comes in.
- **Tax and discount order**, applied twice, or applied to the wrong base.

## Dates and times

- Stored in local time instead of UTC, or converted twice.
- Date-only strings: `new Date("2026-10-18")` is UTC midnight, which is the previous day in negative offsets.
- Cairo DST: Egypt observes DST again since 2023, so fixed `+02:00` offsets break in summer.
- The server, DB and browser are in different time zones.

## Arabic, RTL and encoding

- Mojibake (`Ø§Ù„`): UTF-8 bytes read as Latin-1. Check the DB/connection charset (`utf8mb4`), HTTP `Content-Type; charset`, and the file encoding.
- `?` or `□`: the font lacks glyphs, or the column isn't Unicode.
- Wrong order of mixed Arabic + numbers: missing `dir="rtl"`/`dir="auto"`, or a missing Unicode isolate around the number.
- Search or validation fails on Arabic: regexes with `\w` (ASCII only), un-normalized forms (أ/إ/ا, ى/ي, ة/ه), or Arabic-Indic digits (٠-٩).
- PDF or CSV export breaks Arabic: the library needs an Arabic font and shaping. For Excel CSV, write a UTF-8 BOM.

## Stale data and caching

- Browser, CDN, service worker, framework cache (Next.js fetch cache, ISR), or an HTTP `Cache-Control` header.
- Cache key missing a parameter (user, locale, page).
- Hard-reload and incognito first. If the bug disappears, it's a cache.

## Slow (performance regression)

- Measure first. Time the request and profile it; don't guess.
- N+1 queries: one query per row in a loop. Log the query count per request.
- A missing index on a new filter or sort. Run `EXPLAIN` the query on realistic data.
- Work moved into a render loop or hot path, or a big payload with no pagination.
- A synchronous call where there used to be a cache or a background job.

## Crash with null / undefined

- Find where the value was supposed to be set, not where it was read. The read is only the symptom.
- Async: the value is read before it's loaded.
- Optional API fields, empty arrays (`list[0]`), or a renamed field.
- Don't "fix" it with `?.` or `if (!x) return` until you know why x is missing.

## Auth and permissions

- Tokens or sessions that expired, were cached, or sent to the wrong domain (cookie `SameSite`, `Domain`, `Secure` over http).
- CORS: the browser blocks it while curl works. Check the preflight `OPTIONS` response.
- Role checks done in the UI but missing on the server, or the other way round.
