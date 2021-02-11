MKSynthLib { 
	classvar verbosity,
		<numChansOut,
		<synths, 
		<shapeBuffers, 
		<grainShapeBuffers,
		<waveshapeWrappers, 
		<envelopes,
		<emojis,
		<path,
		<initialized;

	*new {|numChannelsOut=2, verbose=true|
		^this.init( numChannelsOut, verbose );
	}

	*add{|basename, synthfunc, numChannelsIn=1|
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

						sig = sig * MKSynthLib.getEnvelopeWrapped(
							envelopeName: envType, 
							dur: dur, 
							envDone: envDone, 
							prefix: "vca"
						);

						sig = MKSynthLib.embedWithWaveshaper(shapeFuncName, sig);

						sig = MKFilterLib.new(
							filterName: filterType, 
							sig: sig, 
							filterEnvType: envType, 
							dur: dur,
							envDone: 0
						);

						sig = MKSynthLib.embedWithPanner(numChannelsIn, sig);

						Out.ar(out, sig * amp);
					};

					SynthDef.new(name, func).store;
					theseSynths = theseSynths.add(name);
					this.addSynthName(name, kind);

				}
			}
		};
		
		this.poster("Done generating synthdefs for %".format(basename));
		// MKGenPat.new(theseSynths.choose);
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

	*getEnvelopeWrapped{|envelopeName, envDone=2, dur=1, prefix="", suffix=""|
		^MKEnvLib.new(envelopeName, envDone: envDone, dur: dur, prefix: prefix, suffix: suffix)	
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
		if(initialized.not, { this.init() });

		^MKPanLib.new(numChannelsIn: numChannelsIn, numChannelsOut: numChansOut, sig: sig)
	}
	
	// Waveshaping
	*addWaveshapeBuffer{|name, buffer|
		this.poster("Adding waveshape buffer %".format(name));
		shapeBuffers.put(name, buffer);
	}

	*embedWithWaveshaper{|waveshaperName, sig|
		if(initialized.not, { this.init() });

		^SynthDef.wrap(
			MKSynthLib.getWaveshapeWrapper(waveshaperName),  
			prependArgs: [sig]
		) 
	}

	// Waveshape wraper functions used with SynthDef.wrap
	*getWaveshapeWrapper{|name|
		if(initialized.not, { this.init() });

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

	*addGrainShapeBuffer{|name, buffer|
		this.poster("Adding grainshape buffer %".format(name));
		grainShapeBuffers.put(name, buffer);
	}

	*embedWithGrainShapes{
		^SynthDef.wrap({|grainshape=0.5|
			var shapebuffers = SynthDef.wrap({ MKSynthLib.grainShapeBuffers.asArray });
			Select.kr(
				grainshape * shapebuffers.size, 
				shapebuffers
			); 
		})
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


	*init{|numChannels, verbose|
		var synthlibLoader;
		path = Main.packages.asDict.at('mk-synthlib');
		
		synthlibLoader = load(path +/+ "main.scd");

		numChansOut = numChannels;

		verbosity = verbose;

		synths = IdentityDictionary[];
		envelopes = IdentityDictionary[];
		shapeBuffers = IdentityDictionary[];
		grainShapeBuffers = IdentityDictionary[];
		waveshapeWrappers = IdentityDictionary[];
		
		Server.local.waitForBoot{
			fork{
				MKFilterLib.loadFilters();
				Server.local.sync;
				this.loadMessage;
				synthlibLoader.value(numChannelsOut: numChannels);
				Server.local.sync;
				initialized = true;
			}
		}
	}

	*loadSynthLib{

	}

	*loadMessage{
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
// When autopan is 0, it works as a normal pan using the pan argument
// When autopan is on, the pan argument becomes a bias for the autopanner
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

MKEnvLib{
	classvar <envelopes, <path;

	*new{|envelopeName=\perc, envDone=2, dur=1, prefix="", suffix=""|
		this.loadEnvelopes;

		^this.embedWithEnvelope(envelopeName, envDone, dur, prefix, suffix)
	}

	*loadEnvelopes{|forceLoad=false|
		path = ( Main.packages.asDict.at('mk-synthlib') +/+ "components" +/+ "singleshot-envelopes.scd");
		if(envelopes.isNil or: { forceLoad }, {
			envelopes = path.load;
		})
	}

	*embedWithEnvelope{|envelopeName, envDone=2, dur=2, prefix="", suffix=""|
		^SynthDef.wrap(this.getEnvelopeWrapper(envelopeName, prefix, suffix), prependArgs: [dur, envDone])
	} 

	*getEnvelopeWrapper{|envelopeName, prefix="", suffix=""|
		^envelopes.at(envelopeName).value(prefix, suffix);
	}

	*envelopeTypes{
		^envelopes.keys.asArray	
	}
}

MKFilterLib{
	classvar <filters;

	*new{|filterName, sig, filterEnvType=\perc, dur=1, envDone=0, suffix=""|
		this.loadFilters;
		^this.embedWithFilter(filterName, sig, filterEnvType, dur, envDone, suffix)
	}

	*loadFilters{|forceLoad=false|
		var path = (MKSynthLib.path +/+ "components" +/+ "filters.scd");
		if(filters.isNil or: { forceLoad }, {
			filters = path.load;
		})
	}

	*embedWithFilter{|filterName, sig, filterEnvType, dur=1, envDone=2, suffix=""|
		^SynthDef.wrap(this.getFilterWrapper(filterName, filterEnvType, suffix),  prependArgs: [sig, dur, envDone])
	} 

	*getFilterWrapper{|filterName,filterEnvType=\perc, suffix=""|
		^filters.at(filterName).value(suffix, filterEnvType);
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
