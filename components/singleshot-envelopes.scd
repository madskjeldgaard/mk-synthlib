(
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
