# Codex Agent Guidelines

This repository contains documentation for the Via di Francesco pilgrimage database.  The docs are stored as `.docx` files in module-specific folders.  There is no executable code or automated test suite.

## Reviewing documentation
- `.docx` files use standard OOXML.  Unzip them to read `word/document.xml` when needed.
- The file `2025-05-17 - checklist.docx` defines the authoritative style for database specs.  Follow its checklist when creating or updating tables.

## Database design conventions (from `2025-05-17 - checklist.docx`)
- Tables are plural `snake_case`; columns are `snake_case`; ENUM types end with `_enum`.
- Always define a primary key with the correct type. Use `GENERATED` identity only when necessary.
- Choose the most efficient data type for each column and ensure all foreign keys match the referenced primary key type exactly.
- Apply `NOT NULL` to all mandatory fields and provide sensible defaults (`now()`, `false`, etc.).
- Include `CHECK` constraints for ranges, regex validation, and similar rules. URL fields should use `CHECK (url_col IS NULL OR url_col ~* '^https?://.+')`.
- Add `COMMENT ON TABLE` and `COMMENT ON COLUMN` statements to describe purpose and version.

### Audit and lifecycle
- Standard audit columns:
  - `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`
  - `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()` (managed by a shared trigger)
  - `created_by_profile_id UUID FK public.profiles(id) ON DELETE SET NULL`
  - `updated_by_profile_id UUID FK public.profiles(id) ON DELETE SET NULL`
- Transactional tables include `deleted_at TIMESTAMPTZ NULL` for soft delete.
- Master lookup tables use `is_active BOOLEAN NOT NULL DEFAULT true` and should be filtered in application logic.

### Internationalization
- English text is stored directly in each table.  Translations for other languages live in `public.translations`.
- Use `AFTER DELETE` triggers on parent tables to remove orphaned translations.

### Row Level Security
- RLS policies are expected for all tables.  Roles are stored in `public.profiles.roles` and synchronized to `auth.users.raw_app_meta_data.roles` for JWT claims.
- Provide helper functions like `public.has_role(TEXT)` and `public.has_role_on_profile(UUID, TEXT)` to implement policies.

### Media management
- Media files reside in Supabase Storage with metadata in `public.media`.
- Use direct FKs for single-image roles and `[entity]_media` linking tables for galleries with `media_role_code`.

## Contribution notes
- When editing documentation, maintain the formatting and module structure of existing `.docx` files.
- Update the change log sections when adding or modifying specifications.

## Testing and CI
- This repository has no test suite or CI configuration.  Codex should not attempt to run tests or install dependencies.
