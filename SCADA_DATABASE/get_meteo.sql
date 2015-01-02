CREATE DEFINER=`res`@`%` PROCEDURE mokresh.`get_meteo`(IN tagpath VARCHAR(255))
BEGIN


  DECLARE t_name, tagpath_id VARCHAR(255);
  DECLARE sql_text VARCHAR(1255);

  DECLARE r_done INT DEFAULT FALSE;
  DECLARE cursor_i CURSOR FOR SELECT TABLE_NAME FROM information_schema.tables
       WHERE TABLE_NAME LIKE 'sqlt_data%_60'
       AND TABLE_SCHEMA='mokresh';

 DECLARE CONTINUE HANDLER FOR NOT FOUND SET r_done = TRUE;
DROP TEMPORARY TABLE IF EXISTS meteo_tmp;
        CREATE TEMPORARY TABLE meteo_tmp (
            v float, t_stamp int(11) UNSIGNED);

  OPEN cursor_i;
  read_loop: LOOP
    FETCH cursor_i INTO t_name;
    IF r_done THEN
      LEAVE read_loop;
    END IF;


SET @sql_text := concat(
'SELECT avg(ifnull(floatvalue,intvalue)) as v,',
' ((t_stamp/1000)-(t_stamp/1000)%3600) as tim FROM ',t_name,
' WHERE tagid in (SELECT id FROM mokresh.sqlth_te where tagpath= \'', tagpath,
'\') group by tim'
);

SET @sql_text := concat('insert into meteo_tmp (',@sql_text,')');

PREPARE stmt FROM @sql_text;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

  END LOOP;
  CLOSE cursor_i;

END