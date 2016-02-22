
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


-------------------------------

