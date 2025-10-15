~createUI = {
    var window, bufferNames,
    textDeck1, textDeck2, textDeck3, textDeck4,
    listDeck1, listDeck2, listDeck3, listDeck4,
    loopSlider1, loopLabel1, loopSlider2, loopLabel2,
    loopSlider3, loopLabel3, loopSlider4, loopLabel4,
    speedButton1, speedButton2, speedButton3, speedButton4,
    freqscope;

    var createSpeedButton;

    var applyDarkStyle = { |view|
        view.tryPerform(\background_, Color.black);
        view.tryPerform(\stringColor_, Color.white);
    };

    bufferNames = ~files.collect { |file| file.fileName };

    if(~deckSpeedState.isNil) { ~deckSpeedState = IdentityDictionary.new; };
    if(~deckBasePitch.isNil) { ~deckBasePitch = IdentityDictionary.new; };
    if(~applyDeckSpeedState.isNil) {
        ~applyDeckSpeedState = { |deck, deckKey|
            var basePitch = ~deckBasePitch[deckKey] ? ~pitch;
            var isHalfSpeed = ~deckSpeedState[deckKey] ? false;
            if(deck.notNil) {
                deck.set(\pitch, basePitch);
                deck.set(\speedMix, if(isHalfSpeed) { 1 } { 0 });
            };
        };
    };

    createSpeedButton = { |deckFunc, deckKey|
        var button, isHalfSpeed;

        isHalfSpeed = ~deckSpeedState[deckKey] ? false;
        ~deckSpeedState[deckKey] = isHalfSpeed;
        ~deckBasePitch[deckKey] = ~deckBasePitch[deckKey] ? ~pitch;

        button = Button(window)
            .background_(Color.black)
            .maxHeight_(40)
            .states_([
                ["Vitesse x1", Color.white, Color.black],
                ["Vitesse x0.5", Color.black, Color.gray(0.3)]
            ])
            .action_({ |but|
                var deck = deckFunc.value;
                var isHalf = (but.value == 1);

                ~deckSpeedState[deckKey] = isHalf;
                ~applyDeckSpeedState.(deck, deckKey);
            });

        button.tryPerform(\stringColor_, Color.white);

        button.value = if(isHalfSpeed) { 1 } { 0 };
        ~applyDeckSpeedState.(deckFunc.value, deckKey);
        button;
    };

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

    // --- Deck 1 ---
    textDeck1 = StaticText(window).string_("Player Y Buffer:"); applyDarkStyle.(textDeck1);
    listDeck1 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black);
    listDeck1.tryPerform(\stringColor_, Color.white);
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
    speedButton1 = createSpeedButton.({ ~deck1 }, \deck1);

    // --- Deck 2 ---
    textDeck2 = StaticText(window).string_("Player X Buffer:"); applyDarkStyle.(textDeck2);
    listDeck2 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black);
    listDeck2.tryPerform(\stringColor_, Color.white);
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
    speedButton2 = createSpeedButton.({ ~deck2 }, \deck2);

    // --- Deck 3 ---
    textDeck3 = StaticText(window).string_("Player Z Buffer:"); applyDarkStyle.(textDeck3);
    listDeck3 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black);
    listDeck3.tryPerform(\stringColor_, Color.white);
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
    speedButton3 = createSpeedButton.({ ~deck3 }, \deck3);

    // --- Deck 4 ---
    textDeck4 = StaticText(window).string_("Player W Buffer:"); applyDarkStyle.(textDeck4);
    listDeck4 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black);
    listDeck4.tryPerform(\stringColor_, Color.white);
    listDeck4.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck4, \deck4);
    };
    loopLabel4 = StaticText(window).string_("Free"); applyDarkStyle.(loopLabel4);
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
            loopLabel4.string = if(val == 1) { "Looped" } { "Loop OFF" };
        });
    speedButton4 = createSpeedButton.({ ~deck4 }, \deck4);

    // --- Scope ---
    freqscope = FreqScopeView(window);
    freqscope.active_(true);

    // --- Layout ---
    window.layout_(
        VLayout(
            HLayout(
                VLayout(textDeck1, listDeck1, loopLabel1, loopSlider1, speedButton1),
                VLayout(textDeck2, listDeck2, loopLabel2, loopSlider2, speedButton2),
                VLayout(textDeck3, listDeck3, loopLabel3, loopSlider3, speedButton3),
                VLayout(textDeck4, listDeck4, loopLabel4, loopSlider4, speedButton4)
            ),
            freqscope
        )
    );

    window.onClose = { window.close; freqscope.kill };
    window.front;
};

~createUI.value;
