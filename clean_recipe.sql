-- ===================================
-- CLEAN UP
-- ==================================

-- clean up! * CANNOT LOWERCASE, as this is sometimes the only difference between chemical names: e.g N,n-dimethylthiourea. 
update	raw_recipe set comp=trim((lower(comp))), subcomp=trim((lower(subcomp))), name1=trim((lower(name1))), name2=trim((lower(name2))), cas=trim(cas), unit=trim(unit);
update raw_recipe set cas=null where length(cas)=0;
update raw_recipe set name1=null where length(name1)=0;
update raw_recipe set name2= null where length(name2)=0;
update raw_recipe set subcomp='unspecified' where subcomp is null or subcomp='(unspecified)';
update raw_recipe set subcomp='low population density' where subcomp='low. pop.';
update raw_recipe set subcomp='high population density' where subcomp='high. pop.';
update raw_recipe set comp='resource' where comp='raw';


-- fix problems---------
update raw_recipe set cas='93-65-2' where (name1='mecoprop' or name2='mecoprop') and cas='7085-19-0'; -- deprecated
update raw_recipe set cas='138261-41-3' where cas='38261-41-3'; -- imidacloprid cas not found in scifinder

update raw_recipe set name2='n,n''-dimethylthiourea' where cas ='534-13-4'; -- formally case sensitive name n,n-dimethyl, now n,n'-dimethyl

-- cas of 2-butenal, instead of (2e)-2-butenal
update raw_recipe set name1='2-butenal, (2e)-', name2='crotonaldehyde, (e)-' where cas='123-73-9' and name1='2-butenal';

update raw_recipe set name1='3-(1-methylbutyl)phenyl methylcarbamate' where cas='2282-34-0'; -- instead of 'bufencarb' (008065-36-9), which is a mixture of this substance and phenol, 3-(1-ethylpropyl)-, 1-(n-methylcarbamate),

-- nomenclature conflict between recipe and simapro. 
-- pure chlordane is set with cas 000057-74-9, and is also defined for cis and trans. this one here seems to be more of a mixture or low grade. 
-- no molecular formula on scifinder
update raw_recipe set name2='chlordane (technical)' where cas='12789-03-6'; -- instead of simpley 'chlordane'


-- same chemical (phenoxycarb) twice, once under deprecated cas, and with different characterisation factors. remove the rows with deprecated cas.
	/*
	cas registry number: 72490-01-8
	
	        c17 h19 n o4
	        carbamic acid, n-[2-(4-phenoxyphenoxy)ethyl]-, ethyl ester
	        carbamic acid, [2-(4-phenoxyphenoxy)ethyl]-, ethyl ester (9ci); abg 6215; eclipse; eclipse (growth regulator);
		 ethyl [2-(4-phenoxyphenoxy)ethyl]carbamate; fenoxycarb; insegar; logic; logic (growth regulator); phenoxycarb; ro 13-5223 
	deleted cas registry numbers: 79127-80-3
	*/
delete from raw_recipe where cas='79127-80-3';

-- replace duplicate original cas number (084011-06-3), which fit well with the name 'ether, 1,2,2-trifluoroethyl trifluoromethyl-' but not with the "ipcc-tag" (e.g hfe-236fa). also contradiction between chemical name and tag. to be fixed later?
update raw_recipe set cas='20193–67–3' where name1='ether, 1,2,2-trifluoroethyl trifluoromethyl-, hfe-236fa';
update raw_recipe set cas='57041–67–5' where name1='ether, 1,2,2-trifluoroethyl trifluoromethyl-, hfe-236ea2';
update raw_recipe set cas='160620-20-2' where name1 like '%356pcc3%';
update raw_recipe set cas='35042-99-0' where name1 like '%356pcf3%';
update raw_recipe set cas=null where name1 like '%356pcf2%' and cas='382-34-3';
update raw_recipe set cas='382-34-3' where name1 like '%356mec3%';
update raw_recipe set cas='22410-44-2' where name1 like '%245cb2%';
update raw_recipe set cas='84011-15-4' where name1 like '%245fa1%';
update raw_recipe set cas='28523–86–6' where name1 like '%347mcc3%';

