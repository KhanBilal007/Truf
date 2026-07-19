# Supabase Setup

Step 2 adds database setup files only. The Flutter app is not connected to
Supabase yet.

## 1. Create a Supabase Project

1. Sign in at [supabase.com](https://supabase.com).
2. Create a new project.
3. Choose a secure database password and save it somewhere private.
4. Wait for the project to finish provisioning.

## 2. Open the SQL Editor

In the Supabase dashboard, open **SQL Editor** and create a new query.

## 3. Run the Schema

Copy the complete contents of `database/schema.sql` into the SQL Editor and run
it.

This creates the TurfVerse tables, constraints, indexes, triggers, helper
functions, and row level security policies.

For an existing project where `profiles.id` equals `auth.users.id`, run
`database/auth_profiles_policy_sync.sql` to align profile RLS without
recreating tables.

Assign the `admin` role only through a trusted server-side process or the
Supabase SQL Editor using appropriate administrative credentials. Client-side
profile policies intentionally reject self-service admin role assignment.

## 4. Run the Seed Data

Create another SQL Editor query, copy the contents of `database/seed.sql`, and
run it.

The seed file explains the required order for test data. Create users through
Supabase Auth first. Each `public.profiles.id` must equal its corresponding
Auth user ID. The app creates a missing profile when that user signs in.

## 5. Get the Project URL and Anon Key

In the project dashboard, open **Project Settings > API** and note:

- Project URL
- Anon/public key

These values are not used by the Flutter app in Step 2.

## 6. Add Keys Later

When Flutter Supabase integration is implemented in a future step, add the
project URL and anon key to a local `.env` file using names documented at that
time.

## 7. Protect Secrets

Never commit real project keys, service-role keys, database passwords, or a
populated `.env` file. The service-role key must never be included in a Flutter
client application.

## Verify the Setup

After running both SQL files:

1. Open **Table Editor** and confirm all 11 public tables exist.
2. Confirm the sample profiles, turfs, slots, and open matches were inserted.
3. Open **Authentication > Policies** and confirm RLS is enabled for every
   public table.
4. Run the Supabase Security Advisor and review any recommendations.
