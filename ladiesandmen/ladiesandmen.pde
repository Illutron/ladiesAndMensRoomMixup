// Copyright Halfmachine / Mads H¿bye, Vanessa Carpenter, Daniel Brynolf


int bits[8] = { 
  128, 64, 32, 16, 8, 4, 2, 1   };
// byte ledmatrixarray[64];


int clock[2] = {2,5};   
int data[2] = {1,4}; //refers to pins.
int cs[2] = {0,3};

int step[2]; // animation step, usually from 0 to 8, per screen
int stepDelay = 19; //the wait time between each animation frame
int delayCounter[2]; //holder for the delay, as to not hog to processor, per screen

int animationStyle = 0; //different types of animation

byte displayPicture[2][8][8]; //Display picture. What is currently ON display.

byte bitmaps[19][8][8]; //2 (male/female), 1 unisex, 9x2 blur pair (total 21) all on an 8X8 grid
int blurBitmapPair = 0; //setting for which blur pair to use
int numBlurPairs = 8; //number of blur pairs
int blurSwitchDisplay = 0; //Switches the signs of the blur Pair
int blurDelayCounter = 0; //holds value for delay between blurpair changes.
int nextBlurChange = 1700; // default value for next change - should be something alot bigger, 5000?

int readTimes = 0; //number of times read for the wheel
int lastRead = 0; // last read for wheel
int wheelValue = 0;
int wheelModi = 0;
  
int drawModeCount = 0;
int currentBitmap[2]; //current displayed bitmap, per display
int targetBitmap[2]; //Desired image, for the animation to strive for, per display

