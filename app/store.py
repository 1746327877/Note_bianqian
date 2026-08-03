import sqlite3
import time
from pathlib import Path

DEFAULT_COLORS = ["#FDF6E3", "#FBE7D0", "#E4F0E3", "#ECE7F5"]


class Store:
    def __init__(self, path):
        self._conn = sqlite3.connect(str(path))
        self._conn.row_factory = sqlite3.Row
        self._init()

    def _init(self):
        self._conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS notes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                x REAL,
                y REAL,
                color TEXT DEFAULT '#FDF6E3',
                opacity REAL DEFAULT 0.96,
                created_at TEXT DEFAULT (datetime('now','localtime'))
            );
            CREATE TABLE IF NOT EXISTS todos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                note_id INTEGER NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
                text TEXT NOT NULL,
                done INTEGER DEFAULT 0,
                done_at TEXT,
                created_at TEXT DEFAULT (datetime('now','localtime'))
            );
            """
        )
        self._conn.commit()

    def _row_to_dict(self, row):
        return dict(row)

    def create_note(self, x, y, color):
        cur = self._conn.execute(
            "INSERT INTO notes (x, y, color) VALUES (?, ?, ?)", (x, y, color)
        )
        self._conn.commit()
        return cur.lastrowid

    def delete_note(self, note_id):
        self._conn.execute("DELETE FROM notes WHERE id = ?", (note_id,))
        self._conn.commit()

    def get_note(self, note_id):
        row = self._conn.execute("SELECT * FROM notes WHERE id = ?", (note_id,)).fetchone()
        return self._row_to_dict(row) if row else None

    def list_notes(self):
        rows = self._conn.execute("SELECT * FROM notes ORDER BY created_at").fetchall()
        return [self._row_to_dict(r) for r in rows]

    def update_note_position(self, note_id, x, y):
        self._conn.execute("UPDATE notes SET x = ?, y = ? WHERE id = ?", (x, y, note_id))
        self._conn.commit()

    def set_note_color(self, note_id, color):
        self._conn.execute("UPDATE notes SET color = ? WHERE id = ?", (color, note_id))
        self._conn.commit()

    def set_note_opacity(self, note_id, opacity):
        self._conn.execute("UPDATE notes SET opacity = ? WHERE id = ?", (opacity, note_id))
        self._conn.commit()

    def create_todo(self, note_id, text):
        cur = self._conn.execute(
            "INSERT INTO todos (note_id, text) VALUES (?, ?)", (note_id, text)
        )
        self._conn.commit()
        return cur.lastrowid

    def toggle_todo(self, todo_id, done):
        done_at = time.strftime("%Y-%m-%d %H:%M:%S") if done else None
        self._conn.execute(
            "UPDATE todos SET done = ?, done_at = ? WHERE id = ?", (int(done), done_at, todo_id)
        )
        self._conn.commit()

    def delete_todo(self, todo_id):
        self._conn.execute("DELETE FROM todos WHERE id = ?", (todo_id,))
        self._conn.commit()

    def list_todos(self, note_id):
        rows = self._conn.execute(
            "SELECT id, text, done FROM todos WHERE note_id = ? ORDER BY created_at, id",
            (note_id,),
        ).fetchall()
        return [{"id": r["id"], "text": r["text"], "done": bool(r["done"])} for r in rows]
