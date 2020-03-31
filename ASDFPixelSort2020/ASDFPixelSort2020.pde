 /*
ASDF Pixel Sort
Original by:
Kim Asendorf | 2010 | kimasendorf.com | github.com/kimasendorf/ASDFPixelSort
Adapted and modernized by:
Massimo Albanese | @madlitch | 2020 | madlitch.cc
 */
 
//////////// Parameters ////////////
 
 // Inputs
String inputFilePath = "/Users/massimoalbanese/Pictures/PixelSorting/source/";
String fileName = "DSC03098g.jpeg";

// Outputs
String outputFilePath = "/Users/massimoalbanese/Pictures/PixelSorting/results/";
String outputFileType = ".tiff";
 
// Variables
boolean sortByBlacks = true;
boolean sortByBrightness = true;
boolean sortByWhites = true;

boolean sortHorizontally = true;
boolean sortVertically = true;
boolean sortVAndH = true;

int loops = 1;

// Threshold values to determine sorting start and end pixels
int blackValue = -16000000;
int brightnessValue = 60;
int whiteValue = -13000000;


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////


int files;
String saveFileName;
int row;
int column;
boolean saved;
PImage img;

void setup() {
  row = 0;
  column = 0;
  img = loadImage(inputFilePath + fileName);
  saveFileName = stripFileExtension(fileName); 
  size(1, 1);
  
  if(sortHorizontally)
    callSort(false, true, false);
  if (sortVertically)
    callSort(true, false, false);
  if (sortVAndH)
    callSort(false, false, true);

  
  println("Saved " + files + " file(s)");
  saved = true;
  println("Done! You can now exit the program.");
}

void callSort(boolean vertical, boolean horizontal, boolean VandH){
  if (sortByBlacks)
    sort(0, vertical, horizontal, VandH);
  if (sortByBrightness)
    sort(1, vertical, horizontal, VandH);
  if (sortByWhites)
    sort(2, vertical, horizontal, VandH);
}

void sort(int mode, boolean vertical, boolean horizontal, boolean VandH){
  files++;
  for(int i = 1; i <= loops; i++){
    if(!horizontal)
      loopColumns(mode);
      
    if(!vertical)
      loopRows(mode);
      
    if(VandH){
      loopRows(mode);
      loopColumns(mode);
    }
    column = row = 0;
    if (vertical)
      println("Sorted "+ i +" Frame(s) of file " + files + ", vertical mode " + mode);
    else if (horizontal)
      println("Sorted "+ i +" Frame(s) of file " + files + ", horizontal mode " + mode);
    else if (VandH)
      println("Sorted "+ i +" Frame(s) of file " + files + ", V and H mode " + mode);
    
  }
  save(mode, vertical, horizontal, VandH);
}

void loopColumns(int mode){
  while(column < img.width-1) {
    img.loadPixels(); 
    sortColumn(mode);
    column++;
    img.updatePixels();
  }
}

void loopRows(int mode){
  while(row < img.height-1) {
    img.loadPixels(); 
    sortRow(mode);
    row++;
    img.updatePixels();
  }
}

void save(int mode, boolean vertical, boolean horizontal, boolean VandH){
  if (vertical)
      img.save(outputFilePath + saveFileName + "/" + saveFileName +"_ASDF_" + mode + "_V" + outputFileType);
    else if (horizontal)
      img.save(outputFilePath + saveFileName + "/" + saveFileName +"_ASDF_" + mode + "_H" + outputFileType);
    else if (VandH)
      img.save(outputFilePath + saveFileName + "/" + saveFileName +"_ASDF_" + mode + "_V&H" + outputFileType);
      
  println("Saved file " + files);
  row = 0;
  column = 0;
  img = loadImage(inputFilePath + fileName);
  //image(img, 0, 0, width, height);
}

// strip file extension for saving and renaming
String stripFileExtension(String s) {
  s = s.substring(s.lastIndexOf('/')+1, s.length());
  s = s.substring(s.lastIndexOf('\\')+1, s.length());
  s = s.substring(0, s.lastIndexOf('.'));
  return s;
}

