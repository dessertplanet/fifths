-- fifths
-- hard autotune a voltage at input 1 to the major scale (or any of its modes)
-- modulate the postition of the current key on the circle of fifths at input 2
-- each of the four outputs is a perfect fifth apart, with all four honoring the inputs

-- window boundaries for 12 equal-ish sized windows for -5 to +5V
twelve_windows = {-4.97,-4,-3,-2,-1,0,1,2,3,4,4.97}

-- tonics on the circle of fifths starting from Db all the way to F#, 
-- always choosing an octave with a note as close as possible to note 0 (C4)
circle_of_fifths = {1,-4,3,-2,5,0,-5,2,-3,4,-1,6}

--build a major scale for any root note (tonic)
function major_scale(tonic)
    local scale = {}
    local whole = 2
    local half = 1
    scale = {
        tonic,
        tonic + whole,
        tonic + whole + whole,
        tonic + whole + whole + half,
        tonic + whole + whole + half + whole,
        tonic + whole + whole + half + whole + whole,
        tonic + whole + whole + half + whole + whole + whole
    }
    return scale
end

-- choose output values based on input 1 and perfect 5th offsets
input[1].scale = function(x) 
    local fifth = 7 / 12
    output[1].volts = x.volts
    output[2].volts = x.volts + fifth
    output[3].volts = x.volts + fifth + fifth
    output[4].volts = x.volts + fifth + fifth + fifth
end

-- when input 2 hops between windows, choose a new key from the circle of fifths
input[2].window = function(x) 
    local new_key = major_scale(circle_of_fifths[x])
    input[1].mode('scale', new_key)
end

--initialize things
function init()

    --input 2 produces value 1 at -5V and value 12 at +5V
    input[2].mode('window',twelve_windows)

    --quantize all outputs to the chromatic scale in case our fifths get weird
    for i=1,4 do
        output[i].scale({})
    end

    --start in C major (ie. 0V at input 2)
    input[2].window(6)
end