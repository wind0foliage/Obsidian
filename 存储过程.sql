-- 存储过程

存储过程定义文件：cmd.txt

sql，table 定义文件： table.SQL

/* 定义变量 */
DECLARE l_int int unsigned default 4000000; 
DECLARE intvalue int unsigned default 300;

/* 变量赋值 */
SELECT prefix,postfix_len into V_Prefix,V_PostfixLen from sys_no_cfg WHERE `key`=P_Key;
这行SQL代码中的INTO是存储过程/函数中的变量赋值语法，用于将查询结果直接赋值给变量。这种语法常见于MySQL、SQL Server和Oracle等数据库的存储过程中。