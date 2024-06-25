
import SwiftUI
import SwiftUISupport

struct BookMeshGradient: View, PreviewProvider {
  var body: some View {
    ContentView()
  }
  
  static var previews: some View {
    Self()
  }
  
  private struct ContentView: View {
    
    struct ControlPoint: Equatable {
      
      struct Representation: Codable {
        
        var positionX: Float
        var positionY: Float
        var color: Color.Resolved
        
        init(from controlPoint: ControlPoint) {
          positionX = controlPoint.position.x
          positionY = controlPoint.position.y
          
          let color = controlPoint.color.resolve(in: .init())
          
          self.color = color
        }
        
        var controlPoint: ControlPoint {
          .init(
            position: .init(positionX, positionY),
            color: Color(cgColor: color.cgColor)
          )
        }
      }
      
      var position: SIMD2<Float>
      var color: Color
      
    }
    
    @State var gradientSize: CGSize = .zero
    
    @State var focusingPoint: (x: Int, y: Int)?
    
    @State var pickingColor: Color?
    
    /// 2D row and column
    @State private var matrix: [[ControlPoint]] = [
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
    ]
    
    private var flattenedPoints: [ControlPoint] {
      matrix.flatMap { $0 }
    }
    
    private var width: Int {
      matrix.first?.count ?? 0
    }
    
    private var height: Int {
      matrix.count
    }
    
    var body: some View {
      NavigationView {
        VStack {
          ZStack {
                        
            MeshGradient(
              width: width,
              height: height,
              points: flattenedPoints.map(\.position),
              colors: flattenedPoints.map(\.color)
            )
            .measureSize($gradientSize)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(
              MeshGradient(
                width: width,
                height: height,
                points: flattenedPoints.map(\.position),
                colors: flattenedPoints.map(\.color)
              )
              .measureSize($gradientSize)
              .saturation(0.8)
              .brightness(0.2)
              .blur(radius: 30)
            )
            
            /// control points
            ForEach(0..<height, id: \.self) { h in
              ForEach(0..<width, id: \.self) { w in
                
                let point = matrix[h][w]
                
                Handle(
                  color: point.color,
                  onTap: {
                    focusingPoint = (h, w)
                    
                  }
                )
                .position(
                  x: CGFloat(point.position.x) * gradientSize.width,
                  y: CGFloat(point.position.y) * gradientSize.height
                )
                .simultaneousGesture(
                  DragGesture(
                    minimumDistance: 10,
                    coordinateSpace: .named("container")
                  )
                  .onChanged { value in
                    
                    focusingPoint = (h, w)
                    
                    let positionX = max(0, min(1, value.location.x / gradientSize.width))
                    let positionY = max(0, min(1, value.location.y / gradientSize.height))
                    
                    withAnimation(.snappy) {
                      
                      matrix[h][w].position.x = Float(positionX)
                      matrix[h][w].position.y = Float(positionY)
                      
                    }
                    
                    print(positionX)
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
                selection: $matrix[focusingPoint.x][focusingPoint.y].color,
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
          .onChange(of: matrix) { oldValue, newValue in
            
          }
          
        }
        .toolbar {
          Button("Export") {
            
            let rep = matrix.map {
              $0.map {
                ControlPoint.Representation(from: $0)
              }
            }        
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try! encoder.encode(rep)
            let string = String(data: data, encoding: .utf8)!
            print(string)
            
          }
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
        },
        onDecrement: {
          
          guard width > 2 else {
            return
          }
          
          focusingPoint = nil
          
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
          
        },
        onDecrement: {
          
          guard height > 2 else {
            return
          }
          
          focusingPoint = nil
          
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
          
        }
      )
      
    }
  }
  
  private struct Handle: View {
    
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
