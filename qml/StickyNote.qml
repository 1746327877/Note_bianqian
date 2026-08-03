import QtQuick
import QtQuick.Controls

Window {
    id: root
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"
    width: 280
    height: 380
    opacity: 0

    property int noteId: -1
    property color paperColor: "#FDF6E3"
    property color paperLight: Qt.lighter(paperColor, 1.06)
    property color paperDark: Qt.darker(paperColor, 1.04)
    property color inkColor: "#4A3F35"
    property color mutedInk: Qt.rgba(0.29, 0.25, 0.21, 0.55)
    property color accent: "#E8A33D"
    property real noteOpacity: 0.96
    property string tapeColor: "#E8B84B"

    onPaperColorChanged: tapeColor = bridge.getTapeColor(noteId)

    Item {
        id: content
        anchors.fill: parent
        scale: 0.7
        opacity: 0

        NumberAnimation on scale {
            id: appearScale
            to: 1
            duration: 320
            easing.type: Easing.OutBack
        }
        NumberAnimation on opacity {
            id: appearOpacity
            to: 1
            duration: 240
        }

        // soft shadow stack
        Rectangle {
            anchors.fill: paper
            anchors.margins: -4
            radius: 16
            color: "transparent"
            border.width: 0
            z: 0
            Rectangle {
                anchors.fill: parent
                radius: 16
                color: "#12000000"
                anchors.margins: 3
            }
            Rectangle {
                anchors.fill: parent
                radius: 16
                color: "#12000000"
                anchors.margins: 6
            }
            Rectangle {
                anchors.fill: parent
                radius: 16
                color: "#10000000"
                anchors.margins: 9
            }
        }

        Rectangle {
            id: paper
            anchors.fill: parent
            anchors.margins: 10
            radius: 12
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.06)
            gradient: Gradient {
                GradientStop { position: 0.0; color: paperLight }
                GradientStop { position: 1.0; color: paperDark }
            }

            // tape strip
            Rectangle {
                id: tape
                width: 118
                height: 26
                radius: 2
                color: tapeColor
                opacity: 0.85
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -12
                rotation: -3
                border.width: 0
                layer.enabled: true
                layer.samples: 4
                layer.smooth: true
            }

            // header
            Text {
                id: titleText
                anchors.top: parent.top
                anchors.topMargin: 22
                anchors.left: parent.left
                anchors.leftMargin: 16
                text: "便签"
                color: mutedInk
                font.family: "Microsoft YaHei"
                font.pixelSize: 13
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
                Text {
                    text: "✕"
                    color: closeArea.containsMouse ? "#B3502E" : mutedInk
                    anchors.centerIn: parent
                    font.pixelSize: 15
                    Behavior on color { ColorAnimation { duration: 160 } }
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
                height: 34
                radius: 17
                color: Qt.rgba(255, 255, 255, 0.55)
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.07)

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

                    property string placeholderText: "写下新待办..."
                    Text {
                        text: input.placeholderText
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
                    width: 28
                    height: 28
                    radius: 14
                    color: addArea.containsMouse ? Qt.darker(accent, 1.05) : accent
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        text: "＋"
                        color: "#FFFDF6"
                        anchors.centerIn: parent
                        font.pixelSize: 17
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
                anchors.bottomMargin: 4
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
                        NumberAnimation { property: "y"; from: 24; to: 0; duration: 240; easing.type: Easing.OutCubic }
                    }
                }
                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; to: 0; duration: 160; easing.type: Easing.InCubic }
                        NumberAnimation { property: "height"; to: 0; duration: 200; easing.type: Easing.InCubic }
                    }
                }
                displaced: Transition {
                    NumberAnimation { property: "y"; duration: 220; easing.type: Easing.OutCubic }
                }
            }

            Text {
                id: emptyHint
                visible: todoModel.count === 0
                anchors.centerIn: list
                text: "空空的\n写点什么吧"
                color: mutedInk
                horizontalAlignment: Text.AlignHCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 13
                opacity: 0.8
            }

            // footer: progress + slider
            Rectangle {
                id: footer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 44
                color: "transparent"

                Rectangle {
                    id: progressTrack
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 64
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 4
                    height: 3
                    radius: 1.5
                    color: Qt.rgba(0, 0, 0, 0.08)

                    Rectangle {
                        id: progressFill
                        width: todoModel.count === 0 ? 0 : Math.max(6, progressTrack.width * doneCount / todoModel.count)
                        height: parent.height
                        radius: 1.5
                        color: accent
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    }
                }

                Text {
                    id: progressText
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 4
                    text: doneCount + "/" + todoModel.count
                    color: mutedInk
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 11
                }

                // opacity slider
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                    spacing: 6

                    Text {
                        text: "透明度"
                        color: mutedInk
                        font.pixelSize: 10
                        font.family: "Microsoft YaHei"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Slider {
                        id: opacitySlider
                        width: 90
                        height: 14
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
                            color: Qt.rgba(0, 0, 0, 0.08)
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
                            border.color: Qt.rgba(0, 0, 0, 0.15)
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
            property point pressPos: Qt.point(0, 0)
            property point winPos: Qt.point(0, 0)

            onPressed: {
                pressPos = Qt.point(mouse.x, mouse.y)
                winPos = Qt.point(root.x, root.y)
            }
            onPositionChanged: {
                if (pressed) {
                    root.x = winPos.x + (mouse.x - pressPos.x)
                    root.y = winPos.y + (mouse.y - pressPos.y)
                }
            }
            onReleased: bridge.noteMoved(noteId, root.x, root.y)
        }

                Component {
                    id: todoDelegate
                    Item {
                        id: row
                        width: list.width
                        height: 42

                        Rectangle {
                            id: rowBg
                            anchors.fill: parent
                            radius: 9
                            color: rowHover.containsMouse ? Qt.rgba(255, 255, 255, 0.45) : (done ? Qt.rgba(255, 255, 255, 0.25) : "transparent")
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }

                        Rectangle {
                            id: check
                            width: 22
                            height: 22
                            radius: 11
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            color: done ? accent : "transparent"
                            border.width: 2
                            border.color: done ? accent : Qt.rgba(0, 0, 0, 0.25)
                            Behavior on color { ColorAnimation { duration: 220 } }
                            Behavior on border.color { ColorAnimation { duration: 220 } }

                            Text {
                                text: "✓"
                                color: "#FFFDF6"
                                anchors.centerIn: parent
                                font.pixelSize: 13
                                font.bold: true
                                opacity: done ? 1 : 0
                                scale: done ? 1 : 0.2
                                Behavior on opacity { NumberAnimation { duration: 180 } }
                                Behavior on scale { SpringAnimation { spring: 3; damping: 0.25; duration: 300 } }
                            }

                            MouseArea {
                                id: checkArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    popAnim.restart()
                                    toggleRow()
                                }
                            }
                            SequentialAnimation {
                                id: popAnim
                                NumberAnimation { target: check; property: "scale"; to: 0.72; duration: 90 }
                                NumberAnimation { target: check; property: "scale"; to: 1.0; duration: 260; easing.type: Easing.OutBack }
                            }
                        }

                        Text {
                            id: todoText
                            anchors.left: check.right
                            anchors.leftMargin: 10
                            anchors.right: delBtn.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.text
                            color: done ? Qt.rgba(0.29, 0.25, 0.21, 0.45) : inkColor
                            elide: Text.ElideRight
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
                                color: Qt.rgba(0.29, 0.25, 0.21, 0.4)
                                Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                            }
                        }

                        Rectangle {
                            id: delBtn
                            width: 20
                            height: 20
                            radius: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            color: delArea.containsMouse ? "#B3502E" : "transparent"
                            opacity: rowHover.containsMouse ? 1 : 0
                            Behavior on color { ColorAnimation { duration: 160 } }
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            Text {
                                text: "✕"
                                color: "#FFFDF6"
                                anchors.centerIn: parent
                                font.pixelSize: 11
                            }
                            MouseArea {
                                id: delArea
                                anchors.fill: parent
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
                            onClicked: toggleRow()
                        }

                        function toggleRow() {
                            todoModel.setProperty(index, "done", !done)
                            bridge.toggleTodo(model.id, !done)
                        }
                    }
                }

        // exit animation for note deletion
        SequentialAnimation {
            id: exitAnim
            ParallelAnimation {
                NumberAnimation { target: content; property: "scale"; to: 0.5; duration: 200; easing.type: Easing.InBack }
                NumberAnimation { target: content; property: "opacity"; to: 0; duration: 180; easing.type: Easing.InCubic }
            }
            ScriptAction {
                script: {
                    root.opacity = 0
                    bridge.deleteNote(noteId)
                }
            }
        }
    }

    property int doneCount: 0

    function addTodo() {
        var text = input.text.trim()
        if (text.length === 0) return
        var id = bridge.addTodo(noteId, text)
        todoModel.append({"id": id, "text": text, "done": false})
        input.text = ""
        updateCount()
    }

    Component.onCompleted: {
        var todos = bridge.getTodos(noteId)
        for (var i = 0; i < todos.length; i++) {
            todoModel.append(todos[i])
        }
        updateCount()
        tapeColor = bridge.getTapeColor(noteId)
        root.opacity = noteOpacity
        content.opacity = 0
        content.scale = 0.7
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
}
