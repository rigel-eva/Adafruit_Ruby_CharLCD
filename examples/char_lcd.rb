#!/usr/bin/ruby
require "adafruit_charlcd"
#Setting up the pin numbering for the raspberry pi
RPi::GPIO.set_numbering :bcm
# Raspberry Pi pin configuration:
lcd_rs        = 27  # Note this might need to be changed to 21 for older revision Pi"s.
lcd_en        = 22
lcd_d4        = 25
lcd_d5        = 24
lcd_d6        = 23
lcd_d7        = 18
lcd_backlight = 4

# Define LCD column and row size for 16x2 LCD.
lcd_columns = 16
lcd_rows    = 2

# Alternatively specify a 20x4 LCD.
# lcd_columns = 20
# lcd_rows    = 4

# Initialize the LCD using the pins above.
lcd=Adafruit_CharLCD.new(lcd_rs, lcd_en, lcd_d4, lcd_d5, lcd_d6, lcd_d7,lcd_columns, lcd_rows, lcd_backlight)
# Print a two line message
lcd.message("Hello\nworld!")

# Wait 5 seconds
sleep(5.0)

# Demo showing the cursor.
lcd.clear()
lcd.show_cursor(true)
lcd.message("Show cursor")

sleep(5.0)

# Demo showing the blinking cursor.
lcd.clear()
lcd.blink(true)
lcd.message("Blink cursor")

sleep(5.0)

# Stop blinking and showing cursor.
lcd.show_cursor(false)
lcd.blink(false)

# Demo scrolling message right/left.
lcd.clear()
message = "Scroll"
lcd.message(message)
(0..lcd_columns-message.length-1).each{|i|
      sleep(0.5)
      lcd.move_right()
}
(0..lcd_columns-message.length-1).each{|i|
  sleep(0.5)
  lcd.move_left()
}

# Demo turning backlight off and on.
lcd.clear()
lcd.message("Flash backlight\nin 5 seconds...")
sleep(5.0)
# Turn backlight on.
lcd.set_backlight(1)
sleep(2.0)
# Turn backlight off.
lcd.set_backlight(0)
# Change message.
lcd.clear()
lcd.message("Goodbye!")
#Cleaning up pin usage
RPi::GPIO.clean_up
