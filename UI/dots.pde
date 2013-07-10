ArrayList<Dot> dots;

void drawDots()
{
  for(int i = 0; i < dots.size(); i++) {
    Dot dot = dots.get(i);
    if(dot.alpha < 1) {
      dots.remove(i);
    } else {
      dot.drawSelf();
      if(millis() - dot.last_fade > 100) {
        // 10 fades per second
        dot.fade();
      }
    }
  }
}

class Dot {
  float cm;
  float angle;
  float alpha;
  float dotRadius;
  long last_fade;
  
  Dot(float dist, float ang) {
    cm = dist;
    angle = ang;
    alpha = 255;
    dotRadius = width / 64;
    last_fade = 0;
  }
  
  void drawSelf() {
    noStroke();
    fill(36, 221, 0, alpha);
    float px = (cm / outerLimit) * radius; // number of pixels from the center of the circle
    ellipse(width / 4 + px * cos(radians(angle)), height / 2 + px * sin(radians(angle)), dotRadius, dotRadius);
  }
  
  void fade() {
    alpha *= 9.0/10.0;
    last_fade = millis();
  }
}
    
