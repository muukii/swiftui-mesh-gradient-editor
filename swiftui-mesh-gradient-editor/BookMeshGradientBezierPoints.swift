import SwiftUI
import SwiftUISupport

struct BookMeshGradientBezierPoints: View, PreviewProvider {
  var body: some View {
    ContentView()
  }

  static var previews: some View {
    Self()
  }

  private struct ContentView: View {

    enum Locations {

      struct BezierPoints {
        var matrix: [[BezierControlPoint]]

        var width: Int {
          matrix.first?.count ?? 0
        }

        var height: Int {
          matrix.count
        }

        consuming func addHorizonal() -> Self {
          // update position
          do {
            let coefficient = (1 - (1 / Float(width)))

            for column in matrix.indices {
              for row in matrix[column].indices {
                matrix[column][row].point.position.x *= coefficient
              }
            }
          }

          // apply
          do {
            let step = 1.0 / Float(height - 1)

            for column in matrix.indices {

              let newColor = matrix[column].last!.color

              let position = SIMD2<Float>.init(1, Float(column) * step)
              matrix[column].append(
                .init(
                  point: .init(
                    position: position,
                    leadingControlPoint: position,
                    topControlPoint: position,
                    trailingControlPoint: position,
                    bottomControlPoint: position
                  ),
                  color: newColor
                )
              )
            }
          }

          return self
        }

        consuming func removeHorizontal() -> Self {
          guard width > 2 else {
            return self
          }

          // apply
          do {
            for i in matrix.indices {
              matrix[i].removeLast()
            }
          }

          // update position
          do {
            let coefficient = (1 + (1 / Float(width - 1)))

            for column in matrix.indices {
              for row in matrix[column].indices {
                matrix[column][row].point.position.x *= coefficient
              }
            }

            for column in matrix.indices {
              matrix[column][width - 1].point.position.x = 1
            }
          }

          return self
        }

        consuming func addVertical() -> Self {

          // update position
          do {
            let coefficient = (1 - (1 / Float(height)))

            for column in matrix.indices {
              for row in matrix[column].indices {
                matrix[column][row].point.position.y *= coefficient
              }
            }

          }

          // apply
          do {
            let step = 1.0 / Float(width - 1)

            var row: [BezierControlPoint] = []

            for i in 0..<width {

              let newColor = matrix.last![i].color

              let position = SIMD2<Float>.init(Float(i) * step, 1)

              row.append(
                .init(
                  point: .init(
                    position: position,
                    leadingControlPoint: position,
                    topControlPoint: position,
                    trailingControlPoint: position,
                    bottomControlPoint: position
                  ),
                  color: newColor
                )
              )

            }

            matrix.append(
              row
            )
          }

          return self

        }

        consuming func removeVertical() -> Self {
          guard height > 2 else {
            return self
          }

          // Apply
          do {

            matrix.removeLast()

          }

          // update position

          do {
            let coefficient = (1 + (1 / Float(height - 1)))

            for column in matrix.indices {
              for row in matrix[column].indices {
                matrix[column][row].point.position.y *= coefficient
              }
            }

            for row in matrix[height - 1].indices {
              matrix[height - 1][row].point.position.y = 1
            }
          }

          return self
        }
      }

      struct Points {
        var matrix: [[ControlPoint]]

        var width: Int {
          matrix.first?.count ?? 0
        }

        var height: Int {
          matrix.count
        }

        consuming func addHorizonal() -> Self {

          // update position
          do {
            let coefficient = (1 - (1 / Float(width)))
            
            for column in matrix.indices {
              for row in matrix[column].indices {
                matrix[column][row].position.x *= coefficient
              }
            }
          }
          
          // apply
          do {
            let step = 1.0 / Float(height - 1)
            
            for column in matrix.indices {
              
              let newColor = matrix[column].last!.color
              
              matrix[column].append(
                .init(
                  position: .init(1, Float(column) * step),
                  color: newColor
                )
              )
            }
          }

          return self
        }

        consuming func removeHorizontal() -> Self {
          guard width > 2 else {
            return self
          }
                    
          // apply
          do {
            for i in matrix.indices {
              matrix[i].removeLast()
            }
          }
          
          // update position
          do {
            let coefficient = (1 + (1 / Float(width - 1)))
            
            for column in matrix.indices {
              for row in matrix[column].indices {
                matrix[column][row].position.x *= coefficient
              }
            }
            
            for column in matrix.indices {
              matrix[column][width - 1].position.x = 1
            }
          }
          
          return self
        }

