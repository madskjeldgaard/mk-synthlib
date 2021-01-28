MKSynthLib { 
	classvar verbosity,
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

	// VCA / envelope
	*getEnvelope{|envelopeName, kind|
		^envelopes.at(kind).at(envelopeName)
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

	// Wraps an envelope around the signal and uses it to scale the amplitude
	*embedWithVCA{|envelopeName, kind, sig, dur, envDone, gate|
		^SynthDef.wrap({|sig, dur, envDone, gate|
			sig * SynthDef.wrap(this.getEnvelope(envelopeName, kind), prependArgs: [dur, envDone, gate])
		},  prependArgs: [sig, dur, envDone, gate]
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
