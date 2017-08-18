#!/usr/bin/ruby
require "adafruit_charlcd"
#Setting up the pin numbering for the raspberry pi
RPi::GPIO.set_numbering :bcm
# Raspberry Pi configuration:
lcd_rs = 27  # Change this to pin 21 on older revision Raspberry Pi's
lcd_en = 22
lcd_d4 = 25
lcd_d5 = 24
lcd_d6 = 23
lcd_d7 = 18
lcd_red   = 4
lcd_green = 17
lcd_blue  = 7  # Pin 7 is CE1
# Define LCD column and row size for 16x2 LCD.
lcd_columns = 16
lcd_rows    = 2

# Alternatively specify a 20x4 LCD.
# lcd_columns = 20
# lcd_rows    = 4

# Initialize the LCD using the pins above.
lcd = Adafruit_RGBCharLCD.new(lcd_rs, lcd_en, lcd_d4, lcd_d5, lcd_d6, lcd_d7, lcd_columns, lcd_rows, lcd_red, lcd_green, lcd_blue)

# Show some basic colors.
lcd.set_color(1.0, 0.0, 0.0)
lcd.clear()
lcd.message('RED')
sleep(3.0)

lcd.set_color(0.0, 1.0, 0.0)
lcd.clear()
lcd.message('GREEN')
sleep(3.0)

lcd.set_color(0.0, 0.0, 1.0)
lcd.clear()
lcd.message('BLUE')
sleep(3.0)

lcd.set_color(1.0, 1.0, 0.0)
lcd.clear()
lcd.message('YELLOW')
sleep(3.0)

lcd.set_color(0.0, 1.0, 1.0)
lcd.clear()
lcd.message('CYAN')
sleep(3.0)

lcd.set_color(1.0, 0.0, 1.0)
lcd.clear()
lcd.message('MAGENTA')
sleep(3.0)

lcd.set_color(1.0, 1.0, 1.0)
lcd.clear()
lcd.message('WHITE')
sleep(3.0)
