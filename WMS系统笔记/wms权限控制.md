
权限组
SELECT * FROM dict_print_field_group;

权限字段
SELECT * FROM dict_print_field;

权限
SELECT * FROM dict_rights WHERE right_code = 'setting_print';
sql权限控制
SELECT * FROM dict_rights_sql WHERE right_code = 'setting_print';
员工表
SELECT * FROM hr_employee LIMIT 1;

SELECT * FROM hr_employee WHERE employee_no = 'zc';
员工字段权限控制
SELECT field_rights FROM hr_employee WHERE employee_id = 627;

权限控制字段函数
FN_FIELD_RIGHT