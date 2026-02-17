>通过php脚本调用存储过程，实现归档

$db_result = $db->query("CALL **SP_SALES_TRADE_LOG_AUTO_FILE()**");
LogUtil::write("日志归档:" . ($db_result ? "success" : "failure," . $db->error_msg()));

reset_alarm(72000);
$db_result = $db->query("CALL **SP_SN_AUTO_FILE()**");
LogUtil::write("SN归档:" . ($db_result ? "success" : "failure," . $db->error_msg()));

reset_alarm(72000);
$db_result = $db->query("CALL **SP_STOCK_SPEC_POSITION_CHANGE_HISTORY_AUTO_FILE()**");
LogUtil::write("货位库存变化自动归档:" . ($db_result ? "success" : "failure," . $db->error_msg()));

reset_alarm(72000);
$db_result = $db->query("CALL **SP_STAT_PERFORMANCE_AUTO_FILE()**");
LogUtil::write("绩效归档:" . ($db_result ? "success" : "failure," . $db->error_msg()));


日志记录：
/data/wms/sync/logs