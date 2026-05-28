package com.shopping.service;

public interface SpeechService {
    /**
     * 将音频数据转为文字
     * @param audioData 音频字节数组 (WAV/PCM格式)
     * @param sampleRate 采样率，如 16000
     * @return 识别出的文字，失败返回 null
     */
    String speechToText(byte[] audioData, int sampleRate);
}