void setup() {
  Serial.begin(9600);
   pinMode(43, OUTPUT); 
    pinMode(44, OUTPUT); 
  pinMode(48, OUTPUT); 
  //pole out
   pinMode(41, OUTPUT); 
   // btns
   pinMode(6, INPUT); 
   pinMode(7, INPUT); 
   randomSeed(analogRead(16));
   blurBitmapPair = ((int)random(0,150))%numBlurPairs;
   
  digitalWrite(48, HIGH); 
  matrixInit();
  int bitmap = 0;
   // digitalWrite(43, HIGH);   
    //digitalWrite(44, HIGH);
  // Girl
  
  addLineTobitmap(bitmap,0,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,1,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,2,0,0,0,2,0,0,0,0);
  addLineTobitmap(bitmap,3,0,2,2,6,2,2,0,0);
  addLineTobitmap(bitmap,4,0,0,6,6,6,0,0,0);
  addLineTobitmap(bitmap,5,0,6,6,6,6,6,0,0);
  addLineTobitmap(bitmap,6,0,0,2,0,2,0,0,0);
  addLineTobitmap(bitmap,7,0,0,2,0,2,0,0,0);
 
  // Boy
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,1,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,2,0,0,0,2,0,0,0,0);
  addLineTobitmap(bitmap,3,2,2,3,3,3,2,2,0);
  addLineTobitmap(bitmap,4,0,0,3,3,3,0,0,0);
  addLineTobitmap(bitmap,5,0,0,3,3,3,0,0,0);
  addLineTobitmap(bitmap,6,0,0,2,0,2,0,0,0);
  addLineTobitmap(bitmap,7,0,0,2,0,2,0,0,0);
   
  // Unisex
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,2,2,2,2,0,0);
  addLineTobitmap(bitmap,1,0,0,2,2,2,2,0,0);
  addLineTobitmap(bitmap,2,0,0,0,2,2,0,0,0);
  addLineTobitmap(bitmap,3,0,2,2,6,3,3,2,0);
  addLineTobitmap(bitmap,4,0,0,6,6,3,3,0,0);
  addLineTobitmap(bitmap,5,0,6,6,6,3,3,0,0);
  addLineTobitmap(bitmap,6,0,0,2,0,0,2,0,0);
  addLineTobitmap(bitmap,7,0,0,2,0,0,2,0,0);
  
  // Blurpair 1: Orange Triangle
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,1,0,4,0,0,0,0,0,0);
  addLineTobitmap(bitmap,2,0,4,4,0,0,0,0,0);
  addLineTobitmap(bitmap,3,0,4,4,4,0,0,0,0);
  addLineTobitmap(bitmap,4,0,4,4,4,4,0,0,0);
  addLineTobitmap(bitmap,5,0,4,4,4,4,4,0,0);
  addLineTobitmap(bitmap,6,0,4,4,4,4,4,4,0);
  addLineTobitmap(bitmap,7,0,0,0,0,0,0,0,0);
  
    // Blurpair 1: Light Blue Ball
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,1,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,2,0,0,5,5,5,5,0,0);
  addLineTobitmap(bitmap,3,0,5,5,5,5,5,5,0);
  addLineTobitmap(bitmap,4,0,5,5,5,5,5,5,0);
  addLineTobitmap(bitmap,5,0,0,5,5,5,5,0,0);
  addLineTobitmap(bitmap,6,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,7,0,0,0,0,0,0,0,0);
  
  // Blurpair 2: Pink X
  bitmap++;
  addLineTobitmap(bitmap,0,7,0,0,0,0,0,0,7);
  addLineTobitmap(bitmap,1,0,7,0,0,0,0,7,0);
  addLineTobitmap(bitmap,2,0,0,7,0,0,7,0,0);
  addLineTobitmap(bitmap,3,0,0,0,7,7,0,0,0);
  addLineTobitmap(bitmap,4,0,0,0,7,7,0,0,0);
  addLineTobitmap(bitmap,5,0,0,7,0,0,7,0,0);
  addLineTobitmap(bitmap,6,0,7,0,0,0,0,7,0);
  addLineTobitmap(bitmap,7,7,0,0,0,0,0,0,7);
  
    // Blurpair 2: Blue Heart
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,1,0,3,3,0,0,3,3,0);
  addLineTobitmap(bitmap,2,3,3,3,3,3,3,3,3);
  addLineTobitmap(bitmap,3,3,3,3,3,3,3,3,3);
  addLineTobitmap(bitmap,4,0,3,3,3,3,3,3,0);
  addLineTobitmap(bitmap,5,0,0,3,3,3,3,0,0);
  addLineTobitmap(bitmap,6,0,0,0,3,3,0,0,0);
  addLineTobitmap(bitmap,7,0,0,0,0,0,0,0,0);
  
  // Blurpair 3, Rainbow
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,1,0,5,5,5,5,5,5,0);
  addLineTobitmap(bitmap,2,0,5,0,0,0,0,5,0);
  addLineTobitmap(bitmap,3,0,5,0,0,0,0,5,0);
  addLineTobitmap(bitmap,4,0,5,0,0,0,0,5,0);
  addLineTobitmap(bitmap,5,0,5,0,0,0,0,5,0);
  addLineTobitmap(bitmap,6,0,5,5,5,5,5,5,0);
  addLineTobitmap(bitmap,7,0,0,0,0,0,0,0,0);
  
    // Blurpair 3, White Lined Square 
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,1,1,1,1,1,1,1,1,1);
  addLineTobitmap(bitmap,2,4,4,4,4,4,4,4,4);
  addLineTobitmap(bitmap,3,2,2,2,2,2,2,2,2);
  addLineTobitmap(bitmap,4,5,5,5,5,5,5,5,5);
  addLineTobitmap(bitmap,5,3,3,3,3,3,3,3,3);
  addLineTobitmap(bitmap,6,6,6,6,6,6,6,6,6);
  addLineTobitmap(bitmap,7,0,0,0,0,0,0,0,0);
  
  // Blurpair 4, Happy Smiley
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,1,0,0,4,0,0,4,0,0);
  addLineTobitmap(bitmap,2,0,0,4,0,0,4,0,0);
  addLineTobitmap(bitmap,3,0,0,4,0,0,4,0,0);
  addLineTobitmap(bitmap,4,4,0,0,0,0,0,0,4);
  addLineTobitmap(bitmap,5,0,4,0,0,0,0,4,0);
  addLineTobitmap(bitmap,6,0,0,4,4,4,4,0,0);
  addLineTobitmap(bitmap,7,0,0,0,0,0,0,0,0);
  
    // Blurpair 4, Sad Smiley
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,1,0,0,4,0,0,4,0,0);
  addLineTobitmap(bitmap,2,0,0,4,0,0,4,0,0);
  addLineTobitmap(bitmap,3,0,0,4,0,0,4,0,0);
  addLineTobitmap(bitmap,4,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,5,0,0,4,4,4,4,0,0);
  addLineTobitmap(bitmap,6,0,4,0,0,0,0,4,0);
  addLineTobitmap(bitmap,7,4,0,0,0,0,0,0,4);
  
  // Blurpair 5, Danish flag
  //bitmap++;
  //addLineTobitmap(bitmap,0,1,1,5,5,1,1,1,1);
  //addLineTobitmap(bitmap,1,1,1,5,5,1,1,1,1);
  //addLineTobitmap(bitmap,2,1,1,5,5,1,1,1,1);
  //addLineTobitmap(bitmap,3,5,5,5,5,5,5,5,5);
  //addLineTobitmap(bitmap,4,5,5,5,5,5,5,5,5);
  //addLineTobitmap(bitmap,5,1,1,5,5,1,1,1,1);
  //addLineTobitmap(bitmap,6,1,1,5,5,1,1,1,1);
  //addLineTobitmap(bitmap,7,1,1,5,5,1,1,1,1);
  
    // Blurpair 5, Swedish flag
  //bitmap++;
  //addLineTobitmap(bitmap,0,3,3,4,4,3,3,3,3);
  //addLineTobitmap(bitmap,1,3,3,4,4,3,3,3,3);
  //addLineTobitmap(bitmap,2,3,3,4,4,3,3,3,3);
  //addLineTobitmap(bitmap,3,4,4,4,4,4,4,4,4);
  //addLineTobitmap(bitmap,4,4,4,4,4,4,4,4,4);
  //addLineTobitmap(bitmap,5,3,3,4,4,3,3,3,3);
  //addLineTobitmap(bitmap,6,3,3,4,4,3,3,3,3);
  //addLineTobitmap(bitmap,7,3,3,4,4,3,3,3,3);

    // Blurpair 6, Can-Can Girl
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,1,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,2,0,0,0,2,0,0,0,0);
  addLineTobitmap(bitmap,3,0,2,2,6,6,2,0,0);
  addLineTobitmap(bitmap,4,0,0,6,6,6,6,6,0);
  addLineTobitmap(bitmap,5,0,6,6,6,0,2,0,0);
  addLineTobitmap(bitmap,6,0,0,2,0,0,2,0,0);
  addLineTobitmap(bitmap,7,0,0,2,0,0,0,0,0);
 
    // Blurpair 6, Breakdance boy
  bitmap++;
  addLineTobitmap(bitmap,7,0,0,2,0,0,0,0,0);
  addLineTobitmap(bitmap,6,0,0,2,0,0,0,0,0);
  addLineTobitmap(bitmap,5,0,0,3,3,0,0,0,0);
  addLineTobitmap(bitmap,4,0,0,3,3,2,2,2,0);
  addLineTobitmap(bitmap,3,2,2,3,3,3,0,0,0);
  addLineTobitmap(bitmap,2,0,0,2,3,2,0,0,0);
  addLineTobitmap(bitmap,1,0,2,2,2,0,2,0,0);
  addLineTobitmap(bitmap,0,0,2,2,2,0,0,0,0);
    // Blurpair 7, Question Mark
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,5,5,5,5,0,0);
  addLineTobitmap(bitmap,1,0,5,5,5,5,5,5,0);
  addLineTobitmap(bitmap,2,0,5,5,0,0,5,5,0);
  addLineTobitmap(bitmap,3,0,0,0,0,5,5,0,0);
  addLineTobitmap(bitmap,4,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,5,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,6,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,7,0,0,0,5,5,0,0,0);
 
    // Blurpair 7, Exclamation Mark
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,1,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,2,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,3,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,4,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,5,0,0,0,0,0,0,0,0);
  addLineTobitmap(bitmap,6,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,7,0,0,0,5,5,0,0,0);

    // Blurpair 8, Windows
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,1,0,0,0,0);
  addLineTobitmap(bitmap,1,0,0,1,1,1,2,0,2);
  addLineTobitmap(bitmap,2,0,1,1,1,2,2,2,0);
  addLineTobitmap(bitmap,3,0,1,3,1,2,2,2,0);
  addLineTobitmap(bitmap,4,0,3,3,3,4,2,4,0);
  addLineTobitmap(bitmap,5,3,3,3,4,4,4,0,0);
  addLineTobitmap(bitmap,6,3,0,3,4,4,4,0,0);
  addLineTobitmap(bitmap,7,0,0,0,0,4,0,0,0);
 
    // Blurpair 8, Mac
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,0,0,5,5,0,0);
  addLineTobitmap(bitmap,1,0,0,0,5,5,0,0,0);
  addLineTobitmap(bitmap,2,0,5,5,0,0,5,5,0);
  addLineTobitmap(bitmap,3,5,5,5,5,5,5,5,5);
  addLineTobitmap(bitmap,4,5,5,5,5,5,5,5,0);
  addLineTobitmap(bitmap,5,5,5,5,5,5,5,5,5);
  addLineTobitmap(bitmap,6,0,5,5,5,5,5,5,0);
  addLineTobitmap(bitmap,7,0,0,5,5,5,5,0,0);

  // Girl with blue skirt
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,1,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,2,0,0,0,2,0,0,0,0);
  addLineTobitmap(bitmap,3,0,2,2,3,2,2,0,0);
  addLineTobitmap(bitmap,4,0,0,3,3,3,0,0,0);
  addLineTobitmap(bitmap,5,0,3,3,3,3,3,0,0);
  addLineTobitmap(bitmap,6,0,0,2,0,2,0,0,0);
  addLineTobitmap(bitmap,7,0,0,2,0,2,0,0,0);
 
  // Boy with pink dress
  bitmap++;
  addLineTobitmap(bitmap,0,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,1,0,0,2,2,2,0,0,0);
  addLineTobitmap(bitmap,2,0,0,0,2,0,0,0,0);
  addLineTobitmap(bitmap,3,2,2,6,6,6,2,2,0);
  addLineTobitmap(bitmap,4,0,0,6,6,6,0,0,0);
  addLineTobitmap(bitmap,5,0,0,6,6,6,0,0,0);
  addLineTobitmap(bitmap,6,0,0,2,0,2,0,0,0);
  addLineTobitmap(bitmap,7,0,0,2,0,2,0,0,0);

}


