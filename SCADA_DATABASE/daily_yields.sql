CREATE EVENT mokresh.daily_yields
ON SCHEDULE
EVERY "1" DAY
STARTS '2015-01-03 02:01:34'

ON COMPLETION PRESERVE
ENABLE
COMMENT ''
DO
BEGIN

CALL daily_production('gmahala_bktp%',DATE_SUB(CURDATE(), INTERVAL 1 DAY), DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);
CALL daily_production('meter_breznik',DATE_SUB(CURDATE(), INTERVAL 1 DAY),DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);

CALL daily_production('meter_pcs%',DATE_SUB(CURDATE(), INTERVAL 1 DAY), DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);

CALL daily_production('sliven_bktp%_mv',DATE_SUB(CURDATE(), INTERVAL 1 DAY),DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);

CALL daily_production('sredets_bktp%_mv', DATE_SUB(CURDATE(), INTERVAL 1 DAY),DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);
CALL daily_production('sredets_bktp%_lv',DATE_SUB(CURDATE(), INTERVAL 1 DAY),DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);
CALL daily_production('studenobuche_bktp%_mv',DATE_SUB(CURDATE(), INTERVAL 1 DAY),DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);

CALL daily_production('tizba_bktp1_lv',DATE_SUB(CURDATE(), INTERVAL 1 DAY),DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);

CALL daily_production('vdrum_%th',DATE_SUB(CURDATE(), INTERVAL 1 DAY), DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);

CALL daily_production('yerusalimovo_bktp%_mv',DATE_SUB(CURDATE(), INTERVAL 1 DAY),DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);
CALL daily_production('yerusalimovo_bktp%_lv',DATE_SUB(CURDATE(), INTERVAL 1 DAY),DATE_SUB(CURDATE(), INTERVAL 1 DAY), @ret);
END