import java.util.List;
import com.vividsolutions.jts.geom.Geometry;

void setup(){
  size(200,200);
  
  String filename = dataPath("tabblock2010_25_pophu.shp");
  println( filename );

  print( "begin reading..." );
  List<Feature> feats = getFeatures( filename );
  println( "done" );
  println( "read "+feats.size()+" features" );
  println( "first feature: "+feats.get(0) );
  
}

void draw(){
}
