import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

String vertexShaderSource = '''
attribute vec4 a_Position;
attribute vec4 a_Color;
uniform mat4 u_ProjMatrix;
varying vec4 v_Color;
void main() {
  gl_Position = u_ProjMatrix * a_Position;
  v_Color = a_Color;
}
''';

String fragmentShaderSource = '''
precision mediump float;
varying vec4 v_Color;
void main() {
  gl_FragColor = v_Color;
}
''';

void main() {
  
  CanvasElement canvas = querySelector('#canvas');
  RenderingContext gl = canvas.getContext3d();
  
  Shader vertexShader = gl.createShader(VERTEX_SHADER);
  gl.shaderSource(vertexShader, vertexShaderSource);
  gl.compileShader(vertexShader);
  
  Shader fragmentShader = gl.createShader(FRAGMENT_SHADER);
  gl.shaderSource(fragmentShader, fragmentShaderSource);
  gl.compileShader(fragmentShader);
  
  Program program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  gl.useProgram(program);
  
  var vertices = new Float32List.fromList([
    0.0,  0.6,  -0.3,  1.0,  0.0,  0.0, // red triangle
   -0.5, -0.4,  -0.3,  1.0,  0.0,  0.0,
    0.5, -0.4,  -0.3,  1.0,  0.0,  0.0, 

    0.5,  0.4,  -0.2,  0.0,  1.0,  0.0, // green triangle
   -0.5,  0.4,  -0.2,  0.0,  1.0,  0.0,
    0.0, -0.6,  -0.2,  0.0,  1.0,  0.0, 

    0.0,  0.5,  -0.1,  0.0,  0.0,  1.0, // blue triangle 
   -0.5, -0.5,  -0.1,  0.0,  0.0,  1.0,
    0.5, -0.5,  -0.1,  0.0,  0.0,  1.0, 
  ]);
  
  Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, vertices, STATIC_DRAW);
  
  int a_Position = gl.getAttribLocation(program, 'a_Position');
  gl.vertexAttribPointer(a_Position, 3, FLOAT, false, 
      vertices.elementSizeInBytes * 6, 0);
  gl.enableVertexAttribArray(a_Position);
  
  int a_Color = gl.getAttribLocation(program, 'a_Color');
  gl.vertexAttribPointer(a_Color, 3, FLOAT, false,
      vertices.elementSizeInBytes * 6, vertices.elementSizeInBytes * 3);
  gl.enableVertexAttribArray(a_Color);
  
  UniformLocation u_ProjMatrix = gl.getUniformLocation(program, 'u_ProjMatrix');
  
  num farPlane = 0.3;
  Function draw = () {

    Matrix4 orthoMatrix = makeOrthographicMatrix(-1.0, 1.0, -1.0, 1.0, 0.0, farPlane);
    gl.uniformMatrix4fv(u_ProjMatrix, false, orthoMatrix.storage);
    
    gl.clear(COLOR_BUFFER_BIT);
    gl.drawArrays(TRIANGLES, 0, vertices.length ~/ 6);
    
  };
  
  ButtonElement plusButton  = new ButtonElement()
    ..text = '+'
    ..disabled = true;
  ButtonElement minusButton = new ButtonElement()..text = '-';
  DivElement div = new DivElement();
  div.children.addAll([plusButton, minusButton]);
  document.body.children.add(div);
  
  plusButton.onClick.listen((_) {
      farPlane += 0.1;
      if(farPlane >= 0.3) {
        farPlane = 0.3;
        plusButton.disabled = true;
      }
      minusButton.disabled = false;
      draw();
    });
  
  minusButton.onClick.listen((_) {
    farPlane -= 0.1;
    if(farPlane <= 0.0) {
      farPlane = 0.0;
      minusButton.disabled = true;
    }
    plusButton.disabled = false;
    draw();
  });
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  draw();
}
