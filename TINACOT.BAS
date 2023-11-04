10000 REM :::::::::::::::::::::::::::::::::::::::::::::
10010 REM :: TINACOT FOR AgonLight (BBC BASIC v3)    ::
10020 REM :::::::::::::::::::::::::::::::::::::::::::::
10030 REM :: 20231103: Ver 1.2 - Use new VDP MODEs   ::
10040 REM :::::::::::::::::::::::::::::::::::::::::::::
10050 REM :: This original game was submitted to the ::
10060 REM :: Olimex Week Programming Challenge       ::
10070 REM :: Issue #4                                ::
10080 REM :::::::::::::::::::::::::::::::::::::::::::::
10090 REM :: It is best experienced in a 40+ column, ::
10100 REM :: 64-color display mode.                  ::
10110 REM :::::::::::::::::::::::::::::::::::::::::::::
10120 CLEAR
10130 REPEAT CLS:SY$=FN_TO_UPPER(FN_PROMPT(0,0,"TARGET (A)gon or (B)BC B-SDL:","A")):UNTIL SY$ = "A" OR SY$ = "B"
10140 IF SY$ = "B" THEN LEFT = 136:RIGHT = 137:DOWN = 138:UP = 139:DL% = 10:MO% = 9:ELSE LEFT = 8:RIGHT = 21:DOWN = 10:UP = 11:DL% = 14:MO% = 12
10150 IF SY$ = "A" THEN REPEAT CLS:MO$=FN_PROMPT_FOR_NUMBERS(0,0,"MODE (0,3,4,8,9,12,13,...):",STR$(MO%),3):UNTIL VAL(MO$) >= 0:MO% = VAL(MO$)
10160 MODE MO%
10170 PROC_SETUP
10180 ON ERROR PROC_HANDLE_ERROR:REM Handle ESC key
10190 :
10200 PROC_WELCOME
10210 REPEAT
10220   PROC_NEW_GAME(NOT FN_LEVEL_COMPLETE)
10230   PROC_MAIN_LOOP:REM Invoke main loop
10240   GameOver% = Won% OR Lost%
10250   IF GameOver% THEN PROC_GAME_OVER:Resp$ = FN_PLAY_AGAIN:IF Resp$ = "Y" THEN GameOver% = FALSE
10260 UNTIL GameOver%
10270 PROC_GOODBYE(GameName$)
10280 END
10290 :
10300 REM ::::::::::::::::::::
10310 REM ::   Setup Game   ::
10320 REM ::::::::::::::::::::
10330 DEF PROC_SETUP
10340 MAXINT% = &3B9AC9FF:GameName$ = "TINACOT":HighScore% = 2500:MaxLevel% = 5
10350 BLACK = 0:RED = 1:GREEN = 2:YELLOW = 3:BLUE = 4:MAGENTA = 5:CYAN = 6:WHITE = 7:C_ORANGE = 8 + (SY$ = "A" AND FN_COLORCOUNT = &40) *-50
10360 P_TOP = 0:P_LEFT = 1:P_RIGHT = 2:P_BOTTOM = 3:BLANK = 32:HASH = 35:I_HASH = 36
10370 PWN_1 = 150:PWN_2 = 151:PWN_3 = 152:PWN_4 = 153:PWN_5 = 154:PWN_6 = 155:PWN_7 = 156
10380 B_VERT = 140:B_HORZ = 141:B_UR = 142:B_UL = 143:B_DL = 144:B_DR = 145
10390 IF SY$ = "A" THEN CW% = FN_getByteVDP(&13):CH% = FN_getByteVDP(&14):ELSE CW% = 40:CH% = 24
10400 TargetSequence$ = "":Side% = (CH% - 3) DIV 3:LevelComplete% = FALSE
10410 P$ = CHR$(PWN_1)+CHR$(PWN_2)+CHR$(PWN_3)+CHR$(PWN_4)+CHR$(PWN_5)+CHR$(PWN_6)+CHR$(PWN_7)
10420 C$ = CHR$(CYAN)+CHR$(BLUE)+CHR$(C_ORANGE)+CHR$(YELLOW)+CHR$(GREEN)+CHR$(MAGENTA)+CHR$(RED)
10430 PR$ = STRING$(3, P$)+STRING$(5 * LEN(P$), " ")
10440 DIM PZ%(3, 1), AZ%(3), AN%(3), PR LEN(PR$)
10450 PZ%(0, 0) = Side%:PZ%(0, 1) = 0:PZ%(1, 0) = 0:PZ%(1, 1) = Side%:PZ%(2, 0) = Side%*2:PZ%(2, 1) = Side%:PZ%(3, 0) = Side%:PZ%(3, 1) = Side%*2
10460 $PR = PR$
10470 DW% = (CW% - Side%*2) DIV 2: DH% = (CH% - Side%*2) DIV 2
10480 TK = TIME:PROC_SLEEP(100):TK = TIME - TK:REM CALIBRATE TIME TICKS
10490 SP% = INT(30 * TK / 100 * 7 / Side%):REM Speed Throttler (smaller value speeds up the game)
10500 BX$ = CHR$(B_UR) + CHR$(B_HORZ) + CHR$(B_UL) + CHR$(B_VERT) + CHR$(B_DL) + CHR$(B_HORZ) + CHR$(B_DR) + CHR$(B_VERT)
10510 PROC_REDEFINE_COLORS
10520 PROC_REDEFINE_CHARS
10530 PROC_HISCORE_READ(GameName$)
10540 ENDPROC
10550 :
10560 REM ::::::::::::::::::::::
10570 REM ::     New Game     ::
10580 REM ::::::::::::::::::::::
10590 DEF PROC_NEW_GAME(fullReset%)
10600 LOCAL i%
10610 TI = 0:TIME = 0:Lost% = FALSE:Won% = FALSE:PR_Pointer% = 0
10620 IF fullReset% = TRUE THEN Score% = 0:Level% = 0
10630 FOR i% = 0 TO 3:AZ%(i%) = -1:AN%(i%) = -1:NEXT i%
10640 CLS:PROC_HIDE_CURSOR
10650 PROC_NEW_LEVEL
10660 PROC_DRAW_PLAYING_FIELD(WHITE):PROC_DISPLAY_SEQUENCE_INFO(1):PROC_SHUFFLE_PR
10670 VDU 17,YELLOW:PROC_FULL_CENTER_TEXT("GET READY!"):REM Display GET READY! Message
10680 PROC_LEVEL_START_MUSIC
10690 PROC_SLEEP(200):PROC_FULL_CENTER_TEXT(STRING$(10, " ")):REM Erase GET READY! Message after 2 Seconds
10700 PROC_DRAW_CENTER_POINT(ASC("+"), WHITE)
10710 PROC_DISPLAY_SCORES
10720 ENDPROC
10730 :
10740 REM ::::::::::::::::::::::
10750 REM ::     New Level    ::
10760 REM ::::::::::::::::::::::
10770 DEF PROC_NEW_LEVEL
10780 Level% = Level% + 1:LevelComplete% = FALSE:Sequence$ = "":SQ% = Level% * 2 + 2:TargetSequence$ = FN_RND_SEQ(SQ%)
10790 ENDPROC
10800 :
10810 REM ::::::::::::::::::::::
10820 REM ::     Main Loop    ::
10830 REM ::::::::::::::::::::::
10840 DEF PROC_MAIN_LOOP
10850 LOCAL dd%, prevsec%, sec%, tt%
10860 sec% = -1
10870 REPEAT
10880   TI = FN_INT_TIME
10890   prevsec% = sec%:sec% = FN_INT_TIME DIV TK
10900   PROC_DISPLAY_SEQUENCE_INFO(2)
10910   REM IF FN_IS_TIME(sec%, prevsec%, 30) THEN
10920   PROC_ADVANCE_PAWNS
10930   IF SY$ <> "A" THEN dd% = INKEY(INT(TK * 2 * DL% / 100)):PROC_EMPTY_KEYBOARD_BUFFER:ELSE dd% = FN_GET_KEY(INT(TK * 2 * DL% / 100))
10940   dd% = FN_MAP_INPUT(dd%)
10950   IF dd% >= 0 THEN PROC_ATTACK_PAWN(dd%)
10960   PROC_DISPLAY_SCORES:REM Update score display
10970   tt% = FN_INT_TIME - TI:PROC_SLEEP((tt% < SP%) * -(SP% - tt%)):REM Throttle if necessary
10980 UNTIL LevelComplete% OR Lost% OR Won%
10990 ENDPROC
11000 :
11010 REM ::::::::::::::::::::::::
11020 REM :: Draw Playing Field ::
11030 REM ::::::::::::::::::::::::
11040 DEF PROC_DRAW_PLAYING_FIELD(color%)
11050 LOCAL ch%, i%, j%
11060 FOR i% = 0 TO Side%*2
11070   FOR j% = 0 TO Side%*2
11080     ch% = (((i% = 0 OR i% = Side%*2) AND (j% < Side%-1 OR j% > Side%+1)) OR ((j% = 0 OR j% = Side%*2) AND (i% < Side%-1 OR i% > Side%+1))) * -HASH
11090     ch% = ch% + ((j% = 0 AND i% = Side%-1) OR (j% = Side%*2 AND i% = Side%+1) OR (i% = Side%-1 AND j% = 0) OR (i% = Side%+1 AND j% = Side%*2) OR (i% = 0 AND j% = Side%-1) OR (i% = Side%*2 AND j% = Side%+1)) * -ASC("\")
11100     ch% = ch% + ((j% = 0 AND i% = Side%+1) OR (j% = Side%*2 AND i% = Side%-1) OR (i% = Side%+1 AND j% = 0) OR (i% = Side%-1 AND j% = Side%*2) OR (i% = 0 AND j% = Side%+1) OR (i% = Side%*2 AND j% = Side%-1)) * -ASC("/")
11110     ch% = ch% + (ch% = 0) * -32
11120     VDU 31, DW% + j%, DH% + i%, 17, color%, ch%
11130   NEXT j%
11140 NEXT i%
11150 ENDPROC
11160 :
11170 REM :::::::::::::::::::::::::
11180 REM ::  Draw Center Point  ::
11190 REM :::::::::::::::::::::::::
11200 DEF PROC_DRAW_CENTER_POINT(ch%, co%)
11210 VDU 31, DW% + Side%, DH% + Side%, 17, co%, ch%
11220 ENDPROC
11230 :
11240 REM ::::::::::::::::::::::::::::::
11250 REM ::  Highlight Center Point  ::
11260 REM ::::::::::::::::::::::::::::::
11270 DEF PROC_HIGHLIGHT_CENTER_POINT
11280 LOCAL nx%, ny%, ch%, co%, j%, x%, y%
11290 nx% = DW% + Side%
11300 ny% = DH% + Side%
11310 COLOUR 128+RED
11320 FOR j% = 0 TO 7
11330   IF (j% < 3) THEN x% = nx% + (j% - 1):y% = ny% - 1
11340   IF (j% > 2 AND j% < 5) THEN x% = nx% + (j% = 3) + (j% = 4) *-1:y% = ny%
11350   IF (j% > 4) THEN x% = nx% + (j% - 6):y% = ny% + 1
11360   VDU 31, x%, y%, 17, BLACK, ASC("*")
11370 NEXT j%
11380 COLOUR 128+BLACK
11390 ENDPROC
11400 :
11410 REM :::::::::::::::::::::::::::::
11420 REM :: Shuffle Pawn Randomizer ::
11430 REM :::::::::::::::::::::::::::::
11440 DEF PROC_SHUFFLE_PR
11450 LOCAL i%, l%, n%, t%
11460 i% = 0:l% = LEN($PR)
11470 REPEAT
11480   t% = PR?i%
11490   n% = FN_RND_INT(0, l% - 1)
11500   PR?i% = PR?n%
11510   PR?n% = t%
11520   i% = i% + 1
11530 UNTIL i% = l%
11540 ENDPROC
11550 :
11560 REM :::::::::::::::
11570 REM :: Find Pawn ::
11580 REM :::::::::::::::
11590 DEF FN_FIND_PAWN(ch%)
11600 LOCAL i%, l%, r%
11610 r% = -1:i% = 1:l% = LEN(P$)
11620 REPEAT
11630   IF ASC(MID$(P$, i%, 1)) = ch% THEN r% = i%
11640   i% = i% + 1
11650 UNTIL i% > l% OR r% <> -1
11660 := r%
11670 :
11680 REM ::::::::::::::::::::::::
11690 REM :: Find Color of Pawn ::
11700 REM ::::::::::::::::::::::::
11710 DEF FN_FIND_PAWN_COLOR(ch%)
11720 LOCAL i%
11730 r% = -1:i% = FN_FIND_PAWN(ch%)
11740 IF i% > 0 THEN r% = ASC(MID$(C$, i%, 1))
11750 := r%
11760 :
11770 REM :::::::::::::::::::::::::::
11780 REM :: Next Pawn in Sequence ::
11790 REM :::::::::::::::::::::::::::
11800 DEF FN_NEXT_PAWN_IN_SEQ
11810 LOCAL l%
11820 l% = LEN(Sequence$)
11830 := ASC(MID$(TargetSequence$, l% + 1, 1))
11840 :
11850 REM :::::::::::::::::::::::::::
11860 REM :: Display Sequence Info ::
11870 REM :::::::::::::::::::::::::::
11880 DEF PROC_DISPLAY_SEQUENCE_INFO(startRow%)
11890 LOCAL ch%, co%, i%, l%, s%, t%, u%
11900 i% = 1:l% = LEN(Sequence$):t% = LEN(TargetSequence$):s% = (CW% - t%) DIV 2:u% = 0
11910 REPEAT
11920   IF 1 = startRow% THEN ch% = ASC(MID$(TargetSequence$, i%, 1)):co% = FN_FIND_PAWN_COLOR(ch%):VDU 31, s% + i%, u% + 1, 17, co%, ch%
11930   IF l% >= i% THEN ch% = ASC(MID$(Sequence$, i%, 1)):co% = FN_FIND_PAWN_COLOR(ch%):VDU 31, s% + i%, u% + 3, 17, co%, ch%
11940   IF (i% < l% + 1 AND MID$(TargetSequence$, i%, 1) <> MID$(Sequence$, i%, 1)) THEN Lost% = TRUE:PROC_DRAW_CENTER_POINT(ASC("*"), RED):PROC_HIGHLIGHT_CENTER_POINT
11950   IF NOT Lost% THEN IF i% = l% + 1 THEN VDU 31, s% + i%, u% + 2, 17, WHITE, ASC("+"):ELSE VDU 31, s% + i%, u% + 2, 17, BLACK, BLANK
11960   IF Lost% THEN VDU 31, s% + i%, u% + 2, 17, RED, ASC("*")
11970   i% = i% + 1
11980 UNTIL i% > t% OR Lost% = TRUE
11990 IF (l% = t% AND NOT Lost%) THEN LevelComplete% = TRUE
12000 ENDPROC
12010 :
12020 REM ::::::::::::::::::::::
12030 REM :: Is Correct Pawn? ::
12040 REM ::::::::::::::::::::::
12050 DEF FN_IS_CORRECT_PAWN
12060 LOCAL ch%, l%
12070 l% = LEN(Sequence$):IF l% > 0 THEN ch% = ASC(MID$(Sequence$, l%, 1)):ELSE ch% = 0
12080 := (ch% = ASC(MID$(TargetSequence$, l%, 1)))
12090 :
12100 REM :::::::::::::::::
12110 REM :: Attack Pawn ::
12120 REM :::::::::::::::::
12130 DEF PROC_ATTACK_PAWN(i%)
12140 LOCAL ch%, np%
12150 ch% = -1:IF AN%(i%) > 0 THEN ch% = ASC(MID$(P$, AN%(i%), 1))
12160 np% = FN_NEXT_PAWN_IN_SEQ
12170 IF np% = ch% THEN Lost% = TRUE:PROC_HIGHLIGHT_PAWN(i%):ELSE PROC_SOUND(np% + 67, 4):PROC_DISPLAY_PAWN(i%, TRUE)::Score% = Score% + (AZ%(i%) + 1) * 10:AN%(i%) = -1:AZ%(i%) = -1
12180 ENDPROC
12190 :
12200 REM :::::::::::::::::::
12210 REM :: Advance Pawns ::
12220 REM :::::::::::::::::::
12230 DEF PROC_ADVANCE_PAWNS
12240 LOCAL flag%, i%
12250 flag% = FALSE:i% = P_TOP
12260 REPEAT
12270   IF AZ%(i%) <> -1 THEN PROC_ADVANCE_PAWN(i%):ELSE IF flag% = FALSE THEN flag% = FN_INTRODUCE_PAWN(i%)
12280   i% = i% + 1
12290 UNTIL i% > P_BOTTOM
12300 ENDPROC
12310 :
12320 REM ::::::::::::::::::::::
12330 REM :: Introduce A Pawn ::
12340 REM ::::::::::::::::::::::
12350 DEF FN_INTRODUCE_PAWN(i%)
12360 LOCAL n%, r%
12370 n% = PR?PR_Pointer%
12380 AN%(i%) = FN_FIND_PAWN(n%)
12390 PR_Pointer% = (PR_Pointer% + 1) MOD LEN($PR)
12400 r% = AN%(i%) > 0 AND AN%(i%) <> BLANK
12410 IF r% THEN AZ%(i%) = 0:PROC_DISPLAY_PAWN(i%, FALSE)
12420 := r%
12430 :
12440 REM ::::::::::::::::::::
12450 REM :: Advance A Pawn ::
12460 REM ::::::::::::::::::::
12470 DEF PROC_ADVANCE_PAWN(i%)
12480 PROC_DISPLAY_PAWN(i%, TRUE)
12490 AZ%(i%) = AZ%(i%) + 1
12500 IF AZ%(i%) = Side% THEN PROC_PAWN_REACHED_CENTER(i%):ELSE PROC_DISPLAY_PAWN(i%, FALSE):PROC_SOUND(AN%(i%) + 200, 1.05)
12510 ENDPROC
12520 :
12530 REM :::::::::::::::::::::::::
12540 REM :: Pawn Reached Center ::
12550 REM :::::::::::::::::::::::::
12560 DEF PROC_PAWN_REACHED_CENTER(n%)
12570 LOCAL i%
12580 Sequence$ = Sequence$ + MID$(P$, AN%(n%), 1):REM Update the sequence played so far
12590 FOR i% = 0 TO 1:PROC_SOUND(AN%(n%) + 142, 4):NEXT i%:REM Make a sound
12600 AN%(n%) = -1:AZ%(n%) = -1:REM Reset tracking variables
12610 PROC_DRAW_CENTER_POINT(ASC("+"), WHITE)
12620 IF FN_IS_CORRECT_PAWN THEN Score% = Score% + LEN(Sequence$)
12630 PROC_DISPLAY_SEQUENCE_INFO(2):REM Update display of target sequence and played sequence
12640 PROC_SLEEP(10):REM Brief Pause
12650 ENDPROC
12660 :
12670 REM ::::::::::::::::::
12680 REM :: Display Pawn ::
12690 REM ::::::::::::::::::
12700 DEF PROC_DISPLAY_PAWN(i%, blank%)
12710 LOCAL nx%, ny%, ch%, co%
12720 nx% = PZ%(i%, 0) + (i% = P_TOP OR i% = P_BOTTOM) * 0 + (i% = P_LEFT) * -AZ%(i%) + (i% = P_RIGHT) * AZ%(i%)
12730 ny% = PZ%(i%, 1) + (i% = P_LEFT OR i% = P_RIGHT) * 0 + (i% = P_TOP) * -AZ%(i%) + (i% = P_BOTTOM) * AZ%(i%)
12740 ch% = (blank% <> FALSE) * -BLANK + (blank% = FALSE) * -(ASC(MID$(P$, AN%(i%), 1)))
12750 co% = (blank% <> FALSE) * -BLACK + (blank% = FALSE) * -(ASC(MID$(C$, AN%(i%), 1)))
12760 VDU 31, DW% + nx%, DH% + ny%, 17, co%, ch%
12770 ENDPROC
12780 :
12790 REM ::::::::::::::::::::
12800 REM :: Highlight Pawn ::
12810 REM ::::::::::::::::::::
12820 DEF PROC_HIGHLIGHT_PAWN(i%)
12830 LOCAL nx%, ny%, ch%, co%, j%, x%, y%
12840 ch% = ASC(MID$(P$, AN%(i%), 1))
12850 co% = FN_FIND_PAWN_COLOR(ch%)
12860 nx% = PZ%(i%, 0) + (i% = P_TOP OR i% = P_BOTTOM) * 0 + (i% = P_LEFT) * -AZ%(i%) + (i% = P_RIGHT) * AZ%(i%)
12870 ny% = PZ%(i%, 1) + (i% = P_LEFT OR i% = P_RIGHT) * 0 + (i% = P_TOP) * -AZ%(i%) + (i% = P_BOTTOM) * AZ%(i%)
12880 COLOUR 128 + co%
12890 FOR j% = 0 TO 7
12900   IF (j% < 3) THEN x% = nx% + (j% - 1):y% = ny% - 1
12910   IF (j% > 2 AND j% < 5) THEN x% = nx% + (j% = 3) + (j% = 4) *-1:y% = ny%
12920   IF (j% > 4) THEN x% = nx% + (j% - 6):y% = ny% + 1
12930   VDU 31, DW% + x%, DH% + y%, 17, BLACK, ASC("*")
12940 NEXT j%
12950 COLOUR 128+BLACK
12960 ENDPROC
12970 :
12980 REM :::::::::::::::::::
12990 REM ::    Welcome    ::
13000 REM :::::::::::::::::::
13010 DEF PROC_WELCOME
13020 LOCAL boxh%, boxw%, c%, cc%, ch$, co%, ex%, perimeter%, t%, t$, ux%, uy%
13030 ch% = ASC("*"):boxh% = FN_MIN(CH%, 19):boxw% = FN_MIN(CW%, 40):cc% = 0:ex% = FALSE:perimeter% = 2 * (boxw% + boxh% - 2):t% = 2:ux% = (CW% - boxw%) DIV 2:uy% = 0:co% = 0
13040 PROC_DEFAULT_COLORS:CLS:PROC_HIDE_CURSOR
13050 PRINT TAB(0, uy% + 2);
13060 PROC_CENTER("Welcome to " + CHR$(17)+CHR$(YELLOW) + GameName$ + CHR$(17)+CHR$(WHITE)+ "..."):PRINT:PRINT
13070 PROC_CENTER(CHR$(17) + CHR$(C_ORANGE) + "TINACOT"):PRINT
13080 PROC_CENTER("Is Not A Clone Of Tetris" + CHR$(17) + CHR$(WHITE)):PRINT:PRINT
13090 PROC_CENTER("Build out the sequence by only"):PRINT
13100 PROC_CENTER("allowing a piece which matches"):PRINT
13110 PROC_CENTER("the current target piece to reach"):PRINT
13120 PROC_CENTER("the center point (+). Use the"):PRINT
13130 PROC_CENTER("Arrow Keys to repel any and all"):PRINT
13140 PROC_CENTER("NON-matching pieces before they"):PRINT
13150 PROC_CENTER("can reach the center point (+)."):PRINT:PRINT
13160 COLOUR CYAN:PROC_CENTER("Hit a key to continue")
13170 PROC_CLOCKWISE_BOX(ux% + 1, uy% + 1, boxw% - 2, boxh% - 2, CYAN)
13180 REPEAT
13190   PROC_CLOCKWISE_PLOT(cc%, BLACK, BLANK, ux%, uy%, boxw%, boxh%)
13200   cc% = (cc% + 1) MOD perimeter%:IF cc% = 1 THEN co% = (co% + 1) MOD 7 + 1
13210   PROC_CLOCKWISE_PLOT(cc%, co%, ch%, ux%, uy%, boxw%, boxh%)
13220   IF SY$ = "A" THEN c% = INKEY(DL%):PROC_EMPTY_KEYBOARD_BUFFER:ELSE c% = INKEY(TK/DL%)
13230   ex% = (c% > 0)
13240 UNTIL ex%
13250 PROC_DEFAULT_COLORS:CLS:boxh% = FN_MIN(CH%, 16):cc% = 0:ex% = FALSE:perimeter% = 2 * (boxw% + boxh% - 2)
13260 PRINT TAB(0, uy% + 2);
13270 PROC_CENTER("Be careful not to repel a"):PRINT
13280 PROC_CENTER("matching piece, which can occur"):PRINT
13290 PROC_CENTER("when multiple copies of it are"):PRINT
13300 PROC_CENTER("advancing toward the center"):PRINT
13310 PROC_CENTER("simultaneously."):PRINT:PRINT
13320 PROC_CENTER("Complete " + STR$(MaxLevel%) + " levels"):PRINT
13330 PROC_CENTER("to win the game."):PRINT
13340 COLOUR WHITE:PROC_CENTER(" Good luck and have fun!"):PRINT:PRINT
13350 COLOUR GREEN:PROC_CENTER("Hit a key to begin playing")
13360 PROC_CLOCKWISE_BOX(ux% + 1, uy% + 1, boxw% - 2, boxh% - 2, CYAN)
13370 REPEAT
13380   PROC_CLOCKWISE_PLOT(cc%, BLACK, BLANK, ux%, uy%, boxw%, boxh%)
13390   cc% = (cc% + 1) MOD perimeter%:IF cc% = 1 THEN co% = (co% + 1) MOD 7 + 1
13400   PROC_CLOCKWISE_PLOT(cc%, co%, ch%, ux%, uy%, boxw%, boxh%)
13410   IF SY$ = "A" THEN c% = INKEY(DL%):PROC_EMPTY_KEYBOARD_BUFFER:ELSE c% = INKEY(TK/DL%)
13420   ex% = (c% > 0)
13430 UNTIL ex%
13440 PROC_DEFAULT_COLORS
13450 ENDPROC
13460 :
13470 REM ::::::::::::::::::::::
13480 REM ::  Level Complete  ::
13490 REM ::::::::::::::::::::::
13500 DEF FN_LEVEL_COMPLETE
13510 LOCAL r%
13520 r% = LevelComplete%
13530 IF r% THEN VDU 17,CYAN:PROC_FULL_CENTER_TEXT("LEVEL COMPLETE"):PROC_TADA:PROC_SLEEP(200):PROC_FULL_CENTER_TEXT(STRING$(14, " ")):IF Level% + 1 > MaxLevel% THEN Won% = TRUE:r% = FALSE
13540 := r%
13550 :
13560 REM :::::::::::::::::
13570 REM ::  Game Over  ::
13580 REM :::::::::::::::::
13590 DEF PROC_GAME_OVER
13600 LOCAL co%, msg$
13610 IF Lost% THEN co% = RED:msg$ = "YOU LOSE!":ELSE co% = GREEN:msg$ = "YOU WIN!!!"
13620 VDU 17,co%:VDU 31, 0, CH% DIV 2 + 4:PROC_FULL_CENTER_TEXT(msg$)
13630 IF Lost% THEN PROC_WAH_WAH:ELSE PROC_CHARGE
13640 PROC_SLEEP(200)
13650 PROC_HISCORE_WRITE(GameName$)
13660 ENDPROC
13670 :
13680 REM :::::::::::::::::
13690 REM :: Say Goodbye ::
13700 REM :::::::::::::::::
13710 DEF PROC_GOODBYE(game$)
13720 PROC_HIDE_CURSOR
13730 CLS:PROC_FULL_CENTER_TEXT("So long and thank you for playing...")
13740 FOR i% = 0 TO FN_CENTER(game$) - 1:PRINTTAB(0, CH% DIV 2 + 2)STRING$(i%, " ")CHR$(17)CHR$(i% MOD 7 + 1)game$:PROC_SLEEP(20):NEXT i%
13750 PROC_DEFAULT_COLORS
13760 PROC_SHOW_CURSOR
13770 ENDPROC
13780 :
13790 REM :::::::::::::::::::::::
13800 REM :: Play Another Game ::
13810 REM :::::::::::::::::::::::
13820 DEF FN_PLAY_AGAIN
13830 LOCAL message$, r$
13840 message$ = "Play Again? (Y/N)"
13850 PROC_EMPTY_KEYBOARD_BUFFER:VDU 17,YELLOW
13860 REPEAT r$ = FN_PROMPT(FN_CENTER(message$), CH% DIV 2 + 2, message$, "") UNTIL INSTR("YN", r$) <> 0
13870 = r$
13880 :
13890 REM ::::::::::::::::::::::::
13900 REM ::   Display Scores   ::
13910 REM ::::::::::::::::::::::::
13920 DEF PROC_DISPLAY_SCORES
13930 LOCAL sc$
13940 sc$ = CHR$(17)+CHR$(CYAN)+"L"+STR$(Level%)+CHR$(17)+CHR$(RED)+" SCORE "+CHR$(17)+CHR$(WHITE)+STR$(Score%)
13950 PRINT TAB(0,0)sc$
13960 PROC_UPDATE_HIGH_SCORE
13970 ENDPROC
13980 :
13990 REM :::::::::::::::::::::::::
14000 REM ::  Update High Score  ::
14010 REM :::::::::::::::::::::::::
14020 DEF PROC_UPDATE_HIGH_SCORE
14030 LOCAL hs$
14040 IF (HighScore% < Score%) THEN HighScore% = Score%:REM Check if new highscore has been achieved and update if needed
14050 hs$ = CHR$(17)+CHR$(YELLOW)+"HIGH SCORE "+CHR$(17)+CHR$(WHITE)+STR$(HighScore%)
14060 PRINT TAB(CW%-LEN(hs$)+4,0)hs$
14070 ENDPROC
14080 :
14090 REM :::::::::::::::::::::::::
14100 REM ::   High Score Read   ::
14110 REM :::::::::::::::::::::::::
14120 DEF PROC_HISCORE_READ(game$)
14130 LOCAL f0%, error%, val%
14140 error% = FALSE
14150 f0% = OPENIN(game$ + ".HI")
14160 IF f0% <> 0 THEN INPUT#f0%, val%:ELSE error% = TRUE
14170 CLOSE#f0%
14180 IF NOT error% THEN HighScore% = val%
14190 ENDPROC
14200 :
14210 REM :::::::::::::::::::::::::
14220 REM ::   High Score Write  ::
14230 REM :::::::::::::::::::::::::
14240 DEF PROC_HISCORE_WRITE(game$)
14250 LOCAL f0%
14260 f0% = OPENOUT(game$ + ".HI")
14270 PRINT#f0%, HighScore%
14280 CLOSE#f0%
14290 ENDPROC
14300 :
14310 REM ::::::::::::::::::::::::::::::
14320 REM :: Map keyboard input to a  ::
14330 REM :: cardinal direction value ::
14340 REM ::::::::::::::::::::::::::::::
14350 DEF FN_MAP_INPUT(n%)
14360 LOCAL r%
14370 r% = -1
14380 IF (n% > 0) THEN r% = (n% = UP)*-P_TOP + (n% = LEFT)*-P_LEFT + (n% = RIGHT)*-P_RIGHT + (n% = DOWN)*-P_BOTTOM
14390 := r%
14400 :
14410 REM :::::::::::::::::::::
14420 REM ::   Center text   ::
14430 REM :::::::::::::::::::::
14440 DEF FN_CENTER(text$):= 1 + (CW% - LEN(text$)) DIV 2
14450 :
14460 REM ::::::::::::::::::::::
14470 REM :: Maximum of x & y ::
14480 REM ::::::::::::::::::::::
14490 DEF FN_MAX(x, y):= y + (x > y) * (y - x)
14500 :
14510 REM ::::::::::::::::::::::
14520 REM :: Minimum of x & y ::
14530 REM ::::::::::::::::::::::
14540 DEF FN_MIN(x, y):= y + (x < y) * (y - x)
14550 :
14560 REM :::::::::::::::::::::::::::
14570 REM ::   Bounded time ticks  ::
14580 REM :::::::::::::::::::::::::::
14590 DEF FN_INT_TIME:= TIME MOD MAXINT%
14600 :
14610 REM :::::::::::::::::::::::
14620 REM :: Has time reached  ::
14630 REM :: target seconds?   ::
14640 REM :::::::::::::::::::::::
14650 DEF FN_IS_TIME(sec%, prevSec%, targetSec%):= (sec% MOD targetSec% = 0 AND sec% <> prevSec%)
14660 :
14670 REM ::::::::::::::::::::::
14680 REM :: Retrieve a byte  ::
14690 REM :: register value   ::
14700 REM :: from VDP         ::
14710 REM ::::::::::::::::::::::
14720 DEF FN_getByteVDP(var%):A% = &A0:L% = var%:= USR(&FFF4)
14730 :
14740 REM ::::::::::::::::::::::
14750 REM :: Retrieve a word  ::
14760 REM :: register value   ::
14770 REM :: from VDP         ::
14780 REM ::::::::::::::::::::::
14790 DEF FN_getWordVDP(var%):= FN_getByteVDP(var%) + 256 * FN_getByteVDP(var% + 1)
14800 :
14810 REM ::::::::::::::::::::::
14820 REM :: Retrieve the     ::
14830 REM :: number of colors ::
14840 REM :: reported by VDP  ::
14850 REM ::::::::::::::::::::::
14860 DEF FN_COLORCOUNT:= FN_getByteVDP(&15)
14870 :
14880 REM ::::::::::::::::::::::
14890 REM :: Retrieve the     ::
14900 REM :: ASCII key code   ::
14910 REM :: reported by VDP  ::
14920 REM ::::::::::::::::::::::
14930 DEF FN_ASCII_KEYCODE:= FN_getByteVDP(&05)
14940 :
14950 REM ::::::::::::::::::::::
14960 REM :: Retrieve the     ::
14970 REM :: Virtual key code ::
14980 REM :: reported by VDP  ::
14990 REM ::::::::::::::::::::::
15000 DEF FN_VIRTUAL_KEYCODE:= FN_getByteVDP(&17)
15010 :
15020 REM :::::::::::::::::::::::::::::
15030 REM :: Retrieve the number of  ::
15040 REM :: keys as reported by VDP ::
15050 REM :::::::::::::::::::::::::::::
15060 DEF FN_ASCII_KEYCOUNT:= FN_getByteVDP(&19)
15070 :
15080 REM :::::::::::::::::::::::::::::::::
15090 REM :: Retrieve a keypress within  ::
15100 REM :: the given timeout value     ::
15110 REM :::::::::::::::::::::::::::::::::
15120 DEF FN_GET_KEY(timeout%)
15130 LOCAL i%, keycount%, r%, sync%
15140 r% = -1
15150 keycount% = FN_ASCII_KEYCOUNT
15160 i% = 0
15170 REPEAT
15180   IF keycount% <> FN_ASCII_KEYCOUNT THEN r% = FN_ASCII_KEYCODE:IF r% = 0 THEN r% = FN_VIRTUAL_KEYCODE ELSE *FX 19
15190   i% = i% + 1
15200 UNTIL i% = timeout% OR r% > 0
15210 := r%
15220 :
15230 REM :::::::::::::::::::::::::::
15240 REM :: Empty Keyboard Buffer ::
15250 REM :::::::::::::::::::::::::::
15260 DEF PROC_EMPTY_KEYBOARD_BUFFER
15270 REPEAT UNTIL INKEY(0) = -1
15280 ENDPROC
15290 :
15300 REM ::::::::::::::::::::::::::::
15310 REM :: Disable display of the ::
15320 REM :: cursor on the screen   ::
15330 REM ::::::::::::::::::::::::::::
15340 DEF PROC_HIDE_CURSOR:VDU 23,1,0;0;0;0;:ENDPROC
15350 :
15360 REM ::::::::::::::::::::::::::::
15370 REM :: Enable display of the  ::
15380 REM :: cursor on the screen   ::
15390 REM ::::::::::::::::::::::::::::
15400 DEF PROC_SHOW_CURSOR:VDU 23,1,1;0;0;0;:ENDPROC
15410 :
15420 REM :::::::::::::::::::::::::::::::::
15430 REM :: Center text both vertically ::
15440 REM :: and horizontally            ::
15450 REM :::::::::::::::::::::::::::::::::
15460 DEF PROC_FULL_CENTER_TEXT(text$):VDU 31,FN_CENTER(text$), CH% DIV 2:PRINT text$;:ENDPROC
15470 :
15480 REM :::::::::::::::::::::::::::::::::::::::
15490 REM :: Pause execution of the program    ::
15500 REM :: for a number of ticks (1/100) sec ::
15510 REM :::::::::::::::::::::::::::::::::::::::
15520 DEF PROC_SLEEP(hundredth_seconds%):LOCAL t:hundredth_seconds% = hundredth_seconds% + (hundredth_seconds% < 0) * -hundredth_seconds%:t = TIME:REPEAT UNTIL ((TIME - t) > hundredth_seconds%):ENDPROC
15530 :
15540 REM ::::::::::::::::::::::::::::::::
15550 REM :: Return TRUE when random    ::
15560 REM :: value is below given value ::
15570 REM ::::::::::::::::::::::::::::::::
15580 DEF FN_RND_PCT(n%):=RND(1) <= (n% / 100):REM Returns TRUE or FALSE
15590 :
15600 REM :::::::::::::::::::::::::::::::::
15610 REM :: Random Integer Within Range ::
15620 REM :::::::::::::::::::::::::::::::::
15630 DEF FN_RND_INT(lo%, hi%):= (RND(1) * (hi% - lo% + 1)) + lo%
15640 :
15650 REM ::::::::::::::::::::::::::::::::
15660 REM :: Generate A Random Sequence ::
15670 REM ::::::::::::::::::::::::::::::::
15680 DEF FN_RND_SEQ(n%)
15690 LOCAL i%, r$
15700 R$ = ""
15710 FOR i% = 1 TO n%
15720   r$ = r$ + MID$(P$, FN_RND_INT(1, 7), 1)
15730 NEXT i%
15740 := r$
15750 :
15760 REM ::::::::::::::::::::::
15770 REM ::   To Uppercase   ::
15780 REM ::::::::::::::::::::::
15790 DEF FN_TO_UPPER(ch$):LOCAL ch%:ch% = ASC(ch$):ch$ = CHR$(ch% + 32 * (ch% >= 97 AND ch% <= 122)):=ch$
15800 :
15810 REM :::::::::::::::::::::::::
15820 REM :: Prompt For Response ::
15830 REM :::::::::::::::::::::::::
15840 DEF FN_PROMPT(x%, y%, text$, default$)
15850 LOCAL r$
15860 PRINT TAB(x%, y%)text$;" ";default$:PRINT TAB(x% + LEN(text$) + 1, y%);
15870 r$ = GET$:r$ = FN_TO_UPPER(r$):IF r$ = CHR$(13) THEN r$ = default$
15880 := r$
15890 :
15900 REM :::::::::::::::::::::::::::::::::
15910 REM :: Enter numbers from keyboard ::
15920 REM :::::::::::::::::::::::::::::::::
15930 DEF FN_PROMPT_FOR_NUMBERS(x%, y%, text$, default$, length%)
15940 LOCAL c$, r$
15950 r$ = "":PROC_EMPTY_KEYBOARD_BUFFER:PROC_SHOW_CURSOR
15960 PRINT TAB(x%, y%)text$;" ";default$:PRINT TAB(x% + LEN(text$) + 1, y%);
15970 REPEAT
15980   c$ = GET$
15990   IF ((c$ = CHR$(127) OR c$ = CHR$(8)) AND LEN(r$) > 0) THEN r$ = LEFT$(r$, LEN(r$) - 1):PRINT CHR$(127);
16000   IF (c$ >= "0" AND c$ <= "9") AND LEN(r$) < length% THEN r$ = r$ + c$:PRINT c$;
16010   IF c$ = CHR$(13) AND LEN(r$) = 0 THEN r$ = default$
16020 UNTIL (c$ = CHR$(13) AND LEN(r$) <= length%)
16030 PROC_HIDE_CURSOR
16040 := r$
16050 :
16060 REM :::::::::::::::::::::::::::::
16070 REM ::  Display Centered Text  ::
16080 REM :::::::::::::::::::::::::::::
16090 DEF PROC_CENTER(text$)
16100 LOCAL i%, n%, l%
16110 l% = 0
16120 FOR i% = 1 TO LEN(text$)
16130   IF ASC(MID$(text$, i%, 1)) >= BLANK THEN l% = l% + 1
16140 NEXT i%
16150 n% = FN_CENTER(STRING$(l%, CHR$(BLANK)))
16160 i% = VPOS:VDU 31, n%, i%
16170 FOR i% = 1 TO LEN(text$)
16180   VDU ASC(MID$(text$, i%, 1))
16190 NEXT i%
16200 ENDPROC
16210 :
16220 REM ::::::::::::::::::::::::::::
16230 REM :: Restore Default Colors ::
16240 REM ::::::::::::::::::::::::::::
16250 DEF PROC_DEFAULT_COLORS
16260 COLOUR 128+BLACK:COLOUR WHITE
16270 ENDPROC
16280 :
16290 REM :::::::::::::::::::::::::::::::::::::::::::
16300 REM ::  Calculate type index of a clockwise  ::
16310 REM ::  position on a box's perimeter        ::
16320 REM :::::::::::::::::::::::::::::::::::::::::::
16330 DEF FN_CLOCKWISE_BOX_SIDE_INDEX(pos%, width%, height%)
16340 REM 0 = UPPER_LEFT_CORNER, 1 = UPPER_MIDDLE, 2 = UPPER_RIGHT_CORNER, 3 = MIDDLE_RIGHT, 4 = LOWER_RIGHT_CORNER, 5 = LOWER_MIDDLE, 6 = LOWER_LEFT_CORNER, 7 = MIDDLE_LEFT
16350 LOCAL r%
16360 r% = (pos% > 0 AND pos% < width% - 1) * -1 + (pos% = width% - 1) * -2 + (pos% >= width% AND pos% < width% + height% - 2) * -3 + (pos% = width% + height% - 2) * -4
16370 r% = r% + (pos% > width% + height% - 2 AND pos% < 2 * width% + height% - 3) * -5 + (pos% = 2 * width% + height% - 3) * -6 + (pos% > 2 * width% + height% - 3) * -7
16380 :=r%
16390 :
16400 REM ::::::::::::::::::::::::::
16410 REM ::  Draw Box Clockwise  ::
16420 REM ::::::::::::::::::::::::::
16430 DEF PROC_CLOCKWISE_BOX(ux%, uy%, width%, height%, color%)
16440 LOCAL aq%, bq%, ch%, i%, p%, x%, y%
16450 aq% = width% + height% - 2:bq% = aq% + width%:p% = bq% + height% - 2
16460 FOR i% = 0 TO p% - 1
16470   x% = (i% < width%) * -i% + (i% > (width%-1) AND i% < aq%) * -(width%-1) + (i% >= aq% AND i% < bq%) * (i% - (bq% - 1)) + (i% >= bq%) * 0
16480   y% = (i% < width%) * 0 + (i% > (width%-1) AND i% < aq%) * -(i% - (width%-1)) + (i% >= aq% AND i% < bq%) * -(height%-1) + (i% >= bq%) * -((height%-2) - (i% - bq%))
16490   ch% = ASC(MID$(BX$, FN_CLOCKWISE_BOX_SIDE_INDEX(i%, width%, height%) + 1, 1))
16500   PROC_PLOT(ux% + x%, uy% + y%, ch%, color%)
16510 NEXT i%
16520 ENDPROC
16530 :
16540 REM ::::::::::::::::::::::::::::::::
16550 REM ::       Clockwise Plot       ::
16560 REM ::::::::::::::::::::::::::::::::
16570 DEF PROC_CLOCKWISE_PLOT(pos%, color%, char%, ux%, uy%, width%, height%)
16580 LOCAL cx%, cy%, a%, b%, c%
16590 a% = width% + height% - 2:b% = a% + width%:c% = b% + height% - 2
16600 cx% = (pos% < width%) * -pos% + (pos% > (width% - 1) AND pos% < a%) * -(width% - 1)
16610 cx% = cx% + (pos% >= a% AND pos% < b%) * (pos% - (b% - 1)) + (pos% >= b%) * 0
16620 cy% = (pos% < width%) * 0 + (pos% > (width% - 1) AND pos% < a%) * -(pos% - (width% - 1))
16630 cy% = cy% + (pos% >= a% AND pos% < b%) * -(height% - 1) + (pos% >= b%) * -((height% - 2) - (pos% - b%))
16640 VDU 31,ux% + cx%,uy% + cy%,17,color%,char%:REM Plot a character on the path
16650 ENDPROC
16660 :
16670 REM :::::::::::::::::::::::
16680 REM :: Play Simple Sound ::
16690 REM :::::::::::::::::::::::
16700 DEF PROC_SOUND(index%, duration%)
16710 LOCAL constant%
16720 constant% = 12.2
16730 SOUND 1, -10, index% * constant%, duration%
16740 ENDPROC
16750 :
16760 REM :::::::::::::::::::::::::
16770 REM :: Play Musical Phrase ::
16780 REM :::::::::::::::::::::::::
16790 DEF PROC_PLAY(notes$)
16800 LOCAL d%, j%, l%, p%
16810 l% = LEN(notes$) DIV 3
16820 FOR j% = 1 TO l% STEP 2
16830   p% = VAL(MID$(notes$, 3 * (j% - 1) + 1, 3)):d% = VAL(MID$(notes$, 3 * (j% - 1) + 4, 3))
16840   IF p% >= 0 THEN SOUND 1, -10, p%, d%:ELSE SOUND 1, 0, 0, d%
16850   SOUND 1, 0, p%, 1:REM Stacatto the currently playing sound
16860 NEXT j%
16870 ENDPROC
16880 :
16890 REM :::::::::::::::::::::::
16900 REM :: Level Start Music ::
16910 REM :::::::::::::::::::::::
16920 DEF PROC_LEVEL_START_MUSIC
16930 PROC_PLAY(STRING$(Level% * 2 + 2, "129004"))
16940 ENDPROC
16950 :
16960 REM :::::::::::::::::::
16970 REM ::  CHARGE!!!!!  ::
16980 REM :::::::::::::::::::
16990 DEF PROC_CHARGE
17000 PROC_PLAY("129001149001165001177004165002177008"):REM COUNT,PITCH,DURATION
17010 ENDPROC
17020 :
17030 REM ::::::::::::::
17040 REM ::  Tada!!  ::
17050 REM ::::::::::::::
17060 REM COUNT,PITCH,DURATION
17070 DEF PROC_TADA
17080 PROC_PLAY("197002225008"):REM COUNT,PITCH,DURATION
17090 ENDPROC
17100 :
17110 REM :::::::::::::::
17120 REM ::  WAH-WAH  ::
17130 REM :::::::::::::::
17140 REM COUNT,PITCH,DURATION
17150 DEF PROC_WAH_WAH
17160 PROC_PLAY("081002081002081002069020073002073002073002061024"):REM COUNT,PITCH,DURATION
17170 ENDPROC
17180 :
17190 REM :::::::::::::::::::::::::::
17200 REM :: Plot a single colored ::
17210 REM :: character to screen   ::
17220 REM :::::::::::::::::::::::::::
17230 DEF PROC_PLOT(x%, y%, ch%, co%)
17240 VDU 31, x%, y%
17250 VDU 17, co%, ch%
17260 ENDPROC
17270 :
17280 REM ::::::::::::::::::::::::::
17290 REM :: Define Custom Colors ::
17300 REM ::::::::::::::::::::::::::
17310 DEF PROC_REDEFINE_COLORS
17320 IF SY$="A" AND FN_COLORCOUNT < &40 THEN VDU 19,C_ORANGE,&FF,&FF,&80,&00:ELSE COLOUR C_ORANGE,&FF,&80,&00
17330 ENDPROC
17340 :
17350 REM ::::::::::::::::::::::::::::::
17360 REM :: Define Custom Characters ::
17370 REM ::::::::::::::::::::::::::::::
17380 DEF PROC_REDEFINE_CHARS
17390 VDU 23,HASH,141,108,99,27,216,198,54,177:REM HASH
17400 VDU 23,36,114,147,156,228,39,57,201,78:REM I_HASH
17410 VDU 23,B_VERT,24,24,24,24,24,24,24,24:REM VERTICAL(4)
17420 VDU 23,B_HORZ,0,0,0,255,255,0,0,0:REM HORIZONTAL(4)
17430 VDU 23,B_UR,0,0,0,7,15,28,24,24:REM UPRIGHT C(4)
17440 VDU 23,B_UL,0,0,0,224,240,56,24,24:REM UPLEFT C(4)
17450 VDU 23,B_DL,24,24,56,240,224,0,0,0:REM DOWNLEFT C(4)
17460 VDU 23,B_DR,24,24,28,15,7,0,0,0:REM DOWN RIGHT C(4)
17470 VDU 23,PWN_1,24,24,24,24,24,24,24,24:REM PAWN 1
17480 VDU 23,PWN_2,0,12,12,12,12,60,60,0:REM PAWN 2
17490 VDU 23,PWN_3,0,48,48,48,48,60,60,0:REM PAWN 3
17500 VDU 23,PWN_4,0,0,60,60,60,60,0,0:REM PAWN 4
17510 VDU 23,PWN_5,0,0,30,30,120,120,0,0:REM PAWN 5
17520 VDU 23,PWN_6,0,0,126,126,24,24,0,0:REM PAWN 6
17530 VDU 23,PWN_7,0,0,120,120,30,30,0,0:REM PAWN 7
17540 ENDPROC
17550 :
17560 REM ::::::::::::::::::::::::::::::
17570 REM ::  Error Handling Routine  ::
17580 REM ::::::::::::::::::::::::::::::
17590 DEF PROC_HANDLE_ERROR
17600 IF ERR <> 17 THEN PROC_DEFAULT_COLORS:PROC_SHOW_CURSOR:PRINT:REPORT:PRINT" @line #";ERL:STOP
17610 ENDPROC
17620 :
17630 REM ::::::::::::::::::::::::::::::
17640 REM ::  Console Output (DEBUG)  ::
17650 REM ::::::::::::::::::::::::::::::
17660 DEF PROC_COUT(text$, row%):VDU 31,0,CH%+row%,17,WHITE:PRINT text$:ENDPROC
17670 :
17680 REM :::::::::::::::::::::::::::::::
17690 REM ::  Test FN_GET_KEY (DEBUG)  ::
17700 REM :::::::::::::::::::::::::::::::
17710 DEF PROC_KEYTEST:CLS:REPEAT PRINT TAB(18,0)STR$(FN_GET_KEY(30))"   ":UNTIL FALSE
17720 ENDPROC
