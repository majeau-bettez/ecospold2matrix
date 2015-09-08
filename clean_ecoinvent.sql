
-- ========================================
-- TEMPORARY TABLES
-- =======================================
drop table if exists dsid_substid;
create table dsid_substid(
	ecorawId        integer		UNIQUE,
	substid		integer,
	obsflowid	integer,
	constraint oneSubstPerDSID unique(ecorawId, obsflowid)
);

drop table if exists temp;
create table temp(
	comp	text,
	subcomp	text,
	impactId text
);

drop table if exists unmatchedEcoinventSubst;
create table unmatchedEcoinventSubst(
	rawid	serial primary key,
	name	text,
	tag	text,
	unit	text,
	cas	text
);
-- -- =======================================
-- -- READ IN + CLEANUP ECOINVENT ELEMENTARY FLOWS 
-- --=======================================
-- 
-- DROP TABLE IF EXISTS labels_ecoinvent cascade;
-- CREATE TABLE labels_ecoinvent(
-- 	ecorawId	SERIAL	PRIMARY KEY,
-- 	excelId		INTEGER	,
-- 	NAME		TEXT 	NOT NULL,
-- 	tag		text	default null,
-- 	comp		text 	NOT NULL,
-- 	subcomp		TEXT	,
-- 	formula		TEXT	,
-- 	unit		TEXT	,
-- 	cas		TEXT	,
-- 	dsid		integer,
-- 	name3		TEXT	
-- );
-- 
-- COPY labels_ecoinvent (excelId, NAME, comp, subcomp, formula, unit, cas, dsid, name3)
-- FROM '/home/bill/data/characterisation/update_characterisation/ecoinvent22ElementaryFlows.csv' 
-- delimiter AS '	' csv header;


-- Should apply same clean Up procedure as applied to labels_ecoinvent
-- clean up! * CANNOT LOWERCASE NAME, as this is sometimes the only difference between chemical names: e.g N,n-dimethylthiourea. 
UPDATE labels_ecoinvent SET comp=trim( (lower(comp))), subcomp=trim( (lower(subcomp))), name=trim((name)), cas=trim(cas), unit=trim(unit);
UPDATE labels_ecoinvent SET cas=NULL WHERE length(cas)=0;
UPDATE labels_ecoinvent SET name=NULL WHERE length(name)=0;
UPDATE labels_ecoinvent SET name= NULL WHERE length(name)=0;
UPDATE labels_ecoinvent SET subcomp='unspecified' WHERE subcomp=NULL;

update labels_ecoinvent set cas='7440-23-5' where name='sodium'; -- same cas for ion and substance

-- changes specific to ecoinvent
update labels_ecoinvent set cas='56-35-9' where name='tributyltin compounds' and cas='56573-85-4'; -- kind of ambiguous, both cas numbers are tributyltin based. need to harmonize with recipe.
update labels_ecoinvent set cas='108-62-3' where name='metaldehyde' and cas='9002-91-9'; -- was cas of the polymer, not the molecule
update labels_ecoinvent set cas='107534-96-3' where name='tebuconazole' and cas='80443-41-0'; -- deprecated cas
update labels_ecoinvent set cas='107-15-3' where cas='117-15-3'; --typo in ecoinvent for ethylene diamine
update labels_ecoinvent set cas='2764-72-9' where name='diquat' and cas='231-36-7'; -- was cas of ion, not neutral molecule
update labels_ecoinvent set unit='m3' where unit='Nm3';
--delete from labels_ecoinvent where dsid is null;
update labels_ecoinvent set cas='74-89-5' where name='methyl amine'; -- previously 000075-89-5
update labels_ecoinvent set cas='302-04-5' where cas='71048-69-6'; -- deprecated for thiocyanate

-- some ipcc fixes
update labels_ecoinvent set cas='20193–67–3' where name='ether, 1,2,2-trifluoroethyl trifluoromethyl-, hfe-236fa';
update labels_ecoinvent set cas='57041–67–5' where name='ether, 1,2,2-trifluoroethyl trifluoromethyl-, hfe-236ea2';
update labels_ecoinvent set cas='160620-20-2' where name like '%356pcc3%';
update labels_ecoinvent set cas='35042-99-0' where name like '%356pcf3%';
update labels_ecoinvent set cas='382-34-3' where name like '%356mec3%';
update labels_ecoinvent set cas='22410-44-2' where name like '%245cb2%';
update labels_ecoinvent set cas='84011-15-4' where name like '%245fa1%';
update labels_ecoinvent set cas='28523–86–6' where name like '%347mcc3%';

-- http://www.deq.state.ne.us/press.nsf/3eb24ee59e8286048625663a006354f0/1721875d44a691d9862578bf005ba3ce/$FILE/GHG%20table_Handout.pdf

-----------tag   tag   tag
update labels_ecoinvent set tag='fossil' where name like '%, fossil';
update labels_ecoinvent set tag='total' where name like '%, total';
update labels_ecoinvent set tag='organic bound' where name like '%, organic bound';
update labels_ecoinvent set tag='biogenic' where name like '%, biogenic';
update labels_ecoinvent set tag='non-fossil' where name like '%, non-fossil';
update labels_ecoinvent set tag='as n' where name like '%, as n';
update labels_ecoinvent set tag='land transformation' where name like '%, land transformation';
--update labels_ecoinvent set tag='in ore' where name like '% in ground';
update labels_ecoinvent set tag='mix' where name like '% compounds';


update labels_ecoinvent set tag='alpha radiation' where name like '%alpha%' and unit='kBq';


update labels_ecoinvent set tag='in ore' where subcomp like '%in ground'; -- Ecoinvent Specific tag

-- metals in ore are treated as synonyms
-- update labels_ecoinvent set cas=null where name like '%, in ground' OR name like '% ore%';


update labels_ecoinvent set name=replace(name,', in ground','') where name like '%, in ground';
update labels_ecoinvent set cas=NULL where name like '%water%';
update labels_ecoinvent set name=replace(name,', unspecified','') where name like '%, unspecified';
