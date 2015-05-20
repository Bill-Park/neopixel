import processing.serial.*;
import static javax.swing.JOptionPane.*;

int mag = 45 ;  
boolean flag = false ;
int start = 0 ;
Serial ardu ;
arr arr ;
mouse mou ;
script te1 ;
script te2 ;
set_color led_color ;
packet packet ;

void setup() {
  size(32 * mag + 100, 8 * mag) ;
  arr = new arr() ;
  mou = new mouse() ;
  te1 = new script() ;
  te2 = new script() ;
  led_color = new set_color() ;
  packet = new packet() ;
  led_color.call_color() ;
  ardu = new Serial(this, "COM29", 9600) ;

  background(0) ;
  arr.make() ;
  fill(255) ;
  rect(25, 5, 50, 155, 7) ;

  stroke(255) ;
  fill(0) ;
  rect(30, 160, 40, 40, 7) ;

  fill(led_color.la_co) ;
  rect(33, 163, 34, 34, 7) ;

  fill(255, 255, 100) ;
  rect(25, height - 5, 50, -155, 7) ;

  textAlign(CENTER, CENTER) ;

  textSize(30) ;
  fill(0) ;

  te1.init("COLOR", 0, 50, 20, 'h', 30, 30);
  te1.show() ;
  te2.init("RESET", 0, 50, height - 145, 'h', 30, 30) ;
  te2.show() ;
}

void draw()
{

  if (flag == true) {
    if (mou.state() == 1) {
      mou.calc() ;
      if (led_color.blank == true) {
        stroke(led_color.la_co) ;
        fill(led_color.stro) ;
        rect(mou.x, mou.y, 45, 45) ;
        stroke(255,0,0) ;
        line(mou.x, mou.y, mou.x + 45, mou.y + 45) ;
      } else {
        stroke(led_color.stro) ;      
        fill(led_color.la_co) ;
        rect(mou.x, mou.y, 45, 45) ;
      }
      packet.send(1) ;
    } else if (mou.state() == 2) {
      flag = false ;
      led_color.call_color() ;
      stroke(led_color.stro) ;
      fill(led_color.la_co) ;
      rect(33, 163, 34, 34, 7) ;
      packet.send(2) ;
    } else if (mou.state() == 3) {
      arr.make() ;
      packet.send(3) ;
    }
  }

  if (start == 2) {
    delay(500) ;
    while (true)
    {
      println("false") ;
      if (packet.send(2) == true) {          
        println("success") ;
        break ;
      }
    }
    start = 3 ;
  }

  start++ ;
  //delay(10) ;
}

void mousePressed()
{
  flag = true ;
}
void mouseReleased()
{
  flag = false ;
}

class arr
{
  int rect_co = 255 ;
  int line_co = 0 ;

  void make()
  {
    fill(this.rect_co) ;
    rect(width, height, -32 * 45, -8 * 45) ;
    stroke(this.line_co) ;
    for (int i = 0; i <= 31; i++) line(100 + (width - 100) / 32 * i, 0, 100 + (width - 100) / 32 * i, height) ; //column line
    for (int i = 1; i <= 7; i++) line(width - 32 * 45, height / 8 * i, width, height / 8 * i) ; //row line
  }
}

class mouse
{
  int x ;
  int y ;
  int co ;
  int ro ;

  int state() {
    if ( xpo() >= 100) return 1  ;
    else if (xpo() < 75 && xpo() > 25) {
      if (ypo() > 20 && ypo() < 155) return 2  ;
      else if (ypo() > height - 175 && ypo() < height - 20) return 3  ;
    }
    return 0 ;
  }

  int xpo() {
    return mouseX / 1 ;
  }
  int ypo() {
    return mouseY / 1 ;
  }
  void calc() {
    co = (mou.xpo() - 100) / 45 ;
    ro = mou.ypo() / 45 ;
    x = co * 45 + 100 ;
    y = ro * 45 ;
  }
}

class script
{
  String scr ;
  int[] scr_color = new int[3] ;
  char[] cscr ;
  int xpo, ypo ;
  int inc ;
  int dir ;
  int size ;