        consuming func addVertical() -> Self {
          // update position
          do {
            let coefficient = (1 - (1 / Float(height)))

            for column in matrix.indices {
              for row in matrix[column].indices {
                matrix[column][row].position.y *= coefficient
              }
            }

          }

          // apply
          do {
            let step = 1.0 / Float(width - 1)

            var row: [ControlPoint] = []

            for i in 0..<width {

              let newColor = matrix.last![i].color

              row.append(
                .init(
                  position: .init(Float(i) * step, 1),
                  color: newColor
                )
              )
            }

            matrix.append(
              row
            )
          }

          return self
        }

        consuming func removeVertical() -> Self {
          guard height > 2 else {
            return self
          }

          // Apply
          do {

            matrix.removeLast()

          }

          // update position

          do {
            let coefficient = (1 + (1 / Float(height - 1)))

            for column in matrix.indices {
              for row in matrix[column].indices {
                matrix[column][row].position.y *= coefficient
              }
            }

            for row in matrix[height - 1].indices {
              matrix[height - 1][row].position.y = 1
            }
          }

          return self

        }
      }

      case bezierPoints(BezierPoints)
      case points(Points)

      var width: Int {
        switch self {
        case .bezierPoints(let points):
          return points.width
        case .points(let points):
          return points.width
        }

      }

      var height: Int {
        switch self {
        case .bezierPoints(let points):
          return points.height
        case .points(let points):
          return points.height
        }
      }

      consuming func addHorizonal() -> Self {
        switch self {
        case .bezierPoints(let points):
          return .bezierPoints(points.addHorizonal())
        case .points(let points):
          return .points(points.addHorizonal())
        }
      }

      consuming func removeHorizontal() -> Self {
        switch self {
        case .bezierPoints(let points):
          return .bezierPoints(points.removeHorizontal())
        case .points(let points):
          return .points(points.removeHorizontal())
        }
      }

      consuming func addVertical() -> Self {
        switch self {
        case .bezierPoints(let points):
          return .bezierPoints(points.addVertical())
        case .points(let points):
          return .points(points.addVertical())
        }
      }

      consuming func removeVertical() -> Self {
        switch self {
        case .bezierPoints(let points):
          return .bezierPoints(points.removeVertical())
        case .points(let points):
          return .points(points.removeVertical())
        }
      }
    }

    struct BezierControlPoint: Equatable {

      var point: MeshGradient.BezierPoint
      var color: Color

    }

    struct ControlPoint: Equatable {

      var position: SIMD2<Float>
      var color: Color

    }

    struct Coordinate: Equatable {
      var x: Int
      var y: Int
    }

    @State var gradientSize: CGSize = .zero

    @State var focusingPoint: Coordinate?

    @State var points2: Locations = .bezierPoints(
      .init(matrix: [
        [
          .init(
            point: .init(
              position: .init(0, 0),
              leadingControlPoint: .init(0, 0),
              topControlPoint: .init(0, 0),
              trailingControlPoint: .init(0, 0),
              bottomControlPoint: .init(0, 0)
            ),
            color: .red
          ),
          .init(
            point: .init(
              position: .init(1, 0),
              leadingControlPoint: .init(1, 0),
              topControlPoint: .init(1, 0),
              trailingControlPoint: .init(1, 0),
              bottomControlPoint: .init(1, 0)
            ),
            color: .pink
          ),
        ],
        [
          .init(
            point: .init(
              position: .init(0, 1),
              leadingControlPoint: .init(0, 1),
              topControlPoint: .init(0, 1),
              trailingControlPoint: .init(0, 1),
              bottomControlPoint: .init(0, 1)
            ),
            color: .cyan
          ),
          .init(
            point: .init(
              position: .init(1, 1),
              leadingControlPoint: .init(1, 1),
              topControlPoint: .init(1, 1),
              trailingControlPoint: .init(1, 1),
              bottomControlPoint: .init(1, 1)
            ),
            color: .purple
          ),
        ],
      ])
    )

