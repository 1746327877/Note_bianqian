import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Window {
    id: root
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"
    width: 280
    height: 384
    opacity: 0

    property int noteId: -1
    property color paperColor: "#FDF6E3"
    property color paperLight: Qt.lighter(paperColor, 1.07)
    property color paperDark: Qt.darker(paperColor, 1.05)
    property color inkColor: "#433A30"
    property color mutedInk: "#6E5F4C"
    property color accent: "#E8A33D"
    property color accentDeep: "#A56212"
    property color doneColor: "#B3502E"
    property real noteOpacity: 0.96
    property string tapeColor: "#E8B84B"

    onPaperColorChanged: tapeColor = bridge.getTapeColor(noteId)

    Item {
        id: content
        anchors.fill: parent
        scale: 0.94
        opacity: 0

        NumberAnimation on scale {
            id: appearScale
            to: 1
            duration: 320
            easing.type: Easing.OutQuart
        }
        NumberAnimation on opacity {
            id: appearOpacity
            to: 1
            duration: 280
            easing.type: Easing.OutCubic
        }

        Rectangle {
            id: paper
            anchors.fill: parent
            anchors.margins: 12
            radius: 13
            border.width: 1
            border.color: Qt.rgba(0.27, 0.22, 0.16, 0.06)
            gradient: Gradient {
                GradientStop { position: 0.0; color: paperLight }
                GradientStop { position: 1.0; color: paperDark }
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.6
                shadowColor: Qt.rgba(0.1, 0.07, 0.04, 0.45)
                shadowVerticalOffset: 5
            }

            // tape strip
            Rectangle {
                id: tape
                width: 122
                height: 26
                radius: 2
                color: tapeColor
                opacity: 0.78
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -11
                rotation: -2.5

                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.18) }
                        GradientStop { position: 1.0; color: Qt.rgba(0.27, 0.22, 0.16, 0.08) }
                    }
                }
            }

            // header
            Text {
                id: titleText
                anchors.top: parent.top
                anchors.topMargin: 22
                anchors.left: parent.left
                anchors.leftMargin: 16
                text: "便签"
                color: inkColor
                font.family: "Microsoft YaHei"
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Rectangle {
                id: closeBtn
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 10
                width: 26
                height: 26
                radius: 13
                color: closeArea.containsMouse ? Qt.rgba(0.5, 0.2, 0.1, 0.1) : "transparent"
                Behavior on color { ColorAnimation { duration: 160 } }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: exitAnim.start()
                }

                IconGlyph {
                    anchors.centerIn: parent
                    kind: "close"
                    size: 11
                    color: closeArea.containsMouse ? doneColor : mutedInk
                }
            }

            Rectangle {
                id: sortBtn
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.right: closeBtn.left
                anchors.rightMargin: 2
                width: 26
                height: 26
                radius: 13
                color: sortArea.containsMouse ? Qt.rgba(0.27, 0.22, 0.16, 0.08) : "transparent"
                Behavior on color { ColorAnimation { duration: 160 } }

                MouseArea {
                    id: sortArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: cycleSort()
                }

                IconGlyph {
                    anchors.centerIn: parent
                    kind: "sort"
                    size: 12
                    color: sortArea.containsMouse ? accentDeep : mutedInk
                }
            }

            // input row
            Rectangle {
                id: inputBox
                anchors.top: parent.top
                anchors.topMargin: 54
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: parent.right
                anchors.rightMargin: 14
                height: 36
                radius: 18
                color: Qt.rgba(255, 255, 255, 0.6)
                border.width: input.activeFocus ? 1.5 : 1
                border.color: input.activeFocus ? accentDeep : Qt.rgba(0.27, 0.22, 0.16, 0.09)
                Behavior on border.color { ColorAnimation { duration: 180 } }

                TextInput {
                    id: input
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.right: addBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: inkColor
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 13
                    clip: true
                    selectByMouse: true

                    Text {
                        text: "写下新待办..."
                        color: mutedInk
                        visible: input.length === 0 && !input.activeFocus
                        font: input.font
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                    }

                    onAccepted: addTodo()
                }

                Rectangle {
                    id: addBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 3
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: 30
                    radius: 15
                    scale: addArea.pressed ? 0.9 : 1
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    color: addArea.containsMouse ? accentDeep : Qt.darker(accentDeep, 1.08)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    IconGlyph {
                        anchors.centerIn: parent
                        kind: "plus"
                        size: 12
                        color: "#FFFDF6"
                    }
                    MouseArea {
                        id: addArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: addTodo()
                    }
                }
            }

            // list
            ListView {
                id: list
                anchors.top: inputBox.bottom
                anchors.topMargin: 8
                anchors.bottom: footer.top
                anchors.bottomMargin: 2
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                clip: true
                spacing: 2

                model: ListModel { id: todoModel }
                delegate: todoDelegate

                add: Transition {
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
                        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 240; easing.type: Easing.OutQuart }
                    }
                }
                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; to: 0; duration: 170; easing.type: Easing.InCubic }
                        NumberAnimation { property: "height"; to: 0; duration: 220; easing.type: Easing.InQuart }
                    }
                }
                displaced: Transition {
                    NumberAnimation { property: "y"; duration: 240; easing.type: Easing.OutQuart }
                }
            }

            // empty state
            Item {
                visible: todoModel.count === 0
                anchors.centerIn: list
                width: list.width - 24
                height: 74

                Text {
                    id: emptyHint
                    anchors.centerIn: parent
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: "空空的\n写点什么吧"
                    color: mutedInk
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 13
                    lineHeight: 1.6
                }
            }

            // footer: progress + opacity
            Rectangle {
                id: footer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 46
                color: "transparent"

                Rectangle {
                    id: progressTrack
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 60
                    anchors.verticalCenter: parent.verticalCenter
                    height: 3
                    radius: 1.5
                    color: Qt.rgba(0.27, 0.22, 0.16, 0.1)

                    Rectangle {
                        id: progressFill
                        width: todoModel.count === 0 ? 0 : Math.max(8, progressTrack.width * doneCount / todoModel.count)
                        height: parent.height
                        radius: 1.5
                        color: accent
                        Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
                    }
                }

                Text {
                    id: progressText
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: doneCount + " / " + todoModel.count
                    color: mutedInk
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 11
                }

                Rectangle {
                    id: opacityBtn
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    radius: 8
                    color: opacityArea.containsMouse ? Qt.rgba(0.27, 0.22, 0.16, 0.1) : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    IconGlyph {
                        anchors.centerIn: parent
                        kind: "slider"
                        size: 10
                        color: mutedInk
                    }
                    MouseArea {
                        id: opacityArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: opacityPopup.open()
                    }

                    Popup {
                        id: opacityPopup
                        x: -12
                        y: -30
                        width: 120
                        padding: 0
                        background: Rectangle {
                            radius: 8
                            color: "#FFFDF8"
                            border.width: 1
                            border.color: Qt.rgba(0.27, 0.22, 0.16, 0.12)
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowBlur: 0.5
                                shadowColor: Qt.rgba(0.1, 0.07, 0.04, 0.3)
                                shadowVerticalOffset: 3
                            }
                        }
                        contentItem: Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text {
                                text: "透明度"
                                color: mutedInk
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Slider {
                                id: opacitySlider
                                width: 66
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                                from: 0.55
                                to: 1.0
                                stepSize: 0.01
                                value: root.noteOpacity
                                onMoved: {
                                    root.opacity = value
                                    bridge.setNoteOpacity(noteId, value)
                                }
                                background: Rectangle {
                                    x: opacitySlider.leftPadding
                                    y: opacitySlider.topPadding + opacitySlider.availableHeight / 2 - height / 2
                                    width: opacitySlider.availableWidth
                                    height: 3
                                    radius: 1.5
                                    color: Qt.rgba(0.27, 0.22, 0.16, 0.1)
                                    Rectangle {
                                        width: opacitySlider.visualPosition * parent.width
                                        height: parent.height
                                        radius: 1.5
                                        color: accent
                                    }
                                }
                                handle: Rectangle {
                                    x: opacitySlider.leftPadding + opacitySlider.visualPosition * (opacitySlider.availableWidth - width)
                                    y: opacitySlider.topPadding + opacitySlider.availableHeight / 2 - height / 2
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: "#FFFFFF"
                                    border.width: 1
                                    border.color: Qt.rgba(0.27, 0.22, 0.16, 0.18)
                                }
                            }
                        }
                    }
                }
            }
        }

        // drag area behind everything
        MouseArea {
            id: dragArea
            anchors.fill: parent
            z: -1
            cursorShape: Qt.OpenHandCursor

            onPressed: {
                root.dragging = true
                paper.layer.enabled = false
                dragArea.cursorShape = Qt.ClosedHandCursor
                saveTimer.restart()
                root.startSystemMove()
            }
            onReleased: finishDrag()
        }

        // startSystemMove hands the grab to the OS, so onReleased is not
        // guaranteed. Debounce on position changes as a fallback to restore
        // the shadow and persist the final values.
        Timer {
            id: saveTimer
            interval: 150
            repeat: false
            onTriggered: finishDrag()
        }

        function finishDrag() {
            var active = root.dragging || root.resizing
            if (!active) return
            root.dragging = false
            root.resizing = false
            saveTimer.stop()
            paper.layer.enabled = true
            dragArea.cursorShape = Qt.OpenHandCursor
            if (active) bridge.noteMoved(noteId, root.x, root.y)
            bridge.noteResized(noteId, root.width, root.height)
        }

        // manual resize: fully controlled, works on frameless windows
        function beginResize(edge, gx, gy) {
            if (root.dragging) return
            root.resizing = true
            root.resizeEdge = edge
            root.resizeStartGlobal = Qt.point(gx, gy)
            root.resizeStartX = root.x
            root.resizeStartY = root.y
            root.resizeStartW = root.width
            root.resizeStartH = root.height
            paper.layer.enabled = false
            saveTimer.restart()
        }

        function applyResize(gx, gy) {
            if (!root.resizing) return
            var dx = gx - root.resizeStartGlobal.x
            var dy = gy - root.resizeStartGlobal.y
            var MIN_W = 220
            var MIN_H = 260
            var e = root.resizeEdge
            var newX = root.resizeStartX, newY = root.resizeStartY
            var newW = root.resizeStartW, newH = root.resizeStartH

            if (e & Qt.RightEdge) newW = root.resizeStartW + dx
            if (e & Qt.LeftEdge) {
                newX = root.resizeStartX + dx
                newW = root.resizeStartW - dx
            }
            if (e & Qt.BottomEdge) newH = root.resizeStartH + dy
            if (e & Qt.TopEdge) {
                newY = root.resizeStartY + dy
                newH = root.resizeStartH - dy
            }

            if (newW < MIN_W) {
                if (e & Qt.LeftEdge) newX = newX + newW - MIN_W
                newW = MIN_W
            }
            if (newH < MIN_H) {
                if (e & Qt.TopEdge) newY = newY + newH - MIN_H
                newH = MIN_H
            }

            root.x = newX
            root.y = newY
            root.width = newW
            root.height = newH
            saveTimer.restart()
        }

        // resize handles on the four edges and corners
        MouseArea {
            id: resizeTop
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 7
            cursorShape: Qt.SizeVerCursor
            onPressed: beginResize(Qt.TopEdge, mouse.globalPosition.x, mouse.globalPosition.y)
            onPositionChanged: applyResize(mouse.globalPosition.x, mouse.globalPosition.y)
            onReleased: finishDrag()
        }
        MouseArea {
            id: resizeBottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 7
            cursorShape: Qt.SizeVerCursor
            onPressed: beginResize(Qt.BottomEdge, mouse.globalPosition.x, mouse.globalPosition.y)
            onPositionChanged: applyResize(mouse.globalPosition.x, mouse.globalPosition.y)
            onReleased: finishDrag()
        }
        MouseArea {
            id: resizeLeft
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 7
            cursorShape: Qt.SizeHorCursor
            onPressed: beginResize(Qt.LeftEdge, mouse.globalPosition.x, mouse.globalPosition.y)
            onPositionChanged: applyResize(mouse.globalPosition.x, mouse.globalPosition.y)
            onReleased: finishDrag()
        }
        MouseArea {
            id: resizeRight
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 7
            cursorShape: Qt.SizeHorCursor
            onPressed: beginResize(Qt.RightEdge, mouse.globalPosition.x, mouse.globalPosition.y)
            onPositionChanged: applyResize(mouse.globalPosition.x, mouse.globalPosition.y)
            onReleased: finishDrag()
        }
        MouseArea {
            id: resizeTopLeft
            anchors.top: parent.top
            anchors.left: parent.left
            width: 14
            height: 14
            cursorShape: Qt.SizeFDiagCursor
            onPressed: beginResize(Qt.TopEdge | Qt.LeftEdge, mouse.globalPosition.x, mouse.globalPosition.y)
            onPositionChanged: applyResize(mouse.globalPosition.x, mouse.globalPosition.y)
            onReleased: finishDrag()
        }
        MouseArea {
            id: resizeTopRight
            anchors.top: parent.top
            anchors.right: parent.right
            width: 14
            height: 14
            cursorShape: Qt.SizeBDiagCursor
            onPressed: beginResize(Qt.TopEdge | Qt.RightEdge, mouse.globalPosition.x, mouse.globalPosition.y)
            onPositionChanged: applyResize(mouse.globalPosition.x, mouse.globalPosition.y)
            onReleased: finishDrag()
        }
        MouseArea {
            id: resizeBottomLeft
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 14
            height: 14
            cursorShape: Qt.SizeBDiagCursor
            onPressed: beginResize(Qt.BottomEdge | Qt.LeftEdge, mouse.globalPosition.x, mouse.globalPosition.y)
            onPositionChanged: applyResize(mouse.globalPosition.x, mouse.globalPosition.y)
            onReleased: finishDrag()
        }
        MouseArea {
            id: resizeBottomRight
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 14
            height: 14
            cursorShape: Qt.SizeFDiagCursor
            onPressed: beginResize(Qt.BottomEdge | Qt.RightEdge, mouse.globalPosition.x, mouse.globalPosition.y)
            onPositionChanged: applyResize(mouse.globalPosition.x, mouse.globalPosition.y)
            onReleased: finishDrag()
        }

            Component {
            id: todoDelegate
            Item {
                id: row
                width: list.width
                property bool expanded: false
                property bool isLong: model.text.length > 12

                height: expanded
                        ? 7 + Math.max(20, todoText.implicitHeight) + 2 + 15 + 8
                        : 48
                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                Rectangle {
                    id: rowBg
                    anchors.fill: parent
                    radius: 9
                    color: rowHover.containsMouse ? Qt.rgba(255, 255, 255, 0.5) : (done ? Qt.rgba(255, 255, 255, 0.3) : "transparent")
                    Behavior on color { ColorAnimation { duration: 180 } }
                }

                Text {
                    id: rowIndex
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    horizontalAlignment: Text.AlignHCenter
                    text: (index + 1)
                    color: done ? Qt.rgba(0.29, 0.25, 0.21, 0.4) : mutedInk
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 11
                    Behavior on color { ColorAnimation { duration: 260 } }
                }

                Rectangle {
                    id: check
                    width: 22
                    height: 22
                    radius: 11
                    anchors.left: rowIndex.right
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    scale: checkArea.pressed ? 0.85 : 1
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    color: done ? doneColor : "transparent"
                    border.width: done ? 0 : 2
                    border.color: done ? "transparent" : Qt.rgba(0.27, 0.22, 0.16, 0.3)
                    Behavior on color { ColorAnimation { duration: 220 } }
                    Behavior on border.color { ColorAnimation { duration: 220 } }

                    IconGlyph {
                        anchors.centerIn: parent
                        kind: "check"
                        size: 11
                        color: "#FFFDF6"
                        opacity: done ? 1 : 0
                        scale: done ? 1 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                        Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutQuart } }
                    }

                    MouseArea {
                        id: checkArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: toggleRow()
                    }
                }

                Text {
                    id: todoText
                    anchors.left: check.right
                    anchors.leftMargin: 10
                    anchors.right: expandBtn.left
                    anchors.rightMargin: 8
                    anchors.top: parent.top
                    anchors.topMargin: 7
                    height: expanded ? implicitHeight : 18
                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    text: model.text
                    color: done ? "#8A7864" : inkColor
                    elide: expanded ? Text.ElideNone : Text.ElideRight
                    wrapMode: expanded ? Text.WrapAnywhere : Text.NoWrap
                    maximumLineCount: expanded ? 100 : 1
                    clip: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 13
                    Behavior on color { ColorAnimation { duration: 260 } }

                    Rectangle {
                        id: strike
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: done ? parent.width : 0
                        height: 1.5
                        radius: 0.75
                        color: Qt.rgba(0.43, 0.35, 0.27, 0.45)
                        Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                    }

                    // full text tooltip on hover when collapsed
                    ToolTip {
                        id: fullTip
                        visible: rowHover.containsMouse && !expanded && row.isLong
                        text: model.text
                        delay: 600
                        width: Math.min(260, 200)
                    }
                }

                TextInput {
                    id: editInput
                    anchors.left: todoText.left
                    anchors.right: expandBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    visible: false
                    z: 2
                    color: inkColor
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 13
                    selectByMouse: true
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        radius: 5
                        color: Qt.rgba(255, 255, 255, 0.7)
                        border.width: 1
                        border.color: accentDeep
                        z: -1
                    }

                    onAccepted: saveEdit()
                    onActiveFocusChanged: {
                        if (!activeFocus && visible) saveEdit()
                    }
                }

                Text {
                    id: todoTime
                    anchors.left: todoText.left
                    anchors.top: todoText.bottom
                    anchors.topMargin: 2
                    text: root.formatTime(model.created_at, model.done_at, done)
                    color: Qt.rgba(0.29, 0.25, 0.21, 0.5)
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    width: todoText.width
                }

                Rectangle {
                    id: expandBtn
                    width: 22
                    height: 22
                    radius: 11
                    anchors.right: delBtn.left
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: row.isLong ? 1 : 0
                    scale: expandArea.pressed ? 0.85 : 1
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    color: expandArea.containsMouse ? Qt.rgba(0.27, 0.22, 0.16, 0.1) : "transparent"
                    Behavior on color { ColorAnimation { duration: 160 } }

                    IconGlyph {
                        anchors.centerIn: parent
                        kind: "chevron"
                        size: 9
                        color: mutedInk
                        rotation: row.expanded ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                    MouseArea {
                        id: expandArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: row.isLong
                        onClicked: row.expanded = !row.expanded
                    }
                }

                Rectangle {
                    id: editBtn
                    width: 22
                    height: 22
                    radius: 11
                    anchors.right: expandBtn.left
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: rowHover.containsMouse || editArea.containsMouse ? 1 : 0
                    scale: editArea.pressed ? 0.85 : 1
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    color: editArea.containsMouse ? Qt.rgba(0.27, 0.22, 0.16, 0.1) : "transparent"
                    Behavior on color { ColorAnimation { duration: 160 } }

                    IconGlyph {
                        anchors.centerIn: parent
                        kind: "edit"
                        size: 10
                        color: editArea.containsMouse ? accentDeep : mutedInk
                    }
                    MouseArea {
                        id: editArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: startEdit()
                    }
                }

                Rectangle {
                    id: delBtn
                    width: 22
                    height: 22
                    radius: 11
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    scale: delArea.pressed ? 0.85 : 1
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    color: delArea.containsMouse ? doneColor : Qt.rgba(0.6, 0.25, 0.15, 0.15)
                    opacity: rowHover.containsMouse || delArea.containsMouse ? 1 : 0
                    Behavior on color { ColorAnimation { duration: 160 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    IconGlyph {
                        anchors.centerIn: parent
                        kind: "close"
                        size: 8
                        color: delArea.containsMouse ? "#FFFDF6" : doneColor
                    }
                    MouseArea {
                        id: delArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var id = model.id
                            todoModel.remove(index)
                            bridge.deleteTodo(id)
                        }
                    }
                }

                MouseArea {
                    id: rowHover
                    anchors.fill: parent
                    z: -1
                    hoverEnabled: true
                    onClicked: {
                        if (!editInput.visible) toggleRow()
                    }
                }

                function startEdit() {
                    row.expanded = false
                    editInput.text = model.text
                    editInput.visible = true
                    editInput.forceActiveFocus()
                    editInput.selectAll()
                }

                function saveEdit() {
                    if (!editInput.visible) return
                    var text = editInput.text.trim()
                    editInput.visible = false
                    if (text.length > 0 && text !== model.text) {
                        todoModel.setProperty(index, "text", text)
                        bridge.updateTodo(model.id, text)
                    }
                }

                function toggleRow() {
                    var newDone = !done
                    var now = ""
                    var d = new Date()
                    now = d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate()) +
                          " " + pad2(d.getHours()) + ":" + pad2(d.getMinutes()) + ":" + pad2(d.getSeconds())
                    todoModel.setProperty(index, "done", newDone)
                    todoModel.setProperty(index, "done_at", newDone ? now : "")
                    bridge.toggleTodo(model.id, newDone)
                    if (root.sortMode === "done_desc") {
                        var id = model.id
                        var item = {"id": id, "text": model.text, "done": newDone,
                                    "created_at": model.created_at, "done_at": newDone ? now : ""}
                        todoModel.remove(index)
                        var i = 0
                        var inserted = false
                        if (newDone) {
                            for (i = 0; i < todoModel.count; i++) {
                                if (todoModel.get(i).done) { todoModel.insert(i, item); inserted = true; break }
                            }
                            if (!inserted) todoModel.append(item)
                        } else {
                            todoModel.insert(0, item)
                        }
                    }
                    updateCount()
                }

                function pad2(n) { return n < 10 ? "0" + n : "" + n }
            }
        }

        // exit animation for note deletion
        SequentialAnimation {
            id: exitAnim
            ParallelAnimation {
                NumberAnimation { target: content; property: "scale"; to: 0.92; duration: 200; easing.type: Easing.InCubic }
                NumberAnimation { target: content; property: "opacity"; to: 0; duration: 180; easing.type: Easing.InCubic }
            }
            ScriptAction {
                script: {
                    bridge.deleteNote(noteId)
                }
            }
        }
    }

    property int doneCount: 0
    property bool dragging: false
    property bool resizing: false
    property int resizeEdge: 0
    property point resizeStartGlobal: Qt.point(0, 0)
    property real resizeStartX: 0
    property real resizeStartY: 0
    property real resizeStartW: 0
    property real resizeStartH: 0
    property string sortMode: "created_desc"
    property string sortLabel: "按添加时间"

    onXChanged: if (dragging) saveTimer.restart()
    onYChanged: if (dragging) saveTimer.restart()
    onWidthChanged: if (resizing) saveTimer.restart()
    onHeightChanged: if (resizing) saveTimer.restart()

    function addTodo() {
        var text = input.text.trim()
        if (text.length === 0) return
        var todo = bridge.addTodo(noteId, text)
        insertTodo(todo)
        input.text = ""
        updateCount()
    }

    function insertTodo(todo) {
        var i = 0
        var inserted = false
        if (sortMode === "created_asc") {
            todoModel.append(todo)
            inserted = true
        } else if (sortMode === "done_desc") {
            for (i = 0; i < todoModel.count; i++) {
                if (todoModel.get(i).done) {
                    todoModel.insert(i, todo)
                    inserted = true
                    break
                }
            }
            if (!inserted) todoModel.append(todo)
        } else {
            todoModel.insert(0, todo)
        }
        updateCount()
    }

    function cycleSort() {
        if (sortMode === "created_desc") {
            sortMode = "created_asc"
            sortLabel = "按添加时间"
        } else if (sortMode === "created_asc") {
            sortMode = "done_desc"
            sortLabel = "按完成时间"
        } else {
            sortMode = "created_desc"
            sortLabel = "按添加时间"
        }
        bridge.setNoteSort(noteId, sortMode)
        reloadTodos()
    }

    function reloadTodos() {
        todoModel.clear()
        var todos = bridge.getTodos(noteId)
        for (var i = 0; i < todos.length; i++) {
            todoModel.append(todos[i])
        }
        updateCount()
    }

    function formatTime(created, doneAt, isDone) {
        var fmt = function(s) {
            if (!s) return ""
            var m = s.match(/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})/)
            if (!m) return s
            return m[3] + "/" + m[2] + " " + m[4] + ":" + m[5]
        }
        var c = fmt(created)
        if (isDone && doneAt) {
            return "完成 " + fmt(doneAt)
        }
        return "添加 " + c
    }

    Component.onCompleted: {
        sortMode = bridge.getNoteSort(noteId)
        reloadTodos()
        tapeColor = bridge.getTapeColor(noteId)
        playAppear()
    }

    onVisibleChanged: {
        if (visible) playAppear()
    }

    function playAppear() {
        root.opacity = noteOpacity
        content.opacity = 0
        content.scale = 0.94
        appearOpacity.start()
        appearScale.start()
    }

    function updateCount() {
        var d = 0
        for (var i = 0; i < todoModel.count; i++) {
            if (todoModel.get(i).done) d++
        }
        doneCount = d
    }

    Connections {
        target: todoModel
        function onRowsInserted() { updateCount() }
        function onRowsRemoved() { updateCount() }
        function onDataChanged() { updateCount() }
    }

    // consistent icon system: one stroke, round caps
    component IconGlyph: Canvas {
        property string kind: ""
        property color color: "#000000"
        width: size
        height: size
        property real size: 10

        antialiasing: true
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var s = width
            var t = Math.max(1.3, s / 6)
            ctx.strokeStyle = color
            ctx.lineWidth = t
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            if (kind === "check") {
                ctx.beginPath()
                ctx.moveTo(s * 0.16, s * 0.54)
                ctx.lineTo(s * 0.42, s * 0.8)
                ctx.lineTo(s * 0.86, s * 0.18)
                ctx.stroke()
            } else if (kind === "edit") {
                ctx.beginPath()
                ctx.moveTo(s * 0.12, s * 0.88)
                ctx.lineTo(s * 0.3, s * 0.82)
                ctx.lineTo(s * 0.82, s * 0.3)
                ctx.lineTo(s * 0.7, s * 0.18)
                ctx.lineTo(s * 0.18, s * 0.7)
                ctx.closePath()
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(s * 0.68, s * 0.16)
                ctx.lineTo(s * 0.84, s * 0.32)
                ctx.stroke()
            } else if (kind === "plus") {
                ctx.beginPath()
                ctx.moveTo(s * 0.5, s * 0.16)
                ctx.lineTo(s * 0.5, s * 0.84)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(s * 0.16, s * 0.5)
                ctx.lineTo(s * 0.84, s * 0.5)
                ctx.stroke()
            } else if (kind === "close") {
                ctx.beginPath()
                ctx.moveTo(s * 0.18, s * 0.18)
                ctx.lineTo(s * 0.82, s * 0.82)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(s * 0.82, s * 0.18)
                ctx.lineTo(s * 0.18, s * 0.82)
                ctx.stroke()
            } else if (kind === "sort") {
                var arrow = function(yTop, yBottom) {
                    ctx.beginPath()
                    ctx.moveTo(s * 0.5, yTop)
                    ctx.lineTo(s * 0.5, yBottom)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(s * 0.5, yTop)
                    ctx.lineTo(s * 0.3, yTop + s * 0.12)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(s * 0.5, yTop)
                    ctx.lineTo(s * 0.7, yTop + s * 0.12)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(s * 0.5, yBottom)
                    ctx.lineTo(s * 0.3, yBottom - s * 0.12)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(s * 0.5, yBottom)
                    ctx.lineTo(s * 0.7, yBottom - s * 0.12)
                    ctx.stroke()
                }
                arrow(s * 0.18, s * 0.82)
            } else if (kind === "chevron") {
                ctx.beginPath()
                ctx.moveTo(s * 0.22, s * 0.36)
                ctx.lineTo(s * 0.5, s * 0.64)
                ctx.lineTo(s * 0.78, s * 0.36)
                ctx.stroke()
            } else if (kind === "slider") {
                ctx.beginPath()
                ctx.moveTo(s * 0.1, s * 0.3)
                ctx.lineTo(s * 0.9, s * 0.3)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(s * 0.35, s * 0.3, s * 0.12, 0, Math.PI * 2)
                ctx.fillStyle = color
                ctx.fill()
                ctx.beginPath()
                ctx.arc(s * 0.65, s * 0.3, s * 0.12, 0, Math.PI * 2)
                ctx.fill()
                ctx.beginPath()
                ctx.moveTo(s * 0.1, s * 0.7)
                ctx.lineTo(s * 0.9, s * 0.7)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(s * 0.35, s * 0.7, s * 0.12, 0, Math.PI * 2)
                ctx.fill()
                ctx.beginPath()
                ctx.arc(s * 0.65, s * 0.7, s * 0.12, 0, Math.PI * 2)
                ctx.fill()
            }
        }
        onKindChanged: requestPaint()
        onColorChanged: requestPaint()
        onWidthChanged: requestPaint()
    }
}