  void init(String s, color c, int x, int y) { 
    init(s, c, x, y, 'w', 10, -1 ) ;
  }
  void init(String s, color c, int x, int y, char dir) { 
    init(s, c, x, y, dir, 10, -1) ;
  }
  void init(String s, color c, int x, int y, char dir, int siz) { 
    init(s, c, x, y, dir, siz, -1) ;
  }
  void init(String s, color c, int x, int y, char dir, int siz, int inc)
  {
    textAlign(CENTER, CENTER) ;
    cscr = s.toCharArray() ;
    fill(c) ;
    textSize(siz) ;
    if (inc == -1) inc = siz ;
    xpo = x ;
    ypo = y ;
    this.dir = dir ;
    this.inc = inc ;
  }

  void show()
  {
    for (int i = 0; i < cscr.length; i++) {
      text(cscr[i], xpo, ypo) ;
      if (dir == 'w') xpo += inc ;
      else if (dir == 'h') ypo += inc ;
    }
  }
}

class set_color
{
  color la_co ;
  String in_color ;
  String[] fi_co ;
  char[] se_co ;
  int[] th_co ;
  int len ;
  color stro ;
  int j = 0, h = 0 ;
  boolean blank = false ;
  void call_color()
  {
    in_color = "" ;
    in_color = showInputDialog("Input Color code", "0") ;
    if (in_color == null) in_color = "0" ;
    //println(in_color) ;
    this.convert() ;
  }
  void convert()
  {
    fi_co = split(in_color, ',') ;
    se_co = new char[fi_co.length] ;
    th_co = new int[fi_co.length] ;

    for (int i = 0; i < fi_co.length; i++) {
      se_co = fi_co[i].toCharArray() ;

      for ( h = j; h < th_co.length; h++) {
        th_co[h] = 0 ;
      }
      for ( j = 0; j < se_co.length; j++) {
        th_co[i] += (se_co[j] - 48) * squ(10, (se_co.length - j - 1)) ;
      }
    }
    if (fi_co.length == 1) {
      if (this.th_co[0] > 254) this.th_co[0] = 254 ;
      else if (this.th_co[0] < 0) this.th_co[0] = 0 ;
      if (this.th_co[0] == 0) blank = true ;
      else blank = false ;  
      la_co = color(this.th_co[0]) ;
      stro = color(255 - this.th_co[0]) ;
    } else if (fi_co.length == 3) {
      for (int i = 0; i < 3; i++) {
        if (this.th_co[i] > 254) this.th_co[i] = 254 ;
        else if (this.th_co[i] < 0) this.th_co[i] = 0 ;
      }
      if ((this.th_co[0] == 0) && (this.th_co[1] == 0) && (this.th_co[2] == 0)) blank = true ;
      else blank = false ;
      la_co = color(this.th_co[0], this.th_co[1], this.th_co[2]) ;
      stro = color(254 - this.th_co[0], 254 - this.th_co[1], 254 - this.th_co[2]) ;
    }
  }
  int squ(int x, int many)
  {
    if (many <= 0) return 1 ;
    else {
      int tem = x ;
      for (int i = 0; i < (many - 1); i++) tem *= x ;
      return tem ;
    }
  }
}

class packet
{
  boolean send(int mode)
  {
    ardu.write('s') ;
    switch(mode) {
    case 1 :    
      this.zzz() ;
      ardu.write('1') ;
      this.zzz() ;
      ardu.write(mou.co & 0xff) ;
      this.zzz() ;
      ardu.write(mou.ro & 0xff) ;
      this.zzz() ;
      ardu.write('e') ;
      return this.finish() ;

    case 2 :
      ardu.write('2') ;
      for (int i = 0; i < led_color.fi_co.length; i++) {
        this.zzz() ;
        ardu.write((led_color.th_co[i] & 0xff) << 0) ;
      }
      this.zzz() ;
      ardu.write('e') ;
      return this.finish() ;

    case 3 :
      ardu.write('3') ;
      this.zzz() ;
      ardu.write(0x0f) ;
      this.zzz() ;
      ardu.write('e') ;
      return this.finish() ;
    }
    return true ;
  }
  void zzz()
  {
    long check = millis() ;
    while (true) {
      if (ardu.read() == 0xff) break ;
      if (millis() > check + 50) break ;
    }
  }
  boolean finish()
  {
    long check = millis() ;
    while (true) {
      if (ardu.read() == 0x01) return true ;
      if (millis() > check + 50) return false ;
    }
  }
}

