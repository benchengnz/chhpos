CLEAR
SET TALK OFF
DEFINE PAD padEnv OF _MSYSMENU PROMPT 'E\<nvironment';
   KEY ALT+R, 'ALT+R'
ON PAD padEnv OF _MSYSMENU ACTIVATE POPUP popEnv
DEFINE POPUP popEnv MARGIN RELATIVE COLOR SCHEME 4
DEFINE BAR 1 OF popEnv PROMPT '\<Status Bar'
DEFINE BAR 2 OF popEnv PROMPT '\<Clock'
DEFINE BAR 3 OF popEnv PROMPT '\<Extended Video'
DEFINE BAR 4 OF popEnv PROMPT 'St\<icky'
ON SELECTION POPUP popEnv DO enviropop IN cntbar.prg
FOR i = 1 TO CNTBAR('popEnv')
   DO CASE
      CASE PRMBAR('popEnv', i) = 'Status Bar'
         IF _WINDOWS or _MAC
            SET MARK OF BAR i OF popEnv TO SET('STATUS BAR') = 'ON'
         ELSE
            SET MARK OF BAR i OF popEnv TO SET('STATUS') = 'ON'
         ENDIF
      CASE PRMBAR('popEnv', i) = 'Clock'
         SET MARK OF BAR i OF popEnv TO  SET('CLOCK') = 'ON'
      CASE PRMBAR('popEnv', i) = 'Extended Video'
         SET MARK OF BAR i OF popEnv TO  SROW( ) > 25
      CASE PRMBAR('popEnv', i) = 'Sticky'
         SET MARK OF BAR i OF popEnv TO  SET('STICKY') = 'ON'
   ENDCASE
ENDFOR

PROCEDURE enviropop
DO CASE
   CASE PROMPT() = 'Status'
      IF mrkbar('popEnv', BAR( ))
         DO CASE
            CASE _WINDOWS OR _MAC
               SET STATUS BAR OFF
            CASE _DOS
               SET STATUS OFF
            OTHERWISE
         ENDCASE
         SET MARK OF BAR BAR( ) OF popEnv TO .F.
      ELSE
         DO CASE
            CASE _WINDOWS OR _MAC
               SET STATUS BAR ON
            CASE _DOS
               SET STATUS ON
            OTHERWISE
         ENDCASE
         SET MARK OF BAR BAR( ) OF popEnv TO .T.
      ENDIF
CASE PROMPT( ) = 'Clock'
   IF mrkbar('popEnv', BAR( ))
      SET CLOCK OFF
      SET MARK OF BAR BAR( ) OF popEnv TO .F.
   ELSE
      DO CASE
         CASE _WINDOWS OR _MAC
            SET STATUS BAR ON
            SET CLOCK STATUS
         CASE _DOS
            SET CLOCK ON
         OTHERWISE
      ENDCASE
      SET MARK OF BAR BAR( ) OF popEnv TO .T.
   ENDIF
CASE PROMPT( ) = 'Extended Video'
   IF MRKBAR('popEnv', BAR( ))
      SET DISPLAY TO VGA25
      SET MARK OF BAR BAR( ) OF popEnv TO .F.
   ELSE
      SET DISPLAY TO VGA50
      SET MARK OF BAR BAR( ) OF popEnv TO .T.
   ENDIF
CASE PROMPT( ) = 'Sticky'
   IF MRKBAR('popEnv', BAR( ))
      DO CASE
         CASE _WINDOWS OR _MAC
            WAIT WINDOW 'STICKY is always on in this Visual FoxPro version'
         CASE _DOS
            SET STICKY OFF
         OTHERWISE
      ENDCASE
      SET MARK OF BAR BAR( ) OF popEnv TO .F.
   ELSE
      DO CASE
         CASE _WINDOWS OR _MAC
            WAIT WINDOW 'STICKY is always ON in Visual FoxPro'
         CASE _DOS
            SET STICKY ON
         OTHERWISE
      ENDCASE
       SET MARK OF BAR BAR( ) OF popEnv TO .T.
   ENDIF
ENDCASE

