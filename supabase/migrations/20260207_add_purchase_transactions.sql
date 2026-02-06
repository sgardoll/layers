-- Migration: Add purchase_transactions table for idempotency tracking
-- Date: 2026-02-07
-- Run this in Supabase SQL Editor

-- Create purchase_transactions table for RevenueCat webhook idempotency
CREATE TABLE IF NOT EXISTS purchase_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- RevenueCat transaction tracking
  transaction_id TEXT NOT NULL UNIQUE,
  
  -- User and product info
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  
  -- Purchase details
  amount INTEGER NOT NULL,
  price_cents INTEGER NOT NULL,
  currency TEXT NOT NULL CHECK (LENGTH(currency) = 3),
  
  -- Transaction status
  status TEXT NOT NULL DEFAULT 'pending' 
    CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  
  -- RevenueCat webhook payload for debugging
  revenuecat_json JSONB,
  
  -- Verification timestamp
  verified_at TIMESTAMPTZ,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for efficient lookups
CREATE INDEX IF NOT EXISTS idx_purchase_transactions_user_id ON purchase_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_purchase_transactions_transaction_id ON purchase_transactions(transaction_id);
CREATE INDEX IF NOT EXISTS idx_purchase_transactions_status ON purchase_transactions(status);
CREATE INDEX IF NOT EXISTS idx_purchase_transactions_created_at ON purchase_transactions(created_at DESC);

-- Enable RLS
ALTER TABLE purchase_transactions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any (to make migration idempotent)
DROP POLICY IF EXISTS "Users can view own transactions" ON purchase_transactions;
DROP POLICY IF EXISTS "Service role can manage all transactions" ON purchase_transactions;
DROP POLICY IF EXISTS "Users cannot modify transactions" ON purchase_transactions;

-- Users can view their own transactions
CREATE POLICY "Users can view own transactions" ON purchase_transactions
  FOR SELECT
  USING (auth.uid() = user_id);

-- Service role can manage all transactions (for RevenueCat webhook)
-- Note: Service role bypasses RLS, but policy included for documentation
CREATE POLICY "Service role can manage all transactions" ON purchase_transactions
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM pg_roles 
      WHERE pg_roles.rolname = current_user 
      AND pg_roles.rolname LIKE 'supabase_admin%'
    )
  );

-- Prevent users from modifying transactions directly (only service role can)
CREATE POLICY "Users cannot modify transactions" ON purchase_transactions
  FOR INSERT
  WITH CHECK (FALSE);

CREATE POLICY "Users cannot update transactions" ON purchase_transactions
  FOR UPDATE
  USING (FALSE);

CREATE POLICY "Users cannot delete transactions" ON purchase_transactions
  FOR DELETE
  USING (FALSE);

-- Comments for clarity
COMMENT ON TABLE purchase_transactions IS 'Tracks RevenueCat purchase transactions for idempotency';
COMMENT ON COLUMN purchase_transactions.transaction_id IS 'Unique RevenueCat transaction ID';
COMMENT ON COLUMN purchase_transactions.amount IS 'Number of credits purchased';
COMMENT ON COLUMN purchase_transactions.revenuecat_json IS 'Full RevenueCat webhook payload for debugging';
