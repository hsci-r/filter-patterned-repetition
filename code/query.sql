-- Produces one row for *every* SKVR poem.
SELECT
  CONCAT("https://runoregi.rahtiapp.fi/poem?nro=", nro) AS link,
  nro, COUNT(DISTINCT clust_id) AS n_clust, COUNT(DISTINCT pos) AS n_verses, 
  (COUNT(DISTINCT pos)-COUNT(DISTINCT clust_id)) / COUNT(DISTINCT pos) AS p_rep,
  IFNULL(indiv.n_individual_lines, 0) AS n_individual_lines,
  GROUP_CONCAT(DISTINCT theme ORDER BY theme SEPARATOR "; ") AS types,
  GROUP_CONCAT(DISTINCT tlc ORDER BY tlc SEPARATOR "; ") AS tlc,
  IFNULL(lc.name, lp.name) AS region,
  IF(lc.name IS NOT NULL, lp.name, NULL) AS parish,
  pol.pol_id AS pol_id
FROM (
  -- We need this in a subquery to set the types and verses that we
  -- don't want to count to NULL. This applies for:
  -- - types marked as "minor"
  -- - verses of type other than <V> or with empty cleaned text, even if
  --   they have entries in the `v_clust` table.
  SELECT
    p.p_id, p.nro,
    IF(v.type = "V" AND v_cl.text <> "", vp.pos, NULL) AS pos,
    IF(v.type = "V" AND v_cl.text <> "", vc.clust_id, NULL) AS clust_id,
    IF(pt.is_minor = 0, t1.name, NULL) AS theme,
    IF(pt.is_minor = 0, IFNULL(t4.name, IFNULL(t3.name, t2.name)), NULL) AS tlc,
    v.type, v.text
  FROM
    poems p
    LEFT JOIN verse_poem vp ON p.p_id = vp.p_id
    LEFT JOIN verses v ON vp.v_id = v.v_id
    LEFT JOIN v_clust vc ON vc.v_id = vp.v_id AND vc.clustering_id = 0
    LEFT JOIN verses_cl v_cl ON v_cl.v_id = vp.v_id
    LEFT JOIN poem_theme pt ON vp.p_id = pt.p_id
    LEFT JOIN themes t1 ON pt.t_id = t1.t_id
    LEFT JOIN themes t2 ON t1.par_id = t2.t_id
    LEFT JOIN themes t3 ON t2.par_id = t3.t_id
    LEFT JOIN themes t4 ON t3.par_id = t4.t_id
  WHERE
    p.collection = "skvr"
  ) t
  LEFT JOIN p_loc ON t.p_id = p_loc.p_id
  LEFT JOIN locations lp ON lp.loc_id = p_loc.loc_id
  LEFT JOIN locations lc ON lp.par_id = lc.loc_id
  LEFT JOIN pol_loc ON lp.loc_id = pol_loc.loc_id
  LEFT JOIN polygons pol ON pol_loc.pol_id = pol.pol_id
  LEFT JOIN (
    -- A table counting the numbers of individual lines
    -- (verse clusters that occur only once in the poem).
    SELECT 
      p_id, COUNT(*) AS n_individual_lines
    FROM (
      SELECT
        p.p_id, p.nro, vc.clust_id, COUNT(*) AS n
      FROM
        poems p
        JOIN verse_poem vp ON vp.p_id = p.p_id
        JOIN v_clust vc ON vp.v_id = vc.v_id AND vc.clustering_id = 0
        JOIN verses_cl v_cl ON v_cl.v_id = vp.v_id
        JOIN verses v ON v.v_id = vp.v_id
      WHERE v_cl.text <> "" AND v.type = "V"
      GROUP BY p.p_id, vc.clust_id
    ) t2
    WHERE t2.n = 1
    GROUP BY t2.p_id
    ) indiv ON indiv.p_id = t.p_id
GROUP BY t.p_id
ORDER BY p_rep DESC
;

