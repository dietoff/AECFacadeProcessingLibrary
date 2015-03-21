import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Vector;
AEC aec;
PFont font1;

// some parameters that turned out to work best for the font we're using
float FONT_SIZE = 6;
float FONT_OFFSET_Y = 0.12;
float FONT_SCALE_X = 2.669;
float FONT_SCALE_Y = 2.67;
  Table table;
String stringWithSpecialCharacters = "Von der Auffahrt zur Margarethenkirche bis zur Ortstafel";
  private HashMap<Integer, Pixel> idmap;
  private HashMap<Integer, Pixel> xymap;
  private HashMap<Integer, ArrayList<Pixel>> xmap;
  private HashMap<Integer, ArrayList<Pixel>> ymap;
  
void setup() {
  frameRate(25);
  size(1200, 400);
  readTopology();
  randomize();
    
  // NOTE: This font needs to be in the data folder.
  // and it's available for free at http://www.dafont.com
  // You COULD use a different font, but you'd have to tune the above parameters. Monospaced bitmap fonts work best.
  font1 = createFont("wendy.ttf", 9, false);
 // font1 = createFont("CourierNewPSMT", 9, false, charactersToInclude);
 // font1 = loadFont("CourierNewPS-BoldMT-20.vlw");
  
  aec = new AEC();
  aec.init();
  frameRate(30);
}

  private void randomize() {
    for (Pixel p:idmap.values()) {
      float random = random(0,1);
      if (random > 0.5) p.on = true; else p.on = false;
    }
  }

  private void readTopology() {
    table = loadTable("window2mask.csv", "header");
    idmap = new HashMap<Integer, Pixel>();
    xymap = new HashMap<Integer, Pixel>();
    xmap = new HashMap<Integer, ArrayList<Pixel>>();
    ymap = new HashMap<Integer, ArrayList<Pixel>>();
    int minx = Integer.MAX_VALUE;
    int maxx = Integer.MIN_VALUE;
    int miny = Integer.MAX_VALUE;
    int maxy = Integer.MIN_VALUE;

    // read in text file
    for (TableRow row : table.rows()) {
      int id = row.getInt("window");
      int x = row.getInt("x");
      int y = row.getInt("y");

      if (x<minx) minx = x;
      if (x>maxx) maxx = x;
      if (y<miny) miny = y;
      if (y>maxy) maxy = y;

      int w = row.getInt("width");
      Pixel pix = new Pixel(id,x,y,w);

      if (!xmap.containsKey(x)) {
        ArrayList<Pixel> tmp = new ArrayList<Pixel>();
        tmp.add(pix);
        xmap.put(x, tmp);
      } else {
        xmap.get(x).add(pix);
      }

      if (!ymap.containsKey(y)) {
        ArrayList<Pixel> tmp = new ArrayList<Pixel>();
        tmp.add(pix);
        ymap.put(y, tmp);
      } else {
        ymap.get(y).add(pix);
      }
      idmap.put(id, pix);
      xymap.put(combine(x, y), pix);
    }

    // calculate neighbors
    for (int x=minx;x<maxx+1;x++) {
      for (int y=miny;y<maxy+1;y++) {
        Pixel pixel = xymap.get(combine(x,y));
        if (pixel!=null) {

          Integer top =  combine(x,y-1);
          Integer bot =  combine(x,y+1);
          Integer lef =  combine(x-1,y);
          Integer rig =  combine(x+1,y);

          if (xymap.containsKey(top)) {
            Pixel px = xymap.get(top);
            pixel.addNeighbor("top", px);
          }
          if (xymap.containsKey(bot)) {
            Pixel px = xymap.get(bot);
            pixel.addNeighbor("bottom", px);
          }
          if (xymap.containsKey(lef)) {
            Pixel px = xymap.get(lef);
            pixel.addNeighbor("left", px);
          }
          if (xymap.containsKey(rig)) {
            Pixel px = xymap.get(rig);
            pixel.addNeighbor("right", px);
          }
        }
      }
    }

    HashMap<String, Pixel> neighbors2 = idmap.get(2).getNeighbors();
    HashMap<String, Pixel> neighbors = idmap.get(11).getNeighbors();
    HashMap<String, Pixel> neighbors3 = idmap.get(11).getNeighbors();

  }

  private int combine(int x, int y) {
    return x|(y<<8);
  }

void draw() {
  if (frameCount%300==0) randomize();
  aec.beginDraw();
  background(0,0,0);
  noStroke();
  
  fill(255,0,100);
  
  // determines the speed (number of frames between text movements)
  int frameInterval = 3;
  
  // min and max grid positions at which the text origin should be. we scroll from max (+40) to min (-80)
  int minPos = -150;
  int maxPos = 50;
  int loopFrames = (maxPos-minPos) * frameInterval;
  
  // vertical grid pos
  int yPos = 15;
  
  displayText(max(minPos, maxPos - (frameCount%loopFrames) / frameInterval), yPos);
    
    moveUp();
  aec.endDraw();
  aec.drawSides();
}
  private void moveUp() {
    Collection<Pixel> values = idmap.values();
    ArrayList<Pixel> a = new ArrayList<Pixel>();
    a.addAll(values);
    Collections.shuffle(a);
  
    
    for (int i = 0; i< a.size()/10; i++ ) {
      Pixel p = a.get(i);
      if (p.on&&p.top!=null&&!p.top.on) {
        p.on=false;
        p.top.on=true;
      }
    }
  }
void displayText(int x, int y)
{
  // push & translate to the text origin
  pushMatrix();
  translate(x, y+FONT_OFFSET_Y);
  
  // scale the font up by fixed paramteres so it fits our grid
  scale(FONT_SCALE_X,FONT_SCALE_Y);
  textFont(font1);
  textSize(FONT_SIZE);
  
  // draw the font glyph by glyph, because the default kerning doesn't align with our grid
  for(int i = 0; i < stringWithSpecialCharacters.length(); i++)
  {
    text(stringWithSpecialCharacters.charAt(i), (float)i*3, 0);
  }
  
  popMatrix();
  
}

void keyPressed() {
  aec.keyPressed(key);
}
