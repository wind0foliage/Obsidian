~~~
LATEST DETECTED DEADLOCK
------------------------
2026-01-02 10:45:42 7f5918e09700
*** (1) TRANSACTION:
TRANSACTION 631306645166, ACTIVE 0 sec inserting
mysql tables in use 1, locked 1
LOCK WAIT 32 lock struct(s), heap size 6544, 24 row lock(s), undo log entries 4
MySQL thread id 352922965, OS thread handle 0x7f5919b71700, query id 2422566673580 172.17.13.89 root update
INSERT INTO stockout_order_detail_position(stockout_order_detail_id, stock_spec_detail_id, position_id, batch_id, position_no, batch_no, expire_date, num, stockin_detail_id, defect, owner_id, created)
						VALUES(V_RecId, V_RecId2, V_PositionId, V_BatchId, V_PositionNo, V_BatchNo, V_ExpireDate, V_Num, V_StockinDetailId, V_bDefect, V_OwnerId, NOW())
*** (1) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 6911925 page no 55266 n bits 296 index `FK_stockout_order_detail_position_id` of table `d_lshzp03_wms`.`stockout_order_detail_position` trx id 631306645166 lock_mode X insert intention waiting
Record lock, heap no 1 PHYSICAL RECORD: n_fields 1; compact format; info bits 0
 0: len 8; hex 73757072656d756d; asc supremum;;

*** (2) TRANSACTION:
TRANSACTION 631306645152, ACTIVE 0 sec inserting
mysql tables in use 1, locked 1
33 lock struct(s), heap size 6544, 29 row lock(s), undo log entries 4
MySQL thread id 352926464, OS thread handle 0x7f5918e09700, query id 2422566673620 172.17.13.89 root update
INSERT INTO stockout_order_detail_position(stockout_order_detail_id, stock_spec_detail_id, position_id, batch_id, position_no, batch_no, expire_date, num, stockin_detail_id, defect, owner_id, created)
						VALUES(V_RecId, V_RecId2, V_PositionId, V_BatchId, V_PositionNo, V_BatchNo, V_ExpireDate, V_Num, V_StockinDetailId, V_bDefect, V_OwnerId, NOW())
*** (2) HOLDS THE LOCK(S):
RECORD LOCKS space id 6911925 page no 55266 n bits 296 index `FK_stockout_order_detail_position_id` of table `d_lshzp03_wms`.`stockout_order_detail_position` trx id 631306645152 lock mode S
Record lock, heap no 1 PHYSICAL RECORD: n_fields 1; compact format; info bits 0
 0: len 8; hex 73757072656d756d; asc supremum;;

*** (2) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 6911925 page no 55266 n bits 296 index `FK_stockout_order_detail_position_id` of table `d_lshzp03_wms`.`stockout_order_detail_position` trx id 631306645152 lock_mode X insert intention waiting
Record lock, heap no 1 PHYSICAL RECORD: n_fields 1; compact format; info bits 0
 0: len 8; hex 73757072656d756d; asc supremum;;

*** WE ROLL BACK TRANSACTION (1)
------------

~~~


死锁问题定位排查：
死锁信息来源：
1. 后台管理系统，研发专区 -> 死锁信息
2.  服务器 数据库 查看方法：
show processlist 查看进程
查看正在锁的事务
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS;
查看等待锁的事务
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCK_WAITS;
kill id 杀死id

![[Pasted image 20260110123235.png]]

死锁原因：
- 事务(1)请求顺序：先`FK_stockout_order_detail_position_id` → 再`FK_stockout_order_detail_id`
- - 事务(2)请求顺序：先`FK_stockout_order_detail_id` → 再`FK_stockout_order_detail_position_id`

当事务(1)请求`FK_stockout_order_detail_position_id`索引的X锁时，事务(2)已持有该索引的S锁；而事务(2)正在等待`FK_stockout_order_detail_id`索引的X锁，这个锁可能被事务(1)持有或正在等待。这就形成了一个**循环等待**，导致死锁。


解决方案：


