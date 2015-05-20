#include <SoftwareSerial.h>
#include <Adafruit_NeoPixel.h>


#define PIN            6
#define NUMPIXELS      8*32
SoftwareSerial com(8,9) ;
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

static boolean flag = LOW ;
static unsigned char con[3] = {
  0,0,0        } 
;

void setup()
{
  Serial.begin(9600) ;
  pixels.begin();
  pixels.show() ;   
  com.begin(9600) ;
}

void loop()
{

  char buffer[5] = {
    0,                                                                    } 
  ;
  int len = 0 ;

  pixels.show() ;
  flag = LOW ;
  if (Serial.available()) {
    char tem = Serial.read() ;
    if (tem == 0b1110011) {
      int i = 0 ;
      while(1) {
        Serial.write(0xff) ;
        buffer[i] = Serial.read() & 0xff ;
        if (buffer[i] == 0xffffffff) i-- ;
        com.println(int(buffer[i])) ;
        if (buffer[i] == 0b1100101) {
          flag = HIGH ;
          Serial.write(0x01) ;
          len = i ;
          com.println("success") ;
          break ;  
        }
        i++ ;
      }
    }

    if(flag == HIGH) {
      switch (buffer[0]) {
      case '1' :
        pixels.setPixelColor(Pixelpo(buffer[1] + 1, buffer[2] + 1), pixels.Color(con[0], con[1], con[2])) ;
        com.println(Pixelpo(buffer[1] + 1, buffer[2] + 1)) ;
        pixels.show() ;
        break ;
      case '2' :
        if (len == 2) {
          for (int i = 1; i < 4; i++) con[i-1] = buffer[1] ;
        }
        else {
          for (int i = 1; i < len; i++) con[i-1] = buffer[i]  ; 
        }
        com.println(int(len)) ;
        break ;
      case '3' :
        for (int i = 0; i < NUMPIXELS; i++) {
          pixels.setPixelColor(i, pixels.Color(0,0,0)) ;
        }
        com.println("RESET") ;
        break ;
      }
    }
    Serial.flush() ;
  }
}

int Pixelpo(int x, int y)
{ 
  com.println(x) ;
  if (x == 1) return x + y - 2 ;
  else if (x % 2) return 8*(x - 1) + y - 1 ;
  else return 8*x - y ;
}
