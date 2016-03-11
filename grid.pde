class Grid{
  float eq_m_per_londeg = 17716.9;
  float m_per_londeg;
  float m_per_latdeg = 17657.7;
  
  List<Polygon> cells;
  int ncols;
  int nrows;
  
  Coordinate proj(Coordinate coord){
    // deg * m/deg = m
    return new Coordinate(coord.x * m_per_latdeg, coord.y * m_per_latdeg);
  }
  
  Coordinate unproj(Coordinate coord){
    // m / (m/deg) = m * (deg/m) = deg
    return new Coordinate(coord.x / m_per_latdeg, coord.y / m_per_latdeg);
  }
    
  Grid(float centerlat, float centerlon, float cellwidth, int ncols, int nrows) throws Exception{    
    m_per_londeg = cos( radians(centerlat) )*eq_m_per_londeg;
    
    Coordinate center = proj( new Coordinate(centerlon,centerlat) );
    float totalwidth = cellwidth*ncols;
    float totalheight = cellwidth*nrows;
    float left = (float)center.x - totalwidth/2;
    float bottom = (float)center.y - totalwidth/2;
    
    this.nrows = nrows;
    this.ncols = ncols;
        
    List<Polygon> cells = new ArrayList<Polygon>();
    GeometryFactory fact = new GeometryFactory();
    for(int y=0; y<nrows; y++){
      for(int x=0; x<ncols; x++){

        // create coordinates of corners
        Coordinate[] coords = new Coordinate[5];
        coords[0] = unproj( new Coordinate(left+x*cellwidth,    bottom+y*cellwidth) ); //lower left
        coords[1] = unproj( new Coordinate(left+(x+1)*cellwidth,bottom+y*cellwidth) ); //lower right
        coords[2] = unproj( new Coordinate(left+(x+1)*cellwidth,bottom+(y+1)*cellwidth) ); //upper right
        coords[3] = unproj( new Coordinate(left+x*cellwidth,    bottom+(y+1)*cellwidth) ); //upper left
        coords[4] = unproj( new Coordinate(left+x*cellwidth,    bottom+y*cellwidth) ); //lower left
        
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
