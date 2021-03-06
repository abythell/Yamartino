/*==============================================================================
 
 Copyright (c) 2010-2013 Christopher Baker <http://christopherbaker.net>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 ==============================================================================*/

int historyLength = 100;

float xoff = 0.0;

float stdevThresh = 1;

float[] history = new float[historyLength]; // keep our history values
float historyStd = 0;

float[] historyX = new float[historyLength];
float[] historyY = new float[historyLength];
float historyCorrectStd = 0;

float averageAngle = 0;
float yamartinoAverageAngle = 0;

float currentAngle = 0;

float circleRadius = 110;

PFont font;

boolean inTheZone = false;

void setup() {
  size(300, 300);
  smooth();
  background(0);

  font = createFont("", 14);
  textFont(font);
}

void draw() {
  background(0);

  xoff = xoff + .01;
  
  float myNoise = map(noise(xoff),0,1,-5,5);
  
  currentAngle = myAtan2(mouseY-height/2, mouseX-width/2) + radians(myNoise); 
  addItemsToHistoryBuffers(currentAngle);

  calculateMathematicalAverageOfHistory();
  calculateYamartinoAverageOfHistory();  

  pushMatrix();
  translate(width/2, height/2);

  noFill();
  stroke(255);
  ellipse(0, 0, 2*circleRadius, 2*circleRadius);

  noStroke();
  fill(color(0, 255, 0, 100));
  arc(0,0,2*circleRadius*0.6, 2*circleRadius*0.6,
                      averageAngle-historyStd*stdevThresh,
                      averageAngle+historyStd*stdevThresh);

  fill(color(255, 255, 0, 100));
  arc(0,0,2*circleRadius, 2*circleRadius,
                        yamartinoAverageAngle-historyCorrectStd,
                        yamartinoAverageAngle+historyCorrectStd);
    
  stroke(255);
  line(0, 0, circleRadius, 0);
  fill(255);
  text("N", circleRadius + 10, 0);

  drawHand(currentAngle, 4, circleRadius, color(255, 0, 0, 180));
  drawHand(averageAngle, 4, circleRadius*0.6, color(0, 255, 0, 180));
  drawHand(yamartinoAverageAngle, 4, circleRadius, color(255, 255, 0, 180));

  popMatrix();

  // legend

  pushMatrix();
  translate(10, height-50);
  drawLegend(0, "Current:", currentAngle, color(255, 0, 0, 180));
  drawLegend(12, "Average:", averageAngle, color(0, 255, 0, 180));
  drawLegend(24, "Yamartino Average:", yamartinoAverageAngle, color(255, 255, 0, 180));
  popMatrix();
}

float myAtan2(float y, float x) {
  float t = atan2(y, x);
  return t > 0 ? t : 2 * PI + t;
}

void drawLegend(float yOffset, String title, float angle, color c) {
  stroke(c);
  fill(c, 0.75*alpha(c));
  pushMatrix();
  translate(0, yOffset);
  rect(0, 0, 10, 10);

  fill(255);
  textFont(font, 12);
  text(title + " " + degrees(angle), 13, 10);
  popMatrix();
}

void drawHand(float angle, float w, float l, color c) {
  pushMatrix();
  rotate(angle);

  beginShape();
  stroke(c);
  fill(c, 0.75*alpha(c));
  vertex(0, -w/2);
  vertex(l, 0);
  vertex(0, w/2);
  endShape(CLOSE);

  popMatrix();
}
void calculateMathematicalAverageOfHistory() {
    float sum = 0;
    float sq_sum = 0;
    for(int i = 0; i < history.length; ++i) {
       sum += history[i];
       sq_sum += history[i] * history[i];
    }
    
    averageAngle = sum / history.length;
    float variance = sq_sum / history.length - averageAngle * averageAngle;
    historyStd = sqrt(variance);
}

void calculateYamartinoAverageOfHistory() {

  float sumX = 0;
  float sumY = 0;
  
  for (int i = 0; i < history.length; i++) {
    sumX += historyX[i];
    sumY += historyY[i];
  }

  float meanX = sumX / history.length;
  float meanY = sumY / history.length;
  // YAMARTINO METHOD FOR STANDARD DEVIATION!!
  // http://en.wikipedia.org/wiki/Yamartino_method
  float eps = sqrt(1 - (meanX*meanX + meanY*meanY));
  eps = Float.isNaN(eps) ? 0 : eps; // correct for NANs
  historyCorrectStd = asin(eps)* (1 + (2 / sqrt(3) - 1) * (eps * eps * eps));
  
  yamartinoAverageAngle = myAtan2(sumY, sumX);
}

void addItemsToHistoryBuffers(float input) {
  addToHistory(history,input);
  addToHistory(historyX,cos(input));
  addToHistory(historyY,sin(input));
}

void addToHistory(float[] buffer, float input) {
  // delete the oldest value from the history
  // add one value to the history (the input)
  // take the average of the history and return it;

  // shift the values to the left in the array
  for (int i = buffer.length - 1; i >= 0; i--) {
    if (i == 0) {
      buffer[0] = input;
    } 
    else {
      buffer[i] = buffer[i-1];
    }
  }
}



