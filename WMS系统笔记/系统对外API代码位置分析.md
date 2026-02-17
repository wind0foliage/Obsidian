# 系统对外API代码位置分析

## 概述

当前系统对外暴露的API主要通过 **HTTP服务器** 实现，支持两种实现方式：
1. **C# 实现** - 通过 `HttpServer` 和 `HttpConnection` 类
2. **Squirrel脚本实现** - 通过 Squirrel 脚本语言

## 1. HTTP服务器核心代码

### 1.1 C# HTTP服务器封装

**文件位置：** `WdtWMS\csharp\CommonUtil\HttpServer.cs`

**核心类：**
- `HttpServer` - HTTP服务器类
- `HttpConnection` - HTTP连接处理类

**关键方法：**
```csharp
public class HttpServer : IDisposable
{
    // 打开HTTP服务器，监听指定端口
    public void Open(int port, string host, string connection, Window owner);
    
    // 关闭HTTP服务器
    public void Close();
    
    // 获取当前端口号
    public int Port { get; }
    
    // 获取连接数
    public int ConnectorSize { get; }
}

public class HttpConnection : IDisposable
{
    // 构造函数，接收连接对象
    public HttpConnection(object connect);
    
    // 响应HTTP请求（需要在子类中实现）
    public void Response(string content, string contentFormat);
    
    // 发送消息
    public void Send(string message);
    
    // 关闭连接
    public void Close();
}
```

### 1.2 C++ HTTP服务器实现

**文件位置：** `WdtWMS\service\sq\sq_httpserver.cpp`

**核心类：**
- `CHttpServer` - C++ HTTP服务器实现
- `CHttpConnection` - C++ HTTP连接处理实现

**关键功能：**
- HTTP请求解析（使用 `http_parser`）
- 请求路由到 Squirrel 脚本或 C# 代码
- 支持 GET、POST 等HTTP方法
- 解析URL、查询参数、请求头、请求体

### 1.3 C# 与 C++ 桥接

**文件位置：** `WdtWMS\service\clr\clr_utils.cpp`

**关键函数：**
- `HttpServer_Open()` - 打开HTTP服务器
- `HttpConnection_OnRecv()` - 处理HTTP请求接收

## 2. API接口实现示例

### 2.1 PDA箱码打印API（C#实现）

**文件位置：** `WdtWMS\csharp\WdtWMS.Control\Stock\StockBarcodePrint\StockPdaBoxcodePrintWindow.cs`

**实现方式：**
```csharp
// 1. 定义HTTP连接处理类
class PdaBoxcodeConnection : HttpConnection
{
    public PdaBoxcodeConnection(object connect) : base(connect) { }
    
    // 处理HTTP请求
    void OnRecv(object message, object context)
    {
        Dictionary<string, object> diMessage = (Dictionary<string, object>)message;
        StockPdaBoxcodePrintWindow pdaPrint = (StockPdaBoxcodePrintWindow)context;
        
        if (diMessage.ContainsKey("query"))
        {
            Dictionary<string, object> query = (Dictionary<string, object>)diMessage["query"];
            string jsonQuery = JSON.Stringify(query);
            
            // 处理业务逻辑
            string responseMessage = pdaPrint.PrintBoxcodeList(jsonQuery);
            
            // 构造响应
            Dictionary<string, object> response = new Dictionary<string, object> 
            { 
                { "code", 0 }, 
                { "message", "打印成功" }, 
                { "info", "打印成功" } 
            };
            
            var contentFormat = new Dictionary<string, object> 
            { 
                { "type", "text/plain; charset=utf-8" } 
            };
            
            // 返回响应
            Response(JSON.Stringify(response), JSON.Stringify(contentFormat));
        }
    }
}

// 2. 启动HTTP服务器
void OpenPort()
{
    httpServer = new HttpServer();
    httpServer.Open(port, ip, default(PdaBoxcodeConnection), this);
}
```

**API接口说明：**
- **URL格式：** `http://{ip}:{port}/?boxcode={boxcode}&warehouse_id={warehouse_id}`
- **请求方法：** GET
- **响应格式：** JSON
  ```json
  {
    "code": 0,
    "message": "打印成功",
    "info": "打印成功"
  }
  ```

### 2.2 Squirrel脚本实现示例

**文件位置：** `WdtWMS\sq_code\common.nut` 和 `WdtWMS\sq_code\init_merge.nut`

**示例代码（已注释）：**
```squirrel
class MyWebConn extends HttpConnection
{
    function OnRecv(req)
    {
        Response("Hello", {"version":"1.0", "type":"text/plain"});
    }
};

http <- HttpServer();
http.Open("127.0.0.1", 8080, MyWebConn);
```

## 3. WebSocket API

### 3.1 WebSocket服务器

**文件位置：** `WdtWMS\csharp\CommonUtil\WebSocketUtils.cs`

**核心类：**
```csharp
public class WebSocketUtils
{
    public class Server
    {
        // 启动WebSocket服务器
        public Server(string ip, int serverPort);
        
        // 消息处理回调
        public Delegate handler;
        
        // 消息验证回调
        public Func<string, string> checkReceiveMsgHandler;
        
        // 启动服务器
        public void Start();
    }
}
```

### 3.2 远程打印WebSocket API

**文件位置：** `WdtWMS\csharp-ext\RemotePrint\MyClass.cs`

