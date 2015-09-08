

-- =======================================
-- CREATE NEW SUBSTANCES AND SUBSTANCE NAMES
-- ======================================

-- 2.1 : Add schemes
INSERT INTO schemes(NAME) SELECT 'simapro' WHERE NOT EXISTS(SELECT 1 FROM schemes WHERE schemes.NAME='simapro');

INSERT INTO schemes(NAME) SELECT 'recipe111' WHERE NOT EXISTS(SELECT 1 FROM schemes WHERE schemes.NAME='recipe111');


-- -- 2.1*: single name column regardless of scheme
-- -- todo: useful?
-- INSERT INTO labels (comp, subcomp, Name, cas, tag, unit )
-- SELECT DISTINCT comp, subcomp, recipeName, cas, tag, unit FROM raw_recipe UNION SELECT DISTINCT comp, subcomp, simaproName, cas, tag, unit FROM raw_recipe;


-- todo: Already done in step 1?
-- Populate compartment, subcompartment
-- INSERT INTO comp(compName) SELECT DISTINCT comp FROM labels where comp not in (select compName from comp);

-- INSERT INTO subcomp (subcompName) SELECT DISTINCT subcomp FROM labels WHERE subcomp IS NOT NULL and subcomp not in (select subcompname from subcomp);


-- 2.2 New substance for every new CAS + tag
	-- this will automatically ignore any redundant cas-tag-unit combination
INSERT OR ignore INTO substances (aName, cas, tag, unit)
SELECT DISTINCT r.recipeName, r.cas, r.tag, r.unit FROM raw_recipe r
WHERE r.cas IS NOT NULL AND r.recipeName IS NOT NULL
UNION
SELECT DISTINCT r.simaproName, r.cas, r.tag, r.unit FROM raw_recipe r
WHERE r.cas IS NOT NULL AND r.recipeName IS NULL
;


-- 2.4: backfill labels with substid based on CAS-tag-unit
UPDATE raw_recipe
SET substid=(
	SELECT s.substid
	FROM substances as s
	WHERE raw_recipe.cas=s.cas
	AND raw_recipe.tag IS s.tag
	AND raw_recipe.unit=s.unit
	)
WHERE raw_recipe.substid IS NULL
;

-- 2.5: Create new substances for the remaining flows
INSERT INTO substances(aName, cas, tag, unit)
SELECT DISTINCT recipeName, cas, tag, unit
FROM raw_recipe r WHERE r.substid IS NULL AND r.recipeName IS NOT NULL
UNION
SELECT DISTINCT simaproName, cas, tag, unit
FROM raw_recipe r WHERE r.substid IS NULL AND r.recipeName IS NULL
;

-- 2.6: backfill labels with substid based on name-tag-unit
UPDATE raw_recipe
SET substid=(
	SELECT s.substid
	FROM substances s
	WHERE (raw_recipe.recipeName=s.aName OR raw_recipe.simaproName=s.aName)
	AND raw_recipe.tag IS s.tag
	AND raw_recipe.unit=s.unit
	)
WHERE substid IS NULL
;


