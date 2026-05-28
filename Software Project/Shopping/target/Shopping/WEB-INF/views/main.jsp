<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="utf-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>智购</title>
    <link href="${cp}/css/bootstrap.min.css" rel="stylesheet">
    <link href="${cp}/css/style.css" rel="stylesheet">

    <script src="${cp}/js/jquery.min.js" type="text/javascript"></script>
    <script src="${cp}/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="${cp}/js/layer.js" type="text/javascript"></script>
    <!--[if lt IE 9]>
    <script src="${cp}/js/html5shiv.min.js"></script>
    <script src="${cp}/js/js/respond.min.js"></script>
    <![endif]-->

    <style>
        :root {
            --ink: #2c2416;
            --ink-light: #5c4f3a;
            --paper: #f6f3ed;
            --card: #fffefb;
            --accent-red: #c44536;
            --accent-green: #2d6a4f;
            --accent-teal: #1b6b6b;
            --border: #e0dbd1;
            --border-light: #ebe6dc;
            --shadow: 0 2px 12px rgba(0,0,0,.05);
            --shadow-lg: 0 6px 24px rgba(0,0,0,.08);
        }
        body {
            padding-top: 56px;
            background: var(--paper);
            color: var(--ink);
            font-family: "Segoe UI", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
            -webkit-font-smoothing: antialiased;
        }
        body::after {
            content: '';
            position: fixed; top:0;left:0;right:0;bottom:0;
            pointer-events: none; z-index:0; opacity:.025;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
        }
        .page { position:relative; z-index:1; }

        /* ---- 顶部分类栏 ---- */
        .cat-bar {
            display: flex; gap:0; overflow-x:auto;
            padding:10px 16px; margin-bottom:16px;
            flex-wrap:wrap; justify-content:center;
            background: var(--card); border-bottom:1px solid var(--border);
        }
        .cat-bar a {
            display:inline-flex; align-items:center; gap:5px;
            padding:7px 15px; border-radius:20px; font-size:14px; font-weight:600;
            color: var(--ink-light); text-decoration:none;
            transition: all .18s ease;
            white-space:nowrap;
        }
        .cat-bar a:hover, .cat-bar a.active {
            background: var(--ink); color:#fff;
        }

        /* ---- 英雄区 ---- */
        .hero {
            background: var(--card);
            border-bottom:4px solid var(--accent-teal);
            padding:48px 24px 36px; text-align:center;
            position:relative; overflow:hidden;
            margin-bottom:0;
        }
        .hero::before {
            content:''; position:absolute; top:0;left:0;right:0;bottom:0;
            background: repeating-linear-gradient(
                45deg, transparent, transparent 8px,
                rgba(27,107,107,.02) 8px, rgba(27,107,107,.02) 9px
            );
            pointer-events:none;
        }
        .hero h1 {
            font-size: clamp(26px, 5vw, 44px);
            font-weight:800; margin:0 0 10px;
            color: var(--ink); letter-spacing:1px;
            position:relative; z-index:1;
        }
        .hero h1 span { color: var(--accent-teal); }
        .hero p {
            font-size:15px; color:var(--ink-light); max-width:480px;
            margin:0 auto; line-height:1.8;
            position:relative; z-index:1;
        }
        .hero-badges {
            margin-top:16px; display:flex; justify-content:center;
            gap:12px; flex-wrap:wrap; position:relative; z-index:1;
        }
        .hero-badges span {
            padding:4px 14px; border-radius:20px;
            font-size:12px; font-weight:700;
            border:2px solid var(--accent-green); color:var(--accent-green);
        }

        /* ---- 分类标题 ---- */
        .section-head {
            display:flex; align-items:center; gap:14px;
            margin:36px 0 18px; padding:0 8px;
        }
        .section-head h2 {
            font-size:18px; font-weight:800; margin:0; white-space:nowrap;
            color: var(--ink); letter-spacing:.5px;
        }
        .section-head .bar {
            flex:1; height:2px; background:var(--border);
        }
        .section-head .dot {
            width:6px; height:6px; border-radius:50%;
            background:var(--accent-teal); flex-shrink:0;
        }

        /* ---- 商品轮播 ---- */
        .carousel-wrap {
            position:relative; margin-bottom:36px;
            overflow:hidden;
        }
        /* 左右渐变遮罩 — 制造边缘渐隐效果 */
        .carousel-wrap::before,
        .carousel-wrap::after {
            content:''; position:absolute; top:0; bottom:0;
            width:60px; z-index:3; pointer-events:none;
        }
        .carousel-wrap::before {
            left:0;
            background:linear-gradient(to right, var(--bg-body,#f6f3ed) 20%, transparent);
        }
        .carousel-wrap::after {
            right:0;
            background:linear-gradient(to left, var(--bg-body,#f6f3ed) 20%, transparent);
        }
        .carousel-track {
            display:flex; gap:14px; overflow-x:auto;
            padding:4px 60px 12px;
            scrollbar-width:none;
        }
        .carousel-track::-webkit-scrollbar { display:none; }
        .carousel-track>* { flex-shrink:0; }

        .carousel-btn {
            position:absolute; top:50%; transform:translateY(-50%);
            width:38px; height:38px; border-radius:50%;
            background:var(--bg-white,#fffefb); border:2px solid var(--border);
            color:var(--ink-light); font-size:16px; cursor:pointer;
            display:flex; align-items:center; justify-content:center;
            z-index:4; transition:all .2s; box-shadow:var(--shadow-sm);
        }
        .carousel-btn:hover { background:var(--accent-teal); color:#fff; border-color:var(--accent-teal); }
        .carousel-btn.left  { left:8px; }
        .carousel-btn.right { right:8px; }
        @media(max-width:600px){ .carousel-btn { display:none; } }

        .carousel-hint { display:none; }

        /* ---- 卡片(轮播版,更小) ---- */
        .card-shop {
            width:160px; background:var(--card);
            border:1px solid var(--border); flex-shrink:0;
            overflow:hidden; cursor:pointer;
            transition:all .25s ease;
            position:relative;
            display:flex; flex-direction:column;
        }
        .card-shop:hover {
            transform:translateY(-3px);
            box-shadow:var(--shadow-lg);
            border-color:var(--accent-teal);
        }
        .card-img {
            width:100%; height:140px; overflow:hidden;
            background:#faf8f5; position:relative;
        }
        .card-img img {
            width:100%; height:100%; object-fit:contain;
            transition:transform .4s ease;
        }
        .card-shop:hover .card-img img { transform:scale(1.06); }
        .card-badge {
            position:absolute; top:6px; right:6px;
            padding:1px 6px; font-size:10px; font-weight:800;
            color:#fff; background:var(--accent-red); z-index:2;
        }
        .card-body {
            padding:8px 10px 10px; flex:1;
            display:flex; flex-direction:column; gap:3px;
        }
        .card-body .name {
            font-size:13px; font-weight:600; color:var(--ink);
            line-height:1.3; display:-webkit-box;
            -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
        }
        .card-body .price {
            font-size:16px; font-weight:800; color:var(--accent-red);
            margin-top:auto;
        }
        .card-body .price::before { content:'\00a5'; font-size:12px; margin-right:1px; }

        /* ---- 分类标题 ---- */
        .section-head {
            display:flex; align-items:center; gap:14px;
            margin:36px 0 14px; padding:0 8px;
        }
        .section-head h2 {
            font-size:18px; font-weight:800; margin:0; white-space:nowrap;
            color:var(--ink); letter-spacing:.5px;
        }
        .section-head .bar {
            flex:1; height:2px; background:var(--border);
        }
        .section-head .dot {
            width:6px; height:6px; border-radius:50%;
            background:var(--accent-teal); flex-shrink:0;
        }
        @media (max-width:480px) {
            .product-grid { grid-template-columns: repeat(2, 1fr); gap:10px; }
        }

        /* ---- 卡片 ---- */
        .card-shop {
            background: var(--card);
            border:1px solid var(--border);
            overflow:hidden;
            cursor:pointer;
            transition: all .25s ease;
            position:relative;
            display:flex; flex-direction:column;
        }
        .card-shop:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--accent-teal);
        }
        .card-img {
            width:100%; aspect-ratio:1; overflow:hidden;
            background: #faf8f5; position:relative;
        }
        .card-img img {
            width:100%; height:100%; object-fit:contain;
            transition: transform .4s ease;
        }
        .card-shop:hover .card-img img { transform: scale(1.06); }
        .card-badge {
            position:absolute; top:8px; right:8px;
            padding:2px 8px; font-size:10px; font-weight:800;
            color:#fff; background: var(--accent-red); z-index:2;
        }
        .card-body {
            padding:10px 12px 12px; flex:1;
            display:flex; flex-direction:column; gap:4px;
        }
        .card-body .name {
            font-size:14px; font-weight:600; color:var(--ink);
            line-height:1.4; display:-webkit-box;
            -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
        }
        .card-body .price {
            font-size:19px; font-weight:800; color:var(--accent-red);
            margin-top:auto;
        }
        .card-body .price::before { content:'\00a5'; font-size:14px; margin-right:1px; }

        /* ---- AI 周报 Modal ---- */
        .report-overlay {
            position:fixed; inset:0; z-index:20000;
            background:rgba(12,10,8,.92);
            display:none; align-items:center; justify-content:center;
            padding:40px 20px; overflow-y:auto;
        }
        .report-overlay.show { display:flex; animation:fadeIn .3s ease; }
        @keyframes fadeIn { from{opacity:0;} to{opacity:1;} }
        .report-card {
            background:linear-gradient(145deg, #1a2a2a 0%, #162020 50%, #0f1a1a 100%);
            border:1px solid rgba(255,255,255,.06); border-radius:20px;
            padding:20px 28px 32px; max-width:560px; width:100%; position:relative;
            color:#e0eae6; box-shadow:0 20px 60px rgba(0,0,0,.4);
            text-align:center;
        }
        .report-close {
            position:absolute; top:12px; right:16px;
            width:32px; height:32px; border-radius:50%;
            background:rgba(255,255,255,.08); color:rgba(255,255,255,.6); border:none;
            font-size:18px; cursor:pointer; transition:all .2s;
            display:flex; align-items:center; justify-content:center;
        }
        .report-close:hover { background:rgba(255,255,255,.18); color:#fff; }
        .report-card h2 { font-size:28px; font-weight:800; margin:0 0 4px; color:#fff; }
        .report-card .subtitle { font-size:13px; color:#7a9e9e; margin-bottom:20px; }
        .report-stats {
            display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:20px;
        }
        .report-stat {
            background:rgba(255,255,255,.04); border-radius:12px;
            padding:16px 12px; text-align:center;
        }
        .report-stat .val { font-size:26px; font-weight:800; color:#5eead4; }
        .report-stat .lbl { font-size:12px; color:#7a9e9e; margin-top:4px; }
        .report-title-badge {
            display:inline-block; padding:8px 24px; border-radius:30px;
            font-size:20px; font-weight:800; margin:12px 0;
            background:linear-gradient(135deg, #5eead4, #2dd4bf);
            color:#0f1a1a; letter-spacing:1px;
        }
        .report-comment {
            font-size:15px; color:#c0d8d8; line-height:1.8; margin:0 0 20px;
            max-width:420px; margin-left:auto; margin-right:auto;
        }
        .report-recommend {
            display:flex; gap:10px; justify-content:center; flex-wrap:wrap;
        }
        .report-recommend span {
            padding:8px 18px; border-radius:20px;
            background:rgba(94,234,212,.12); color:#5eead4;
            font-size:14px; font-weight:600; border:1px solid rgba(94,234,212,.2);
        }
        .report-open-btn {
            display:inline-flex; align-items:center; gap:6px;
            padding:8px 20px; border-radius:24px;
            background:linear-gradient(135deg, #5eead4, #2dd4bf);
            color:#0f1a1a; font-size:14px; font-weight:700;
            cursor:pointer; border:none; transition:all .2s;
        }
        .report-open-btn:hover { transform:translateY(-1px); box-shadow:0 4px 16px rgba(94,234,212,.3); }
        .report-badge {
            display:inline-block; padding:4px 14px; border-radius:20px;
            font-size:11px; font-weight:700; background:rgba(94,234,212,.12);
            color:#5eead4; border:1px solid rgba(94,234,212,.2);
            margin-left:8px; vertical-align:middle;
        }

        /* ---- AI 抽屉面板 ---- */
        .ai-drawer {
            position:fixed; top:56px; right:0; z-index:999;
            height:calc(100vh - 56px); display:flex;
            pointer-events:none;
        }
        .ai-tab {
            writing-mode:vertical-rl; text-orientation:mixed;
            padding:18px 10px; line-height:1;
            background:linear-gradient(to bottom, var(--accent-teal), #145252);
            color:#fff; font-size:13px; font-weight:700; letter-spacing:4px;
            cursor:pointer; transition:transform .2s;
            white-space:nowrap; pointer-events:auto;
            display:flex; align-items:center; justify-content:center;
            border-radius:0 0 6px 6px;
        }
        .ai-tab:hover { filter:brightness(1.1); }
        .ai-tab .dot { display:block; width:5px; height:5px; border-radius:50%; background:var(--primary-light); margin:6px 0; flex-shrink:0; }
        .ai-panel {
            width:0; overflow:hidden; pointer-events:auto;
            transition:width .35s cubic-bezier(.4,0,.2,1);
            background:linear-gradient(180deg, #fffefb 0%, #f8f5f0 100%);
            box-shadow:-4px 0 24px rgba(0,0,0,.08);
            display:flex; flex-direction:column;
        }
        .ai-drawer.open .ai-panel { width:400px; }
        @media(max-width:500px){ .ai-drawer.open .ai-panel { width:100vw; } }
        .ai-panel .chat-header {
            background:linear-gradient(135deg, #1b6b6b, #145252);
            color:#fff; padding:12px 16px; display:flex;
            justify-content:space-between; align-items:center; flex-shrink:0;
            font-size:14px; font-weight:700; letter-spacing:.3px;
        }
        .ai-panel .chat-header .close-btn {
            cursor:pointer; opacity:.7; font-size:18px; transition:opacity .2s;
            width:26px; height:26px; display:flex; align-items:center; justify-content:center;
            border-radius:50%; background:rgba(255,255,255,.1);
        }
        .ai-panel .chat-header .close-btn:hover { opacity:1; background:rgba(255,255,255,.2); }
        .ai-panel .chat-body {
            flex:1; padding:12px; overflow-y:auto;
            display:flex; flex-direction:column; gap:8px;
        }
        .ai-panel .chat-body::-webkit-scrollbar { width:4px; }
        .ai-panel .chat-body::-webkit-scrollbar-thumb { background:#d5cfc6; border-radius:2px; }
        .msg-user {
            background:var(--accent-teal); color:#fff;
            padding:8px 12px; border-radius:12px 4px 12px 12px;
            align-self:flex-end; max-width:85%; font-size:13px;
            line-height:1.5; box-shadow:0 2px 6px rgba(27,107,107,.12);
            animation:popIn .25s ease; word-break:break-word;
        }
        .msg-ai {
            background:#fff; padding:8px 12px; border-radius:4px 12px 12px 12px;
            align-self:flex-start; max-width:85%; font-size:13px;
            line-height:1.5; border:1px solid var(--border-light); word-break:break-word;
            box-shadow:0 1px 3px rgba(0,0,0,.03);
            animation:popIn .25s ease;
        }
        @keyframes popIn {
            from{transform:scale(.9);opacity:0;} to{transform:scale(1);opacity:1;}
        }
        .ai-panel .chat-footer {
            padding:8px 12px; border-top:1px solid var(--border);
            display:flex; align-items:center; gap:6px; background:#fff; flex-shrink:0;
        }
        .ai-panel .chat-footer input {
            flex:1; padding:8px 10px; border:2px solid var(--border); min-width:0;
            font-size:13px; border-radius:8px; outline:none;
            background:var(--paper); transition:border .2s;
        }
        .ai-panel .chat-footer input:focus { border-color:var(--accent-teal); }
        .ai-panel .chat-footer .send-btn {
            background:var(--accent-teal); color:#fff; border:none;
            padding:8px 14px; border-radius:8px; cursor:pointer;
            font-size:13px; white-space:nowrap; font-weight:700;
            letter-spacing:.5px; transition:background .2s;
        }
        .ai-panel .chat-footer .send-btn:hover { background:#145252; }
        .mic-btn {
            width:34px; height:34px; border-radius:50%; border:none; flex-shrink:0;
            background:var(--ink); color:#fff; font-size:16px; cursor:pointer;
            display:flex; align-items:center; justify-content:center; transition:background .2s;
        }
        .mic-btn:hover { background:#444; }
        .mic-btn.listening { background:var(--accent-red); animation:micPulse 1.4s infinite; }
        @keyframes micPulse {
            0%,100%{box-shadow:0 0 0 0 rgba(196,69,54,.5);transform:scale(1);}
            50%{box-shadow:0 0 0 10px rgba(196,69,54,0);transform:scale(1.06);}
        }
        #voiceWaveCanvas { width:100%; height:26px; display:none; background:rgba(27,107,107,.04); }
        #speechPreview { display:none; padding:4px 10px; font-size:12px; color:var(--ink-light); font-style:italic; }
        .typewriter-cursor {
            display:inline-block; width:2px; height:13px;
            background:var(--accent-teal); margin-left:2px;
            vertical-align:middle; animation:blink .7s step-end infinite;
        }
        @keyframes blink { 0%,100%{opacity:1;} 50%{opacity:0;} }

        /* ---- 页脚 ---- */
        .site-footer { text-align:center; padding:28px 0; font-size:13px; color:var(--ink-light); border-top:1px solid var(--border); margin-top:32px; }
    </style>
</head>
<body>

<div class="page">

<jsp:include page="include/header.jsp"/>

<!-- === 英雄区 === -->
<div class="hero">
    <h1><span>智购</span> · 荟园99栋</h1>
    <p>宿舍楼下 · 即买即达 · 校园生活好伙伴</p>
    <div class="hero-badges">
        <span>#零食</span><span>#饮料</span><span>#速食</span><span>#水果</span><span>#日用</span>
    </div>
    <div style="margin-top:18px;position:relative;z-index:1;">
        <button class="report-open-btn" onclick="openReport()">📊 查看我的购物周报</button>
    </div>
</div>

<!-- ====== AI 周报弹窗 ====== -->
<div class="report-overlay" id="reportOverlay">
    <div class="report-card" id="reportCard">
        <button class="report-close" onclick="closeReport()">✕</button>
        <div style="padding:20px;text-align:center;color:#7a9e9e;">⏳ AI 正在分析你的购物数据...</div>
    </div>
</div>

<!-- === 分类导航 === -->
<div class="cat-bar" id="catBar">
    <a href="#productArea1" data-cat="1">🍪 休闲零食</a>
    <a href="#productArea2" data-cat="2">🥤 酒水饮料</a>
    <a href="#productArea3" data-cat="3">🍜 方便速食</a>
    <a href="#productArea4" data-cat="4">🍎 新鲜水果</a>
    <a href="#productArea5" data-cat="5">🧴 日用百货</a>
    <a href="#productArea6" data-cat="6">📚 文具办公</a>
    <a href="#productArea7" data-cat="7">🎁 其他</a>
</div>

<!-- === 产品区域 === -->
<div class="col-sm-12">
    <div id="productArea1"></div>
    <div id="productArea2"></div>
    <div id="productArea3"></div>
    <div id="productArea4"></div>
    <div id="productArea5"></div>
    <div id="productArea6"></div>
    <div id="productArea7"></div>
</div>

<div class="site-footer">
    <jsp:include page="include/foot.jsp"/>
</div>

<!-- ====== AI Drawer ====== -->
<div class="ai-drawer" id="aiDrawer">
    <div class="ai-tab" id="aiTab" onclick="toggleDrawer()">
        <span class="dot"></span> <c:choose><c:when test="${not empty currentUser and currentUser.role == 1}">商家助手</c:when><c:otherwise>购物助手</c:otherwise></c:choose> <span class="dot"></span>
    </div>
    <div class="ai-panel" id="aiPanel">
        <div id="aiBreathRing"></div>
        <div class="chat-header">
            <span><c:choose><c:when test="${not empty currentUser and currentUser.role == 1}">✦ 商家管理助手</c:when><c:otherwise>✦ 购物小助手</c:otherwise></c:choose> <span id="voiceStatus" style="font-size:11px;opacity:.75;margin-left:6px;"></span></span>
            <span class="close-btn" onclick="toggleDrawer()">✕</span>
        </div>
        <div class="chat-body" id="aiChatContent">
            <div class="msg-ai"><c:choose><c:when test="${not empty currentUser and currentUser.role == 1}">老板你好！我是你的店铺管理助手，可以问我订单、商品、经营建议～</c:when><c:otherwise>你好！我是智购小助手，可以打字或按住🎤语音问我～</c:otherwise></c:choose></div>
        </div>
        <canvas id="voiceWaveCanvas"></canvas>
        <div id="speechPreview"></div>
        <div class="chat-footer">
            <button class="mic-btn" id="micButton" title="按住说话">🎤</button>
            <input type="text" id="aiChatInput" placeholder="输入问题..." onkeypress="if(event.keyCode===13) sendAiMessage()">
            <button class="send-btn" onclick="sendAiMessage()">发送</button>
        </div>
    </div>
</div>

</div><!-- /page -->

<script type="text/javascript">
    function toggleDrawer(){
        document.getElementById('aiDrawer').classList.toggle('open');
    }

    function openReport(){
        var userId=${not empty currentUser ? currentUser.id : 0};
        if(!userId){
            layer.confirm('请先登录才能查看购物周报',{title:'提示',btn:['去登录','取消']},function(){
                window.location.href='${cp}/login';
            });
            return;
        }
        var overlay=document.getElementById('reportOverlay');
        overlay.classList.add('show');
        var card=document.getElementById('reportCard');

        card.innerHTML='<button class="report-close" onclick="closeReport()">✕</button>'+
            '<h2>📊 正在生成购物周报</h2>'+
            '<div class="subtitle" style="margin-bottom:28px;">AI 正在分析你的购物数据...</div>'+
            '<div class="report-stats">'+
            '<div class="report-stat"><div class="skeleton-pulse" style="height:28px;width:60%;margin:0 auto;border-radius:6px;background:rgba(255,255,255,.06);"></div><div class="skeleton-pulse" style="height:12px;width:40%;margin:8px auto 0;border-radius:4px;background:rgba(255,255,255,.04);"></div></div>'+
            '<div class="report-stat"><div class="skeleton-pulse" style="height:28px;width:60%;margin:0 auto;border-radius:6px;background:rgba(255,255,255,.06);"></div><div class="skeleton-pulse" style="height:12px;width:40%;margin:8px auto 0;border-radius:4px;background:rgba(255,255,255,.04);"></div></div>'+
            '<div class="report-stat"><div class="skeleton-pulse" style="height:28px;width:60%;margin:0 auto;border-radius:6px;background:rgba(255,255,255,.06);"></div><div class="skeleton-pulse" style="height:12px;width:40%;margin:8px auto 0;border-radius:4px;background:rgba(255,255,255,.04);"></div></div>'+
            '<div class="report-stat"><div class="skeleton-pulse" style="height:28px;width:60%;margin:0 auto;border-radius:6px;background:rgba(255,255,255,.06);"></div><div class="skeleton-pulse" style="height:12px;width:40%;margin:8px auto 0;border-radius:4px;background:rgba(255,255,255,.04);"></div></div>'+
            '</div>'+
            '<style>.skeleton-pulse{animation:skeletonShimmer 1.6s ease-in-out infinite;}@keyframes skeletonShimmer{0%,100%{opacity:.3;}50%{opacity:.8;}}</style>';

        $.ajax({
            type:'POST', url:'${cp}/weeklyReport', dataType:'json', timeout:30000,
            success:function(res){
                if(!res.success){
                    card.innerHTML='<button class="report-close" onclick="closeReport()">✕</button><div style="padding:32px;text-align:center;"><div style="font-size:48px;margin-bottom:16px;">📭</div><div style="color:#7a9e9e;font-size:16px;">'+res.message+'</div></div>';
                    return;
                }
                var r=res.report;
                if(!r){
                    card.innerHTML='<button class="report-close" onclick="closeReport()">✕</button><div style="padding:32px;text-align:center;"><div style="font-size:48px;margin-bottom:16px;">📭</div><div style="color:#7a9e9e;font-size:16px;">本周暂无购物记录<br>先去买点东西吧~</div></div>';
                    return;
                }
                var recs=(r.recommend||[]).map(function(x){ return '<span>'+x+'</span>'; }).join('');
                var cachedLabel=res.cached?'<span class="report-badge">已缓存</span>':'';
                var limitLabel=res.limitReached?'<span class="report-badge" style="background:rgba(240,100,80,.12);color:#f06450;border-color:rgba(240,100,80,.2);">已达上限</span>':'';
                card.innerHTML=
                    '<button class="report-close" onclick="closeReport()">✕</button>'+
                    '<h2>📊 你的本周购物画像 '+cachedLabel+limitLabel+'</h2>'+
                    '<div class="subtitle">📅 '+(r.date_range||'本周')+' · '+(r.peak_day||'')+' · '+(r.peak_hour||'')+'</div>'+
                    '<div class="report-stats">'+
                    '<div class="report-stat"><div class="val">'+(r.total_items||0)+'</div><div class="lbl">购买总量</div></div>'+
                    '<div class="report-stat"><div class="val">¥'+(r.total_spent||0)+'</div><div class="lbl">总花费</div></div>'+
                    '<div class="report-stat"><div class="val">'+(r.top_category||'--')+'</div><div class="lbl">最爱品类</div></div>'+
                    '<div class="report-stat"><div class="val">'+(r.peak_hour||'--')+'</div><div class="lbl">下单高峰</div></div>'+
                    '</div>'+
                    '<div class="report-title-badge">🏆 '+(r.title||'购物达人')+'</div>'+
                    '<p class="report-comment">💬 '+(r.comment||'')+'</p>'+
                    ((r.health_tip)?'<p style="font-size:14px;color:#f0c060;margin:0 0 16px;line-height:1.6;">💚 '+(r.health_tip||'')+'</p>':'')+
                    (recs?'<div class="report-recommend">'+recs+'</div>':'');
            },
            error:function(xhr,status){
                card.innerHTML='<button class="report-close" onclick="closeReport()">✕</button><div style="padding:32px;text-align:center;"><div style="font-size:48px;margin-bottom:16px;">🔧</div><div style="color:#e07a5f;font-size:15px;">周报生成失败<br><span style="font-size:12px;color:#7a9e9e;">'+(status==='timeout'?'AI响应超时':'服务器异常')+'</span></div></div>';
            }
        });
    }
    function closeReport(){
        document.getElementById('reportOverlay').classList.remove('show');
    }

    // ============================================================
    //  AI Chat
    // ============================================================
    var aiChatHistory = [];
    function startBreath() { var ring=document.getElementById('aiBreathRing'); if(ring) ring.classList.add('breathing'); }
    function stopBreath()  { var ring=document.getElementById('aiBreathRing'); if(ring) ring.classList.remove('breathing'); }

    function typewriterAppend(container, htmlBefore, fullText, htmlAfter, callback) {
        var wrapper = document.createElement('div');
        wrapper.className = 'msg-ai';
        if (htmlBefore) wrapper.innerHTML = htmlBefore;
        var textSpan = document.createElement('span');
        wrapper.appendChild(textSpan);
        var afterSpan = null;
        if (htmlAfter) {
            afterSpan = document.createElement('span');
            afterSpan.innerHTML = htmlAfter;
            afterSpan.style.display = 'none';
            wrapper.appendChild(afterSpan);
        }
        var cursor = document.createElement('span');
        cursor.className = 'typewriter-cursor';
        wrapper.appendChild(cursor);
        container.appendChild(wrapper);

        var index=0, speed=20+Math.random()*12;
        function typeNext(){
            if(index<fullText.length){
                textSpan.textContent += fullText.charAt(index);
                index++;
                container.scrollTop=container.scrollHeight;
                setTimeout(typeNext, speed);
            }else{
                if(cursor.parentNode) cursor.parentNode.removeChild(cursor);
                if(htmlAfter && afterSpan) afterSpan.style.display='';
                container.scrollTop=container.scrollHeight;
                if(callback) callback();
            }
        }
        typeNext();
        return wrapper;
    }

    function sendAiMessage(textOverride) {
        var input=document.getElementById('aiChatInput');
        var text=textOverride||input.value.trim();
        if(!text) return;
        if(!textOverride) input.value='';
        var content=document.getElementById('aiChatContent');
        var userDiv=document.createElement('div');
        userDiv.className='msg-user'; userDiv.textContent=text;
        content.appendChild(userDiv);
        content.scrollTop=content.scrollHeight;
        aiChatHistory.push({role:'user', content:text});
        startBreath();

        var thinkingId='thinking_'+Date.now();
        var thinkDiv=document.createElement('div');
        thinkDiv.id=thinkingId;
        thinkDiv.style.cssText='padding:8px 12px;align-self:flex-start;font-size:14px;color:var(--ink-light);';
        thinkDiv.textContent='思考中...';
        content.appendChild(thinkDiv);
        content.scrollTop=content.scrollHeight;

        $.ajax({
            type:'POST', url:'${cp}/aiChat',
            data:{ message:text, historyJson:JSON.stringify(aiChatHistory) },
            success:function(result){
                stopBreath();
                var td=document.getElementById(thinkingId);
                if(td) td.remove();

                if(result.type==='recommend'){
                    var p=result.product;
                    aiChatHistory.push({role:'assistant',content:result.message});
                    var imgHtml='<br><img src="${cp}/img/'+p.img+'" style="width:50px;display:block;margin:5px 0;">'+
                        '<button onclick="addToCart('+p.id+')" style="background:#2d6a4f;color:#fff;border:none;padding:4px 8px;border-radius:3px;cursor:pointer;font-size:12px;">加入购物车</button>';
                    typewriterAppend(content,'',result.message,imgHtml);
                }else{
                    aiChatHistory.push({role:'assistant',content:result.message});
                    typewriterAppend(content,'',result.message,null);
                }
            },
            error:function(){
                stopBreath();
                var td=document.getElementById(thinkingId);
                if(td) td.remove();
                var errDiv=document.createElement('div');
                errDiv.className='msg-ai';
                errDiv.style.color='#c44536';
                errDiv.textContent='抱歉，请求超时，请重试。';
                content.appendChild(errDiv);
                content.scrollTop=content.scrollHeight;
            }
        });
    }

    function addToCart(productId){
        var userId=${not empty currentUser ? currentUser.id : 0};
        if(userId===0){ layer.msg("请先登录"); return; }
        $.ajax({
            type:'POST', url:'${cp}/addShoppingCar',
            data:{userId:userId, productId:productId, counts:1},
            success:function(){ layer.msg("已加入购物车"); }
        });
    }

    // ============================================================
    //  Voice
    // ============================================================
    var isRecording=false, audioContext=null, mediaStream=null, scriptProcessor=null;
    var audioSampleRate=16000, pcmBuffers=[], analyser=null, animFrameId=null;

    (function initMic(){
        var btn=document.getElementById('micButton'); if(!btn) return;
        var nb=btn.cloneNode(true); btn.parentNode.replaceChild(nb,btn);
        nb.addEventListener('mousedown',function(e){ e.preventDefault(); startRecording(); });
        nb.addEventListener('mouseup',function(e){ e.preventDefault(); stopRecordingAndRecognize(); });
        nb.addEventListener('mouseleave',function(){ if(isRecording) stopRecordingAndRecognize(); });
        nb.addEventListener('touchstart',function(e){ e.preventDefault(); startRecording(); });
        nb.addEventListener('touchend',function(e){ e.preventDefault(); stopRecordingAndRecognize(); });
    })();

    function startRecording(){
        if(isRecording) return;
        isRecording=true; pcmBuffers=[];
        var mic=document.getElementById('micButton');
        var cvs=document.getElementById('voiceWaveCanvas');
        var st=document.getElementById('voiceStatus');
        if(mic) mic.classList.add('listening');
        if(cvs) cvs.style.display='block';
        if(st) st.textContent='🎙️ 录音中...';

        if(!navigator.mediaDevices||!navigator.mediaDevices.getUserMedia){
            isRecording=false; if(mic) mic.classList.remove('listening');
            if(cvs) cvs.style.display='none'; if(st) st.textContent='';
            layer.msg('浏览器不支持麦克风，请使用HTTPS或localhost'); return;
        }
        navigator.mediaDevices.getUserMedia({audio:{echoCancellation:true,noiseSuppression:true}})
            .then(function(stream){
                mediaStream=stream;
                var ctx=new(window.AudioContext||window.webkitAudioContext)();
                audioContext=ctx; audioSampleRate=ctx.sampleRate;
                var source=ctx.createMediaStreamSource(stream);
                analyser=ctx.createAnalyser(); analyser.fftSize=128; analyser.smoothingTimeConstant=.6;
                source.connect(analyser);
                var zg=ctx.createGain(); zg.gain.value=0;
                scriptProcessor=ctx.createScriptProcessor(4096,1,1);
                scriptProcessor.onaudioprocess=function(e){
                    if(!isRecording) return;
                    var input=e.inputBuffer.getChannelData(0);
                    var copy=new Float32Array(input.length); copy.set(input);
                    pcmBuffers.push(copy);
                };
                source.connect(scriptProcessor); scriptProcessor.connect(zg); zg.connect(ctx.destination);
                startWaveform();
            })
            .catch(function(err){
                isRecording=false; if(mic) mic.classList.remove('listening');
                if(cvs) cvs.style.display='none'; if(st) st.textContent='';
                var msg='无法获取麦克风：';
                if(err.name==='NotAllowedError') msg+='请允许麦克风权限';
                else if(err.name==='NotFoundError') msg+='未检测到麦克风';
                else msg+=err.message||'需要HTTPS或localhost';
                layer.msg(msg);
            });
    }

    function stopRecordingAndRecognize(){
        if(!isRecording) return; isRecording=false;
        var mic=document.getElementById('micButton');
        var cvs=document.getElementById('voiceWaveCanvas');
        var st=document.getElementById('voiceStatus');
        if(mic) mic.classList.remove('listening');
        if(cvs) cvs.style.display='none';
        if(st) st.textContent='⏳ 识别中...';
        stopWaveform();
        if(scriptProcessor){ try{scriptProcessor.disconnect();}catch(e){} scriptProcessor=null; }
        if(mediaStream){ mediaStream.getTracks().forEach(function(t){t.stop();}); mediaStream=null; }
        if(pcmBuffers.length>0){
            var blob=encodePCMToWAV(pcmBuffers,audioSampleRate);
            if(audioContext&&audioContext.state!=='closed'){ audioContext.close().catch(function(){}); audioContext=null; analyser=null; }
            uploadAndRecognize(blob,st);
        }else{
            layer.msg('录音太短，请按住再说'); if(st) st.textContent='';
        }
    }

    function concatFloat32(bufs){ var t=0,i; for(i=0;i<bufs.length;i++) t+=bufs[i].length; var r=new Float32Array(t); var o=0; for(i=0;i<bufs.length;i++){ r.set(bufs[i],o); o+=bufs[i].length; } return r; }
    function downsampleTo16k(sam,rate){ if(rate<=16050&&rate>=15950) return sam; var r=16000/rate; var ol=Math.floor(sam.length*r); var res=new Float32Array(ol); for(var i=0;i<ol;i++){ var si=i/r; var f=Math.floor(si); var c=Math.min(f+1,sam.length-1); var fr=si-f; res[i]=sam[f]*(1-fr)+sam[c]*fr; } return res; }

    function encodePCMToWAV(bufs,orgRate){
        var concat=concatFloat32(bufs);
        var samples=downsampleTo16k(concat,orgRate);
        var tr=16000;
        var i16=new Int16Array(samples.length);
        for(var i=0;i<samples.length;i++){ var s=Math.max(-1,Math.min(1,samples[i])); i16[i]=s<0?Math.round(s*0x8000):Math.round(s*0x7FFF); }
        var bc=i16.length*2; var buf=new ArrayBuffer(44+bc); var dv=new DataView(buf);
        function ws(d,o,s){ for(var i=0;i<s.length;i++) d.setUint8(o+i,s.charCodeAt(i)); }
        ws(dv,0,'RIFF'); dv.setUint32(4,36+bc,true); ws(dv,8,'WAVE'); ws(dv,12,'fmt '); dv.setUint32(16,16,true);
        dv.setUint16(20,1,true); dv.setUint16(22,1,true); dv.setUint32(24,tr,true);
        dv.setUint32(28,tr*2,true); dv.setUint16(32,2,true); dv.setUint16(34,16,true);
        ws(dv,36,'data'); dv.setUint32(40,bc,true);
        new Int16Array(buf,44,i16.length).set(i16);
        return new Blob([buf],{type:'audio/wav'});
    }

    function uploadAndRecognize(blob,st){
        var fd=new FormData(); fd.append('audio',blob,'rec.wav'); fd.append('sampleRate','16000');
        $.ajax({
            type:'POST', url:'${cp}/speechToText', data:fd, processData:false, contentType:false,
            success:function(res){
                if(st) st.textContent='';
                if(res.success){
                    document.getElementById('aiChatInput').value=res.text;
                    setTimeout(function(){ if(res.text) sendAiMessage(res.text); document.getElementById('aiChatInput').value=''; },200);
                }else{ layer.msg(res.message||'未识别到语音'); }
            },
            error:function(){ if(st) st.textContent=''; layer.msg('语音识别请求失败'); }
        });
    }

    function startWaveform(){ if(!analyser) return; var c=document.getElementById('voiceWaveCanvas'); if(!c) return; var ctx=c.getContext('2d'); c.width=c.offsetWidth; c.height=c.offsetHeight; drawWaveform(c,ctx); }
    function drawWaveform(cv,ctx){
        if(!analyser) return; var W=cv.width,H=cv.height;
        var bl=analyser.frequencyBinCount||64; var da=new Uint8Array(bl);
        function draw(){
            if(!isRecording) return; animFrameId=requestAnimationFrame(draw);
            analyser.getByteFrequencyData(da); ctx.clearRect(0,0,W,H);
            var bw=(W/bl)*1.5; var bg=2; var x=0;
            for(var i=0;i<bl;i++){
                var bh=(da[i]/255)*H*.9; if(bh<2) bh=2;
                var hue=(i/bl)*200+160; var light=40+(da[i]/255)*35;
                ctx.fillStyle='hsl('+hue+',60%,'+light+'%)';
                ctx.fillRect(x,H-bh,bw,bh);
                x+=bw+bg;
            }
        }
        draw();
    }
    function stopWaveform(){ if(animFrameId){ cancelAnimationFrame(animFrameId); animFrameId=null; } }

    // ============================================================
    //  Product Loading
    // ============================================================
    var loading=null;
    try { loading=layer.load(0); } catch(e) {}
    var productType=['','休闲零食','酒水饮料','方便速食','新鲜水果','日用百货','文具办公','其他'];

    try { listProducts(); } catch(e) { if(loading) layer.close(loading); }

    function listProducts(){
        var all=getAllProducts();
        if(!all||all.length===0){
            layer.msg("暂无商品数据"); layer.close(loading); return;
        }
        var mark=[0,0,0,0,0,0,0,0];
        var defaultIcons=['🍪','🥤','🍜','🍎','🧴','📚','🎁'];
        var carousels=[];

        for(var i=0;i<all.length;i++){
            var p=all[i]; var t=p.type;
            var imgURL="${cp}/img/"+p.img;
            var badge='';
            if(Math.random()<.15) badge='<div class="card-badge">热卖</div>';

            var card='<div class="card-shop" onclick="productDetail('+p.id+')">'+
                badge+
                '<div class="card-img"><img src="'+imgURL+'" alt="'+p.name+'"></div>'+
                '<div class="card-body">'+
                '<span class="name">'+p.name+'</span>'+
                '<span class="price">'+p.price+'</span>'+
                '</div></div>';

            var areaId='productArea'+t;
            var area=document.getElementById(areaId);
            if(!area) continue;

            if(mark[t]===0){
                var icon=defaultIcons[t-1]||'📦';
                var wrapId='carousel'+t;
                area.innerHTML=
                    '<div class="section-head"><span class="dot"></span><h2>'+icon+' '+productType[t]+'</h2><div class="bar"></div></div>'+
                    '<div class="carousel-wrap" id="'+wrapId+'">'+
                    '<button class="carousel-btn left" onclick="slideCarousel(\''+wrapId+'\',-1)">◀</button>'+
                    '<div class="carousel-track" id="track'+t+'">'+card+'</div>'+
                    '<button class="carousel-btn right" onclick="slideCarousel(\''+wrapId+'\',1)">▶</button>'+
                    '</div>';
                mark[t]=1;
                carousels.push({trackId:'track'+t, count:1});
            }else{
                document.getElementById('track'+t).innerHTML+=card;
                for(var ci=0;ci<carousels.length;ci++){
                    if(carousels[ci].trackId==='track'+t){ carousels[ci].count++; break; }
                }
            }
        }

        layer.close(loading);

        // 自动轮播（出错不影响商品显示）
        try {
            carousels.forEach(function(c, i){
                autoplayCarousel(c.trackId, i, c.count);
            });
        } catch(e) { console.log('Carousel error:', e); }
    }

    function slideCarousel(wrapId, dir){
        var track=document.getElementById('track'+wrapId.replace('carousel',''));
        if(!track) return;
        var card=track.querySelector('.card-shop');
        if(!card) return;
        var w=card.offsetWidth||160;
        track.scrollBy({left:dir*(w+14)*3, behavior:'smooth'});
    }

    function autoplayCarousel(trackId, index, count){
        var track=document.getElementById(trackId);
        if(!track) return;
        var gap=14;

        // 克隆填满至少两倍容器宽度
        function fillLoop(){
            var cards=track.querySelectorAll('.card-shop');
            if(!cards.length) return;
            var wrapW=(track.parentElement||{}).offsetWidth||900;
            var need=Math.max(Math.ceil(wrapW*2/((cards[0].offsetWidth||160)+gap))+4, 8);
            while(track.querySelectorAll('.card-shop').length<need){
                for(var i=0;i<Math.min(cards.length,need);i++){
                    track.appendChild(cards[i].cloneNode(true));
                }
            }
        }
        fillLoop();

        // 交替方向
        var dir=(index%2===0)?1:-1;
        // 统一速度：60fps 下约 90px/s
        var speed=1.5;
        if(dir<0) speed=-speed;

        // 原始内容宽度 = 容器宽度（确保始终有东西可滚）
        var origW=(track.parentElement||{}).offsetWidth||900;
        if(origW<300) origW=600;

        // 如果是反向，从中间开始
        if(dir<0) track.scrollLeft=origW*0.6;

        var raf, pausedUntil=0;

        function loop(ts){
            raf=requestAnimationFrame(loop);
            if(!track) return;
            if(ts<pausedUntil) return;

            track.scrollLeft+=speed;

            // 正向到头 → 回到起点
            if(dir>0 && track.scrollLeft>=origW) track.scrollLeft-=origW;
            // 反向到头 → 回到末尾
            if(dir<0 && track.scrollLeft<=0) track.scrollLeft+=origW;
        }

        function pause(e){
            pausedUntil=performance.now()+2000;
        }
        track.addEventListener('touchstart',pause);
        track.addEventListener('mousedown',pause);
        track.addEventListener('wheel',function(){ pausedUntil=performance.now()+1200; });

        raf=requestAnimationFrame(loop);
    }

    function getAllProducts(){
        var all=null;
        $.ajax({
            async:false, type:'POST', url:'${cp}/getAllProducts',
            data:{}, dataType:'json',
            success:function(r){ if(r) all=r.allProducts; else layer.alert('查询错误'); },
            error:function(){ layer.close(loading); layer.alert('连接服务器失败'); }
        });
        if(all) all=eval("("+all+")");
        return all;
    }

    function productDetail(id){
        var jump='';
        $.ajax({
            async:false, type:'POST', url:'${cp}/productDetail',
            data:{id:id}, dataType:'json',
            success:function(r){ jump=r.result; },
            error:function(){ layer.alert('查询错误'); }
        });
        if(jump==='success') window.location.href='${cp}/product_detail';
    }

    // Category bar: click scroll + scroll highlight
    (function(){
        var cats=document.querySelectorAll('#catBar a');
        var secs=[];
        for(var s=1;s<=7;s++){ var el=document.getElementById('productArea'+s); if(el) secs.push(el); }

        cats.forEach(function(cat){
            cat.addEventListener('click',function(e){
                e.preventDefault();
                var target=document.getElementById(this.getAttribute('href').replace('#',''));
                if(target) target.scrollIntoView({behavior:'smooth',block:'start'});
            });
        });

        window.addEventListener('scroll',function(){
            var sp=window.scrollY+180, cur=-1;
            for(var i=secs.length-1;i>=0;i--){ if(secs[i].offsetTop<=sp){ cur=i; break; } }
            cats.forEach(function(c,i){ c.classList.toggle('active',i===cur); });
        });
    })();

    // 从其他页面跳转来的周报自动打开
    if(window.location.hash==='#weekly-report'){
        history.replaceState(null,null,' ');
        setTimeout(function(){ if(typeof openReport==='function') openReport(); },600);
    }
</script>

</body>
</html>
