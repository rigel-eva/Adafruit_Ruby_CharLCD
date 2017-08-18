require 'rpi_gpio'
# Copyright (c) 2014 Adafruit Industries
# Author: Tony DiCola
# Ported by: Rigel
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Commands
LCD_CLEARDISPLAY        = 0x01
LCD_RETURNHOME          = 0x02
LCD_ENTRYMODESET        = 0x04
LCD_DISPLAYCONTROL      = 0x08
LCD_CURSORSHIFT         = 0x10
LCD_FUNCTIONSET         = 0x20
LCD_SETCGRAMADDR        = 0x40
LCD_SETDDRAMADDR        = 0x80

# Entry flags
LCD_ENTRYRIGHT          = 0x00
LCD_ENTRYLEFT           = 0x02
LCD_ENTRYSHIFTINCREMENT = 0x01
LCD_ENTRYSHIFTDECREMENT = 0x00

# Control flags
LCD_DISPLAYON           = 0x04
LCD_DISPLAYOFF          = 0x00
LCD_CURSORON            = 0x02
LCD_CURSOROFF           = 0x00
LCD_BLINKON             = 0x01
LCD_BLINKOFF            = 0x00

# Move flags
LCD_DISPLAYMOVE         = 0x08
LCD_CURSORMOVE          = 0x00
LCD_MOVERIGHT           = 0x04
LCD_MOVELEFT            = 0x00

# Function set flags
LCD_8BITMODE            = 0x10
LCD_4BITMODE            = 0x00
LCD_2LINE               = 0x08
LCD_1LINE               = 0x00
LCD_5x10DOTS            = 0x04
LCD_5x8DOTS             = 0x00

# Offset for up to 4 rows.
LCD_ROW_OFFSETS = [0x00, 0x40, 0x14, 0x54]

# Char LCD plate GPIO numbers.
LCD_PLATE_RS            = 15
LCD_PLATE_RW            = 14
LCD_PLATE_EN            = 13
LCD_PLATE_D4            = 12
LCD_PLATE_D5            = 11
LCD_PLATE_D6            = 10
LCD_PLATE_D7            = 9
LCD_PLATE_RED           = 6
LCD_PLATE_GREEN         = 7
LCD_PLATE_BLUE          = 8

