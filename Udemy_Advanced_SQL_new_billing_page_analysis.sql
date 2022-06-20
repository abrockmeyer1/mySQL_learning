USE mavenfuzzyfactory;
/*SELECT MIN(created_at)
FROM website_pageviews
WHERE created_at < '2012-11-10'
AND pageview_url = '/billing-2'
created_at = '2012-09-10'
*/

CREATE TEMPORARY TABLE bill_land
SELECT MIN(website_pageview_id) as first_session,
website_session_id as session_id,
pageview_url as lander_pg
FROM website_pageviews
WHERE created_at < '2012-11-10'
AND created_at > '2012-09-10'
AND pageview_url IN ('/billing','/billing-2','/thank-you-for-your-order')
GROUP BY website_session_id;

CREATE TEMPORARY TABLE sessions_pv
SELECT first_session,
session_id,
lander_pg,
pageview_url
FROM bill_land
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = session_id
WHERE pageview_url IN ('/billing','/billing-2','/thank-you-for-your-order');
-- Testing Improvement of new billing page
SELECT 
	lander_pg,
    COUNT(DISTINCT session_id) as sessions,
    COUNT(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN session_id ELSE NULL END) as total_orders,
    COUNT(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN session_id ELSE NULL END)/COUNT(DISTINCT session_id) as billing_to_order_rt
FROM sessions_pv
GROUP BY lander_pg
    
    
    
    
    
    
    
    
    