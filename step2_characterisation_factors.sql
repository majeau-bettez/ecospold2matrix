-- ==============================================
-- INSPECT FACTORS FOR PROBLEMS
-- ===========================================

-- Internal problem: same substance, same comp/subcomp, same units, different characterisation factors
select 'two char factors for the same thing?' as message;
SELECT * FROM sparse_factors s1
WHERE EXISTS ( SELECT 1
	FROM sparse_factors s2
	WHERE s1.SubstId = s2.SubstId 
		AND s1.comp=s2.comp 
		AND (s1.subcomp=s2.subcomp OR (s1.subcomp IS NULL AND s2.subcomp IS NULL))
		AND s1.unit=s2.unit 
		AND s1.impactId=s2.impactId
		AND s1.sparseId <> s2.sparseId
		AND s1.factorValue <> s2.factorValue
	ORDER BY (s1.substId, s1.comp, s1.subcomp, s1.unit, s1.impactId))
;

-- Insert all nonproblematic factors

insert into factors (substId, comp, subcomp, unit, impactId, method, factorValue)
	select distinct  sp.substId, sp.comp, sp.subcomp, sp.unit, sp.impactId, 'Recipe108', sp.factorValue
	from sparse_factors sp
	where sp.substid not in (select b.substid from bad b)
;



