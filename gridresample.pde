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
List<MultiPolygon> mpolygons;

void setup(){
  size(200,200);
  
  String filename = dataPath("tabblock2010_25_pophu.shp");
  println( filename );

  print( "begin reading..." );
  List<Feature> feats = getFeatures( filename, 1 );
  println( "done" );
  println( "read "+feats.size()+" features" );
  println( "first feature: "+feats.get(0) );
  
  bounds = getBounds(feats);
  println( bounds );
  
  mpolygons = new ArrayList();
  mpolygons.add( (MultiPolygon) feats.get(0).getDefaultGeometryProperty().getValue() );
  
//  MultiPolygon geom = (MultiPolygon) feats.get(0).getDefaultGeometryProperty().getValue();
//  for(int i=0; i<geom.getNumGeometries(); i++){
//    Geometry subgeom = geom.getGeometryN(i);
//    println( subgeom.getCoordinates() );
//  }

  strokeWeight(0.000003);
  smooth();
  
}

void drawPolygons(){
  for(MultiPolygon geom : mpolygons ){
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

void draw(){
  background(255);

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
  
  
  stroke(255,0,0);
  line(ll,bb,rr,tt);
  stroke(0);
  line(ll,tt,rr,bb);
  line(ll,tt,rr,tt);
  
  drawPolygons();
}
