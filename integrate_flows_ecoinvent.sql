-- ======================================
-- ECOINVENT SUBSTANCES
-- ======================================

-- 2.1 Add Schemes

INSERT INTO schemes(NAME) SELECT 'ecoinvent31' WHERE NOT EXISTS(SELECT 1 FROM schemes WHERE schemes.NAME='ecoinvent31');

-- 2.2 A new substance for each new cas+tag
	-- this will automatically ignore any redundant cas-tag-unit combination
insert OR ignore  into substances(aName, cas, tag, unit)
select distinct l.name, l.cas, l.tag, l.unit from labels_ecoinvent AS l
WHERE l.cas is not null AND l.NAME IS NOT NULL
UNION
select distinct l.name2, l.cas, l.tag, l.unit from labels_ecoinvent AS l
WHERE l.cas is not null AND l.name IS NULL
;

-- 2.4: backfill labels with substid based on CAS-tag-unit
UPDATE OR ignore labels_ecoinvent
SET substid=(
	SELECT s.substid
	FROM substances as s
	WHERE labels_ecoinvent.cas=s.cas
	AND labels_ecoinvent.tag IS s.tag
	AND labels_ecoinvent.unit=s.unit
	)
WHERE labels_ecoinvent.substid IS NULL
;


-- 2.5: Create new substances for the remaining flows
INSERT OR ignore INTO substances(aName, cas, tag, unit)
SELECT DISTINCT name, cas, tag, unit
FROM labels_ecoinvent l WHERE l.substid IS NULL AND l.name IS NOT NULL
UNION
SELECT DISTINCT name2, cas, tag, unit
FROM labels_ecoinvent l WHERE l.substid IS NULL AND l.name IS NULL
;

-- 2.6: backfill labels with substid based on name-tag-unit
UPDATE labels_ecoinvent
SET substid=(
	SELECT s.substid
	FROM substances s
	WHERE (labels_ecoinvent.name=s.aName OR labels_ecoinvent.name2=s.aName)
	AND labels_ecoinvent.tag IS s.tag
	AND labels_ecoinvent.unit=s.unit
	)
WHERE substid IS NULL
;

-- 2.7 Register substid-name pairs
INSERT OR IGNORE INTO names (NAME, substid)
SELECT DISTINCT l.name, l.substid FROM labels_ecoinvent l
UNION
SELECT DISTINCT l.name2, l.substid FROM labels_ecoinvent l
;

insert into nameHasScheme
select distinct n.nameId, s.schemeId from names n, schemes s
where n.name in (select distinct name from labels_ecoinvent)
and s.name='ecoinvent31';
-- -- 
-- -- 
-- 
-- -- -- match recipe and ecoinvent substances  temporary table, substid of each dsid
-- 
-- -- SELECT 'match ecoinvent flow and substances' AS message;
-- insert into dsid_substid 
-- select distinct l.ecorawId, s.substid
-- from substances AS s, labels_ecoinvent as l, names AS n
-- where l.name=n.name and n.substid=s.substid
-- and l.unit=s.unit
-- and not exists (select 1 from dsid_substid ds where ds.dsid=l.dsid)
-- ;
-- -- 
-- -- insert into dsid_substid 
-- -- select distinct l.dsid, s.substid
-- -- from substances s, labels_ecoinvent as l
-- -- where l.cas=s.cas and l.tag is not distinct from s.tag
-- -- and l.unit=s.unit
-- -- and not exists (select 1 from dsid_substid ds where ds.dsid=l.dsid)
-- -- ;

