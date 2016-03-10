import java.util.List;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.MultiPolygon;
import com.vividsolutions.jts.geom.Polygon;
import com.vividsolutions.jts.geom.Envelope;
import com.vividsolutions.jts.geom.GeometryFactory;

class Grid{
  List<Polygon> cells;
  int ncols;
  int nrows;
  
  Grid(float left, float bottom, float right, float top, int ncols, int nrows){
    this.nrows = nrows;
    this.ncols = ncols;
    
    float cellwidth = (right-left)/ncols;
    float cellheight = (top-bottom)/nrows;
    
    List<Polygon> cells = new ArrayList<Polygon>();
    GeometryFactory fact = new GeometryFactory();
    for(int i=0; i<ncols; i++){
      for(int j=0; j<nrows; j++){
        // create coordinates of corners
        Coordinate[] coords = new Coordinate[5];
        coords[0] = new Coordinate(left+i*cellwidth,bottom+j*cellheight); //lower left
        coords[1] = new Coordinate(left+(i+1)*cellwidth,bottom+j*cellheight); //lower right
        coords[2] = new Coordinate(left+(i+1)*cellwidth,bottom+(j+1)*cellheight); //upper right
        coords[3] = new Coordinate(left+i*cellwidth,bottom+(j+1)*cellheight); //upper left
        coords[4] = new Coordinate(left+i*cellwidth,bottom+j*cellheight); //lower left
        
        // string them together into a geometry
        LinearRing linear = new GeometryFactory().createLinearRing(coords);
        Polygon poly = new Polygon(linear, null, fact);
        
        cells.add( poly );
      }
    }
    
    this.cells = cells;
  }
  
  String toString(){
    return "["+this.ncols+"x"+this.nrows+"]";
  }
}

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

float[] bounds;
List<Feature> feats;
Grid grid;

color from,to;

void setup(){
  size(700,400);
  
  String filename = dataPath("subset.shp");

  // read the entire shapefile
  print( "begin reading..." );
  feats = getFeatures( filename, 1000000 );
  println( "done" );
  println( "read "+feats.size()+" features" );
  println( "first feature: "+feats.get(0) );
  
  // get the bounding box of the shapefile
  bounds = getBounds(feats);
  
  // get grid
  grid = new Grid(-71.099356, 42.353578, -71.081149, 42.367631, 5, 5);

  strokeWeight(0.000003);
  smooth();
  
  from = color(204, 102, 0);
  to = color(0, 102, 153);
  
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
  for(Polygon cell : grid.cells ){
    Coordinate[] coords = cell.getCoordinates();
    beginShape();
    for(Coordinate coord : coords){
      vertex((float)coord.x,(float)coord.y);
    }
    endShape(CLOSE);
  }
}

void scaleToBounds(){
  float ll = bounds[0];
  float bb = bounds[1];
  float rr = bounds[2];
  float tt = bounds[3];

  float objx = (rr+ll)/2;
  float objy = (tt+bb)/2;

  float yscale=height/(tt-bb);
  float xscale=width/(rr-ll);
  
  translate(width/2,height/2);
  scale(xscale,-yscale);
  translate(-objx,-objy);
}

void draw(){
  background(255);

  scaleToBounds();
  
  drawPolygons();
  drawGrid();
  
  noLoop(); //loop once through and stop
}
