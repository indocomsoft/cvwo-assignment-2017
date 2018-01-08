module ApplicationHelper
  # Helper to choose foreground colour from a given background colour, following W3C Recommendation
  # https://www.w3.org/TR/WCAG20/#relativeluminancedef
  def choose_fgcolour(bgcolour)
    # Extract the red, green, blue components from the colour hexcode
    # then convert them according to the W3C recommendation 
    r,g,b = bgcolour.match(/#(..)(..)(..)/).to_a.drop(1).map do |e|
      a = e.hex / 255
      if a <= 0.03928
        a / 12.92
      else
        ((a + 0.055) / 1.055) ** 2.4
      end
    end
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    if luminance > 0.179
      "#000000"
    else
      "#FFFFFF"
    end
  end
end
