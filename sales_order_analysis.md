# 销售订单业务核心分析

## 1. 核心数据表及关系

### 主要数据表

| 表名                     | 描述          | 核心字段                                                                                                               |
| ---------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------ |
| `sales_trade`          | 销售订单主表      | `trade_id`, `trade_no`, `owner_id`, `warehouse_id`, `logistics_id`, `trade_status`, `total_amount`, `goods_amount` |
| `sales_trade_order`    | 销售订单商品明细表   | `rec_id`, `trade_id`, `spec_id`, `num`, `price`, `order_price`, `batch_no`, `is_gift`                              |
| `sales_trade_log`      | 销售订单操作日志表   | `log_id`, `trade_id`, `operator_id`, `type`, `message`, `created`                                                  |
| `sales_trade_ex`       | 销售订单扩展信息表   | `trade_id`, `reserve_v3` (包装来源), 其他扩展字段                                                                            |
| `sales_trade_src_tids` | 销售订单源订单号表   | `trade_no`, `owner_id`, `src_tid`                                                                                  |
| `sales_trade_goods_ex` | 销售订单商品扩展信息表 | `trade_id`, `max_side`, `second_side`, `min_side`                                                                  |
| `his_sales_trade`      | 历史销售订单表（归档） | 与 `sales_trade` 结构类似                                                                                               |

### 表关系

```
sales_trade ──┬── 1:N ── sales_trade_order
              ├── 1:N ── sales_trade_log
              ├── 1:1 ── sales_trade_ex
              ├── 1:N ── sales_trade_src_tids
              └── 1:N ── sales_trade_goods_ex
```

## 2. 关键业务流程

### 数据流动

1. **订单创建**：通过接口或导入创建销售订单，数据插入 `sales_trade` 和 `sales_trade_order` 表
2. **订单审核**：审核通过后，订单状态更新，允许进入后续流程
3. **订单递交**：准备出库，分配物流和货位
4. **出库操作**：拣货 → 验货 → 称重 → 打包 → 发货
5. **订单完成**：订单发货后，状态更新为已完成
6. **订单归档**：长期未操作的订单归档到历史表

### 关键业务流程节点

| 流程节点 | 描述       | 相关操作常量                               | 影响的数据表                                                |
| ---- | -------- | ------------------------------------ | ----------------------------------------------------- |
| 订单创建 | 创建新销售订单  | -                                    | `sales_trade`, `sales_trade_order`, `sales_trade_log` |
| 订单审核 | 审核销售订单   | `Check`                              | `sales_trade`, `sales_trade_log`                      |
| 订单递交 | 准备出库     | -                                    | `sales_trade`, `sales_trade_log`                      |
| 订单拆分 | 拆分销售订单   | `Split`, `SplitCheck`, `SplitCustom` | `sales_trade`, `sales_trade_order`, `sales_trade_log` |
| 订单合并 | 合并销售订单   | `Merge`                              | `sales_trade`, `sales_trade_order`, `sales_trade_log` |
| 物流分配 | 分配物流公司   | `ChangeLogistics`                    | `sales_trade`, `sales_trade_log`                      |
| 货位分配 | 分配商品存储位置 | -                                    | `sales_trade_log`                                     |
| 拣货操作 | 拣货员拣货    | -                                    | `sales_trade_log`                                     |
| 验货操作 | 检查商品     | -                                    | `sales_trade_log`                                     |
| 称重操作 | 称量包裹重量   | -                                    | `sales_trade_log`                                     |
| 打包操作 | 包装商品     | -                                    | `sales_trade_log`                                     |
| 订单发货 | 订单发货     | -                                    | `sales_trade`, `sales_trade_log`                      |
| 订单取消 | 取消销售订单   | `Cancel`                             | `sales_trade`, `sales_trade_log`                      |

### 关键方法接口

从 `SalesTradeModel.cs` 中提取的关键操作：

- `Check`：审核销售订单
- `Split`：拆分销售订单
- `Merge`：合并销售订单
- `Cancel`：取消销售订单
- `ChangeLogistics`：修改销售订单物流
- `ChangeWarehouse`：切换销售订单虚拟仓
- `FreezeOrUnFreeze`：冻结/解冻销售订单
- `Update`：修改销售订单信息
- `RefreshLogistics`：刷新订单物流公司
- `CheckMultiOper`：更改销售订单多级审核

