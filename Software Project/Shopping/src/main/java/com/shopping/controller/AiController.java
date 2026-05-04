package com.shopping.controller;

import com.alibaba.fastjson.JSONObject;
import com.shopping.entity.Product;
import com.shopping.entity.ShoppingCar; // Added import for ShoppingCar
import com.shopping.service.AiService;
import com.shopping.service.ProductService;
import com.shopping.service.ShoppingCarService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
public class AiController {
    @Resource
    private AiService aiService;
    @Resource
    private ProductService productService;
    @Resource
    private ShoppingCarService shoppingCarService;

    @RequestMapping(value = "/aiChat", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> aiChat(String message, HttpSession session) {
        Map<String, Object> resultMap = new HashMap<>();
        String aiResponse = aiService.chat(message);
        
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

                if ("add_to_cart".equals(action) && product != null) {
                    Integer userIdObj = (Integer) session.getAttribute("userId");
                    if (userIdObj != null) {
                        int userId = userIdObj;
                        ShoppingCar shoppingCar = new ShoppingCar();
                        shoppingCar.setUserId(userId);
                        shoppingCar.setProductId(product.getId());
                        int count = json.getIntValue("count");
                        shoppingCar.setCounts(count);
                        shoppingCar.setProductPrice(product.getPrice() * count);
                        shoppingCarService.addShoppingCar(shoppingCar);
                        resultMap.put("type", "text");
                        resultMap.put("message", "已为您将 " + productName + " 加入购物车。");
                        return resultMap;
                    }
                } else if ("recommend_product".equals(action) && product != null) {
                    resultMap.put("type", "recommend");
                    resultMap.put("product", product);
                    resultMap.put("message", "为您推荐：" + productName);
                    return resultMap;
                }
            }
        } catch (Exception e) {
            // 解析失败，忽略，走默认流程
        }
        
        // 默认逻辑: 将AI回复直接返回，不做额外动作
        resultMap.put("type", "text");
        resultMap.put("message", aiResponse);
        return resultMap;
    }
}
