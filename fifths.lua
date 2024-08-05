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

--build a lydian dominant scale for any root note (tonic). This means that all modes of Melodic Minor are achievable
function lydian_dominant_scale(tonic)
    local scale = {}
    local whole = 2
    local half = 1
    scale = {
        tonic,
        tonic + whole,
        tonic + whole + whole,
        tonic + whole + whole + whole,
        tonic + whole + whole + whole + half,
        tonic + whole + whole + whole + half + whole,
        tonic + whole + whole + whole + half + whole + half
    }
    return scale
end

function just_fifths_scale(tonic)
    local scale = {}
    scale = {
        tonic,
        tonic + just12(3/2)
    }
    return scale
end

function harmonic_series(tonic)
    local scale = {}
    local series = {1,9/8,10/8,11/8,12/8,13/8,14/8}

    scale = just12(series)

   for i in ipairs(series) do
        scale[i] = just12(series[i]) + tonic
   end

    return scale
end

new_major_key = major_scale(0)
new_melodic_key = lydian_dominant_scale(0)
new_fifths_key = just_fifths_scale(0)
new_harmonic_series = harmonic_series(0)

-- choose output values based on input 1 and offsets. offsets are "ambiguous" thirds, meaning they are 
-- half way between a major and minor third, allowing the tuning and key changes to have maximum effect
input[1].scale = function(x) 

    --last value is only used if line XX is uncommented to allow retuning upon input 2 changes
    last_value = x

    output[1].scale(new_fifths_key)
    output[2].scale(new_major_key)
    output[3].scale(new_melodic_key)
    output[4].scale(new_harmonic_series)

    output[1].volts = x.volts
    output[2].volts = x.volts
    output[3].volts = x.volts
    output[4].volts = x.volts
end

-- when input 2 hops between windows, choose a new key from the circle of fifths
input[2].window = function(x) 
    new_major_key = major_scale(circle_of_fifths[x])
    new_melodic_key = lydian_dominant_scale(circle_of_fifths[x])
    new_fifths_key = just_fifths_scale(circle_of_fifths[x])
    new_harmonic_series = harmonic_series(circle_of_fifths[x])
end

--initialize things
function init()

    --input events fire whenever the input signal moves between semi-tones
    input[1].mode('scale', {})

    --input 2 produces value 1 at -5V and value 12 at +5V
    input[2].mode('window',thirteen_windows,0.2)


    --start in C major (ie. 0V at input 2)
    input[2].window(7)
end
