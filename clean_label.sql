

-- metals in ore are treated as synonyms
-- update {t} set cas=null where name like '%, in ground' OR name like '% ore%';

update {t} set cas=NULL where name like '%water%';

-- cas of 2-butenal, instead of (2e)-2-butenal
update {t} set name='2-butenal, (2e)-', name2='crotonaldehyde, (e)-' where cas='123-73-9' and name='2-butenal';



update {t} set name='3-(1-methylbutyl)phenyl methylcarbamate' where cas='2282-34-0'; -- instead of 'bufencarb' (008065-36-9), which is a mixture of this substance and phenol, 3-(1-ethylpropyl)-, 1-(n-methylcarbamate),

-- nomenclature conflict between recipe and simapro. 
-- pure chlordane is set with cas 000057-74-9, and is also defined for cis and trans. this one here seems to be more of a mixture or low grade. 
-- no molecular formula on scifinder
update {t} set name2='chlordane (technical)' where cas='12789-03-6'; -- instead of simpley 'chlordane'


-- same chemical (phenoxycarb) twice, once under deprecated cas, and with different characterisation factors. remove the rows with deprecated cas.
	/*
	cas registry number: 72490-01-8
	
	        c17 h19 n o4
	        carbamic acid, n-[2-(4-phenoxyphenoxy)ethyl]-, ethyl ester
	        carbamic acid, [2-(4-phenoxyphenoxy)ethyl]-, ethyl ester (9ci); abg 6215; eclipse; eclipse (growth regulator);
		 ethyl [2-(4-phenoxyphenoxy)ethyl]carbamate; fenoxycarb; insegar; logic; logic (growth regulator); phenoxycarb; ro 13-5223 
	deleted cas registry numbers: 79127-80-3
	*/
delete from {t} where cas='79127-80-3';

-- replace duplicate original cas number (084011-06-3), which fit well with the name 'ether, 1,2,2-trifluoroethyl trifluoromethyl-' but not with the "ipcc-tag" (e.g hfe-236fa). also contradiction between chemical name and tag. to be fixed later?
-- http://www.deq.state.ne.us/press.nsf/3eb24ee59e8286048625663a006354f0/1721875d44a691d9862578bf005ba3ce/$file/ghg%20table_handout.pdf

-------------------------------
-- cas for ions (for compatibility with ecoinvent)
update {t} set cas='17428-41-0', name=name2 where name2='arsenic, ion' and cas='7440-38-2';
update {t} set cas='22541-77-1', name=name2 where name2='vanadium, ion' and cas='7440-62-2';
update {t} set cas='23713-49-7', name=name2 where name2='zinc, ion' and cas='7440-66-6';
update {t} set cas='22537-50-4', name=name2 where name2='tin, ion' and cas='7440-31-5';
update {t} set cas='14701-21-4', name=name2 where name2='silver, ion' and cas='7440-22-4';
update {t} set cas='18540-29-9', name='chromium vi' where (name2='chromium vi' or name='chromium vi') and cas='7440-47-3';
update {t} set cas='17493-86-6', name2='copper, ion', name='copper, ion' where cas='7440-50-8' and comp='water'; -- Copper emissions to water, treated as ions in Ecoinvent.


update {t} set name=name2 where name='chromium iii' and cas='7440-47-3'; -- Disambiguation. Assume CAS is right, i.e. we want the neutral substance
update {t} set cas='16065-83-1' where name='chromium iii'; -- Disambiguation, step 2: when really ion, give right CAS
update {t} set name=name2 where cas='7440-02-0'; -- Step1 of nickel disambiguation
update {t} set cas='14701-22-5' where name='nickel ii'; -- step2 of nickel ion
update {t} set cas='22537-48-0', name=name2 where name2='cadmium, ion' and cas='7440-43-9';



--update {t} set cas=NULL where ( name like '% ore%' or name2 like '% ore%') and (name like '% in ground' or name2 like '% in ground');
--update {t} set tag='in ore' where (name like '% in ground' or name2 like '% in ground');


update {t} set cas=NULL where name like '%water, salt%' or name2 like '%water, salt%';

--- Dealing with stupid unit conversion

delete from {t} where name like '%/kg' and unit='kg';

