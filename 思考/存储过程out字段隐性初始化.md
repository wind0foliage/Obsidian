![[Pasted image 20251227160333.png]]
环境验证结果，**触发器报错**


Ai 查询结果

```markdown

你提出的问题非常典型，涉及 **MySQL 存储过程中变量作用域、OUT 参数传递机制** 以及 **错误处理逻辑**。我们来一步步分析：

---

### ✅ 问题总结

1. **在 `I_DL_DECIDE_LOGISTICS_FEE_BY_NEW_POLICY` 中未声明 `V_ShipWeightRoundUp`，但调用 `CALL SP_UTILS_GET_CFG(..., V_ShipWeightRoundUp, ...)` 却不报错**；
2. **单独执行 `CALL SP_UTILS_GET_CFG('shipping_weight_round_up', @x, 0);` 是正常的，但如果你写成 `CALL SP_UTILS_GET_CFG('...', V_ShipWeightRoundUp, 0);`（在外部）会报错**；
3. 你疑惑：**为什么过程内部能“隐式”使用未声明的变量？**

---

## 🔍 根本原因：MySQL 允许在 CALL 中“隐式创建”局部变量（仅限 OUT/INOUT 参数）

### 📌 关键机制说明

在 MySQL 的存储过程中：

- 当你调用一个带有 **OUT 或 INOUT 参数** 的存储过程时，**传入的参数名不需要预先 DECLARE**。
- MySQL 会 **自动将其视为当前作用域下的局部变量**，并在调用时为其分配空间。
- 这是 **合法行为**，**不会报错**。

> ✅ 官方文档依据（MySQL 8.0）：
> 
> > “For OUT or INOUT parameters, the variable passed does not need to be declared in advance within the calling routine; MySQL will treat it as a local variable.”

所以，在你的主存储过程中：
```md

`````

```sql
CALL SP_UTILS_GET_CFG('shipping_weight_round_up', V_ShipWeightRoundUp, 0);
```


虽然你没有写：

```sql
DECLARE V_ShipWeightRoundUp INT DEFAULT 0;
```

但因为 `V_ShipWeightRoundUp` 是作为 **OUT 参数** 传给 `SP_UTILS_GET_CFG` 的，**MySQL 自动将其当作一个局部 INT 变量创建并初始化为 NULL**，然后由被调用过程赋值。

因此：**不报错是正常且符合预期的行为**。

---


Ai 结论验证：
测试代码：
~~~sql

DELIMITER //

-- 测试 OUT 参数的隐式变量创建
CREATE PROCEDURE test_out_implicit()
BEGIN
    -- 注意：没有声明 V_Result！
    CALL test_set_value(42, V_Result);  -- V_Result 未声明
    
    -- 使用之前作为 OUT 参数传递的变量
    SELECT V_Result;  -- 这会成功！
END//

CREATE PROCEDURE test_set_value(IN p_in INT, OUT p_out INT)
BEGIN
    SET p_out = p_in * 2;
END//

DELIMITER ;

CALL test_out_implicit();  -- 输出 84
~~~

未验证成功


SQL错误（1414）：OUT or INOUT argument 1 for routine d_wms_test.test_out_proc is not a variable or NEW pseudo-variable in BEFORE trigger 执行CALL test_implicit_var(); 报错

执行版本 Mysql8.0
猜测：Mysql5.5 合法

