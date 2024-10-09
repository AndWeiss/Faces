//
//
float[][] ReadFile(String filename,String separator){

// load file
String[] lines = loadStrings(filename);

// get number of rows and columns
int rows = lines.length;
//println("number of rows");
//println(rows);
int cols = split(lines[0], separator).length;
//println("number of cols");
//println(cols);

// create array
float[][] floatArray = new float[rows][cols];

// iterate over lines
for (int i = 0; i < rows; i++) {

  // split current line
  String[] row = split(lines[i], separator);

  // iterate over values
  for (int j = 0; j< cols; j++) {

    // parse and store the value
    floatArray[i][j] = float(row[j]);
  }
}
return floatArray;
}