-- http://www.deq.state.ne.us/press.nsf/3eb24ee59e8286048625663a006354f0/1721875d44a691d9862578bf005ba3ce/$file/ghg%20table_handout.pdf

-------------------------------
-- cas for ions (for compatibility with ecoinvent)
update raw_recipe set cas='17428-41-0', name1=name2 where name2='arsenic, ion' and cas='7440-38-2';
update raw_recipe set cas='22541-77-1', name1=name2 where name2='vanadium, ion' and cas='7440-62-2';
update raw_recipe set cas='23713-49-7', name1=name2 where name2='zinc, ion' and cas='7440-66-6';
update raw_recipe set cas='22537-50-4', name1=name2 where name2='tin, ion' and cas='7440-31-5';
update raw_recipe set cas='14701-21-4', name1=name2 where name2='silver, ion' and cas='7440-22-4';
update raw_recipe set cas='18540-29-9', name1='chromium vi' where (name2='chromium vi' or name1='chromium vi') and cas='7440-47-3';
update raw_recipe set cas='17493-86-6', name2='copper, ion', name1='copper, ion' where cas='7440-50-8' and comp='water'; -- Copper emissions to water, treated as ions in Ecoinvent.
update raw_recipe set name1=name2 where name1='chromium iii' and cas='7440-47-3'; -- Disambiguation. Assume CAS is right, i.e. we want the neutral substance
update raw_recipe set cas='16065-83-1' where name1='chromium iii'; -- Disambiguation, step 2: when really ion, give right CAS

update raw_recipe set name1=name2 where cas='7440-02-0'; -- Step1 of nickel disambiguation
update raw_recipe set cas='14701-22-5' where name1='nickel ii'; -- step2 of nickel ion



update raw_recipe set cas='22537-48-0', name1=name2 where name2='cadmium, ion' and cas='7440-43-9';


-----------tag   tag   tag
update raw_recipe set tag='fossil' where name1 like '%, fossil' or name2 like '%, fossil';
update raw_recipe set tag='total' where name1='%, total' or name2 like '%, total';
update raw_recipe set tag='organic bound' where name1='%, organic bound' or name2 like '%, organic bound';
update raw_recipe set tag='biogenic' where name1 like '%, biogenic' or name2 like '%, biogenic';
update raw_recipe set tag='as n' where name1 like '%, as n' or name2 like '%, as n';
update raw_recipe set tag='land transformation' where name1 like '%, land transformation'or name2 like '%, land transformation';
update raw_recipe set tag='mix' where name1 like '% compounds' or name2 like '% compounds';
update raw_recipe set tag='alpha radiation' where (name1 like '%alpha%' or name2 like '%alpha%') and unit='kbq';

--update raw_recipe set cas=NULL where ( name1 like '% ore%' or name2 like '% ore%') and (name1 like '% in ground' or name2 like '% in ground');
--update raw_recipe set tag='in ore' where (name1 like '% in ground' or name2 like '% in ground');
update raw_recipe set name1=replace(name1,', in ground',''), name2=replace(name2, ', in ground','') where (name1 like '% in ground' or name2 like '% in ground');
update raw_recipe set name1=replace(name1,', unspecified','') where name1 like '%, unspecified';
update raw_recipe set name2=replace(name2,', unspecified','') where name2 like '%, unspecified';
update raw_recipe set cas=NULL where name1 like '%water, salt%' or name2 like '%water, salt%';

--- Dealing with stupid unit conversion

delete from raw_recipe where name1 like '%/kg' and unit='kg';
update raw_recipe set name1=replace(name1,'/m3',''), name2=replace(name2,'/m3','') where name1 like '%/m3';

