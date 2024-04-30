-- fifths
-- hard autotune a voltage at input 1 to the major scale (or any of its modes)
-- modulate the position of the current key on the circle of fifths at input 2
-- each of the the first 3 outputs is a fifth apart
-- the fourth output is a 5V pulse every time the voltage at input 1 is quantized

-- window boundaries for 13 equal-ish sized windows for -5 to +5V
thirteen_windows = {-4.97,-4.5,-3.5,-2.5,-1.5,-0.5,0.5,1.5,2.5,3.5,4.5,4.97}

-- tonics on the circle of fifths starting from Gb all the way to F#, 
-- always choosing an octave with a note as close as possible to the key center (0)
circle_of_fifths = {-6,1,-4,3,-2,5,0,-5,2,-3,4,-1,6}

-- half-way between a minor third (3/12) and a major third (4/12) in 1V per Octave terms
ambiguous_third = 7/24

-- enable last value store in case line 61 below is uncommented
last_value = input[1]

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

new_key = major_scale(0)

-- choose output values based on input 1 and offsets. offsets are "ambiguous" thirds, meaning they are 
-- half way between a major and minor third, allowing the tuning and key changes to have maximum effect
input[1].scale = function(x) 

    --last value is only used if line 61 is uncommented to allow retuning upon input 2 changes
    last_value = x

    --update output tuning to new key (behaves like sample and hold of input 2 value)
    for i=1,3 do
        output[i].scale(new_key)
    end

    output[1].volts = x.volts
    output[2].volts = x.volts + ambiguous_third
    output[3].volts = x.volts + ambiguous_third + ambiguous_third
    output[4]() -- pulse output 4 when tuning
end

-- when input 2 hops between windows, choose a new key from the circle of fifths
input[2].window = function(x) 
    new_key = major_scale(circle_of_fifths[x])
    -- Uncomment the line below to add retriggering/tuning upon input 2 window changes
    -- input[1].scale(last_value)
end

--initialize things
function init()

    --input events fire whenever the input signal moves between semi-tones
    input[1].mode('scale', {})

    --input 2 produces value 1 at -5V and value 12 at +5V
    input[2].mode('window',thirteen_windows,0.2)

    --quantize all tuned outputs to the chromatic scale in case our fifths get weird
    for i=1,3 do
        output[i].scale(new_key)
    end

    --start in C major (ie. 0V at input 2)
    input[2].window(7)

    -- set up output 4 pulses
    output[4].action = pulse(0.01, 5)
end
