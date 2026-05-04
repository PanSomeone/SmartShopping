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
  </head>
  <body>
    <!--导航栏部分-->
	<jsp:include page="include/header.jsp"/>
	<!-- 中间内容 -->
	<div class="container-fluid">
		<div class="row">
			<!-- 控制栏 -->
			<div class="col-sm-3 col-md-2 sidebar sidebar-1">
				<ul class="nav nav-sidebar">
					<li class="list-group-item-diy"><a href="#productArea1">休闲零食 <span class="sr-only">(current)</span></a></li>
					<li class="list-group-item-diy"><a href="#productArea2">酒水饮料</a></li>
					<li class="list-group-item-diy"><a href="#productArea3">方便速食</a></li>
					<li class="list-group-item-diy"><a href="#productArea4">新鲜水果</a></li>
					<li class="list-group-item-diy"><a href="#productArea5">日用百货</a></li>
					<li class="list-group-item-diy"><a href="#productArea6">文具办公</a></li>
					<li class="list-group-item-diy"><a href="#productArea7">其他</a></li>
				</ul>
			</div>
			<!-- 控制内容 -->
			<div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
				<div class="jumbotron">
					<h1>欢迎来到智购</h1>
					<p>智购 —— 您的专属校园宿舍购物平台。专为本楼打造，零食饮料即刻送达，让大学生活更便捷！</p>
				</div>

				<div name="productArea1" class="row pd-10" id="productArea1">
				</div>

				<div name="productArea2" class="row" id="productArea2">
				</div>

				<div name="productArea3" class="row" id="productArea3">
				</div>

                <div name="productArea4" class="row" id="productArea4">
				</div>

				<div name="productArea5" class="row" id="productArea5">
				</div>

				<div name="productArea6" class="row" id="productArea6">
				</div>

				<div name="productArea7" class="row" id="productArea7">
				</div>


			</div>
			<div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2">
				<jsp:include page="include/foot.jsp"/>
			</div>
		</div>
	</div>

    <!-- AI 问答悬浮窗口 -->
    <div id="aiChatBox" style="position: fixed; bottom: 20px; right: 20px; width: 300px; height: 400px; background: white; border: 1px solid #ccc; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.2); display: flex; flex-direction: column; z-index: 1000;">
        <div style="background: #337ab7; color: white; padding: 10px; border-top-left-radius: 10px; border-top-right-radius: 10px; display: flex; justify-content: space-between; align-items: center;">
            <span style="font-weight: bold;">智购 AI 助手</span>
            <span style="cursor: pointer;" onclick="document.getElementById('aiChatBox').style.display='none'">关闭</span>
        </div>
        <div id="aiChatContent" style="flex: 1; padding: 10px; overflow-y: auto; background: #f9f9f9; display: flex; flex-direction: column; gap: 10px;">
            <div style="background: #e1f5fe; padding: 8px; border-radius: 5px; align-self: flex-start; max-width: 80%;">您好！我是智购小助手，有什么可以帮您？</div>
        </div>
        <div style="padding: 10px; border-top: 1px solid #eee; display: flex;">
            <input type="text" id="aiChatInput" placeholder="输入您的问题..." style="flex: 1; padding: 5px; border: 1px solid #ccc; border-radius: 3px;" onkeypress="if(event.keyCode===13) sendAiMessage()">
            <button onclick="sendAiMessage()" style="margin-left: 5px; background: #337ab7; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer;">发送</button>
        </div>
    </div>
    <div id="aiChatIcon" style="position: fixed; bottom: 20px; right: 20px; background: #337ab7; color: white; width: 50px; height: 50px; border-radius: 25px; display: none; justify-content: center; align-items: center; cursor: pointer; box-shadow: 0 4px 8px rgba(0,0,0,0.2); z-index: 999; font-size: 24px;" onclick="document.getElementById('aiChatBox').style.display='flex'; this.style.display='none';">💬</div>

  <script type="text/javascript">
      function sendAiMessage() {
          var input = document.getElementById('aiChatInput');
          var text = input.value.trim();
          if(text) {
              var content = document.getElementById('aiChatContent');
              content.innerHTML += '<div style="background: #c8e6c9; padding: 8px; border-radius: 5px; align-self: flex-end; max-width: 80%;">' + text + '</div>';
              input.value = '';
              content.innerHTML += '<div style="background: #e1f5fe; padding: 8px; border-radius: 5px; align-self: flex-start; max-width: 80%;">收到您的问题：“' + text + '”，AI 功能正在开发中，敬请期待！</div>';
              content.scrollTop = content.scrollHeight;
          }
      }

      // 监听聊天框关闭事件，显示悬浮图标
      document.querySelector('#aiChatBox span:last-child').onclick = function() {
          document.getElementById('aiChatBox').style.display = 'none';
          document.getElementById('aiChatIcon').style.display = 'flex';
      };

	  var loading = layer.load(0);

      var productType = new Array;
      productType[1] = "休闲零食";
      productType[2] = "酒水饮料";
      productType[3] = "方便速食";
      productType[4] = "新鲜水果";
      productType[5] = "日用百货";
      productType[6] = "文具办公";
      productType[7] = "其他";


	  listProducts();

	  function listProducts() {
		  var allProduct = getAllProducts();
          if (!allProduct || allProduct.length === 0) {
              layer.msg("暂无商品数据，请检查数据库配置并执行初始化SQL");
              layer.close(loading);
              return;
          }
          var mark = new Array;
          mark[1] = 0;
          mark[2] = 0;
          mark[3] = 0;
          mark[4] = 0;
          mark[5] = 0;
          mark[6] = 0;
          mark[7] = 0;
          for(var i=0;i<allProduct.length;i++){
              var html = "";
              var product=allProduct[i];
              var imgURL = "${cp}/img/"+product.img;
			  html += '<div class="col-sm-4 col-md-4" >'+
					  '<div class="boxes pointer" onclick="productDetail('+allProduct[i].id+')">'+
					  '<div class="big bigimg">'+
					  '<img  src="'+imgURL+'" width:20px height:10px>'+
					  '</div>'+
					  '<p class="product-name">'+allProduct[i].name+'</p>'+
					  '<p class="product-price">¥'+allProduct[i].price+'</p>'+
					  '</div>'+
					  '</div>';
              var id = "productArea"+allProduct[i].type;
              var productArea = document.getElementById(id);
              if(mark[allProduct[i].type] == 0){
                  html ='<hr/><h1>'+productType[allProduct[i].type]+'</h1><hr/>'+html;
                  mark[allProduct[i].type] = 1;
              }
              productArea.innerHTML += html;
		  }
		  layer.close(loading);
	  }
	  function getAllProducts() {
		  var allProducts = null;
		  var nothing = {};
		  $.ajax({
			  async : false, //设置同步
			  type : 'POST',
			  url : '${cp}/getAllProducts',
			  data : nothing,
			  dataType : 'json',
			  success : function(result) {
				  if (result!=null) {
					  allProducts = result.allProducts;
				  }
				  else{
					  layer.alert('查询错误');
				  }
			  },
			  error : function(resoult) {
				  layer.close(loading);
				  layer.alert('连接服务器失败，请检查后端程序是否启动');
			  }
		  });
		  //划重点划重点，这里的eval方法不同于prase方法，外面加括号
          if (allProducts) {
		    allProducts = eval("("+allProducts+")");
          }
		  return allProducts;
	  }

	  function productDetail(id) {
		  var product = {};
		  var jumpResult = '';
		  product.id = id;
		  $.ajax({
			  async : false, //设置同步
			  type : 'POST',
			  url : '${cp}/productDetail',
			  data : product,
			  dataType : 'json',
			  success : function(result) {
				  jumpResult = result.result;
			  },
			  error : function(resoult) {
				  layer.alert('查询错误');
			  }
		  });

		  if(jumpResult == "success"){
			  window.location.href = "${cp}/product_detail";
		  }
	  }

  </script>


  </body>
</html>