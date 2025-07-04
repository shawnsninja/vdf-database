-- =====================================================================================
-- VDF Database - Module 8: Editorial (Platform Content)
-- Migration: 006_test_module_8.sql
-- Description: Test script for Module 8 tables and functionality
-- Version: 1.0
-- =====================================================================================

-- Test runner
DO $$
DECLARE
    v_test_name TEXT;
    v_error_count INTEGER := 0;
    v_total_tests INTEGER := 0;
    v_test_author_id UUID;
    v_test_media_id UUID;
    v_test_article_id BIGINT;
    v_test_trail_id BIGINT;
    v_test_region_id BIGINT;
    v_test_town_id BIGINT;
BEGIN
    -- Initialize test
    RAISE NOTICE '=== Module 8: Editorial - Test Suite ===';
    RAISE NOTICE 'Starting at: %', clock_timestamp();

    -- Create test data
    -- Create test author
    INSERT INTO public.profiles (id, email, username, display_name, roles)
    VALUES 
        ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', 'test_author@example.com', 'test_author', 'Test Author', ARRAY['pilgrim', 'content_creator'])
    ON CONFLICT (id) DO NOTHING;
    
    v_test_author_id := 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a31';

    -- Create test media
    INSERT INTO public.media (id, storage_path, mime_type, file_size_bytes, width_pixels, height_pixels, alt_text, caption)
    VALUES 
        ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a41', 'articles/test-featured.jpg', 'image/jpeg', 102400, 1200, 800, 'Test featured image', 'A beautiful test image')
    ON CONFLICT (id) DO NOTHING;
    
    v_test_media_id := 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a41';

    -- Get test data from existing tables
    SELECT id INTO v_test_trail_id FROM public.trails WHERE deleted_at IS NULL LIMIT 1;
    SELECT id INTO v_test_region_id FROM public.regions WHERE deleted_at IS NULL LIMIT 1;
    SELECT id INTO v_test_town_id FROM public.towns WHERE deleted_at IS NULL LIMIT 1;

    -- -------------------------------------------------------------------------
    -- Test 1: Media Roles Master Seed Data
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 1: Media Roles Master Seed Data';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Check if media roles were seeded
        IF NOT EXISTS (
            SELECT 1 FROM public.media_roles_master 
            WHERE role_code = 'gallery_image'
        ) THEN
            RAISE EXCEPTION 'Media roles not properly seeded';
        END IF;

        -- Check translations
        IF NOT EXISTS (
            SELECT 1 FROM public.translations 
            WHERE table_identifier = 'media_roles_master' 
            AND row_foreign_key = 'featured_image' 
            AND language_code = 'it'
        ) THEN
            RAISE EXCEPTION 'Media role translations not found';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 2: Create Article
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 2: Create Article';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Insert a test article
        INSERT INTO public.articles (
            title, slug, body_content, excerpt,
            author_profile_id, article_status, featured_image_media_id,
            associated_trail_id, associated_region_id, associated_town_id,
            tags, created_by_profile_id
        )
        VALUES (
            'Test Article Title', 'test-article-title', 
            'This is the body content of the test article. It contains multiple paragraphs and detailed information.',
            'This is a short excerpt summarizing the article.',
            v_test_author_id, 'draft'::public.content_visibility_status_enum, v_test_media_id,
            v_test_trail_id, v_test_region_id, v_test_town_id,
            ARRAY['test', 'article', 'module8'], v_test_author_id
        )
        RETURNING id INTO v_test_article_id;

        -- Verify slug format
        IF NOT EXISTS (
            SELECT 1 FROM public.articles 
            WHERE id = v_test_article_id 
            AND slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
        ) THEN
            RAISE EXCEPTION 'Article slug format validation failed';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 3: Add Article Media
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 3: Add Article Media';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Add gallery images
        INSERT INTO public.article_media (
            article_id, media_id, media_role_code, display_order,
            caption_override, alt_text_override, created_by_profile_id
        )
        VALUES 
            (v_test_article_id, v_test_media_id, 'gallery_image', 1,
             'Custom caption for this context', 'Custom alt text', v_test_author_id);

        -- Try to add duplicate (should fail)
        BEGIN
            INSERT INTO public.article_media (
                article_id, media_id, media_role_code, display_order
            )
            VALUES 
                (v_test_article_id, v_test_media_id, 'gallery_image', 2);
            
            RAISE EXCEPTION 'Duplicate article-media link should have failed';
        EXCEPTION
            WHEN unique_violation THEN
                -- Expected - this is correct behavior
                NULL;
        END;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 4: Article Workflow
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 4: Article Workflow';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Update to pending review
        UPDATE public.articles 
        SET article_status = 'pending_review'::public.content_visibility_status_enum
        WHERE id = v_test_article_id;

        -- Publish the article
        UPDATE public.articles 
        SET 
            article_status = 'published'::public.content_visibility_status_enum,
            publication_date = now()
        WHERE id = v_test_article_id;

        -- Check if it appears in published view
        IF NOT EXISTS (
            SELECT 1 FROM public.view_published_articles
            WHERE id = v_test_article_id
        ) THEN
            RAISE EXCEPTION 'Published article not visible in view';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 5: Localized Views
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 5: Localized Views';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Add Italian translation for test article
        INSERT INTO public.translations (table_identifier, row_foreign_key, column_identifier, language_code, translated_text)
        VALUES 
            ('articles', v_test_article_id::text, 'title', 'it', 'Titolo Articolo di Prova'),
            ('articles', v_test_article_id::text, 'excerpt', 'it', 'Questo è un breve riassunto dell''articolo.')
        ON CONFLICT DO NOTHING;

        -- Set language to Italian
        PERFORM set_config('app.current_lang', 'it', true);
        
        -- Check if Italian translation is returned
        IF NOT EXISTS (
            SELECT 1 FROM public.view_article_detail 
            WHERE id = v_test_article_id 
            AND localized_title = 'Titolo Articolo di Prova'
        ) THEN
            RAISE EXCEPTION 'Italian translation not returned in localized view';
        END IF;

        -- Reset language
        PERFORM set_config('app.current_lang', 'en', true);

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Test 6: Soft Delete and Cleanup
    -- -------------------------------------------------------------------------
    v_test_name := 'Test 6: Soft Delete and Cleanup';
    v_total_tests := v_total_tests + 1;
    BEGIN
        -- Soft delete the article
        UPDATE public.articles 
        SET deleted_at = now()
        WHERE id = v_test_article_id;

        -- Check that it's not visible in published view
        IF EXISTS (
            SELECT 1 FROM public.view_published_articles
            WHERE id = v_test_article_id
        ) THEN
            RAISE EXCEPTION 'Soft deleted article should not be visible in published view';
        END IF;

        -- Hard delete to test translation cleanup
        DELETE FROM public.articles WHERE id = v_test_article_id;

        -- Check that translations were cleaned up
        IF EXISTS (
            SELECT 1 FROM public.translations 
            WHERE table_identifier = 'articles' 
            AND row_foreign_key = v_test_article_id::text
        ) THEN
            RAISE EXCEPTION 'Article translations not cleaned up after delete';
        END IF;

        RAISE NOTICE '✓ %', v_test_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '✗ % - Failed: %', v_test_name, SQLERRM;
            v_error_count := v_error_count + 1;
    END;

    -- -------------------------------------------------------------------------
    -- Cleanup
    -- -------------------------------------------------------------------------
    -- Delete test media
    DELETE FROM public.media WHERE id = v_test_media_id;
    
    -- Delete test translations
    DELETE FROM public.translations 
    WHERE (table_identifier = 'articles' AND row_foreign_key = v_test_article_id::text)
    OR (table_identifier = 'article_media' AND row_foreign_key IN (
        SELECT id::text FROM public.article_media WHERE article_id = v_test_article_id
    ));

    -- -------------------------------------------------------------------------
    -- Final Summary
    -- -------------------------------------------------------------------------
    RAISE NOTICE '=== Test Summary ===';
    RAISE NOTICE 'Total tests: %', v_total_tests;
    RAISE NOTICE 'Passed: %', v_total_tests - v_error_count;
    RAISE NOTICE 'Failed: %', v_error_count;
    
    IF v_error_count > 0 THEN
        RAISE EXCEPTION 'Module 8 tests failed with % errors', v_error_count;
    ELSE
        RAISE NOTICE 'All Module 8 tests passed successfully!';
    END IF;
END $$;