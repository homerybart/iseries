000100191127       ********************************************************************
000200191127       *                                                                  *
000300191127       *                      FUNCION DEL PROGRAMA                        *
000400191127       *                                                                  *
000500191127       * Este programa controla si el usuario que accede al servidor FTP  *
000600191127       * está autorizado                                                  *
000700191127       *                                                                  *
000800191127       ********************************************************************
000900191127
001000191127       ********************************************************************
001100191127       * ESTRUCTURAS DE DATOS                                             *
001200191127       ********************************************************************
001300191127       *
001400191127       * Define constants
001500191127       *
001600191127      D Anonym          C                   CONST('ANONYMOUS ')
001700191127      D Text1           C                   CONST('Anonymous (')
001800191127      D Text2           C                   CONST(') FTP logon')
001900191127      D InvalidNet      C                   CONST('10.')
002000191127
002100191213      //*******************************************************************
002200191213      // DEFINICION DE VARIABLES                                          *
002300191213      //*******************************************************************
002400191127       *
002500191127       * Define binary parameters
002600191127       *
002700191127      D                 DS
002800191127      D  APPIDds                1      4B 0
002900191127      D  USRLENds               5      8B 0
003000191127      D  AUTLENds               9     12B 0
003100191127      D  IPLENds               13     16B 0
003200191127      D  RETCDds               17     20B 0
003300191127       *
003400191127      C     *LIKE         DEFINE    APPIDds       APPIDIN
003500191127      C     *LIKE         DEFINE    USRLENds      USRLENIN
003600191127      C     *LIKE         DEFINE    AUTLENds      AUTLENIN
003700191127      C     *LIKE         DEFINE    IPLENds       IPLENIN
003800191127      C     *LIKE         DEFINE    RETCDds       RETCDOUT
003900191127       *
004000191127       * Lista de parámetros
004100191127       *
004200191127      C     *Entry        PLIST
004300191127       * Parámetros de entrada:
004400191127      C                   PARM                    APPIDIN                        Application ID
004500191127       *                                                    possible values:   1 = FTP Server Progra
004600191127      C                   PARM                    USRIN           999            User ID
004700191127      C                   PARM                    USRLENIN                       Length of User ID
004800191127      C                   PARM                    AUTIN           999            Authentication Strg
004900191127      C                   PARM                    AUTLENIN                       Length of Auth. Str
005000191127      C                   PARM                    IPADDRIN         15            Client IP Address
005100191127      C                   PARM                    IPLENIN                        Length of IP Addres
005200191127       * Parámetros de retorno:
005300191127      C                   PARM                    RETCDOUT                       Return Code (Out)
005400191127
005500191127      C                   PARM                    USRPRFOUT        10            User Profile (Out)
005600191127      C                   PARM                    PASSWDOUT        10            Password (Out)
005700191127      C                   PARM                    CURLIBOUT        10            Current Lib. (Out)
005800191127      C
005900191127       ********************************************************************
006000191127       * THE MAIN PROGRAM                                                 *
006100191127       ********************************************************************
006200191127       *
006300191127       * Check for ANONYMOUS user
006400191127       *     1
006500191127      C     USRLENIN      SUBST(P)  USRIN:1       User             10
006600191127      C     User          IFEQ      Anonym
006700191127      C                   MOVEL     Anonym        USRPRFOUT
006800191127       *
006900191127       * Check if the user entered something as a e-mail address
007000191127       *
007100191127      C     AUTLENIN      IFGT      *ZERO
007200191127             E-mail addr. entered
007300191127       *
007400191127       * Check if the E-mail address is a valid one
007500191127       *
007600191127      C                   Z-ADD     0             i                 3 0
007700191127      C     '@'           SCAN      AUTIN:1       i                              Valid E-mail addres
007800191127       *                                                                         contains @ characte
007900191127       *
008000191127      C     i             IFGT      0                                            Found a '@'
008100191127      C     AUTLENIN      SUBST(P)  AUTIN:1       Email            30
008200191127      C                   Z-ADD     5             RETCDOUT                       Accept Logon
008300191127       *
008400191127       * Log Anonymous FTP Logon to message queue QSYSOPR
008500191127       * (The logging should be done to a secure physical file!!!!!!!)
008600191127       *
008700191127      C     Text1         CAT(p)    Email:0       Message          43
008800191127      C     Message       CAT(p)    Text2:0       Message
008900191127      C     Message       DSPLY     'QSYSOPR'
009000191127       *
009100191127      C                   ELSE                                                   Invalid E-mail addr
009200191127      C                   Z-ADD     0             RETCDOUT                       Reject Logon attemp
009300191127      C                   ENDIF
009400191127       *
009500191127      C                   ELSE                                                   No E-mail address
009600191127      C                   Z-ADD     0             RETCDOUT                       Reject Logon attemp
009700191127      C                   ENDIF
009800191127       *
009900191127      C                   ELSE
010000191127       *
010100191127       * Any Other User: Proceed with Normal Logon Processing, but the Client address must not belon
010200191127       *                 to network 10.xxx.xxx.xxx
010300191127       *
010400191127      C     3             SUBST     IPADDRIN:1    TheNet            3
010500191127      C     TheNet        IFEQ      InvalidNet                                   Wrong Net
010600191127      C                   Z-ADD     0             RETCDOUT                       Reject Logon attemp
010700191127      C                   ELSE                                                   Right Net
010800191127      C                   Z-ADD     1             RETCDOUT                       Continue with Logon
010900191127      C                   ENDIF
011000191127       *
011100191127      C                   ENDIF
011200191127       *
011300191127      C                   EVAL      *INLR = *ON
011400191127      C                   RETURN
