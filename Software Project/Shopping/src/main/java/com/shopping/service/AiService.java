package com.shopping.service;

import java.util.List;
import java.util.Map;

public interface AiService {
    String chat(String message, List<Map<String, String>> history, int role);

    int recommendProduct();
}