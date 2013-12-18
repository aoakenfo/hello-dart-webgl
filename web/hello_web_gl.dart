import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:math';

String vertexShaderSource = '''
attribute vec4 a_Position;
uniform mat4 u_ModelMatrix;
void main() {
  gl_Position = u_ModelMatrix * a_Position;
}
''';

String fragmentShaderSource = '''
precision mediump float;
uniform vec4 u_FragColor;
void main() {
  gl_FragColor = u_FragColor;
}
''';

var tick;
var animate = (num highResTime) => tick(highResTime);

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
    -0.5, -0.5,
     0.0,  0.5,
     0.5, -0.5
  ]);
  
  Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, vertices, STATIC_DRAW);
  
  int a_Position = gl.getAttribLocation(program, 'a_Position');
  gl.vertexAttribPointer(a_Position, 2, FLOAT, false, 0, 0);
  gl.enableVertexAttribArray(a_Position);
  
  UniformLocation u_ModelMatrix = gl.getUniformLocation(program, 'u_ModelMatrix');
  UniformLocation u_FragColor = gl.getUniformLocation(program, 'u_FragColor');
  gl.uniform4f(u_FragColor, 1.0, 0.0, 0.0, 1.0);
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);

  num radian = 0.0;
  num sinB = 0.0;
  num cosB = 0.0;
  var modelMatrix = new Float32List.fromList([
       1.0, 0.0, 0.0, 0.0,
       0.0, 1.0, 0.0, 0.0,
       0.0, 0.0, 1.0, 0.0,
       0.0, 0.0, 0.0, 1.0
  ]);
  
  num lastTime = 0.0;
  num angle = 0.0;
  num speed = 40.0;
  num direction = 1;
  
  ButtonElement leftButton = new ButtonElement();
  ButtonElement rightButton = new ButtonElement();
  ButtonElement plusButton = new ButtonElement();
  ButtonElement minusButton = new ButtonElement();
  DivElement div = new DivElement();
  
  div.children.add(leftButton);
  div.children.add(rightButton);
  div.children.add(plusButton);
  div.children.add(minusButton);
  document.body.children.insert(0, div);
  
  leftButton
    ..disabled = true
    ..text = 'left'
    ..onClick.listen((MouseEvent e) {
        direction *= -1;
        leftButton.disabled = true;
        rightButton.disabled = false;
    });

  rightButton
    ..text = 'right'
    ..onClick.listen((MouseEvent e) {
      direction *= -1;
      leftButton.disabled = false;
      rightButton.disabled = true;
    });
  
  plusButton
    ..text = '+'
    ..onClick.listen((MouseEvent e) {
      speed += 10;
      minusButton.disabled = false;
    });
  
  minusButton
    ..text = '-'
    ..onClick.listen((MouseEvent e) {
      speed -= 10;
      if(speed <= 0) {
        minusButton.disabled = true;  
      }
    });
  
  tick = (num highResTime) {
      
      window.requestAnimationFrame(animate);
      
      num elapsedTime = highResTime - lastTime;
      lastTime = highResTime;
      
      angle += direction * (speed * elapsedTime / 1000.0);
      angle %= 360.0;
      radian = PI * angle / 180.0;
      sinB = sin(radian);
      cosB = cos(radian);
      
      modelMatrix[0] =  cosB;
      modelMatrix[1] =  sinB;
      modelMatrix[4] = -sinB;
      modelMatrix[5] =  cosB;
      
      gl.uniformMatrix4fv(u_ModelMatrix, false, modelMatrix);
      gl.clear(COLOR_BUFFER_BIT);
      gl.drawArrays(TRIANGLES, 0, 3);
      
    };
    
    animate(0);
}
