## Check table fragmentation in Oracle
## Fragmentation is caused in table when we do update, delete operation within the table which make the space available in between the table which lead to fragmentation. The space is available with table and table size grow even it has less data in its data blocks. For checking fragmentation we have following queries which will help to check fragmentation in between tables. If fragmentation is large in large size table it will lead to performance degradation also.

## Check top 25 fragmented table in Schema
## Enter schema name inwhich you find top 25 fragmented tables.

SQL> select * from (
select owner,table_name,round((blocks*8),2) "size (kb)" ,
round((num_rows*avg_row_len/1024),2) "actual_data (kb)",
(round((blocks*8),2) - round((num_rows*avg_row_len/1024),2)) "wasted_space (kb)", ((round((blocks * 8), 2) - round((num_rows * avg_row_len / 1024), 2)) /
round((blocks * 8), 2)) * 100 - 10 "reclaimable space % "
from dba_tables
where owner in ('&SCHEMA_NAME' ) and (round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
order by 5 desc ) where rownum < 25;

## Check in percentage of table fragmentation

SQL> select table_name,avg_row_len,round(((blocks*16/1024)),2)||'MB' "TOTAL_SIZE",
round((num_rows*avg_row_len/1024/1024),2)||'Mb' "ACTUAL_SIZE",
round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "FRAGMENTED_SPACE",
(round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
from all_tables WHERE table_name='&TABLE_NAME';

## Check the physical size of tables occupied in datafiles

SQL> Select table_name, round((blocks*8)/1024,2)||'MB' "size" from user_tables where table_name = '&TABLE_NAME';

SQL> Select table_name, round((blocks*8)/1024,2)||'MB' "size" from dba_tables where table_name = '&TABLE_NAME' and owner='&OWNER';

## Check the actual size of table data present in it

SQL> select table_name, round((num_rows*avg_row_len/1024/1024),2)||'MB' "size" from user_tables  where table_name = '&TABLE_NAME';

SQL> select table_name, round((num_rows*avg_row_len/1024/1024),2)||'MB' "size" from dba_tables where table_name = '&TABLE_NAME' and owner='&OWNER';