# Char LCD plate button names.
SELECT                  = 0
RIGHT                   = 1
DOWN                    = 2
UP                      = 3
LEFT                    = 4
# PWM duty cycles
PWM_FREQUENCY=240
class Adafruit_CharLCD
  def initialize(rs, en, d4, d5, d6, d7, cols, lines, backlight=nil,
                    invert_polarity=true,
                    enable_pwm=false,
                    initial_backlight=1.0)
    #Initialize the LCD.  RS, EN, and D4...D7 parameters should be the pins
    #connected to the LCD RS, clock enable, and data line 4 through 7 connections.
    #The LCD will be used in its 4-bit mode so these 6 lines are the only ones
    #required to use the LCD.  You must also pass in the number of columns and
    #lines on the LCD.
    #If you would like to control the backlight, pass in the pin connected to
    #the backlight with the backlight parameter.  The invert_polarity boolean
    #controls if the backlight is one with a LOW signal or HIGH signal.  The
    #default invert_polarity value is true, i.e. the backlight is on with a
    #LOW signal.
    #You can enable PWM of the backlight pin to have finer control on the
    #brightness.  To enable PWM make sure your hardware supports PWM on the
    #provided backlight pin and set enable_pwm to true (the default is false).
    #The appropriate PWM library will be used depending on the platform, but
    #you can provide an explicit one with the pwm parameter.
    #The initial state of the backlight is ON, but you can set it to an
    #explicit initial state with the initial_backlight parameter (0 is off,
    #1 is on/full bright).
    # Save column and line state.
    @_cols = cols
    @_lines = lines
    # Save GPIO state and pin numbers.
    @_rs = rs
    @_en = en
    @_d4 = d4
    @_d5 = d5
    @_d6 = d6
    @_d7 = d7
    # Save backlight state.
    @_backlight = backlight
    @_pwm_enabled = enable_pwm
    @_blpol = !invert_polarity
    #Setting up the pins
    [rs, en, d4, d5, d6, d7].each do |pin|
      RPi::GPIO.setup pin, :as => :output, :initialize => :low
    end
    #setup backlight
    if @_backlight !=nil
      RPi::GPIO.setup @_backlight, :as =>:output,:initialize=>:low
      if enable_pwm
        @_backlightPWM=RPi::GPIO::PWM.new(@_backlight, PWM_FREQUENCY)
        @_backlightPWM.start(_pwm_duty_cycle(initial_backlight))
      else
        #FIXME: I really need to not work through the logic at 03:21 ... https://github.com/adafruit/Adafruit_Python_CharLCD/blob/f5a43f9c331180aeeef9cc86395ad84ca7deb631/Adafruit_CharLCD/Adafruit_CharLCD.py#L148
        if(initial_backlight>0)

        else
        end
      end
    end
    # Initialize the display.
    # Initialize the display.
    write8(0x33)
    write8(0x32)
    # Initialize display control, function, and mode registers.
    @_displaycontrol = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF
    @_displayfunction = LCD_4BITMODE | LCD_1LINE | LCD_2LINE | LCD_5x8DOTS
    @_displaymode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT
    # Write registers.
    write8(LCD_DISPLAYCONTROL | @_displaycontrol)
    write8(LCD_FUNCTIONSET | @_displayfunction)
    write8(LCD_ENTRYMODESET | @_displaymode)  # set the entry mode
    clear()
  end
  def home()
    #Move the cursor back to its home (first line and first column).
    write8(LCD_RETURNHOME)  # set cursor position to zero
    sleep(0.003)            # this command takes a long time!
  end
  def clear()
    #Clear the LCD.
    write8(LCD_CLEARDISPLAY)  # command to clear display
    sleep(0.003)              # 3000 microsecond sleep, clearing the display takes a long time
  end
  def set_cursor(col, row)
    #Move the cursor to an explicit column and row position.
    # Clamp row to the last row of the display.
    if row > @_lines
      row = @_lines - 1
    end
    # Set location.
    write8(LCD_SETDDRAMADDR | (col + LCD_ROW_OFFSETS[row]))
  end
  def enable_display(enable)
    #Enable or disable the display.  Set enable to true to enable.
    if(enable)
      @_displaycontrol |= LCD_DISPLAYON
    else
      @_displaycontrol &= ~LCD_DISPLAYON
    end
    write8(@_displaycontrol|LCD_DISPLAYCONTROL)
  end
  def show_cursor(show)
    #Show or hide the cursor.  Cursor is shown if show is true.
    if(show)
      @_displaycontrol |= LCD_CURSORON
    else
      @_displaycontrol &= ~LCD_CURSORON
    end
    write8(@_displaycontrol|LCD_DISPLAYCONTROL)
  end
  def blink(blink)
    #Turn on or off cursor blinking.  Set blink to true to enable blinking."""
    if blink
      @_displaycontrol |= LCD_BLINKON
    else
      @_displaycontrol &= ~LCD_BLINKON
    end
    write8(@_displaycontrol|LCD_DISPLAYCONTROL)
  end
  def move_left()
    #Move display left one position.
    write8(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVELEFT)
  end
  def move_right()
    #Move display right one position.
    write8(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVERIGHT)
  end
  def set_left_to_right()
    #Set text direction left to right."""
    @_displaymode |= LCD_ENTRYLEFT
    write8(LCD_ENTRYMODESET | @_displaymode)
  end
  def set_right_to_left()
    #Set text direction right to left.
    @_displaymode &= ~LCD_ENTRYLEFT
    write8(LCD_ENTRYMODESET | @_displaymode)
  end
  def autoscroll(autoscroll)
    #Autoscroll will 'right justify' text from the cursor if set true,
    #otherwise it will 'left justify' the text.
    if autoscroll
      @_displaymode |= LCD_ENTRYSHIFTINCREMENT
    else
      @_displaymode &= ~LCD_ENTRYSHIFTINCREMENT
    end
    write8(LCD_ENTRYMODESET | @_displaymode)
  end
  def message(text)
    #Write text to display.  Note that text can include newlines.
    line = 0
    # Iterate through each character.
    text.split("").each{|char|#Bit of a hacky way to do it but 🤷
      # Advance to next line if character is a new line.
      if(char == "\n")
        line += 1
        # Move to left or right side depending on text direction.
        if (@_displaymode & LCD_ENTRYLEFT )> 0
          col = 0
        else
          @_cols-1
        end
        set_cursor(col, line)
      # Write the character to the display.
      else
        write8(char.ord, true)
      end
    }
  end
  def set_backlight(backlight)
    #Enable or disable the backlight.  If PWM is not enabled (default), a
    #non-zero backlight value will turn on the backlight and a zero value will
    #turn it off.  If PWM is enabled, backlight can be any value from 0.0 to
    #1.0, with 1.0 being full intensity backlight.
    if @_backlight !=nil
      if @_pwm_enabled
        @_backlightPWM=_pwm_duty_cycle(backlight)
      else
        puts backlight
        if(backlight>0)
          RPi::GPIO.set_high @_backlight
        else
          RPi::GPIO.set_low @_backlight
        end
      end
    end
  end
  def write8(value, char_mode=false)
    #Write 8-bit value in character or data mode.  Value should be an int
    #value from 0-255, and char_mode is true if character data or false if
    #non-character data (default).
    # One millisecond delay to prevent writing too quickly.
    sleep(0.001)
    # Set character / data bit.
    if(char_mode)
      RPi::GPIO.set_high @_rs
    else
      RPi::GPIO.set_low @_rs
    end
    # Write upper 4 bits.
    {@_d4=>4,@_d5=>5,@_d6=>6,@_d7=>7}.each{|pin,bit|#This is super jankey, but it should work
      if((value>>bit)& 1)>0
        RPi::GPIO.set_high pin
      else
        RPi::GPIO.set_low pin
      end
    }
    #RPi::GPIO.output([@_d4,@_d5,@_d6,@_d7],
    #                  ((value >> 4) & 1) > 0,
    #                  ((value >> 5) & 1) > 0,
    #                  ((value >> 6) & 1) > 0,
    #                  ((value >> 7) & 1) > 0)
    #RPi::GPIO.output_pins({ @_d4: ((value >> 4) & 1) > 0,
    #                        @_d5: ((value >> 5) & 1) > 0,
    #                         @_d6: ((value >> 6) & 1) > 0,
    #                         @_d7: ((value >> 7) & 1) > 0 })
    _pulse_enable()
    # Write lower 4 bits.
    {@_d4=>0,@_d5=>1,@_d6=>2,@_d7=>3}.each{|pin,bit|#This is super jankey, but it should work
      if((value>>bit)&1)>0
        RPi::GPIO.set_high pin
      else
        RPi::GPIO.set_low pin
      end
    }
    #RPi::GPIO.output([@_d4,@_d5,@_d6,@_d7],
    #                  (value & 1) > 0,
    #                  ((value >> 1) & 1) > 0,
    #                  ((value >> 2) & 1) > 0,
    #                  ((value >> 3) & 1) > 0)
    _pulse_enable()
  end
  def create_char(location, pattern)
    #Fill one of the first 8 CGRAM locations with custom characters.
    #The location parameter should be between 0 and 7 and pattern should
    #provide an array of 8 bytes containing the pattern. E.g. you can easyly
    #design your custom character at http://www.quinapalus.com/hd44780udg.html
    #To show your custom character use eg. lcd.message('\x01')
    # only position 0..7 are allowed
    location &= 0x7
    write8(LCD_SETCGRAMADDR | (location << 3))
    (0..8).each{|i|
      write8(pattern[i], true)
    }
  end
  def _pulse_enable()
    # Pulse the clock enable line off, on, off to send command.
    RPi::GPIO.set_low @_en
    sleep(0.000001)         # 1 microsecond pause - enable pulse must be > 450ns
    RPi::GPIO.set_high @_en
    sleep(0.000001)         # 1 microsecond pause - enable pulse must be > 450ns
    RPi::GPIO.set_low @_en
    sleep(0.000001)         # commands need > 37us to settle
  end
  def _pwm_duty_cycle(intensity)
    # Convert intensity value of 0.0 to 1.0 to a duty cycle of 0.0 to 100.0
    intensity = 100.0*intensity
    # Invert polarity if required.
    if not @_blpol
      intensity = 100.0-intensity
    end
    return intensity
  end
