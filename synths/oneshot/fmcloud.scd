{
	MKSynthLib.getEnvelopeNamesForKind.do{|envType|
		MKSynthLib.shapeWrapperKinds.do{|shapeFuncName|
			MKFilterLib.filterTypes.do{|filterType|
				var basename = "fmcloud";
				var name = "%_%_%_%".format(basename, envType, filterType, shapeFuncName).asSymbol;

				MKSynthLib.addSynthName(name, kind: \oneshot);

				SynthDef.new(name, {
					arg out=0, amp=0.51, 
					dur=4, envDone=2;
					var grainFreq = MKNC.kr("grainDensity", 10.0);
					var interGrainRatio = MKNC.kr("interGrainRatio", 1.01);
					var amountFeedback = MKNC.kr("feedback", 0.95);

					var numGrains = 4;
					var feedback = LocalIn.ar(numGrains);
					var sig = Array.fill(numGrains, {|grainNum|
						var thisGrain, thisGrainPanner;
						var trigger = TDelay.kr(Dust2.kr(grainFreq * (grainNum+1)), Rand(0.001,0.1) * dur);
						var driftParam = MKNC.kr("drift", 0.01);
						var drift = LFNoise2.kr(1).range(1,1+driftParam);
						var drift2 = LFNoise2.kr(1.1).range(1,1+driftParam);
						grainNum = grainNum + 1;

						thisGrain = FMGrain.ar(
							trigger: trigger, 
							dur: MKNC.kr("graindur", 0.002) * (grainNum/numGrains/2 + 1), 
							carfreq: MKNC.kr("grainCarFreq", 1200) * grainNum * interGrainRatio * drift, 
							modfreq: MKNC.kr("grainModFreq", 100) * grainNum * interGrainRatio * drift2, 
							index: MKNC.kr("grainFMIndex", 1.01) * grainNum * interGrainRatio, 
						);
						thisGrain = thisGrain + (feedback[grainNum%numGrains] * amountFeedback) / 2.0;

						thisGrainPanner = LFNoise2.kr(Rand(0.01,0.25));
						Pan2.ar(thisGrain, thisGrainPanner);
					});

					LocalOut.ar(LeakDC.ar(LPF.ar(sig, 1500).tanh));

					sig = Splay.ar(sig);

					sig = MKSynthLib.embedWithVCA(envType, \oneshot, sig, dur, envDone);
					sig = MKSynthLib.embedWithWaveshaper(shapeFuncName, sig);
					sig = MKFilterLib.embedWithFilter(filterType, sig);
					sig = MKSynthLib.embedWithPanner(2, sig);

					Out.ar(out, sig * amp)
				}).store
			}
		}
	}
}