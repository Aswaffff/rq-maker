-- QRora Storage policies for the public qr-public-files bucket.
-- Safe to re-run. The bucket remains public so QR scans can open uploaded files.

update storage.buckets
set public = true,
    file_size_limit = 20971520
where id = 'qr-public-files';

-- Public downloads are allowed by the bucket's public setting. Do not add a
-- broad SELECT policy just to enable public file URLs or expose object listings.

-- Anonymous uploads are restricted to the ephemeral folder and an allow-list
-- of extensions. The bucket-level 20 MB limit is enforced by Storage.
drop policy if exists "Anon ephemeral upload qr-public-files" on storage.objects;
create policy "Anon ephemeral upload qr-public-files"
on storage.objects for insert
to anon, authenticated
with check (
  bucket_id = 'qr-public-files'
  and (storage.foldername(name))[1] = 'ephemeral'
  and lower(storage.extension(name)) in (
    'pdf','jpg','jpeg','png','webp','gif','svg',
    'mp3','m4a','aac','wav','ogg','mp4','webm','mov'
  )
);

-- Critical: remove anonymous deletion. Do not delete directly from
-- storage.objects. The qrora-storage-cleanup Edge Function uses the Storage
-- API remove() method and is scheduled daily by pg_cron in the connected
-- QRora Supabase project.
drop policy if exists "Anon ephemeral delete qr-public-files" on storage.objects;
