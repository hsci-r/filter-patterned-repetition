SELECT
  CONCAT("http://runoregi.rahtiapp.fi/poem?nro=", p.nro, "&hl=",
         GROUP_CONCAT(vp.pos SEPARATOR ','),
         "#", MIN(vp.pos)) AS link,
  p.nro, vc.clust_id, COUNT(*) AS n, MIN(v_cl.text)
FROM
  verse_poem vp
  JOIN poems p ON vp.p_id = p.p_id
  JOIN v_clust vc ON vc.v_id = vp.v_id AND vc.clustering_id = 0
  JOIN verses_cl v_cl ON v_cl.v_id = vp.v_id
WHERE
  p.nro = 'skvr07210180'
GROUP BY
  vp.p_id, vc.clust_id
HAVING
  n > 1
;