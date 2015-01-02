CREATE DEFINER=`res`@`%` PROCEDURE mokresh.`daily_production`( IN m_table VARCHAR(255), IN start_date date, IN end_date date, OUT ret VARCHAR(2256))
BEGIN

DECLARE meter_table, tagpath_id VARCHAR(255);
DECLARE sql_text, sql_text1, sql_text2, sql_text3 VARCHAR(3256);
DECLARE curdate datetime;
DECLARE v1 , v2 , v3 , v4, w1 , w2 , w3 , w4 decimal(12,3) DEFAULT 0;
DECLARE r_done INT DEFAULT FALSE;
DECLARE cursor_i CURSOR FOR SELECT TABLE_NAME FROM t_temp;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET r_done = TRUE;


SET @sql_text1 := concat('CREATE TABLE IF NOT EXISTS dy_',replace(m_table,'%','_'),'__dy (TABLE_NAME varchar(22) not null, t_stamp datetime not null, kWh_Export decimal(12,3), kWh_Import decimal(12,3), kvarh_Export decimal(12,3), kvarh_Import decimal(12,3), PRIMARY KEY (TABLE_NAME,t_stamp))');
PREPARE stmt FROM @sql_text1;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP TEMPORARY TABLE IF EXISTS t_temp;
CREATE TEMPORARY TABLE t_temp (TABLE_NAME varchar(22));
SET @sql_text3 := concat('insert into t_temp (select TABLE_NAME	from information_schema.tables where TABLE_NAME like ''', m_table,''' and TABLE_SCHEMA=''mokresh'')');
PREPARE stmt FROM @sql_text3;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

OPEN cursor_i;
read_loop: LOOP
FETCH cursor_i INTO meter_table;
  IF r_done THEN
 LEAVE read_loop;
  END IF;

SET @w1 := 0;
SET @w2 := 0;
SET @w3 := 0;
SET @w4 := 0;
SET @v1 := 0;
SET @v2 := 0;
SET @v3 := 0;
SET @v4 := 0;

SET curdate := DATE_SUB(start_date,INTERVAL 1 DAY);

WHILE curdate <= DATE_ADD(end_date,INTERVAL 1 DAY) DO

SET @sql_text := concat(
 'select p3.kWh_Export + (UNIX_TIMESTAMP(''', curdate, ''' ) - UNIX_TIMESTAMP(pprev.t1)) * (p4.kWh_Export - p3.kWh_Export)/(UNIX_TIMESTAMP(pnext.t2) - UNIX_TIMESTAMP(pprev.t1)), ',
    'p3.kWh_Import + (UNIX_TIMESTAMP(''', curdate, ''' ) - UNIX_TIMESTAMP(pprev.t1)) * (p4.kWh_Import - p3.kWh_Import)/(UNIX_TIMESTAMP(pnext.t2) - UNIX_TIMESTAMP(pprev.t1)), ',
 'p3.kvarh_Export + (UNIX_TIMESTAMP(''', curdate, ''' ) - UNIX_TIMESTAMP(pprev.t1)) * (p4.kvarh_Export - p3.kvarh_Export)/(UNIX_TIMESTAMP(pnext.t2) - UNIX_TIMESTAMP(pprev.t1)), ',
 'p3.kvarh_Import + (UNIX_TIMESTAMP(''', curdate, ''' ) - UNIX_TIMESTAMP(pprev.t1)) * (p4.kvarh_Import - p3.kvarh_Import)/(UNIX_TIMESTAMP(pnext.t2) - UNIX_TIMESTAMP(pprev.t1)) ',
   'into @v1, @v2, @v3, @v4 from ',
 '(SELECT max(p1.t_stamp) as t1 FROM ', meter_table, ' p1 ',
 'where p1.t_stamp< ''', curdate, ''' ',
 'and p1.quality_code=192 ',
 ') pprev ,');

SET @sql_text := concat(@sql_text,'(SELECT min(p2.t_stamp) as t2 FROM ',meter_table, ' p2 ',
 'where p2.t_stamp> ''',curdate, ''' ',
 'and p2.quality_code=192',
 ') pnext ,', meter_table, ' p3, ', meter_table,' p4 ',
 'where p3.t_stamp=pprev.t1 and p4.t_stamp=pnext.t2 limit 1' );
SELECT concat(meter_table,' ',curdate);


PREPARE stmt FROM @sql_text;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

IF curdate > start_date THEN
 SET @sql_text2 := concat('insert into dy_',replace(m_table,'%','_'),'__dy  values(''',meter_table,''' , ''', DATE_SUB(curdate,INTERVAL 1 DAY), ''', ',
       @v1-@w1,',', @v2-@w2,',', @v3-@w3,',', @v4-@w4,
       ') ON DUPLICATE KEY UPDATE ',
       ' kWh_Export=',@v1-@w1,', kWh_Import=', @v2-@w2,', kvarh_Export=', @v3-@w3,', kvarh_Import=', @v4-@w4);

PREPARE stmt FROM @sql_text2;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END IF;

SET @w1 := @v1;
SET @w2 := @v2;
SET @w3 := @v3;
SET @w4 := @v4;

SET curdate := DATE_ADD(curdate,INTERVAL 1 DAY);
END WHILE;

END LOOP;
CLOSE cursor_i;

END
