import java.util.List;
import com.vividsolutions.jts.geom.Geometry;

void setup(){
  size(200,200);
  
  String filename = dataPath("tabblock2010_25_pophu.shp");
  println( filename );

  List<Geometry> geoms = getGeoms( filename );
  println( geoms.get(0) );
  
}

void draw(){
}