boolean btnState = false;
int btnStateCount =1;

void loop() //Need to make a mode-switcher thingy. Make a switch statement.
{ 
  modeWheel();
  
  handleAnimations();
  writeMatrix();
}

//Button Part: (For Doors). Button is set to false(Low/off) so that only when there 
//is a change in status, and it turns on, that it recognizes the need to do something.
boolean btn0 = false; 
boolean btn1 = false;
int btnCount =0;
boolean btnModeMixed = false;

void modeButton()
{
  if(digitalRead(6) != btn0) //If the button is not in the off position (b/c we set btn0 to be false initially)
  {
    btn0= !btn0; //then change btn0 to be the opposite of what it's set to - ie: make it true/on.
    btnCount++; //then add one to the button count
  }
  if(digitalRead(7) != btn1) //ditto for btn1
  {
    btn1= !btn1;
    btnCount++;
  }
  if (btnCount > 15) //then if the button count (btn0 and btn1) is >15
  {
    btnCount = 0; //reset the button count
    btnModeMixed = !btnModeMixed;
  }
  if (btnModeMixed)
  {
    drawMode(0); //draw! (when it is switched)  refers to case 0 
  }
  else
  {
    drawMode(2); //draw! (when it is normal) refers to case 2
  }
  
}



void modeWheel()
{
  wheelValue = analogRead(0);
  //Serial.println(value); 
  wheelModi = (wheelValue/(1025 / 5));
  Serial.println(wheelModi); 
  if (wheelModi == lastRead){
  readTimes += 1;  
    if (readTimes > 6){
      
      switch (wheelModi)
      {
      case 0:
        drawMode(1); //boy boy
        break;
      case 1:
        drawMode(2); //boy girl
        break;
      case 2:
      modeButton();//auto
        
        break;
      case 3:        
        drawMode(5); //blur
        break;
     case 4:
        drawMode(0); //girl boy
        break;
      case 5:
        drawMode(2); //boy girl
        break;
      case 6:
        drawMode(3); //girl girl
        break;
      }
    }
  } else {
  readTimes = 0;
  }
  lastRead = wheelModi;
}

