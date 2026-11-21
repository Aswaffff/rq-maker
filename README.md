# QRora — Free QR Code Generator & Design Studio

**Free-tier setup** · No login required · Built with static HTML/Tailwind/JavaScript + Supabase Storage for temporary file QR codes. Availability and limits depend on the providers’ current free-tier terms.

## Actual Files in This Package
- `index.html` — Complete QRora web app (27+ QR types, ISO/IEC 18004 Versions 1–25 QR encoder with 8-mask selection, Canva-inspired Color Picker Studio, 10-template Sticker Maker, Bulk CSV-to-ZIP Generator, PNG/JPG/SVG/PDF exports, local browser Dashboard).
- `qr-code-generator.html`, `free-qr-code-generator.html`, `custom-qr-code-generator.html`, `qr-code-with-logo.html`, `qr-sticker-maker.html`, `wifi-qr-code-generator.html`, `pdf-qr-code-generator.html`, `vcard-qr-code-generator.html`, `social-media-qr-code-generator.html`, `dynamic-qr-codes.html`, `bulk-qr-code-generator.html`, `qr-code-templates.html`, `qr-code-types.html` — 13 standalone SEO landing pages.
- `og-image.png`, `favicon.svg` — Open Graph social preview card and SVG favicon.
- `robots.txt`, `sitemap.xml` — Search engine crawl rules and XML sitemap.
- `supabase-storage-migration.sql` — Safe RLS policy migration for your existing Supabase bucket `qr-public-files`.
- `supabase/functions/qrora-storage-cleanup/index.ts` — Storage API cleanup Edge Function.
- `supabase/functions/qrora-dynamic/index.ts` — Dynamic redirect, expiry, password and scan-count Edge Function.
- `supabase/dynamic-qr-migration.sql` — Private dynamic QR tables and deny-by-default RLS policies.
- `supabase/storage-cleanup-schedule.sql` — Reference scheduler setup for a separate project.
- `.env.example` — Reference template showing the public Supabase URL and publishable key.

## 1. Free GitHub Pages Deployment ($0/month)
1. Upload all extracted files (`index.html`, the 13 `.html` landing pages, `og-image.png`, `favicon.svg`, `robots.txt`, `sitemap.xml`) to your GitHub repository root.
2. Open **Settings → Pages → Source: Deploy from a branch → main / root → Save**.
3. Your live site will be available at `https://<your-username>.github.io/<repo>/` (or your custom domain `https://qrora.app/`).

## 2. Supabase Storage Setup (Free Tier)
- **Existing Project**: `https://eufdpkdceiankwucmggv.supabase.co`
- **Public Bucket**: `qr-public-files` (20 MB max file size, uploads restricted to `ephemeral/`)
- The connected QRora Supabase project has already had the storage policies applied. The included `supabase-storage-migration.sql` documents the safe bucket policy setup for reference; do not run it blindly over a different project without checking its bucket and policies.
- **Public Access Notice**: Files uploaded to `qr-public-files` are publicly readable via their HTTPS URL so any smartphone scanning the QR code can open them. Do not upload confidential files.
- **Automated Cleanup**: The connected project runs `qrora-storage-cleanup` hourly. It removes `ephemeral/` files older than 24 hours using the Storage API, not SQL deletes from `storage.objects`.

## 3. Local Browser Dashboard Notice
Saved QR codes (`qrora_saved`) and uploaded file history (`qrora_assets_local`) are stored in your browser's `localStorage` so no sign-in is required. These dashboard records are specific to the browser/device you used and are not synchronized across devices. Dynamic redirect records are stored in Supabase so the redirect continues working when the browser is closed.


## QR Encoder repair note
The alignment-pattern placement now draws alignment patterns before timing patterns, so timing modules correctly take precedence where the two patterns intersect. This source-level repair has been checked with an independent decoder in this working environment; real-device scans are still recommended before production deployment.


## Supabase backend (QRora project)

The connected QRora Supabase project now includes:

- `qr-public-files` public Storage bucket (20 MB per file) with anonymous uploads restricted to `ephemeral/` and allowed file extensions.
- Anonymous delete access removed. Public file links remain readable; do not upload confidential files.
- `qrora-storage-cleanup` Edge Function, scheduled hourly at minute 00 (UTC). It lists files in `ephemeral/` and removes files older than 24 hours through the Supabase Storage API (never by deleting `storage.objects` rows).
- `qrora-dynamic` Edge Function and private `dynamic_qr_links` table for short redirects, optional expiry, optional password prompt, and scan counts. Dynamic links are activated when the user saves, downloads, copies, or sends the QR to Sticker Studio.
- Dynamic link creation is limited to 10 per IP hash per hour.

The frontend uses the Supabase publishable key only. Never add a service-role key to this ZIP or browser code.
