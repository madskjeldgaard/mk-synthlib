// Deduce a panning function from number of channels in and number of channels out
// Return a function to be used with SynthDef.wrap
(
~panFunc = {|numChannelsIn=1, numChannelsOut=2|
	case
	// Mono output
	{ numChannelsOut == 1 } { 
		if(numChannelsIn > 1, { 
			{|sig|sig.sum}		
		}, {
			{|sig|sig}
		}) 
	}
	// Stereo output
	{ numChannelsOut == 2 } { 
		case 
		// Mono input
		{ numChannelsIn == 1 } { 
			{|sig, pan=0| Pan2.ar(sig, pan)} 
		}
		// Stereo input
		{ numChannelsIn == 2 } { 
			{|sig, pan=0|Balance2.ar(sig[0], sig[1], pan) }		
		}
	}
	// Multichannel output
	{numChannelsOut > 2} { 
		case
		// Mono input
		{ numChannelsIn == 1 } { 
			{|sig, pan=0, width=2, orientation=0.5|
				PanAz.ar(numChannelsOut, sig, pan, width: width, orientation: orientation) 
			}
		}
		// Stereo input
		{ numChannelsIn == 2 } { 
			{|sig, pan=0, spread=1, width=2.0, orientation=0.5, levelComp=true|
				SplayAz.ar(numChannelsOut, sig,  spread: spread,  level: 1,  width: width,  center: pan,  orientation: orientation,  levelComp: levelComp)
			}
		};

	};

};
)
