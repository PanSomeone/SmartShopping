package com.shopping.service;

import java.util.Map;

public interface AiService {
    // 简单的聊天接口，返回AI的回复
    String chat(String message);
    
    // 获取推荐商品逻辑，返回推荐商品的ID
    int recommendProduct();
}
