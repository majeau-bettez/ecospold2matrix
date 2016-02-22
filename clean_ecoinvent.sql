-- Should apply same clean Up procedure as applied to labels_ecoinvent
-- clean up! * CANNOT LOWERCASE NAME, as this is sometimes the only difference between chemical names: e.g N,n-dimethylthiourea. 
UPDATE raw_ecoinvent SET comp=trim( (lower(comp))), subcomp=trim( (lower(subcomp))), name=trim((name)), cas=trim(cas), unit=trim(unit);
UPDATE raw_ecoinvent SET cas=NULL WHERE length(cas)=0;
UPDATE raw_ecoinvent SET name=NULL WHERE length(name)=0;
UPDATE raw_ecoinvent SET name= NULL WHERE length(name)=0;
UPDATE raw_ecoinvent SET subcomp='unspecified' WHERE subcomp=NULL;

update raw_ecoinvent set cas='7440-23-5' where name='sodium'; -- same cas for ion and substance

-- changes specific to ecoinvent
update raw_ecoinvent set cas='56-35-9' where name='tributyltin compounds' and cas='56573-85-4'; -- kind of ambiguous, both cas numbers are tributyltin based. need to harmonize with recipe.
update raw_ecoinvent set cas='108-62-3' where name='metaldehyde' and cas='9002-91-9'; -- was cas of the polymer, not the molecule
update raw_ecoinvent set cas='107534-96-3' where name='tebuconazole' and cas='80443-41-0'; -- deprecated cas
update raw_ecoinvent set cas='107-15-3' where cas='117-15-3'; --typo in ecoinvent for ethylene diamine
update raw_ecoinvent set cas='2764-72-9' where name='diquat' and cas='231-36-7'; -- was cas of ion, not neutral molecule
update raw_ecoinvent set unit='m3' where unit='Nm3';
--delete from raw_ecoinvent where dsid is null;
update raw_ecoinvent set cas='74-89-5' where name='methyl amine'; -- previously 000075-89-5
update raw_ecoinvent set cas='302-04-5' where cas='71048-69-6'; -- deprecated for thiocyanate

-- some ipcc fixes
update raw_ecoinvent set cas='20193–67–3' where name='ether, 1,2,2-trifluoroethyl trifluoromethyl-, hfe-236fa';
update raw_ecoinvent set cas='57041–67–5' where name='ether, 1,2,2-trifluoroethyl trifluoromethyl-, hfe-236ea2';
update raw_ecoinvent set cas='160620-20-2' where name like '%356pcc3%';
update raw_ecoinvent set cas='35042-99-0' where name like '%356pcf3%';
update raw_ecoinvent set cas='382-34-3' where name like '%356mec3%';
update raw_ecoinvent set cas='22410-44-2' where name like '%245cb2%';
update raw_ecoinvent set cas='84011-15-4' where name like '%245fa1%';
update raw_ecoinvent set cas='28523–86–6' where name like '%347mcc3%';

-- http://www.deq.state.ne.us/press.nsf/3eb24ee59e8286048625663a006354f0/1721875d44a691d9862578bf005ba3ce/$FILE/GHG%20table_Handout.pdf

-----------tag   tag   tag
update raw_ecoinvent set tag='fossil' where name like '%, fossil';
update raw_ecoinvent set tag='total' where name like '%, total';
update raw_ecoinvent set tag='organic bound' where name like '%, organic bound';
update raw_ecoinvent set tag='biogenic' where name like '%, biogenic';
update raw_ecoinvent set tag='non-fossil' where name like '%, non-fossil';
update raw_ecoinvent set tag='as n' where name like '%, as n';
update raw_ecoinvent set tag='land transformation' where name like '%, land transformation';
--update raw_ecoinvent set tag='in ore' where name like '% in ground';
update raw_ecoinvent set tag='mix' where name like '% compounds';


update raw_ecoinvent set tag='alpha radiation' where name like '%alpha%' and unit='kBq';


update raw_ecoinvent set tag='in ore' where subcomp like '%in ground'; -- Ecoinvent Specific tag

-- metals in ore are treated as synonyms
-- update raw_ecoinvent set cas=null where name like '%, in ground' OR name like '% ore%';


update raw_ecoinvent set name=replace(name,', in ground','') where name like '%, in ground';
update raw_ecoinvent set cas=NULL where name like '%water%';
update raw_ecoinvent set name=replace(name,', unspecified','') where name like '%, unspecified';
