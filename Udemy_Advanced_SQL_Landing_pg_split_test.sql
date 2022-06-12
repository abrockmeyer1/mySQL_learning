USE mavenfuzzyfactory;
-- This was a project to analyze landing pages and drop rate
/*SELECT MIN(created_at)
FROM website_pageviews
WHERE pageview_url = '/lander-1'

-- '2012-06-19' is when 'lander-1' was created*/

-- STEP 1 create table showing each session id with minimum website view to use as filter
-- STEP create table showing sessions with only first page by session id
-- STEP create table showing sessions with only one page view
-- FINAL STEP bounce rates (sessions only on one page/sessions landing on first page)
CREATE TEMPORARY TABLE first_pg_session
SELECT 
	MIN(website_pageview_id) as first_pg_id,
    website_pageviews.website_session_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
	website_pageviews.created_at > '2012-06-19' 
    AND website_pageviews.created_at < '2012-07-28'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	website_session_id;

CREATE TEMPORARY TABLE land_pg_session
SELECT first_pg_session.first_pg_id,	
	first_pg_session.website_session_id,
    website_pageviews.pageview_url as first_page_viewed
FROM first_pg_session
	LEFT JOIN website_pageviews
		ON first_pg_session.first_pg_id = website_pageviews.website_pageview_id;

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
	land_pg_session.website_session_id,
	COUNT(website_pageviews.website_pageview_id) as num_pageviews,
    land_pg_session.first_page_viewed as only_page_viewed
FROM land_pg_session
	LEFT JOIN website_pageviews
		ON land_pg_session.website_session_id = website_pageviews.website_session_id
GROUP BY land_pg_session.website_session_id,
	land_pg_session.first_page_viewed
HAVING num_pageviews = 1;

SELECT
	land_pg_session.first_page_viewed,
    COUNT(land_pg_session.first_page_viewed) as sessions,
    COUNT(bounced_sessions_only.only_page_viewed) as bounced_sessions,
    COUNT(bounced_sessions_only.only_page_viewed)/COUNT(land_pg_session.first_page_viewed) as bounce_rate
FROM land_pg_session
	LEFT JOIN bounced_sessions_only
		ON bounced_sessions_only.website_session_id = land_pg_session.website_session_id
WHERE land_pg_session.first_page_viewed != '/products'
GROUP BY land_pg_session.first_page_viewed
ORDER BY bounce_rate DESC
    



    
    
    
    
    
    
    
    
    
    
    
    
    
    
