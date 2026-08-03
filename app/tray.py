from PySide6.QtGui import QAction
from PySide6.QtWidgets import QMenu, QSystemTrayIcon


def create_tray(app, bridge, random_position):
    menu = QMenu()
    new_action = QAction("新建便签", menu)

    def new_note():
        x, y = random_position(app.primaryScreen())
        bridge.create_note(x, y)

    new_action.triggered.connect(new_note)
    menu.addAction(new_action)
    menu.addSeparator()

    quit_action = QAction("退出", menu)

    def quit_app():
        bridge.close_all()
        app.quit()

    quit_action.triggered.connect(quit_app)
    menu.addAction(quit_action)

    tray = QSystemTrayIcon(app.windowIcon())
    tray.setToolTip("桌面便签")
    tray.setContextMenu(menu)
    tray.activated.connect(lambda reason: new_note() if reason == QSystemTrayIcon.DoubleClick else None)
    return tray
