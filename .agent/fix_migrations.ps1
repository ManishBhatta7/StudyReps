Write-Host "Repairing migration history..."

# 1. Revert missing remote migrations (cleanup history)
npx supabase migration repair --status reverted 20230422133000
npx supabase migration repair --status reverted 20250708033947
npx supabase migration repair --status reverted 20250721033738
npx supabase migration repair --status reverted 20250823015627
npx supabase migration repair --status reverted 20250902091144
npx supabase migration repair --status reverted 20250902091253
npx supabase migration repair --status reverted 20250902091351
npx supabase migration repair --status reverted 20250902091422
npx supabase migration repair --status reverted 20250903024144
npx supabase migration repair --status reverted 20250903024329
npx supabase migration repair --status reverted 20251003124822
npx supabase migration repair --status reverted 20251003124922
npx supabase migration repair --status reverted 20251003124951
npx supabase migration repair --status reverted 20251003125043
npx supabase migration repair --status reverted 20251003125114
npx supabase migration repair --status reverted 20251003125139
npx supabase migration repair --status reverted 20251003125253
npx supabase migration repair --status reverted 20251003125342
npx supabase migration repair --status reverted 20251003125443
npx supabase migration repair --status reverted 20251003125545
npx supabase migration repair --status reverted 20251003125616
npx supabase migration repair --status reverted 20251005121049
npx supabase migration repair --status reverted 20251101042154

# 2. Pull synchronized schema
Write-Host "Pulling remote schema..."
npx supabase db pull

# 3. Push new changes (our init_schema)
Write-Host "Pushing new schema..."
npx supabase db push

Write-Host "Database sync complete!"
