import random
from pathlib import Path

from PySide6.QtCore import QObject, Slot, QUrl
from PySide6.QtQml import QQmlComponent

PALETTE = ["#FDF6E3", "#FBE7D0", "#E4F0E3", "#ECE7F5", "#F6E4E4"]
TAPES = ["#E8B84B", "#E8954B", "#8AB06A", "#A892D6", "#D68A8A"]


class NoteBridge(QObject):
    def __init__(self, store, engine, qml_dir):
        super().__init__()
        self.store = store
        self.engine = engine
        self.windows = {}
        self._screen = None
        self._component = QQmlComponent(
            engine, QUrl.fromLocalFile(str(Path(qml_dir) / "StickyNote.qml"))
        )

    def set_screen(self, screen):
        self._screen = screen

    def _clamp(self, x, y, w, h):
        g = self._screen.availableGeometry() if self._screen else None
        if g is None:
            return x, y
        x = max(g.left() - w + 80, min(x, g.right() - 80))
        y = max(g.top(), min(y, g.bottom() - 60))
        return int(x), int(y)

    def _create_window(self, note):
        note_id = note["id"]
        x, y = self._clamp(note["x"], note["y"], 280, 380)
        obj = self._component.createObject(None, {
            "noteId": note_id,
            "paperColor": note["color"],
            "noteOpacity": note["opacity"],
            "x": x,
            "y": y,
        })
        if obj is None:
            return
        obj.show()
        self.windows[note_id] = obj

    def load_existing(self):
        for note in self.store.list_notes():
            self._create_window(note)

    def create_note(self, x, y):
        color = random.choice(PALETTE)
        note_id = self.store.create_note(x, y, color)
        note = self.store.get_note(note_id)
        self._create_window(note)
        return note_id

    def close_all(self):
        for obj in list(self.windows.values()):
            obj.close()
        self.windows.clear()

    @Slot(int, result=list)
    def getTodos(self, note_id):
        return self.store.list_todos(note_id)

    @Slot(int, str, result=int)
    def addTodo(self, note_id, text):
        return self.store.create_todo(note_id, text)

    @Slot(int, bool)
    def toggleTodo(self, todo_id, done):
        self.store.toggle_todo(todo_id, done)

    @Slot(int)
    def deleteTodo(self, todo_id):
        self.store.delete_todo(todo_id)

    @Slot(int)
    def deleteNote(self, note_id):
        obj = self.windows.pop(note_id, None)
        if obj is not None:
            obj.close()
            obj.deleteLater()
        self.store.delete_note(note_id)

    @Slot(int, int, int)
    def noteMoved(self, note_id, x, y):
        self.store.update_note_position(note_id, x, y)

    @Slot(int, float)
    def setNoteOpacity(self, note_id, opacity):
        self.store.set_note_opacity(note_id, opacity)

    @Slot(int, str)
    def setNoteColor(self, note_id, color):
        self.store.set_note_color(note_id, color)

    @Slot(int, result=str)
    def getTapeColor(self, note_id):
        return random.choice(TAPES)
