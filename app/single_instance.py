from PySide6.QtCore import QObject, Signal
from PySide6.QtNetwork import QLocalServer, QLocalSocket

APP_SERVER_NAME = "StickyNotesSingleInstance"


class SingleInstance(QObject):
    """Ensures only one instance runs.

    The first instance becomes the owner and listens on a local socket.
    Later instances connect, ask the owner to show its window, then exit.
    """

    showRequested = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._server = None

    def try_acquire(self) -> bool:
        """Return True if this process is the owner, False if another runs."""
        socket = QLocalSocket()
        socket.connectToServer(APP_SERVER_NAME)
        if socket.waitForConnected(500):
            # Another instance is alive: ask it to show, then give up.
            socket.write(b"show")
            socket.flush()
            socket.waitForBytesWritten(500)
            socket.disconnectFromServer()
            socket.close()
            return False

        QLocalServer.removeServer(APP_SERVER_NAME)
        self._server = QLocalServer(self)
        self._server.newConnection.connect(self._on_new_connection)
        if not self._server.listen(APP_SERVER_NAME):
            return False
        return True

    def close(self):
        if self._server is not None:
            self._server.close()

    def _on_new_connection(self):
        conn = self._server.nextPendingConnection()
        if conn is None:
            return
        conn.readyRead.connect(lambda: self._read(conn))
        conn.disconnected.connect(conn.deleteLater)

    def _read(self, conn):
        data = bytes(conn.readAll()).decode("utf-8", errors="ignore")
        if "show" in data:
            self.showRequested.emit()
        conn.disconnectFromServer()
