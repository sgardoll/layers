-- Migration: Storage policies for anonymous uploads
-- Run this in Supabase SQL Editor after creating storage buckets

-- Enable RLS on storage.objects (if not already enabled)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- SOURCE-IMAGES BUCKET POLICIES
-- ============================================================

-- Drop existing policies for source-images bucket (idempotency)
DROP POLICY IF EXISTS "Users can upload source images" ON storage.objects;
DROP POLICY IF EXISTS "Users can read own source images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own source images" ON storage.objects;

-- Policy: Users (authenticated or anonymous) can upload to their own folder
CREATE POLICY "Users can upload source images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'source-images' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- Policy: Users (authenticated or anonymous) can read their own files
CREATE POLICY "Users can read own source images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'source-images' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- Policy: Users (authenticated or anonymous) can delete their own files
CREATE POLICY "Users can delete own source images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'source-images' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- ============================================================
-- LAYERS BUCKET POLICIES
-- ============================================================

-- Drop existing policies for layers bucket (idempotency)
DROP POLICY IF EXISTS "Users can read own layers" ON storage.objects;

-- Policy: Users (authenticated or anonymous) can read their own layers
-- BuildShip writes layers via service_role key, which bypasses RLS
CREATE POLICY "Users can read own layers" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'layers' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- ============================================================
-- EXPORTS BUCKET POLICIES
-- ============================================================

-- Drop existing policies for exports bucket (idempotency)
DROP POLICY IF EXISTS "Users can read own exports" ON storage.objects;

-- Policy: Users (authenticated or anonymous) can read their own exports
-- BuildShip writes exports via service_role key, which bypasses RLS
CREATE POLICY "Users can read own exports" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'exports' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- ============================================================
-- THUMBNAILS BUCKET POLICIES
-- ============================================================

-- Drop existing policies for thumbnails bucket (idempotency)
DROP POLICY IF EXISTS "Anyone can read thumbnails" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload thumbnails" ON storage.objects;

-- Policy: Public read access for thumbnails (for gallery display)
CREATE POLICY "Anyone can read thumbnails" ON storage.objects
  FOR SELECT USING (bucket_id = 'thumbnails');

-- Policy: Users (authenticated or anonymous) can upload thumbnails
CREATE POLICY "Users can upload thumbnails" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'thumbnails' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- ============================================================
-- NOTES
-- ============================================================
-- Key insight: Anonymous users store files under 'anonymous/' folder.
-- The policies above check the first path segment using storage.foldername(name)[1].
-- If the folder is 'anonymous', access is allowed without authentication.
-- 
-- BuildShip workflows use the service_role key which bypasses RLS entirely,
-- so they don't need specific policies for write operations.
