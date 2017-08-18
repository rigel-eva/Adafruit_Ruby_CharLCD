#!/usr/bin/ruby
require "adafruit_charlcd"
def hsv_to_rgb(hsv)
    # Converts a tuple of hue, saturation, value to a tuple of red, green blue.
    # Hue should be an angle from 0.0 to 359.0.  Saturation and value should be a
    # value from 0.0 to 1.0, where saturation controls the intensity of the hue and
    # value controls the brightness.
    # Algorithm adapted from http://www.cs.rit.edu/~ncs/color/t_convert.html
    h, s, v = hsv
    if hsv[1] == 0
        return [hsv[2], hsv[2], hsv[2]]
    end
    h /= 60.0
    i = math.floor(h)
    f = h-i
    p = v*(1.0-s)
    q = v*(1.0-s*f)
    t = v*(1.0-s*(1.0-f))
    case i
    when 0
      return [v,t,p]
    when 1
      return [q,v,p]
    when 2
      return [p,v,t]
    when 3
      return [p,q,v]
    when 4
      return [t,p,v]
    else
      return [v,p,q]
    end
end
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
lcd_blue = 7 # Pin 7 is CE1
# Define LCD column and row size for 16x2 LCD.
lcd_columns = 16
lcd_rows    = 2

# Alternatively specify a 20x4 LCD.
# lcd_columns = 20
# lcd_rows    = 4

# Initialize the LCD using the pins
lcd = Adafruit_RGBCharLCD.new(lcd_rs, lcd_en, lcd_d4, lcd_d5, lcd_d6, lcd_d7,
                              lcd_columns, lcd_rows, lcd_red, lcd_green, lcd_blue,
                              true,true)

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

# Use HSV color space so the hue can be adjusted to see a nice gradient of colors.
# Hue ranges from 0.0 to 359.0, saturation from 0.0 to 1.0, and value from 0.0 to 1.0.
hue = 0.0
saturation = 1.0
value = 1.0

# Loop through all RGB colors.
lcd.clear()
print('Press Ctrl-C to quit.')
while true do
    # Convert HSV to RGB colors.
    rgb = hsv_to_rgb([hue, saturation, value])
    # Set backlight color.
    lcd.set_color(rgb[0], rgb[1], rgb[2])
    # Print message with RGB values to display.
    lcd.set_cursor(0, 0)
    lcd.message("RED  GREEN  BLUE\n{0:0.2f}  {1:0.2f}  {2:0.2f}".format(red, green, blue))
    # Increment hue (wrapping around at 360 degrees).
    hue += 1.0
    if hue > 359.0
      hue = 0.0
    end
end
