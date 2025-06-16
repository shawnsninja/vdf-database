-- Module 5: Dynamic Conditions
-- 004_localized_views.sql: Localized views for API consumption
-- 
-- Purpose: Create API-optimized views for warning system with localized labels

-- Create main localized view for active segment warnings
CREATE OR REPLACE VIEW public.v_segment_warnings_localized AS
SELECT 
    -- Core warning information
    sw.id,
    sw.segment_id,
    sw.warning_type_id,
    sw.severity_id,
    sw.source_type_id,
    sw.workflow_status_id,
    sw.title,
    sw.description,
    sw.detailed_description,
    
    -- Temporal information
    sw.date_warning_effective_from,
    sw.date_warning_expected_resolution,
    sw.date_warning_resolved_or_expired,
    sw.is_currently_active,
    
    -- Spatial information
    sw.location_on_segment_geom,
    sw.location_description,
    sw.affects_entire_segment,
    
    -- Source and verification
    sw.source_contact_info,
    sw.source_reference_url,
    sw.verification_date,
    sw.verified_by_profile_id,
    sw.verification_notes,
    
    -- Impact assessment
    sw.estimated_detour_distance_meters,
    sw.estimated_delay_minutes,
    sw.alternative_route_description,
    sw.safety_impact_level,
    sw.accessibility_impact_level,
    
    -- Media
    sw.primary_media_id,
    sw.supporting_media_ids,
    
    -- Administrative
    sw.internal_notes,
    sw.public_visibility_override,
    sw.notification_sent_at,
    
    -- Localized master data - Warning Type
    wt.code as warning_type_code,
    wt.display_name as warning_type_label,
    wt.description as warning_type_description,
    wt.icon_identifier as warning_type_icon,
    wt.sort_order as warning_type_sort_order,
    
    -- Localized master data - Severity
    ws.code as severity_code,
    ws.display_name as severity_label,
    ws.description as severity_description,
    ws.color_hex as severity_color,
    ws.icon_identifier as severity_icon,
    ws.urgency_level as severity_urgency_level,
    ws.sort_order as severity_sort_order,
    
    -- Localized master data - Source Type
    st.code as source_type_code,
    st.display_name as source_type_label,
    st.description as source_type_description,
    st.reliability_score as source_reliability_score,
    st.requires_verification as source_requires_verification,
    st.icon_identifier as source_type_icon,
    
    -- Localized master data - Workflow Status
    wfs.code as workflow_status_code,
    wfs.display_name as workflow_status_label,
    wfs.description as workflow_status_description,
    wfs.is_publicly_visible as workflow_status_publicly_visible,
    wfs.is_draft_status as workflow_status_is_draft,
    wfs.is_published_status as workflow_status_is_published,
    wfs.is_archived_status as workflow_status_is_archived,
    wfs.allows_public_access as workflow_status_allows_public_access,
    wfs.color_hex as workflow_status_color,
    wfs.icon_identifier as workflow_status_icon,
    
    -- Segment information
    s.name as segment_name,
    s.description as segment_description,
    s.distance_meters as segment_distance_meters,
    s.elevation_gain_meters as segment_elevation_gain_meters,
    s.elevation_loss_meters as segment_elevation_loss_meters,
    s.route_id as segment_route_id,
    
    -- Route information
    r.name as route_name,
    r.description as route_description,
    r.trail_id as route_trail_id,
    
    -- Trail information
    t.name as trail_name,
    t.description as trail_description,
    
    -- Verified by profile information
    vp.display_name as verified_by_display_name,
    vp.first_name as verified_by_first_name,
    vp.last_name as verified_by_last_name,
    
    -- Primary media information
    m.filename as primary_media_filename,
    m.content_type as primary_media_content_type,
    m.file_size_bytes as primary_media_file_size,
    m.width_pixels as primary_media_width,
    m.height_pixels as primary_media_height,
    m.alt_text as primary_media_alt_text,
    m.caption as primary_media_caption,
    
    -- Audit information
    sw.created_at,
    sw.updated_at,
    sw.created_by_profile_id,
    sw.updated_by_profile_id,
    
    -- Created by profile information
    cp.display_name as created_by_display_name,
    cp.first_name as created_by_first_name,
    cp.last_name as created_by_last_name,
    
    -- Updated by profile information
    up.display_name as updated_by_display_name,
    up.first_name as updated_by_first_name,
    up.last_name as updated_by_last_name
    
