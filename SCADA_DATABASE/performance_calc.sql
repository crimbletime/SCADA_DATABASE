CREATE DEFINER=`res`@`%` PROCEDURE mokresh.`performance_calc`()
BEGIN

DROP TEMPORARY TABLE IF EXISTS temp_coeff;
CREATE TEMPORARY TABLE temp_coeff (t_stamp datetime, v float);
CALL `mokresh`.`get_meteo`('GMAHALA/ZRU/METEO/TmpMdul');
INSERT INTO temp_coeff (SELECT from_unixtime(t_stamp),1-(v-25)*.005 FROM meteo_tmp );


DROP TEMPORARY TABLE IF EXISTS temp_irr;
CREATE TEMPORARY TABLE temp_irr (t_stamp datetime, v float, std_dev float);
CALL `mokresh`.`get_meteo_with_stats`('GMAHALA/ZRU/METEO/IntSolIrr');
INSERT INTO temp_irr (SELECT from_unixtime(t_stamp),v, std_dev FROM meteo_tmp);

DROP TEMPORARY TABLE IF EXISTS temp_pac;
CREATE TEMPORARY TABLE temp_pac (t_stamp datetime, v float);
CALL `mokresh`.`get_meteo`('GMAHALA/BKTP3/INV 3-01/Pac');
INSERT INTO temp_pac (SELECT from_unixtime(t_stamp),v FROM meteo_tmp);

/*
DROP TEMPORARY TABLE IF EXISTS temp_perf;
CREATE TEMPORARY TABLE temp_perf (t_stamp datetime, v float);

insert into temp_perf (select t1.t_stamp, (t3.v * t1.v)/t2.v
from temp_coeff t1
join temp_irr t2 on t1.t_stamp = t2.t_stamp
join temp_pac t3 on t1.t_stamp = t3.t_stamp);
*/

END