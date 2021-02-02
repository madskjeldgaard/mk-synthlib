MKSynthLib { 
	classvar verbosity,
		<numChansOut,
		<synths, 
		<shapeBuffers, 
		<waveshapeWrappers, 
		<envelopes,
		<vcaWrappers,
		<emojis,
		<path;

	*new {|numChannelsOut=2, verbose=true|
		^super.new.init( numChannelsOut, verbose );
	}

	*add{|basename, synthfunc|
		var theseSynths = [];
		var kind = \oneshot;
		var func;

		this.getEnvelopeNamesForKind.do{|envType|
			this.shapeWrapperKinds.do{|shapeFuncName|
				MKFilterLib.filterTypes.do{|filterType|
					var name = "%_%_%_%".format(basename, envType, filterType, shapeFuncName).asSymbol;

					// Wrap the input function
					func = { | out=0, amp=0.25, dur=1, envDone=2|
						var sig = SynthDef.wrap(synthfunc);

						sig = MKSynthLib.embedWithVCA(envType, \oneshot, sig, dur, envDone);
						sig = MKSynthLib.embedWithWaveshaper(shapeFuncName, sig);
						sig = MKFilterLib.new(filterType, sig);
						// sig = MKSynthLib.embedWithPanner(sig.size, sig);

						Out.ar(out, sig*amp);
					};

					SynthDef.new(name, func).store;
					theseSynths = theseSynths.add(name);
					this.addSynthName(name, kind);

				}
			}
		};
		
		this.poster("Done generating synthdefs for %".format(basename));
		MKGenPat.new(theseSynths.choose);

	}

	*initClass{
		emojis = ["🤠", "🪱", "🦑", "🥀", "🌻", "🍁", "🍇",  "🦞", "🍍", "🧀" ];
	}

	// Synthdef names
	*addSynthName{|synthName, kind|
		if(kind.isNil, {
			this.poster("No kind supplied for %".format(synthName), error: true)
		}, {
			this.poster("\t Adding synth %".format(synthName));
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
	*embedWithPanner{|numChannelsIn=1, sig|
		^MKPanLib.new(numChannelsIn: numChannelsIn, numChannelsOut: numChansOut, sig: sig)
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
		var synthlibLoader;

		path = Main.packages.asDict.at('mk-synthlib');

		synthlibLoader = load(path +/+ "main.scd");

		numChansOut = numChannels;

		verbosity = verbose;

		synths = IdentityDictionary[];
		envelopes = IdentityDictionary[];
		vcaWrappers = IdentityDictionary[];
		shapeBuffers = IdentityDictionary[];
		waveshapeWrappers = IdentityDictionary[];
		
		Server.local.waitForBoot{
			fork{
				MKFilterLib.loadFilters();
				Server.local.sync;
				this.loadMessage;
				synthlibLoader.value(numChannelsOut: numChannels);
			}
		}
	}

	*loadSynthLib{

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

// Convenience function for calculating auto panning values
MKAutoPan{
	*ar{|pan=1, panFreq=1, autopan=0, panShape=1.0|
		// Width is divided by two to make it go from saw to tri from 0 to 1 (instead of back to saw at the end)
		var panner = VarSaw.ar(panFreq, 0, width: panShape / 2.0).linlin(-1.0,1.0,pan,(-1)*pan);
		panner = XFade2.ar(K2A.ar(pan), panner, autopan.linlin(0.0,1.0,-1.0,1.0));
		^panner
	}
	// *kr{ }
}

MKPanLib {
	classvar <numChansOut;

	*new{|numChannelsIn=1, numChannelsOut=2, sig|
		numChansOut = numChannelsOut;

		^this.embedWithPanner(numChannelsIn, sig)
	}

	*embedWithPanner{|numChannelsIn=1, sig|
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
				{|sig, pan=0, panFreq=1, autopan=0, panShape=1| 
					var panner = MKAutoPan.ar(pan:pan, panFreq:panFreq, autopan:autopan, panShape:panShape);
					Pan2.ar(sig, panner)
				} 
			}
			// Stereo input
			{ numChannelsIn == 2 } { 
				{|sig, pan=0, panFreq=1, autopan=0, panShape=1| 
					var panner = MKAutoPan.ar(pan:pan, panFreq:panFreq, autopan:autopan, panShape:panShape);
					Balance2.ar(sig[0], sig[1], panner) 
				}		
			}
		}
		// Multichannel output
		{numChannelsOut > 2} { 
			case
			// Mono input
			{ numChannelsIn == 1 } { 
				{|sig, pan=0, width=2, orientation=0.5, panFreq=1, autopan=0, panShape=1|
					var panner = MKAutoPan.ar(pan:pan, panFreq:panFreq, autopan:autopan, panShape:panShape);

					PanAz.ar(
						numChannelsOut, 
						sig, 
						panner, 
						width: width, 
						orientation: orientation
					) 
				}
			}
			// Stereo input
			{ numChannelsIn > 1 } { 
				{|sig, pan=0, spread=1, width=2.0, orientation=0.5, levelComp=true, panFreq=1, autopan=0, panShape=1|
					var panner = MKAutoPan.ar(pan:pan, panFreq:panFreq, autopan:autopan, panShape:panShape);

					SplayAz.ar(
						numChannelsOut, 
						sig,  
						spread: spread,  
						level: 1,  
						width: width,  
						center: panner,  
						orientation: orientation,  
						levelComp: levelComp
					)
				}
			};

		};

		^panFunc
	}
}

MKFilterLib{
	classvar <filters;

	*new{|filterName, sig, suffix=""|
		this.loadFilters;
		^this.embedWithFilter(filterName, sig, suffix)
	}

	*loadFilters{
		var path = (MKSynthLib.path +/+ "components" +/+ "filters.scd");
		if(filters.isNil, {
			filters = path.load;
		})
	}

	*embedWithFilter{|filterName, sig, suffix=""|
		^SynthDef.wrap(this.getFilterWrapper(filterName, suffix),  prependArgs: [sig])
	} 
	*getFilterWrapper{|filterName, suffix=""|
		^filters.at(filterName).value(suffix);
	}

	*filterTypes{
		^filters.keys.asArray	
	}
}

// Named control with prefix and suffix
MKNC {
	*kr{arg name, values, lags, fixedLag = false, spec, suffix="", prefix="";
		name = this.fixedName(name, prefix, suffix);
		^NamedControl.new(name, values, \control, lags, fixedLag, spec)
	}
	*ar { arg  name, values, lags, spec, suffix="", prefix="";
		name = this.fixedName(name, prefix, suffix);
		^NamedControl.new(name, values, \audio, lags, false, spec)
	}

	*ir { arg  name, values, lags, spec, suffix="", prefix="";
		name = this.fixedName(name, prefix, suffix);
		^NamedControl.new(name, values, \scalar, lags, false, spec)
	}

	*tr { arg  name, values, lags, spec, suffix="", prefix="";
		name = this.fixedName(name, prefix, suffix);
		^NamedControl.new(name, values, \trigger, lags, false, spec)
	}

	*fixedName{|name,prefix="",suffix=""|
		^(prefix.asString ++ name.asString ++ suffix.asString).asSymbol;

	}
}

MKGenPat{
	*new{|synthDefName=\default, wrapInPdef=true, randomize=false|
		this.synthDefExists(synthDefName).if({
			this.postPatFor(synthDefName, wrapInPdef, randomize)
		})
	}

	*synthDefExists{|synthDefName|
		^SynthDescLib.global.synthDescs.at(synthDefName).isNil.not;
	}

	*postPatFor {|synthDef=\default, wrapInPdef=true, randomize=true|
		var controls = SynthDescLib.global.synthDescs.at(synthDef).controls;

		if(wrapInPdef, {"Pdef('%', ".format(MKSynthLib.emojis.choose).postln});
		if(wrapInPdef, "\t".post);
		"Pbind(".postln;
		if(wrapInPdef, "\t".post);
		"\t%instrument, %%,".format("\\", "\\", synthDef.asSymbol).postln;
		controls.do{|control| 
				var name = control.name;
				var val = control.defaultValue;

				// Check that synth doesn't have a duration of 0 by default (making sc explode)
				val = if(name == \dur && val == 0.0, { 1.0 }, { val });
				val = if(randomize && val.isKindOf(Number), { val * rrand(0.9,1.1) }, { val });

				if(wrapInPdef, "\t".post);
				"\t%%, %,".format("\\", name, val).postln
		};
		if(wrapInPdef, {"\t)\n).play".postln}, {").play".postln});
	}

}
