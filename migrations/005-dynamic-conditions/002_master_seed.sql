-- Module 5: Dynamic Conditions
-- 002_master_seed.sql: Seed data for master tables
-- 
-- Purpose: Populate master tables with essential data for warning system

-- Insert warning severities first (referenced by warning types)
INSERT INTO public.warning_severities_master (
    code, display_name, description, color_hex, icon_identifier, urgency_level, sort_order
) VALUES 
    ('info', 'Information', 'General information or updates about trail conditions', '#2563eb', 'info-circle', 1, 10),
    ('advisory', 'Advisory', 'Trail condition that pilgrims should be aware of but does not prevent passage', '#059669', 'exclamation-triangle', 2, 20),
    ('caution', 'Caution', 'Trail condition requiring extra care and attention', '#d97706', 'warning', 4, 30),
    ('warning', 'Warning', 'Significant trail condition that may impact safety or passage', '#dc2626', 'alert-triangle', 6, 40),
    ('danger', 'Danger', 'Serious safety hazard requiring immediate attention', '#b91c1c', 'alert-octagon', 8, 50),
    ('critical', 'Critical', 'Extreme danger or complete trail closure', '#7f1d1d', 'x-circle', 10, 60)
ON CONFLICT (code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    color_hex = EXCLUDED.color_hex,
    icon_identifier = EXCLUDED.icon_identifier,
    urgency_level = EXCLUDED.urgency_level,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert warning types with references to severities
INSERT INTO public.warning_types_master (
    code, display_name, description, icon_identifier, default_severity_id, sort_order
) VALUES 
    ('trail_damage', 'Trail Damage', 'Physical damage to the trail surface, bridges, or infrastructure', 'road-construction', (SELECT id FROM public.warning_severities_master WHERE code = 'caution'), 10),
    ('natural_hazard', 'Natural Hazard', 'Weather-related or geological hazards affecting trail safety', 'cloud-storm', (SELECT id FROM public.warning_severities_master WHERE code = 'warning'), 20),
    ('closure_temporary', 'Temporary Closure', 'Trail section temporarily closed for maintenance, events, or safety', 'road-barrier', (SELECT id FROM public.warning_severities_master WHERE code = 'critical'), 30),
    ('closure_permanent', 'Permanent Closure', 'Trail section permanently closed or rerouted', 'ban', (SELECT id FROM public.warning_severities_master WHERE code = 'critical'), 40),
    ('construction', 'Construction Work', 'Construction or maintenance work affecting trail passage', 'tools', (SELECT id FROM public.warning_severities_master WHERE code = 'caution'), 50),
    ('wildlife_activity', 'Wildlife Activity', 'Unusual wildlife activity that may affect safety', 'paw-print', (SELECT id FROM public.warning_severities_master WHERE code = 'advisory'), 60),
    ('water_crossing', 'Water Crossing Issue', 'Problems with river crossings, flooding, or bridge conditions', 'waves', (SELECT id FROM public.warning_severities_master WHERE code = 'warning'), 70),
    ('accommodation_issue', 'Accommodation Issue', 'Problems with nearby accommodation availability or access', 'bed', (SELECT id FROM public.warning_severities_master WHERE code = 'advisory'), 80),
    ('service_disruption', 'Service Disruption', 'Disruption to essential services (water, food, transport)', 'service', (SELECT id FROM public.warning_severities_master WHERE code = 'caution'), 90),
    ('seasonal_condition', 'Seasonal Condition', 'Seasonal conditions affecting trail accessibility or safety', 'calendar', (SELECT id FROM public.warning_severities_master WHERE code = 'info'), 100),
    ('navigation_issue', 'Navigation Issue', 'Missing or damaged trail markers, unclear route', 'compass', (SELECT id FROM public.warning_severities_master WHERE code = 'caution'), 110),
    ('terrain_change', 'Terrain Change', 'Significant changes to terrain or trail difficulty', 'mountain', (SELECT id FROM public.warning_severities_master WHERE code = 'advisory'), 120),
    ('security_concern', 'Security Concern', 'Safety or security concerns in the area', 'shield-alert', (SELECT id FROM public.warning_severities_master WHERE code = 'warning'), 130),
    ('event_impact', 'Event Impact', 'Local events affecting trail access or conditions', 'calendar-event', (SELECT id FROM public.warning_severities_master WHERE code = 'info'), 140),
    ('other', 'Other', 'Other conditions not covered by specific categories', 'alert-circle', (SELECT id FROM public.warning_severities_master WHERE code = 'advisory'), 999)
ON CONFLICT (code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    default_severity_id = EXCLUDED.default_severity_id,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert warning source types
INSERT INTO public.warning_source_types_master (
    code, display_name, description, reliability_score, requires_verification, icon_identifier, sort_order
) VALUES 
    ('official_authority', 'Official Authority', 'Warning issued by official government or trail management authority', 10, false, 'shield-check', 10),
    ('trail_organization', 'Trail Organization', 'Warning from recognized trail organizations or pilgrim associations', 9, false, 'users', 20),
    ('local_business', 'Local Business', 'Report from local accommodation, restaurant, or service provider', 7, true, 'store', 30),
    ('verified_pilgrim', 'Verified Pilgrim', 'Report from verified pilgrim with good reporting history', 6, true, 'user-check', 40),
    ('community_report', 'Community Report', 'Report from pilgrim community or forums', 5, true, 'message-circle', 50),
    ('automated_system', 'Automated System', 'Automatically generated warning from monitoring systems', 8, false, 'cpu', 60),
    ('emergency_services', 'Emergency Services', 'Report from emergency services or rescue organizations', 10, false, 'ambulance', 70),
    ('weather_service', 'Weather Service', 'Official weather service warnings and forecasts', 9, false, 'cloud', 80),
    ('media_report', 'Media Report', 'Information from news media or journalists', 4, true, 'newspaper', 90),
    ('anonymous_report', 'Anonymous Report', 'Anonymous pilgrim or visitor report', 3, true, 'user-x', 100),
    ('historical_data', 'Historical Data', 'Warning based on historical patterns and seasonal data', 6, false, 'clock', 110),
    ('third_party_app', 'Third Party App', 'Report from external applications or services', 5, true, 'smartphone', 120)
ON CONFLICT (code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    reliability_score = EXCLUDED.reliability_score,
    requires_verification = EXCLUDED.requires_verification,
    icon_identifier = EXCLUDED.icon_identifier,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert workflow statuses
INSERT INTO public.workflow_statuses_master (
    code, display_name, description, is_publicly_visible, is_draft_status, is_published_status, 
    is_archived_status, allows_public_access, color_hex, icon_identifier, sort_order
) VALUES 
    ('draft', 'Draft', 'Warning is being prepared and not yet published', false, true, false, false, false, '#6b7280', 'edit', 10),
    ('pending_review', 'Pending Review', 'Warning submitted for review and approval', false, false, false, false, false, '#f59e0b', 'clock', 20),
    ('under_review', 'Under Review', 'Warning is currently being reviewed by content moderators', false, false, false, false, false, '#3b82f6', 'eye', 30),
    ('approved', 'Approved', 'Warning has been approved but not yet published', false, false, false, false, false, '#10b981', 'check-circle', 40),
    ('published', 'Published', 'Warning is actively published and visible to public', true, false, true, false, true, '#059669', 'globe', 50),
    ('updated', 'Updated', 'Published warning has been updated with new information', true, false, true, false, true, '#0891b2', 'refresh', 60),
    ('resolved', 'Resolved', 'Warning condition has been resolved but kept for reference', true, false, false, false, true, '#84cc16', 'check', 70),
    ('expired', 'Expired', 'Warning has passed its expiration date', false, false, false, false, false, '#71717a', 'calendar-x', 80),
    ('superseded', 'Superseded', 'Warning has been replaced by a newer warning', false, false, false, false, false, '#a3a3a3', 'arrow-right', 90),
    ('rejected', 'Rejected', 'Warning was rejected during review process', false, false, false, false, false, '#ef4444', 'x-circle', 100),
    ('archived', 'Archived', 'Warning has been archived for historical reference', false, false, false, true, false, '#6b7280', 'archive', 110),
    ('deleted', 'Deleted', 'Warning has been marked for deletion', false, false, false, false, false, '#dc2626', 'trash', 120)
ON CONFLICT (code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    is_publicly_visible = EXCLUDED.is_publicly_visible,
    is_draft_status = EXCLUDED.is_draft_status,
    is_published_status = EXCLUDED.is_published_status,
    is_archived_status = EXCLUDED.is_archived_status,
    allows_public_access = EXCLUDED.allows_public_access,
    color_hex = EXCLUDED.color_hex,
    icon_identifier = EXCLUDED.icon_identifier,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Add comments to document the seed data
COMMENT ON TABLE public.warning_severities_master IS 'Contains 6 predefined severity levels from info (1) to critical (10)';
COMMENT ON TABLE public.warning_types_master IS 'Contains 15 predefined warning types covering common trail conditions';
COMMENT ON TABLE public.warning_source_types_master IS 'Contains 12 predefined source types with reliability scoring';
COMMENT ON TABLE public.workflow_statuses_master IS 'Contains 12 predefined workflow states for content lifecycle management';