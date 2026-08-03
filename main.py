import os
import random
import sys
from pathlib import Path

from PySide6.QtCore import QTimer, Qt
from PySide6.QtGui import QIcon, QPainter, QPixmap, QColor, QPen, QBrush
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

from app.store import Store
from app.bridge import NoteBridge
from app.tray import create_tray

if getattr(sys, "frozen", False):
    BASE = Path(sys._MEIPASS)
else:
    BASE = Path(__file__).resolve().parent
QML_DIR = BASE / "qml"
DATA_DIR = Path(os.environ.get("APPDATA", str(Path.home()))) / "StickyNotes"
DATA_DIR.mkdir(parents=True, exist_ok=True)


def make_icon():
    pm = QPixmap(64, 64)
    pm.fill(Qt.transparent)
    p = QPainter(pm)
    p.setRenderHint(QPainter.Antialiasing)
    p.setBrush(QColor("#E8B84B"))
    p.setPen(QPen(QColor("#C89B35"), 2))
    p.drawRoundedRect(4, 4, 56, 56, 12, 12)
    p.setBrush(QColor("#FBF3E3"))
    p.setPen(Qt.NoPen)
    p.drawRoundedRect(16, 14, 32, 26, 4, 4)
    p.setPen(QPen(QColor("#6B5A44"), 3, Qt.SolidLine, Qt.RoundCap))
    p.drawLine(20, 22, 42, 22)
    p.drawLine(20, 29, 42, 29)
    p.end()
    return QIcon(pm)


def random_position(screen):
    g = screen.availableGeometry()
    x = g.left() + random.randint(40, max(40, g.width() - 400))
    y = g.top() + random.randint(40, max(40, g.height() - 440))
    return x, y


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("StickyNotes")
    app.setQuitOnLastWindowClosed(False)
    app.setWindowIcon(make_icon())

    engine = QQmlApplicationEngine()
    store = Store(DATA_DIR / "notes.db")
    bridge = NoteBridge(store, engine, QML_DIR)
    bridge.set_screen(app.primaryScreen())

    ctx = engine.rootContext()
    ctx.setContextProperty("bridge", bridge)

    tray = create_tray(app, bridge, random_position)

    bridge.load_existing()
    if not bridge.windows:
        x, y = random_position(app.primaryScreen())
        bridge.create_note(x, y)

    tray.show()

    if os.environ.get("SMOKE"):
        def _report():
            print(f"SMOKE windows={len(bridge.windows)} qml_dir={QML_DIR}")
            app.quit()
        QTimer.singleShot(2500, _report)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
