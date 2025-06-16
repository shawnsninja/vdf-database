# 0. VDF Database Overview

  https://gemini.google.com/u/1/app/4e4c57eff1c5afd3 
https://gemini.google.com/u/1/app/4e4c57eff1c5afd3 
https://gemini.google.com/u/1/app/cfcea269c16d7792 Project Overview: Via di 
Francesco Pilgrimage Platform Database (Updated May 18, 2025 -- V2.1) 
================================================================================
============= 1. 🚀 Executive Summary The Via di Francesco Pilgrimage Platform 
aims to be the definitive digital companion for pilgrims, offering 
comprehensive, reliable, and engaging information for planning and undertaking 
their journeys. This V2.1 update of the database overview reflects significant 
progress across all modules, emphasizing standardization towards V2 patterns, 
enhanced data integrity, and improved support for multilingual content and rich 
media. Key advancements in this iteration include the consistent application of 
standardized audit columns (`created_by_profile_id`, `updated_by_profile_id`, 
`created_at`, `updated_at`) across almost all tables, refined lifecycle 
management for master data (`is_active` flags) and transactional data 
(`deleted_at` timestamps), a more robust and centralized internationalization 
(i18n) strategy leveraging the `public.translations` table with primary 
language (English) content stored directly in entity tables, and enhanced media 
management through dedicated linking tables and semantic roles. Furthermore, 
Row-Level Security (RLS) policies have been refined and are consistently 
designed to integrate with Supabase Auth and standardized helper functions. 
Many modules now also feature specialized views to optimize data retrieval for 
API endpoints, particularly for localized content. 2. 🎯 Refined Goals & 
Success Metrics This V2.1 update reinforces the project's core goals by 
enhancing data quality, system maintainability, and the richness of information 
provided to users. Specific refinements and new objectives supported by these 
updates include: - Enhanced Data Integrity & Auditability: Standardized audit 
columns and lifecycle flags across all modules significantly improve data 
tracking and governance capabilities. - Improved Multilingual Support: 
Centralized translation management with primary language direct storage makes 
content more accessible and easier to manage globally. - Richer Media 
Integration: New media linking strategies allow for more versatile and 
context-specific image and file associations (e.g., galleries, specific roles 
for articles). - Streamlined API Performance: Introduction of localized and 
summary views aims to optimize data retrieval for common API queries. - 
Increased Pilgrim Safety: The Dynamic Conditions module (Module 5) provides 
more structured and verifiable information about trail warnings and hazards. - 
Better Pilgrim Planning: Detailed information for accommodations (Module 4a), 
attractions, food/water sources, shops/services (Module 4b), transport (Module 
4c), and events (Module 4d) allows for more comprehensive journey planning. - 
Enhanced User Engagement: Module 6 (User Interaction) enables waypoint voting 
and moderated tips, while Module 8 (Platform Content) supports rich articles 
and news. 3. 👥 Primary Personas & User Stories The primary user roles remain 
consistent: - Pilgrims: Planning and undertaking journeys, seeking information 
on routes, POIs, accommodations, conditions. - Accommodation Hosts: Managing 
their listings and availability. - Regional Content Managers: Updating local 
information, trail conditions, and POIs. - Platform Administrators: Overseeing 
content, system integrity, and user management. Module updates provide richer 
data and better tools for all personas, for instance, through more detailed 
filtering for pilgrims or more structured content management for hosts and 
administrators. 4. 🗺️ Module Map (Snapshot Table) | Module | Core Purpose | Key 
Tables | Version | Major Changes (V2.1 Rollup) | | 
:-------------------------------------------------- | 
:-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
---------------------------------------- | 
:-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------------------- | 
:---------------------------------------- | 
:-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------------------------- | | 1. User & Content 
Infrastructure | Manages users, roles (JWT sync), languages, media metadata, 
and platform-wide translations. | profiles, user_roles_master, 
languages_master, media, translations. | 2.3 | Standardized audit columns 
(created_by_profile_id, updated_by_profile_id); icon_identifier in master 
tables; primary language (English) content stored directly in main tables, 
others in public.translations; API returns base field in English & 
*_translations object; profiles.last_activity_at added; role synchronization to 
auth.users.raw_app_meta_data.roles via triggers. | | 2. Core Trail Hierarchy | 
Defines structure and characteristics of trails, routes, and segments, 
including master data for terrain and usage. | trails, routes, segments, 
route_segments, terrain_types_master, usage_types_master, segment_media. | 2.2 
(API Aligned) | GPX file management shifted to media table (via media_id); 
segment_media enhanced with media_role_code and translatable captions/alt-text; 
surrogate id PKs for junction tables (trail_regions, route_segments); 
terrain_types_master & usage_types_master updated to full V2 spec (is_active, 
audit columns, translatable names); all module tables now have full V2 audit 
columns; new localized views for API support (v_trails_detailed_localized, 
etc.). | | 3. Geographical Context | Defines and categorizes geographical areas 
(regions, provinces, towns) with multilingual support and auditability. | 
regions, provinces, towns, characteristic_tags_master, service_tags_master, 
town_types_master. | 2.2 (API-Aware) | Consistent V2 audit columns and 
lifecycle management (is_active for master/provinces; deleted_at & 
content_visibility_status for regions/towns); master tables 
(characteristic_tags_master, etc.) enhanced with is_active, audit, translatable 
names, icons; array FK validation triggers (e.g., 
trigger_validate_characteristics_tags); new region_media & town_media linking 
tables for galleries; localized views (v_towns_list_localized, 
v_regions_list_localized) for API efficiency. | | 4. Waypoint Detail Modules 
(General) | Manages core POI ("waypoint") information, categorization, tagging, 
and content lifecycle. | waypoints, waypoint_categories_master, tags_master, 
content_statuses_master. | 1.2 | Finalized core tables (waypoints v1.3, master 
tables v1.2/1.3) to V2 patterns (audit columns, is_active for master data, 
deleted_at for waypoints, i18n support via public.translations); localized 
views (v_waypoint_categories_localized, v_tags_localized) introduced for 
efficient localized master data retrieval; array FK integrity trigger 
trigger_check_waypoint_subcategory_tags for 
waypoints.waypoint_subcategory_tag_ids. | | 4a. Waypoint - Accommodations | 
Manages detailed accommodation-specific information including types, amenities, 
rooms, pricing, and reviews. | accommodations, accommodation_reviews, various 
*_master tables (e.g., accommodation_types_master), various accommodation_* 
junction tables. | 1.0 (New) | New module. Central accommodations table (v1.5); 
numerous specialized master tables (e.g., accommodation_types_master v1.4, 
amenities_master v1.5) aligned with V2 patterns (audit, is_active, translatable 
labels/descriptions, icons, sort order); junction tables (e.g., 
accommodation_amenities v1.4) with translatable notes and audit columns; new 
accommodation_reviews table (v1.0) with moderation workflow; localized views 
(e.g., v_accommodation_types_localized) for all master tables; 
accommodations_capacity_summary_view; specific translation cleanup triggers per 
table. | | 4b. Waypoint - Attractions, Food/Water, Shops/Services | Enriches 
waypoints with specific details for attractions (incl. religious services), 
food/water sources, and shops/services. | attractions_details, 
religious_service_schedules, food_water_sources_details, 
shops_and_services_details, numerous *_master tables, *_media linking tables. | 
1.1 (New) | New module. Detail tables (attractions_details v1.3.1, etc.) with 
translatable fields; numerous master tables (attraction_types_master v1.1, 
etc.) with V2 patterns (is_active, audit, translatable labels, icons, sort 
order); dedicated *_media linking tables (e.g., attraction_details_media v1.0) 
for galleries with roles and translatable overrides; localized views 
(v_waypoint_attraction_details_localized v1.0, etc.) for efficient API data 
retrieval; "active check" triggers for all FKs to master tables; array FK 
integrity triggers; shops_and_services_details.deleted_at for independent soft 
delete. | | 4c. Waypoint - Transportation | Manages public transportation stop 
information, types, facilities, and operational details. | 
transport_stops_details, transport_stop_types_master, 
transport_stop_facilities_master, view_transport_stops_enriched. | 2.1 (New) | 
New module. Master tables (transport_stop_types_master v2.1, 
transport_stop_facilities_master v2.1) with V2 patterns (is_active, full audit, 
translatable labels, icons, sort order); transport_stops_details table (v2.1) 
links to waypoints, includes translatable operator_names_text array, and 
stop_facility_ids array FK with validation trigger 
check_transport_stop_facility_ids; new view_transport_stops_enriched (v2.1) for 
API efficiency; orphan translation cleanup triggers; standardized API 
translation model (primary lang field + translations object); 
transport_stops_details.deleted_at added for soft delete. | | 4d. Waypoint - 
Events | Manages detailed information about events associated with waypoints, 
including classification, timing, and scale. | events_details, 
event_types_master, event_recurrence_frequencies_master, 
event_attendance_scales_master, event_date_certainty_levels_master. | 1.1 (New) 
| New module. Central events_details table (v1.3); master tables 
(event_types_master v1.1, etc.) with V2 patterns (code, default_name 
(translatable), is_active, audit columns, sort order, icons); 
event_theme_or_focus_tag_ids (array FK to tags_master) with validation trigger 
(trigger_validate_event_theme_tags); orphan translation cleanup triggers for 
all module tables; events_details.deleted_at for soft deletion; full V2 audit 
columns on all module tables; primary language content in direct fields, other 
languages in public.translations. | | 5. Dynamic Conditions | Manages and 
disseminates timely, verifiable information about warnings, hazards, closures, 
and advisories for trail segments. | segment_warnings, warning_types_master, 
warning_severities_master, warning_source_types_master, 
workflow_statuses_master. | 2.1 | Master tables (warning_types_master v2.1, 
etc.) aligned to V2 patterns (id PK, code, display_name (translatable), 
is_active, audit columns by profiles.id, icons, sort order); segment_warnings 
table (v2.1) with segment_id (FK), warning_type_id (FK), is_currently_active 
(generated column), workflow_status_code (FK), and audit by auth.users.id; 
public_active_segment_warnings_view (v1.0) proposed for simplified public 
access to active warnings; orphan translation cleanup triggers. | | 6. User 
Interaction Module | Capturing user votes on waypoints, managing user-submitted 
tips with moderation, and defining standardized, translatable categories for 
tips. | user_waypoint_votes, user_waypoint_short_tips, tip_categories_master. | 
2.0 | tip_categories_master (v2.1) updated to V2 patterns (category_code PK, 
translatable default_name/description, is_active, audit); user_waypoint_votes 
(v2.1.1) with trigger update_waypoint_vote_counts to denormalize counts onto 
public.waypoints; user_waypoint_short_tips (v2.1.1) with is_publicly_visible 
generated column and detailed moderation fields; view_tip_categories_localized 
for API support. | | 7. Curated Itinerary Module | Defines, structures, 
categorizes, and manages the lifecycle of pre-defined pilgrimage itineraries 
and their associated lookup data. | curated_itineraries, 
curated_itinerary_segments, itinerary_categories_master, seasons_master, 
trail_difficulty_levels_master, content_statuses_master. | 2.1 | Promotion of 
ENUMs (difficulty, status, categories, seasons) to full master tables (v2.1) 
with V2 patterns (code, name (translatable), is_active, audit, icons, sort 
order); full V2 audit columns on all module tables; orphan translation cleanup 
triggers; curated_itineraries (v3.1) with content_status_id FK (NOT NULL); new 
junction tables curated_itinerary_to_category (v2.1) and 
curated_itinerary_to_season (v2.1); localized views 
(v_curated_itineraries_list_localized, etc.). User GWI Event Manager - **Module 
8: Platform Content | Manages general platform content like news, articles, and 
blog posts, supporting rich text, multimedia, author attribution, and 
associations. | `articles`, `media_roles_master`, `article_media`, 
`published_articles_view`, `article_media_details_view`. | 1.0 (New) | New 
module providing a framework for creating, managing, and displaying dynamic 
content like news and articles. Supports featured images, media galleries, 
author attribution, and multilingual capabilities via `public.translations`. 
Includes RLS policies for content integrity and access. Standard audit columns 
and soft delete (`deleted_at`) are included. `media_roles_master` defines media 
use within articles. Plogging data from the user about each of modules to 
create a summary. Done. Now generating the comprehensive project overview 
document.Project Overview: Via di Francesco Pilgrimage Platform Database 
(Updated May 18, 2025 -- V2.1) 
================================================================================
======================================================================== 1. 🚀 
Executive Summary The Via di Francesco Pilgrimage Platform aims to be the 
definitive digital companion for pilgrims, offering comprehensive, reliable, 
and engaging information for planning and undertaking their journeys. This V2.1 
update of the database overview reflects significant progress across all 
modules, emphasizing standardization towards V2 patterns, enhanced data 
integrity, and improved support for multilingual content and rich media. Key 
advancements in this iteration include the consistent application of 
standardized audit columns (`created_by_profile_id`, `updated_by_profile_id`, 
`created_at`, `updated_at`) across almost all tables, refined lifecycle 
management for master data (`is_active` flags) and transactional data 
(`deleted_at` timestamps), a more robust and centralized internationalization 
(i18n) strategy leveraging the `public.translations` table with primary 
language (English) content stored directly in entity tables, and enhanced media 
management through dedicated linking tables and semantic roles. Furthermore, 
Row-Level Security (RLS) policies have been refined and are consistently 
designed to integrate with Supabase Auth and standardized helper functions. 
Many modules now also feature specialized views to optimize data retrieval for 
API endpoints, particularly for localized content. 2. 🎯 Refined Goals & 
Success Metrics This V2.1 update reinforces the project's core goals by 
enhancing data quality, system maintainability, and the richness of information 
provided to users. Specific refinements and new objectives supported by these 
updates include: - Enhanced Data Integrity & Auditability: Standardized audit 
columns and lifecycle flags across all modules significantly improve data 
tracking and governance capabilities. - Improved Multilingual Support: 
Centralized translation management with primary language direct storage makes 
content more accessible and easier to manage globally. - Richer Media 
Integration: New media linking strategies allow for more versatile and 
context-specific image and file associations (e.g., galleries, specific roles 
for articles). - Streamlined API Performance: Introduction of localized and 
summary views aims to optimize data retrieval for common API queries. - 
Increased Pilgrim Safety: The Dynamic Conditions module (Module 5) provides 
more structured and verifiable information about trail warnings and hazards. - 
Better Pilgrim Planning: Detailed information for accommodations (Module 4a), 
attractions, food/water sources, shops/services (Module 4b), transport (Module 
4c), and events (Module 4d) allows for more comprehensive journey planning. - 
Enhanced User Engagement: Module 6 (User Interaction) enables waypoint voting 
and moderated tips, while Module 8 (Platform Content) supports rich articles 
and news. 3. 👥 Primary Personas & User Stories The primary user roles remain 
consistent: - Pilgrims: Planning and undertaking journeys, seeking information 
on routes, POIs, accommodations, conditions. - Accommodation Hosts: Managing 
their listings and availability. - Regional Content Managers: Updating local 
information, trail conditions, and POIs. - Platform Administrators: Overseeing 
content, system integrity, and user management. Module updates provide richer 
data and better tools for all personas, for instance, through more detailed 
filtering for pilgrims or more structured content management for hosts and 
administrators. 4. 🗺️ Module Map (Snapshot Table) | Module | Core Purpose | Key 
Tables | Version | Major Changes (V2.1 Rollup) | | 
:-------------------------------------------------- | 
:-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
---------------------------------------- | 
:-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------------------- | 
:---------------------------------------- | 
:-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------------------------- | | 1. User & Content 
Infrastructure | Manages users, roles (JWT sync), languages, media metadata, 
and platform-wide translations. | profiles, user_roles_master, 
languages_master, media, translations. | 2.3 | Standardized audit columns 
(created_by_profile_id, updated_by_profile_id); icon_identifier in master 
tables; primary language (English) content stored directly in main tables, 
others in public.translations; API returns base field in English & 
*_translations object; profiles.last_activity_at added; role synchronization to 
auth.users.raw_app_meta_data.roles via triggers. | | 2. Core Trail Hierarchy | 
Defines structure and characteristics of trails, routes, and segments, 
including master data for terrain and usage. | trails, routes, segments, 
route_segments, terrain_types_master, usage_types_master, segment_media. | 2.2 
(API Aligned) | GPX file management shifted to media table (via media_id); 
segment_media enhanced with media_role_code and translatable captions/alt-text; 
surrogate id PKs for junction tables (trail_regions, route_segments); 
terrain_types_master & usage_types_master updated to full V2 spec (is_active, 
audit columns, translatable names); all module tables now have full V2 audit 
columns; new localized views for API support (v_trails_detailed_localized, 
etc.). | | 3. Geographical Context | Defines and categorizes geographical areas 
(regions, provinces, towns) with multilingual support and auditability. | 
regions, provinces, towns, characteristic_tags_master, service_tags_master, 
town_types_master. | 2.2 (API-Aware) | Consistent V2 audit columns and 
lifecycle management (is_active for master/provinces; deleted_at & 
content_visibility_status for regions/towns); master tables 
(characteristic_tags_master, etc.) enhanced with is_active, audit, translatable 
names, icons; array FK validation triggers (e.g., 
trigger_validate_characteristics_tags); new region_media & town_media linking 
tables for galleries; localized views (v_towns_list_localized, 
v_regions_list_localized) for API efficiency. | | 4. Waypoint Detail Modules 
(General) | Manages core POI ("waypoint") information, categorization, tagging, 
and content lifecycle. | waypoints, waypoint_categories_master, tags_master, 
content_statuses_master. | 1.2 | Finalized core tables (waypoints v1.3, master 
tables v1.2/1.3) to V2 patterns (audit columns, is_active for master data, 
deleted_at for waypoints, i18n support via public.translations); localized 
views (v_waypoint_categories_localized, v_tags_localized) introduced for 
efficient localized master data retrieval; array FK integrity trigger 
trigger_check_waypoint_subcategory_tags for 
waypoints.waypoint_subcategory_tag_ids. | | 4a. Waypoint - Accommodations | 
Manages detailed accommodation-specific information including types, amenities, 
rooms, pricing, and reviews. | accommodations, accommodation_reviews, various 
*_master tables (e.g., accommodation_types_master), various accommodation_* 
junction tables. | 1.0 (New) | New module. Central accommodations table (v1.5); 
numerous specialized master tables (e.g., accommodation_types_master v1.4, 
amenities_master v1.5) aligned with V2 patterns (audit, is_active, translatable 
labels/descriptions, icons, sort order); junction tables (e.g., 
accommodation_amenities v1.4) with translatable notes and audit columns; new 
accommodation_reviews table (v1.0) with moderation workflow; localized views 
(e.g., v_accommodation_types_localized) for all master tables; 
accommodations_capacity_summary_view; specific translation cleanup triggers per 
table. | | 4b. Waypoint - Attractions, Food/Water, Shops/Services | Enriches 
waypoints with specific details for attractions (incl. religious services), 
food/water sources, and shops/services. | attractions_details, 
religious_service_schedules, food_water_sources_details, 
shops_and_services_details, numerous *_master tables, *_media linking tables. | 
1.1 (New) | New module. Detail tables (attractions_details v1.3.1, etc.) with 
translatable fields; numerous master tables (attraction_types_master v1.1, 
etc.) with V2 patterns (is_active, audit, translatable labels, icons, sort 
order); dedicated *_media linking tables (e.g., attraction_details_media v1.0) 
for galleries with roles and translatable overrides; localized views 
(v_waypoint_attraction_details_localized v1.0, etc.) for efficient API data 
retrieval; "active check" triggers for all FKs to master tables; array FK 
integrity triggers; shops_and_services_details.deleted_at for independent soft 
delete. | | 4c. Waypoint - Transportation | Manages public transportation stop 
information, types, facilities, and operational details. | 
transport_stops_details, transport_stop_types_master, 
transport_stop_facilities_master, view_transport_stops_enriched. | 2.1 (New) | 
New module. Master tables (transport_stop_types_master v2.1, 
transport_stop_facilities_master v2.1) with V2 patterns (is_active, full audit, 
translatable labels, icons, sort order); transport_stops_details table (v2.1) 
links to waypoints, includes translatable operator_names_text array, and 
stop_facility_ids array FK with validation trigger 
check_transport_stop_facility_ids; new view_transport_stops_enriched (v2.1) for 
API efficiency; orphan translation cleanup triggers; standardized API 
translation model (primary lang field + translations object); 
transport_stops_details.deleted_at added for soft delete. | | 4d. Waypoint - 
Events | Manages detailed information about events associated with waypoints, 
including classification, timing, and scale. | events_details, 
event_types_master, event_recurrence_frequencies_master, 
event_attendance_scales_master, event_date_certainty_levels_master. | 1.1 (New) 
| New module. Central events_details table (v1.3); master tables 
(event_types_master v1.1, etc.) with V2 patterns (code, default_name 
(translatable), is_active, audit columns, sort order, icons); 
event_theme_or_focus_tag_ids (array FK to tags_master) with validation trigger 
(trigger_validate_event_theme_tags); orphan translation cleanup triggers for 
all module tables; events_details.deleted_at for soft deletion; full V2 audit 
columns on all module tables; primary language content in direct fields, other 
languages in public.translations. | | 5. Dynamic Conditions | Manages and 
disseminates timely, verifiable information about warnings, hazards, closures, 
and advisories for trail segments. | segment_warnings, warning_types_master, 
warning_severities_master, warning_source_types_master, 
workflow_statuses_master. | 2.1 | Master tables (warning_types_master v2.1, 
etc.) aligned to V2 patterns (id PK, code, display_name (translatable), 
is_active, audit columns by profiles.id, icons, sort order); segment_warnings 
table (v2.1) with segment_id (FK), warning_type_id (FK), is_currently_active 
(generated column), workflow_status_code (FK), and audit by auth.users.id; 
public_active_segment_warnings_view (v1.0) proposed for simplified public 
access to active warnings; orphan translation cleanup triggers. | | 6. User 
Interaction Module | Capturing user votes on waypoints, managing user-submitted 
tips with moderation, and defining standardized, translatable categories for 
tips. | user_waypoint_votes, user_waypoint_short_tips, tip_categories_master. | 
2.0 | tip_categories_master (v2.1) updated to V2 patterns (category_code PK, 
translatable default_name/description, is_active, audit); user_waypoint_votes 
(v2.1.1) with trigger update_waypoint_vote_counts to denormalize counts onto 
public.waypoints; user_waypoint_short_tips (v2.1.1) with is_publicly_visible 
generated column and detailed moderation fields; view_tip_categories_localized 
for API support. | | 7. Curated Itinerary Module | Defines, structures, 
categorizes, and manages the lifecycle of pre-defined pilgrimage itineraries 
and their associated lookup data. | curated_itineraries, 
curated_itinerary_segments, itinerary_categories_master, seasons_master, 
trail_difficulty_levels_master, content_statuses_master. | 2.1 | Promotion of 
ENUMs (difficulty, status, categories, seasons) to full master tables (v2.1) 
with V2 patterns (code, name (translatable), is_active, audit, icons, sort 
order); full V2 audit columns on all module tables; orphan translation cleanup 
triggers; curated_itineraries (v3.1) with content_status_id FK (NOT NULL); new 
junction tables curated_itinerary_to_category (v2.1) and 
curated_itinerary_to_season (v2.1); localized views 
(v_curated_itineraries_list_localized, etc.). // MinifistOK (USS Account for 
Via di Francesco Pilgrimage Platform database): Okay, sounds good. I'm ready 
when you are. Please ensure all the context files have been provided. I will be 
sure to pay close attention to the instructions on the output structure. 
Project Overview: Via di Francesco Pilgrimage Platform Database (Updated May 
18, 2025 -- V2.1) 
================================================================================
================ 5. 🚀 Executive Summary The Via di Francesco Pilgrimage 
Platform aims to be the definitive digital companion for pilgrims, offering 
comprehensive, reliable, and engaging information for planning and undertaking 
their journeys. This V2.1 update of the database overview reflects significant 
progress across all modules, emphasizing standardization towards V2 patterns, 
enhanced data integrity, and improved support for multilingual content and rich 
media. Key advancements in this iteration include the consistent application of 
standardized audit columns (`created_by_profile_id`, `updated_by_profile_id`, 
`created_at`, `updated_at`) across almost all tables, refined lifecycle 
management for master data (`is_active` flags) and transactional data 
(`deleted_at` timestamps), a more robust and centralized internationalization 
(i18n) strategy leveraging the `public.translations` table with primary 
language (English) content stored directly in entity tables, and enhanced media 
management through dedicated linking tables and semantic roles. Furthermore, 
Row-Level Security (RLS) policies have been refined and are consistently 
designed to integrate with Supabase Auth and standardized helper functions. 
Many modules now also feature specialized views to optimize data retrieval for 
API endpoints, particularly for localized content. 6. 🎯 Refined Goals & 
Success Metrics This V2.1 update reinforces the project's core goals by 
enhancing data quality, system maintainability, and the richness of information 
provided to users. Specific refinements and new objectives supported by these 
updates include: - Enhanced Data Integrity & Auditability: Standardized audit 
columns and lifecycle flags across all modules significantly improve data 
tracking and governance capabilities. - Improved Multilingual Support: 
Centralized translation management with primary language direct storage makes 
content more accessible and easier to manage globally. - Richer Media 
Integration: New media linking strategies allow for more versatile and 
context-specific image and file associations (e.g., galleries, specific roles 
for articles). - Streamlined API Performance: Introduction of localized and 
summary views aims to optimize data retrieval for common API queries. - 
Increased Pilgrim Safety: The Dynamic Conditions module (Module 5) provides 
more structured and verifiable information about trail warnings and hazards. - 
Better Pilgrim Planning: Detailed information for accommodations (Module 4a), 
attractions, food/water sources, shops/services (Module 4b), transport (Module 
4c), and events (Module 4d) allows for more comprehensive journey planning. - 
Enhanced User Engagement: Module 6 (User Interaction) enables waypoint voting 
and moderated tips, while Module 8 (Platform Content) supports rich articles 
and news. 7. 👥 Primary Personas & User Stories The primary user roles remain 
consistent: - Pilgrims: Planning and undertaking journeys, seeking information 
on routes, POIs, accommodations, conditions. - Accommodation Hosts: Managing 
their listings and availability. - Regional Content Managers: Updating local 
information, trail conditions, and POIs. - Platform Administrators: Overseeing 
content, system integrity, and user management. Module updates provide richer 
data and better tools for all personas, for instance, through more detailed 
filtering for pilgrims or more structured content management for hosts and 
administrators. 8. 🗺️ Module Map (Snapshot Table) | Module | Core Purpose | Key 
Tables | Version | Major Changes (V2.1 Rollup) | | 
:-------------------------------------------------- | 
:-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
---------------------------------------- | 
:-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------------------- | 
:---------------------------------------- | 
:-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------------------------- | | 1. User & Content 
Infrastructure | Manages users, roles (JWT sync), languages, media metadata, 
and platform-wide translations. | profiles, user_roles_master, 
languages_master, media, translations. | 2.3 | Standardized audit columns 
(created_by_profile_id, updated_by_profile_id); icon_identifier in master 
tables; primary language (English) content stored directly in main tables, 
others in public.translations; API returns base field in English & 
*_translations object; profiles.last_activity_at added; role synchronization to 
auth.users.raw_app_meta_data.roles via triggers. | | 2. Core Trail Hierarchy | 
Defines structure and characteristics of trails, routes, and segments, 
including master data for terrain and usage. | trails, routes, segments, 
route_segments, terrain_types_master, usage_types_master, segment_media. | 2.2 
(API Aligned) | GPX file management shifted to media table (via media_id); 
segment_media enhanced with media_role_code and translatable captions/alt-text; 
surrogate id PKs for junction tables (trail_regions, route_segments); 
terrain_types_master & usage_types_master updated to full V2 spec (is_active, 
audit columns, translatable names); all module tables now have full V2 audit 
columns; new localized views for API support (v_trails_detailed_localized, 
etc.). | | 3. Geographical Context | Defines and categorizes geographical areas 
(regions, provinces, towns) with multilingual support and auditability. | 
regions, provinces, towns, characteristic_tags_master, service_tags_master, 
town_types_master. | 2.2 (API-Aware) | Consistent V2 audit columns and 
lifecycle management (is_active for master/provinces; deleted_at & 
content_visibility_status for regions/towns); master tables 
(characteristic_tags_master, etc.) enhanced with is_active, audit, translatable 
names, icons; array FK validation triggers (e.g., 
trigger_validate_characteristics_tags); new region_media & town_media linking 
tables for galleries; localized views (v_towns_list_localized, 
v_regions_list_localized) for API efficiency. | | 4. Waypoint Detail Modules 
(General) | Manages core POI ("waypoint") information, categorization, tagging, 
and content lifecycle. | waypoints, waypoint_categories_master, tags_master, 
content_statuses_master. | 1.2 | Finalized core tables (waypoints v1.3, master 
tables v1.2/1.3) to V2 patterns (audit columns, is_active for master data, 
deleted_at for waypoints, i18n support via public.translations); localized 
views (v_waypoint_categories_localized, v_tags_localized) introduced for 
efficient localized master data retrieval; array FK integrity trigger 
trigger_check_waypoint_subcategory_tags for 
waypoints.waypoint_subcategory_tag_ids. | | 4a. Waypoint - Accommodations | 
Manages detailed accommodation-specific information including types, amenities, 
rooms, pricing, and reviews. | accommodations, accommodation_reviews, various 
*_master tables (e.g., accommodation_types_master), various accommodation_* 
junction tables. | 1.0 (New) | New module. Central accommodations table (v1.5); 
numerous specialized master tables (e.g., accommodation_types_master v1.4, 
amenities_master v1.5) aligned with V2 patterns (audit, is_active, translatable 
labels/descriptions, icons, sort order); junction tables (e.g., 
accommodation_amenities v1.4) with translatable notes and audit columns; new 
accommodation_reviews table (v1.0) with moderation workflow; localized views 
(e.g., v_accommodation_types_localized) for all master tables; 
accommodations_capacity_summary_view; specific translation cleanup triggers per 
table. | | 4b. Waypoint - Attractions, Food/Water, Shops/Services | Enriches 
waypoints with specific details for attractions (incl. religious services), 
food/water sources, and shops/services. | attractions_details, 
religious_service_schedules, food_water_sources_details, 
shops_and_services_details, numerous *_master tables, *_media linking tables. | 
1.1 (New) | New module. Detail tables (attractions_details v1.3.1, etc.) with 
translatable fields; numerous master tables (attraction_types_master v1.1, 
etc.) with V2 patterns (is_active, audit, translatable labels, icons, sort 
order); dedicated *_media linking tables (e.g., attraction_details_media v1.0) 
for galleries with roles and translatable overrides; localized views 
(v_waypoint_attraction_details_localized v1.0, etc.) for efficient API data 
retrieval; "active check" triggers for all FKs to master tables; array FK 
integrity triggers; shops_and_services_details.deleted_at for independent soft 
delete. | | 4c. Waypoint - Transportation | Manages public transportation stop 
information, types, facilities, and operational details. | 
transport_stops_details, transport_stop_types_master, 
transport_stop_facilities_master, view_transport_stops_enriched. | 2.1 (New) | 
New module. Master tables (transport_stop_types_master v2.1, 
transport_stop_facilities_master v2.1) with V2 patterns (is_active, full audit, 
translatable labels, icons, sort order); transport_stops_details table (v2.1) 
links to waypoints, includes translatable operator_names_text array, and 
stop_facility_ids array FK with validation trigger 
check_transport_stop_facility_ids; new view_transport_stops_enriched (v2.1) for 
API efficiency; orphan translation cleanup triggers; standardized API 
translation model (primary lang field + translations object); 
transport_stops_details.deleted_at added for soft delete. | | 4d. Waypoint - 
Events | Manages detailed information about events associated with waypoints, 
including classification, timing, and scale. | events_details, 
event_types_master, event_recurrence_frequencies_master, 
event_attendance_scales_master, event_date_certainty_levels_master. | 1.1 (New) 
| New module. Central events_details table (v1.3); master tables 
(event_types_master v1.1, etc.) with V2 patterns (code, default_name 
(translatable), is_active, audit columns, sort order, icons); 
event_theme_or_focus_tag_ids (array FK to tags_master) with validation trigger 
(trigger_validate_event_theme_tags); orphan translation cleanup triggers for 
all module tables; events_details.deleted_at for soft deletion; full V2 audit 
columns on all module tables; primary language content in direct fields, other 
languages in public.translations. | | 5. Dynamic Conditions | Manages and 
disseminates timely, verifiable information about warnings, hazards, closures, 
and advisories for trail segments. | segment_warnings, warning_types_master, 
warning_severities_master, warning_source_types_master, 
workflow_statuses_master. | 2.1 | Master tables (warning_types_master v2.1, 
etc.) aligned to V2 patterns (id PK, code, display_name (translatable), 
is_active, audit columns by profiles.id, icons, sort order); segment_warnings 
table (v2.1) with segment_id (FK), warning_type_id (FK), is_currently_active 
(generated column), workflow_status_code (FK), and audit by auth.users.id; 
public_active_segment_warnings_view (v1.0) proposed for simplified public 
access to active warnings; orphan translation cleanup triggers. | | 6. User 
Interaction Module | Capturing user votes on waypoints, managing user-submitted 
tips with moderation, and defining standardized, translatable categories for 
tips. | user_waypoint_votes, user_waypoint_short_tips, tip_categories_master. | 
2.0 | tip_categories_master (v2.1) updated to V2 patterns (category_code PK, 
translatable default_name/description, is_active, audit); user_waypoint_votes 
(v2.1.1) with trigger update_waypoint_vote_counts to denormalize counts onto 
public.waypoints; user_waypoint_short_tips (v2.1.1) with is_publicly_visible 
generated column and detailed moderation fields; view_tip_categories_localized 
for API support. | | 7. Curated Itinerary Module | Defines, structures, 
categorizes, and manages the lifecycle of pre-defined pilgrimage itineraries 
and their associated lookup data. | curated_itineraries, 
curated_itinerary_segments, itinerary_categories_master, seasons_master, 
trail_difficulty_levels_master, content_statuses_master. | 2.1 | Promotion of 
ENUMs (difficulty, status, categories, seasons) to full master tables (v2.1) 
with V2 patterns (code, name (translatable), is_active, audit, icons, sort 
order); full V2 audit columns on all module tables; orphan translation cleanup 
triggers; curated_itineraries (v3.1) with content_status_id FK (NOT NULL); new 
junction tables curated_itinerary_to_category (v2.1) and 
curated_itinerary_to_season (v2.1); localized views 
(v_curated_itineraries_list_localized, etc.). _When this user inputs documents 
from other files, they are uploaded to a shared workspace. This means that the 
overview document is not accessible to this model. I will update the 
information using my knowledge and the module overview documents provided. 9. 🏗️ 
System Architecture Updates The V2.1 architecture reflects a mature, 
standardized approach to database design, consistently applied across modules: 
- Centralized Translation Model: The `public.translations` table is the 
definitive source for all translated text beyond the primary reference language 
(English). Entity tables now store English text directly in their primary 
descriptive columns (e.g., `trails.name`, `waypoints.description`, 
`warning_types_master.display_name`). API responses are designed to provide the 
base field (often resolved to English or requested language) and a 
corresponding `*_translations` object for other languages. - Standardized Media 
Linking: - Singular, critical semantic roles (e.g., 
`profiles.public_avatar_media_id`, `waypoints.primary_image_media_id`) often 
use direct Foreign Keys to `public.media.id`. - For galleries or multiple media 
associations, new `[entity_name]_media` linking tables are being introduced 
(e.g., `trail_media`, `segment_media`, `region_media`, `town_media`, 
`attraction_details_media`, `food_water_source_media`, `shop_service_media`, 
`article_media`). These linking tables include `media_role_code` (FK to 
`public.media_roles_master`), `display_order`, and translatable 
caption/alt-text overrides. - GPX files are now consistently managed via 
`media_id` Foreign Keys in `segments` and `routes` tables, pointing to the 
`public.media` table. - Enhanced Row-Level Security (RLS): - RLS policies are 
extensively used across all modules, with increasing standardization. - 
Reliance on helper functions like `public.has_role(TEXT)` or 
`public.has_role_on_profile(UUID, TEXT)` (checking `auth.uid()` against 
`public.profiles.roles` or JWT claims) is standard. - Synchronization of 
`public.profiles.roles` to `auth.users.raw_app_meta_data.roles` for JWT 
inclusion is a key feature of Module 1. - Data Integrity via Triggers: - 
Standard `updated_at` triggers are universally applied. - Orphaned translation 
cleanup `AFTER DELETE` triggers are mandated for all tables with translatable 
content. - Array Foreign Key integrity triggers (checking existence and 
`is_active` status of master records) are implemented for columns like 
`waypoints.waypoint_subcategory_tag_ids`, 
`events_details.event_theme_or_focus_tag_ids`, and 
`transport_stops_details.stop_facility_ids`. Similar "active check" triggers 
are implemented for non-array Foreign Keys to master tables. - Promotion of 
ENUMs to Master Tables: Many former ENUM types have been promoted to full 
`*_master` tables with `is_active` flags, audit columns, translatable labels, 
icons, and sort order (e.g., for waypoint categories, tags, content statuses, 
warning types, event types, transport types/facilities, itinerary categories, 
seasons, difficulty levels). 10. 📚 Data Governance & Cross‑Cutting Concerns - 
Translations & i18n: - A central `public.translations` table stores all 
translated content for fields designated as translatable across all modules. - 
Primary reference language (English) content is stored directly in the main 
table columns. - API responses generally include the base field (primary 
language or requested language) and a `*_translations` object for other 
available languages. - `AFTER DELETE` triggers on parent tables ensure orphaned 
translations are removed from `public.translations`. - Standard Audit Columns: 
- All relevant tables include `created_at`, `updated_at` (auto-triggered), 
`created_by_profile_id`, and `updated_by_profile_id`. - For `media`, 
`uploader_profile_id` serves as `created_by_profile_id`. - For 
`segment_warnings`, user audit links to `auth.users.id`. - Soft-Delete & 
Lifecycle Management: - Transactional/user data (e.g., `waypoints`, 
`events_details`, `articles`, `transport_stops_details`, `user_waypoint_votes`, 
`user_waypoint_short_tips`, `curated_itineraries` ) typically uses `deleted_at 
TIMESTAMPTZ NULL`. - Master/lookup data uniformly uses `is_active BOOLEAN NOT 
NULL DEFAULT true`. - Content status tables (e.g., `content_statuses_master`, 
`workflow_statuses_master` ) manage complex content lifecycles. - Media 
Handling Strategy: - A central `public.media` table stores metadata for 
original uploads and `image_variants_json` for derivatives. Backend processes 
generate variants. - Direct FKs for singular roles (e.g., avatar, primary 
image) and `[entity_name]_media` linking tables for galleries/multiple roles 
(with `media_role_code` FK to `public.media_roles_master`). - Access Control 
(RLS): - RLS is extensively applied using Supabase Auth, JWT claims (from 
`public.profiles.roles` ), and helper functions like `public.has_role(TEXT)`. 
11. 📈 Performance & Scalability Notes - Indexing: Comprehensive indexing 
strategies are defined per module, including: - PKs, FKs, and unique `code` 
columns on master tables are indexed. - GIST indexes for geospatial data 
(`segments.path_geom`, `waypoints.geom` ). - GIN indexes for array FKs (e.g., 
`waypoints.waypoint_subcategory_tag_ids`, 
`transport_stops_details.stop_facility_ids`, 
`events_details.event_theme_or_focus_tag_ids` ) and FTS (planned). - Composite 
indexes for filtering/sorting (e.g., on `is_active, sort_order` in master 
tables; `is_currently_active, workflow_status_code` in `segment_warnings` ). - 
Critical indexes on `public.translations` for lookup performance. - Views for 
API Performance: Localized views (e.g., `v_waypoint_categories_localized`, 
`v_towns_list_localized` ), summary views (e.g., 
`accommodations_capacity_summary_view` ), and enriched views (e.g., 
`view_transport_stops_enriched`, `public_active_segment_warnings_view`, 
`published_articles_view` ) are increasingly used to denormalize data, pre-join 
tables, and aggregate translations, simplifying API logic and optimizing read 
performance. - Database Functions for Complex GETs: Recommended for endpoints 
requiring significant aggregation and translation resolution (e.g., 
accommodation details, region/town details, article details ). - Partitioning 
Strategies: `segments`, `media`, and `translations` tables are noted as V2+ 
candidates for partitioning if data volumes grow excessively. 
`segment_warnings`, `events_details`, and `accommodation_reviews` are also 
potential candidates. - Caching: Application-level caching is recommended for 
frequently accessed, relatively static master data (e.g., `languages_master`, 
`user_roles_master`, and various `*_master` tables from Module 4, 5, 7). 
Materialized views are a future option for complex localized views if standard 
views face performance issues. 12. 🔐 Security & Compliance - Authentication & 
Authorization: Supabase Auth is the authentication provider, leveraging JWTs. 
Application-level roles stored in `public.profiles.roles` are synchronized to 
JWT custom claims for use in RLS policies. - Row-Level Security (RLS): 
Extensively applied across all tables in all modules, with policies tailored to 
roles (Public, Authenticated User, Owner, various Manager/Admin levels) and 
data status (e.g., `is_active`, `content_visibility_status`, `deleted_at` ). - 
RLS Helper Functions: Standardized SQL helper functions (e.g., 
`public.has_role(TEXT)`, `public.is_platform_admin()`, 
`public.user_manages_segment()` ) are crucial for implementing RLS policies. 
Secure implementation of `SECURITY DEFINER` functions is noted where necessary, 
with careful `search_path` management. - Data Integrity: Database-level 
constraints (`CHECK`, `FOREIGN KEY` with appropriate `ON DELETE` actions, `NOT 
NULL`), "active check" triggers for FKs to master tables, and array FK 
integrity triggers enhance data reliability. - Compliance: No specific new 
compliance requirements (e.g., HIPAA, GDPR beyond standard data protection) 
were noted in the V2.1 module updates. General principles of data minimization 
and purpose limitation should be followed. 13. 🛣️ Roadmap & Next Steps P0 
(Immediate Blockers/Highest Priority): - Global Auth & RLS Foundations: - 
Implement and rigorously test all core RLS helper functions 
(`public.has_role(TEXT)`, `public.has_role_on_profile(UUID, TEXT)`, 
`is_platform_admin()`, `user_manages_segment()`, etc.), ensuring their security 
and performance, especially for `SECURITY DEFINER` contexts. - Verify and test 
the `public.profiles.roles` to `auth.users.raw_app_meta_data.roles` 
synchronization mechanism. - Ensure `public.handle_new_user()` correctly 
initializes `profiles.roles` and `auth.users.raw_app_meta_data.roles`. - 
Translation Infrastructure: - Ensure the global 
`public.cleanup_related_translations()` function is robust for all PK types 
(TEXT, INTEGER, UUID) and correctly implemented as `AFTER DELETE` triggers on 
ALL translatable tables across ALL modules. - Array FK Integrity Triggers & 
Active Check FK Triggers: Implement and test all array FK integrity validation 
triggers (e.g., `check_waypoint_subcategory_tags`, 
`check_event_theme_tags_exist`, `check_transport_stop_facility_ids` ) and 
general "active check" FK triggers ensuring master records are active. P1 (Core 
V2.1 Implementation & Stabilization): - Module DDL Execution: Systematically 
deploy all finalized DDL (tables, views, functions, triggers, indexes) for each 
module according to their specified build orders and V2.1/latest versions. - 
Seed Data Population: Populate all `*_master` tables across all modules with 
agreed initial V2.1 data, including `icon_identifier`, `sort_order`, and 
correct audit column values (using a designated admin UUID). - RLS Policy 
Implementation & Testing: Apply and rigorously test all defined RLS policies 
for all tables and views across all modules with diverse user roles. - API 
Backend Logic & View Integration: - Develop/refine API backend logic to utilize 
the new/updated localized views and database functions for data retrieval. - 
Ensure consistent handling of the `lang` parameter and the API translation 
model (base field + `*_translations` object). - Finalize `waypoints` Vote Count 
Integration: Add `up_vote_count` and `down_vote_count` to `public.waypoints`; 
ensure `public.update_waypoint_vote_counts()` trigger is correct. - Slug & 
Default Status Logic: Implement for `curated_itineraries` and `articles`. - 
JSON Schema Definition: Formally define, document, and validate schemas for 
JSONB fields like `media.image_variants_json` and `opening_hours_structured`. 
P2 (Further Enhancements & Broader Scope): - Backend Media Variant Generation: 
Develop and deploy the backend process for `media.image_variants_json` 
population. - User Tip & Review Edit Policy/RLS: Finalize and implement for 
`user_waypoint_short_tips` and `accommodation_reviews`. - Data Migration from 
Old ENUMs (if applicable). - URL Validation Constraints: Implement DB-level 
`CHECK` constraints for all relevant URL fields. - Review and Standardize `ON 
DELETE` Actions: For all FKs across the database. - Consistent Lifecycle 
Management: Ensure consistent use of `is_active` / `deleted_at` / status fields 
across all tables. - Define Population Logic for Audit Fields: Ensure robust 
application/admin tool logic for setting `created_by_profile_id`, 
`updated_by_profile_id`, especially for `*_master` tables and system actions. - 
`profiles.last_activity_at` Update Mechanism: Define and implement. - Define 
clear conventions for `icon_identifier` usage and asset sources. - Plan and 
Implement Triggers for `media.last_linked_or_used_at`. - Full Specification of 
Waypoint Detail Extension Tables: Complete V2 review for `accommodations` 
(beyond v1.0 current spec), `attractions_details` (beyond v1.3.1), 
`food_water_sources_details` (beyond v1.3.1), etc. - Editorial Workflow for 
`data_last_verified_at`: (e.g., for transport stops, events ). 14. 📋 Appendix 
A -- Module Change Log - Overall Project (V2.0 to V2.1): Comprehensive update 
reflecting standardization to V2 patterns across all modules. Key themes 
include consistent audit columns, `is_active` flags for master data, refined 
`deleted_at` usage, centralized `public.translations` strategy with primary 
language in-table, enhanced media linking with roles, new localized/summary 
views for API optimization, and more robust RLS policies with standardized 
helper functions. Array FK and "active check" FK integrity triggers widely 
implemented. - Module 1: User & Content Infrastructure (to V2.3): Standardized 
audit columns (`created_by_profile_id`, `updated_by_profile_id`) and 
`icon_identifier` added to master tables. Adopted "English in main table, other 
languages in `public.translations`" model with clear API output structure. 
Added `profiles.last_activity_at`. Implemented role synchronization from 
`profiles.roles` to `auth.users.raw_app_meta_data.roles` for JWTs via triggers. 
- Module 2: Core Trail Hierarchy (to V2.2 API Aligned): GPX file management 
fully transitioned to `public.media` via `media_id` FKs. `segment_media` table 
enhanced with `media_role_code` and translatable `caption`/`alt_text`. 
Surrogate `id` PKs added to junction tables (`trail_regions`, 
`route_segments`). `terrain_types_master` and `usage_types_master` fully 
updated to V2 spec (`is_active`, full audit columns, translatable 
names/descriptions). All module tables now include full standard V2 audit 
columns. New localized views (`v_trails_detailed_localized`, 
`v_routes_detailed_localized`, `v_segments_detailed_localized`) introduced for 
API support. - Module 3: Geographical Context (to V2.2 API-Aware): Consistent 
V2 audit columns and lifecycle management (`is_active` for master tables & 
`provinces`; `deleted_at` and `content_visibility_status` for `regions` & 
`towns`). Master tables (`characteristic_tags_master`, `service_tags_master`, 
`town_types_master`) enhanced with `is_active`, audit columns, translatable 
names, icons. Array FK validation triggers (e.g., for 
`regions.characteristics_tags`) added. New `region_media` and `town_media` 
linking tables for galleries. Localized views (`v_towns_list_localized`, 
`v_regions_list_localized`) for API efficiency. - Module 4: Waypoint Detail 
Modules (General) (to V1.2): Finalized core tables `waypoints` (v1.3), 
`waypoint_categories_master` (v1.2), `tags_master` (v1.3), 
`content_statuses_master` (v1.2) to V2 patterns (standard audit columns, 
`is_active` for master data, `deleted_at` for `waypoints`, i18n support via 
`public.translations` ). Localized views (`v_waypoint_categories_localized`, 
`v_tags_localized`) introduced for efficient retrieval of translated master 
data. Array FK integrity trigger `trigger_check_waypoint_subcategory_tags` 
specified for `waypoints.waypoint_subcategory_tag_ids`. - Module 4a: Waypoint - 
Accommodations (to V1.0 - New Module): Introduced central `accommodations` 
table (v1.5); numerous specialized master tables (e.g., 
`accommodation_types_master` v1.4, `amenities_master` v1.5 ) aligned with V2 
patterns (audit, `is_active`, translatable labels/descriptions, icons, sort 
order); junction tables (e.g., `accommodation_amenities` v1.4 ) with 
translatable notes and audit columns; new `accommodation_reviews` table (v1.0) 
with moderation workflow; localized views (e.g., 
`v_accommodation_types_localized`) for all master tables; 
`accommodations_capacity_summary_view`; specific translation cleanup triggers 
per table. - Module 4b: Waypoint - Attractions, Food/Water, Shops/Services (to 
V1.1 - New Module): Introduced detail tables (`attractions_details` v1.3.1, 
`religious_service_schedules` v1.3.1, `food_water_sources_details` v1.3.1, 
`shops_and_services_details` v1.3.1 ) with translatable fields; numerous master 
tables (`attraction_types_master` v1.1, etc.) with V2 patterns (`is_active`, 
audit, translatable labels, icons, sort order); dedicated `*_media` linking 
tables (e.g., `attraction_details_media` v1.0 ) for galleries with roles and 
translatable overrides; localized views 
(`v_waypoint_attraction_details_localized` v1.0, etc.) for API data retrieval; 
"active check" triggers for all FKs to master tables; array FK integrity 
triggers; `shops_and_services_details.deleted_at` for independent soft delete. 
- Module 4c: Waypoint - Transportation (to V2.1 - New Module): Introduced 
master tables (`transport_stop_types_master` v2.1, 
`transport_stop_facilities_master` v2.1 ) with V2 patterns (`is_active`, full 
audit, translatable labels, icons, sort order). `transport_stops_details` table 
(v2.1) links to waypoints, includes translatable `operator_names_text` array, 
and `stop_facility_ids` array FK with validation trigger 
`check_transport_stop_facility_ids`. New `view_transport_stops_enriched` (v2.1) 
for API efficiency. Orphan translation cleanup triggers and standardized API 
translation model (primary lang field + `translations` object) implemented. 
`transport_stops_details.deleted_at` added for soft delete. - Module 4d: 
Waypoint - Events (to V1.1 - New Module): Introduced central `events_details` 
table (v1.3). Master tables (`event_types_master` v1.1, etc.) with V2 patterns 
(`code`, `default_name` (translatable), `is_active`, audit columns, sort order, 
icons). `event_theme_or_focus_tag_ids` array FK (to `tags_master.id`) with 
validation trigger (`trigger_validate_event_theme_tags`). Orphan translation 
cleanup triggers for all module tables. `events_details.deleted_at` for soft 
deletion. Full V2 audit columns on all module tables. Primary language content 
in direct fields, other languages in `public.translations`. - Module 5: Dynamic 
Conditions (to V2.1): Master tables (`warning_types_master` v2.1, etc.) aligned 
to V2 patterns (`id` PK, `code`, `display_name` (translatable), `is_active`, 
audit columns by `profiles.id`, icons, sort order). `segment_warnings` table 
(v2.1) with `segment_id` (FK), `warning_type_id` (FK), `is_currently_active` 
(generated column), `workflow_status_code` (FK), and audit by `auth.users.id`. 
`public_active_segment_warnings_view` (v1.0) proposed for simplified public 
access to active warnings. Orphan translation cleanup triggers. - Module 6: 
User Interaction (to V2.0): `tip_categories_master` (v2.1) updated to V2 
patterns (`category_code` PK, translatable `default_name`/`description`, 
`is_active`, audit). `user_waypoint_votes` (v2.1.1) with trigger 
`update_waypoint_vote_counts` to denormalize counts onto `public.waypoints`. 
`user_waypoint_short_tips` (v2.1.1) with `is_publicly_visible` generated column 
and detailed moderation fields. `view_tip_categories_localized` for API 
support. - Module 7: Curated Itinerary (to V2.1): Promotion of ENUMs 
(difficulty, status, categories, seasons) to full master tables (v2.1) with V2 
patterns (`code`, `name` (translatable), `is_active`, audit, icons, sort 
order). Full V2 audit columns on all module tables. Orphan translation cleanup 
triggers. `curated_itineraries` (v3.1) with `content_status_id` FK (NOT NULL). 
New junction tables `curated_itinerary_to_category` (v2.1) and 
`curated_itinerary_to_season` (v2.1). Localized views 
(`v_curated_itineraries_list_localized`, etc.). - Module 8: Platform Content 
(to V1.0 - New Module): New module. `articles` table (v1.0) for news/blog posts 
with translatable text, featured image, associations, audit columns, status, 
and soft delete (`deleted_at`). `media_roles_master` (v1.0) defines semantic 
roles for media within articles, with translatable names, `is_active` flag, and 
audit columns. `article_media` (v1.0) linking table connects articles to 
`public.media` items, assigning a role, display order, and allowing 
translatable caption/alt-text overrides, with audit columns. Views 
`published_articles_view` and `article_media_details_view` for denormalized 
access. Translation cleanup triggers on all module tables. 15. 📋 Appendix B -- 
Glossary / ENUM Registry - General Trend: Many former database `ENUM` types 
have been promoted to dedicated `*_master` lookup tables across modules (e.g., 
Waypoint Categories, Tags, Content Statuses, Warning Types, Event Types, 
Transportation Types/Facilities, Itinerary Categories, Seasons, Difficulty 
Levels ). These master tables typically include `id` (PK), `code` (unique text 
identifier), `label`/`name` (translatable, English primary), `description` 
(translatable, English primary, optional), `icon_identifier` (optional), 
`sort_order`, `is_active` (boolean for lifecycle), and full audit columns 
(`created_at`, `updated_at`, `created_by_profile_id`, `updated_by_profile_id`). 
- Key Remaining Global ENUMs (examples from modules): - 
`public.units_preference_enum` ('metric', 'imperial') - 
`public.pilgrim_experience_enum` ('novice_first_pilgrimage', ...) - 
`public.user_account_status_enum` ('active', 'suspended_by_admin', ...) - 
`public.media_asset_type_enum` ('image', 'gpx_file', ...) - 
`public.media_licence_enum` ('all_rights_reserved', 'cc_by', ...) - 
`public.media_status_enum` ('pending_review', 'published_approved', ...) - 
`public.trail_difficulty_enum` (used by Core Trail Hierarchy & Curated 
Itineraries - though Module 7 now uses `trail_difficulty_levels_master`) - 
`public.trail_operational_status_enum` - 
`public.content_visibility_status_enum` (used by multiple modules for main 
entities like trails, routes, segments, regions, towns, articles - though 
Module 7 now uses `content_statuses_master`) - `public.route_category_enum` 
('main_section', 'official_variant', ...) - `public.segment_sun_exposure_enum` 
('mostly_shaded', 'mostly_exposed', ...) - 
`public.segment_travel_direction_enum` ('bidirectional', 'northbound_only', 
...) - `public.weekday_enum` (used by religious service schedules, etc.) - 
`public.vote_type_enum` ('up', 'down') (used by user interactions, 
accommodation reviews) - `public.content_moderation_status_enum` 
('pending_approval', 'approved_visible', ...) (used by user interactions, 
accommodation reviews) - `is_active` (BOOLEAN): Standard lifecycle flag for 
master/lookup data. `TRUE` means the entry is current and can be referenced. 
`FALSE` means it's retired/historical. - `deleted_at` (TIMESTAMPTZ): Standard 
flag for soft-deleting transactional data. `NULL` means active. A timestamp 
indicates when it was soft-deleted. - `icon_identifier` (TEXT): A textual 
reference (e.g., CSS class name, SVG file name, material icon code) used by the 
frontend to display an appropriate icon. Introduced in many `*_master` tables. 
- Primary Language / Reference Language: English. Stored directly in entity 
table columns. - `code` (TEXT): A stable, machine-readable, unique identifier 
(often `snake_case`) used in master tables (e.g., 
`user_roles_master.role_code`, `warning_types_master.code`, 
`media_roles_master.role_code` ). Essential for system integrations and 
referencing specific master data entries programmatically. 
