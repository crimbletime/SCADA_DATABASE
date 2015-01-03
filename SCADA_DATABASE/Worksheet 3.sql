select date(d.t_stamp) as slice,  count(d.kWh_Export) - (select max(f.maxcount) from (select count(*) as maxcount, date(t_stamp) from mokresh.dy_gmahala_bktp___dy group by date(t_stamp) ) f) as quality
FROM mokresh.dy_gmahala_bktp___dy d
group by slice
order by slice;