//This next part sets up the switching between the 6 bitmaps for each mode of control.
int drawModeLast = 0;
void drawMode(int value)
{
  drawModeCount = value % 6; //Switch 'switches' thru all the cases below.
  switch (value % 6)
  {
    case 0:
    //girl boy
      targetBitmap[0] = 0; 
      targetBitmap[1] = 1; 
      break;
   case 1:
   //boy boy
      targetBitmap[0] = 1; 
      targetBitmap[1] = 1; 
      break;
   case 2:
   //boy girl
      targetBitmap[0] = 1; 
      targetBitmap[1] = 0; 
      break;
   case 3:
   //girl girl
      targetBitmap[0] = 0; 
      targetBitmap[1] = 0; 
      break;
   case 4:
   //unisex
      targetBitmap[0] = 2; 
      targetBitmap[1] = 2; 
      break;
   case 5:
   //blur
       if(value != drawModeLast)
       {
         handleBlurChange();
       }
       else
       {
        handleBlur(); 
       }
      if(blurSwitchDisplay == 0){
        targetBitmap[0] = 3+blurBitmapPair*2; 
        targetBitmap[1] = 4+blurBitmapPair*2; 
      }
      else
      {        
        targetBitmap[0] = 4+blurBitmapPair*2; 
        targetBitmap[1] = 3+blurBitmapPair*2; 
      }
      
      break;
  } 
  drawModeLast = value;
}


