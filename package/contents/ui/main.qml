import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    implicitWidth: 48
    implicitHeight: 32

    property string lastFile: ""

    function stripFileScheme(urlValue) {
        let s = urlValue.toString ? urlValue.toString() : String(urlValue)
        s = decodeURIComponent(s)
        return s.replace(/^file:\/\//, "")
    }

    function shellQuote(s) {
        return "'" + s.replace(/'/g, "'\"'\"'") + "'"
    }

    function runPlot(filePaths) {
        const scriptPath = stripFileScheme(Qt.resolvedUrl("../../plot-file.sh"))
        let cmd = "bash " + shellQuote(scriptPath)

        for (const filePath of filePaths) {
            cmd += " " + shellQuote(filePath)
        }

        executable.exec(cmd)
        lastFile = filePaths[filePaths.length - 1]
    }

    preferredRepresentation: compactRepresentation

    compactRepresentation: Rectangle {
        implicitWidth: 48
        implicitHeight: 32
        radius: 10
        border.width: 1
        border.color: "#cbd5e1"
        color: "#292525ff"

        QQC2.Label {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            text: "\u00B6"
            font.pixelSize: Math.max(16, Math.min(parent.width, parent.height) * 0.6)
            font.weight: Font.DemiBold
            color: "#f8fafc"
        }

        DropArea {
            anchors.fill: parent

            onDropped: function(drop) {
                if (!drop.hasUrls || drop.urls.length === 0) {
                    return
                }

                const filePaths = []
                for (const url of drop.urls) {
                    filePaths.push(root.stripFileScheme(url))
                }

                root.runPlot(filePaths)
            }
        }
    }

    fullRepresentation: compactRepresentation

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            disconnectSource(source)

            if (data.stderr && data.stderr.length > 0) {
                console.log("plot error:", data.stderr)
            }
        }

        function exec(cmd) {
            connectSource(cmd)
        }
    }
}
