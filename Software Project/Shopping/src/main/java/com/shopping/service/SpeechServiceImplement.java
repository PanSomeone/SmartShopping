package com.shopping.service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.*;
import java.net.URL;
import java.net.URLConnection;

@Service
public class SpeechServiceImplement implements SpeechService {

    // ========== 百度语音识别配置 ==========
    // 请前往 https://console.bce.baidu.com/ai/#/ai/speech/overview/index 创建应用获取
    private static final String API_KEY    = "xdDW6xOCQaTXPhmWoiAAYn60";     // ← 改成你自己的 API Key
    private static final String SECRET_KEY = "1pbcldfHVhpgJgBLcAdOJJCHy06xKrEI";  // ← 改成你自己的 Secret Key
    private static final String TOKEN_URL  = "https://aip.baidubce.com/oauth/2.0/token";
    private static final String ASR_URL    = "https://vop.baidu.com/server_api";
    // =======================================

    private String accessToken;
    private long tokenExpireTime;

    @PostConstruct
    public void init() {
        refreshToken();
    }

    @Override
    public String speechToText(byte[] audioData, int sampleRate) {
        // 不拆 WAV 头，直接把整个 WAV 文件发给百度解析，避免头解析错误
        boolean isWav = audioData.length > 44
                && audioData[0] == 'R' && audioData[1] == 'I'
                && audioData[2] == 'F' && audioData[3] == 'F';

        // 从 WAV 头读取真实采样率
        if (isWav) {
            int wavRate = (audioData[24] & 0xFF)
                    | ((audioData[25] & 0xFF) << 8)
                    | ((audioData[26] & 0xFF) << 16)
                    | ((audioData[27] & 0xFF) << 24);
            if (wavRate > 0) {
                sampleRate = wavRate;
            }
            System.out.println("[SpeechService] WAV头采样率=" + wavRate + "Hz, 格式=wav, 大小=" + audioData.length);
        }

        String format = isWav ? "wav" : "pcm";
        return callBaiduAsr(audioData, sampleRate, format);
    }

    /**
     * 获取百度 access_token
     */
    private synchronized void refreshToken() {
        // 如果 token 还没过期（提前 5 分钟刷新）
        if (accessToken != null && System.currentTimeMillis() < tokenExpireTime - 300000) {
            return;
        }
        try {
            String urlStr = TOKEN_URL + "?grant_type=client_credentials"
                    + "&client_id=" + API_KEY
                    + "&client_secret=" + SECRET_KEY;
            URL url = new URL(urlStr);
            URLConnection conn = url.openConnection();
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            try {
                BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) sb.append(line);
                reader.close();

                JSONObject json = JSONObject.parseObject(sb.toString());
                if (json.containsKey("access_token")) {
                    accessToken = json.getString("access_token");
                    tokenExpireTime = System.currentTimeMillis() + json.getLongValue("expires_in") * 1000;
                    System.out.println("[SpeechService] 百度 access_token 获取成功，有效期至: " + new java.util.Date(tokenExpireTime));
                } else {
                    String errDesc = json.containsKey("error_description") ? json.getString("error_description") : "无错误描述";
                    System.err.println("[SpeechService] ⚠ 获取 token 失败: " + sb);
                    System.err.println("[SpeechService] ⚠ 错误详情: " + errDesc);
                    System.err.println("[SpeechService] ⚠ 请检查 API_KEY/SECRET_KEY 是否在百度AI控制台正确创建了语音识别应用");
                }
            } catch (java.io.IOException ioEx) {
                // 读取错误流
                java.io.InputStream errStream = ((java.net.HttpURLConnection) conn).getErrorStream();
                if (errStream != null) {
                    BufferedReader errReader = new BufferedReader(new InputStreamReader(errStream, "UTF-8"));
                    StringBuilder errSb = new StringBuilder();
                    String errLine;
                    while ((errLine = errReader.readLine()) != null) errSb.append(errLine);
                    errReader.close();
                    System.err.println("[SpeechService] ⚠ 获取 token 网络错误: " + errSb);
                } else {
                    System.err.println("[SpeechService] ⚠ 获取 token 网络异常: " + ioEx.getMessage());
                }
            }
        } catch (Exception e) {
            System.err.println("[SpeechService] ⚠ 获取 token 异常: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 调用百度短语音识别 API
     */
    private String callBaiduAsr(byte[] audioData, int sampleRate, String format) {
        refreshToken();
        if (accessToken == null) {
            throw new RuntimeException("百度 access_token 获取失败");
        }

        // 如果是 pcm 需要拆 WAV 头
        byte[] sendData = audioData;
        if ("pcm".equals(format) && audioData.length > 44
                && audioData[0] == 'R' && audioData[1] == 'I'
                && audioData[2] == 'F' && audioData[3] == 'F') {
            sendData = new byte[audioData.length - 44];
            System.arraycopy(audioData, 44, sendData, 0, sendData.length);
        }

        String tokenEncoded;
        try {
            tokenEncoded = java.net.URLEncoder.encode(accessToken, "UTF-8");
        } catch (Exception e) {
            tokenEncoded = accessToken;
        }

        System.out.println("[SpeechService] RAW模式: format=" + format + ", rate=" + sampleRate + ", 数据大小=" + sendData.length + " bytes");

        CloseableHttpClient client = HttpClients.createDefault();
        try {
            HttpPost post = new HttpPost(ASR_URL + "?cuid=smartshopping&token=" + tokenEncoded);
            post.setHeader("Content-Type", "audio/" + format + ";rate=" + sampleRate);
            post.setEntity(new ByteArrayEntity(sendData));

            System.out.println("[SpeechService] 发送请求到: " + ASR_URL);

            HttpResponse response = client.execute(post);
            int statusCode = response.getStatusLine().getStatusCode();
            String resultStr = EntityUtils.toString(response.getEntity(), "UTF-8");

            System.out.println("[SpeechService] HTTP状态=" + statusCode + ", 响应=" + resultStr);

            JSONObject result = JSONObject.parseObject(resultStr);
            int errNo = result.getInteger("err_no") != null ? result.getInteger("err_no") : -1;
            String errMsg = result.getString("err_msg");

            if (errNo == 0) {
                JSONArray arr = result.getJSONArray("result");
                if (arr != null && !arr.isEmpty()) {
                    return arr.getString(0);
                }
                throw new RuntimeException("百度返回成功但无识别结果");
            } else {
                // 常见错误码解释
                String detail;
                switch (errNo) {
                    case 3300: detail = "输入参数不正确，请检查音频格式和采样率"; break;
                    case 3301: detail = "音频质量过差，无法识别"; break;
                    case 3302: detail = "鉴权失败，token 无效或已过期"; break;
                    case 3303: detail = "音频过长（最多60秒），或百度服务端问题"; break;
                    case 3304: detail = "没有匹配的识别结果"; break;
                    case 3305: detail = "识别过程出错"; break;
                    case 3311: detail = "采样率rate参数无效，当前dev_pid=" + (result.getInteger("dev_pid") != null ? result.getInteger("dev_pid") : "未返回") + "，请确认音频采样率为16000且dev_pid支持"; break;
                    default:   detail = "未知错误";
                }
                throw new RuntimeException("百度识别失败 err_no=" + errNo + ": " + errMsg + "（" + detail + "）");
            }
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("语音识别网络异常: " + e.getMessage(), e);
        } finally {
            try { client.close(); } catch (Exception e) {}
        }
    }
}