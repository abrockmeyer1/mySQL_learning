USE mavenfuzzyfactory;

USE mavenfuzzyfactory;
-- This was a project to analyze landing pages and drop rate

-- STEP 1 create table showing each session id with minimum website view to use as filter
-- STEP create table showing sessions with only first page by session id
-- STEP create table showing sessions with only one page view
-- FINAL STEP bounce rates by week (sessions only on one page/sessions landing on first page)
CREATE TEMPORARY TABLE first_pg_session
SELECT 
	MIN(website_pageview_id) as first_pg_id,
    MIN(website_pageviews.created_at) as created_at,
    website_pageviews.website_session_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
	website_pageviews.created_at > '2012-06-01' 
    AND website_pageviews.created_at < '2012-08-31'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	website_session_id;

CREATE TEMPORARY TABLE land_pg_session
SELECT first_pg_session.first_pg_id,
	first_pg_session.created_at,
	first_pg_session.website_session_id,
    website_pageviews.pageview_url as first_page_viewed
FROM first_pg_session
	LEFT JOIN website_pageviews
		ON first_pg_session.first_pg_id = website_pageviews.website_pageview_id;

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
	land_pg_session.website_session_id,
    MIN(land_pg_session.created_at),
	COUNT(website_pageviews.website_pageview_id) as num_pageviews,
    land_pg_session.first_page_viewed as only_page_viewed
FROM land_pg_session
	LEFT JOIN website_pageviews
		ON land_pg_session.website_session_id = website_pageviews.website_session_id
GROUP BY land_pg_session.website_session_id,
	land_pg_session.first_page_viewed
HAVING num_pageviews = 1;

SELECT
	MIN(DATE(land_pg_session.created_at)) as week_start_date,
    COUNT(bounced_sessions_only.only_page_viewed)/COUNT(land_pg_session.first_page_viewed) as bounce_rate,
    COUNT(CASE WHEN land_pg_session.first_page_viewed = '/home' THEN land_pg_session.website_session_id ELSE NULL END) as home_sessions,
    COUNT(CASE WHEN land_pg_session.first_page_viewed = '/lander-1' THEN land_pg_session.website_session_id ELSE NULL END) as lander_sessions
FROM land_pg_session
	LEFT JOIN bounced_sessions_only
		ON bounced_sessions_only.website_session_id = land_pg_session.website_session_id
WHERE land_pg_session.first_page_viewed != '/products'
GROUP BY WEEK(land_pg_session.created_at)
    



    
    
    
    