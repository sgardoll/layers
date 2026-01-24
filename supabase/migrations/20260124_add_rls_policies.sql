-- Migration: Add RLS policies for user-scoped data
-- Run this in Supabase SQL Editor

-- Enable RLS on projects table (if not already enabled)
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any (to make migration idempotent)
DROP POLICY IF EXISTS "Users can view own projects" ON projects;
DROP POLICY IF EXISTS "Users can insert own projects" ON projects;
DROP POLICY IF EXISTS "Users can update own projects" ON projects;
DROP POLICY IF EXISTS "Users can delete own projects" ON projects;

-- Create RLS policies for projects
-- Users can only see their own projects
CREATE POLICY "Users can view own projects" ON projects
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can only insert projects with their own user_id
CREATE POLICY "Users can insert own projects" ON projects
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only update their own projects
CREATE POLICY "Users can update own projects" ON projects
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can only delete their own projects
CREATE POLICY "Users can delete own projects" ON projects
  FOR DELETE
  USING (auth.uid() = user_id);

-- Enable RLS on project_layers table
ALTER TABLE project_layers ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own project layers" ON project_layers;
DROP POLICY IF EXISTS "Users can insert own project layers" ON project_layers;
DROP POLICY IF EXISTS "Users can update own project layers" ON project_layers;
DROP POLICY IF EXISTS "Users can delete own project layers" ON project_layers;

-- Create RLS policies for project_layers
-- Users can view layers of their own projects
CREATE POLICY "Users can view own project layers" ON project_layers
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = project_layers.project_id 
      AND projects.user_id = auth.uid()
    )
  );

-- Users can insert layers for their own projects
CREATE POLICY "Users can insert own project layers" ON project_layers
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = project_layers.project_id 
      AND projects.user_id = auth.uid()
    )
  );

-- Users can update layers of their own projects
CREATE POLICY "Users can update own project layers" ON project_layers
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = project_layers.project_id 
      AND projects.user_id = auth.uid()
    )
  );

-- Users can delete layers of their own projects
CREATE POLICY "Users can delete own project layers" ON project_layers
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE projects.id = project_layers.project_id 
      AND projects.user_id = auth.uid()
    )
  );

-- Enable RLS on exports table (if exists)
-- exports links to projects via project_id, so we join through projects
DO $$
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'exports') THEN
    ALTER TABLE exports ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "Users can view own exports" ON exports;
    DROP POLICY IF EXISTS "Users can insert own exports" ON exports;
    DROP POLICY IF EXISTS "Users can delete own exports" ON exports;
    
    CREATE POLICY "Users can view own exports" ON exports
      FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM projects 
          WHERE projects.id = exports.project_id 
          AND projects.user_id = auth.uid()
        )
      );
    
    CREATE POLICY "Users can insert own exports" ON exports
      FOR INSERT
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM projects 
          WHERE projects.id = exports.project_id 
          AND projects.user_id = auth.uid()
        )
      );
    
    CREATE POLICY "Users can delete own exports" ON exports
      FOR DELETE
      USING (
        EXISTS (
          SELECT 1 FROM projects 
          WHERE projects.id = exports.project_id 
          AND projects.user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Storage policies for source-images bucket
-- Note: Run these in Supabase Dashboard > Storage > Policies

-- Policy: Users can upload to their own folder
-- INSERT: (bucket_id = 'source-images') AND (auth.uid()::text = (storage.foldername(name))[1])

-- Policy: Users can read their own files
-- SELECT: (bucket_id = 'source-images') AND (auth.uid()::text = (storage.foldername(name))[1])

-- Policy: Users can delete their own files
-- DELETE: (bucket_id = 'source-images') AND (auth.uid()::text = (storage.foldername(name))[1])
