// ================= SynthDef BufferPlayer =================
SynthDef(\bufferPlayer, {
    |out=0, bufnum=0, trig=1, pitch=1, amp=0.5,
     low=0, mid1=0, mid2=0, high=0,
     cue=0, cuegain=1,
     loopOn=0, bpm=120, loopTrig=0,
     smoothTime=0.03, fadeTime=0.12| // fadeTime = fondu aux bords de la boucle

    var bufFrames, rate, measureDurSec, measureFrames;
    var phasorNormal, loopStart, loopEnd, phasorLoop;
    var sigNormal, sigLoop, sig;
    var fadeFrames, fadeInLoop, fadeOutLoop, fadeEnvLoop;
    var loopOnLag, fadeEnvNormal, loopMixEnv;
    var trigImpulse, crossEnv, trigEvents;
    var resyncTrig, loopOffTrig, loopTrackPos, loopExitPos, loopExitPosWrap;
    var normalResetTrig, normalResetPosState, normalResetPosFeed;
    var loopStartTrig, loopActive, gatedResyncTrig, loopResetTrig;

    // === Infos buffer ===
    bufFrames = BufFrames.kr(bufnum);
    rate = BufRateScale.kr(bufnum) * pitch;

    // === Durée d'une mesure en frames (4 temps) ===
    measureDurSec = (60 / bpm) * 4;
    // ajuster la longueur de mesure selon le pitch pour garder une durée fixe
    measureFrames = measureDurSec * BufSampleRate.kr(bufnum) * pitch;

    // === Trigger pour relancer la boucle ===
    resyncTrig  = Trig1.kr(HPZ1.kr(trig).max(0), 0.001);
    loopStartTrig = Trig1.kr(HPZ1.kr(loopTrig).max(0), 0.001);
    loopOffTrig = Trig1.kr(HPZ1.kr(loopOn).min(0).abs, 0.001);

    loopOnLag = LagUD.kr(loopOn, fadeTime, fadeTime);
    loopActive = (loopOnLag > 0.5);
    gatedResyncTrig = resyncTrig * (1 - loopActive);
    loopResetTrig = loopStartTrig + gatedResyncTrig;

    trigImpulse = loopResetTrig;
    trigEvents = loopResetTrig + loopOffTrig;

    // === Gestion des resets du phasor normal ===
    normalResetTrig = resyncTrig + loopOffTrig;
    normalResetPosFeed = LocalIn.kr(1).first;

    // === Phasor normal (lecture libre) ===
    phasorNormal = Phasor.ar(
        trig: DelayN.kr(normalResetTrig, ControlDur.ir, ControlDur.ir),
        rate: rate,
        start: 0,
        end: bufFrames,
        resetPos: normalResetPosFeed
    );

    // === Points de boucle latched sur le trigger ===
    loopStart = Latch.kr(phasorNormal, loopResetTrig);
    loopEnd   = loopStart + measureFrames;

    // === Tracking de la position globale pendant la boucle ===
    loopTrackPos = loopStart + Sweep.kr(loopResetTrig, rate * SampleRate.ir * loopOnLag);
    loopExitPos  = Latch.kr(loopTrackPos, loopOffTrig);
    loopExitPosWrap = loopExitPos.wrap(0, bufFrames);

    normalResetPosState = normalResetPosFeed;
    normalResetPosState = Select.kr((resyncTrig > 0).asInteger, [normalResetPosState, 0]);
    normalResetPosState = Select.kr((loopOffTrig > 0).asInteger, [normalResetPosState, loopExitPosWrap]);
    LocalOut.kr(normalResetPosState);

    // === Phasor en mode boucle ===
    phasorLoop = Phasor.ar(
        trig: trigImpulse,
        resetPos: loopStart,
        rate: rate,
        start: loopStart,
        end: loopEnd
    );

    // === Lecture audio ===
    sigNormal = BufRd.ar(2, bufnum, phasorNormal, loop: 1);
    sigLoop   = BufRd.ar(2, bufnum, phasorLoop, loop: 1);

    // === Fade sur les bords de la boucle ===
    fadeFrames = fadeTime * BufSampleRate.kr(bufnum);
    fadeInLoop  = ((phasorLoop - loopStart) / fadeFrames).clip(0, 1);
    fadeOutLoop = ((loopEnd - phasorLoop) / fadeFrames).clip(0, 1);
    fadeEnvLoop = fadeInLoop * fadeOutLoop;
    sigLoop = sigLoop * fadeEnvLoop;

    // === Crossfade normal <-> loop ===
    fadeEnvNormal = (1 - loopOnLag);
    loopMixEnv    = loopOnLag;
    sig = (sigNormal * fadeEnvNormal) + (sigLoop * loopMixEnv);

    // === Anti-clic supplémentaire lors d’un changement de trig ===
    crossEnv = LagUD.kr(trigEvents, smoothTime, smoothTime);
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
