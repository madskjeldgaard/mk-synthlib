(
// Same as Env.adsr but with release node set to nil to make it triggered
tadsr:{ |dur=1, envDone=2, attack=0.01, decay=0.3, sustainLevel=0.5, release=1.0, peakLevel=1.0, curve = -4.0, bias = 0.0, gate=1|
	EnvGen.kr(
		Env.new(			
			[0, peakLevel, peakLevel * sustainLevel, 0] + bias,
			[attack, decay, release],
			curve
		),
		gate,  
		timeScale:dur,
		levelBias: 0,
		levelScale: 1.0,
		doneAction: envDone
	)
},
perc: { |dur=1, envDone=2, attack=0.1, release=0.9, envcurve=(-5.0), gate=1|
	EnvGen.kr(
		Env.perc(attack, release,  level: 1.0,  curve: envcurve),
		gate,  
		timeScale:dur,
		levelBias: 0,
		levelScale: 1.0,
		doneAction: envDone
	)
},
sine:{ |dur=1, envDone=2, gate=1|
	EnvGen.kr(
		Env.sine(1,  level: 1.0),
		gate,  
		timeScale:dur,
		levelBias: 0,
		levelScale: 1.0,
		doneAction: envDone
	)
},
triangle:{ |dur=1, envDone=2, gate=1|
	EnvGen.kr(
		Env.triangle(1,  level: 1.0),
		gate,  
		timeScale:dur,
		levelBias: 0,
		levelScale: 1.0,
		doneAction: envDone
	)
}
)