void handleBlurChange()
{
   blurSwitchDisplay = ( blurSwitchDisplay + 1 )%2;
    blurBitmapPair = ( blurBitmapPair + (int)random(0,100) )%numBlurPairs;
    blurDelayCounter = 0;
  
}


void handleBlur()
{
  blurDelayCounter++;
  if (blurDelayCounter > nextBlurChange){
   handleBlurChange();
    }
  
}

void randomColorGenerator()
{

  displayPicture[0][(int)random(8)][(int)random(8)] = (byte)(int)random(8);
  //x,y, colour definition for diplay 0. 
}

void handleAnimations()
{
  for (int screen = 0; screen <2 ; screen++){
      
      if(currentBitmap[screen] != targetBitmap[screen]){
        
        //the function takes 4 variables
        drawAnimationToDisplay(currentBitmap[screen], targetBitmap[screen], step[screen], screen); 
        delayCounter[screen]++;
        
        if(delayCounter[screen] > stepDelay){
          step[screen]++;
        }
        
        if(step[screen] > 7){
          step[screen] = 0;
          currentBitmap[screen] = targetBitmap[screen];
        }
      }
      else
      {
        drawBitmapToDisplay(currentBitmap[screen], screen); 
      }
    }
}


// ###### MATRIX API #####################

void matrixInit()
{
  for(int display = 0;display <2;display++) //Running through each display (0 and 1)
  {
    pinMode(clock[display], OUTPUT); // sets the digital pin as output 
    pinMode(data[display], OUTPUT); 
    pinMode(cs[display], OUTPUT); 
  }
}


void writeByte(byte myByte, int display) //prints out bytes. Each colour is printed out.
{

  for (int b = 0; b < 8; b++) { //converting it to binary from colour code.
    digitalWrite(clock[display], LOW); 
    if ((myByte & bits[b])  > 0)
    {
      digitalWrite(data[display], HIGH);
    }
    else
    {
      digitalWrite(data[display], LOW);
    }
    digitalWrite(clock[display], HIGH); 
    delayMicroseconds(10);
    digitalWrite(clock[display], LOW); 
  }
}

void writeMatrix()
{
  for(int display = 0;display <2;display++)
  {
    digitalWrite(clock[display], LOW);    //sets the clock for each display, running through 0 then 1
    digitalWrite(data[display], LOW);    //ditto for data.

    delayMicroseconds(10);
    digitalWrite(cs[display], LOW);     //ditto for cs.
    delayMicroseconds(10);
    for(int x = 0; x < 8;x++)
    {
      for (int y = 0 ; y < 8;y++)
      {
        writeByte(displayPicture[display][x][y], display); //Drawing the grid. x across then down to next y then x across.
        delayMicroseconds(10);
      }
    }
    delayMicroseconds(10);
    digitalWrite(cs[display], HIGH);
  }
}

void addLineTobitmap(int bitmap, int line, byte a,byte b,byte c, byte d, byte e, byte f,byte g, byte h)
{
  bitmaps[bitmap][7][line] = a;
  bitmaps[bitmap][6][line] = b;
  bitmaps[bitmap][5][line] = c;
  bitmaps[bitmap][4][line] = d;
  bitmaps[bitmap][3][line] = e;
  bitmaps[bitmap][2][line] = f;
  bitmaps[bitmap][1][line] = g;
  bitmaps[bitmap][0][line] = h;
}

void drawBitmapToDisplay(int bitmap, int display)
{
    for(int x = 0; x < 8;x++)
    {
      for (int y = 0 ; y < 8;y++)
      {
        //copies the bitmap to be displayed ( in memory )
       displayPicture[display][x][y] = bitmaps[bitmap][x][y];
      }
    } 
      
}

void drawAnimationToDisplay(int bitmap, int targetBitmap, int step, int display)
{
  
  switch (animationStyle)
  {
    case 0:   // slide transition
      for(int x = 0; x < 8-step;x++)
      {
        for (int y = 0 ; y < 8;y++)
        {
         displayPicture[display][x][y] = bitmaps[bitmap][x+step][y];
        }
      }
    
      for(int x = 0; x < step ;x++)
      {
        for (int y = 0 ; y < 8;y++)
        {
         displayPicture[display][8-step+x][y] = bitmaps[targetBitmap][x][y];
        }
      }  
  }
}
