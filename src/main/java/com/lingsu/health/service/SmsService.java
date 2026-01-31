package com.lingsu.health.service;

import com.aliyun.dysmsapi20170525.Client;
import com.aliyun.dysmsapi20170525.models.SendSmsRequest;
import com.aliyun.dysmsapi20170525.models.SendSmsResponse;
import com.aliyun.teaopenapi.models.Config;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class SmsService {

    @Value("${aliyun.sms.access-key-id:}")
    private String accessKeyId;

    @Value("${aliyun.sms.access-key-secret:}")
    private String accessKeySecret;

    @Value("${aliyun.sms.sign-name:灵素养生}")
    private String signName;

    @Value("${aliyun.sms.template-code:}")
    private String templateCode;

    /**
     * 发送养生任务提醒短信
     * @param phoneNumber 手机号
     * @param taskName 任务名称
     * @param taskTime 任务时间
     * @return 是否发送成功
     */
    public boolean sendTaskReminder(String phoneNumber, String taskName, String taskTime) {
        try {
            Client client = createClient();
            
            SendSmsRequest request = new SendSmsRequest()
                .setPhoneNumbers(phoneNumber)
                .setSignName(signName)
                .setTemplateCode(templateCode)
                .setTemplateParam("{\"task\":\"" + taskName + "\",\"time\":\"" + taskTime + "\"}");

            SendSmsResponse response = client.sendSms(request);
            
            return "OK".equals(response.getBody().getCode());
        } catch (Exception e) {
            System.err.println("发送短信失败: " + e.getMessage());
            return false;
        }
    }

    /**
     * 创建阿里云短信客户端
     */
    private Client createClient() throws Exception {
        Config config = new Config()
            .setAccessKeyId(accessKeyId)
            .setAccessKeySecret(accessKeySecret)
            .setEndpoint("dysmsapi.aliyuncs.com");
        
        return new Client(config);
    }
}
