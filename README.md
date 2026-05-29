# 智购 SmartShopping

> 校园宿舍一站式购物平台 — Java Spring MVC + AI 对话购物 + 语音识别

![Tech Stack](https://img.shields.io/badge/Java-1.8-orange) ![Spring MVC](https://img.shields.io/badge/Spring_MVC-4.3.5-green) ![Hibernate](https://img.shields.io/badge/Hibernate-4.3.8-yellow) ![MySQL](https://img.shields.io/badge/MySQL-8.0-blue) ![Tomcat](https://img.shields.io/badge/Tomcat-11.0-red)

## 项目简介

智购是一个面向大学校园宿舍楼场景的 B2C 在线购物平台，集成 GPT-4o-mini 大语言模型实现 AI 对话购物，集成百度语音识别实现语音输入。支持普通买家、商家、管理员三类角色。

### 核心功能

| 模块 | 功能 |
|------|------|
| 🛒 **商品浏览** | 60fps 连续轮播展示、关键词搜索、商品详情 |
| 🛍️ **购物系统** | 购物车、下单、订单状态跟踪（未发货→运输中→已收货） |
| 🤖 **AI 对话购物** | GPT-4o-mini 驱动的购物助手，自然语言推荐商品、一键加购 |
| 🎤 **语音识别** | 百度 ASR，按住说话自动转文字并发送给 AI |
| 👥 **双角色 AI** | 顾客模式（购物助手）+ 商家模式（店铺管理助手） |
| 📊 **AI 购物周报** | 每周自动分析购物数据，生成个性化消费画像 + 健康提醒 |
| 🏪 **商家后台** | 商品管理（上架/下架）、订单处理（发货）、销售记录 |
| 📝 **论坛交流** | 用户发帖、看帖、管理员管理帖子 |
| ⭐ **商品评价** | 星级评分 + 文字评价 |

### AI 功能亮点

- **大语言模型集成**：通过 OpenAI API 格式调用 GPT-4o-mini，动态注入商品清单作为上下文
- **Function Calling**：AI 输出结构化 JSON 指令（推荐商品/加入购物车），后端解析执行
- **语音转文字**：Web Audio API 录音 → 降采样 → WAV 编码 → 百度短语音识别
- **角色自适应**：前端根据登录角色显示不同 AI 助手界面，后端使用不同 System Prompt
- **AI 购物周报**：每周消费数据分析 → AI 生成个性化报告（称号/点评/推荐）+ 健康提醒 + 智能缓存

---

## 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 后端框架 | Spring MVC 4.3.5 | DispatcherServlet + @Controller + @ResponseBody |
| ORM | Hibernate 4.3.8 | DAO 层实体映射，Spring ORM 集成 |
| 数据库 | MySQL 8.0.13 | 关系型存储，支持事务 |
| 前端 | JSP + JSTL + Bootstrap 3 | 服务端渲染 + AJAX 动态交互 |
| 构建 | Maven | 依赖管理、编译打包 |
| 服务器 | Apache Tomcat 11.0 | Servlet 容器 |
| AI 模型 | OpenAI GPT-4o-mini | 通过 REST API 调用 |
| 语音识别 | 百度 AI 短语音识别 | OAuth2 鉴权 + RAW 模式上传 |
| HTTP 客户端 | Apache HttpClient 4.5.13 | AI API 和语音 API 的 HTTP 请求 |
| JSON | FastJSON 1.2.24 + Jackson 2.9 | 序列化/反序列化 |

---

## 环境要求

| 软件 | 最低版本 | 用途 |
|------|---------|------|
| JDK | 1.8 | Java 运行环境 |
| Maven | 3.0+ | 项目构建 |
| MySQL | 8.0+ | 数据库 |
| Tomcat | 9.0+ | Web 服务器（推荐 11.0） |
| IDE | IntelliJ IDEA / Eclipse | 开发工具（可选） |

---

## 部署步骤

### 1. 克隆项目

```bash
git clone https://github.com/your-username/SmartShopping.git
cd SmartShopping/Software\ Project/Shopping
```

### 2. 配置数据库

#### 2.1 创建数据库

```sql
CREATE DATABASE shopping_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```

#### 2.2 配置数据库连接

编辑 `src/main/resources/spring/applicationContext.xml`，找到数据源配置：

```xml
<bean id="dataSource" class="org.apache.commons.dbcp2.BasicDataSource">
    <property name="driverClassName" value="com.mysql.cj.jdbc.Driver"/>
    <property name="url" value="jdbc:mysql://localhost:3306/shopping_db?useUnicode=true&amp;characterEncoding=utf-8"/>
    <property name="username" value="root"/>        <!-- 改为你的 MySQL 用户名 -->
    <property name="password" value="your_password"/> <!-- 改为你的 MySQL 密码 -->
</bean>
```

#### 2.3 初始化数据表

启动项目后，Hibernate 会根据 `@Entity` 注解自动建表（`hibernate.hbm2ddl.auto=update`）。

如需初始化商品数据，可执行项目中的 SQL 脚本（如果有）或通过商家后台手动添加。

### 3. 配置 AI 密钥

#### 3.1 OpenAI API（对话 AI）

编辑 `src/main/java/com/shopping/service/AiServiceImplement.java`：

```java
private static final String API_URL = "https://api.openai.com/v1/chat/completions";  // 或代理地址
private static final String API_KEY = "sk-xxxxxxxxxxxxxxxx";  // 你的 API Key
```

> **注意**：如果使用代理（如 poloai.top），需修改 `API_URL` 为代理地址，模型名称 `gpt-4o-mini` 保持不变。

#### 3.2 百度语音识别（可选）

编辑 `src/main/java/com/shopping/service/SpeechServiceImplement.java`：

```java
private static final String API_KEY    = "你的百度 API Key";
private static final String SECRET_KEY = "你的百度 Secret Key";
```

> 百度密钥可在 [百度 AI 控制台](https://console.bce.baidu.com/ai/#/ai/speech/overview/index) 创建「语音识别」应用获取。

### 4. 编译打包

**方式一：IDEA 内置 Maven（推荐）**

1. 打开右侧 Maven 工具窗口
2. Lifecycle → 双击 `clean`，完成后双击 `package`
3. 或直接 **Build → Rebuild Project**（Ctrl+Shift+F9），IDEA 会自动编译并更新部署

**方式二：命令行**

```bash
mvn clean package
```

编译成功后，`target/Shopping.war` 即为部署包。

### 5. 部署到 Tomcat

#### 方式一：IDEA 直接运行

1. 在 IntelliJ IDEA 中导入项目为 Maven 项目
2. 配置 Tomcat Server（Run → Edit Configurations → + Tomcat Server → Local）
3. Deployment 添加 `Shopping:war exploded`
4. 点击运行

#### 方式二：手动部署战争包

```bash
# 复制 war 包到 Tomcat webapps 目录
cp target/Shopping.war /path/to/tomcat/webapps/

# 启动 Tomcat
/path/to/tomcat/bin/startup.sh    # Linux/macOS
/path/to/tomcat/bin/startup.bat   # Windows
```

### 6. 访问系统

浏览器打开：`http://localhost:8080/Shopping/`

默认进入首页（main.jsp），可浏览商品。点击右上角「登录」进行身份认证。

---

## 项目结构

```
Shopping/
├── pom.xml                          # Maven 配置
├── src/
│   ├── main/
│   │   ├── java/com/shopping/
│   │   │   ├── bean/                 # 实体类
│   │   │   ├── controller/           # 11 个控制器
│   │   │   │   ├── AiController.java          # AI 对话
│   │   │   │   ├── SpeechController.java      # 语音识别
│   │   │   │   ├── ProductController.java     # 商品管理
│   │   │   │   ├── ShoppingCarController.java # 购物车
│   │   │   │   └── ...
│   │   │   ├── service/             # 10 个服务接口+实现
│   │   │   │   ├── AiService.java / AiServiceImplement.java
│   │   │   │   ├── SpeechService.java / SpeechServiceImplement.java
│   │   │   │   └── ...
│   │   │   ├── dao/                 # 26 个 DAO 接口+实现
│   │   │   └── entity/              # JPA 实体
│   │   ├── resources/
│   │   │   └── spring/              # Spring 配置文件
│   │   │       ├── applicationContext.xml   # 数据源、Hibernate
│   │   │       └── spring-mvc.xml           # Spring MVC 配置
│   │   └── webapp/
│   │       ├── WEB-INF/views/       # JSP 视图
│   │       │   ├── main.jsp         # 首页（含 AI 聊天 + 轮播）
│   │       │   ├── login.jsp        # 登录页
│   │       │   ├── shopping_car.jsp # 购物车
│   │       │   ├── bossControl.jsp  # 商家后台
│   │       │   ├── managerControl.jsp # 管理员后台
│   │       │   └── include/         # 公共头部/尾部
│   │       ├── static/
│   │       │   ├── css/             # Bootstrap + 自定义样式
│   │       │   ├── js/              # jQuery + Bootstrap + Layer.js
│   │       │   └── img/             # 商品图片
│   │       └── WEB-INF/web.xml      # 部署描述符
└── PROJECT_DEFENSE.md               # 答辩材料
```

---

## 常见问题

### Q: 启动后页面显示 404？

确认 Tomcat 部署的 context path 正确。访问 `http://localhost:8080/Shopping/`（注意大写 `S`）。

### Q: AI 对话返回 "AI服务暂不可用"？

检查 `AiServiceImplement.java` 中的 `API_URL` 和 `API_KEY` 是否正确，以及服务器是否能访问外网。

### Q: 语音识别无法使用？

语音识别需要 HTTPS 或 localhost 环境。如果通过 IP 访问（非 localhost），浏览器会拒绝麦克风权限。

### Q: 图片无法显示？

确认 `src/main/webapp/static/img/` 目录下有商品图片。Maven 编译时会自动同步静态资源到 `target/` 目录。

### Q: AI 周报为什么打不开或显示失败？

确认已登录后再查看周报。如果 AI 服务不可用，周报会自动使用本地统计兜底数据（仍可看到购买总量、品类分布等），不会完全空白。

### Q: 打开订单状态页面显示商品查询错误或卡住？

说明后端 class 文件未更新。在 IDEA 中执行 **Build → Rebuild Project**，然后重新部署。如果仍有问题，确认数据库中对应订单的商品未被删除。

### Q: 数据库表已存在怎么办？

编辑 `applicationContext.xml`，将 `hibernate.hbm2ddl.auto` 从 `update` 改为 `validate`，避免重复建表覆盖数据。

---

## License

本项目仅用于课程学习和答辩演示。
