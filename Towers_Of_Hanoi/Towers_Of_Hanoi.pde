void setup() { //<>// //<>// //<>// //<>// //<>//
  size(600, 600);
  populateArray();
  textSize(32);
}
PVector currentTranslation = new PVector(0, 0);
PVector[] Discs[] = new PVector[4][4];
int[][] ColorDiscs = {
  {102, 255, 51}, 
  {0, 255, 255}, 
  {255, 255, 0}, 
  {255, 124, 242}
};
int[][] Stacks = {
  {4, 3, 2, 1, 0}, 
  {0, 0, 0, 0, 0}, 
  {0, 3, 2, 1, 0}
};
PVector[] LocationOfDiscs = new PVector[4];
int PrevMouseX;
int PrevMouseY;
boolean MouseDown;
boolean EnRoute;
int[] EnRoutePole = {0, 0, 0};
int newPoleNum = -1;
int MoveCounter;
boolean Won;
void draw() {

  // iTranslate(0,0);
  background(0);
  stroke(255);
  strokeWeight(10);
  checkWon();
  if (Won) {
    wonScreen();
  } else {
    drawPoles();
    drawAll();
    drawText();
  }
  // println(frameRate);
}

void wonScreen() {
  textSize(100);
  textAlign(CENTER, CENTER);
  text("You Won in", width/2, height/4);
  text(MoveCounter + " Moves" , width/2, height/2);
}

void checkWon() {
  if (Stacks[2][0] == Discs.length) {
    Won = true;
  }
}

void drawText() {

  fill(255);
  text("Moves: " + MoveCounter, 0, 30);
}


void drawPoles() {
  for (float s = 0; s<Discs.length-1; s++) {
    line(width*((s+1)/Discs.length), height, width*((s+1)/Discs.length), height * 0.25);
  }
}

void drawAll() {
  for (int a =0; a<Discs.length-1; a++) {
    for (int b = 1; b<Stacks[a][0] + 1; b++) {
      if (b==Stacks[a][0]) {
        drawRing(Stacks[a][b], LocationOfDiscs[a], b -1, true, a);
      } else {
        drawRing(Stacks[a][b], LocationOfDiscs[a], b-1, false, a);
      }
    }
  }
}

void drawRing(int Index, PVector pTran, int yOffset, boolean topOfStack, int PoleNum) {
  int[] ColorOfRing = ColorDiscs[Index];
  pushMatrix();
  strokeWeight(2);
  stroke(ColorOfRing[0], ColorOfRing[1], ColorOfRing[2]);
  iTranslate(pTran.x, pTran.y-(yOffset*50));
  fill(0);
  if ((EnRoute  && topOfStack &&EnRoutePole[PoleNum] == 1 ) || (containsPoint(Discs[Index], mouseX, mouseY, true) && topOfStack) ) {
    fill(255, 0, 0, 150);
    if (mousePressed) {
      popMatrix();
      pushMatrix();
      iTranslate(mouseX, mouseY);
      for (int s = 0; s < Discs.length-1; s++) {

        if ( (containsPoint(Discs[Index], LocationOfDiscs[s].x, mouseY, false)) && s != PoleNum && checkLegal(Index, s)) {
          fill(0, 255, 0, 150);
          popMatrix();
          pushMatrix();
          iTranslate(LocationOfDiscs[s].x, LocationOfDiscs[s].y-(Stacks[s][0] * 50));
          newPoleNum = s;
          break;
        } else {
          newPoleNum = -1;
        }
      }
      EnRoute = true;
      EnRoutePole[PoleNum] = 1;
    } else { 
      EnRoute = false;
      EnRoutePole[PoleNum] = 0;
      if (newPoleNum> -1 ) {
        popMatrix();
        pushMatrix();
        iTranslate(LocationOfDiscs[newPoleNum].x, LocationOfDiscs[newPoleNum].y-(Stacks[newPoleNum][0] * 50));
        moveDisc(PoleNum, newPoleNum, Index);
      }
    }
  }


  beginShape();
  for (PVector v : Discs[Index]) {
    vertex(v.x, v.y);
  }
  endShape(CLOSE);
  popMatrix();
}


boolean checkLegal(int discIndex, int poleIndex) {
  if (discIndex <= Stacks[poleIndex][Stacks[poleIndex][0]] || Stacks[poleIndex][0] == 0 ) {
    return true;
  } else {
    return false;
  }
}

void moveDisc(int oldPole, int newPole, int discIndex) {
  MoveCounter += 1;
  Stacks[oldPole][0]-= 1;
  Stacks[newPole][0]+= 1;
  Stacks[newPole][Stacks[newPole][0]] = discIndex;
  newPoleNum = -1;
}



void populateArray() {
  for (int i = 0; i < Discs.length; i++) {
    PVector[] verts = new PVector[4];

    verts[0] = new PVector(-(i+1)*20, 0);
    verts[1] = new PVector(-(i+1)*20, -50);
    verts[2] = new PVector((i+1)*20, -50);
    verts[3] = new PVector((i+1)*20, 0);
    Discs[i] = verts;
  }

  for (float i =0; i<Discs.length-1; i++) {
    LocationOfDiscs[int(i)] = new PVector(width*((i+1)/Discs.length), height);
  }
}

void iTranslate(float ix, float iy) {
  // print(currentTranslation.y * -1);
  //translate(-1 *currentTranslation.x,currentTranslation.y * -1);
  currentTranslation = new PVector(ix, iy);
  translate(ix, iy);
}


boolean containsPoint(PVector[] verts, float px, float py, boolean Skipable) {
  if (EnRoute && Skipable) {
    return false;
  }
  PVector[] tempVert = verts;
  int num = verts.length;
  int i, j = num - 1;
  boolean oddNodes = false;
  for (i = 0; i < num; i++) {
    PVector vi = tempVert[i];
    vi.x+= currentTranslation.x;
    vi.y+= currentTranslation.y;
    PVector vj = tempVert[j];
    vj.x+= currentTranslation.x;
    vj.y+= currentTranslation.y;
    if (vi.y < py && vj.y >= py || vj.y < py && vi.y >= py) {
      if (vi.x + (py - vi.y) / (vj.y - vi.y) * (vj.x - vi.x) < px) {
        oddNodes = !oddNodes;
      }
    }
    j = i;
    vi.x-= currentTranslation.x;
    vi.y-= currentTranslation.y;
    vj.x-= currentTranslation.x;
    vj.y-= currentTranslation.y;
  }

  return oddNodes;
}