**实现方式：**
```csharp
webSocketServer = new WebSocketUtils.Server("127.0.0.1", LocalConfig.RemotePrintPort.ToInteger())
{
    handler = (Action<string>)ExecuteCommand,
    checkReceiveMsgHandler = CheckCommand
};
webSocketServer.Start();
```

**API说明：**
- **协议：** WebSocket
- **地址：** `ws://127.0.0.1:{port}`
- **消息格式：** JSON
  ```json
  {
    "requestId": "xxx",
    "command": "..."
  }
  ```

## 4. 其他API相关代码

### 4.1 外部API调用（客户端）

**文件位置：** `WdtWMS\csharp\WdtWMS.Control\Common\StatClient.cs`

**功能：** 作为客户端调用外部API，不是对外暴露的API

**关键类：**
- `StatClient` - 统计客户端，调用外部统计API
- `WebClient` - Web客户端，调用Web后端API

### 4.2 揽件接口（DeliveryApi）

**文件位置：** `WdtWMS\csharp-ext\DeliveryApi\MyClass.cs`

**说明：** 这是一个扩展模块，用于管理揽件接口的配置和日志，不是对外暴露的API实现。

## 5. API实现架构

### 5.1 请求处理流程

```
HTTP请求
  ↓
CHttpServer::OnAccept (C++)
  ↓
创建 CHttpConnection (C++)
  ↓
CHttpConnection::OnRecv (C++)
  ↓
解析HTTP请求（method, url, query, headers, body）
  ↓
路由到处理类：
  - Squirrel脚本：调用 Squirrel 的 OnRecv 方法
  - C#代码：调用 C# 的 OnRecv 方法
  ↓
业务逻辑处理
  ↓
返回响应（Response）
```

### 5.2 关键文件位置总结

| 文件路径 | 功能说明 |
|---------|---------|
| `WdtWMS\csharp\CommonUtil\HttpServer.cs` | C# HTTP服务器封装类 |
| `WdtWMS\service\sq\sq_httpserver.cpp` | C++ HTTP服务器核心实现 |
| `WdtWMS\service\clr\clr_utils.cpp` | C# 与 C++ 桥接代码 |
| `WdtWMS\csharp\WdtWMS.Control\Stock\StockBarcodePrint\StockPdaBoxcodePrintWindow.cs` | PDA箱码打印API实现示例 |
| `WdtWMS\csharp\CommonUtil\WebSocketUtils.cs` | WebSocket服务器实现 |
| `WdtWMS\sq_code\common.nut` | Squirrel脚本示例（已注释） |

## 6. 如何添加新的API接口

### 6.1 使用C#实现

1. **创建HTTP连接处理类：**
```csharp
class MyApiConnection : HttpConnection
{
    public MyApiConnection(object connect) : base(connect) { }
    
    void OnRecv(object message, object context)
    {
        Dictionary<string, object> req = (Dictionary<string, object>)message;
        string url = req["url"].ToString();
        Dictionary<string, object> query = (Dictionary<string, object>)req["query"];
        
        // 处理业务逻辑
        Dictionary<string, object> response = new Dictionary<string, object>
        {
            { "code", 0 },
            { "data", "..." }
        };
        
        var contentFormat = new Dictionary<string, object>
        {
            { "type", "application/json; charset=utf-8" }
        };
        
        Response(JSON.Stringify(response), JSON.Stringify(contentFormat));
    }
}
```

2. **启动HTTP服务器：**
```csharp
HttpServer httpServer = new HttpServer();
httpServer.Open(port, ip, default(MyApiConnection), this);
```

### 6.2 使用Squirrel脚本实现

```squirrel
class MyApiConnection extends HttpConnection
{
    function OnRecv(req)
    {
        local url = req.url;
        local query = req.query;
        
        // 处理业务逻辑
        local response = {
            code = 0,
            data = "..."
        };
        
        Response(JSON.Encode(response), {
            type = "application/json; charset=utf-8"
        });
    }
}

local httpServer = HttpServer();
httpServer.Open("0.0.0.0", 8080, MyApiConnection);
```

## 7. 注意事项

1. **端口管理：** 系统使用 `Utils.PortOccupancy()` 来查找可用端口
2. **错误处理：** API实现中应该包含异常处理，避免服务器崩溃
3. **响应格式：** 建议统一使用JSON格式返回数据
4. **安全性：** 对外暴露的API应该考虑身份验证和授权
5. **日志记录：** 建议记录API调用日志，便于排查问题

## 8. 总结
		
系统对外暴露的API主要通过以下方式实现：

1. **HTTP API：** 
   - 使用 `HttpServer` 和 `HttpConnection` 类
   - 支持 C# 和 Squirrel 两种实现方式
   - 核心实现在 C++ 层（`sq_httpserver.cpp`）

2. **WebSocket API：**
   - 使用 `WebSocketUtils.Server` 类
   - 主要用于实时通信场景

3. **API位置：**
   - 核心框架：`WdtWMS\csharp\CommonUtil\HttpServer.cs`
   - 实现示例：`WdtWMS\csharp\WdtWMS.Control\Stock\StockBarcodePrint\StockPdaBoxcodePrintWindow.cs`
   - C++底层：`WdtWMS\service\sq\sq_httpserver.cpp`
	