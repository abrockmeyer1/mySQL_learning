USE mavenfuzzyfactory;
/*
	STEP 1: find first website_pageview_id for relevent sessions
    STEP 2: identify landing page of each sessions
    STEP 3: count pageviews for each session to identify "bounces"
    STEP 4: summarize by counting total sessions and bounced sessions
*/

-- Morgan wants to see bounce rates for traffic landing on homepage
-- answer should be Sessions, Bounced_sessions (count), and bounce rate

-- STEP 1: Creates temporary table with each website session's first pageview id
CREATE TEMPORARY TABLE first_pg
SELECT 
	website_session_id,
	MIN(website_pageview_id) as first_pv_session
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

-- STEP 2: Creates a temporary table correlating website session id to landing page
CREATE TEMPORARY TABLE entry_pg
SELECT 
	first_pg.website_session_id,
    website_pageviews.pageview_url
FROM first_pg
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pg.first_pv_session;

-- STEP 3: Identifies bounced sessions
CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
	entry_pg.website_session_id,
    entry_pg.pageview_url,
	COUNT(website_pageviews.website_pageview_id) as count_of_pv
FROM entry_pg
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = entry_pg.website_session_id
GROUP BY
	entry_pg.website_session_id,
    entry_pg.pageview_url
HAVING
	count_of_pv = 1;


-- STEP 4: Creating query to count number of sessions vs number of bounced sessions

SELECT
	COUNT(DISTINCT entry_pg.website_session_id) as sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) as bounced_sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id)/COUNT(DISTINCT entry_pg.website_session_id) as bounce_rt
FROM entry_pg
	LEFT JOIN bounced_sessions_only
		ON bounced_sessions_only.website_session_id = entry_pg.website_session_id
GROUP BY
	entry_pg.pageview_url;