-- 2.7 Register substid-name pairs
INSERT OR IGNORE INTO names (name, substid)
SELECT DISTINCT r.recipeName, r.substid FROM raw_recipe r
UNION
SELECT DISTINCT r.simaproName, r.substid FROM raw_recipe r
;


	-- -- -- This leaves us with all the names that have no cas. We group into synonyms and singles
	-- -- 
	-- -- INSERT INTO tempNamesWithoutCas(rawId, tag, name1, name2, unit)
	-- -- SELECT * FROM (
	-- -- 	SELECT rawId, tag, recipeName, simaproName, unit FROM raw_recipe r
	-- -- 	WHERE r.cas IS null 
	-- -- 	ORDER BY recipeName, simaproName, tag, unit)
	-- -- GROUP BY recipeName, simaproName, tag, unit;
	-- -- 
	-- -- 
	-- -- INSERT INTO synonyms(rawId, tag, name1, name2, unit)
	-- -- SELECT * FROM(
	-- -- 	SELECT rawId, tag, name1, name2, unit  FROM tempNamesWithoutCas
	-- -- 	WHERE name1 IS NOT NULL AND name2 IS NOT NULL
	-- -- 	ORDER BY name1, name2, tag, unit)
	-- -- GROUP BY name1, name2, tag, unit;
	-- -- 
	-- -- INSERT INTO singles(name, tag, unit)
	-- -- SELECT * FROM (
	-- -- SELECT DISTINCT t.name1, t.tag, t.unit FROM tempNamesWithoutCAS t, synonyms sy
	-- -- WHERE t.name1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM synonyms sy WHERE sy.NAME1=t.name1 OR sy.name2=t.name1)
	-- -- UNION 
	-- -- SELECT DISTINCT t.name2, t.tag, t.unit FROM tempNamesWithoutCAS t, synonyms sy
	-- -- WHERE t.name2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM synonyms sy WHERE sy.NAME1=t.name2 OR sy.name2=t.name2)
	-- -- ); 
	-- -- 
	-- add all synonyms that can be matched to existing substances by virtue of their other name



-- INSERT INTO names (NAME, substId)
-- SELECT sy.name2, n.substId FROM synonyms sy, names n
-- WHERE sy.name1=n.name  AND (sy.name2 NOT IN (SELECT n.NAME FROM  names n))
-- UNION
-- SELECT sy.name1, n.substId FROM synonyms sy, names n
-- WHERE sy.name2=n.name AND sy.name1 NOT IN (SELECT n.NAME FROM names n)
-- ;
-- 
-- -- create substance for each pair when none of the synonyms are found
-- INSERT INTO substances (aName, tag, unit) 
-- SELECT DISTINCT sy.name1, sy.tag, sy.unit FROM synonyms sy, names n
-- WHERE NOT EXISTS ( SELECT 1 FROM names n WHERE
-- 			sy.name1 = n.NAME OR sy.name2 = n.NAME);
-- 
-- INSERT INTO names (substId, name)
-- SELECT s.substid, sy.name1 FROM substances s, synonyms sy
-- WHERE s.aName = sy.name1 AND NOT EXISTS ( SELECT 1 FROM names n WHERE sy.name1 = n.NAME)
-- UNION
-- SELECT s.substid, sy.name2 FROM substances s, synonyms sy
-- WHERE s.aName = sy.name1 AND NOT EXISTS ( SELECT 1 FROM names n WHERE sy.name2 = n.NAME);
-- 
-- -- create new substance for all unmatched single names--
-- INSERT INTO substances ( aName, tag, unit) 
-- SELECT DISTINCT si.name, si.tag, si.unit FROM singles si, names n
-- WHERE si.name NOT IN (SELECT n.name FROM names n);
-- 
-- INSERT INTO names (substId, NAME) 
-- SELECT s.substId, si.NAME FROM substances s, singles si
-- WHERE s.aName=si.name AND si.name NOT IN (SELECT n.NAME FROM names n);
-- 

--========================
-- REVERSE DOCUMENTATION
--=======================

-- UPDATE raw_recipe
-- SET substId = (SELECT n.substId
-- 	       FROM names n, names n2
--                WHERE (n.NAME=raw_recipe.recipeName OR raw_recipe.recipeName IS NULL)
--          		AND (n2.NAME=simaproName OR raw_recipe.simaproName IS NULL)
-- 		       	AND n.substId=n2.substid);
-- 

-- 2.8 : associate name with scheme
insert into nameHasScheme
select distinct n.nameId, s.schemeId from names n, schemes s
where n.name in (select simaproname from raw_recipe)
and s.name='simapro';

insert into nameHasScheme
select distinct n.nameId, s.schemeId from names n, schemes s
where n.name in (select recipename from raw_recipe)
and s.name='recipe111';

