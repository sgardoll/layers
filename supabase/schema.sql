-- ============================================================
-- LAYERS APP - SUPABASE SCHEMA
-- ============================================================
-- Copy-paste this into Supabase SQL Editor and run.
-- 
-- Tables: projects, project_layers, exports
-- Triggers: on INSERT/DELETE for projects, on INSERT/DELETE for exports
-- Storage: buckets for source images, layers, exports
-- RLS: Row Level Security policies
-- ============================================================

-- ============================================================
-- 1. EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 2. TABLES
-- ============================================================

-- projects: One user image → one layering job
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  
  -- Source image
  source_image_path TEXT NOT NULL,
  source_image_url TEXT,
  
  -- Job status
  status TEXT NOT NULL DEFAULT 'queued' 
    CHECK (status IN ('queued', 'processing', 'packaging', 'ready', 'failed')),
  error_message TEXT,
  
  -- Model parameters
  params JSONB DEFAULT '{}',
  
  -- Output
  manifest_path TEXT,
  thumbnail_path TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- project_layers: Each generated layer for a project
CREATE TABLE IF NOT EXISTS project_layers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  
  -- Layer info
  name TEXT NOT NULL,
  png_path TEXT NOT NULL,
  png_url TEXT,
  
  -- Dimensions
  width INTEGER NOT NULL,
  height INTEGER NOT NULL,
  
  -- Ordering & visibility
  z_index INTEGER NOT NULL DEFAULT 0,
  visible BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Optional metadata
  bbox JSONB,
  transform JSONB DEFAULT '{"x": 0, "y": 0, "scale": 1, "rotation": 0, "opacity": 1}',
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- exports: Async export jobs (PNG/ZIP/layersPack)
CREATE TABLE IF NOT EXISTS exports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  
  -- Export type
  type TEXT NOT NULL CHECK (type IN ('pngs', 'zip', 'layersPack')),
  
  -- Job status
  status TEXT NOT NULL DEFAULT 'queued'
    CHECK (status IN ('queued', 'processing', 'ready', 'failed')),
  error_message TEXT,
  
  -- Options (e.g., which layer IDs to include)
  options JSONB DEFAULT '{}',
  
  -- Output
  asset_path TEXT,
  asset_url TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 3. INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_projects_user_id ON projects(user_id);
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_project_layers_project_id ON project_layers(project_id);
CREATE INDEX IF NOT EXISTS idx_project_layers_z_index ON project_layers(project_id, z_index);

CREATE INDEX IF NOT EXISTS idx_exports_project_id ON exports(project_id);
CREATE INDEX IF NOT EXISTS idx_exports_status ON exports(status);

-- ============================================================
-- 4. UPDATED_AT TRIGGER FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to projects
DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
CREATE TRIGGER update_projects_updated_at
  BEFORE UPDATE ON projects
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply to exports
DROP TRIGGER IF EXISTS update_exports_updated_at ON exports;
CREATE TRIGGER update_exports_updated_at
  BEFORE UPDATE ON exports
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Enable RLS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_layers ENABLE ROW LEVEL SECURITY;
ALTER TABLE exports ENABLE ROW LEVEL SECURITY;

-- Projects policies
-- Users can see their own projects (or anonymous projects if user_id is NULL)
CREATE POLICY "Users can view own projects" ON projects
  FOR SELECT USING (
    auth.uid() = user_id OR user_id IS NULL
  );

CREATE POLICY "Users can insert own projects" ON projects
  FOR INSERT WITH CHECK (
    auth.uid() = user_id OR user_id IS NULL
  );

CREATE POLICY "Users can update own projects" ON projects
  FOR UPDATE USING (
    auth.uid() = user_id OR user_id IS NULL
  );

CREATE POLICY "Users can delete own projects" ON projects
  FOR DELETE USING (
    auth.uid() = user_id OR user_id IS NULL
  );

-- Project layers policies (inherit from project ownership)
CREATE POLICY "Users can view own project layers" ON project_layers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = project_layers.project_id 
      AND (projects.user_id = auth.uid() OR projects.user_id IS NULL)
    )
  );

CREATE POLICY "Users can insert own project layers" ON project_layers
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = project_layers.project_id 
      AND (projects.user_id = auth.uid() OR projects.user_id IS NULL)
    )
  );

