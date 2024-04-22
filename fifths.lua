-- fifths
-- hard autotune a voltage at input 1 to the major scale (or any of its modes)
-- modulate the position of the current key on the circle of fifths at input 2
-- each of the four outputs is a fifth apart

-- window boundaries for 13 equal-ish sized windows for -5 to +5V
thirteen_windows = {-4.97,-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5,4.97}

-- tonics on the circle of fifths starting from Gb all the way to F#, 
-- always choosing an octave with a note as close as possible to the key center (0)
circle_of_fifths = {-6,1,-4,3,-2,5,0,-5,2,-3,4,-1,6}

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

-- choose output values based on input 1 and offsets based on fifths. 0V is assumed to be tuned to C3 (not mandatory!)
input[1].scale = function(x) 
    local fifth = 7 / 12
    local relative_to_c3 = x.volts + 4
    output[1].volts = relative_to_c3
    output[2].volts = relative_to_c3 + fifth
    output[3].volts = relative_to_c3 + fifth + fifth - 1 -- drop an octave to keep things under control
    output[4].volts = relative_to_c3 + fifth + fifth + fifth - 1 -- drop an octave to keep things under control
end

-- when input 2 hops between windows, choose a new key from the circle of fifths
input[2].window = function(x) 
    local new_key = major_scale(circle_of_fifths[x])
    input[1].mode('scale', new_key)
end

--initialize things
function init()

    --input 2 produces value 1 at -5V and value 12 at +5V
    input[2].mode('window',thirteen_windows,0.2)

    --quantize all outputs to the chromatic scale in case our fifths get weird
    for i=1,4 do
        output[i].scale({})
    end

    --start in C major (ie. 0V at input 2)
    input[2].window(7)
end
