# QRora repair and Supabase backend report

## QR encoder

- Corrected alignment/timing pattern construction in `index.html`.
- Independent decoder tests reported 37/37 successful QR payload decodes in the previous repair pass.

## Supabase backend deployed

- Removed the unrestricted anonymous DELETE policy for `qr-public-files`.
- Kept the public bucket and the restricted anonymous upload policy for the `ephemeral/` folder.
- Deployed `qrora-storage-cleanup` (version 2), which uses `storage.from('qr-public-files').list()` and `.remove()`; it removes only `ephemeral/` objects older than 24 hours, in batches of up to 1,000.
- Scheduled cleanup daily at 03:00 UTC using `pg_cron` + `pg_net`; project URL and publishable key are stored in Supabase Vault.
- Deployed `qrora-dynamic` (version 6) for public redirects, optional expiry, optional password prompt, scan counts, and basic creation rate limiting.
- Added private database tables for dynamic links and creation rate limits. RLS is enabled and direct access is revoked from `anon` and `authenticated`; Edge Functions use the server-side service-role environment variable.

## Verification

- Cleanup Edge Function deployed and active with JWT verification enabled.
- Manual invocation through `pg_net` returned HTTP 200 and JSON `{ ok: true, deleted: 0 }`.
- Cron job `qrora-ephemeral-cleanup` is active with schedule `0 * * * *`.
- Anonymous DELETE policy no longer exists. Remaining DELETE policy is restricted to authenticated users' own UID folder.
- Security and health advisors returned no health findings. One performance-only INFO advisory reports three currently unused indexes on empty QR tables.
- Supabase security advisor reports a warning that `pg_net` is installed in the `public` schema; the extension does not support `ALTER EXTENSION ... SET SCHEMA`, so it was not moved.

## Important limitations

- The Storage bucket is public. Anyone with a public file URL can read that file. Do not upload confidential files.
- The cleanup schedule runs daily; files become eligible after 24 hours and are deleted at the next scheduled run, so actual deletion can be later than exactly 24 hours.
- Dynamic QR links use the Supabase Edge Function URL. A custom `qrora.app/r/...` route requires a separate domain/hosting rewrite and is not configured here.
- Dynamic QR supports HTTP/HTTPS destinations. Passwords are stored as SHA-256 hashes, not plaintext.
- A real anonymous browser file upload, physical Android/iPhone camera scanning, and a production GitHub Pages deployment must still be performed.

- Dynamic redirect endpoint tested with an HTTP redirect to the configured destination. Password-protected link creation and the password prompt page were tested; password submission from a physical mobile browser still needs a final end-to-end check.
