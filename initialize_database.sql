-- ==================================================
-- TEMPORARY TABLES TO FACILITATE INPUT OF DATA
-- ==================================================

DROP table if exists raw_char;

CREATE TABLE raw_char(
id           INTEGER NOT NULL PRIMARY KEY,
comp         TEXT,
subcomp      TEXT,
name         TEXT,
name2        TEXT,
cas          TEXT    CHECK (cas NOT LIKE '0%'),
tag          TEXT    NOT NULL DEFAULT '',
unit         TEXT,
impactId     TEXT,
factorValue  REAL,
substId      INTEGER,
UNIQUE(comp, subcomp, name, name2, tag, cas, unit, impactId),
CONSTRAINT hasAName CHECK(name IS NOT NULL OR name2 IS NOT NULL)
);

DROP TABLE IF EXISTS raw_inventory;
CREATE TABLE raw_inventory(
id    SERIAL  NOT NULL PRIMARY KEY,
substId     INTEGER,
name        TEXT    ,
name2       TEXT    ,
tag         TEXT    DEFAULT NULL DEFAULT '',
comp        TEXT    NOT NULL,
subcomp     TEXT    ,
unit        TEXT    ,
cas         text    CHECK (cas NOT LIKE '0%'),
CONSTRAINT hasAName CHECK(NAME IS NOT NULL OR name2 IS NOT NULL)
);


--=================================================
-- KEY TABLES
--=================================================

DROP TABLE IF EXISTS substances;
CREATE TABLE substances(
substId     INTEGER NOT NULL PRIMARY KEY,
formula     TEXT,
cas         text    CHECK (cas NOT LIKE '0%'),
tag         TEXT    DEFAULT NULL,
aName       text,
CONSTRAINT uniqueSubstanceCas UNIQUE(cas, tag),
	-- ensure no cas conflict
CONSTRAINT namePerSubstance UNIQUE(aName, tag)
	-- though mostly for readability, aName still used in matching
	-- ensure no name conflict
);

DROP TABLE IF EXISTS schemes;
CREATE TABLE schemes(
SchemeId    INTEGER     NOT NULL    PRIMARY KEY ,
name        TEXT        NOT NULL    UNIQUE
);

DROP TABLE IF EXISTS Names;
CREATE TABLE Names(
nameId      INTEGER NOT NULL    PRIMARY KEY,
name        TEXT    NOT NULL,
tag	    TEXT    NOT NULL DEFAULT '',
substId	    TEXT    REFERENCES substances,
UNIQUE(NAME, tag),  --enforce a many-to-1 relation between name and substid
UNIQUE(NAME, tag, substId)  --enforce a many-to-1 relation between name and substid
);

DROP TABLE IF EXISTS nameHasScheme;
CREATE TABLE nameHasScheme(
nameId      INTEGER NOT NULL    REFERENCES names,
schemeId    INTEGER NOT NULL    REFERENCES schemes,
UNIQUE(nameId, schemeId)
);

DROP TABLE IF EXISTS comp;
CREATE TABLE comp(
compName    TEXT    PRIMARY KEY
);

DROP TABLE IF EXISTS subcomp;
CREATE TABLE subcomp(
subcompName TEXT    PRIMARY KEY,
parentcomp  TEXT    REFERENCES comp(compName)
);


drop table if exists old_labels;
create table old_labels(
oldid       INTEGER NOT NULL  PRIMARY KEY,
ardaid      INTEGER NOT NULL UNIQUE,
name        TEXT,
name2       TEXT,
name3       TEXT,
tag	    TEXT NOT NULL DEFAULT '',
cas         text    CHECK (cas NOT LIKE '0%'),
comp        TEXT NOT NULL,
subcomp     TEXT,
unit        TEXT NOT NULL,
substId     INTEGER,
CONSTRAINT hasAName CHECK((name IS NOT NULL) OR (name2 IS NOT NULL) OR (name3 IS NOT NULL) )
);

DROP TABLE IF EXISTS impacts;
CREATE TABLE impacts (
impactId        TEXT    PRIMARY KEY,
long_name       TEXT    ,
scope           text    ,
perspective     text    not null,
unit            TEXT    not null,
referenceSubstId    INTEGER --REFERENCES substances(substId)    
);

DROP TABLE IF EXISTS factors;
CREATE TABLE factors(
factorId    INTEGER     NOT NULL PRIMARY KEY,
substId     integer     NOT NULL REFERENCES substances,
comp        text        NOT NULL REFERENCES comp(compName),
subcomp     text                 REFERENCES subcomp(subcompName),
unit        text        NOT NULL,
impactId    TEXT        NOT NULL     REFERENCES impacts,
method      TEXT	DEFAULT '--',
factorValue double precision    not null,
UNIQUE (substId, comp, subcomp, unit, impactId, method, factorValue)
-- STRICTER:
-- UNIQUE (substId, comp, subcomp, unit, impactId, method)
-- The unique constraint makes sense, but remove and check manually to facilitate
-- 	logging and idenfying source of conflict
);