    @State var points: Locations = .points(
      .init(matrix: [
        [
          .init(position: .init(0, 0), color: .red),
          .init(position: .init(0.5, 0), color: .orange),
          .init(position: .init(1, 0), color: .cyan),
        ],
        [
          .init(position: .init(0, 0.5), color: .yellow),
          .init(position: .init(0.5, 0.5), color: .orange),
          .init(position: .init(1, 0.5), color: .indigo),
        ],
        [
          .init(position: .init(0, 1), color: .mint),
          .init(position: .init(0.5, 1), color: .gray),
          .init(position: .init(1, 1), color: .purple),
        ],
      ])
    )

    private var gradient: MeshGradient {
      switch points {
      case .bezierPoints(let points):
        return MeshGradient(
          width: points.width,
          height: points.height,
          bezierPoints: points.matrix.flatMap { $0 }.map(\.point),
          colors: points.matrix.flatMap { $0 }.map(\.color)
        )
      case .points(let points):
        return MeshGradient(
          width: points.width,
          height: points.height,
          points: points.matrix.flatMap { $0 }.map(\.position),
          colors: points.matrix.flatMap { $0 }.map(\.color)
        )
      }
    }

    var body: some View {
      NavigationView {
        VStack {
          ZStack {

            gradient
              .measureSize($gradientSize)
              .clipShape(RoundedRectangle(cornerRadius: 16))
              .background(
                gradient
                  .measureSize($gradientSize)
                  .saturation(0.8)
                  .brightness(0.2)
                  .blur(radius: 30)
              )

            /// control points
            ForEach(0..<points.height, id: \.self) { h in
              ForEach(0..<points.width, id: \.self) { w in

                switch points {
                case .bezierPoints(let points):

                  let p = Coordinate(x: h, y: w)

                  Self.handlesForBezierPoint(
                    point: .init(
                      get: {
                        points.matrix[h][w]
                      },
                      set: { newPoint in
                        var newPoints = points
                        newPoints.matrix[h][w] = newPoint
                        self.points = .bezierPoints(newPoints)
                      }
                    ),
                    size: gradientSize,
                    isActive: focusingPoint == p,
                    onSelect: {
                      print("selecting \(p)")
                      focusingPoint = p
                    }
                  )

                case .points(let points):

                  Self.handlesForPoint(
                    point: .init(
                      get: {
                        return points.matrix[h][w]
                      },
                      set: { newPoint in
                        var newPoints = points
                        newPoints.matrix[h][w] = newPoint
                        self.points = .points(newPoints)
                      }
                    ), 
                    size: gradientSize,
                    onSelect: {
                      print("selecting \(h) \(w)")
                      focusingPoint = .init(x: h, y: w)
                    }
                  )

                }

              }
            }

          }
          .coordinateSpace(.named("container"))
          .padding(20)

          VStack {

            rowStepper

            columnStepper

            switch points {
            case .bezierPoints(let points):

              if let focusingPoint {
                ColorPicker(
                  selection: .init(
                    get: {
                      points.matrix[focusingPoint.x][focusingPoint.y].color
                    },
                    set: { newColor in

                      var newPoints = points
                      newPoints.matrix[focusingPoint.x][focusingPoint.y].color = newColor

                      self.points = .bezierPoints(
                        newPoints
                      )

                    }
                  ),
                  supportsOpacity: true,
                  label: {
                    EmptyView()
                  }
                )
              } else {
                ColorPicker(
                  selection: .constant(.clear),
                  supportsOpacity: true,
                  label: {
                    EmptyView()
                  }
                )
                .disabled(true)
              }

            case .points(let points):

              if let focusingPoint {
                ColorPicker(
                  selection: .init(
                    get: {
                      points.matrix[focusingPoint.x][focusingPoint.y].color
                    },
                    set: { newColor in

                      var newPoints = points
                      newPoints.matrix[focusingPoint.x][focusingPoint.y].color = newColor

                      self.points = .points(
                        newPoints
                      )

                    }
                  ),
                  supportsOpacity: true,
                  label: {
                    EmptyView()
                  }
                )
              } else {
                ColorPicker(
                  selection: .constant(.clear),
                  supportsOpacity: true,
                  label: {
                    EmptyView()
                  }
                )
                .disabled(true)
              }

            }
          }
          .padding()
          .background(RoundedRectangle(cornerRadius: 16).fill(.background.secondary))
          .padding(.horizontal)

        }
      }
    }

