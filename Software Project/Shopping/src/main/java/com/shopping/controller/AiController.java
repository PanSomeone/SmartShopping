package com.shopping.controller;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.shopping.entity.Product;
import com.shopping.entity.ShoppingCar;
import com.shopping.entity.ShoppingRecord;
import com.shopping.entity.User;
import com.shopping.service.AiService;
import com.shopping.service.ProductService;
import com.shopping.service.ShoppingCarService;
import com.shopping.service.ShoppingRecordService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import java.text.SimpleDateFormat;
import java.util.*;

@Controller
public class AiController {
    @Resource
    private AiService aiService;
    @Resource
    private ProductService productService;
    @Resource
    private ShoppingCarService shoppingCarService;
    @Resource
    private ShoppingRecordService shoppingRecordService;

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

    /**
     * AI 购物周报
     */
    @RequestMapping(value = "/weeklyReport", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> weeklyReport(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            result.put("success", false);
            result.put("message", "请先登录后再查看购物周报");
            return result;
        }

        try {
            // === 计算本周日期范围(周一~周日) ===
            SimpleDateFormat dateFmt = new SimpleDateFormat("MM/dd");
            Calendar cal = Calendar.getInstance();
            int todayDow = cal.get(Calendar.DAY_OF_WEEK); // 1=Sun...7=Sat
            int daysFromMon = todayDow == Calendar.SUNDAY ? 6 : todayDow - 2;
            cal.add(Calendar.DAY_OF_YEAR, -daysFromMon);
            Date monDate = cal.getTime();
            cal.add(Calendar.DAY_OF_YEAR, 6);
            Date sunDate = cal.getTime();
            String dateRange = dateFmt.format(monDate) + " - " + dateFmt.format(sunDate);

            // 重置回周一00:00
            cal.setTime(monDate);
            cal.set(Calendar.HOUR_OF_DAY, 0);
            cal.set(Calendar.MINUTE, 0);
            cal.set(Calendar.SECOND, 0);
            Date weekStart = cal.getTime();

            // === 查询购物记录 ===
            List<ShoppingRecord> records = shoppingRecordService.getShoppingRecords(currentUser.getId());
            if (records == null) records = new ArrayList<>();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH-mm-ss");

            List<ShoppingRecord> recentRecords = new ArrayList<>();
            StringBuilder cacheHash = new StringBuilder();
            for (ShoppingRecord r : records) {
                try {
                    Date d = sdf.parse(r.getTime());
                    if (d != null && !d.before(weekStart)) {
                        recentRecords.add(r);
                        cacheHash.append(r.getProductId()).append(":").append(r.getTime()).append(";");
                    }
                } catch (Exception ignored) {}
            }

            if (recentRecords.isEmpty()) {
                result.put("success", true);
                result.put("message", "本周暂无购物记录，先去逛逛吧~");
                return result;
            }

            // === 缓存检查 ===
            String hash = String.valueOf(cacheHash.toString().hashCode());
            Integer weekNum = (Integer) session.getAttribute("reportWeek");
            Integer regenCount = (Integer) session.getAttribute("reportRegenCount");
            String cachedHash = (String) session.getAttribute("reportHash");
            String cachedReport = (String) session.getAttribute("reportCache");

            Calendar now = Calendar.getInstance();
            int currentWeek = now.get(Calendar.WEEK_OF_YEAR);
            if (weekNum == null || weekNum != currentWeek) {
                regenCount = 0;
                weekNum = currentWeek;
            }

            // 如果缓存命中且购物记录无变化，直接返回缓存
            if (cachedReport != null && hash.equals(cachedHash)) {
                result.put("success", true);
                result.put("report", JSONObject.parseObject(cachedReport));
                result.put("cached", true);
                return result;
            }

            // 超过3次不再重新生成
            if (regenCount != null && regenCount >= 3 && cachedReport != null) {
                result.put("success", true);
                result.put("report", JSONObject.parseObject(cachedReport));
                result.put("cached", true);
                result.put("limitReached", true);
                return result;
            }

            // === 统计分析 ===
            StringBuilder data = new StringBuilder();
            int totalSpent = 0, totalItems = 0, lateNightCount = 0;
            Map<String, Integer> catMap = new HashMap<>();
            Map<String, Integer> hourMap = new HashMap<>();
            Map<String, Integer> dayMap = new HashMap<>();
            String[] weeks = {"周日","周一","周二","周三","周四","周五","周六"};
            Map<String, String> typeNames = new HashMap<>();
            typeNames.put("1","休闲零食");typeNames.put("2","酒水饮料");typeNames.put("3","方便速食");
            typeNames.put("4","新鲜水果");typeNames.put("5","日用百货");typeNames.put("6","文具办公");typeNames.put("7","其他");

            for (ShoppingRecord r : recentRecords) {
                try {
                    Product p = productService.getProduct(r.getProductId());
                    String name = p != null ? p.getName() : "商品";
                    String cat = p != null ? String.valueOf(p.getType()) : "0";
                    Date d = sdf.parse(r.getTime());
                    if (d == null) continue;
                    int hour = d.getHours();
                    String day = weeks[d.getDay()];
                    int qty = r.getCounts();
                    int price = r.getProductPrice();

                    data.append("- ").append(day).append(hour).append(":00 买")
                        .append(name).append(" x").append(qty).append(" ¥").append(price).append("\n");
                    totalSpent += price;
                    totalItems += qty;
                    if (hour >= 22 || hour < 6) lateNightCount++;
                    String cn = typeNames.getOrDefault(cat, cat);
                    catMap.put(cn, catMap.getOrDefault(cn, 0) + 1);
                    hourMap.put(hour + "点", hourMap.getOrDefault(hour + "点", 0) + 1);
                    dayMap.put(day, dayMap.getOrDefault(day, 0) + 1);
                } catch (Exception inner) { continue; }
            }

            if (totalItems == 0) {
                result.put("success", true);
                result.put("message", "本周暂无有效购物记录");
                return result;
            }

            String topCat = catMap.isEmpty() ? "未知" :
                catMap.entrySet().stream().max(Map.Entry.comparingByValue()).get().getKey();
            String topHour = hourMap.isEmpty() ? "未知" :
                hourMap.entrySet().stream().max(Map.Entry.comparingByValue()).get().getKey();
            String peakDayFallback = dayMap.isEmpty() ? "每天" :
                dayMap.entrySet().stream().max(Map.Entry.comparingByValue()).get().getKey();

            // === 健康提醒 ===
            String healthTip = "";
            if ("方便速食".equals(topCat)) {
                healthTip = "方便速食虽然快捷，记得搭配蔬菜水果营养更均衡哦~";
            } else if ("休闲零食".equals(topCat) && lateNightCount > 3) {
                healthTip = "晚上可以少吃零食，给肠胃放个假~";
            } else if ("休闲零食".equals(topCat)) {
                healthTip = "零食虽好，可不要贪吃哦，适量运动更健康~";
            } else if ("酒水饮料".equals(topCat)) {
                healthTip = "多喝水，少喝含糖饮料，身体会感谢你的~";
            } else if (lateNightCount > 5) {
                healthTip = "深夜购物虽快乐，但早睡早起才是王道~";
            } else if (totalItems > 15) {
                healthTip = "囤货是门艺术，但适度消费更从容~";
            } else {
                healthTip = "购物要理性，健康第一位，加油哦~";
            }

            // === 兜底数据 ===
            String[] titles = {"购物达人","零食收藏家","深夜觅食者","佛系买家","囤货狂魔","精打细算王","速食爱好者"};
            String titleFallback = titles[Math.abs(currentUser.getId()) % titles.length];
            String peakHourFallback = topHour.isEmpty() ? "任意时段" : topHour;

            // === 尝试 AI 生成 ===
            JSONObject report = null;
            try {
                String prompt = data.toString() +
                    "\n根据以上数据生成趣味购物周报JSON（含健康提醒）。统计：总花费¥"+totalSpent+
                    "，总件数"+totalItems+"，最爱品类"+topCat+
                    "，下单高峰"+peakHourFallback+
                    "\n严格输出纯JSON（无markdown）：\n"+
                    "{\"title\":\"有趣头衔4-6字\",\"total_items\":"+totalItems+
                    ",\"total_spent\":"+totalSpent+
                    ",\"top_category\":\""+topCat+
                    "\",\"peak_hour\":\""+peakHourFallback+
                    "\",\"peak_day\":\""+peakDayFallback+
                    "\",\"comment\":\"幽默点评30字\",\"health_tip\":\""+healthTip+
                    "\",\"recommend\":[\"推1\",\"推2\",\"推3\"]}";

                String aiResp = aiService.chat(prompt, new ArrayList<>(), 0);
                if (aiResp != null && !aiResp.contains("暂不可用")) {
                    String clean = aiResp.trim();
                    if (clean.startsWith("```json")) clean = clean.substring(7, clean.lastIndexOf("```")).trim();
                    else if (clean.startsWith("```")) clean = clean.substring(3, clean.lastIndexOf("```")).trim();
                    if (clean.startsWith("{")) report = JSONObject.parseObject(clean);
                }
            } catch (Exception aiEx) {
                System.err.println("[WeeklyReport] AI生成失败: " + aiEx.getMessage());
            }

            if (report == null) {
                report = new JSONObject();
                report.put("title", titleFallback);
                report.put("total_items", totalItems);
                report.put("total_spent", totalSpent);
                report.put("top_category", topCat);
                report.put("peak_hour", peakHourFallback);
                report.put("peak_day", peakDayFallback);
                report.put("comment", "本周你在"+topCat+"上花了最多钱，下单高峰在"+peakHourFallback+"！");
                report.put("health_tip", healthTip);
                report.put("recommend", new String[]{topCat+"爆款","热门饮料","夜宵必备"});
            }

            if (!report.containsKey("health_tip")) report.put("health_tip", healthTip);

            // === 缓存报告 ===
            report.put("date_range", dateRange);
            session.setAttribute("reportCache", report.toJSONString());
            session.setAttribute("reportHash", hash);
            session.setAttribute("reportWeek", currentWeek);
            session.setAttribute("reportRegenCount", (regenCount == null ? 0 : regenCount) + 1);

            result.put("success", true);
            result.put("report", report);
            result.put("cached", false);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "周报生成异常: " + e.getMessage());
        }
        return result;
    }
}