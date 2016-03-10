import java.util.List;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.MultiPolygon;
import com.vividsolutions.jts.geom.Envelope;

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

color from,to;

void setup(){
  size(700,400);
  
  String filename = dataPath("tabblock2010_25_pophu.shp");

  // read the entire shapefile
  print( "begin reading..." );
  feats = getFeatures( filename, 1000000 );
  println( "done" );
  println( "read "+feats.size()+" features" );
  println( "first feature: "+feats.get(0) );
  
  // get the bounding box of the shapefile
  bounds = getBounds(feats);

  strokeWeight(0.000003);
  smooth();
  noStroke();
  
  from = color(204, 102, 0);
  to = color(0, 102, 153);
  
}

void drawPolygons(){
  for(Feature feat : feats ){
    MultiPolygon geom = (MultiPolygon) feat.getDefaultGeometryProperty().getValue();
    int ind = (Integer)feat.getProperty("POP10").getValue();
    
    fill( lerpColor(from,to,ind/100.0) );
    
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
  
  noLoop(); //loop once through and stop
}
