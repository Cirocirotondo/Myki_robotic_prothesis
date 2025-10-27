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
int MAX_DATA_IN_BUFFER_TO_SHOW_3D = 2000;

int Mmax = 20;  //max number of magnets
int Bmax = 10;  //max number of boards
int Nsensmax = 20*Bmax+1; //number of sensors
int tmr_scale = 100; //tmr at 0.01ms
PImage magTexture;
PShape magnet;
PImage boardTexture;
PShape board;
PVector supp, versX, versY, versZ;
PVector[] orient = new PVector[Mmax];
int _M = 1;
int _B = 1;
int _S = 0; // numero sensori da rimuovere
int _I; // numero iterazione
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
float[] phiBrd = new float[Bmax];
float[] thetaBrd = new float[Bmax];
int[] sens2rem = new int[Nsensmax];
int s2r_ind;

float rotX = 574;
float rotY = -725;
float zoom = 290;
int   traslX = 1000;
int   traslY = 580;
float t_localization, t_iteration, t_abs;
int temp;
int header = 'X';
boolean remove_it;
boolean boards_poses_received = false;
boolean plotta_acq = true;

boolean hideBoard = true;
boolean axis_mode = false;
boolean save_txt = false;
boolean save_csv = false;
boolean rotation = false;
int S_present = 0;
int M_present = 0;
int T_present = 0;
boolean VISUALIZE_3D = true;

boolean message_complete = false;

PrintWriter output;

PVector[] sens = new PVector[Nsensmax];
PVector remote;

PVector[] BrdPos = new PVector[Bmax];
PVector[] BrdOri = new PVector[Bmax];

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
  // size(1920, 1080, P3D);
  // size(800, 600, P3D);
  
  String portName = "COM18";
  //String portName = Serial.list()[port_num];
  print("\n\rSerial ports list: ");
  print(Serial.list());
  print("\n\r");
  print(Serial.list()[port_num]);
  print(" opened\n\r");

  myPort = new Serial(this, Serial.list()[port_num], 921600);
  noStroke();
  magTexture = loadImage("MagNS.png");
  magnet = createShape(SPHERE, 20);
  magnet.setTexture(magTexture);
  boardTexture = loadImage("boardPic.jpg");
  board = createShape(BOX, 640, 15, 300);
  // board = loadShape("bot.obj");
  board.setTexture(boardTexture);

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

  for(int i=0; i<Bmax; i++)
  {
    BrdPos[i] = new PVector();
    BrdOri[i] = new PVector();
  }

  // myPort.clear();
  ask_for_poses();
}

