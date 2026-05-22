import CoreGraphics
import MacroMonstersCore
import SpriteKit

final class IsometricBaseScene: SKScene {
    private let tileWidth: CGFloat = 74
    private let tileHeight: CGFloat = 38
    private var lastConfiguration = Configuration()

    override init(size: CGSize = CGSize(width: 900, height: 700)) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = SKColor(red: 0.10, green: 0.16, blue: 0.14, alpha: 1)
        anchorPoint = CGPoint(x: 0, y: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scaleMode = .resizeFill
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        draw(configuration: lastConfiguration)
    }

    func configure(
        baseLevel: Int,
        decorLevel: Int,
        carbHabitatLevel: Int,
        proteinHabitatLevel: Int,
        fatHabitatLevel: Int,
        creatures: [CreatureKind]
    ) {
        let configuration = Configuration(
            baseLevel: max(0, baseLevel),
            decorLevel: max(0, decorLevel),
            carbHabitatLevel: max(0, carbHabitatLevel),
            proteinHabitatLevel: max(0, proteinHabitatLevel),
            fatHabitatLevel: max(0, fatHabitatLevel),
            creatures: creatures
        )
        lastConfiguration = configuration
        draw(configuration: configuration)
    }

    private func draw(configuration: Configuration) {
        removeAllChildren()
        drawGroundShadow(for: configuration)
        drawTiles(for: configuration)
        drawHabitats(for: configuration)
        drawTownCenter(level: configuration.baseLevel)
        drawDecor(level: configuration.decorLevel)
        drawCreatures(configuration.creatures)
    }