FROM public.segment_warnings sw
LEFT JOIN public.warning_types_master wt ON sw.warning_type_id = wt.id
LEFT JOIN public.warning_severities_master ws ON sw.severity_id = ws.id
LEFT JOIN public.warning_source_types_master st ON sw.source_type_id = st.id
LEFT JOIN public.workflow_statuses_master wfs ON sw.workflow_status_id = wfs.id
LEFT JOIN public.segments s ON sw.segment_id = s.id
LEFT JOIN public.routes r ON s.route_id = r.id
LEFT JOIN public.trails t ON r.trail_id = t.id
LEFT JOIN public.profiles vp ON sw.verified_by_profile_id = vp.id
LEFT JOIN public.media m ON sw.primary_media_id = m.id
LEFT JOIN public.profiles cp ON sw.created_by_profile_id = cp.id
LEFT JOIN public.profiles up ON sw.updated_by_profile_id = up.id;

-- Create view specifically for public active warnings (most common API endpoint)
CREATE OR REPLACE VIEW public.v_public_active_segment_warnings AS
SELECT 
    -- Core warning information
    sw.id,
    sw.segment_id,
    sw.title,
    sw.description,
    sw.detailed_description,
    
    -- Temporal information
    sw.date_warning_effective_from,
    sw.date_warning_expected_resolution,
    sw.is_currently_active,
    
    -- Spatial information
    sw.location_on_segment_geom,
    sw.location_description,
    sw.affects_entire_segment,
    
    -- Public source information (filtered)
    sw.source_reference_url,
    sw.verification_date,
    
    -- Impact assessment
    sw.estimated_detour_distance_meters,
    sw.estimated_delay_minutes,
    sw.alternative_route_description,
    sw.safety_impact_level,
    sw.accessibility_impact_level,
    
    -- Media
    sw.primary_media_id,
    
    -- Warning Type
    wt.code as warning_type_code,
    wt.display_name as warning_type_label,
    wt.description as warning_type_description,
    wt.icon_identifier as warning_type_icon,
    
    -- Severity
    ws.code as severity_code,
    ws.display_name as severity_label,
    ws.description as severity_description,
    ws.color_hex as severity_color,
    ws.icon_identifier as severity_icon,
    ws.urgency_level as severity_urgency_level,
    
    -- Source Type (filtered for public)
    st.display_name as source_type_label,
    st.reliability_score as source_reliability_score,
    st.icon_identifier as source_type_icon,
    
    -- Segment and location information
    s.name as segment_name,
    s.description as segment_description,
    s.distance_meters as segment_distance_meters,
    s.elevation_gain_meters as segment_elevation_gain_meters,
    s.elevation_loss_meters as segment_elevation_loss_meters,
    s.geometry as segment_geometry,
    
    -- Route and trail context
    r.name as route_name,
    r.description as route_description,
    t.name as trail_name,
    t.description as trail_description,
    
    -- Primary media (public info only)
    m.filename as primary_media_filename,
    m.content_type as primary_media_content_type,
    m.alt_text as primary_media_alt_text,
    m.caption as primary_media_caption,
    
    -- Public timestamps
    sw.created_at,
    sw.updated_at
    
FROM public.segment_warnings sw
JOIN public.warning_types_master wt ON sw.warning_type_id = wt.id AND wt.is_active = true
JOIN public.warning_severities_master ws ON sw.severity_id = ws.id AND ws.is_active = true
JOIN public.warning_source_types_master st ON sw.source_type_id = st.id AND st.is_active = true
JOIN public.workflow_statuses_master wfs ON sw.workflow_status_id = wfs.id 
    AND wfs.is_active = true 
    AND wfs.is_publicly_visible = true
JOIN public.segments s ON sw.segment_id = s.id AND s.deleted_at IS NULL
JOIN public.routes r ON s.route_id = r.id AND r.deleted_at IS NULL
JOIN public.trails t ON r.trail_id = t.id AND t.deleted_at IS NULL
LEFT JOIN public.media m ON sw.primary_media_id = m.id
WHERE sw.is_currently_active = true
  AND (sw.public_visibility_override IS NULL OR sw.public_visibility_override = true);

-- Create summary view for dashboard/statistics
CREATE OR REPLACE VIEW public.v_segment_warnings_summary AS
SELECT 
    -- Warning counts by type
    wt.code as warning_type_code,
    wt.display_name as warning_type_label,
    wt.icon_identifier as warning_type_icon,
    COUNT(*) as total_warnings,
    COUNT(*) FILTER (WHERE sw.is_currently_active = true) as active_warnings,
    
    -- Severity breakdown for active warnings
    COUNT(*) FILTER (WHERE sw.is_currently_active = true AND ws.urgency_level >= 8) as critical_active,
    COUNT(*) FILTER (WHERE sw.is_currently_active = true AND ws.urgency_level BETWEEN 4 AND 7) as moderate_active,
    COUNT(*) FILTER (WHERE sw.is_currently_active = true AND ws.urgency_level <= 3) as low_active,
    
    -- Average impact metrics for active warnings
    ROUND(AVG(sw.safety_impact_level) FILTER (WHERE sw.is_currently_active = true), 1) as avg_safety_impact,
    ROUND(AVG(sw.accessibility_impact_level) FILTER (WHERE sw.is_currently_active = true), 1) as avg_accessibility_impact,
    ROUND(AVG(sw.estimated_delay_minutes) FILTER (WHERE sw.is_currently_active = true AND sw.estimated_delay_minutes IS NOT NULL), 0) as avg_delay_minutes,
    
    -- Temporal information
    MIN(sw.date_warning_effective_from) FILTER (WHERE sw.is_currently_active = true) as earliest_active_warning,
    MAX(sw.date_warning_effective_from) FILTER (WHERE sw.is_currently_active = true) as latest_active_warning,
    
    -- Update tracking
    MAX(sw.updated_at) as last_updated
    
