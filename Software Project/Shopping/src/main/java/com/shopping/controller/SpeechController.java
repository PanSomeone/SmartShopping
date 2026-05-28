package com.shopping.controller;

import com.shopping.service.SpeechService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

@Controller
public class SpeechController {

    @Resource
    private SpeechService speechService;

    /**
     * 语音转文字接口
     * 前端上传 WAV 音频文件，返回识别文字
     */
    @RequestMapping(value = "/speechToText", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> speechToText(
            @RequestParam("audio") MultipartFile audioFile,
            @RequestParam(value = "sampleRate", defaultValue = "16000") int sampleRate) {

        Map<String, Object> result = new HashMap<>();

        if (audioFile == null || audioFile.isEmpty()) {
            result.put("success", false);
            result.put("message", "音频数据为空");
            return result;
        }

        try {
            byte[] audioData = audioFile.getBytes();
            System.out.println("[SpeechController] 收到音频: size=" + audioData.length + " bytes, sampleRate=" + sampleRate);

            // 检查 WAV 头
            if (audioData.length >= 4) {
                System.out.println("[SpeechController] 前4字节: "
                        + Integer.toHexString(audioData[0] & 0xFF) + " "
                        + Integer.toHexString(audioData[1] & 0xFF) + " "
                        + Integer.toHexString(audioData[2] & 0xFF) + " "
                        + Integer.toHexString(audioData[3] & 0xFF));
            }

            String text = speechService.speechToText(audioData, sampleRate);

            if (text != null && !text.isEmpty()) {
                result.put("success", true);
                result.put("text", text);
            } else {
                result.put("success", false);
                result.put("message", "未识别到语音内容（请查看后端控制台错误详情）");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "语音识别异常: " + e.getMessage());
            e.printStackTrace();
        }

        return result;
    }
}