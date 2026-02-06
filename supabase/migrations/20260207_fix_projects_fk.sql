-- Migration: Fix projects.user_id foreign key to use CASCADE on delete
-- Date: 2026-02-07
-- Run this in Supabase SQL Editor

-- Fix projects.user_id foreign key from SET NULL to CASCADE
-- This ensures projects are deleted when the user account is deleted

-- First, find and drop the existing foreign key constraint
DO $$
DECLARE
  constraint_name TEXT;
BEGIN
  -- Find the existing FK constraint name
  SELECT conname INTO constraint_name
  FROM pg_constraint 
  WHERE conrelid = 'projects'::regclass 
    AND confrelid = 'auth.users'::regclass
    AND contype = 'f';
  
  -- Drop the constraint if found
  IF constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE projects DROP CONSTRAINT IF EXISTS %I', constraint_name);
    RAISE NOTICE 'Dropped existing constraint: %', constraint_name;
  ELSE
    RAISE NOTICE 'No existing FK constraint found on projects.user_id';
  END IF;
END $$;

-- Also try common constraint names as fallback
ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_user_id_fkey;
ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_user_id_fkey1;
ALTER TABLE projects DROP CONSTRAINT IF EXISTS fk_projects_user_id;

-- Add the new foreign key constraint with CASCADE
ALTER TABLE projects 
  ADD CONSTRAINT projects_user_id_fkey 
  FOREIGN KEY (user_id) 
  REFERENCES auth.users(id) 
  ON DELETE CASCADE;

-- Verify the constraint was created correctly
DO $$
DECLARE
  fk_def TEXT;
BEGIN
  SELECT pg_get_constraintdef(oid) INTO fk_def
  FROM pg_constraint 
  WHERE conrelid = 'projects'::regclass 
    AND conname = 'projects_user_id_fkey';
  
  IF fk_def LIKE '%ON DELETE CASCADE%' THEN
    RAISE NOTICE 'Successfully created FK with ON DELETE CASCADE: %', fk_def;
  ELSE
    RAISE EXCEPTION 'FK created but does not have ON DELETE CASCADE';
  END IF;
END $$;

-- Comment for clarity
COMMENT ON CONSTRAINT projects_user_id_fkey ON projects IS 
  'Foreign key to auth.users with CASCADE delete - ensures projects are deleted when user is deleted';