FROM public.segment_warnings sw
JOIN public.warning_types_master wt ON sw.warning_type_id = wt.id AND wt.is_active = true
JOIN public.warning_severities_master ws ON sw.severity_id = ws.id AND ws.is_active = true
JOIN public.segments s ON sw.segment_id = s.id AND s.deleted_at IS NULL
JOIN public.routes r ON s.route_id = r.id AND r.deleted_at IS NULL
JOIN public.trails t ON r.trail_id = t.id AND t.deleted_at IS NULL
GROUP BY wt.id, wt.code, wt.display_name, wt.icon_identifier, wt.sort_order
ORDER BY wt.sort_order, wt.display_name;

-- Create geographic summary view for map displays
CREATE OR REPLACE VIEW public.v_segment_warnings_geographic AS
SELECT 
    -- Segment geographic information
    s.id as segment_id,
    s.name as segment_name,
    s.geometry as segment_geometry,
    ST_Centroid(s.geometry) as segment_centroid,
    
    -- Route and trail context
    r.id as route_id,
    r.name as route_name,
    t.id as trail_id,
    t.name as trail_name,
    
    -- Warning counts and severity
    COUNT(*) FILTER (WHERE sw.is_currently_active = true) as active_warning_count,
    MAX(ws.urgency_level) FILTER (WHERE sw.is_currently_active = true) as max_severity_level,
    
    -- Most severe active warning details
    (SELECT sw2.title FROM public.segment_warnings sw2 
     JOIN public.warning_severities_master ws2 ON sw2.severity_id = ws2.id
     WHERE sw2.segment_id = s.id 
     AND sw2.is_currently_active = true 
     ORDER BY ws2.urgency_level DESC, sw2.created_at DESC 
     LIMIT 1) as most_severe_warning_title,
     
    (SELECT ws2.color_hex FROM public.segment_warnings sw2 
     JOIN public.warning_severities_master ws2 ON sw2.severity_id = ws2.id
     WHERE sw2.segment_id = s.id 
     AND sw2.is_currently_active = true 
     ORDER BY ws2.urgency_level DESC, sw2.created_at DESC 
     LIMIT 1) as most_severe_warning_color,
     
    -- Warning locations on segment
    array_agg(sw.location_on_segment_geom ORDER BY sw.created_at) 
        FILTER (WHERE sw.is_currently_active = true AND sw.location_on_segment_geom IS NOT NULL) as warning_locations,
    
    -- Update tracking
    MAX(sw.updated_at) FILTER (WHERE sw.is_currently_active = true) as last_warning_update
    
FROM public.segments s
LEFT JOIN public.segment_warnings sw ON s.id = sw.segment_id 
    AND sw.is_currently_active = true
LEFT JOIN public.warning_severities_master ws ON sw.severity_id = ws.id AND ws.is_active = true
JOIN public.routes r ON s.route_id = r.id AND r.deleted_at IS NULL
JOIN public.trails t ON r.trail_id = t.id AND t.deleted_at IS NULL
WHERE s.deleted_at IS NULL
GROUP BY s.id, s.name, s.geometry, r.id, r.name, t.id, t.name
HAVING COUNT(*) FILTER (WHERE sw.is_currently_active = true) > 0
ORDER BY max_severity_level DESC NULLS LAST, active_warning_count DESC;

-- Add comments for all views
COMMENT ON VIEW public.v_segment_warnings_localized IS 'Complete localized view of segment warnings with all master table labels and related entity information for administrative interfaces';
COMMENT ON VIEW public.v_public_active_segment_warnings IS 'Public-facing view of currently active segment warnings with filtered information suitable for pilgrim-facing APIs';
COMMENT ON VIEW public.v_segment_warnings_summary IS 'Statistical summary view of warnings grouped by type for dashboard and reporting purposes';
COMMENT ON VIEW public.v_segment_warnings_geographic IS 'Geographic summary view optimized for map displays showing warning counts and severity by segment';