

-- =======================================
-- CREATE NEW SUBSTANCES AND SUBSTANCE NAMES
-- ======================================

INSERT INTO schemes(NAME) SELECT 'simapro' WHERE NOT EXISTS(SELECT 1 FROM schemes WHERE schemes.NAME='simapro');

INSERT INTO schemes(NAME) SELECT 'recipe111' WHERE NOT EXISTS(SELECT 1 FROM schemes WHERE schemes.NAME='recipe111');

INSERT INTO schemes(NAME) SELECT 'ecoinvent31' WHERE NOT EXISTS(SELECT 1 FROM schemes WHERE schemes.NAME='ecoinvent31');


INSERT INTO labels (comp, subcomp, Name, cas, tag, unit ) SELECT DISTINCT comp, subcomp, recipeName, cas, tag, unit FROM raw_recipe UNION SELECT DISTINCT comp, subcomp, simaproName, cas, tag, unit FROM raw_recipe;
-- Populate compartment, subcompartment

INSERT INTO comp(compName) SELECT DISTINCT comp FROM labels where comp not in (select compName from comp);

INSERT INTO subcomp (subcompName) SELECT DISTINCT subcomp FROM labels WHERE subcomp IS NOT NULL and subcomp not in (select subcompname from subcomp) 
;


-- New substance for every new CAS 
INSERT INTO substances (cas, tag, unit) SELECT DISTINCT l.cas, l.tag, l.unit FROM labels l WHERE l.cas IS NOT NULL AND NOT EXISTS (SELECT 1 FROM substances s WHERE s.cas=l.cas AND (s.tag is l.tag ) and s.unit=l.unit);


-- New names with cas/tags assigned to their respective substance
INSERT INTO names (NAME, substid)
SELECT DISTINCT l.NAME, s.substid FROM labels l, substances s
WHERE l.NAME IS NOT NULL 
AND l.NAME NOT IN (SELECT n.NAME FROM names n)
AND s.cas = l.cas
AND (s.tag is l.tag )
and s.unit = l.unit;

-- This leaves us with all the names that have no cas. We group into synonyms and singles

INSERT INTO tempNamesWithoutCas(rawId, tag, name1, name2, unit)
SELECT * FROM (
	SELECT rawId, tag, recipeName, simaproName, unit FROM raw_recipe r
	WHERE r.cas IS null 
	ORDER BY recipeName, simaproName, tag, unit)
GROUP BY recipeName, simaproName, tag, unit;


INSERT INTO synonyms(rawId, tag, name1, name2, unit)
SELECT * FROM(
	SELECT rawId, tag, name1, name2, unit  FROM tempNamesWithoutCas
	WHERE name1 IS NOT NULL AND name2 IS NOT NULL
	ORDER BY name1, name2, tag, unit)
GROUP BY name1, name2, tag, unit;

INSERT INTO singles(rawId, NAME, tag, unit)
SELECT * FROM (
SELECT DISTINCT ON (t.name1) t.rawId, t.name1, t.tag, t.unit FROM tempNamesWithoutCAS t, synonyms sy
WHERE t.name1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM synonyms sy WHERE sy.NAME1=t.name1 OR sy.name2=t.name1)
ORDER BY t.name1, t.rawId, t.tag, t.unit) AS single1
UNION (
SELECT DISTINCT ON (t.name2) t.rawId, t.name2, t.tag, t.unit FROM tempNamesWithoutCAS t, synonyms sy
WHERE t.name2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM synonyms sy WHERE sy.NAME1=t.name2 OR sy.name2=t.name2)
ORDER BY t.name2, t.rawId, t.tag, t.unit); 

-- add all synonyms that can be matched to existing substances by virtue of their other name
INSERT INTO names (NAME, substId)
SELECT sy.name2, n.substId FROM synonyms sy, names n
WHERE sy.name1=n.name  AND (sy.name2 NOT IN (SELECT n.NAME FROM  names n))
UNION
SELECT sy.name1, n.substId FROM synonyms sy, names n
WHERE sy.name2=n.name AND sy.name1 NOT IN (SELECT n.NAME FROM names n)
;

-- create substance for each pair when none of the synonyms are found
INSERT INTO substances (rawId, tag, unit) 
SELECT DISTINCT sy.rawId, sy.tag, sy.unit FROM synonyms sy, names n
WHERE NOT EXISTS ( SELECT 1 FROM names n WHERE
			sy.name1 = n.NAME OR sy.name2 = n.NAME);

INSERT INTO names (substId, name)
SELECT s.substid, sy.name1 FROM substances s, synonyms sy
WHERE s.rawId = sy.rawId AND NOT EXISTS ( SELECT 1 FROM names n WHERE sy.name1 = n.NAME)
UNION
SELECT s.substid, sy.name2 FROM substances s, synonyms sy
WHERE s.rawId = sy.rawId AND NOT EXISTS ( SELECT 1 FROM names n WHERE sy.name2 = n.NAME);

-- create new substance for all unmatched single names--
INSERT INTO substances ( rawId, tag, unit) 
SELECT DISTINCT rawId, tag, unit FROM singles si, names n
WHERE si.NAME NOT IN (SELECT n.name FROM names n);

INSERT INTO names (substId, NAME) 
SELECT s.substId, si.NAME FROM substances s, singles si
WHERE s.rawId=si.rawId AND si.NAME NOT IN (SELECT n.NAME FROM names n);


--========================
-- REVERSE DOCUMENTATION
--=======================
-- add substId in raw_recipe (probably slow);
UPDATE raw_recipe AS r
SET substId = n.substId
FROM names n, names n2
WHERE (n.NAME=r.recipeName OR r.recipeName IS NULL) AND (n2.NAME=simaproName OR r.simaproName IS NULL) AND n.substId=n2.substid;

insert into nameHasScheme
select distinct n.nameId, s.schemeId from names n, schemes s
where n.name in (select simaproname from raw_recipe)
and s.name='simapro';

insert into nameHasScheme
select distinct n.nameId, s.schemeId from names n, schemes s
where n.name in (select recipename from raw_recipe)
and s.name='recipe108';


