~createUI = {
    var window, bufferNames,
    textDeck1, textDeck2, textDeck3, textDeck4,
    listDeck1, listDeck2, listDeck3, listDeck4,
    loopSlider1, loopLabel1, loopLengthLabel1, resyncButton1,
    loopSlider2, loopLabel2, loopLengthLabel2, resyncButton2,
    loopSlider3, loopLabel3, loopLengthLabel3, resyncButton3,
    loopSlider4, loopLabel4, loopLengthLabel4, resyncButton4,
    freqscope, loopLengthChoices, loopLengthLabels, updateLoopControl,
    sendPulse;

    var applyDarkStyle = { |view|
        view.background_(Color.black).stringColor_(Color.white);
    };

    sendPulse = { |deck, param, hold = 0.02|
        if(deck.notNil and: { deck.isPlaying }) {
            deck.set(param, 1);
            AppClock.sched(hold, {
                if(deck.isPlaying) { deck.set(param, 0) };
            });
        };
    };

    var resyncDeck = { |deck|
        sendPulse.(deck, \trig);
    };

    bufferNames = ~files.collect { |file| file.fileName };

    // Flags → morceaux joués
    ~playedFlags = Array.fill(bufferNames.size, { false });

    // Labels avec point devant si déjà joué
    ~getDisplayNames = {
        bufferNames.collect { |name, i|
            if (~playedFlags[i]) { "• " ++ name } { name }
        }
    };

    // Rafraîchir toutes les listes
    ~refreshAllMenus = {
        var names = ~getDisplayNames.();
        [listDeck1, listDeck2, listDeck3, listDeck4].do { |menu|
            if(menu.notNil) {
                var oldVal = menu.value;
                menu.items = names;
                menu.value = oldVal;
            }
        };
    };

    window = Window.new("Buffer Selector", Rect(100, 100, 500, 400))
        .background_(Color.black);

    // Options de longueur de boucle
    loopLengthChoices = [1, 2, 4];
    loopLengthLabels = ["1 temps", "2 temps", "1 mesure"];

    updateLoopControl = { |deck, slider, statusLabel, lengthLabel|
        var steps = loopLengthChoices.size.max(1);
        var normalized = slider.value.clip(0, 1);
        var value = (normalized * steps).round.asInteger.clip(0, loopLengthChoices.size);
        slider.value = value / steps;
        if(value == 0) {
            deck.set(\loopOn, 0);
            statusLabel.string = "Loop OFF";
            lengthLabel.string = "Durée boucle: --";
        } {
            var index = value - 1;
            var beats = loopLengthChoices[index];

            deck.set(\loopBeats, beats);

            // capturer la position de lecture AVANT d’activer le crossfade
            sendPulse.(deck, \loopTrig);

            // activer la boucle une fois la position mémorisée
            AppClock.sched(0, {
                if(deck.notNil) { deck.set(\loopOn, 1) };
            });

            statusLabel.string = "Loop ON";
            lengthLabel.string = "Durée boucle: " ++ loopLengthLabels[index];
        };
    };

    // --- Deck 1 ---
    textDeck1 = StaticText(window).string_("Player Y Buffer:"); applyDarkStyle.(textDeck1);
    listDeck1 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck1.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck1, \deck1);   // ✅ synchro transport
    };
    loopLabel1 = StaticText(window).string_("Loop OFF"); applyDarkStyle.(loopLabel1);
    loopSlider1 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200)
        .value_(0)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl| updateLoopControl.(~deck1, sl, loopLabel1, loopLengthLabel1) });
    loopLengthLabel1 = StaticText(window).string_("Durée boucle: --"); applyDarkStyle.(loopLengthLabel1);
    resyncButton1 = Button(window)
        .states_([["Resync", Color.white, Color.black]])
        .action_({ resyncDeck.(~deck1) });

    // --- Deck 2 ---
    textDeck2 = StaticText(window).string_("Player X Buffer:"); applyDarkStyle.(textDeck2);
    listDeck2 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck2.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck2, \deck2);
    };
    loopLabel2 = StaticText(window).string_("Loop OFF"); applyDarkStyle.(loopLabel2);
    loopSlider2 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200)
        .value_(0)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl| updateLoopControl.(~deck2, sl, loopLabel2, loopLengthLabel2) });
    loopLengthLabel2 = StaticText(window).string_("Durée boucle: --"); applyDarkStyle.(loopLengthLabel2);
    resyncButton2 = Button(window)
        .states_([["Resync", Color.white, Color.black]])
        .action_({ resyncDeck.(~deck2) });

    // --- Deck 3 ---
    textDeck3 = StaticText(window).string_("Player Z Buffer:"); applyDarkStyle.(textDeck3);
    listDeck3 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck3.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck3, \deck3);
    };
    loopLabel3 = StaticText(window).string_("Loop OFF"); applyDarkStyle.(loopLabel3);
    loopSlider3 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200)
        .value_(0)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl| updateLoopControl.(~deck3, sl, loopLabel3, loopLengthLabel3) });
    loopLengthLabel3 = StaticText(window).string_("Durée boucle: --"); applyDarkStyle.(loopLengthLabel3);
    resyncButton3 = Button(window)
        .states_([["Resync", Color.white, Color.black]])
        .action_({ resyncDeck.(~deck3) });

    // --- Deck 4 ---
    textDeck4 = StaticText(window).string_("Player W Buffer:"); applyDarkStyle.(textDeck4);
    listDeck4 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck4.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck4, \deck4);
    };
    loopLabel4 = StaticText(window).string_("Loop OFF"); applyDarkStyle.(loopLabel4);
    loopSlider4 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200)
        .value_(0)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl| updateLoopControl.(~deck4, sl, loopLabel4, loopLengthLabel4) });
    loopLengthLabel4 = StaticText(window).string_("Durée boucle: --"); applyDarkStyle.(loopLengthLabel4);
    resyncButton4 = Button(window)
        .states_([["Resync", Color.white, Color.black]])
        .action_({ resyncDeck.(~deck4) });

    // --- Scope ---
    freqscope = FreqScopeView(window);
    freqscope.active_(true);

    // --- Layout ---
    window.layout_(
        VLayout(
            HLayout(
                VLayout(textDeck1, listDeck1, loopLabel1, loopSlider1, loopLengthLabel1, resyncButton1),
                VLayout(textDeck2, listDeck2, loopLabel2, loopSlider2, loopLengthLabel2, resyncButton2),
                VLayout(textDeck3, listDeck3, loopLabel3, loopSlider3, loopLengthLabel3, resyncButton3),
                VLayout(textDeck4, listDeck4, loopLabel4, loopSlider4, loopLengthLabel4, resyncButton4)
            ),
            freqscope
        )
    );

    window.onClose = { window.close; freqscope.kill };
    window.front;
};

~createUI.value;
