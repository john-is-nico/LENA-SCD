-- Step 1: Close old records that changed
UPDATE customers
SET valid_to = '{today}', is_current = 0
WHERE customer_id IN (SELECT customer_id FROM staging)
AND is_current = 1
AND EXISTS (
    SELECT 1 FROM staging s
    WHERE s.customer_id = customers.customer_id
    AND s.city <> customers.city
);

-- Step 2: Insert new versions for changed customers
SELECT s.customer_id, s.name, s.city, '{today}' as valid_from, NULL as valid_to, 1 as is_current
FROM staging s
JOIN customers c ON c.customer_id = s.customer_id
WHERE c.is_current = 0
AND NOT EXISTS (
    SELECT 1 FROM customers cc
    WHERE cc.customer_id = s.customer_id AND cc.is_current = 1 AND cc.city = s.city
);

-- Step 3: Insert brand new customers
SELECT s.customer_id, s.name, s.city, '{today}' as valid_from, NULL as valid_to, 1 as is_current
FROM staging s
WHERE NOT EXISTS (
    SELECT 1 FROM customers c
    WHERE c.customer_id = s.customer_id
);
