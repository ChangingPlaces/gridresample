class Grid{
  float eq_m_per_londeg = 17716.9;
  float m_per_latdeg = 17657.7;
  
  List<Polygon> cells;
  int ncols;
  int nrows;
  float cellArea;
  
  Grid(float centerlat, float centerlon, float cellwidth_meters, int ncols, int nrows){
    float m_per_londeg = cos( radians(centerlat) )*eq_m_per_londeg;
    
    float cellwidth = cellwidth_meters / m_per_londeg; // m / (m/deg) = m * (deg/m) = deg
    float cellheight = cellwidth_meters / m_per_latdeg; // m / (m/deg) = m * (deg/m) = deg
    float totalwidth = cellwidth*ncols;
    float totalheight = cellheight*nrows;
    float left = centerlon - totalwidth/2;
    float rigtht = centerlon + totalwidth/2;
    float bottom = centerlat - totalheight/2;
    float top = centerlat + totalheight/2;
    
    this.nrows = nrows;
    this.ncols = ncols;
    
    this.cellArea = cellwidth*cellheight;
    
    List<Polygon> cells = new ArrayList<Polygon>();
    GeometryFactory fact = new GeometryFactory();
    for(int y=0; y<nrows; y++){
      for(int x=0; x<ncols; x++){

        // create coordinates of corners
        Coordinate[] coords = new Coordinate[5];
        coords[0] = new Coordinate(left+x*cellwidth,    bottom+y*cellheight); //lower left
        coords[1] = new Coordinate(left+(x+1)*cellwidth,bottom+y*cellheight); //lower right
        coords[2] = new Coordinate(left+(x+1)*cellwidth,bottom+(y+1)*cellheight); //upper right
        coords[3] = new Coordinate(left+x*cellwidth,    bottom+(y+1)*cellheight); //upper left
        coords[4] = new Coordinate(left+x*cellwidth,    bottom+y*cellheight); //lower left
        
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
  
  float[][] resample(STRtree index, String propname){
    
    float[][] ret = new float[ncols][nrows];
    
    for(int y=0; y<nrows; y++){
      for(int x=0; x<ncols; x++){
        //println("cell: ("+x+","+y+")");
        float sum = 0;
        
        Polygon cell = this.cells.get(y*ncols+x);
        
        List<Feature> queryFeats = index.query( cell.getEnvelopeInternal() );
        
        int nOverlaps = 0;
        for(Feature feat : queryFeats){
          MultiPolygon featgeom = (MultiPolygon) feat.getDefaultGeometryProperty().getValue();
          int ind = (Integer)feat.getProperty(propname).getValue();
          Geometry overlap = featgeom.intersection(cell);
          
          float fracOverlap = (float)(overlap.getArea()/featgeom.getArea());
          if(fracOverlap>0){
            nOverlaps += 1;
            //println( "  feat "+ind+" * "+(fracOverlap*100)+"% = "+(fracOverlap*ind) );
          }
          
          sum += fracOverlap*ind;
        }
        //println( "cell ("+x+","+y+") has "+nOverlaps+" overlapping features, sum:"+sum+"" );
        
        ret[y][x] = sum;
      }
    }
    
    return ret;
  }
  
  Polygon getCell(int x, int y){
    return this.cells.get(y*ncols+x);
  }
}
