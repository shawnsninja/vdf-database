# 2025-05-17 - checklist

  ### Final V2 Enhancement & Review Checklist (REV 05-17-25-B) > How to use > – 
For every table spec, mark each bullet ✅ (done) ➖ (partial) ❌ (missing) ⚪ 
(N/A + why). > – Implement fixes for every ➖/❌. > – Always include 
new/modified triggers, helper functions, and RLS policies in the spec. 
╔══════════════════════════════════════════════════════════════════╗ ║ 0. 
GENERAL DESIGN & METADATA ║ 
╚══════════════════════════════════════════════════════════════════╝ A. 
**Naming** – tables plural `snake_case`; columns `snake_case`; ENUMs end 
`_enum`. B. **Primary Key** – defined; correct type; `GENERATED … IDENTITY` 
only when needed. C. **Data Types** – most efficient type per column (match FK 
→ PK types exactly). D. **NOT NULL** – on all mandatory fields. E. **Default 
Values** – sensible defaults (`now()`, `false`, `0`, etc.). F. **CHECK 
Constraints** – ranges, regex, non-empty strings, etc. G. **Comments** – 
`COMMENT ON TABLE/COLUMN` describe purpose/version. 
╔══════════════════════════════════════════════════════════════════╗ ║ I. DATA 
INTEGRITY & RELATIONSHIPS ║ 
╚══════════════════════════════════════════════════════════════════╝ 1. 
**Foreign Keys** – correct ref; `ON DELETE` rule justified; `ON UPDATE` set. 2. 
**Array-FK Integrity** – trigger/app check validates each ID exists **and** is 
`is_active = true` if master table has that flag. 3. **URL Validation** – 
`CHECK (url_col IS NULL OR url_col ~* '^https?://.+')`. 4. **Type Consistency** 
– every FK column’s data type **exactly matches** the referenced PK (e.g., all 
`waypoint_id` FKs are `BIGINT`). 
╔══════════════════════════════════════════════════════════════════╗ ║ II. 
AUDIT & LIFECYCLE (CROSS-CUTTING) ║ 
╚══════════════════════════════════════════════════════════════════╝ 5. 
**Standard Audit Columns** • `created_at TIMESTAMPTZ NOT NULL DEFAULT now()` • 
`updated_at TIMESTAMPTZ NOT NULL DEFAULT now()` ‹auto-update trigger› • 
`created_by_profile_id UUID FK public.profiles(id) ON DELETE SET NULL` • 
`updated_by_profile_id UUID FK public.profiles(id) ON DELETE SET NULL` • 
**Trigger** – use one consolidated BEFORE UPDATE trigger (e.g., 
`public.handle_updated_at()` or `extensions.moddatetime`) across all tables. 6. 
**Soft Delete vs. is_active** • Transactional/user data ➜ `deleted_at 
TIMESTAMPTZ NULL`. • Master/lookup data ➜ `is_active BOOLEAN NOT NULL DEFAULT 
true`. • RLS / app logic must filter `is_active = true`. 
╔══════════════════════════════════════════════════════════════════╗ ║ III. 
CONTENT STRUCTURE & SEMANTICS ║ 
╚══════════════════════════════════════════════════════════════════╝ 7. 
**Master Table Pattern** – stable `code` PK/UNIQUE, `name/label`, 
`description`, `sort_order`, optional `icon_identifier`. 8. **Structured Text** 
– `key_highlights TEXT[]`, `structured_content JSONB` where helpful. 
╔══════════════════════════════════════════════════════════════════╗ ║ IV. 
MEDIA INTEGRATION ║ 
╚══════════════════════════════════════════════════════════════════╝ 9. 
**Linking Strategy** • Singular roles ➜ direct FK `<role>_media_id`. • 
Galleries/flexible ➜ `[parent]_media` M-to-M table with `media_role_code` FK → 
`media_roles_master`. • **media.image_variants_json** – spec must show expected 
JSON keys (e.g., `"thumb_S"`, `"display_L"`) and note that app/storage layer 
populates them. 
╔══════════════════════════════════════════════════════════════════╗ ║ V. 
INTERNATIONALIZATION (i18n) ║ 
╚══════════════════════════════════════════════════════════════════╝ 10. 
**Translatable Fields** • Mark “(Translatable via `public.translations`)”. • 
AFTER DELETE trigger item → `public.cleanup_related_translations(...)`. 
╔══════════════════════════════════════════════════════════════════╗ ║ VI. 
PERFORMANCE & SCALABILITY ║ 
╚══════════════════════════════════════════════════════════════════╝ 11. 
**Indexes** – FKs and high-query columns indexed; document rationale. 12. 
**FTS** – `tsvector` + GIN if needed. 13. **JSONB Flex** – 
`additional_attributes JSONB` + GIN where appropriate. 14. **Partitioning** – 
note if future partitioning is likely. 
╔══════════════════════════════════════════════════════════════════╗ ║ VII. 
SECURITY (ROW-LEVEL SECURITY) ║ 
╚══════════════════════════════════════════════════════════════════╝ 15. **RLS 
Policies** • Define SELECT / INSERT / UPDATE / DELETE policies per role. • 
Helper fns (`is_platform_admin()`, `user_manages_segment(...)`, etc.) must be 
identified; SECURITY INVOKER default; SECURITY DEFINER only with hardened 
search_path & minimal grants. • Policies must gracefully handle NULL ownership 
FKs. ╔══════════════════════════════════════════════════════════════════╗ ║ 
VIII. TRIGGERS, FUNCTIONS & SPECIAL LOGIC (NEW) ║ 
╚══════════════════════════════════════════════════════════════════╝ 16. 
**Array-FK Validation Triggers** – write specific function + trigger per 
referencing table (e.g., `check_event_theme_tags_exist()`). 17. **Waypoint Vote 
Counts** – ensure `public.update_waypoint_vote_counts()` exists and triggers 
fire on `user_waypoint_votes`. 18. **Trail Geometry Calcs** – confirm 
`calculate_segment_geom_properties()`, `update_segment_geom_derived_fields()`, 
`update_route_aggregates_from_segments()` are present and linked. 19. 
**Standard updated_at Trigger** – ensure one chosen implementation is attached 
to every table with `updated_at`. 20. **Orphan Translation Cleanup** – generic 
`public.cleanup_related_translations()` exists and every translatable parent 
table has AFTER DELETE trigger. 
╔══════════════════════════════════════════════════════════════════╗ ║ IX. 
DOCUMENTATION & SEED DATA ║ 
╚══════════════════════════════════════════════════════════════════╝ 21. 
**Comments & JSON Schema Mirror** – keep SQL comments and JSON schema perfectly 
in sync after changes. 22. **Initial Seed Data** – for every `_master` table, 
list V1 seed rows (`code`, `name_en`, `is_active`, `sort_order`, etc.). **End 
of Checklist** 
