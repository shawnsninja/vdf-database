-- Module 4: Waypoint Details
-- 006_content_statuses_master_seed.sql: Initial content status definitions
-- 
-- Purpose: Seed essential content publication statuses

-- Insert initial content statuses
INSERT INTO public.content_statuses_master (
    code,
    label,
    description,
    is_publicly_visible,
    sort_order,
    is_active
) VALUES 
    -- Primary workflow statuses
    ('draft', 'Draft', 'Content is being created or edited and not ready for review', false, 10, true),
    ('pending_review', 'Pending Review', 'Content is complete and awaiting editorial review', false, 20, true),
    ('in_review', 'In Review', 'Content is currently being reviewed by an editor', false, 30, true),
    ('revision_needed', 'Revision Needed', 'Content requires changes before approval', false, 40, true),
    ('approved', 'Approved', 'Content has been approved but not yet published', false, 50, true),
    ('published', 'Published', 'Content is live and visible to the public', true, 60, true),
    ('featured', 'Featured', 'Published content highlighted for special promotion', true, 70, true),
    
    -- Administrative statuses
    ('archived', 'Archived', 'Content is no longer current but preserved for historical purposes', false, 80, true),
    ('deprecated', 'Deprecated', 'Content is outdated and should not be used for new references', false, 90, true),
    ('suspended', 'Suspended', 'Content temporarily removed from public view pending investigation', false, 100, true),
    ('deleted', 'Deleted', 'Content marked for deletion but not yet permanently removed', false, 110, true),
    
    -- Special statuses
    ('seasonal_inactive', 'Seasonal Inactive', 'Content temporarily hidden due to seasonal availability', false, 120, true),
    ('maintenance', 'Under Maintenance', 'Content temporarily unavailable while being updated', false, 130, true),
    ('imported', 'Imported', 'Content imported from external sources, pending review', false, 140, true)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    is_publicly_visible = EXCLUDED.is_publicly_visible,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = now();