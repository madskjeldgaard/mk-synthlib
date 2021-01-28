MKSynthLib { 
	classvar verbosity,
		<synths, 
		<shapeBuffers, 
		<waveshapeWrappers, emojis;

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

	// Waveshaping
	*addWaveshapeBuffer{|name, buffer|
		this.poster("Adding waveshape buffer %".format(name));
		shapeBuffers.put(name, buffer);
	}

	// Waveshape wraper functions used with SynthDef.wrap
	*waveshapeWrapper{|name|
		^waveshapeWrappers[name]
	}
	*addWaveshapeWrapper{|name, func|
		this.poster("Adding waveshape wrapper function %".format(name));
		waveshapeWrappers.put(name, func);
	}

	*numShapes{
		^shapeBuffers.size;
	}

	*kinds{
		^synths.keys
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