end
#Not comfertable with this bit of code just yet ...
class Adafruit_RGBCharLCD < Adafruit_CharLCD
  def initialize(rs, en, d4, d5, d6, d7, cols, lines, red, green, blue,
    invert_polarity=True,
    enable_pwm=False,
    initial_color=[1.0, 1.0, 1.0])
      # Initialize the LCD with RGB backlight.  RS, EN, and D4...D7 parameters
      # should be the pins connected to the LCD RS, clock enable, and data line
      # 4 through 7 connections. The LCD will be used in its 4-bit mode so these
      # 6 lines are the only ones required to use the LCD.  You must also pass in
      # the number of columns and lines on the LCD.
      # The red, green, and blue parameters define the pins which are connected
      # to the appropriate backlight LEDs.  The invert_polarity parameter is a
      # boolean that controls if the LEDs are on with a LOW or HIGH signal.  By
      # default invert_polarity is True, i.e. the backlight LEDs are on with a
      # low signal.  If you want to enable PWM on the backlight LEDs (for finer
      # control of colors) and the hardware supports PWM on the provided pins,
      # set enable_pwm to True.  Finally you can set an explicit initial backlight
      # color with the initial_color parameter.  The default initial color is
      # white (all LEDs lit).
      # You can optionally pass in an explicit GPIO class,
      # for example if you want to use an MCP230xx GPIO extender.  If you don't
      # pass in an GPIO instance, the default GPIO for the running platform will
      # be used.

      super(rs, en, d4, d5, d6, d7,cols,lines,false,invert_polarity,enable_pwm)
      @_red = red
      @_green = green
      @_blue = blue
      # Setup backlight pins.
      [@_red, @_green, @_blue].each{|pin|
        RPi::GPIO.setup pin, :as => :output, :initialize => :low
      }
      if enable_pwm
        # Determine initial backlight duty cycles.
        @_backlightPWM=[]
        inital_color=_rgb_to_duty_cycle(inital_color)
        {@_red=>initial_color[0], @_green=>initial_color[1], @_blue=>initial_color[2]}.each{|pin,color|
          @_backlightPWM.push<<RPi::GPIO::PWM.new(pin, PWM_FREQUENCY)
          @_backlightPWM[-1].start(color)
        }
        rdc, gdc, bdc = _rgb_to_duty_cycle(initial_color)
        pwm.start(red, rdc)
        pwm.start(green, gdc)
        pwm.start(blue, bdc)
      else
        _rgb_to_pins(rgb).each{|pin,value|
          if(value)
            RPi::GPIO.set_high pin
          end
        }
      end
  end
  def _rgb_to_duty_cycle(rgb)
    # Convert tuple of RGB 0-1 values to tuple of duty cycles (0-100).
    rgb.each{|color|
      color=color.clamp(0.0,1.0)
      color=_pwm_duty_cycle(color)
    }
    return rgb
  end
  def _rgb_to_pins(rgb)
    # Convert tuple of RGB 0-1 values to dict of pin values.
    retDict={}
    {@_red=>rgb[0],@_green=>rgb[1],@_blue=>rgb[2]}.each{|pin,color|
      if(color>0)#FIXME There has to be a more elegant way of doing this ...
        retDict[pin]=@_blpol
      else
        retDict[pin]=!@_blpol
      end
    }
  end
  def set_color(red, green, blue)
    # Set backlight color to provided red, green, and blue values.  If PWM
    # is enabled then color components can be values from 0.0 to 1.0, otherwise
    # components should be zero for off and non-zero for on.
    if @_pwm_enabled
      # Set duty cycle of PWM pins.
      rgb=_rgb_to_duty_cycle([red, green, blue])
      for i in (0..2)
        @_backlightPWM[i].duty_cycle=rgb[i]
      end
    else
      # Set appropriate backlight pins based on polarity and enabled colors.
      {@_red=>red,@_green=>green,@_blue=>blue}.each{|pin,value|
        if value>0
          RPi::GPIO.output(pin, @_blpol)
        else
          RPi::GPIO.output(pin,!@_blpol)
        end
      }
    end
  end
  def set_backlight(backlight)
    # Enable or disable the backlight.  If PWM is not enabled (default), a
    # non-zero backlight value will turn on the backlight and a zero value will
    # turn it off.  If PWM is enabled, backlight can be any value from 0.0 to
    # 1.0, with 1.0 being full intensity backlight.  On an RGB display this
    # function will set the backlight to all white.
    set_color(backlight, backlight, backlight)
  end
end