DROP TABLE IF EXISTS labels_inventory;
CREATE TABLE labels_inventory(
id    SERIAL  NOT NULL PRIMARY KEY,
substId     INTEGER REFERENCES substances,
name        TEXT    ,
tag         TEXT    DEFAULT NULL,
comp        TEXT    NOT NULL references comp(compName),
subcomp     TEXT    references subcomp(subcompName),
formula     TEXT    ,
unit        TEXT    ,
cas         text    CHECK (cas NOT LIKE '0%'),
dsid        integer,
name2       TEXT,
CONSTRAINT hasAName CHECK(NAME IS NOT NULL OR name2 IS NOT NULL),
FOREIGN KEY (name, tag) REFERENCES names(name, tag),
FOREIGN KEY (name2, tag) REFERENCES names(name, tag)
-- Cannot put uniqueness constraints, data in a mess
-- name and name2 cannot reference names(name) because no unique constraint
);


DROP TABLE IF EXISTS labels_char;
CREATE table labels_char(
id	    INTEGER NOT NULL PRIMARY KEY,
substId     INTEGER REFERENCES substances,
comp        TEXT    NOT NULL references comp(compName),
subcomp     TEXT    references subcomp(subcompName),
name        TEXT    ,
name2       TEXT    ,
cas         text    CHECK (cas NOT LIKE '0%'),
tag         TEXT    ,
unit        TEXT    ,
CONSTRAINT hasAName CHECK(NAME IS NOT NULL OR name2 IS NOT NULL),
FOREIGN KEY (name, tag) REFERENCES names(name, tag),
FOREIGN KEY (name2, tag) REFERENCES names(name, tag)
-- Cannot put uniqueness constraints, data in a mess
);

DROP TABLE IF EXISTS labels_out;
CREATE TABLE labels_out(
id          	INTEGER  NOT NULL PRIMARY KEY,
dsid        	TEXT,
substId     	INTEGER REFERENCES substances,
name        	TEXT    ,
tag         	TEXT    DEFAULT NULL,
comp        	TEXT    NOT NULL references comp(compName),
subcomp     	TEXT    REFERENCES subcomp(subcompName),
formula     	TEXT    ,
unit        	TEXT    ,
cas         	text    CHECK (cas NOT LIKE '0%'),
name2       	TEXT,
ardaid	    	INTEGER UNIQUE,
characterized	Boolean	DEFAULT NULL
CONSTRAINT hasAName CHECK(NAME IS NOT NULL OR name2 IS NOT NULL),
FOREIGN KEY (name, tag) REFERENCES names(name, tag),
FOREIGN KEY (name2, tag) REFERENCES names(name, tag)
);

--==========================================
-- MATCHING ELEMENTARY FLOWS ANC CHAR FACTORS
--===========================================

-- Define the "default" subcompartment amongst all the
-- subcompartments of a parent compartment. Useful for
-- characterisation methods that do not define factors for the parent
-- compartment (i.e. no "unspecified" subcompartment).

DROP TABLE IF EXISTS fallback_sc;
CREATE TABLE fallback_sc(
comp    TEXT    not null    REFERENCES comp, 
subcomp TEXT    not null    REFERENCES subcomp,
method  TEXT
);

--  Table for matching the "observed" (best estimate) subcompartment
--  with the best fitting comp/subcompartment of characterisation
--  method

--  Kind of like the "proxy table" of
--  elementaryflow/characterisation factors. Could maybe find a
--  better name.

DROP TABLE IF EXISTS obs2char_subcomps;
CREATE TABLE obs2char_subcomps(
obs2charId  INTEGER NOT NULL    primary key,
comp        text    not null    ,
	--references comp(compName),--REFERENCES comp,
obs_sc      text    not null    ,
    --references subcomp(subcompName), -- observed subcomp
char_sc     text    not null    ,
	    --references subcomp(subcompName),
	    -- best match for a characterised subcomp
scheme      TEXT    ,
UNIQUE(comp, obs_sc, scheme)
);

-- TODO: connect with references
DROP TABLE IF EXISTS obs2char;
CREATE TABLE obs2char(
flowId      INTEGER,
dsid        TEXT,
impactId    text    not null,
factorId    int not null,
factorValue double precision    not null,
scheme      TEXT DEFAULT '--',
UNIQUE(flowId, impactId, scheme)
);

--====================================
-- TEMPORARY TABLES
--====================================



-- DROP TABLE IF EXISTS synonyms;
-- CREATE TABLE synonyms(
--     rawId   INTEGER,
--     tag     TEXT,
--     name   TEXT,
--     name2   TEXT,
--     unit    text
-- );

-- DROP TABLE IF EXISTS tempNamesWithoutCas;
-- CREATE TABLE tempNamesWithoutCas(
--     rawId INTEGER,
--     tag TEXT,
--     name TEXT,
--     name2 TEXT,
--     unit    text
-- );

-- DROP TABLE IF EXISTS singles;
-- CREATE TABLE singles(
--     rawId   INTEGER,
--     tag TEXT,
--     name    TEXT,
--     unit    text
-- );



DROP Table IF EXISTS bad;
CREATE TABLE bad(
sparseId        INTEGER REFERENCES sparse_factors,
substId         INTEGER DEFAULT NULL ,
comp            TEXT    ,
subcomp         TEXT    ,
unit            TEXT    ,
factorValue double precision,
impactId    TEXT
);

DROP TABLE IF EXISTS sparse_factors;
CREATE TABLE sparse_factors(
sparseId        INTEGER  PRIMARY KEY NOT NULL,
substId         INTEGER     DEFAULT NULL ,
comp            TEXT    ,
subcomp         TEXT    ,
unit            TEXT    ,
factorValue     double precision,
impactId        TEXT
);

