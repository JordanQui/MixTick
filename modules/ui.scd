~createUI = {
    var window, bufferNames,
    textDeck1, textDeck2, textDeck3, textDeck4,
    listDeck1, listDeck2, listDeck3, listDeck4,
    loopSlider1, loopLabel1, loopLengthLabel1, loopLengthMenu1, resyncButton1,
    loopSlider2, loopLabel2, loopLengthLabel2, loopLengthMenu2, resyncButton2,
    loopSlider3, loopLabel3, loopLengthLabel3, loopLengthMenu3, resyncButton3,
    loopSlider4, loopLabel4, loopLengthLabel4, loopLengthMenu4, resyncButton4,
    freqscope, loopLengthChoices, loopLengthLabels, updateLoopLength;

    var applyDarkStyle = { |view|
        view.background_(Color.black).stringColor_(Color.white);
    };

    var resyncDeck = { |deck|
        deck.set(\trig, 1);
        AppClock.sched(0.01, { deck.set(\trig, 0) });
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

    updateLoopLength = { |deck, slider, label, menu|
        var index = menu.value;
        if(index.isNil) { index = 2 }; // valeur par défaut : 1 mesure
        index = index.clip(0, loopLengthChoices.size - 1);
        menu.value = index;
        var beats = loopLengthChoices[index];
        deck.set(\loopBeats, beats);
        label.string = "Durée boucle: " ++ loopLengthLabels[index];
        if(slider.value.asInteger == 1) {
            deck.set(\loopTrig, 1);
            AppClock.sched(0.01, { deck.set(\loopTrig, 0) });
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
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck1.set(\loopOn, val);
            if(val == 1) {
                ~deck1.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck1.set(\loopTrig, 0) });
            };
            loopLabel1.string = if(val == 1) { "Loop ON" } { "Loop OFF" };
        });
    loopLengthLabel1 = StaticText(window).string_("Durée boucle: 1 mesure"); applyDarkStyle.(loopLengthLabel1);
    loopLengthMenu1 = PopUpMenu(window)
        .items_(loopLengthLabels)
        .background_(Color.black)
        .stringColor_(Color.white)
        .value_(2)
        .action_({ |menu| updateLoopLength.(~deck1, loopSlider1, loopLengthLabel1, menu) });
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
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck2.set(\loopOn, val);
            if(val == 1) {
                ~deck2.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck2.set(\loopTrig, 0) });
            };
            loopLabel2.string = if(val == 1) { "Loop ON" } { "Loop OFF" };
        });
    loopLengthLabel2 = StaticText(window).string_("Durée boucle: 1 mesure"); applyDarkStyle.(loopLengthLabel2);
    loopLengthMenu2 = PopUpMenu(window)
        .items_(loopLengthLabels)
        .background_(Color.black)
        .stringColor_(Color.white)
        .value_(2)
        .action_({ |menu| updateLoopLength.(~deck2, loopSlider2, loopLengthLabel2, menu) });
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
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck3.set(\loopOn, val);
            if(val == 1) {
                ~deck3.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck3.set(\loopTrig, 0) });
            };
            loopLabel3.string = if(val == 1) { "Loop ON" } { "Loop OFF" };
        });
    loopLengthLabel3 = StaticText(window).string_("Durée boucle: 1 mesure"); applyDarkStyle.(loopLengthLabel3);
    loopLengthMenu3 = PopUpMenu(window)
        .items_(loopLengthLabels)
        .background_(Color.black)
        .stringColor_(Color.white)
        .value_(2)
        .action_({ |menu| updateLoopLength.(~deck3, loopSlider3, loopLengthLabel3, menu) });
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
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck4.set(\loopOn, val);
            if(val == 1) {
                ~deck4.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck4.set(\loopTrig, 0) });
            };
            loopLabel4.string = if(val == 1) { "Loop ON" } { "Loop OFF" };
        });
    loopLengthLabel4 = StaticText(window).string_("Durée boucle: 1 mesure"); applyDarkStyle.(loopLengthLabel4);
    loopLengthMenu4 = PopUpMenu(window)
        .items_(loopLengthLabels)
        .background_(Color.black)
        .stringColor_(Color.white)
        .value_(2)
        .action_({ |menu| updateLoopLength.(~deck4, loopSlider4, loopLengthLabel4, menu) });
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
                VLayout(textDeck1, listDeck1, loopLabel1, loopSlider1, loopLengthLabel1, loopLengthMenu1, resyncButton1),
                VLayout(textDeck2, listDeck2, loopLabel2, loopSlider2, loopLengthLabel2, loopLengthMenu2, resyncButton2),
                VLayout(textDeck3, listDeck3, loopLabel3, loopSlider3, loopLengthLabel3, loopLengthMenu3, resyncButton3),
                VLayout(textDeck4, listDeck4, loopLabel4, loopSlider4, loopLengthLabel4, loopLengthMenu4, resyncButton4)
            ),
            freqscope
        )
    );

    window.onClose = { window.close; freqscope.kill };
    window.front;
};

~createUI.value;
