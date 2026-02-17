
请求路由目录：
wms_web\src\router
路由文件：
index.ts

路由模板：
~~~ markdown
{

name: 'stockout_b2b_transport_route',
path: 'stockout_b2b_transport_route',
meta: { key: 'stockout_b2b_transport_route', title: '运输路线管理' },
component: () => import('@/pages/tms/TransportRoute/StockOutB2BTransportRoute.vue')

}
~~~

name:路由的唯一标识符，用于路由跳转和引用
path:路由的URL路径，用于浏览器URL匹配
meta：路由的元信息，用于存储额外的数据
component：由对应的Vue组件  -- （主要写的）

接口目录
wms_web\src\model\api

页面目录
wms_web\src\pages

常用组件：
EasyPage 分页页面容器
EasySplitArea 页面分区容器
SearchPanel
SearchCondition
搜索容器
SfMselect多选容器
SfInput 输入框
SearchPanel 表单数据

核心操作
绑定数据
transform="@MyGoodsOwnerName"


翻译函数目录：
wms_web\src\base\Convert.ts

快速开发流程：

页面分类：
一般查询页面 + 详情 + 日志页面
直接参考
src\pages\tms\TransportOrderMgr\TransportOrderMgr.vue

弹窗 ：
showDialog


// 监听单个prop

watch(() => props.TMSDriverHisDetail, (newVal, oldVal) => {

    console.log('props has changed:', newVal, oldVal)

})