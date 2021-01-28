(
var envs = (
	adsr: { |dur=1, envDone=2, attack=0.1, decay=0.3, sustain=0.75, release=0.6, envcurve=(-5.0), gate=1|
	EnvGen.kr(
		Env.adsr(attack, decay, sustain, release.poll, 1.0, envcurve), 
		gate,  
		timeScale:dur,
		levelBias: 0,
		levelScale: 1.0,
		doneAction: envDone
	)
}
);

envs.keysValuesDo({|envName, env|
	MKSynthLib.addEnvelope(envName, \mono, env)
})
)
