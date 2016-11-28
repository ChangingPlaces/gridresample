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
  
  println("Shapefile Extents: " + xmin, xmax, ymin, ymax);
  
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
float maxDensity;

// shapefile and resampling grid parameters
String friendly_name, shapefile_name, shapefile_filesuffix, shapefile_filename, property_name, property_type;
int nrows, ncols, iterations;
float centerlat, centerlon, cellwidth, theta;

void setMassData() {
  // MA Data Set
  friendly_name = "boston";
  shapefile_name = "subset";
  shapefile_filesuffix = ".shp";
  shapefile_filename = shapefile_name + shapefile_filesuffix;
  property_name = "POP10";
  property_type = "Int";
  iterations = 1;
  
  // resampling grid parameters
  nrows=30;
  ncols=30;
  centerlat = 42.367631;
  centerlon = -71.099356;
  cellwidth = 250.0;
  theta = radians(30);
}

void setColoradoData() {
  // CO Data Set
  friendly_name = "denver";
  shapefile_name = "tabblock_2010_08_pophu_reduced";
  property_name = "POP10";
  shapefile_filesuffix = ".shp";
  shapefile_filename = shapefile_name + shapefile_filesuffix;
  property_type = "Int";
  iterations = 1;

  // resampling grid parameters
  nrows=4*22;
  ncols=4*18;
  centerlat = 39.95;
  centerlon = -104.9903;
  cellwidth = 2000.0;
  theta = radians(0);
}

void setSanJoseData() {
  // CO Data Set
  friendly_name = "sanjose";
  shapefile_name = "tabblock2010_06_pophu_reduced";
  //property_name = "HOUSING10";
  property_name = "POP10";
  shapefile_filesuffix = ".shp";
  shapefile_filename = shapefile_name + shapefile_filesuffix;
  property_type = "Int";
  iterations = 1;

  // resampling grid parameters
  nrows=4*22;
  ncols=4*18;
  centerlat = 37.395237;
  centerlon = -121.979507;
  cellwidth = 2000.0;
  theta = radians(0);
}

void setSingaporeData() {
  // Singapore Data Set
  friendly_name = "singapore";
  shapefile_name = "singapore/ResPopWGS84";
  //shapefile_name = "singapore/JELandUse_WGS84";
  property_name = "POP";
  //property_name = "TEST";
  shapefile_filesuffix = ".shp";
  shapefile_filename = shapefile_name + shapefile_filesuffix;
  property_type = "Int";
  iterations = 1;

  // resampling grid parameters (Uses psuedo Mercator)
  
  // Decimal: 103.74234° lon, 1.33342° lat
  // Psuedo Mercator: 11548544.46 X; 148449.04 Y
  
  nrows=1*4*22;
  ncols=1*4*18;
  centerlat = 1.33342;
  centerlon = 103.74234;
  //cellwidth = 3000.0/(4*18);
  cellwidth = 20;
  theta = radians(0);
}  

void setKendallData() {
  // Kendall Data Set
  friendly_name = "kendall";
  shapefile_name = "Kendall_Commuter/Kendall_TravelMode_BOS";
  //shapefile_name = "Kendall_Commuter/Kendall_TravelTime";
  property_name = "MHD01_VD01";
  shapefile_filesuffix = ".shp";
  shapefile_filename = shapefile_name + shapefile_filesuffix;
  property_type = "String";
  iterations = 21;
  
  // resampling grid parameters
  nrows=4*12;
  ncols=4*12;
  centerlat = 42.36397;
  centerlon = -71.08396;
  cellwidth = 0.58 * 1609.34 / nrows; // 0.58 mi; 1609.34 m/mi
  theta = 1.443659698; // Radians
}  

// data-to-screen scaling variables;
float[] bounds;
float objx;
float objy;
float yscale;
float xscale;

// grid of resampled data
float[][] resampled;

STRtree index;


