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
import java.util.List;
import java.util.Random;


@Service("aiService")
public class AiServiceImplement implements AiService {
    @Resource
    private ProductService productService;

    // TODO: 1. 替换为你实际申请的API地址和Key
    private static final String API_URL = "https://poloai.top/v1/chat/completions";
    private static final String API_KEY = "sk-2HjjpbE4ZMIW4Zei0fMR5CvVbQ3yCg0hXw2XjUVkEPSR8TUh";

    public String chat(String message) {
        // 移除硬编码的推荐逻辑判断，交由AI大模型自身判断是否输出结构化指令
        // 原有逻辑：if (message.contains("推荐") || message.contains("吃什么")) { return "推荐"; }
        // 现在，将完全依赖AI大模型是否根据system prompt输出JSON


        // 获取所有商品列表作为上下文
        List<Product> allProducts = productService.getAllProduct();
        StringBuilder productList = new StringBuilder();
        if (allProducts != null) {
            for (Product p : allProducts) {
                productList.append(p.getName()).append(", ");
            }
        }

        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            HttpPost post = new HttpPost(API_URL);
            post.setHeader("Content-Type", "application/json");
            post.setHeader("Authorization", "Bearer " + API_KEY);

            JSONObject json = new JSONObject();
            json.put("model", "gpt-4o-mini"); 
            
            // 构建系统消息和用户消息
            JSONObject systemMsg = new JSONObject();
            systemMsg.put("role", "system");
            systemMsg.put("content", "你是一个购物助手。目前有以下商品：" + productList.toString() + "。\n" +
                                       "严格遵循以下规则响应用户的请求：\n" +
                                       "1. **普通对话**：如果用户的问题是闲聊、一般咨询、对你回复的评论（如“你咋推荐的这么快”），或没有明确的商品购买/推荐意图，请使用**自然语言**直接回复，不要输出JSON。\n" +
                                       "2. **商品操作**：\n" +
                                       "   - 如果用户明确表示要**推荐**某个商品，或者询问**购买**、**添加到购物车**某个商品（例如：“推荐薯片”，“我想买可乐”，“把方便面加到购物车”），并且该商品在上述商品列表中，请以**严格的JSON格式**输出，**不要添加任何额外文字**。JSON格式必须是以下两种之一：\n" +
                                       "     - **推荐商品**：`{\"action\": \"recommend_product\", \"product_name\": \"[商品名称]\"}`\n" +
                                       "     - **加入购物车**：`{\"action\": \"add_to_cart\", \"product_name\": \"[商品名称]\", \"count\": [数量，默认为1]}`\n" +
                                       "   - 如果用户提到的商品不在你的商品列表里，请礼貌地告知用户无法提供该商品，并引导用户选择其他商品。**此时也应使用自然语言回复，不要输出JSON。**\n" +
                                       "3. **JSON输出必须是完整的、单独的JSON对象，不能包含Markdown或其他任何文本包装。**\n" +
                                       "4. **商品名称必须精确匹配可用商品列表中的名称。**");
            
            JSONObject userMsg = new JSONObject();
            userMsg.put("role", "user");
            userMsg.put("content", message);
            
            json.put("messages", new JSONObject[]{systemMsg, userMsg});

            post.setEntity(new StringEntity(json.toString(), "UTF-8"));

            try (CloseableHttpResponse response = httpClient.execute(post)) {
                String responseBody = EntityUtils.toString(response.getEntity());
                JSONObject result = JSONObject.parseObject(responseBody);
                // 示例解析路径，需根据具体API文档调整
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
