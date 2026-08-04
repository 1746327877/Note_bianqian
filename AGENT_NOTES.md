# 桌面便签 Agent 使用指南

## 用途

本机有一个桌面便签程序(Sticky Notes),待办事项存储在 SQLite 数据库。
你可以通过命令行接口读取和修改这些待办,与便签程序实时同步。

## 数据库位置

`%APPDATA%/StickyNotes/notes.db`(Windows 下通常为
`C:\Users\<用户名>\AppData\Roaming\StickyNotes\notes.db`)

## 命令接口

在项目目录 `D:\code\python\demo02` 下运行:

| 命令 | 作用 |
|---|---|
| `python notes_cli.py list` | 查看未完成待办 |
| `python notes_cli.py list --all` | 查看全部待办(含已完成) |
| `python notes_cli.py add "任务内容"` | 添加待办 |
| `python notes_cli.py done <id>` | 标记为已完成 |
| `python notes_cli.py undo <id>` | 标记为未完成 |
| `python notes_cli.py delete <id>` | 删除待办 |
| `python notes_cli.py count` | 统计未完成/总数 |
| `python notes_cli.py path` | 打印数据库路径 |

## 工作流建议

1. 任务开始时先运行 `python notes_cli.py list` 查看当前待办
2. 执行任务后,用 `python notes_cli.py done <id>` 标记完成
3. 新想到的任务用 `python notes_cli.py add "..."` 加入
4. 结束时用 `python notes_cli.py list` 确认状态

## 注意事项

- 不要直接改数据库文件,请用 `notes_cli.py` 命令
- 每次操作后程序会自动写入数据库,无需手动保存
- 已完成事项默认不显示,加 `--all` 查看
