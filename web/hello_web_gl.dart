import 'dart:html';
import 'dart:web_gl';

void main() {
  
  CanvasElement canvas = querySelector('#canvas');
  RenderingContext gl = canvas.getContext3d();
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  gl.clear(COLOR_BUFFER_BIT);

}
