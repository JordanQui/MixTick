// ================= SynthDef BufferPlayer =================
SynthDef(\bufferPlayer, {
    |out=0, bufnum=0, trig=1, pitch=1, amp=0.5,
     low=0, mid1=0, mid2=0, high=0,
     cue=0, cuegain=1,
     loopOn=0, bpm=120, loopTrig=0,
     smoothTime=0.01, fadeTime=0.05|

    var bufFrames, bufFramesA, bufSampleRate;
    var rate, measureDurSec, measureFrames, measureFramesA;
    var phasorNormal, phasorNormalK, pointerNormal;
    var loopStartFrames, loopStartFramesA, loopStartNorm, loopEndNorm;
    var pointerEnv, pointerLoop;
    var fadeAmount, sustainDur, loopAmpEnv;
    var sigNormal, sigLoop, sig;
    var loopOnLag, trigEvents, trigImpulse, trigAudio, crossEnv;
    var windowSize;

    // === Infos buffer ===
    bufFrames = (BufFrames.kr(bufnum) + 1e-6);
    bufSampleRate = BufSampleRate.kr(bufnum);
    bufFramesA = K2A.ar(bufFrames);
    measureDurSec = (60 / bpm.max(1e-3)) * 4;
    measureFrames = measureDurSec * bufSampleRate;
    measureFramesA = K2A.ar(measureFrames);

    // === Rate indépendant du pitch ===
    rate = BufRateScale.kr(bufnum);

    // === Trigger pour relancer la boucle ===
    trigEvents = HPZ1.kr(trig).max(0) + HPZ1.kr(loopTrig).max(0);
    trigImpulse = Trig1.kr(trigEvents, ControlDur.ir);
    trigAudio = K2A.ar(trigImpulse);

    // === Lecture libre (normal) ===
    phasorNormal = Phasor.ar(
        rate: rate,
        start: 0,
        end: bufFrames
    );
    pointerNormal = (phasorNormal / bufFramesA).wrap(0, 1);

    // === Position du loop capturée au déclenchement ===
    phasorNormalK = A2K.kr(phasorNormal);
    loopStartFrames = Latch.kr(phasorNormalK, trigImpulse);
    loopStartFramesA = K2A.ar(loopStartFrames);
    loopStartNorm = loopStartFramesA / bufFramesA;
    loopEndNorm = (loopStartFramesA + measureFramesA) / bufFramesA;

    // === Enveloppe de position pour la boucle ===
    pointerEnv = EnvGen.ar(
        Env([0, 1], [measureDurSec], 'lin'),
        trigAudio,
        doneAction: 0
    );
    pointerLoop = (loopStartNorm + pointerEnv * (loopEndNorm - loopStartNorm)).wrap(0, 1);

    // === Fenêtre temporelle pour Warp1 ===
    windowSize = (measureDurSec / 8).clip(0.02, 0.5);

    // === Enveloppe d'amplitude de la boucle (une mesure) ===
    fadeAmount = fadeTime.min(measureDurSec * 0.5);
    sustainDur = (measureDurSec - (2 * fadeAmount)).max(0.0);
    loopAmpEnv = EnvGen.ar(
        Env([0, 1, 1, 0], [fadeAmount, sustainDur, fadeAmount.max(0.0001)], 'lin'),
        trigAudio,
        doneAction: 0
    );

    // === Lecture Warp1 : tempo/pitch indépendants ===
    sigNormal = Warp1.ar(2, bufnum, pointerNormal, pitch, windowSize, -1, 8, 0.0, 2);
    sigLoop   = Warp1.ar(2, bufnum, pointerLoop,  pitch, windowSize, -1, 8, 0.0, 2) * loopAmpEnv;

    // === Mix normal <-> loop ===
    loopOnLag = Lag.kr(loopOn, 0.1);
    sig = (sigNormal * (1 - loopOnLag)) + (sigLoop * loopOnLag);

    // === Anti-clic supplémentaire lors d’un changement de trig ===
    crossEnv = Lag.kr(trigEvents, smoothTime);
    sig = (sig * (1 - crossEnv)) + (sigLoop * crossEnv);

    // === EQ ===
    sig = BLowShelf.ar(sig, freq: 100, rs: 0.7, db: low);
    sig = BPeakEQ.ar(sig, freq: 300, rq: 0.7, db: mid1);
    sig = BPeakEQ.ar(sig, freq: 800, rq: 0.7, db: mid2);
    sig = BHiShelf.ar(sig, freq: 4000, rs: 0.7, db: high);

    // === Sorties ===
    Out.ar(out, sig.tanh * amp);                 // Master
    Out.ar(2,   sig.tanh * cue * cuegain);       // Cue (casque)
}).add;

// ================= Limiteur global =================
SynthDef(\outputLimiter, {|input=0, out=0|
    var inSig = In.ar(input, 2);
    var limited = Limiter.ar(inSig, 0.99, 0.01);
    Out.ar(out, limited.tanh);
}).add;
