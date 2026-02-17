### 业务学习：
术语：
TMS：运输管理系统
OMS：订单管理系统
运单：WMS系统中用来记录运输信息的单据
物流单号：实际的物流公司使用的物流单号

旺店通运单管理介绍：https://zsxj.yuque.com/flghe4/apadhy/eoh3yu01teft65rp


核心流程：
![[Pasted image 20260211160114.png]]

界面入口：
![[Pasted image 20260211160121.png]]

业务场景：B2B业务使用

界面信息：搜索框、运单信息展示、底部页签（运单详情、日志）

待翻译内容：
C # 方法：
OnLoad()
OnClickSearch()
OnBottomTabsSwitch()
OnBindTab()
OnClickTransportOrderList()

cmd方法：
transport_order_query
transport_order_log_get_by_transportid
transport_order_detail_get_by_transportid


数据库模型：
主表：tms_trade

~~~mysql
DROP TABLE IF EXISTS `tms_trade`;
CREATE TABLE `tms_trade` (
  `trade_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `origin_owner_id` INT(11) NOT NULL DEFAULT '0' COMMENT '原货主，如果未使用虚拟货主功能，则该值为0',
  `owner_id` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '货主',
  `warehouse_id` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '仓库',
  `trade_sys_no` VARCHAR(50) NOT NULL COMMENT 'TMS单号',
  `trade_no` VARCHAR(50) NOT NULL DEFAULT '' COMMENT 'OMS的订单编号',
  `src_tids` VARCHAR(256) NOT NULL DEFAULT '' COMMENT '原始单号，如果有多个，以\\",\\"分隔\\n过长将被裁剪',
  `source_id` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '订单来源。0：手工导入； 大于0：接口下发',
  `status` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '状态5已取消 10待递交 30待审核 55已审核 90部分发货 92部分完成 95已完成',
  `push_status` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '推送状态 0未推送 1 已推送',
  `loading_type` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '配载类型 1整车 2零担',
  `transport_mode` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '运输模式 1快运 2自提 3城配 4干线 5支线',
  `type` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '出库类型 0销售出库 1出库业务单 2采购退货单',
  `sub_type` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '出库子类型 0 正常订单 1换货订单 2补发订单 3调拨出库 4其它出库 5普通出库 7生产出库 8采购退货出库',
  `goods_count` DECIMAL(19,4) NOT NULL DEFAULT '0.0000',
  `goods_type_count` SMALLINT(6) NOT NULL DEFAULT '0',
  `calc_weight` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估重量',
  `calc_volume` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估体积',
  `calc_box_weight` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估箱重量',
  `calc_box_volume` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估箱体积',
  `provider_no` VARCHAR(40) NOT NULL DEFAULT '' COMMENT '供应商编号',
  `provider_name` VARCHAR(128) NOT NULL DEFAULT '' COMMENT '供应商',
  `sender_name` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '发件人姓名',
  `sender_telno` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '发件人固话',
  `sender_mobile` VARCHAR(40) DEFAULT '' COMMENT '发件人手机号',
  `sender_address` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '发件人地址',
  `receiver_company` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '收件公司 销售订单对应客户网名',
  `receiver_name` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '收件人姓名',
  `receiver_telno` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '联系人固话',
  `receiver_mobile` VARCHAR(1024) DEFAULT '' COMMENT '收货人手机号',
  `receiver_country` INT(11) NOT NULL DEFAULT '0' COMMENT '收货人国家',
  `receiver_province` INT(11) NOT NULL DEFAULT '0' COMMENT '收货人省',
  `receiver_city` INT(11) NOT NULL DEFAULT '0' COMMENT '收货人市',
  `receiver_district` INT(11) NOT NULL DEFAULT '0' COMMENT '收货人区',
  `receiver_area` VARCHAR(128) NOT NULL DEFAULT '' COMMENT '省市区空格分隔',
  `receiver_address` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '收件人地址',
  `logistics_code` VARCHAR(40) NOT NULL DEFAULT '' COMMENT 'OMS指定的物流公司编码,WMS不更新',
  `logistics_id` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT 'OMS指定的物流公司id',
  `logistics_no` VARCHAR(40) NOT NULL DEFAULT '' COMMENT 'OMS指定的预置物流单号,WMS不更新',
  `platform_id` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '平台,不是必要',
  `platform_name` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '平台名',
  `shop_no` VARCHAR(40) NOT NULL DEFAULT '' COMMENT '店铺编号',
  `shop_name` VARCHAR(100) NOT NULL DEFAULT '' COMMENT '店铺名称',
  `delivery_term` TINYINT(4) NOT NULL DEFAULT '1' COMMENT '发货条件 1款到发货 2货到付款(包含部分货到付款) 3分期付款--(冗余字段) 4国补订单',
  `buyer_message` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '客户备注',
  `cs_remark` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '客服备注',
  `print_remark` VARCHAR(500) NOT NULL DEFAULT '' COMMENT '打印备注',
  `goods_amount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '货款总额（未扣除优惠）',
  `post_amount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '邮费',
  `calc_post_amount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估运费',
  `discount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '优惠金额',
  `cod_amount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '货到付款金额,包含ext_cod_fee',
  `ext_cod_fee` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT 'COD服务费',
  `paid` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '已付金额',
  `total_amount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '订单总金额(订单总金额=应收金额+已收金额=商品总金额-订单折扣金额+快递费用)',
  `invoice_type` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '发票类别0不需要1普通发票2增值税发票3电子发票',
  `invoice_title` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '发票抬头',
  `invoice_content` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '发票内容',
  `invoice_amount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '发票总金额',
  `pay_time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '支付时间',
  `calc_delivery_time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '预计到货时间',
  `delivery_time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '要求到货时间',
  `delivery_start_time` TIME NOT NULL DEFAULT '00:00:00' COMMENT '投递时间范围要求,开始时间',
  `delivery_end_time` TIME NOT NULL DEFAULT '00:00:00' COMMENT '投递时间范围要求,结束时间',
  `trade_time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '下单时间',
  `oaid` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '奇门接口的 oaid 加密的收件人信息',
  `goods_aggregate` VARCHAR(50) NOT NULL DEFAULT '货品聚合码',
  `sending_num` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '待发货量',
  `sent_num` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '已发货量',
  `flag_id` INT(11) NOT NULL DEFAULT '0' COMMENT '标记',
  `freeze_reason` smallint(6) NOT NULL DEFAULT '0' COMMENT '冻结原因',
  `is_payment_collection` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否代收货款',
  `payment_type` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '代收货款类型 0跟随订单金额 1自定义输入',
  `payment_amount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '应收货款',
  `remark` VARCHAR(255) NOT NULL DEFAULT '',
  `prop1` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '自字段字段1',
  `prop2` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '自字义字段2',
  `prop3` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '自字义字段3',
  `prop4` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '自字段字段4',
  `prop5` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '自字义字段5',
  `prop6` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '自字义字段6',
  `oms_order_type` varchar(40) NOT NULL DEFAULT '' COMMENT 'oms单据类型',
  `product_label_pdf_url` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '平台货品标签',
  `box_pdf_url` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '平台箱唛',
  `business_type` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '业务类型',
  `print_data` LONGTEXT NOT NULL COMMENT '第三方打印组件信息(接口推送)',
  `origin_num` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '下单数量',
  `modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`trade_id`),
  UNIQUE KEY `UK_tms_trade_no` (`trade_no`,`owner_id`,`type`,`origin_owner_id`),
  UNIQUE KEY `UX_tms_trade_sys_no` (`trade_sys_no`),
  KEY `IX_tms_trade_trade_status` (`status`,`warehouse_id`,`owner_id`),
  KEY `IX_tms_trade_owner_warehouse` (`owner_id`,`warehouse_id`,`status`),
  KEY `IX_tms_trade_delivery_time` (`delivery_time`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='TMS订单';
~~~

tms_trade_detail ：tms 订单细节表

~~~mysql
DROP TABLE IF EXISTS `tms_trade_detail`;
CREATE TABLE `tms_trade_detail` (
  `rec_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `trade_id` BIGINT(20) NOT NULL,
  `oms_oid` VARCHAR(50) NOT NULL DEFAULT '' COMMENT 'oms系统子单号',
  `num` DECIMAL(19,4) NOT NULL COMMENT '数量',
  `spec_id` INT(11) NOT NULL DEFAULT '0',
  `oms_spec_no` VARCHAR(50) NOT NULL COMMENT 'oms商家编码',
  `oms_goods_name` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'oms货品名称',
  `production_date` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '生产日期',
  `expire_date` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '有效期',
  `batch_id` INT(11) NOT NULL DEFAULT '0',
  `batch_no` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '批次',
  `sending_num` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '待发货量',
  `sent_num` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '已发货量',
  `defect` TINYINT(4) NOT NULL DEFAULT '0',
  `is_gift` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否是赠品',
  `order_price` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '实际成交价',
  `price` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '标价',
  `discount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '单件折扣金额',
  `remark` VARCHAR(1024) NOT NULL DEFAULT '',
  `reserved1` TINYINT(4) NOT NULL DEFAULT '0',
  `reserved2` VARCHAR(50) NOT NULL DEFAULT '',
  `reserved3` INT(11) NOT NULL DEFAULT '0',
  `reserved4` VARCHAR(50) NOT NULL DEFAULT '',
  `reserved6` DECIMAL(19,4) NOT NULL DEFAULT '0.0000',
  `origin_num` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '下单数量',
  `modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`rec_id`),
  KEY `I_tms_trade_detail_trade_id` (`trade_id`),
  KEY `I_tms_trade_detail_spec_id` (`spec_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='TMS订单货品详情';
~~~


日志表：tms_trade_log

~~~mysql
DROP TABLE IF EXISTS `tms_trade_log`;
CREATE TABLE `tms_trade_log` (
  `rec_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `trade_id` BIGINT(20) NOT NULL,
  `order_id` BIGINT(20) NOT NULL DEFAULT '0' COMMENT '子单id',
  `operator_id` INT(11) NOT NULL,
  `type` SMALLINT(6) NOT NULL COMMENT '操作类型，具体见tms订单操作日志',
  `data` INT(11) NOT NULL DEFAULT '0' COMMENT '用于打印状态和驳回处理',
  `message` VARCHAR(1024) NOT NULL DEFAULT '',
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rec_id`),
  KEY `IX_tms_trade_log_trade_id` (`trade_id`),
  KEY `IX_tms_trade_log_order_id` (`order_id`),
  KEY `IX_tms_trade_log` (`type`,`created`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='TMS订单日志';
~~~

TMS 原始单号：tms_trade_src_tids

~~~mysql
DROP TABLE IF EXISTS `tms_trade_src_tids`; 
CREATE TABLE `tms_trade_src_tids` (
  `rec_id` INT(11) NOT NULL AUTO_INCREMENT,
  `trade_id` BIGINT(20) NOT NULL,
  `src_tid` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '原始单号',
  `created` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '创建时间',
  PRIMARY KEY (`rec_id`),
  UNIQUE INDEX `UX_src_tids` (`trade_id`, `src_tid`),
  KEY `IX_b2b_trade_src_tid` (`src_tid`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='TMS原始单号表（方便查询）';
~~~

tms子单：tms_sub_trade
~~~mysql
DROP TABLE IF EXISTS `tms_sub_trade`;
CREATE TABLE `tms_sub_trade` (
  `sub_trade_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `sub_trade_no` VARCHAR(50) NOT NULL COMMENT '子单号',
  `trade_id` BIGINT(20) NOT NULL DEFAULT '0' COMMENT '原单ID',
  `dispatch_id` INT(11) NOT NULL DEFAULT '0' COMMENT '调度单ID',
  `source_id` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '子单来源 0 TMS订单 1 多车运输拆分 2 中转运输拆分',
  `status` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '状态 5 已取消 30 待审核 55 已审核 92部分完成 95 已完成',
  `goods_count` DECIMAL(19,4) NOT NULL DEFAULT '0.0000',
  `goods_type_count` SMALLINT(6) NOT NULL DEFAULT '0',
  `calc_weight` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估重量',
  `calc_volume` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估体积',
  `calc_box_weight` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估箱重量',
  `calc_box_volume` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估箱体积',
  `logistics_id` INT(11) NOT NULL DEFAULT '0' COMMENT '物流公司',
  `logistics_no` VARCHAR(40) NOT NULL DEFAULT '' COMMENT '物流单号',
  `sender_name` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '发件人姓名',
  `sender_telno` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '发件人固话',
  `sender_mobile` VARCHAR(40) DEFAULT '' COMMENT '发件人手机号',
  `sender_address` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '发件人地址',
  `receiver_address` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '收件人地址',
  `receiver_company` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '收件公司 销售订单对应客户网名',
  `receiver_name` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '收件人姓名',
  `receiver_telno` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '联系人固话',
  `receiver_mobile` VARCHAR(1024) DEFAULT '' COMMENT '收货人手机号',
  `receiver_country` INT(11) NOT NULL DEFAULT '0' COMMENT '收货人国家',
  `receiver_province` INT(11) NOT NULL DEFAULT '0' COMMENT '收货人省',
  `receiver_city` INT(11) NOT NULL DEFAULT '0' COMMENT '收货人市',
  `receiver_district` INT(11) NOT NULL DEFAULT '0' COMMENT '收货人区',
  `receiver_area` VARCHAR(128) NOT NULL DEFAULT '' COMMENT '省市区空格分隔',
  `origin_sub_trade_id` BIGINT(20) NOT NULL COMMENT '初始子单ID',
  `origin_sub_trade_no` VARCHAR(50) NOT NULL COMMENT '初始子单号',
  `upper_sub_trade_id` BIGINT(20) NOT NULL COMMENT '上层子单ID',
  `upper_sub_trade_no` VARCHAR(50) NOT NULL COMMENT '上层子单号',
  `delivery_type` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '送货方式 1仅送货 2送货+卸货',
  `signing_status` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '签收状态 0等待配送 1已到达 2已签收 3部分签收 4已拒签 —— 已不用',
  `dispatch_status` INT(11) NOT NULL DEFAULT '0' COMMENT '调度状态 0 待调度 1 调度中 2 调度完成 3 无需调度',
  `transport_status` INT(11) NOT NULL DEFAULT '4' COMMENT '运输状态 0 等待配送 1 部分签收 2 已签收 3 已拒签 4 待出库 5 已到达 6 派送不成功',
  `abnormal_info` TEXT NOT NULL COMMENT '异常情况',
  `loading_type` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '配载类型 1整车 2零担',
  `transport_mode` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '运输模式 1快运 2自提 3城配 4干线 5支线',
  `transport_sequence` INT(11) NOT NULL DEFAULT 0 COMMENT '运输顺序',
  `depart_time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '发车时间',
  `clock_in_time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '到达打卡时间',
  `clock_in_mileage` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '到达打卡里程',
  `signer` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '签收人',
  `signing_time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '签收时间',
  `calc_consign_time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '预计发货时间',
  `delivery_time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '要求到货时间',
  `stockout_no` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '出库单号',
  `is_payment_collection` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否代收货款',
  `is_delivery_timeout` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否送货超时',
  `is_stay_timeout` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否停留超时',
  `payment_type` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '代收货款类型 0跟随订单金额 1自定义输入',
  `payment_amount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '应收货款',
  `calc_post_amount` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '预估运费',
  `destination_type` SMALLINT(6) NOT NULL DEFAULT '0' COMMENT '目的地类型 0 终点地 1 运输地',
  `flag_id` INT(11) NOT NULL DEFAULT '0' COMMENT '标记',
  `origin_num` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '下单数量',
  `remark` VARCHAR(255) NOT NULL DEFAULT '',
  `modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`sub_trade_id`),
  UNIQUE KEY `UX_tms_sub_trade_noo` (`sub_trade_no`),
  KEY `IX_tms_sub_trade` (`trade_id`),
  KEY `IX_tms_sub_dispatch` (`dispatch_id`),
  KEY `IX_tms_sub_upper` (`upper_sub_trade_id`),
  KEY `IX_tms_sub_delivery_time` (`delivery_time`),
  KEY `IX_tms_sub_trade_status` (`status`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='TMS子单';
~~~

TMS子订单货品详情 ：tms_sub_trade_detail

~~~mysql
DROP TABLE IF EXISTS `tms_sub_trade_detail`;
CREATE TABLE `tms_sub_trade_detail` (
  `rec_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `sub_trade_id` BIGINT(20) NOT NULL,
	  `oms_oid` VARCHAR(50) NOT NULL DEFAULT '' COMMENT 'oms系统子单号',
  `num` DECIMAL(19,4) NOT NULL COMMENT '数量',
  `spec_id` INT(11) NOT NULL DEFAULT '0',
  `production_date` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '生产日期',
  `expire_date` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '有效期',
  `batch_id` INT(11) NOT NULL DEFAULT '0',
  `batch_no` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '批次',
  `defect` TINYINT(4) NOT NULL DEFAULT '0',
  `origin_num` DECIMAL(19,4) NOT NULL DEFAULT '0.0000' COMMENT '下单数量',
  `remark` VARCHAR(1024) NOT NULL DEFAULT '',
  `modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`rec_id`),
  KEY `I_tms_sub_trade_detail_sub_trade_id` (`sub_trade_id`),
  KEY `I_tms_sub_trade_detail_spec_id` (`spec_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='TMS子订单货品详情';
~~~

TMS子订单打卡记录：tms_sub_trade_punch_clock
运输节点打卡
~~~mysql
DROP TABLE IF EXISTS `tms_sub_trade_punch_clock`;
CREATE TABLE `tms_sub_trade_punch_clock` (
  `rec_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `sub_trade_id` BIGINT(20) NOT NULL,
  `longitude` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '经度',
  `latitude` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '纬度',
  `address` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '打卡地址',
  `img_url` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '图片地址',
  `created` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`rec_id`),
  KEY `I_tms_sub_trade_punch_clock_sub_trade_id` (`sub_trade_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='TMS子订单打卡记录';
~~~