void sortRow(int mode) {
  // current row
  int y = row;
  
  // where to start sorting
  int x = 0;
  
  // where to stop sorting
  int xend = 0;
  
  while(xend < img.width-1) {
    switch(mode) {
      case 0:
        x = getFirstNotBlackX(x, y);
        xend = getNextBlackX(x, y);
        break;
      case 1:
        x = getFirstBrightX(x, y);
        xend = getNextDarkX(x, y);
        break;
      case 2:
        x = getFirstNotWhiteX(x, y);
        xend = getNextWhiteX(x, y);
        break;
      default:
        break;
    }
    
    if(x < 0) break;
    
    int sortLength = xend-x;
    
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    for(int i=0; i<sortLength; i++) {
      unsorted[i] = img.pixels[x + i + y * img.width];
    }
    
    sorted = sort(unsorted);
    
    for(int i=0; i<sortLength; i++) {
      img.pixels[x + i + y * img.width] = sorted[i];      
    }
    x = xend+1;
  }
}


void sortColumn(int mode) {
  // current column
  int x = column;
  
  // where to start sorting
  int y = 0;
  
  // where to stop sorting
  int yend = 0;
  
  while(yend < img.height-1) {
    switch(mode) {
      case 0:
        y = getFirstNotBlackY(x, y);
        yend = getNextBlackY(x, y);
        break;
      case 1:
        y = getFirstBrightY(x, y);
        yend = getNextDarkY(x, y);
        break;
      case 2:
        y = getFirstNotWhiteY(x, y);
        yend = getNextWhiteY(x, y);
        break;
      default:
        break;
    }
    
    if(y < 0) break;

    int sortLength = yend-y;
    
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    for(int i=0; i<sortLength; i++) {
      unsorted[i] = img.pixels[x + (y+i) * img.width];
    }
    
    sorted = sort(unsorted);
    
    for(int i=0; i<sortLength; i++) {
      img.pixels[x + (y+i) * img.width] = sorted[i];
    }
    y = yend+1;
  }
}

// black x
int getFirstNotBlackX(int x, int y) {
  while(img.pixels[x + y * img.width] < blackValue) {
    x++;
    if(x >= img.width) 
      return -1;
  }
  return x;
}

int getNextBlackX(int x, int y) {
  x++;
  while(img.pixels[x + y * img.width] > blackValue) {
    x++;
    if(x >= img.width) 
      return img.width-1;
  }
  return x-1;
}

// brightness x
int getFirstBrightX(int x, int y) {
  while(brightness(img.pixels[x + y * img.width]) < brightnessValue) {
    x++;
    if(x >= img.width)
      return -1;
  }
  return x;
}

int getNextDarkX(int _x, int _y) {
  int x = _x+1;
  int y = _y;
  
  while(brightness(img.pixels[x + y * img.width]) > brightnessValue) {
    x++;
    if(x >= img.width) return img.width-1;
  }
  return x-1;
}

// white x
int getFirstNotWhiteX(int x, int y) {
  while(img.pixels[x + y * img.width] > whiteValue) {
    x++;
    if(x >= img.width) 
      return -1;
  }
  return x;
}

int getNextWhiteX(int x, int y) {
  x++;
  while(img.pixels[x + y * img.width] < whiteValue) {
    x++;
    if(x >= img.width) 
      return img.width-1;
  }
  return x-1;
}

// black y
int getFirstNotBlackY(int x, int y) {
  if(y < img.height) {
    while(img.pixels[x + y * img.width] < blackValue) {
      y++;
      if(y >= img.height)
        return -1;
    }
  }
  return y;
}

int getNextBlackY(int x, int y) {
  y++;
  if(y < img.height) {
    while(img.pixels[x + y * img.width] > blackValue) {
      y++;
      if(y >= img.height)
        return img.height-1;
    }
  }
  return y-1;
}

// brightness y
int getFirstBrightY(int x, int y) {
  if(y < img.height) {
    while(brightness(img.pixels[x + y * img.width]) < brightnessValue) {
      y++;
      if(y >= img.height)
        return -1;
    }
  }
  return y;
}

int getNextDarkY(int x, int y) {
  y++;
  if(y < img.height) {
    while(brightness(img.pixels[x + y * img.width]) > brightnessValue) {
      y++;
      if(y >= img.height)
        return img.height-1;
    }
  }
  return y-1;
}

// white y
int getFirstNotWhiteY(int x, int y) {
  if(y < img.height) {
    while(img.pixels[x + y * img.width] > whiteValue) {
      y++;
      if(y >= img.height)
        return -1;
    }
  }
  return y;
}

int getNextWhiteY(int x, int y) {
  y++;
  if(y < img.height) {
    while(img.pixels[x + y * img.width] < whiteValue) {
      y++;
      if(y >= img.height) 
        return img.height-1;
    }
  }
  return y-1;
}
