-- Migration: Add user_credits table for per-export consumable IAP
-- Date: 2026-02-07
-- Run this in Supabase SQL Editor

-- Create user_credits table for tracking export credit balances
CREATE TABLE IF NOT EXISTS user_credits (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Credit balances
  credits_remaining INTEGER NOT NULL DEFAULT 0,
  monthly_bonus_credits INTEGER NOT NULL DEFAULT 0,
  
  -- Tracking
  last_bonus_date TIMESTAMPTZ,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for efficient lookups
CREATE INDEX IF NOT EXISTS idx_user_credits_user_id ON user_credits(user_id);

-- Enable RLS
ALTER TABLE user_credits ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any (to make migration idempotent)
DROP POLICY IF EXISTS "Users can view own credits" ON user_credits;
DROP POLICY IF EXISTS "Users can update own credits" ON user_credits;
DROP POLICY IF EXISTS "Service role can manage all credits" ON user_credits;

-- Users can view their own credits
CREATE POLICY "Users can view own credits" ON user_credits
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update their own credits (for consumption)
CREATE POLICY "Users can update own credits" ON user_credits
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Service role can manage all credits (for RevenueCat webhook)
-- Note: Service role bypasses RLS, but policy included for documentation
CREATE POLICY "Service role can manage all credits" ON user_credits
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM pg_roles 
      WHERE pg_roles.rolname = current_user 
      AND pg_roles.rolname LIKE 'supabase_admin%'
    )
  );

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to user_credits
DROP TRIGGER IF EXISTS update_user_credits_updated_at ON user_credits;
CREATE TRIGGER update_user_credits_updated_at
  BEFORE UPDATE ON user_credits
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Comment for clarity
COMMENT ON TABLE user_credits IS 'Tracks user export credit balances for consumable IAP';
COMMENT ON COLUMN user_credits.credits_remaining IS 'Number of export credits available to user';
COMMENT ON COLUMN user_credits.monthly_bonus_credits IS 'Monthly bonus credits for Pro subscribers';
COMMENT ON COLUMN user_credits.last_bonus_date IS 'When monthly bonus was last granted';
