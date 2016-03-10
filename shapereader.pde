import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.geotools.data.DataStore;
import org.geotools.data.DataStoreFinder;
import org.geotools.data.FeatureSource;
import org.geotools.feature.FeatureCollection;
import org.geotools.feature.FeatureIterator;
import org.opengis.feature.Feature;

import com.vividsolutions.jts.geom.Geometry;

public List<Feature> getFeatures(String filename) {
  try {
    ArrayList<Feature> ret = new ArrayList<Feature>();

    File file = new File(filename);
    Map<String, Object> map = new HashMap<String, Object>();
    map.put("url", file.toURI().toURL());

    DataStore dataStore = DataStoreFinder.getDataStore(map);
    String typeName = dataStore.getTypeNames()[0];

    FeatureSource<?, ?> featureSource = dataStore.getFeatureSource(typeName);
    FeatureCollection<?, ?> collection = featureSource.getFeatures();
    FeatureIterator<?> iterator = collection.features();

    try {
      while (iterator.hasNext ()) {
        Feature feature = iterator.next();
        //Geometry geom = (Geometry) feature.getDefaultGeometryProperty().getValue();
        ret.add( feature );
      }
    } 
    finally {
      iterator.close();
      dataStore.dispose();
    }

    return ret;
  }
  catch(Exception ex) {
    return new ArrayList();
  }
}

