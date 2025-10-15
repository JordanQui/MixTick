// ================= SynthDef BufferPlayer =================
SynthDef(\bufferPlayer, {
    |out=0, bufnum=0, trig=1, pitch=1, amp=0.5,
     low=0, mid1=0, mid2=0, high=0,
     cue=0, cuegain=1,
     loopOn=0, bpm=120, loopTrig=0,
     smoothTime=0.01, fadeTime=0.05,
     speedMix=0| // fadeTime = fondu aux bords de la boucle

    var bufFrames, baseRate, halfRate, measureDurSec, measureFrames;
    var fadeFrames, loopOnLag, fadeEnvNormal, loopMixEnv, crossEnv;
    var trigImpulse, trigEvents, speedLag;
    var makePlayer, sigNormalData, sigHalfData, sigNormal, sigHalf, sig;
    var halfSyncTrig, halfSyncPos;

    // === Infos buffer ===
    bufFrames = BufFrames.kr(bufnum);
    baseRate = BufRateScale.kr(bufnum) * pitch;
    halfRate = baseRate * 0.5;

    // === Durée d'une mesure en frames (4 temps) ===
    measureDurSec = (60 / bpm) * 4;
    measureFrames = measureDurSec * BufSampleRate.kr(bufnum);

    // === Trigger pour relancer la boucle ===
    trigEvents = HPZ1.kr(trig).max(0) + HPZ1.kr(loopTrig).max(0);
    trigImpulse = Trig1.kr(trigEvents, 0.001);

    // === Paramètres communs de fondu / boucles ===
    fadeFrames   = (fadeTime * BufSampleRate.kr(bufnum)).max(1);
    loopOnLag    = Lag.kr(loopOn, 0.1);
    fadeEnvNormal = (1 - loopOnLag);
    loopMixEnv    = loopOnLag;
    crossEnv      = Lag.kr(trigEvents, smoothTime);

    makePlayer = { |rate, syncTrig = 0, syncPos = 0|
        var phasorFree, loopStart, loopEnd, phasorLoop;
        var sigFree, sigLoop, fadeInLoop, fadeOutLoop, fadeEnvLoop, mix;
        var combinedTrig;

        // === Phasor normal (lecture libre) ===
        phasorFree = Phasor.ar(
            trig: syncTrig,
            rate: rate,
            start: 0,
            end: bufFrames,
            resetPos: syncPos
        );

        // === Points de boucle latched sur le trigger ===
        combinedTrig = trigImpulse + syncTrig;
        loopStart = Latch.kr(phasorFree, combinedTrig);
        loopEnd   = loopStart + measureFrames;

        // === Phasor en mode boucle ===
        phasorLoop = Phasor.ar(
            trig: combinedTrig,
            resetPos: loopStart,
            rate: rate,
            start: loopStart,
            end: loopEnd
        );

        // === Lecture audio ===
        sigFree = BufRd.ar(2, bufnum, phasorFree, loop: 1);
        sigLoop = BufRd.ar(2, bufnum, phasorLoop, loop: 1);

        // === Fade sur les bords de la boucle ===
        fadeInLoop  = ((phasorLoop - loopStart) / fadeFrames).clip(0, 1);
        fadeOutLoop = ((loopEnd - phasorLoop) / fadeFrames).clip(0, 1);
        fadeEnvLoop = fadeInLoop * fadeOutLoop;
        sigLoop = sigLoop * fadeEnvLoop;

        // === Crossfade normal <-> loop ===
        mix = (sigFree * fadeEnvNormal) + (sigLoop * loopMixEnv);

        // === Anti-clic supplémentaire lors d’un changement de trig ===
        mix = (mix * (1 - crossEnv)) + (sigLoop * crossEnv);
        [mix, phasorFree]
    };

    // === Resynchronisation demi-vitesse sur bascule ===
    halfSyncTrig = Trig1.kr(HPZ1.kr(speedMix).max(0), 0.001);

    sigNormalData = makePlayer.(baseRate);
    sigNormal = sigNormalData[0];

    halfSyncPos = Latch.kr(sigNormalData[1], halfSyncTrig);
    sigHalfData = makePlayer.(halfRate, halfSyncTrig, halfSyncPos);
    sigHalf = sigHalfData[0];

    // === Crossfade vitesse normale / demi-vitesse ===
    speedLag = Lag.kr(speedMix, 0.1);
    sig = (sigNormal * (1 - speedLag)) + (sigHalf * speedLag);

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
