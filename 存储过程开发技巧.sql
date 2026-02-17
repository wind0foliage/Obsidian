存储过程定义文件：cmd.txt

sql，table 定义文件： table.SQL

/* 定义变量 */
DECLARE l_int int unsigned default 4000000;
DECLARE intvalue int unsigned default 300;

/* 变量赋值 */
SELECT prefix,postfix_len into V_Prefix,V_PostfixLen from sys_no_cfg WHERE `key`=P_Key;
这行SQL代码中的INTO是存储过程/函数中的变量赋值语法，用于将查询结果直接赋值给变量。这种语法常见于MySQL、SQL Server和Oracle等数据库的存储过程中。


存储过程传输 list的过程

DB.Exec("sys_import_tmp", JSON.Stringify(detailParams));
插入临时表
DB.Exec(LogisticsModel.UpdateLogisticsSender, args.printmethon);

cmd.txt
同步脚本：

存储过程开发模板
DROP PROCEDURE IF EXISTS `SP_XXXX`;
DELIMITER //
CREATE PROCEDURE `SP_XXXXX`(IN P_PrintMethod INT(11))
	SQL SECURITY INVOKER
MAIN_LABEL:BEGIN
	DECLARE V_NOT_FOUND, V_Type, V_RecId, V_owner_id, V_warehouse_id INT DEFAULT 0;
	DECLARE V_Query VARCHAR(1024) DEFAULT '';
	DECLARE sender_cursor CURSOR FOR SELECT f1, f2 FROM tmp_xchg WHERE f3 = V_Type ORDER BY rec_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET V_NOT_FOUND = 1;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		RESIGNAL;
	END;

	START TRANSACTION;

	COMMIT;
END//

DELIMITER ;


游标创建模板
DECLARE detail_cursor CURSOR FOR SELECT f1,f2,f3 FROM tmp_xchg;

OPEN order_cursor;
	ORDER_LABEL:LOOP
		SET V_NOT_FOUND = 0;
		FETCH detail_cursor INTO V_RecId, V_DetailInfo, V_Deleted;
		IF V_NOT_FOUND THEN
			SET V_NOT_FOUND = 0;
			LEAVE ORDER_LABEL;
		END IF;

		START TRANSACTION;

		COMMIT;

	END LOOP;
	CLOSE order_cursor;



