import java.util.List;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.MultiPolygon;
import com.vividsolutions.jts.geom.Polygon;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.Envelope;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.index.strtree.STRtree;

import com.vividsolutions.jts.geom.GeometryFactory;

float[] getBounds(List<Feature> feats){
  float[] ret = new float[4];
  float xmin = Float.POSITIVE_INFINITY;
  float xmax = Float.NEGATIVE_INFINITY;
  float ymin = Float.POSITIVE_INFINITY;
  float ymax = Float.NEGATIVE_INFINITY;
  
  for(Feature feat : feats){
    Geometry geom = (Geometry)feat.getDefaultGeometryProperty().getValue();
    Envelope env = geom.getEnvelopeInternal();
    xmin = min(xmin, Double.valueOf(env.getMinX()).floatValue());
    xmax = max(xmax, Double.valueOf(env.getMaxX()).floatValue());
    ymin = min(ymin, Double.valueOf(env.getMinY()).floatValue());
    ymax = max(ymax, Double.valueOf(env.getMaxY()).floatValue());
  }
  
  ret[0] = xmin;
  ret[1] = ymin;
  ret[2] = xmax;
  ret[3] = ymax;
  return ret;
}

List<Feature> feats;
Grid grid;

// color ramp endpoints
color from,to;

// resampling grid parameters
int nrows=10;
int ncols=20;
float centerlat = 42.367631;
float centerlon = -71.099356;
float cellwidth = 30.0;
float theta = radians(30);

// data-to-screen scaling variables;
float[] bounds;
float objx;
float objy;
float yscale;
float xscale;

// grid of resampled data
float[][] resampled;

STRtree index;

String shapefile_filename = "subset.shp";
String property_name = "POP10";

void setup(){
  size(1000,800);
  
  String filename = dataPath(shapefile_filename);

  // read the entire shapefile
  print( "begin reading..." );
  feats = getFeatures( filename, 1000000 );
  println( "done" );
  println( "read "+feats.size()+" features" );
  println( "first feature: "+feats.get(0) );
  
  println("indexing...");
  index = new STRtree();
  for(Feature feat : feats){
    Geometry geom = (Geometry) feat.getDefaultGeometryProperty().getValue();
    Envelope env = geom.getEnvelopeInternal();
    index.insert( env, feat );
  }
  println("done");
  
  setScale();
  
  makeGridAndResample(true);

  strokeWeight(0.000003);
  smooth();
  
  from = color(204, 102, 0);
  to = color(0, 102, 153);
  
}

void setScale(){
    // get the bounding box of the shapefile
    bounds = getBounds(feats);
  
    float ll = bounds[0];
    float bb = bounds[1];
    float rr = bounds[2];
    float tt = bounds[3];

    objx = (rr+ll)/2;
    objy = (tt+bb)/2;

    yscale=height/(tt-bb);
    xscale=width/(rr-ll);
}

void makeGridAndResample(boolean resample){
  // get grid
  try{
    grid = new Grid(centerlat, centerlon, cellwidth, ncols, nrows, theta );
  } catch(Exception ex){
    grid = null;
  }
  
  if(resample){
    resampled = grid.resample(index, property_name);
  }
  
}

void drawPolygons(){
  noStroke();
  
  for(Feature feat : feats ){
    MultiPolygon geom = (MultiPolygon) feat.getDefaultGeometryProperty().getValue();
    int ind = (Integer)feat.getProperty("POP10").getValue();
    float density = ind/(float)geom.getArea();
    
    fill( lerpColor(from,to,density/300000000.0) );
    
    for(int i=0; i<geom.getNumGeometries(); i++){
      Geometry subgeom = geom.getGeometryN(i);
      Coordinate[] coords = subgeom.getCoordinates();
      beginShape();
      for(Coordinate coord : coords){
        vertex((float)coord.x,(float)coord.y);
      }
      endShape(CLOSE);
    }
  }
}

void drawGrid(){
  stroke(0);
  strokeWeight(0.00001);
  noFill();
  for(int y=0; y<nrows; y++){
    for(int x=0; x<ncols; x++){
      Polygon cell = grid.getCell(x,y);
      
      if(resampled != null){
        float ind = resampled[y][x];
        float density = ind/(float)cell.getArea();
        fill( lerpColor(from,to,density/300000000.0) );
      }
      
      Coordinate[] coords = cell.getCoordinates();
      beginShape();
      for(Coordinate coord : coords){
        vertex((float)coord.x,(float)coord.y);
      }
      endShape(CLOSE);
    }
  }
}

void scaleToBounds(){
  translate(width/2,height/2);
  scale(xscale,-yscale);
  translate(-objx,-objy);
}

void mousePressed(){
  float x = mouseX;
  float y = mouseY;
  
  x -= width/2;
  y -= height/2;
  
  x /= xscale;
  y /= -yscale;
  
  x += objx;
  y += objy;
  
  centerlon = x;
  centerlat = y;
  
  makeGridAndResample(true);
  loop();
}

void draw(){
  background(255);

  scaleToBounds();
  
  drawPolygons();
  drawGrid();
  
  noLoop(); //loop once through and stop
}

void keyPressed(){
  if(key=='w'){
    nrows += 1;
    makeGridAndResample(true);
    loop();
  } else if(key=='s'){
    nrows -= 1;
    makeGridAndResample(true);
    loop();
  }else if(key=='d'){
    ncols += 1;
    makeGridAndResample(true);
    loop();
  }else if(key=='a'){
    ncols -= 1;
    makeGridAndResample(true);
    loop();
  }
  else if(key=='e'){
    theta -= PI/32;
    makeGridAndResample(true);
    loop();
  }
  else if(key=='q'){
    theta += PI/32;
    makeGridAndResample(true);
    loop();
  }
  else if(key=='+'){
    cellwidth *= 1.1;
    makeGridAndResample(true);
    loop();
  }
  else if(key=='-'){
    cellwidth /= 1.1;
    makeGridAndResample(true);
    loop();
  }
}
