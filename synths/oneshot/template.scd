{
	MKSynthLib.getEnvelopeNamesForKind.do{|envType|
		MKSynthLib.shapeWrapperKinds.do{|shapeFuncName|
			MKFilterLib.filterTypes.do{|filterType|
				var basename = "template";
				var name = "%_%_%".format(basename, envType, filterType, shapeFuncName).asSymbol;

				MKSynthLib.addSynthName(name, kind: \oneshot);

				SynthDef.new(name, {
					arg out=0, amp=0.51, 
					dur=4, envDone=2;

					var sig = Silent.ar();

					sig = MKSynthLib.embedWithVCA(envType, \oneshot, sig, dur, envDone);
					sig = MKSynthLib.embedWithWaveshaper(shapeFuncName, sig);
					sig = MKFilterLib.new(filterType, sig);
					sig = MKSynthLib.embedWithPanner(2, Splay.ar(sig, spread: 0.25));
					Out.ar(out, sig * amp)
				}).store
			}
		}
	}
}
