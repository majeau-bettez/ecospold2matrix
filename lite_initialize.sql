
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS substances;
CREATE TABLE substances(
	substId		INTEGER NOT NULL PRIMARY KEY,
	formula		TEXT,
	cas		TEXT	CHECK (length(cas)=11 OR cas IS NULL),	-- CAS number
	tag		TEXT	DEFAULT NULL, -- distinguish special instances same substance 
	rawId		INT	UNIQUE,
	unit		TEXT	NOT NULL,
	UNIQUE(cas, tag, unit)
);

DROP TABLE IF EXISTS schemes;
CREATE TABLE schemes(
	SchemeId	INTEGER PRIMARY KEY 	NOT NULL,
	name		TEXT    		NOT NULL
);

DROP TABLE IF EXISTS Names;
CREATE TABLE Names(
	nameId	INTEGER NOT NULL PRIMARY KEY,
	name	text	NOT NULL ,
	substId	int	NOT NULL	references substances,
	unique(name, substId)
);


DROP TABLE IF EXISTS nameHasScheme;
CREATE TABLE nameHasScheme(
	nameId		INTEGER	NOT NULL 	references names,
	schemeId	INTEGER	NOT NULL	references schemes
);

DROP TABLE IF EXISTS comp;
CREATE TABLE comp(
	compName	TEXT	PRIMARY KEY
);

DROP TABLE IF EXISTS subcomp;
CREATE TABLE subcomp(
	subcompName	TEXT	PRIMARY KEY,
	parentcomp	TEXT	REFERENCES comp(compName)
);


-- elementary flow tables (named observed flows for no good reason)
DROP TABLE IF EXISTS observedflows;
CREATE TABLE observedflows(
	obsflowId 	INTEGER 	NOT NULL PRIMARY KEY,
	substId		INTEGER		NOT NULL REFERENCES substances,
	DSID		integer		UNIQUE,
	ardaId		integer		unique,
	comp		TEXT		NOT NULL references comp ,
	subcomp		TEXT		references subcomp,
	unit		TEXT		not null,
	UNIQUE(substId, comp, subcomp, unit)
);

drop table if exists old_labels;
create table old_labels(
	oldid		INTEGER NOT NULL  primary key,
	fullname	text,
	ardaid		integer not null,
	name		text not null,
	dsid		integer not null,
	infrastructure	text,
	location	text,
	comp		text,
	subcomp		text,
	unit		text ,
	covered_before	boolean not null,
	covered_new	boolean default false
);

DROP TABLE IF EXISTS impacts;
CREATE TABLE impacts (
	impactId		TEXT	PRIMARY KEY,
	long_name		TEXT	not null,
	scope			text	not null,
	perspective		text	not null,
	unit			TEXT	not null,
	referenceSubstId	INTEGER	--REFERENCES substances(substId)	
);

DROP TABLE IF EXISTS factors;
CREATE TABLE factors(
	factorId	INTEGER		NOT NULL PRIMARY KEY,
	substId		integer		not null		references substances,
	comp		text		not null		references comp,
	subcomp		text					references subcomp, -- no subcomp in Arda
	unit		text		not null,
	impactId	TEXT		not null		REFERENCES impacts,
	method		TEXT, 			-- Or foreignkey of table scheme?
	factorValue	double precision	not null,
	UNIQUE (substId, comp, subcomp, impactId,  method)
);

--==========================================
-- MATCHING ELEMENTARY FLOWS ANC CHAR FACTORS
--===========================================

-- Define the "default" subcompartment amongst all the subcompartments of a parent compartment. Useful for characterisation methods that do not define factors for the parent compartment (i.e. no "unspecified" subcompartment).
DROP TABLE IF EXISTS fallback_sc;
CREATE TABLE fallback_sc(
	comp	TEXT	not null	REFERENCES comp, 
	subcomp	TEXT	not null	REFERENCES subcomp,
	method	TEXT
);

-- Table for matching the "observed" (best estimate) subcompartment with the best fitting comp/subcompartment of characterisation method
-- Kind of like the "proxy table" of elementaryflow/characterisation factors. Could maybe find a better name.
drop table if exists obs2char_subcomps;
create table obs2char_subcomps(
	obs2charId	INTEGER NOT NULL 	primary key,
	comp		text	not null	references comp,--REFERENCES comp,
	obs_sc		text	not null	references subcomp, -- observed subcomp
	char_sc		text	not null	references subcomp, -- best match for a characterised subcomp
	scheme		TEXT	,
	UNIQUE(comp, obs_sc, scheme)
);

DROP TABLE IF EXISTS obs2char;
CREATE TABLE obs2char(
	obsflowId	INTEGER,
	impactId	text	not null,
	factorId	int	not null,
	factorValue	double precision	not null,
	scheme		TEXT,
	UNIQUE(obsflowId, impactId, scheme)
);

--====================================
-- TEMPORARY TABLES
--====================================

DROP table if exists raw_recipe;
create table raw_recipe (
	rawId		INTEGER	primary key,
	substid		int	references substances,
	flowId		INTEGER	,
	comp		text	not null,
	subcomp		text		,
	recipeName	text 		,
	simaproName	text	DEFAULT NULL	,
	cas		TEXT	DEFAULT NULL		,
	tag		TEXT	DEFAULT NULL,
	unit		text	not null,
	formula		TEXT	,
	LHV		double precision,
	grouping	TEXT	,
	FEP20	double precision,
	FEP100	double precision,
	FEPInf	double precision,
	MEP20	double precision,
	MEP100	double precision,
	MEPInf	double precision,
	GWP20	double precision,
	GWP100	double precision,
	GWP500	double precision,
	ODP20	double precision,
	ODP100	double precision,
	ODPInf	double precision,
	TAP20	double precision,
	TAP100	double precision,
	TAP500	double precision,
	POFP20	double precision,
	POFP100	double precision,
	POFPInf	double precision,
	PMFP20	double precision,
	PMFP100	double precision,
	PMFPInf	double precision,
	IRP20	double precision,
	IRP100	double precision,
	IRPInf	double precision,
	ALOP20	double precision,
	ALOP100	double precision,
	ALOPInf	double precision,
	ULOP20	double precision,
	ULOP100	double precision,
	ULOPInf	double precision,
	LTP20	double precision,
	LTP100	double precision,
	LTPInf	double precision,
	WDP20	double precision,
	WDP100	double precision,
	WDPInf	double precision,
	MDP20	double precision,
	MDP100	double precision,
	MDPInf	double precision,
	FDP20	double precision,
	FDP100	double precision,
	FDPInf	double precision,
	FETP_I	double precision,
	FETP_H	double precision,
	FETP_E	double precision,
	HTP_I	double precision,
	HTP_H	double precision,
	HTP_E	double precision,
	METP_I	double precision,
	METP_H	double precision,
	METP_E	double precision,
	TETP_I	double precision,
	TETP_H	double precision,
	TETP_E	double precision,
	remark	TEXT,
	constraint MustHaveName check  ( recipeName is not null or simaproName is not null)
);
