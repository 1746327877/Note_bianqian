#!/usr/bin/env python3
"""桌面便签的命令行接口,供 Agent(如 Claude Code / Cline 等)读写待办事项。

用法:
    python notes_cli.py list               查看所有待办
    python notes_cli.py list --all         查看所有待办(含已完成)
    python notes_cli.py add "任务内容"      添加待办
    python notes_cli.py done <todo_id>     标记为已完成
    python notes_cli.py undo <todo_id>     标记为未完成
    python notes_cli.py delete <todo_id>   删除待办
    python notes_cli.py count              统计(未完成/总数)
    python notes_cli.py path               打印数据库路径

输出格式:每行一条,`[x]` 已完成,`[ ]` 未完成,前缀为 id。
"""

import os
import sqlite3
import sys
import time
from pathlib import Path

DATA_DIR = Path(os.environ.get("APPDATA", str(Path.home()))) / "StickyNotes"
DB_PATH = DATA_DIR / "notes.db"


def _connect():
    return sqlite3.connect(str(DB_PATH))


def _get_main_note(conn):
    row = conn.execute(
        "SELECT id FROM notes ORDER BY created_at ASC LIMIT 1"
    ).fetchone()
    if row is None:
        cur = conn.execute(
            "INSERT INTO notes (x, y, color) VALUES (100, 100, '#FDF6E3')"
        )
        conn.commit()
        return cur.lastrowid
    return row[0]


def list_todos(include_done=False):
    conn = _connect()
    note_id = _get_main_note(conn)
    sql = (
        "SELECT id, text, done FROM todos WHERE note_id = ? "
        "ORDER BY done ASC, created_at ASC"
    )
    rows = conn.execute(sql, (note_id,)).fetchall()
    conn.close()
    if not rows:
        print("(无待办事项)")
        return
    for rid, text, done in rows:
        if done and not include_done:
            continue
        mark = "[x]" if done else "[ ]"
        print(f"{mark} {rid} {text}")


def add_todo(text):
    conn = _connect()
    note_id = _get_main_note(conn)
    cur = conn.execute(
        "INSERT INTO todos (note_id, text, created_at) "
        "VALUES (?, ?, ?)",
        (note_id, text, time.strftime("%Y-%m-%d %H:%M:%S")),
    )
    conn.commit()
    todo_id = cur.lastrowid
    conn.close()
    print(f"已添加 #{todo_id}: {text}")


def set_done(todo_id, done):
    conn = _connect()
    done_at = time.strftime("%Y-%m-%d %H:%M:%S") if done else None
    cur = conn.execute(
        "UPDATE todos SET done = ?, done_at = ? WHERE id = ?",
        (int(done), done_at, todo_id),
    )
    conn.commit()
    conn.close()
    if cur.rowcount == 0:
        print(f"错误:未找到待办 #{todo_id}")
        return 1
    print(f"#{todo_id} 已标记为{'完成' if done else '未完成'}")
    return 0


def delete_todo(todo_id):
    conn = _connect()
    cur = conn.execute("DELETE FROM todos WHERE id = ?", (todo_id,))
    conn.commit()
    conn.close()
    if cur.rowcount == 0:
        print(f"错误:未找到待办 #{todo_id}")
        return 1
    print(f"#{todo_id} 已删除")
    return 0


def count():
    conn = _connect()
    note_id = _get_main_note(conn)
    total = conn.execute(
        "SELECT COUNT(*) FROM todos WHERE note_id = ?", (note_id,)
    ).fetchone()[0]
    done = conn.execute(
        "SELECT COUNT(*) FROM todos WHERE note_id = ? AND done = 1",
        (note_id,),
    ).fetchone()[0]
    conn.close()
    print(f"未完成 {total - done} / 总计 {total}")


def main(argv):
    if not argv:
        list_todos()
        return 0

    cmd = argv[0]
    try:
        if cmd == "list":
            include_done = "--all" in argv
            list_todos(include_done)
            return 0
        if cmd == "add":
            if len(argv) < 2:
                print("用法: notes_cli.py add \"任务内容\"")
                return 1
            add_todo(argv[1])
            return 0
        if cmd == "done":
            return set_done(int(argv[1]), True)
        if cmd == "undo":
            return set_done(int(argv[1]), False)
        if cmd == "delete":
            return delete_todo(int(argv[1]))
        if cmd == "count":
            count()
            return 0
        if cmd == "path":
            print(DB_PATH)
            return 0
    except (IndexError, ValueError):
        print(f"用法错误,命令: {cmd}")
        return 1

    print(f"未知命令: {cmd}")
    print(__doc__)
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
