USE mavenfuzzyfactory;

-- This section of code translates the pages visited into a flagged table showing which pages were viewed by each session id
CREATE TEMPORARY TABLE flagged_pageviews
SELECT website_pageviews.website_session_id,
	MAX(CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE 0 END) as'to_lander',
    MAX(CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END) as'to_products',
    MAX(CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) as'to_fuzzy',
    MAX(CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END) as'to_cart',
    MAX(CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END) as'to_shipping',
    MAX(CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END) as'to_billing',
    MAX(CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) as'to_thank_you'
FROM website_pageviews
LEFT JOIN website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at < '2012-09-05' 
AND website_pageviews.created_at > '2012-08-05'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND website_pageviews.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy', '/cart','/shipping', '/billing','/thank-you-for-your-order')
GROUP BY website_pageviews.website_session_id;

-- This table contains the total amount of pageviews for each page
SELECT
	COUNT(DISTINCT CASE WHEN to_lander = 1 THEN website_session_id ELSE NULL END) as sessions,
    COUNT(DISTINCT CASE WHEN to_products = 1 THEN website_session_id ELSE NULL END) as product_clicks,
    COUNT(DISTINCT CASE WHEN to_fuzzy = 1 THEN website_session_id ELSE NULL END) as fuzzy_clicks,
    COUNT(DISTINCT CASE WHEN to_cart = 1 THEN website_session_id ELSE NULL END) as cart_clicks,
    COUNT(DISTINCT CASE WHEN to_shipping = 1 THEN website_session_id ELSE NULL END) as shipping_clicks,
    COUNT(DISTINCT CASE WHEN to_billing = 1 THEN website_session_id ELSE NULL END) as billing_clicks,
    COUNT(DISTINCT CASE WHEN to_thank_you = 1 THEN website_session_id ELSE NULL END) as thankyou_clicks
FROM flagged_pageviews;

-- This table contains the click through rate of each page
SELECT
	COUNT(DISTINCT CASE WHEN to_products = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) as lander_click_rt,
    COUNT(DISTINCT CASE WHEN to_fuzzy = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) as product_click_rt,
    COUNT(DISTINCT CASE WHEN to_cart = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) as fuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN to_shipping = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) as cart_click_rt,
    COUNT(DISTINCT CASE WHEN to_billing = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) as shipping_click_rt,
    COUNT(DISTINCT CASE WHEN to_thank_you = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) as billing_click_rt
FROM flagged_pageviews;

