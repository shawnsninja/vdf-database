-- Module 4: Waypoint Details
-- 009_waypoints_rls_policies.sql: Row Level Security policies for waypoints
-- 
-- Purpose: Define access control policies for the waypoints table

-- Public read access to published, non-deleted waypoints
CREATE POLICY "Allow public read access to published waypoints" ON public.waypoints
    FOR SELECT
    USING (
        content_visibility_status_id IN (
            SELECT id FROM public.content_statuses_master 
            WHERE is_publicly_visible = true AND is_active = true
        ) 
        AND deleted_at IS NULL
    );

-- Authenticated users can read all non-deleted waypoints
CREATE POLICY "Allow authenticated users read access to non-deleted waypoints" ON public.waypoints
    FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND deleted_at IS NULL
    );

-- Content creators can insert waypoints
CREATE POLICY "Allow content creators to insert waypoints" ON public.waypoints
    FOR INSERT
    WITH CHECK (
        auth.role() = 'authenticated'
        AND (
            public.has_role('content_creator') OR
            public.has_role('regional_content_manager') OR
            public.has_role('admin') OR
            public.has_role('platform_admin')
        )
    );

-- Users can update waypoints they created (if they have content creator role)
CREATE POLICY "Allow content creators to update their own waypoints" ON public.waypoints
    FOR UPDATE
    USING (
        auth.role() = 'authenticated'
        AND created_by_profile_id = auth.uid()
        AND (
            public.has_role('content_creator') OR
            public.has_role('regional_content_manager') OR
            public.has_role('admin') OR
            public.has_role('platform_admin')
        )
    )
    WITH CHECK (
        auth.role() = 'authenticated'
        AND (
            public.has_role('content_creator') OR
            public.has_role('regional_content_manager') OR
            public.has_role('admin') OR
            public.has_role('platform_admin')
        )
    );

-- Regional content managers can update waypoints in their regions
-- Note: This would require a function to check regional permissions
-- For now, we'll allow all regional content managers to update
CREATE POLICY "Allow regional content managers to update waypoints" ON public.waypoints
    FOR UPDATE
    USING (
        auth.role() = 'authenticated'
        AND public.has_role('regional_content_manager')
    )
    WITH CHECK (
        auth.role() = 'authenticated'
        AND public.has_role('regional_content_manager')
    );

-- Admins can perform all operations
CREATE POLICY "Allow admins full access to waypoints" ON public.waypoints
    FOR ALL
    USING (
        auth.role() = 'authenticated'
        AND (
            public.has_role('admin') OR
            public.has_role('platform_admin')
        )
    )
    WITH CHECK (
        auth.role() = 'authenticated'
        AND (
            public.has_role('admin') OR
            public.has_role('platform_admin')
        )
    );

-- Platform admins can delete waypoints (soft delete via updated_at)
CREATE POLICY "Allow platform admins to delete waypoints" ON public.waypoints
    FOR UPDATE
    USING (
        auth.role() = 'authenticated'
        AND public.has_role('platform_admin')
    )
    WITH CHECK (
        auth.role() = 'authenticated'
        AND public.has_role('platform_admin')
    );

-- Service role can perform all operations (for system maintenance)
CREATE POLICY "Allow service role full access to waypoints" ON public.waypoints
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');