## 3. 数据修改的业务

### 数据修改操作类型

| 操作类型 | 描述 | 影响的数据表 | 相关方法/存储过程 |
|----------|------|--------------|------------------|
| 订单创建 | 新建销售订单 | `sales_trade`, `sales_trade_order`, `sales_trade_log` | - |
| 订单审核 | 审核通过/驳回 | `sales_trade`, `sales_trade_log` | `I_SALES_TRADE_CHECK` |
| 订单拆分 | 拆分订单为多个子单 | `sales_trade`, `sales_trade_order`, `sales_trade_log` | - |
| 订单合并 | 合并多个订单为一个 | `sales_trade`, `sales_trade_order`, `sales_trade_log` | - |
| 物流修改 | 更新订单物流信息 | `sales_trade`, `sales_trade_log` | - |
| 仓库修改 | 切换订单仓库 | `sales_trade`, `sales_trade_log` | - |
| 订单取消 | 取消订单 | `sales_trade`, `sales_trade_log` | - |
| 状态更新 | 更新订单状态 | `sales_trade`, `sales_trade_log` | - |
| 出库操作 | 拣货、验货、称重、打包、发货 | `sales_trade`, `sales_trade_log` | - |
| 订单归档 | 将订单归档到历史表 | `his_sales_trade` | - |

### 数据修改触发条件

1. **用户操作**：通过系统界面进行的各种订单操作
2. **接口调用**：外部系统通过API进行的订单操作
3. **定时任务**：系统定时执行的订单归档等操作
4. **业务规则触发**：例如自动审核、自动分配物流等

## 4. 业务规则与约束

1. **订单状态流转**：订单状态有严格的流转规则，例如未审核的订单不能发货
2. **库存约束**：订单发货数量不能超过库存数量
3. **拆分合并规则**：ERP指定包装订单不能随意拆分
4. **多级审核**：部分订单需要多级审核才能通过
5. **虚拟仓规则**：虚拟仓订单有特殊处理逻辑
6. **日志记录**：所有订单操作都必须记录日志

## 5. 核心业务实体

### 销售订单状态

| 状态值范围 | 描述 |
|------------|------|
| < 10 | 订单创建阶段 |
| 10-25 | 订单审核阶段 |
| 25-55 | 订单处理阶段（递交、拆分、物流分配等） |
| 55-95 | 出库操作阶段（拣货、验货、打包、发货等） |
| ≥ 95 | 订单完成/取消阶段 |

### 操作日志类型

| 类型 | 描述 |
|------|------|
| 5 | 接口下单 |
| 7 | 递交订单 |
| 15 | 取消订单 |
| 20 | 修改货品 |
| 25 | 修改物流 |
| 30 | 修改仓库 |
| 35 | 修改收件人信息 |
| 40 | 修改其他信息 |
| 41 | 拆分订单 |
| 42 | 合并订单 |
| 43 | 标记订单 |
| 44 | 冻结订单 |
| 45 | 解冻订单 |
| 55 | 审核订单 |
| 56 | 分配货位 |
| 60 | 驳回审核 |
| 66 | 创建分拣单/打印批次 |
| 70 | 清除打印取消打印状态 |
| 75 | 标记打印完成 |
| 80 | 出库单签入 |
| 85 | 出库单签出 |
| 95 | 验货操作 |
| 100 | 登记包装 |
| 105 | 称重操作 |
| 110 | 出库操作 |
| 115 | 发货 |
| 116 | 出库并发货 |
| 120 | 驳回验货/称重 |
| 124 | 开始拣货 |
| 125 | 登记拣货员/拣货完成 |
| 126 | 登记拣货出错 |
| 127 | 登记打包员 |
| 130 | 登记监视员 |
| 131 | 开始分拣 |
| 135 | 物流回传 |
| 140 | 回传发货状态到ERP |

## 总结

销售订单业务是WMS系统的核心业务之一，涉及多个数据表和复杂的业务流程。核心流程包括订单创建、审核、递交、出库操作和完成等阶段，每个阶段都有严格的业务规则和数据约束。系统通过详细的日志记录，确保了订单操作的可追溯性和安全性。

理解销售订单业务的核心数据表、关系和流程，对于系统维护、功能扩展和问题排查都具有重要意义。