-- Module 4b: Attractions
-- 007_additional_master_seed.sql: Seed data for additional master tables
-- 
-- Purpose: Insert standard master data for price ranges, meal types, dietary options, and payment methods

-- Insert establishment price ranges
INSERT INTO public.establishment_price_ranges_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    min_price_eur,
    max_price_eur,
    sort_order
) VALUES 
    ('budget', 'Budget', 'Budget-friendly establishments with low prices.', 'dollar-sign', 0.00, 15.00, 10),
    ('moderate', 'Moderate', 'Mid-range establishments with reasonable prices.', 'credit-card', 15.01, 35.00, 20),
    ('expensive', 'Expensive', 'High-end establishments with premium pricing.', 'gem', 35.01, 75.00, 30),
    ('luxury', 'Luxury', 'Luxury establishments with top-tier pricing.', 'crown', 75.01, NULL, 40),
    ('free', 'Free', 'No cost or donation-based establishments.', 'gift', 0.00, 0.00, 5),
    ('varies', 'Price Varies', 'Pricing varies significantly by item or service.', 'shuffle', NULL, NULL, 50)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    min_price_eur = EXCLUDED.min_price_eur,
    max_price_eur = EXCLUDED.max_price_eur,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert meal type tags
INSERT INTO public.meal_type_tags_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    sort_order
) VALUES 
    ('breakfast', 'Breakfast', 'Morning meal service.', 'sunrise', 10),
    ('lunch', 'Lunch', 'Midday meal service.', 'sun', 20),
    ('dinner', 'Dinner', 'Evening meal service.', 'moon', 30),
    ('brunch', 'Brunch', 'Late morning combination of breakfast and lunch.', 'clock', 15),
    ('snacks', 'Snacks', 'Light snacks and quick bites.', 'cookie', 40),
    ('coffee_tea', 'Coffee & Tea', 'Hot beverages and light refreshments.', 'coffee', 50),
    ('aperitivo', 'Aperitivo', 'Italian pre-dinner drinks and appetizers.', 'wine', 25),
    ('full_menu', 'Full Menu', 'Complete menu available throughout operating hours.', 'utensils', 5),
    ('buffet', 'Buffet', 'Self-service buffet style dining.', 'table', 35),
    ('takeaway', 'Takeaway', 'Food available for takeout/to-go.', 'shopping-bag', 45),
    ('picnic_packs', 'Picnic Packs', 'Pre-prepared meals for outdoor dining.', 'map', 55),
    ('pilgrim_menu', 'Pilgrim Menu', 'Special menu offerings for pilgrims.', 'route', 60)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert dietary option tags
INSERT INTO public.dietary_option_tags_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    sort_order
) VALUES 
    ('vegetarian', 'Vegetarian', 'Vegetarian options available (no meat).', 'leaf', 10),
    ('vegan', 'Vegan', 'Vegan options available (no animal products).', 'seedling', 20),
    ('gluten_free', 'Gluten-Free', 'Gluten-free options available.', 'wheat-off', 30),
    ('dairy_free', 'Dairy-Free', 'Dairy-free options available.', 'milk-off', 40),
    ('halal', 'Halal', 'Halal-certified food available.', 'crescent-moon', 50),
    ('kosher', 'Kosher', 'Kosher-certified food available.', 'star-of-david', 60),
    ('organic', 'Organic', 'Organic food options available.', 'eco', 70),
    ('local_sourced', 'Locally Sourced', 'Locally sourced ingredients used.', 'map-pin', 80),
    ('low_sodium', 'Low Sodium', 'Low sodium or salt-free options.', 'heart', 90),
    ('sugar_free', 'Sugar-Free', 'Sugar-free or diabetic-friendly options.', 'candy-off', 100),
    ('raw_food', 'Raw Food', 'Raw food options available.', 'apple', 110),
    ('paleo', 'Paleo', 'Paleo diet options available.', 'bone', 120),
    ('keto', 'Keto', 'Ketogenic diet options available.', 'zap', 130),
    ('mediterranean', 'Mediterranean', 'Mediterranean diet options.', 'sun', 140),
    ('child_friendly', 'Child-Friendly', 'Kid-friendly meal options available.', 'baby', 150)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Insert payment methods
INSERT INTO public.payment_methods_master (
    code, 
    label, 
    description, 
    icon_identifier, 
    is_electronic,
    sort_order
) VALUES 
    ('cash_eur', 'Cash (EUR)', 'Euro currency cash payments.', 'banknote', false, 10),
    ('cash_usd', 'Cash (USD)', 'US Dollar cash payments.', 'dollar-sign', false, 15),
    ('credit_card', 'Credit Card', 'Major credit cards (Visa, MasterCard, etc.).', 'credit-card', true, 20),
    ('debit_card', 'Debit Card', 'Debit card payments.', 'card', true, 25),
    ('maestro', 'Maestro', 'Maestro debit card payments.', 'credit-card', true, 30),
    ('american_express', 'American Express', 'American Express credit card.', 'credit-card', true, 35),
    ('contactless', 'Contactless', 'Contactless card or device payments.', 'radio', true, 40),
    ('paypal', 'PayPal', 'PayPal digital payments.', 'paypal', true, 50),
    ('apple_pay', 'Apple Pay', 'Apple Pay mobile payments.', 'smartphone', true, 60),
    ('google_pay', 'Google Pay', 'Google Pay mobile payments.', 'smartphone', true, 65),
    ('samsung_pay', 'Samsung Pay', 'Samsung Pay mobile payments.', 'smartphone', true, 70),
    ('bank_transfer', 'Bank Transfer', 'Direct bank transfer payments.', 'bank', true, 80),
    ('bitcoin', 'Bitcoin', 'Bitcoin cryptocurrency payments.', 'bitcoin', true, 90),
    ('travelers_check', 'Travelers Check', 'Travelers check payments.', 'check', false, 95),
    ('gift_card', 'Gift Card', 'Gift cards or vouchers.', 'gift-card', true, 100),
    ('loyalty_points', 'Loyalty Points', 'Loyalty program points or rewards.', 'star', true, 110),
    ('donation_based', 'Donation Based', 'Pay what you can or donation-based.', 'heart', false, 5)
ON CONFLICT (code) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    icon_identifier = EXCLUDED.icon_identifier,
    is_electronic = EXCLUDED.is_electronic,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- Verify all seed data insertion
DO $$
DECLARE
    price_ranges_count INTEGER;
    meal_types_count INTEGER;
    dietary_options_count INTEGER;
    payment_methods_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO price_ranges_count FROM public.establishment_price_ranges_master;
    SELECT COUNT(*) INTO meal_types_count FROM public.meal_type_tags_master;
    SELECT COUNT(*) INTO dietary_options_count FROM public.dietary_option_tags_master;
    SELECT COUNT(*) INTO payment_methods_count FROM public.payment_methods_master;
    
    RAISE NOTICE 'Additional seed data inserted successfully:';
    RAISE NOTICE '- Price Ranges: %', price_ranges_count;
    RAISE NOTICE '- Meal Types: %', meal_types_count;
    RAISE NOTICE '- Dietary Options: %', dietary_options_count;
    RAISE NOTICE '- Payment Methods: %', payment_methods_count;
    
    ASSERT price_ranges_count >= 6, 'Should have at least 6 price ranges';
    ASSERT meal_types_count >= 12, 'Should have at least 12 meal types';
    ASSERT dietary_options_count >= 15, 'Should have at least 15 dietary options';
    ASSERT payment_methods_count >= 17, 'Should have at least 17 payment methods';
END $$;