    private func drawGroundShadow(for configuration: Configuration) {
        let shadow = SKShapeNode(ellipseOf: CGSize(
            width: CGFloat(320 + configuration.baseLevel * 64),
            height: CGFloat(110 + configuration.baseLevel * 18)
        ))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.22)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: size.width / 2, y: baseOriginY + 40)
        shadow.zPosition = -20
        addChild(shadow)
    }

    private func drawTiles(for configuration: Configuration) {
        let radius = 2 + configuration.baseLevel
        for x in -radius...radius {
            for y in -radius...radius where abs(x) + abs(y) <= radius + 1 {
                let tile = makeDiamondTile(
                    fill: tileColor(x: x, y: y, decorLevel: configuration.decorLevel),
                    stroke: SKColor.white.withAlphaComponent(0.12)
                )
                tile.position = tilePosition(x: x, y: y)
                tile.zPosition = zPosition(for: tile.position.y)
                addChild(tile)
            }
        }
    }

    private func drawTownCenter(level: Int) {
        let center = makeStackedBlock(
            topColor: SKColor(red: 0.61, green: 0.70, blue: 0.58, alpha: 1),
            sideColor: SKColor(red: 0.34, green: 0.42, blue: 0.34, alpha: 1),
            height: CGFloat(42 + level * 9),
            label: "MM"
        )
        center.position = tilePosition(x: 0, y: 0)
        center.zPosition = zPosition(for: center.position.y) + 25
        addChild(center)
    }

    private func drawHabitats(for configuration: Configuration) {
        if configuration.carbHabitatLevel > 0 {
            addHabitat(
                name: "Grain",
                x: -2,
                y: 1,
                level: configuration.carbHabitatLevel,
                color: SKColor(red: 0.85, green: 0.57, blue: 0.20, alpha: 1)
            )
        }

        if configuration.proteinHabitatLevel > 0 {
            addHabitat(
                name: "Amino",
                x: 2,
                y: 0,
                level: configuration.proteinHabitatLevel,
                color: SKColor(red: 0.24, green: 0.61, blue: 0.38, alpha: 1)
            )
        }

        if configuration.fatHabitatLevel > 0 {
            addHabitat(
                name: "Oil",
                x: 0,
                y: 2,
                level: configuration.fatHabitatLevel,
                color: SKColor(red: 0.78, green: 0.32, blue: 0.44, alpha: 1)
            )
        }
    }

    private func addHabitat(name: String, x: Int, y: Int, level: Int, color: SKColor) {
        let habitat = makeStackedBlock(
            topColor: color,
            sideColor: color.withAlphaComponent(0.70),
            height: CGFloat(26 + level * 7),
            label: name
        )
        habitat.position = tilePosition(x: x, y: y)
        habitat.zPosition = zPosition(for: habitat.position.y) + 20
        addChild(habitat)
    }

    private func drawDecor(level: Int) {
        guard level > 0 else {
            return
        }

        let points = [
            (-3, 0), (-1, -2), (1, -2), (3, -1),
            (-2, 2), (2, 2), (0, -3), (3, 1)
        ]

        for (index, point) in points.prefix(level * 2).enumerated() {
            let tree = makeTree(index: index)
            tree.position = tilePosition(x: point.0, y: point.1)
            tree.zPosition = zPosition(for: tree.position.y) + 15
            addChild(tree)
        }
    }

    private func drawCreatures(_ creatures: [CreatureKind]) {
        let roamingPoints = [
            (-1, 1), (1, -1), (-2, -1), (2, 1), (0, 2), (0, -2),
            (-1, -2), (2, -2), (-3, 1), (3, 0)
        ]

        for (index, kind) in creatures.enumerated() {
            let point = roamingPoints[index % roamingPoints.count]
            let creature = makeCreature(kind: kind)
            creature.position = tilePosition(x: point.0, y: point.1)
            creature.zPosition = zPosition(for: creature.position.y) + 35
            addChild(creature)
            animateCreature(creature, index: index)
        }
    }

    private func makeDiamondTile(fill: SKColor, stroke: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: tileHeight / 2))
        path.addLine(to: CGPoint(x: tileWidth / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -tileHeight / 2))
        path.addLine(to: CGPoint(x: -tileWidth / 2, y: 0))
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        node.fillColor = fill
        node.strokeColor = stroke
        node.lineWidth = 1
        return node
    }

    private func makeStackedBlock(topColor: SKColor, sideColor: SKColor, height: CGFloat, label: String) -> SKNode {
        let container = SKNode()

        let sidePath = CGMutablePath()
        sidePath.move(to: CGPoint(x: -tileWidth / 2, y: 0))
        sidePath.addLine(to: CGPoint(x: 0, y: -tileHeight / 2))
        sidePath.addLine(to: CGPoint(x: tileWidth / 2, y: 0))
        sidePath.addLine(to: CGPoint(x: tileWidth / 2, y: -height))
        sidePath.addLine(to: CGPoint(x: 0, y: -height - tileHeight / 2))
        sidePath.addLine(to: CGPoint(x: -tileWidth / 2, y: -height))
        sidePath.closeSubpath()

        let side = SKShapeNode(path: sidePath)
        side.fillColor = sideColor
        side.strokeColor = sideColor.withAlphaComponent(0.75)
        side.lineWidth = 1
        side.zPosition = 0
        container.addChild(side)

        let top = makeDiamondTile(fill: topColor, stroke: SKColor.white.withAlphaComponent(0.25))
        top.position = CGPoint(x: 0, y: 0)
        top.zPosition = 1
        container.addChild(top)

        let labelNode = SKLabelNode(text: label)
        labelNode.fontName = "AvenirNext-DemiBold"
        labelNode.fontSize = 11
        labelNode.fontColor = SKColor.white.withAlphaComponent(0.90)
        labelNode.position = CGPoint(x: 0, y: -6)
        labelNode.zPosition = 2
        container.addChild(labelNode)

        return container
    }

    private func makeTree(index: Int) -> SKNode {
        let container = SKNode()
        let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: 18), cornerRadius: 2)
        trunk.fillColor = SKColor(red: 0.38, green: 0.25, blue: 0.16, alpha: 1)
        trunk.strokeColor = .clear
        trunk.position = CGPoint(x: 0, y: -10)
        container.addChild(trunk)

        let crown = SKShapeNode(circleOfRadius: CGFloat(15 + index % 2 * 3))
        crown.fillColor = SKColor(red: 0.20, green: 0.50, blue: 0.31, alpha: 1)
        crown.strokeColor = SKColor.white.withAlphaComponent(0.12)
        crown.position = CGPoint(x: 0, y: 6)
        crown.zPosition = 1
        container.addChild(crown)
        return container
    }

    private func makeCreature(kind: CreatureKind) -> SKNode {
        let container = SKNode()
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 30, height: 10))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.25)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -13)
        container.addChild(shadow)

        let body = SKShapeNode(ellipseOf: CGSize(width: 26, height: 30))
        body.fillColor = creatureColor(kind)
        body.strokeColor = SKColor.white.withAlphaComponent(0.24)
        body.lineWidth = 1
        body.zPosition = 1
        container.addChild(body)

        let face = SKShapeNode(ellipseOf: CGSize(width: 12, height: 5))
        face.fillColor = SKColor.white.withAlphaComponent(0.35)
        face.strokeColor = .clear
        face.position = CGPoint(x: 0, y: -1)
        face.zPosition = 2
        container.addChild(face)

        return container
    }

    private func animateCreature(_ node: SKNode, index: Int) {
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 7, duration: 0.8),
            SKAction.moveBy(x: 0, y: -7, duration: 0.8)
        ])
        let drift = SKAction.sequence([
            SKAction.moveBy(x: CGFloat(index % 2 == 0 ? 18 : -18), y: CGFloat(index % 3 - 1) * 8, duration: 2.4),
            SKAction.moveBy(x: CGFloat(index % 2 == 0 ? -18 : 18), y: CGFloat(1 - index % 3) * 8, duration: 2.4)
        ])
        node.run(SKAction.repeatForever(SKAction.group([bob, drift])))
    }

    private func tilePosition(x: Int, y: Int) -> CGPoint {
        CGPoint(
            x: size.width / 2 + CGFloat(x - y) * tileWidth / 2,
            y: baseOriginY + CGFloat(x + y) * tileHeight / 2
        )
    }

    private var baseOriginY: CGFloat {
        max(150, size.height * 0.35)
    }

    private func zPosition(for y: CGFloat) -> CGFloat {
        1_000 - y
    }

    private func tileColor(x: Int, y: Int, decorLevel: Int) -> SKColor {
        let alternating = (x + y).isMultiple(of: 2)
        let green = alternating ? 0.36 : 0.32
        let boost = CGFloat(decorLevel) * 0.018
        return SKColor(red: 0.21, green: CGFloat(green) + boost, blue: 0.24, alpha: 1)
    }

    private func creatureColor(_ kind: CreatureKind) -> SKColor {
        switch kind {
        case .grainling:
            return SKColor(red: 0.90, green: 0.62, blue: 0.23, alpha: 1)
        case .flexling:
            return SKColor(red: 0.29, green: 0.68, blue: 0.42, alpha: 1)
        case .oilkin:
            return SKColor(red: 0.81, green: 0.36, blue: 0.51, alpha: 1)
        }
    }
}

private struct Configuration: Equatable {
    var baseLevel = 0
    var decorLevel = 0
    var carbHabitatLevel = 0
    var proteinHabitatLevel = 0
    var fatHabitatLevel = 0
    var creatures: [CreatureKind] = []
}
