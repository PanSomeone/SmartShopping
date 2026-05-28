package com.shopping.controller;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.shopping.entity.Product;
import com.shopping.entity.ShoppingCar;
import com.shopping.entity.User;
import com.shopping.service.AiService;
import com.shopping.service.ProductService;
import com.shopping.service.ShoppingCarService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class AiController {
    @Resource
    private AiService aiService;
    @Resource
    private ProductService productService;
    @Resource
    private ShoppingCarService shoppingCarService;

    @SuppressWarnings("unchecked")
    @RequestMapping(value = "/aiChat", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> aiChat(String message, String historyJson, HttpSession session) {
        Map<String, Object> resultMap = new HashMap<>();

        // 获取当前用户角色：0=普通买家, 1=商家, 未登录默认0
        int role = 0;
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser != null) {
            role = currentUser.getRole();
        }

        // 从参数获取对话历史，如果客户端传了就用客户端的，否则从session取
        List<Map<String, String>> history = new ArrayList<>();
        if (historyJson != null && !historyJson.isEmpty()) {
            try {
                JSONArray arr = JSONArray.parseArray(historyJson);
                for (int i = 0; i < arr.size(); i++) {
                    JSONObject item = arr.getJSONObject(i);
                    Map<String, String> m = new HashMap<>();
                    m.put("role", item.getString("role"));
                    m.put("content", item.getString("content"));
                    history.add(m);
                }
            } catch (Exception e) {
                // 解析失败则使用 session 历史回退
                Object sessionHistory = session.getAttribute("aiChatHistory");
                if (sessionHistory instanceof List) {
                    history = (List<Map<String, String>>) sessionHistory;
                }
            }
        } else {
            Object sessionHistory = session.getAttribute("aiChatHistory");
            if (sessionHistory instanceof List) {
                history = (List<Map<String, String>>) sessionHistory;
            }
        }

        String aiResponse = aiService.chat(message, history, role);

        // 将本轮对话存入历史
        Map<String, String> userTurn = new HashMap<>();
        userTurn.put("role", "user");
        userTurn.put("content", message);
        history.add(userTurn);

        // 尝试解析 JSON 指令，处理可能存在的 Markdown 代码块包裹
        try {
            String cleanResponse = aiResponse.trim();
            if (cleanResponse.startsWith("```json")) {
                cleanResponse = cleanResponse.substring(7, cleanResponse.lastIndexOf("```")).trim();
            } else if (cleanResponse.startsWith("```")) {
                cleanResponse = cleanResponse.substring(3, cleanResponse.lastIndexOf("```")).trim();
            }

            if (cleanResponse.startsWith("{")) {
                JSONObject json = JSONObject.parseObject(cleanResponse);
                String action = json.getString("action");
                String productName = json.getString("product_name");
                Product product = productService.getProduct(productName);

                if (("add_to_cart".equals(action) || "recommend_product".equals(action)) && role == 1) {
                    // 商家不能执行购物操作
                    String replyText = "老板，这是顾客功能哦～你需要处理订单可以去左侧导航栏「处理订单」查看。";
                    resultMap.put("type", "text");
                    resultMap.put("message", replyText);
                    Map<String, String> aiTurn = new HashMap<>();
                    aiTurn.put("role", "assistant");
                    aiTurn.put("content", replyText);
                    history.add(aiTurn);
                    session.setAttribute("aiChatHistory", history);
                    return resultMap;
                }
                if ("add_to_cart".equals(action) && product != null) {
                    if (currentUser != null) {
                        int userId = currentUser.getId();
                        int count = json.getIntValue("count");
                        if (count <= 0) count = 1;

                        // 检查购物车中是否已存在该商品
                        ShoppingCar existingCar = shoppingCarService.getShoppingCar(userId, product.getId());
                        if (existingCar == null) {
                            // 不存在，新增
                            ShoppingCar shoppingCar = new ShoppingCar();
                            shoppingCar.setUserId(userId);
                            shoppingCar.setProductId(product.getId());
                            shoppingCar.setCounts(count);
                            shoppingCar.setProductPrice(product.getPrice() * count);
                            shoppingCarService.addShoppingCar(shoppingCar);
                        } else {
                            // 已存在，更新数量
                            int newCounts = existingCar.getCounts() + count;
                            existingCar.setCounts(newCounts);
                            existingCar.setProductPrice(product.getPrice() * newCounts);
                            shoppingCarService.updateShoppingCar(existingCar);
                        }

                        String replyText = "已为您将 " + productName + " 加入购物车。";
                        resultMap.put("type", "text");
                        resultMap.put("message", replyText);

                        // AI的回复也存入历史
                        Map<String, String> aiTurn = new HashMap<>();
                        aiTurn.put("role", "assistant");
                        aiTurn.put("content", replyText);
                        history.add(aiTurn);
                        session.setAttribute("aiChatHistory", history);
                        return resultMap;
                    }
                } else if ("recommend_product".equals(action) && product != null) {
                    String replyText = "为您推荐：" + productName;
                    resultMap.put("type", "recommend");
                    resultMap.put("product", product);
                    resultMap.put("message", replyText);

                    // AI的回复也存入历史
                    Map<String, String> aiTurn = new HashMap<>();
                    aiTurn.put("role", "assistant");
                    aiTurn.put("content", replyText);
                    history.add(aiTurn);
                    session.setAttribute("aiChatHistory", history);
                    return resultMap;
                }
            }
        } catch (Exception e) {
            // 解析失败，忽略，走默认流程
        }

        // 默认逻辑: 将AI回复直接返回，不做额外动作
        Map<String, String> aiTurn = new HashMap<>();
        aiTurn.put("role", "assistant");
        aiTurn.put("content", aiResponse);
        history.add(aiTurn);
        session.setAttribute("aiChatHistory", history);

        resultMap.put("type", "text");
        resultMap.put("message", aiResponse);
        return resultMap;
    }
}