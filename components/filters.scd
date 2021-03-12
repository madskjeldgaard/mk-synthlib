(
var filters = (
	dfm1: {|suffix="", filterEnvType=\perc|

		{|sig, dur, envDone=0|
			// Filter envelope stuff
			var filterLag = MKNC.kr("filterLag", 0.1);
			var filterEnv = MKSynthLib.getEnvelopeWrapped(
							envelopeName: filterEnvType, dur: dur, envDone: envDone, prefix: "filter"
						).lag(filterLag * dur );
			var filterEnvPeak = MKNC.kr("filterEnvPeak", 1, suffix: suffix);
			var cutoffParam = MKNC.kr("cutoff", 20000, suffix: suffix);
			var filterEnvParam = MKNC.kr("filterEnvAmount", 0.0, suffix:suffix);
			var cutoff = SelectX.kr(filterEnvParam, [
				cutoffParam, filterEnv.linlin(0.0,1.0,20.0, clip(cutoffParam * filterEnvPeak, 20.0,20000.0))
			]);

			DFM1.ar(
				sig, 
				cutoff,
				MKNC.ar("resonance", 0.0, suffix:suffix), 
				MKNC.ar("filterGain", 1.0, suffix: suffix), 
				MKNC.ar("filterType", 0.0, suffix: suffix), 
				MKNC.ir("filterNoise", 0.0, suffix: suffix)
			)

		}
	},
	// svf: {|suffix="", filterEnvType=\perc|
	// 	{|sig, dur, envDone=0|
	// 		// Filter envelope stuff
	// 		var filterLag = MKNC.kr("filterLag", 0.1);
	// 		var filterEnv = MKSynthLib.getEnvelopeWrapped(
	// 						envelopeName: filterEnvType, dur: dur, envDone: envDone, prefix: "filter"
	// 					).lag(filterLag * dur );
	// 		var filterEnvPeak = MKNC.kr("filterEnvPeak", 1, suffix: suffix);
	// 		var cutoffParam = MKNC.kr("cutoff", 1500, suffix: suffix);
	// 		var filterEnvParam = MKNC.kr("filterEnvAmount", 1.0, suffix:suffix);
	// 		var cutoff = SelectX.kr(filterEnvParam, [
	// 			cutoffParam, filterEnv.linlin(0.0,1.0,20.0, clip(cutoffParam * filterEnvPeak, 20.0,20000.0))
	// 		]);

	// 		SVF.ar(
	// 			sig,
	// 			cutoffParam,
	// 			MKNC.ar("resonance", 0.5, suffix: suffix),
	// 			MKNC.ar("lowpassAmount", 1.0, suffix: suffix),
	// 			MKNC.ar("bandpassAmount", 0.0, suffix: suffix),
	// 			MKNC.ar("highpassAmount", 0.0, suffix: suffix),
	// 			MKNC.ar("notchAmount", 0.0, suffix: suffix),
	// 			MKNC.ar("filterPeak", 0.0, suffix: suffix),
	// 		)
	// 	}
	// },
	// Picked this up here: https://scsynth.org/t/morphing-filters/1790/6
	// morphing: {|suffix="", filterEnvType=\perc|
	// 	{|sig, dur, envDone=0|
	// 		// Filter envelope stuff
	// 		var filterLag = MKNC.kr("filterLag", 0.1);
	// 		var filterEnv = MKSynthLib.getEnvelopeWrapped(
	// 						envelopeName: filterEnvType, dur: dur, envDone: envDone, prefix: "filter"
	// 					).lag(filterLag * dur );
	// 		var filterEnvPeak = MKNC.kr("filterEnvPeak", 1, suffix: suffix);
	// 		var cutoffParam = MKNC.kr("cutoff", 1500, suffix: suffix);
	// 		var filterEnvParam = MKNC.kr("filterEnvAmount", 1.0, suffix:suffix);
	// 		var cutoff = SelectX.kr(filterEnvParam, [
	// 			cutoffParam, filterEnv.linlin(0.0,1.0,20.0, clip(cutoffParam * filterEnvPeak, 20.0,20000.0))
	// 		]);

	// 		var freq = cutoffParam;
	// 		// Render Low/Band/High-pass signals
	// 		var lp = BLowPass4.ar(sig, freq, rq: 0.1);
	// 		var bp = BHiPass4.ar(lp, freq: freq, rq: 1);
	// 		var hp = BHiPass4.ar(sig, freq: freq, rq: 0.1);

	// 		// Mix through signals
	// 		var morphAmount = MKNC.ar("filterMorph", 0.5, suffix: suffix);
	// 		LinSelectX.ar((morphAmount * 2), [lp, bp, hp]);
	// 	}
	// },
	// morphingParallel: {|suffix=""|
	// 	{|sig|
	// 		var filters = Array.fill(2, {|filterNum|
	// 			var freq = MKNC.ar("morphFreq", 1500, suffix: (filterNum+1).asString );

	// 			// Render Low/Band/High-pass signals
	// 			var lp = BLowPass4.ar(sig, freq, rq: 0.25);
	// 			var bp = BHiPass4.ar(lp, freq: freq, rq: 1);
	// 			var hp = BHiPass4.ar(sig, freq: freq, rq: 0.3);

	// 			// Mix through signals
	// 			var morphAmount = MKNC.ar("filterMorph", 0.5, suffix:(filterNum+1).asString);
	// 			LinSelectX.ar((morphAmount * 2), [lp, bp, hp]);
	// 		});
	// 		sig
	// 	}
	// },
);

filters
)
