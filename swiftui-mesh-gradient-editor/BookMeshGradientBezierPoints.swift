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

    @State var pickingColor: Color?

    /// 2D row and column
    @State private var bezierMatrix: [[BezierControlPoint]] = [
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
    ]

    private var flattenedPoints: [BezierControlPoint] {
      bezierMatrix.flatMap { $0 }
    }

    private var width: Int {
      bezierMatrix.first?.count ?? 0
    }

    private var height: Int {
      bezierMatrix.count
    }

    var body: some View {
      NavigationView {
        VStack {
          ZStack {

            MeshGradient(
              width: width,
              height: height,
              locations: .bezierPoints(flattenedPoints.map(\.point)),
              colors: .colors(flattenedPoints.map(\.color))
            )
            .measureSize($gradientSize)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(
              MeshGradient(
                width: width,
                height: height,
                locations: .bezierPoints(flattenedPoints.map(\.point)),
                colors: .colors(flattenedPoints.map(\.color))
              )
              .measureSize($gradientSize)
              .saturation(0.8)
              .brightness(0.2)
              .blur(radius: 30)
            )

            /// control points
            ForEach(0..<height, id: \.self) { h in
              ForEach(0..<width, id: \.self) { w in

                let point = $bezierMatrix[h][w]

                let p = Coordinate(x: h, y: w)

                Self.handles(
                  point: point,
                  size: gradientSize,
                  isActive: focusingPoint == p,
                  onSelect: {
                    print("selecting \(p)")
                    focusingPoint = p
                  }
                )

              }
            }

          }
          .coordinateSpace(.named("container"))
          .padding(20)

          VStack {

            rowStepper

            columnStepper

            if let focusingPoint {
              ColorPicker(
                selection: $bezierMatrix[focusingPoint.x][focusingPoint.y].color,
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
          .padding()
          .background(RoundedRectangle(cornerRadius: 16).fill(.background.secondary))
          .padding(.horizontal)
          .onChange(of: bezierMatrix) { oldValue, newValue in

          }

        }
      }
    }

    private static func handles(
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

                binding.x.wrappedValue = Float(positionX)
                binding.y.wrappedValue = Float(positionY)

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

          // update position
          do {
            let coefficient = (1 - (1 / Float(width)))

            for column in bezierMatrix.indices {
              for row in bezierMatrix[column].indices {
                bezierMatrix[column][row].point.position.x *= coefficient
              }
            }
          }

          // apply
          do {
            let step = 1.0 / Float(height - 1)

            for column in bezierMatrix.indices {

              let newColor = bezierMatrix[column].last!.color

              let position = SIMD2<Float>.init(1, Float(column) * step)
              bezierMatrix[column].append(
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
        },
        onDecrement: {

          guard width > 2 else {
            return
          }

          focusingPoint = nil

          // apply
          do {
            for i in bezierMatrix.indices {
              bezierMatrix[i].removeLast()
            }
          }

          // update position
          do {
            let coefficient = (1 + (1 / Float(width - 1)))

            for column in bezierMatrix.indices {
              for row in bezierMatrix[column].indices {
                bezierMatrix[column][row].point.position.x *= coefficient
              }
            }

            for column in bezierMatrix.indices {
              bezierMatrix[column][width - 1].point.position.x = 1
            }
          }

        }
      )
    }

    private var columnStepper: some View {
      Stepper(
        "H",
        onIncrement: {

          // update position
          do {
            let coefficient = (1 - (1 / Float(height)))

            for column in bezierMatrix.indices {
              for row in bezierMatrix[column].indices {
                bezierMatrix[column][row].point.position.y *= coefficient
              }
            }

          }

          // apply
          do {
            let step = 1.0 / Float(width - 1)

            var row: [BezierControlPoint] = []

            for i in 0..<width {

              let newColor = bezierMatrix.last![i].color

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

            bezierMatrix.append(
              row
            )
          }

        },
        onDecrement: {

          guard height > 2 else {
            return
          }

          focusingPoint = nil

          // Apply
          do {

            bezierMatrix.removeLast()

          }

          // update position

          do {
            let coefficient = (1 + (1 / Float(height - 1)))

            for column in bezierMatrix.indices {
              for row in bezierMatrix[column].indices {
                bezierMatrix[column][row].point.position.y *= coefficient
              }
            }

            for row in bezierMatrix[height - 1].indices {
              bezierMatrix[height - 1][row].point.position.y = 1
            }
          }

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
}
