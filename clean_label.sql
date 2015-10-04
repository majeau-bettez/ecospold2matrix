

-- metals in ore are treated as synonyms
-- update {t} set cas=null where name like '%, in ground' OR name like '% ore%';







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

update {t} set name=name2 where cas='7440-02-0'; -- Step1 of nickel disambiguation
update {t} set cas='14701-22-5' where name='nickel ii'; -- step2 of nickel ion
update {t} set cas='22537-48-0', name=name2 where name2='cadmium, ion' and cas='7440-43-9';



--update {t} set cas=NULL where ( name like '% ore%' or name2 like '% ore%') and (name like '% in ground' or name2 like '% in ground');
--update {t} set tag='in ore' where (name like '% in ground' or name2 like '% in ground');


update {t} set cas=NULL where name like '%water, salt%' or name2 like '%water, salt%';

--- Dealing with stupid unit conversion

delete from {t} where name like '%/kg' and unit='kg';

