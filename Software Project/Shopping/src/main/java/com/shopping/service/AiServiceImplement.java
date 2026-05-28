package com.shopping.service;

import com.alibaba.fastjson.JSONArray; // Added for parsing JSON arrays
import com.alibaba.fastjson.JSONObject;
import com.shopping.entity.Product;
import org.apache.http.HttpEntity; // Added
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.springframework.stereotype.Service;
import javax.annotation.Resource;
import java.io.IOException; // Added for exception handling
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Random;


@Service("aiService")
public class AiServiceImplement implements AiService {
    @Resource
    private ProductService productService;

    // TODO: 1. 替换为你实际申请的API地址和Key
    private static final String API_URL = "https://poloai.top/v1/chat/completions";
    private static final String API_KEY = "sk-2HjjpbE4ZMIW4Zei0fMR5CvVbQ3yCg0hXw2XjUVkEPSR8TUh";

    public String chat(String message, List<Map<String, String>> history, int role) {
        List<Product> allProducts = productService.getAllProduct();
        StringBuilder productList = new StringBuilder();
        if (allProducts != null) {
            for (Product p : allProducts) {
                productList.append(p.getName()).append(", ");
            }
        }

        String systemPrompt;
        if (role == 1) {
            // ====== 商家模式 ======
            systemPrompt = "你是智购平台的商家管理助手，专门帮助商户经营店铺。当前店铺商品：" + productList.toString() + "\n" +
                "你的职责：\n" +
                "1. 解答商家关于订单处理、库存管理、店铺运营的问题\n" +
                "2. 帮商家分析哪些商品卖得好，哪些需要补货\n" +
                "3. 根据商家的需求，提供上架/下架建议\n" +
                "4. 回答关于平台使用、订单状态查看的问题\n" +
                "\n" +
                "规则：\n" +
                "- 使用自然、友好的中文对话，称呼用户为「老板」\n" +
                "- 如果商家问「我的订单」「有哪些订单」「处理订单」，告诉他们去左侧导航栏「处理订单」查看\n" +
                "- 如果商家问「管理商品」「上架」「下架」，告诉他们去左侧导航栏「商品管理」\n" +
                "- 主动提供经营建议，比如推荐进货热门品类\n" +
                "- 不要推荐商品给商家本人购买，商家是卖家不是买家";
        } else {
            // ====== 顾客模式（含未登录） ======
            systemPrompt = "你是智购平台的AI购物小助手。目前可用商品清单：" + productList.toString() + "\n" +
                "请始终使用自然语言与用户对话，但在以下情况必须输出严格JSON：\n" +
                "1. **推荐商品**：当用户明确请你推荐某类/某个商品，或表达了购买意向（如「我想买薯片」、「推荐个饮料」、「来包辣条」、「帮我加到购物车里」），且你能从**对话上下文**或**当前消息**中确定具体商品时，输出：\n" +
                "   {\"action\":\"recommend_product\",\"product_name\":\"[精确商品名]\"}\n" +
                "2. **加入购物车**：当用户明确要求把商品加入购物车（如「加到购物车」、「帮我下单」、「买了」），且你能从**对话上下文**或**当前消息**中确定具体商品时，输出：\n" +
                "   {\"action\":\"add_to_cart\",\"product_name\":\"[精确商品名]\",\"count\":[数量，默认1]}\n" +
                "\n" +
                "关键规则：\n" +
                "- **重视上下文**：仔细查看对话历史。如果用户说「帮我加到购物车里呗」而没有提商品名，请结合对话历史上你刚推荐/讨论过的商品来推断。\n" +
                "- **主动推荐**：如果用户表达了模糊需求（如「想喝水」、「饿了」），请从可用商品中选一个合适的，直接输出推荐JSON，不要反问用户。\n" +
                "- 商品名必须精确匹配清单中的名称。\n" +
                "- JSON必须独立存在，不含Markdown标记、不换行包裹、不添加任何解释文字。\n" +
                "- 如果无法确定商品且用户没有给你足够信息，才用自然语言友好询问。";
        }

        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            HttpPost post = new HttpPost(API_URL);
            post.setHeader("Content-Type", "application/json");
            post.setHeader("Authorization", "Bearer " + API_KEY);

            JSONObject json = new JSONObject();
            json.put("model", "gpt-4o-mini");

            List<JSONObject> messageList = new ArrayList<>();

            JSONObject systemMsg = new JSONObject();
            systemMsg.put("role", "system");
            systemMsg.put("content", systemPrompt);
            messageList.add(systemMsg);

            // 2. 历史消息（最近10轮，避免token过长）
            if (history != null && !history.isEmpty()) {
                int start = Math.max(0, history.size() - 20); // 最多最近10轮（20条）
                for (int i = start; i < history.size(); i++) {
                    JSONObject histMsg = new JSONObject();
                    histMsg.put("role", history.get(i).get("role"));
                    histMsg.put("content", history.get(i).get("content"));
                    messageList.add(histMsg);
                }
            }

            // 3. 当前用户消息
            JSONObject userMsg = new JSONObject();
            userMsg.put("role", "user");
            userMsg.put("content", message);
            messageList.add(userMsg);

            json.put("messages", messageList);

            post.setEntity(new StringEntity(json.toString(), "UTF-8"));

            try (CloseableHttpResponse response = httpClient.execute(post)) {
                String responseBody = EntityUtils.toString(response.getEntity());
                JSONObject result = JSONObject.parseObject(responseBody);
                return result.getJSONArray("choices").getJSONObject(0).getJSONObject("message").getString("content");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "AI服务暂不可用。";
        }
    }

    public int recommendProduct() {
        List<Product> products = productService.getAllProduct();
        if (products != null && !products.isEmpty()) {
            return products.get(new Random().nextInt(products.size())).getId();
        }
        return -1;
    }
}