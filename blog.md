# 优雅使用Code CLI，使用urai_code轻松切换AI服务设置

## claude code and gemini code cli介绍
### claude code可以使用环境变量指定ANTHROPIC_BASE_URL，所以可以方便使用其它AI服务商
### gemini code cli不能切换到第三方。但基于它的第三方分支如qwen code，支持qwen接口和openai接口，可以使用第三方AI服务
### 国内环境的特殊性。anthorpic和gemini的价格问题

## 国内开源模型的整体提高。glm-4.5, qwen3 code, k2, deepseek-v3.1
### 支持anthorpic api接口调用，适配claude code使用
### 都支持openai接口，可以使用qwen code

## 配置文件
### api key
### claude_url
### openai_url
### model

## 脚本使用
