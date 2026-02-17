
### 业务学习

仓库代替货主发货服务 - 计算费用

费用类型：应付司机 / 应收货主

费用计费方式 ： 自定义公式

自定义公式组成：货品种类数 、货品数量 总重量、 总体积 ==> 四则运算 
计费条件: 仓库 + 货主 + 物流公司

![[Pasted image 20260211160147.png]]



![[Pasted image 20260211160208.png]]

模拟计算-输入数据：货品种类数 、货品数量 总重量、 总体积 + 目的地类型 + 运输模式 + 配载类型

界面信息：
![[Pasted image 20260211160214.png]]
![[Pasted image 20260211160217.png]]
界面参考：
![[Pasted image 20260211160221.png]]


界面信息 ： 搜索、 运费策略信息展示、策略公式 、日志
新建、编辑策略界面—>主要模块：策略信息、计费条件、计费规则、公式模拟

需要翻译内容
C#代码 TransportFeePolicyWindow.cs：
运费策略：
 OnLoad()
 OnClickSearch()
OnClickAddPolicy()
OnChgPolicy()
OnDisabledPolicy()
OnAblePolicy()
JudgeSelectedPolicy()
OnClickDelPolicy()
OnClickTrPolicyList()
OnSwitchBottomTabs()
OnBindTab（）
编辑运费策略：
OnLoad()
OnTypeChanged()
OnSave()
InitDetail()
ParseFormula()
AddElement(）
GetElement()
OnAddElement()
OnAddTransportMode()
OnAddLoadingType()
OnAddDestinationType()
OnClickSaveTemplate()
OnClickSelectData()
OnChangedTemplateList()
OnClickFormulaTest()
OnloadingTypeChanged()
OnMouseDown()
OnClear()
OnElementKeyDown()
OnContainerKeyDown()
OnContainerChar()


cmd方法调用
cfg_common_log_get
tms_transport_fee_policy_query
tms_transport_fee_policy_enable_or_disable
tms_transport_fee_policy_policy_delete
tms_transport_fee_policy_get
tms_transport_fee_formula_imitate
tms_transport_fee_policy_edit



数据库模型
~~~ sql

DROP TABLE IF EXISTS cfg_tms_transport_fee_policy;
CREATE TABLE `cfg_tms_transport_fee_policy` (
  `policy_id` INT(11) NOT NULL AUTO_INCREMENT,
  `warehouse_id` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '仓库',
  `owner_id` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '货主',
  `logistics_id` INT(11) NOT NULL DEFAULT '0' COMMENT '物流公司',
  `policy_name` VARCHAR(40) NOT NULL DEFAULT '' COMMENT '策略名称',
  `type` TINYINT(4) NOT NULL DEFAULT '1' COMMENT '1 应收货主费用 2 应付司机费用',
  `charging_type` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '0 自定义公式',
  `formula` VARCHAR(512) NOT NULL DEFAULT '' COMMENT '公式',
  `is_disabled` TINYINT(1) NOT NULL DEFAULT '0',
  `remark` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注',
  `modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`policy_id`),
  UNIQUE KEY `UNI_cfg_tms_transport_policy_name` (`policy_name`),
  UNIQUE KEY `UNI_cfg_tms_transport_policy` (`warehouse_id`,`owner_id`,`logistics_id`,`type`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='TMS运费策略';

~~~