void setup(){
  size(1000,1000);
  
  setMassData();
  //setColoradoData();
  //setSanJoseData();
  //setSingaporeData();
  //setKendallData();
    
  for (int i=1; i<=iterations; i++) {
    
    if (iterations > 1) // Exceptional data reference for Kendall Data
      property_name = "MHD01_VD" + String.format("%02d", i);
    
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
  
  saveResample();
}

void saveResample() {
  
  // Init Table Object for data export
  Table resampledCSV = new Table();
  for (int i=0; i<nrows; i++) {
    resampledCSV.addRow();
  }
  for (int j=0; j<ncols; j++) {
    resampledCSV.addColumn();
  }
  
  float ind;
  Polygon cell;
  
  for(int y=0; y<nrows; y++){
    for(int x=0; x<ncols; x++){
      if(resampled != null){
        resampledCSV.setFloat(y,x,resampled[y][x]);
      } else {
        resampledCSV.setFloat(y,x,0);
      }
    }
  }
  
  saveTable(resampledCSV, "export/" + friendly_name + "_" + property_name + "_" + nrows + "_" + ncols + "_" + (int)cellwidth + ".csv");
}

void setMaxDensity() {
  maxDensity = Float.NEGATIVE_INFINITY;
  float ind, density;
  Polygon cell;
  
  // Determines max density of cell values
  for(int y=0; y<nrows; y++){
    for(int x=0; x<ncols; x++){
      cell = grid.getCell(x,y);
      ind = resampled[y][x];
      density = ind/(float)cell.getArea();
      maxDensity = max(maxDensity, density);
    }
  }
}

void drawPolygons(){
  noStroke();
  
  float ind, density;
  MultiPolygon geom;
  float totalValue = 0;
  
  for(Feature feat : feats ){
    geom = (MultiPolygon) feat.getDefaultGeometryProperty().getValue();
    println(feat.getProperty(property_name).getValue());
    ind = 0;
    if (property_type.equals("Int")) 
      ind = (Integer)feat.getProperty(property_name).getValue();
    else if (property_type.equals("String"))
      ind = Integer.parseInt((String)feat.getProperty(property_name).getValue());
    density = ind/(float)geom.getArea();
    totalValue += ind;
    
    // Density in units of value per degrees^2
    fill( lerpColor(from,to,density/maxDensity) );
    
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
  println("Total Polygon Values = " + totalValue + " " + property_name + " units.");
}

void drawGrid(){
  stroke(0);
  strokeWeight(0.00001);
  noFill();
  
  float maxValue = Float.NEGATIVE_INFINITY;
  float minValue = Float.POSITIVE_INFINITY;
  float totalValue = 0.0;
  
  float ind, density;
  Polygon cell;
  
  for(int y=0; y<nrows; y++){
    for(int x=0; x<ncols; x++){
      cell = grid.getCell(x,y);
      
      if(resampled != null){
        ind = resampled[y][x];
        density = ind/(float)cell.getArea();
        totalValue += ind;
        maxValue = max(maxValue, ind);
        minValue = min(minValue, ind);
        
        // value / deg^2
        fill( lerpColor(from,to,density/maxDensity) );
      }
      
      Coordinate[] coords = cell.getCoordinates();
      beginShape();
      for(Coordinate coord : coords){
        vertex((float)coord.x,(float)coord.y);
      }
      endShape(CLOSE);
    }
  }
  
  println("---");
  println("Max Cell Value      = " + maxValue + " " + property_name + " units.");
  println("Min Cell Value      = " + minValue + " " + property_name + " units.");
  println("Average Cell Value  = " + totalValue/(nrows*ncols) + " " + property_name + " units.");
  println("Total Cell Values   = " + totalValue + " " + property_name + " units.");
  println("Area of each Cell   = " + sq(cellwidth) + " square meters.");
  println("Total Area of Cells = " + nrows*ncols*sq(cellwidth) + " square meters.");
  println("Average Density     = " + totalValue/(nrows*ncols*sq(cellwidth)) + " " + property_name + " units per square meter.");
  
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
  
  println("lon: " + centerlon);
  println("lat: " + centerlat);
  
  makeGridAndResample(true);
  loop();
}

boolean drawGrid = true;

void draw(){
  background(255);

  scaleToBounds();
  
  setMaxDensity();
  drawPolygons();
  if (drawGrid) {
    drawGrid();
  }
  
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
  else if(key=='g'){
    if(drawGrid) {
     drawGrid = false;
    } else {
     drawGrid = true;
    }
    loop();
  }
}
