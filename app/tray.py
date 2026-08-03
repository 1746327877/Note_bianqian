from PySide6.QtGui import QAction
from PySide6.QtWidgets import QMenu, QSystemTrayIcon


class TrayController:
    """Owns the tray icon and its menu so nothing gets garbage collected."""

    def __init__(self, app, bridge):
        self.app = app
        self.bridge = bridge

        self.menu = QMenu()
        self.show_action = QAction("显示便签", self.menu)
        self.quit_action = QAction("退出", self.menu)

        self.show_action.triggered.connect(self.show_note)
        self.quit_action.triggered.connect(self.quit_app)

        self.menu.addAction(self.show_action)
        self.menu.addSeparator()
        self.menu.addAction(self.quit_action)

        self.tray = QSystemTrayIcon(app.windowIcon())
        self.tray.setToolTip("桌面便签")
        self.tray.setContextMenu(self.menu)
        self.tray.activated.connect(self.on_activated)

    def show_note(self):
        self.bridge.showMainNote()

    def quit_app(self):
        self.bridge.close_all()
        self.app.quit()

    def on_activated(self, reason):
        if reason == QSystemTrayIcon.DoubleClick:
            self.show_note()

    def show(self):
        self.tray.show()


def create_tray(app, bridge):
    return TrayController(app, bridge)
