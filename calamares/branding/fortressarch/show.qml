import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Image {
            source: "logo.svg"
            anchors.centerIn: parent
            width: 220
            height: 220
            fillMode: Image.PreserveAspectFit
        }
        Text {
            anchors.top: parent.verticalCenter
            anchors.topMargin: 120
            anchors.horizontalCenter: parent.horizontalCenter
            text: "FortressArch protects itself automatically"
            font.pixelSize: 18
            color: "#eaeaea"
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.7
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: "Before risky updates, a snapshot is taken automatically. If something breaks, it can roll back on its own."
            font.pixelSize: 18
            color: "#eaeaea"
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.7
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: "Corrupted system files are detected and repaired in the background, without needing your help."
            font.pixelSize: 18
            color: "#eaeaea"
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.7
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: "You are notified when it matters, and can always ask for help if something needs a closer look."
            font.pixelSize: 18
            color: "#eaeaea"
        }
    }
}
