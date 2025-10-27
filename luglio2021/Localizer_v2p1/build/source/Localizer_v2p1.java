import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Localizer_v2p1 extends PApplet {


Serial myPort;  // Create object from Serial class
int port_num = 3;

int Mmax = 9;  //max number of magnets
int Bmax = 4;  //max number of boards
int Nsensmax = 20*Bmax+1; //number of sensors
int tmr_scale = 100; //tmr at 0.01ms
PImage magTexture;
PShape magnet;
PImage boardTexture;
PShape board;
PVector supp, versX, versY, versZ;
PVector[] orient = new PVector[Mmax];
int _M = Mmax;
int _B = Bmax;
int _S = 0; // numero sensori da rimuovere
float[] _X = new float[Mmax];
float[] _Y = new float[Mmax];
float[] _Z = new float[Mmax];
float[] _Rx = new float[Mmax];
float[] _Ry = new float[Mmax];
float[] _Rz = new float[Mmax];
float[] phi = new float[Mmax];
float[] theta = new float[Mmax];
float[] magnitude = new float[Mmax];

float[] phiSens = new float[Nsensmax];
float[] thetaSens = new float[Nsensmax];
float phiRem, thetaRem;
int[] sens2rem = new int[Nsensmax];

float rotX = 573;
float rotY = -657;
float zoom = 250;
int traslX;
int traslY;
float t_localization, t_iteration;
int temp;
int header = 'X';

boolean hideBoard = false;
boolean axis_mode = false;
boolean save_txt = false;
boolean save_csv = false;
boolean rotation = false;
int S_present = 0;
int M_present = 0;
int T_present = 0;

boolean message_complete = false;

PrintWriter output;

PVector[] sens = new PVector[Nsensmax];
PVector remote;
float[] sp = { -13.5f,   -13.5f,   0.5f,   // 1
               -13.5f,   -04.5f,   0.5f,   // 2
               -13.5f,   +04.5f,   0.5f,   // 3
               -13.5f,   +13.5f,   0.5f,   // 4
               -13.5f,   +22.5f,   0.5f,   // 5
               -04.5f,   -13.5f,   0.5f,   // 6
               -04.5f,   -04.5f,   0.5f,   // 7
               -04.5f,   +04.5f,   0.5f,   // 8
               -04.5f,   +13.5f,   0.5f,   // 9
               -04.5f,   +22.5f,   0.5f,   // 10
               +04.5f,   -13.5f,   0.5f,   // 11
               +04.5f,   -04.5f,   0.5f,   // 12
               +04.5f,   +04.5f,   0.5f,   // 13
               +04.5f,   +13.5f,   0.5f,   // 14
               +04.5f,   +22.5f,   0.5f,   // 15
               +13.5f,   -13.5f,   0.5f,   // 16
               +13.5f,   -04.5f,   0.5f,   // 17
               +13.5f,   +04.5f,   0.5f,   // 18
               +13.5f,   +13.5f,   0.5f,   // 19
               +13.5f,   +22.5f,   0.5f};  // 20


public void setup() {
  
  //size(displayWidth, displayHeight, P3D);
  String portName = "COM18";
  //String portName = Serial.list()[port_num];
  print("\n\rSerial ports list: ");
  print(Serial.list());
  print("\n\r");
  print(Serial.list()[port_num]);
  print(" opened\n\r");

  myPort = new Serial(this, portName, 921600/2);
  noStroke();
  // magTexture = loadImage("MagNS.png");
  magnet = createShape(SPHERE, 20);
  // magnet.setTexture(magTexture);
  // boardTexture = loadImage("boardPic.jpg");
  board = createShape(BOX, 1215, 15, 380);
  // board.setTexture(boardTexture);

  traslX = round(width/2);
  traslY = round(height*0.66f);

  for(int i=0; i<Mmax; i++)
  {
    orient[i] = new PVector();
  }
  supp = new PVector(0, 0, 1);
  versX = new PVector(1, 0, 0);
  versY = new PVector(0, 1, 0);
  versZ = new PVector(0, 0, 1);

  for(int i=0; i<Nsensmax; i++)
  {
    sens[i] = new PVector();
  }
  remote = new PVector();
}

public void draw() {
  message_complete = false;
  if(myPort.available() >= 7)
  {
    if(myPort.read() == 'L')
    {
      if(myPort.read() == 'O')
      {
        if(myPort.read() == 'C')
        {
          if(myPort.read() == '\r')
          {
            if(myPort.read() == 'm')
            {
              _M = myPort.read();
              if(myPort.read() == 'M')
              {
                do {} while(myPort.available() < ((_M*6*4)+4));
                print("\r\n\t#\tX\tY\tZ\trX\trY\trZ");
                for(int i=0; i<_M; i++)
                {
                  _X[i]  = read_float();
                  _Y[i]  = read_float();
                  _Z[i]  = read_float();
                  _Rx[i] = read_float();
                  _Ry[i] = read_float();
                  _Rz[i] = read_float();

                  orient[i].x = _Rx[i];
                  orient[i].y = _Ry[i];
                  orient[i].z = _Rz[i];
                  magnitude[i] = orient[i].mag();
                  orient[i].normalize();
                  phi[i] = PVector.angleBetween(orient[i], versZ);
                  supp = orient[i].copy();
                  supp.z = 0;
                  theta[i] = PVector.angleBetween(supp, versX) + PI;
                  print("\n\rMAG" + '\t' + (i+1) + '/' +  _M + '\t' + nf(_X[i],1,2) + '\t' + nf(_Y[i],1,2) + '\t' + nf(_Z[i],1,2) + '\t' + nf(_Rx[i],1,2) + '\t' + nf(_Ry[i],1,2) + '\t' + nf(_Rz[i],1,2) + '\t');
                }
                if(myPort.read() == '\r')
                {
                  if(myPort.read() == 'b')
                  {
                    _B = myPort.read();
                    if(myPort.read() == 'B')
                    {
                      print("\r\n\t#\tX\tY\tZ");
                      do {} while(myPort.available() < ((_B*3*4)+4));
                      for(int i=0; i<_B*20; i++)
                      {
                        sens[i].x = read_float();
                        sens[i].y = read_float();
                        sens[i].z = read_float();
                        phiSens[i] = PVector.angleBetween(sens[i], versZ);
                        supp = sens[i].copy();
                        supp.z = 0;
                        thetaSens[i] = PVector.angleBetween(supp, versX) + PI;
                        print("\n\rSNS" + '\t' + (i+1) + '/' +  (_B*20) + "\t" + nf(sens[i].x,2,2) + "\t" + nf(sens[i].y,2,2) + "\t" + nf(sens[i].z,2,2) + "\t\t");
                      }
                      if(myPort.read() == '\r')
                      {
                        if(myPort.read() == 's')
                        {
                          _S = myPort.read();
                          if(myPort.read() == 'S')
                          {
                            do {} while(myPort.available() < (_S+29));
                            for(int i=0; i<_S; i++)
                            {
                              sens2rem[i] = myPort.read();
                              print("\n\rS2R" + "\t\t" + sens2rem[i] + '\t');
                            }
                            if(myPort.read() == '\r')
                            {
                              if(myPort.read() == 'R')
                              {
                                remote.x = read_float();
                                remote.y = read_float();
                                remote.z = read_float();
                                phiRem = PVector.angleBetween(remote, versZ);
                                supp = remote.copy();
                                supp.z = 0;
                                thetaRem = PVector.angleBetween(supp, versX) + PI;
                                print("\n\rRMT" + "\t\t" + nf(remote.x,2,2) + '\t' + nf(remote.y,2,2) + '\t' + nf(remote.z,2,2) + '\t');
                                if(myPort.read() == '\r')
                                {
                                  if(myPort.read() == 'T')
                                  {
                                    t_localization = read_float();
                                    t_iteration = read_float();
                                    print("\n\rLocalization time:" + '\t' + nf(t_localization,0,3) + '\t');
                                    print("\n\rIteration time:" + '\t' + nf(t_iteration,0,3) + "\t--> Frequency:\t" + nf((1/t_iteration),0,2) + '\t');
                                    if(myPort.read() == '\r')
                                    {
                                      if(myPort.read() == 'E')
                                      {
                                        if(myPort.read() == 'N')
                                        {
                                          if(myPort.read() == 'D')
                                          {
                                            if(myPort.read() == '\r')
                                            {
                                              message_complete = true;
                                              myPort.clear();
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  else
  {
    print("-");
  }

  if(message_complete)
  {
    print("\r\n\t---------------------------------------------------------------------------------\r\n\t");
  }
  // else
  // {
  //   // print("\r\n\tPORCATROIAAAAAAAAAAAAAAAAA!!!\r\n\t");
  //   // myPort.clear();
  // }


    // //write to text
    // if(save_txt)
    // {
    //   output.println("N_sensors:\t" + Nsens + "\tN_magnets:\t" + _M + '\t');
    //   for(int i=0; i<Nsens; i++)
    //     // output.println("Sns" + '\t' + (i+1) + '/' + Nsens + '\t' + sens[i].x/10000 + '\t' + sens[i].y/10000 + '\t' + sens[i].z/10000 + '\t');
    //     output.println("Sns" + '\t' + (i+1) + '\t' + sens[i].x + '\t' + sens[i].y + '\t' + sens[i].z + '\t');
    //   for(int i=0; i<_M; i++)
    //     // output.println("Mag" + '\t' + (i+1) + '/' +  _M + '\t' + _X[i]/10000 + '\t' + _Y[i]/10000 + '\t' + _Z[i]/10000 + '\t' + _Rx[i]/10000 + '\t' + _Ry[i]/10000 + '\t' + _Rz[i]/10000 + '\t');
    //     output.println("Mag" + '\t' + (i+1) + '\t' + _X[i] + '\t' + _Y[i] + '\t' + _Z[i] + '\t' + _Rx[i] + '\t' + _Ry[i] + '\t' + _Rz[i] + '\t');
    //   // output.println("Computation time [ms]: " + t_stop + " - " + t_start + " = " + (t_stop-t_start) + '\t');
    //   // output.println("Time from previous operation [ms]: " + t_stop + " - " + t_stop_old + " = " + (t_stop-t_stop_old) + '\t');
    //   output.println("Algorithm computation time  :\t" + (double)t_stop/tmr_scale + "\t-\t" + (double)t_start/tmr_scale + "\t=\t" + (double)(t_stop-t_start)/tmr_scale + "\t[ms]\t");
    //   output.println("Time from previous operation:\t" + (double)t_stop/tmr_scale + "\t-\t" + (double)t_stop_old/tmr_scale + "\t=\t" + (double)(t_stop-t_stop_old)/tmr_scale + "\t[ms]\t");
    //   output.println("\n");
    // }
    //
    // if(save_csv)
    // {
    //   for(int i=0; i<Nsens; i++)
    //     output.println(sens[i].x + "," + sens[i].y + "," + sens[i].z + "," + '0' + "," + Nsens + "," + i);  //acq sensori: X,Y,Z per Nsens righe + '0' + Nsens + sensID
    //   for(int i=0; i<_M; i++)
    //     output.println(_X[i] + "," + _Y[i] + "," + _Z[i] + "," + _Rx[i] + "," + _Ry[i] + "," + _Rz[i]); //pose MM: pX,pY,pZ,rX,rY,rZ per _M magneti
    //   output.println(t_stop + "," + t_start + "," + (t_stop-t_start) + "," + '0' + "," + _M + "," + tmr_scale);  // stop, start, diff, 0, _M, tmr_scale
    // }


  if(mousePressed)
  {
    if(mouseX < width/10)
      rotY++;
    else if(mouseX > width*9/10)
      rotY--;
    else if(mouseY < height/10)
      rotX--;
    else if(mouseY > height*8/10)
      rotX++;
    else if(mouseY < height/2)
      zoom -= 5;
    else if(mouseY > height/2)
      zoom += 5;
  }

//
//
//   lights(); // turn on lights
//   background(180, 180, 180);
//
//   fill(0);
//   textSize(16);
//   textAlign(LEFT, TOP);
//   for (int i=0; i<_M; i++)
//   {
//     text("MM" + (i+1) + "\nX = " + _X[i]*1000 + "mm\nY = " + _Y[i]*1000 + "mm\nZ = " + _Z[i]*1000 + "mm\n", 10, 120*i);
//     text("\nphi = " + phi[i] + "\ntheta = " + theta[i] + "\nmagnitude = " + magnitude[i] + "\n", 200, 120*i);
//     // text("MAG" + (i+1) + "\nX = " + _X[i]/10 + "mm\nY = " + _Y[i]/10 + "mm\nZ = " + _Z[i]/10 + "mm\n" , 10, 130*i);
//   }
//   // textSize(16);
//   if(save_txt)
//   {
//     textAlign(RIGHT, BOTTOM);
//     fill(255, 0, 0);
//     textSize(32);
//     text("Saving on verbose TXT file", width-10, height-10);
//   }
//   if(save_csv)
//   {
//     textAlign(RIGHT, BOTTOM);
//     fill(255, 0, 0);
//     textSize(32);
//     text("Saving on CSV file", width-10, height-10);
//   }
//   if(rotation)
//   {
//     rotY++;
//   }
//
//   textAlign(RIGHT, TOP);
//   fill(0, 0, 0);
//   textSize(18);
//   text("Algorithm computation time: " + (float)(t_stop-t_start)/tmr_scale + " [ms]\n\r" + "Output frequency: " + 1/((float)(t_stop-t_stop_old)/tmr_scale/1000) + " [Hz]\n\r" , width-10, 10);
//
//   translate(traslX, traslY, -zoom);
//   rotateX(rotX/100);
//   rotateY(rotY/100);
//
// // print(traslX);
// // print('\t');
// // print(traslY);
// // print('\t');
// // print(zoom);
// // print('\n');
//
//   pushMatrix();
//   fill(80, 150, 30);
//   if(hideBoard)
//   {
//     noFill();
//     stroke(0);
//     box(1215, 15, 380);
//   }
//   else
//   {
//     shape(board);
//   }
//
//   translate(1215/2, -7.5, 380/2);
//
//   for(int i=0; i<Nsens; i++)
//   {
//     pushMatrix();
//     translate(sp[i*3+1]*-10, sp[i*3+2]*10, sp[i*3+0]*-10);
//     // fill((abs(sens[i].y))/8, (abs(sens[i].z))/8, (abs(sens[i].x))/8);
//     fill(0, sens[i].mag()*300, 0);
//     // fill(0, sens[i].mag()/30, 0);
//     // print(i+'\t'+'-'+'\t');
//     // print(sens[i].mag());
//     // print('\n');
//     stroke(125);
//     if(hideBoard)
//     {
//       noStroke();
//       sphere(10);
//     }
//     else
//     {
//       pushMatrix();
//       box(20);
//       fill(255, 0, 255);
//       textSize(15);
//       translate(0, -11);
//       rotateX(PI/2);
//       textAlign(CENTER, CENTER);
//       text((i+1), 0 , -3);
//       popMatrix();
//     }
//
//     if (sens[i].y > 0)
//     rotateY(thetaSens[i]);
//     else
//     rotateY(-thetaSens[i]);
//     rotateX(phiSens[i]);
//     stroke(255, 0, 0);
//     line(0, -30, 0, 0, 0, 0);
//     stroke(0, 0, 255);
//     line(0, 0, 0, 0, 30, 0);
//
//     popMatrix();
//   }
//
//   for(int i=0; i<_M; i++)
//   {
//     pushMatrix();
//     translate(-_Y[i]*10000, +_Z[i]*10000, -_X[i]*10000); // Position the sphere
//     fill(0);
//     textSize(32);
//     textAlign(LEFT, TOP);
//     textSize(16);
//     text("MM" + (i+1), 12 , 12);
//     stroke(255, 255, 0);
//     //line(-10000, 0, 0, 10000, 0, 0);
//     line(0, -(_Z[i]*10000), 0, 0, 0, 0);
//     //line(0, 0, -10000, 0, 0, 10000);
//     if (orient[i].y > 0)
//     rotateY(theta[i]);
//     else
//     rotateY(-theta[i]);
//     rotateX(phi[i]);
//     stroke(255, 0, 0);
//     line(0, -50, 0, 0, 0, 0);
//     stroke(0, 0, 255);
//     line(0, 0, 0, 0, 50, 0);
//     shape(magnet);
//     popMatrix();
//   }
//
//   popMatrix();
// }
//
//
// void keyPressed(){
//   if(key == CODED) {
//     // pts
//     if (keyCode == UP) {
//       if (true){
//         traslY += 20;
//       }
//     }
//     else if (keyCode == DOWN) {
//       if (true){
//         traslY -= 20;
//       }
//     }
//     // extrusion length
//     if (keyCode == LEFT) {
//       if (true){
//         traslX += 20;
//       }
//     }
//     else if (keyCode == RIGHT) {
//       if (true){
//         traslX -= 20;
//       }
//     }
//   }
//   // lathe radius
//   if (key =='h'){
//     if (true){
//       hideBoard = !hideBoard;
//     }
//   }
//   if (key =='a'){
//     if (true){
//       axis_mode = !axis_mode;
//     }
//   }
//   if (key =='+'){
//     if (true){
//       zoom -= 20;
//     }
//   }
//   if (key =='-'){
//     if (true){
//       zoom += 20;
//     }
//   }
//   if (key =='r'){
//     if (true){
//       rotX = 573;
//       rotY = -657;
//       zoom = 250;
//       traslX = round(width/2);
//       traslY = round(height*0.66);
//     }
//   }
//   if (key =='o'){
//     if (true){
//       rotation = !rotation;
//       traslX = round(width/2);
//       traslY = round(height*0.66);
//     }
//   }
//   if (key =='t'){
//     if (!save_csv){
//       save_txt = !save_txt;
//       if (save_txt)
//       {
//         // write to txt file
//         output = createWriter("MM_record.txt");
//       }
//       else
//       {
//         output.flush(); // Writes the remaining data to the file
//         output.close(); // Finishes the file
//       }
//     }
//   }
//   if (key =='c'){
//     if (!save_txt){
//       save_csv = !save_csv;
//       if (save_csv)
//       {
//         // write to txt file
//         output = createWriter("MM_csv_record.csv"); //FORSE VA SALVATO IN TXT E CAMBIATO DOPO
//         output.println(Nsens + "," + _M + "," + '0' + "," + S_present + "," + M_present + "," + T_present); //salva nella prima riga: #sensori, #magneti, 0 + presenza dati: sensori, magneti, tempi + 99
//       }
//       else
//       {
//         output.flush(); // Writes the remaining data to the file
//         output.close(); // Finishes the file
//       }
//     }
//   }
}

public float read_float()
{
  int temp;
  // temp = (myPort.read()) << 24;
  // temp += (myPort.read()) << 16;
  // temp += (myPort.read()) << 8;
  // temp += myPort.read();
  temp = (myPort.read());
  temp += (myPort.read()) << 8;
  temp += (myPort.read()) << 16;
  temp += (myPort.read()) << 24;
  return Float.intBitsToFloat(temp);
}
  public void settings() {  size(1920, 1080, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Localizer_v2p1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
