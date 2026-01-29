# AI 服务配置选择器

轻量级跨平台命令行工具，用于通过简单的 `.conf` 文件管理多个 AI 服务配置。

## 概述

Claude Code 和 Qwen Code（基于 Gemini Code 的分支，支持 Qwen3 Code）支持自定义 AI 模型和第三方提供商。本项目包含两个脚本，可以轻松在第三方模型之间切换，包括 GLM-4.5、Kimi K2、DeepSeek V3.1 和 Qwen3-Code。

本项目提供两个主要工具：

- **`ccs`** - 用于 Anthropic claude code
- **`qw`** - 用于阿里巴巴 qwen code，使用 OpenAI 兼容的端点

每个工具都允许您通过简单的配置文件管理多个 API 配置，轻松在不同 AI 服务提供商和模型之间切换。

## 特性

- **跨平台支持**：macOS/Linux (bash) 和 Windows CMD
- **简单配置**：纯文本 `.conf` 文件，使用 key=value 对
- **安全**：显示时 API 密钥被屏蔽
- **环境变量集成**：为 AI CLI 工具设置标准环境变量
- **自动配置目录创建**：如果不存在则创建 `~/.aiconf/` 目录

## 安装

### macOS/Linux

1. 下载或克隆此仓库
2. 将脚本放在 PATH 中的目录：
   ```bash
   # 示例：~/bin 目录
   cp ccs qw ~/bin/

   # 使其可执行
   chmod +x ~/bin/ccs ~/bin/qw
   ```

### Windows

1. 下载或克隆此仓库
2. 将脚本放在 PATH 中的目录：
   - `ccs.cmd` 和 `qw.cmd` 用于命令提示符

   命令提示符示例：
   ```cmd
   copy ccs.cmd %USERPROFILE%\bin\
   copy qw.cmd %USERPROFILE%\bin\
   ```

## 配置

### 配置目录

在以下位置创建配置文件：
- **macOS/Linux**：`~/.aiconf/<name>.conf`
- **Windows**：`%USERPROFILE%\.aiconf\<name>.conf`
 - 可选覆盖：设置 `AICONF_DIR` 指向自定义配置目录

### 配置文件格式

每个 `.conf` 文件包含简单的 key=value 对。以 `#` 开头的行是注释。

每个 `.conf` 文件都包含 `claude_url` 和 `openai_url` 字段：

```ini
api_key=sk-your-api-key-here
claude_url=https://api.yourai.com/anthropic  # ccs 使用
openai_url=https://api.yourai.com/v1         # qw 使用
model=claude-3-sonnet-20240229
```

**重要说明**：每个 `.conf` 文件都包含 `claude_url` 和 `openai_url` 字段：
- **`ccs`** 使用 `claude_url` 用于 Claude/Anthropic 兼容的端点
- **`qw`** 使用 `openai_url` 用于 OpenAI 兼容的端点

### 配置示例

查看此目录中的 `.conf.example` 文件作为完整示例：

```bash
# 复制示例配置
cp k2.conf.example ~/.aiconf/k2.conf
# 编辑您的实际 API 密钥和设置
```

## 使用方法

### 基本用法

```bash
# macOS/Linux
ccs <config_name> [options]
qw <config_name> [options]

# Windows CMD
ccs.cmd <config_name> [options]
qw.cmd <config_name> [options]
```

附加命令：

```
ccs --config <config_name> [options]
ccs --list
```

### 示例

```bash
# 使用 k2 配置与 Claude
ccs k2 --version

# 使用 k2 配置与 Qwen
qw k2 -v

# 显示帮助
ccs --help
qw --help
```

### 环境变量

脚本设置标准环境变量，这些变量被大多数 AI CLI 工具识别：

#### 对于 `ccs`：
- `ANTHROPIC_API_KEY` - API 密钥
- `ANTHROPIC_AUTH_TOKEN` - API 密钥（兼容）
- `ANTHROPIC_BASE_URL` - 基础 URL
- `ANTHROPIC_MODEL` - 模型名称

#### 对于 `qw`：
- `OPENAI_API_KEY` - API 密钥
- `OPENAI_BASE_URL` - 基础 URL
- `OPENAI_MODEL` - 模型名称

## 前置要求

这些脚本是包装器，需要安装底层 AI CLI 工具：

- 对于 `ccs`：[Claude CLI](https://github.com/anthropics/claude) 或兼容工具
- 对于 `qw`：[Qwen CLI](https://github.com/QwenLM/Qwen) 或兼容的 OpenAI CLI 工具

确保这些工具已安装并在您的 PATH 中可用。

## 故障排除

### 常见问题

**错误：在 PATH 中找不到 claude/qwen**
- 确保底层 CLI 工具已安装
- 验证工具在您的 PATH 中：`which claude` 或 `where claude`

**找不到配置文件**
- 确认文件存在于正确的目录中
- 检查文件名是否匹配 `<config_name>.conf`
- 验证配置目录存在：`ls ~/.aiconf/`

**模型不匹配**
- "model" 字段是通用的；确保它匹配您的目标提供商支持的模型
- 查看您的提供商的文档以了解支持的模型

### 调试模式

您可以在 bash 脚本中添加 `set -x` 或在 CMD 脚本中启用 echo 来查看发生了什么：

```bash
# 编辑 bash 脚本并在顶部添加：
set -x
```

## 文件结构

```
.
├── ccs                 # macOS/Linux bash 脚本，用于 Claude
├── ccs.cmd            # Windows CMD 脚本，用于 Claude
├── qw                 # macOS/Linux bash 脚本，用于 Qwen
├── qw.cmd             # Windows CMD 脚本，用于 Qwen
├── g.cmd              # 附加工具脚本
├── *.conf.example     # 示例配置文件
└── README.md          # 此文件
```

## 贡献

欢迎贡献！请随时提交拉取请求。

### 开发

1. Fork 仓库
2. 创建功能分支：`git checkout -b feature/new-feature`
3. 进行更改
4. 在所有平台上测试（macOS/Linux、Windows CMD）
5. 提交拉取请求

### 测试

请在以下环境中测试您的更改：
- 使用 bash 的 macOS/Linux
- 使用命令提示符的 Windows

## 许可证

本项目是开源的，在 [MIT 许可证](LICENSE) 下可用。

## 安全

- API 密钥存储在纯文本文件中 - 确保适当的文件权限
- 配置文件应保存在用户特定目录中
- 显示时 API 密钥被屏蔽（仅显示前 8 个字符）
- 永远不要将实际的 API 密钥提交到版本控制

脚本不会完整打印任何密钥，仅显示屏蔽前缀。

## 支持

如果您遇到任何问题或有疑问：

1. 检查上面的故障排除部分
2. 搜索现有问题
3. 创建新问题，详细描述您的环境和问题

---

**注意**：这是一个配置包装器工具。您仍然需要单独安装实际的 AI CLI 工具（Claude、Qwen 等）。

## 变更日志

详细更新说明请见 `CHANGELOG.md`。