public void draw() {
  message_complete = false;
  delay(1);
  // do {print(' ');} while (myPort.read() != 'L');
  do {delay(1);} while (myPort.read() != 'L');
  // if(myPort.read() == 'L')
  // {
    do {delay(1);} while(myPort.available() < 6);
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
              do {delay(1);} while(myPort.available() < ((_M*6*4)+4));
              // print("\r\n\t#\tX\tY\tZ\trX\trY\trZ");
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
                theta[i] = PVector.angleBetween(supp, versX);
                // print("\n\rMAG" + '\t' + (i+1) + '/' +  _M + '\t' + nf(_X[i],1,2) + '\t' + nf(_Y[i],1,2) + '\t' + nf(_Z[i],1,2) + '\t' + nf(_Rx[i],1,2) + '\t' + nf(_Ry[i],1,2) + '\t' + nf(_Rz[i],1,2) + '\t');
              }
              if(myPort.read() == '\r')
              {
                header = myPort.read();
                if(header == 'b')
                {
                  _B = myPort.read();
                  if(myPort.read() == 'B')
                  {
                    do {delay(1);} while(myPort.available() < ((_B*20*3*4)+4));
                    // print("\r\n\t#\tX\tY\tZ");
                    for(int i=0; i<_B*20; i++)
                    {
                      sens[i].x = read_float();
                      sens[i].y = read_float();
                      sens[i].z = read_float();
                      phiSens[i] = PVector.angleBetween(sens[i], versZ);
                      supp = sens[i].copy();
                      supp.z = 0;
                      thetaSens[i] = PVector.angleBetween(supp, versX);
                      // print("\n\rSNS" + '\t' + (i+1) + '/' +  (_B*20) + "\t" + nf(sens[i].x,2,2) + "\t" + nf(sens[i].y,2,2) + "\t" + nf(sens[i].z,2,2) + "\t\t");
                    }
                    if(myPort.read() == '\r')
                    {
                      if(myPort.read() == 's')
                      {
                        _S = myPort.read();
                        if(myPort.read() == 'S')
                        {
                          do {delay(1);} while(myPort.available() < (_S+32));
                          for(int i=0; i<_S; i++)
                          {
                            sens2rem[i] = myPort.read();
                            // print("\n\rS2R" + "\t\t" + sens2rem[i] + '\t');
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
                              thetaRem = PVector.angleBetween(supp, versX);
                              // print("\n\rRMT" + "\t\t" + nf(remote.x,2,2) + '\t' + nf(remote.y,2,2) + '\t' + nf(remote.z,2,2) + '\t');
                              myPort.read(); // '/r'
                              header = myPort.read();
                            }
                          }
                        }
                      }
                    }
                  }
                }
                if(header == 'T')
                {
                  t_localization = read_float();
                  t_iteration = read_float();
                  t_abs = read_float();
                  _I = read_int32();
                  // print("\n\rLocalization time:" + '\t' + nf(t_localization*1000,0,3) + " ms\t");
                  // print("\n\rIteration time:" + '\t' + nf(t_iteration*1000,0,3) + " ms\t--> Frequency:\t" + nf((1/t_iteration),0,2) + " Hz\t");
                  // print("\n\rAbsolute time:" + '\t' + nf(t_abs,0,3) + " s\t");
                  if(myPort.read() == '\r')
                  {
                    header = myPort.read();
                    if(header == 'P')
                    {
                      do {delay(1);} while(myPort.available() < ((_B*6*4)+5));
                      for(int i=0; i<_B; i++)
                      {
                        BrdPos[i].x = read_float();
                        BrdPos[i].y = read_float();
                        BrdPos[i].z = read_float();
                        BrdOri[i].x = read_float();
                        BrdOri[i].y = read_float();
                        BrdOri[i].z = read_float();
                      }
                      print('x');
                      boards_poses_received = true;
                      stop_poses_cmd();
                      myPort.read(); // '/r'
                      header = myPort.read();
                    }
                    else if(!boards_poses_received)
                    {
                      ask_for_poses();
                    }
                    if(header == 'E')
                    {
                      if(myPort.read() == 'N')
                      {
                        if(myPort.read() == 'D')
                        {
                          if(myPort.read() == '\r')
                          {
                            message_complete = true;
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

  //write to csv file
  if(save_csv && message_complete)
  {
    output.println(_M + ", " + _B + ", " + _S + ", " + _I);  // #magnets, #boards, #sensors2remove, #iteration
    // print("\n\n\r------------------ Iteration number: " + _I + " ------------------");
    // print("\r\n\t#\tX\tY\tZ\trX\trY\trZ");
    for(int i=0; i<_M; i++)
    {
      output.println(_X[i] + ", " + _Y[i] + ", " + _Z[i] + ", " + _Rx[i] + ", " + _Ry[i] + ", " + _Rz[i]); //pose MM: pX,pY,pZ,rX,rY,rZ per _M magneti
      // print("\n\rMAG" + '\t' + (i+1) + '/' +  _M + '\t' + nf(1000*_X[i],1,2) + " mm\t" + nf(1000*_Y[i],1,2) + " mm\t" + nf(1000*_Z[i],1,2) + " mm\t" + nf(_Rx[i],1,2) + '\t' + nf(_Ry[i],1,2) + '\t' + nf(_Rz[i],1,2) + '\t');
    }
    // print("\r\n\t#\tX\tY\tZ");
    for(int i=0; i<_B*20; i++)
    {
      output.println(sens[i].x + ", " + sens[i].y + ", " + sens[i].z);  //acq sensori: X,Y,Z per (_B*20) sensori
      // print("\n\rSNS" + '\t' + (i+1) + '/' +  (_B*20) + "\t" + nf(sens[i].x,2,2) + "\t" + nf(sens[i].y,2,2) + "\t" + nf(sens[i].z,2,2) + "\t\t");
    }
    for(int i=0; i<_S; i++)
    {
      output.println(sens2rem[i]); //indic* sensor* da rimuovere, uno per riga (_S in totale)
      // print("\n\rS2R" + "\t\t" + sens2rem[i] + '\t');
    }
    output.println(remote.x + ", " + remote.y + ", " + remote.z);  //acq sensore remoto: X,Y,Z
    // print("\n\rRMT" + "\t\t" + nf(remote.x,2,2) + '\t' + nf(remote.y,2,2) + '\t' + nf(remote.z,2,2) + '\t');
    output.println(t_localization + ", " + t_iteration + ", " + t_abs);  //tempi: t di localizzazione, t totale dell'iterazione, t assoluto dall'accensione. Tutto in secondi.
    // print("\n\rLocalization time:" + '\t' + nf(t_localization*1000,0,3) + " ms\t");
    // print("\n\rIteration time:" + '\t' + nf(t_iteration*1000,0,3) + " ms\t--> Frequency:\t" + nf((1/t_iteration),0,2) + " Hz\t");
    // print("\n\rAbsolute time:" + '\t' + nf((int)(t_abs/60),1,0) + " minuti e " + nf((int)(t_abs%60),1,0) + " secondi\t");
    output.println(myPort.available() + "\n");  //dati nel buffer
    // print("\n\rDati nel buffer: " + '\t' + myPort.available() + '\t');
  }


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

  if(message_complete && VISUALIZE_3D && boards_poses_received)
  {
    lights(); // turn on lights
    background(180, 180, 180);
    fill(0);
    textSize(16);
    textAlign(LEFT, TOP);
    s2r_ind = 0;

    if(save_csv)
    {
      textAlign(RIGHT, BOTTOM);
      fill(255, 0, 0);
      textSize(16);
      text("Saving to CSV file", width-10, height-30);
    }
    textAlign(LEFT, BOTTOM);
    fill(0, 180, 0);
    textSize(16);
    text("Bytes in the buffer: " + nf(myPort.available(),1,0), 10, height-30);

    if(rotation)
    {
      rotY++;
    }

    textAlign(RIGHT, TOP);
    fill(0, 0, 0);
    textSize(16);
    text("Algorithm computation time: " +  nf(t_localization*1000,0,2) + " ms\n\rIteration time: " + '\t' + nf(t_iteration*1000,0,2) + " ms --> Frequency: " + nf((1/t_iteration),0,2) + " Hz\n\rAbsolute time: " + '\t' + nf((int)(t_abs/3600),1,0) + "h " + nf((int)((t_abs/60)%60),1,0) + "m " + nf((int)(t_abs%60),1,0) + "s\t\n# magnets: " + _M, width-10, 10);

    translate(traslX, traslY, -zoom);
    rotateX(rotX/100);
    rotateY(rotY/100);

    pushMatrix();   // posizionamento schede
    fill(80, 150, 30);

    for(int brd = 0; brd < _B; brd++)
    {
      pushMatrix();   // posizione board shape
      translate(-BrdPos[brd].y*10, -BrdPos[brd].z*10, -BrdPos[brd].x*10);

      rotateZ(-radians(BrdOri[brd].x));
      rotateX(-radians(BrdOri[brd].y));
      rotateY(-radians(BrdOri[brd].z));

      translate(-165, +15, 0);
      if(hideBoard)
      {
        noFill();
        stroke(0);
        box(640, 15, 300);
      }
      else
      {
        shape(board);
      }
      popMatrix();    // posizione board shape

      for(int i=0; i<20; i++)
      {
        if(((brd*20)+i == sens2rem[s2r_ind]) && (s2r_ind < _S))
        {
          remove_it = true;
          s2r_ind++;
        }
        else
        {
          remove_it = false;
        }
        pushMatrix();   // campo sui sensori
        translate(-BrdPos[brd].y*10, -BrdPos[brd].z*10, -BrdPos[brd].x*10);
        rotateZ(-radians(BrdOri[brd].x));
        rotateX(-radians(BrdOri[brd].y));
        rotateY(-radians(BrdOri[brd].z));
        translate(sp[i*3+1]*-10, sp[i*3+2]*10, sp[i*3+0]*-10);
        if(remove_it)
        {
          fill(255, 0, 0);
        }
        else
        {
          if(plotta_acq)
          {
            fill(0, sens[i+(brd*20)].mag()*300, 0);
          }
          else
          {
            fill(0, 0, 0);
          }
        }
        stroke(125);
        if(hideBoard)
        {
          noStroke();
          sphere(10);
        }
        else
        {
          pushMatrix();   // testo sui cubetti
          box(20);
          fill(255, 0, 255);
          textSize(15);
          translate(0, -11);
          rotateX(PI/2);
          textAlign(CENTER, CENTER);
          text((i+1), 0 , -3);
          popMatrix();     // testo sui cubetti
        }
        if(!remove_it && plotta_acq)
        {
          rotateY(radians(BrdOri[brd].z));
          rotateX(radians(BrdOri[brd].y));
          rotateZ(radians(BrdOri[brd].x));
          if (sens[i+(brd*20)].y > 0)
          rotateY(thetaSens[i+(brd*20)]);
          else
          rotateY(-thetaSens[i+(brd*20)]);
          rotateX(phiSens[i+(brd*20)]);
          stroke(255, 0, 0);
          line(0, -30, 0, 0, 0, 0);
          stroke(0, 0, 255);
          line(0, 0, 0, 0, 30, 0);
        }
        popMatrix();     // campo sui sensori
      }
    }

    if(plotta_acq)
    {
      // remote sensor
      if (remote.y > 0)
      rotateY(thetaRem);
      else
      rotateY(-thetaRem);
      rotateX(phiRem);
      stroke(255, 0, 0);
      line(0, -10, 0, 0, 0, 0);
      stroke(0, 0, 255);
      line(0, 0, 0, 0, 10, 0);
    }

    popMatrix();    // posizionamento schede

    for(int i=0; i<_M; i++)
    {
      pushMatrix();   // posizionamento magneti
      translate(-_Y[i]*10000, -_Z[i]*10000, -_X[i]*10000); // Position the sphere
      fill(0);
      textSize(32);
      textAlign(LEFT, TOP);
      textSize(16);
      text("MM" + (i+1), 12 , 12);
      stroke(255, 255, 0);
      //line(-10000, 0, 0, 10000, 0, 0);
      // line(0, (_Z[i]*10000), 0, 0, 0, 0);
      //line(0, 0, -10000, 0, 0, 10000);
      if (orient[i].y > 0)
      rotateY(theta[i]);
      else
      rotateY(-theta[i]);
      rotateX(phi[i]);
      stroke(255, 0, 0);
      line(0, -50, 0, 0, 0, 0);
      stroke(0, 0, 255);
      line(0, 0, 0, 0, 50, 0);
      shape(magnet);
      popMatrix();  // posizionamento magneti
    }
  }
  if(!VISUALIZE_3D)
  {
    stroke(180, 180, 180);
    fill(180, 180, 180);
    rect(5, height-50, 300, 20);
    textAlign(LEFT, BOTTOM);
    fill(180, 0, 0);
    textSize(16);
    text("Bytes in the buffer: " + nf(myPort.available(),1,0) + " - Data visualization stopped to go faster", 10, height-30);
  }

  if(myPort.available() < MAX_DATA_IN_BUFFER_TO_SHOW_3D)
  {
    VISUALIZE_3D = true;
  }
  else
  {
    VISUALIZE_3D = false;
    print('-');
  }

  if(!boards_poses_received)
  {
     ask_for_poses();
  }
}


public void keyPressed(){
  if(key == CODED) {
    // pts
    if (keyCode == UP) {
      if (true){
        traslY += 20;
      }
    }
    else if (keyCode == DOWN) {
      if (true){
        traslY -= 20;
      }
    }
    // extrusion length
    if (keyCode == LEFT) {
      if (true){
        traslX += 20;
      }
    }
    else if (keyCode == RIGHT) {
      if (true){
        traslX -= 20;
      }
    }
  }
  // lathe radius
  if (key =='h'){
    if (true){
      hideBoard = !hideBoard;
    }
  }
  if (key =='a'){
    if (true){
      axis_mode = !axis_mode;
    }
  }
  if (key =='+'){
    if (true){
      increase_M_cmd();
    }
  }
  if (key =='-'){
    if (true){
      decrease_M_cmd();
    }
  }

  if (key =='B'){
    if (true){
      increase_B_cmd();
    }
  }
  if (key =='b'){
    if (true){
      decrease_B_cmd();
    }
  }

  if (key =='A'){
    if (true){
      ask_acq_send();
      ask_for_poses();
    }
  }
  if (key =='a'){
    if (true){
      stop_acq_send();
    }
  }

  if (key =='0' || key =='r'){
    if (true){
      rotX = 574;
      rotY = -725;
      zoom = 290;
      traslX = 1000;
      traslY = 580;
    }
  }
  if(key == '1')
  {
    rotX = 616.0f;
    rotY = -785.0f;
    zoom = 270.0f;
    traslX = 960;
    traslY = 540;
  }
  if(key == '2')
  {
    rotX= 628.0f;
    rotY= -943.0f;
    zoom= 270.0f;
    traslX= 820;
    traslY= 540;
  }
  if(key == '3')
  {
    rotX= 628.0f;
    rotY= -1099.0f;
    zoom= 530.0f;
    traslX= 920;
    traslY= 520;
  }
  if(key == '4')
  {
    rotX= 628.0f;
    rotY= -628.0f;
    zoom= 270.0f;
    traslX= 1060;
    traslY= 540;
  }
  if(key == '5')
  {
    rotX= 472.0f;
    rotY= -785.0f;
    zoom= 215.0f;
    traslX= 960;
    traslY= 700;
  }
  if(key == '6')
  {
    rotX= 159.0f;
    rotY= -785.0f;
    zoom= 215.0f;
    traslX= 960;
    traslY= 380;
  }

  if (key == '?')
  {
    print("\n\rrotX= " + rotX + ';');
    print("\n\rrotY= " + rotY + ';');
    print("\n\rzoom= " + zoom + ';');
    print("\n\rtraslX= " + traslX + ';');
    print("\n\rtraslY= " + traslY + ";\n\r");
  }
  if (key =='o'){
    if (true){
      rotation = !rotation;
    }
  }
  if ((key =='c') || (key =='C'))
  {
    if(!save_csv)
    {
      save_csv = true;
      // write to txt file
      output = createWriter("MM_csv_record.csv");
      output.println("FILE STRUCTURE:");
      output.println("-------------------------------------------------------------------------------------------------------");
      output.println("#magnets, #boards, #sensors2remove, #iteration");
      output.println("for(mag=0; mag<#magnets; mag++)");
      output.println("  pos_x[mag], pos_y[mag], pos_z[mag], rot_x[mag], rot_y[mag], rot_z[mag]");
      output.println("for(sens=0; sens<(#boards*20); sens++)");
      output.println("  field_x[sens], field_y[sens], field_z[sens]");
      output.println("for(i=0; i<#sensors2remove; i++)");
      output.println("  sensor_index");
      output.println("remoteSensor_x, remoteSensor_y, remoteSensor_z");
      output.println("t_localization,  t_iteration,  t_absolute");
      output.println("data_in_buffer");
      output.println("-------------------------------------------------------------------------------------------------------\n");
    }
  }
  if ((key =='x') || (key =='X'))
  {
    if(save_csv)
    {
      save_csv = false;
      output.flush(); // Writes the remaining data to the file
      output.close(); // Finishes the file
    }
  }
}

public float read_float()
{
  int temp;
  temp = (myPort.read());
  temp += (myPort.read()) << 8;
  temp += (myPort.read()) << 16;
  temp += (myPort.read()) << 24;
  return Float.intBitsToFloat(temp);
}

public int read_int32()
{
  int temp;
  temp = (myPort.read());
  temp += (myPort.read()) << 8;
  temp += (myPort.read()) << 16;
  temp += (myPort.read()) << 24;
  return temp;
}

public void plot_axis()
{
  stroke(255, 0, 0);
  line(100, 0, 0, 0, 0, 0);
  stroke(0, 255, 0);
  line(0, 100, 0, 0, 0, 0);
  stroke(0, 0, 255);
  line(0, 0, 100, 0, 0, 0);
}

public void ask_for_poses()
{
  myPort.write('B');
  myPort.write('1');
}

public void stop_poses_cmd()
{
  myPort.write('B');
  myPort.write('0');
}

public void ask_acq_send()
{
  myPort.write('A');
  myPort.write('1');
  plotta_acq = true;
}

public void stop_acq_send()
{
  myPort.write('A');
  myPort.write('0');
  plotta_acq = false;
}

public void increase_M_cmd()
{
  myPort.write('M');
  myPort.write('+');
}

public void decrease_M_cmd()
{
  myPort.write('M');
  myPort.write('-');
}

public void increase_B_cmd()
{
  myPort.write('B');
  myPort.write('+');
}

public void decrease_B_cmd()
{
  myPort.write('B');
  myPort.write('-');
}
  public void settings() {  size(displayWidth, displayHeight, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Localizer_v2p1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