    private static func handlesForPoint(
      point: Binding<BookMeshGradientBezierPoints.ContentView.ControlPoint>,
      size: CGSize,
      onSelect: @escaping @MainActor () -> Void
    ) -> some View {
      PointHandle(color: point.wrappedValue.color, onTap: onSelect)
        .position(
          x: CGFloat(point.wrappedValue.position.x) * size.width,
          y: CGFloat(point.wrappedValue.position.y) * size.height
        )
        .simultaneousGesture(
          DragGesture(
            minimumDistance: 10,
            coordinateSpace: .named("container")
          )
          .onChanged { value in
            
            let positionX = max(0, min(1, value.location.x / size.width))
            let positionY = max(0, min(1, value.location.y / size.height))
            
            withAnimation(.snappy) {
              
              point.position.wrappedValue = .init(Float(positionX), Float(positionY))
              
            }
            
          }
        )
    }

    private static func handlesForBezierPoint(
      point: Binding<BookMeshGradientBezierPoints.ContentView.BezierControlPoint>,
      size: CGSize,
      isActive: Bool,
      onSelect: @escaping @MainActor () -> Void
    ) -> some View {

      func makeDraggalbe<V: View>(view: V, binding: Binding<SIMD2<Float>>) -> some View {

        let position = binding.wrappedValue

        return
          view
          .position(
            x: CGFloat(position.x) * size.width,
            y: CGFloat(position.y) * size.height
          )
          .simultaneousGesture(
            DragGesture(
              minimumDistance: 10,
              coordinateSpace: .named("container")
            )
            .onChanged { value in

              let positionX = max(0, min(1, value.location.x / size.width))
              let positionY = max(0, min(1, value.location.y / size.height))

              withAnimation(.snappy) {

                binding.wrappedValue = .init(Float(positionX), Float(positionY))

              }

            }
          )
      }

      return Group {
        makeDraggalbe(
          view: BezierPositionHandle(
            color: point.wrappedValue.color,
            onTap: {
              onSelect()
            }
          ),
          binding: point.point.position
        )

        if isActive {
          Group {
            makeDraggalbe(
              view: BezierHandle().tint(.blue),
              binding: point.point.leadingControlPoint
            )

            makeDraggalbe(
              view: BezierHandle(),
              binding: point.point.topControlPoint
            )

            makeDraggalbe(
              view: BezierHandle(),
              binding: point.point.bottomControlPoint
            )

            makeDraggalbe(
              view: BezierHandle().tint(.blue),
              binding: point.point.trailingControlPoint
            )
          }
          .zIndex(1)
          //          .transition(.scale.animation(.spring))
        }

      }
    }

    private var rowStepper: some View {
      Stepper(
        "W",
        onIncrement: {

          points = points.addHorizonal()

        },
        onDecrement: {

          points = points.removeHorizontal()

        }
      )
    }

    private var columnStepper: some View {
      Stepper(
        "H",
        onIncrement: {

          points = points.addVertical()

        },
        onDecrement: {

          points = points.removeVertical()

        }
      )

    }
  }

  private struct BezierPositionHandle: View {

    private let onTap: @MainActor () -> Void
    private let color: Color

    init(
      color: Color,
      onTap: @escaping @MainActor () -> Void
    ) {
      self.color = color
      self.onTap = onTap
    }

    var body: some View {
      Button {
        onTap()
      } label: {

        Circle()
          .fill(color)
          .frame(width: 20, height: 20)
          .overlay(
            Circle()
              .stroke(.background, lineWidth: 8)
          )
          .padding(4)

      }

    }
  }

  private struct BezierHandle: View {

    init() {
    }

    var body: some View {

      Circle()
        .fill(.background)
        .frame(width: 10, height: 10)
        .overlay(
          Circle()
            .stroke(.pink, lineWidth: 3)
        )
        .padding(4)

    }
  }

  private struct PointHandle: View {

    private let onTap: @MainActor () -> Void
    private let color: Color

    init(
      color: Color,
      onTap: @escaping @MainActor () -> Void
    ) {
      self.color = color
      self.onTap = onTap
    }

    var body: some View {
      Button {
        onTap()
      } label: {

        Circle()
          .fill(color)
          .frame(width: 20, height: 20)
          .overlay(
            Circle()
              .stroke(.background, lineWidth: 8)
          )
          .padding(4)

      }

    }
  }
}
