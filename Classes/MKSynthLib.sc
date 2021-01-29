MKSynthLib { 
	classvar verbosity,
		<numChansOut,
		<synths, 
		<shapeBuffers, 
		<waveshapeWrappers, 
		<envelopes,
		<vcaWrappers,
		<emojis;

	*new {|numChannelsOut=2, verbose=true|
		^super.new.init( numChannelsOut, verbose );
	}

	// Synthdef names
	*addSynthName{|synthName, kind|
		if(kind.isNil, {
			this.poster("No kind supplied for %".format(synthName), error: true)
		}, {
			// If there is not already an array under the key
			// Add one
			if(synths.at(kind).isNil, {
				synths.put(kind, [synthName])
			}, {
				synths.put(kind, synths.at(kind).add(synthName))
			});

		})
	}

	*getEnvelopeNamesForKind{|kind=\oneshot|
		^envelopes.at(kind).keys.asArray
	}

	// Get an envelope wrapper to use with SynthDef.wrap
	*getEnvelopeWrapper{|envelopeName, kind|
		^envelopes.at(kind).at(envelopeName)
	}

	*getEnvelopeWrapped{|envelopeName, kind, dur=1, envDone=2|
		^SynthDef.wrap(this.getEnvelopeWrapper(envelopeName, kind), prependArgs: [dur, envDone])
	}

	*addEnvelope{|envName, kind, envelope|
		if(kind.isNil, {
			this.poster("No kind supplied for envelope %".format(envName), error: true)
		}, {
			// If there is not already an array under the key

			this.poster("Adding % envelope %".format(kind, envName));
			// Add one
			if(envelopes.at(kind).isNil, {
				envelopes.put(kind, IdentityDictionary[envName.asSymbol -> envelope])
			}, {
				envelopes.put(kind, envelopes.at(kind).put(envName.asSymbol, envelope))
			});

		})
	}

	*embedWithPanner{|numChannelsIn, sig|
		^SynthDef.wrap(
			this.getPanFunc(numChannelsIn: numChannelsIn, numChannelsOut: numChansOut),  
			prependArgs: [sig]
		)
	}

	// Deduce a panning function from number of channels in and number of channels out
	// Return a function to be used with SynthDef.wrap
	*getPanFunc{|numChannelsIn=1, numChannelsOut=2|
		var panFunc = case
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

		^panFunc
	}

	// Wraps an envelope around the signal and uses it to scale the amplitude
	*embedWithVCA{|envelopeName, kind, sig, dur, envDone|
		^SynthDef.wrap({|sig, dur, envDone|
			sig * SynthDef.wrap(this.getEnvelopeWrapper(envelopeName, kind), prependArgs: [dur, envDone])
		},  prependArgs: [sig, dur, envDone]
		)
	}

	// Waveshaping
	*addWaveshapeBuffer{|name, buffer|
		this.poster("Adding waveshape buffer %".format(name));
		shapeBuffers.put(name, buffer);
	}

	*embedWithWaveshaper{|waveshaperName, sig|
		^SynthDef.wrap(
			MKSynthLib.getWaveshapeWrapper(waveshaperName),  
			prependArgs: [sig]
		) 
	}

	// Waveshape wraper functions used with SynthDef.wrap
	*getWaveshapeWrapper{|name|
		if(
			waveshapeWrappers.keys.asArray.indexOfEqual(name).isNil,
			{
				this.poster("Waveshape wrapper % not found", error: true);
				^nil
			}, 
			{
				^waveshapeWrappers[name]
			}
		)
	}

	*addWaveshapeWrapper{|name, func|
		this.poster("Adding waveshape wrapper function %".format(name));
		waveshapeWrappers.put(name, func);
	}

	*numShapes{
		^shapeBuffers.size;
	}

	// Synth plumming
	*kinds{
		^synths.keys
	}

	*shapeWrapperKinds{
		^waveshapeWrappers.keys
	}

	*poster{|what, error=false|
		var prefix = emojis.choose;
		verbosity.if({
			var string = "% %".format(prefix, what);
			if(error, {
				string.error;
			}, { 
				string.postln;
			})
		})
	}


	init{|numChannels, verbose|
		var thisPath = Main.packages.asDict.at('mk-synthlib');
		var synthlibLoader = load(thisPath +/+ "main.scd");

		numChansOut = numChannels;

		verbosity = verbose;

		synths = IdentityDictionary[];
		envelopes = IdentityDictionary[];
		vcaWrappers = IdentityDictionary[];
		shapeBuffers = IdentityDictionary[];
		waveshapeWrappers = IdentityDictionary[];
		emojis = ["🤠", "🪱", "🦑", "🥀", "🌻", "🍁", "🍇",  "🦞", "🍍", "🧀" ];

		Server.local.doWhenBooted{
			this.loadMessage;
			synthlibLoader.value(numChannelsOut: numChannels);
		}
	}

	loadMessage{
		if(verbosity, {
			"----------".postln;
			"Loading mk-synthlib".postln;
			100.do{ 
				["🧀", " ", "    ", "      "].wchoose([0.75, 0.05, 0.15, 0.1]).post
			};
			"".postln;
		})
	}

}
