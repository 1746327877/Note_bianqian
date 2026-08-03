from PySide6.QtGui import QAction
from PySide6.QtWidgets import QMenu, QSystemTrayIcon


class TrayController:
    """Owns the tray icon and its menu so nothing gets garbage collected."""

    def __init__(self, app, bridge, random_position):
        self.app = app
        self.bridge = bridge
        self.random_position = random_position

        self.menu = QMenu()
        self.new_action = QAction("新建便签", self.menu)
        self.quit_action = QAction("退出", self.menu)

        self.new_action.triggered.connect(self.new_note)
        self.quit_action.triggered.connect(self.quit_app)

        self.menu.addAction(self.new_action)
        self.menu.addSeparator()
        self.menu.addAction(self.quit_action)

        self.tray = QSystemTrayIcon(app.windowIcon())
        self.tray.setToolTip("桌面便签")
        self.tray.setContextMenu(self.menu)
        self.tray.activated.connect(self.on_activated)

    def new_note(self):
        x, y = self.random_position(self.app.primaryScreen())
        self.bridge.create_note(x, y)

    def quit_app(self):
        self.bridge.close_all()
        self.app.quit()

    def on_activated(self, reason):
        if reason == QSystemTrayIcon.DoubleClick:
            self.new_note()

    def show(self):
        self.tray.show()


def create_tray(app, bridge, random_position):
    return TrayController(app, bridge, random_position)