CREATE POLICY "Users can update own project layers" ON project_layers
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = project_layers.project_id 
      AND (projects.user_id = auth.uid() OR projects.user_id IS NULL)
    )
  );

CREATE POLICY "Users can delete own project layers" ON project_layers
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = project_layers.project_id 
      AND (projects.user_id = auth.uid() OR projects.user_id IS NULL)
    )
  );

-- Exports policies (inherit from project ownership)
CREATE POLICY "Users can view own exports" ON exports
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = exports.project_id 
      AND (projects.user_id = auth.uid() OR projects.user_id IS NULL)
    )
  );

CREATE POLICY "Users can insert own exports" ON exports
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = exports.project_id 
      AND (projects.user_id = auth.uid() OR projects.user_id IS NULL)
    )
  );

CREATE POLICY "Users can update own exports" ON exports
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = exports.project_id 
      AND (projects.user_id = auth.uid() OR projects.user_id IS NULL)
    )
  );

CREATE POLICY "Users can delete own exports" ON exports
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = exports.project_id 
      AND (projects.user_id = auth.uid() OR projects.user_id IS NULL)
    )
  );

-- ============================================================
-- 6. SERVICE ROLE POLICIES (for BuildShip workflows)
-- ============================================================
-- BuildShip uses service_role key which bypasses RLS by default.
-- No additional policies needed for server-side workflows.

-- ============================================================
-- 7. REALTIME SUBSCRIPTIONS
-- ============================================================
-- Enable realtime for status updates

ALTER PUBLICATION supabase_realtime ADD TABLE projects;
ALTER PUBLICATION supabase_realtime ADD TABLE exports;

-- ============================================================
-- 8. STORAGE BUCKETS (run separately in Storage settings or via API)
-- ============================================================
-- Create these buckets in Supabase Dashboard → Storage:
--
-- 1. "source-images" - uploaded original images
--    - Public: false
--    - File size limit: 50MB
--    - Allowed MIME types: image/png, image/jpeg, image/webp
--
-- 2. "layers" - generated layer PNGs
--    - Public: false  
--    - File size limit: 50MB
--    - Allowed MIME types: image/png
--
-- 3. "exports" - ZIP/layersPack exports
--    - Public: false
--    - File size limit: 200MB
--    - Allowed MIME types: application/zip, application/octet-stream
--
-- 4. "thumbnails" - project thumbnails
--    - Public: true (for gallery display)
--    - File size limit: 5MB
--    - Allowed MIME types: image/png, image/jpeg, image/webp

-- Storage bucket creation via SQL (requires supabase_admin role):
-- Uncomment if running with admin privileges:

-- INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
-- VALUES 
--   ('source-images', 'source-images', false, 52428800, ARRAY['image/png', 'image/jpeg', 'image/webp']),
--   ('layers', 'layers', false, 52428800, ARRAY['image/png']),
--   ('exports', 'exports', false, 209715200, ARRAY['application/zip', 'application/octet-stream']),
--   ('thumbnails', 'thumbnails', true, 5242880, ARRAY['image/png', 'image/jpeg', 'image/webp'])
-- ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 9. STORAGE POLICIES
-- ============================================================
-- Run these after creating buckets in Dashboard

-- Source images: users can upload/read their own
CREATE POLICY "Users can upload source images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'source-images' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

CREATE POLICY "Users can read own source images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'source-images' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- Layers: users can read their own (BuildShip writes via service role)
CREATE POLICY "Users can read own layers" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'layers' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- Exports: users can read their own (BuildShip writes via service role)
CREATE POLICY "Users can read own exports" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'exports' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- Thumbnails: public read
CREATE POLICY "Anyone can read thumbnails" ON storage.objects
  FOR SELECT USING (bucket_id = 'thumbnails');

CREATE POLICY "Users can upload thumbnails" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'thumbnails' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR (storage.foldername(name))[1] = 'anonymous')
  );

-- ============================================================
-- DONE! 
-- ============================================================
-- Next steps:
-- 1. Create storage buckets manually in Dashboard → Storage
-- 2. Set up Database Webhooks in Dashboard → Database → Webhooks:
--    - projects INSERT → BuildShip "Run Layering Job" workflow URL
--    - projects DELETE → BuildShip "Cleanup Project" workflow URL  
--    - exports INSERT → BuildShip "Build Export" workflow URL
--    - exports DELETE → BuildShip "Cleanup Export" workflow URL
-- ============================================================
