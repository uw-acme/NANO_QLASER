-- ----------------------------------------------------------------------------
--
--  Copyright (c) Mentor Graphics Corporation, 1982-1996, All Rights Reserved.
--                       UNPUBLISHED, LICENSED SOFTWARE.
--            CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
--          PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS.
--
--
-- PackageName :  std_iopak
-- Title       :  Package for STD_IOPAK
-- Purpose     :  This package contains additional support for 
--             :  performing text IO. 
--             :  
-- Comments    : 
--             :
-- Assumptions : none
-- Limitations : none
-- Known Errors: none
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- Mentor Graphics Corporation owns the sole copyright to this software.
-- Under International Copyright laws you (1) may not make a copy of this
-- software except for the purposes of maintaining a single archive copy, 
-- (2) may not derive works herefrom, (3) may not distribute this work to
-- others. These rights are provided for information clarification, 
-- other restrictions of rights may apply as well.
--
-- This is an "Unpublished" work.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> License   NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- This software is further protected by specific source code and/or
-- object code licenses provided by Mentor Graphics Corporation. Use of this
-- software other than as provided in the licensing agreement constitues
-- an infringement. No modification or waiver of any right(s) shall be 
-- given other than by the written authorization of an officer of The 
-- Mentor Graphics Corporation.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>> Proprietary Information <<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- This source code contains proprietary information of Mentor Graphics 
-- Corporation and shall not be disclosed other than as provided in the software
-- licensing agreement.
-- ----------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Warrantee <<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- ----------------------------------------------------------------------------
-- Mentor Graphics Corporation MAKES NO WARRANTY OF ANY KIND WITH REGARD TO 
-- THE USE OF THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
-- FOR A PARTICULAR PURPOSE.
-- ----------------------------------------------------------------------------
-- Modification History : 
-- ----------------------------------------------------------------------------
--   Version No: |   Author:    |  Mod. Date: | Changes Made:
--     v1.000    |  M.K.Dhodhi  |  10/26/91   | Production Release 
--     v1.100    |  M.K.Dhodhi  |  11/19/91   | Compatible w/ vantage 3.650  Release 
--     v1.110    |  wdb         |  01/27/92   | compatible w/Intermetrics
--     v1.111    |  M.K.Dhodhi  |  02/13/92   | fixing bug in T0_String input time
--                                            | fixing comment in SOX_Machine
--     v1.111    |  M.K.Dhodhi  |  03/06/92   | production release
--     v1.200    |  M.K.Dhodhi  |  04/21/92   | stand alone version
--     v1.300    |  M.K.Dhodhi  |  08/03/92   | production release
--     v1.140    |  M.K.Dhodhi  |  11/05/92   | fixing real 0.0 case for To_String 
--                              |             | and an extra loop in default time.
--     v1.150    |  M.K.Dhodhi  |  11/17/92   | extending fscan upto 20 arguments.
--                                            | fixing default 0 time.
--     v1.160    |  M.K.Dhodhi  |  02/11/93   | Fixing Find_char
--     v1.700 B  |  W.R. Migatz |  05/03/93   | Beta release - changes to all f routines (not fprint)
--                                            | modified str*cpy and str*cmp
--                                            | fixed memory leak
--     v1.700    |  W.R. Migatz |  05/25/93   | production release - change to fscan with %t to allow time unit
--     v1.800    |  W.R. Migatz |  07/28/93   | combining into 1 file,  mentor support, and From_String(time) bug fix
--     v2.000    |  W.R. Migatz |  07/21/94   | production release - fix bug in fprint, fs ps ns timing changes
--     v2.100    |  W.R. Migatz |  01/10/96   | production release 
--					      | Initialization banner removed
--     v2.110    |  W.R. Migatz |  04/02/96   | Fixed Find_Char and To_String(TIME) bugs
--                                            | Find_char did not stop at a NUL character
--                                            | To_String(TIME) did not handle a precision of 0
--     v2.2      |  B. Caslis   |  07/25/96   | Updated for Mentor Graphics Release
-- ----------------------------------------------------------------------------
 
Library ieee;
Use     ieee.std_logic_1164.all; -- Reference the STD_Logic system
Use     STD.TEXTIO.all;

PACKAGE std_iopak is

 -- ************************************************************************
 -- Display Banner
 -- ************************************************************************
    CONSTANT StdIOpakBanner : BOOLEAN;

    

    TYPE ASCII_TEXT IS file of CHARACTER;

    TYPE time_unit_type  is (t_fs, t_ps, t_ns, t_us, t_ms, t_sec, t_min, t_hr);

    CONSTANT max_token_len      : INTEGER := 32;
    CONSTANT max_string_len     : INTEGER := 256;
    CONSTANT END_OF_LINE_MARKER : STRING(1 TO 2);
    
--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert from  a String to a boolean.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : A boolean true or false.
--|
--|     NOTE           :
--|
--|     Use            :
--|                      VARIABLE s_flag : String(1 TO 5) := " TRUE"; 
--|                      VARIABLE good : BOOLEAN 
--|
--|                       good := From_String (s_flag);
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN boolean;
 
--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert from  a String to a bit.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : bit.
--|
--|     NOTE           :
--|
--|     Use            :
--|                      VARIABLE b_val : bit; 
--|
--|                       b_val := From_String (" 100");
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN bit;

--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert from  a String to a Severity_Level.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : Severity_Level
--|
--|     NOTE           :
--|
--|     Use            :
--|                      VARIABLE str10 : String(1 TO 10) := "   WARNING"; 
--|                      VARIABLE sev : severity_level; 
--|
--|                       sev := From_String (str10);
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN severity_level;
--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert from a String to a character.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : Character
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE str10 : String(1 TO 10) := "WARNING   "; 
--|                      VARIABLE ch : character; 
--|
--|                       ch := From_String (str10);
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN character;
--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from a String to an Integer.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : Integer
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE n : Integer; 
--|
--|                       n := From_String ("32 56");
--|                       This statement will set n to integer 32.
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN INTEGER;
--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from a String to a real.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : real value
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE n : real ; 
--|
--|                       n := From_String ("   -354.78");
--|                       This statement will set n to real value -354.78.
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN REAL;
 
--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from a String to an std_ulogic.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : std_ulogic
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE u_val : std_ulogic ; 
--|
--|                       u_val := From_String (" 100");
--|                       This statement will set u_val  equal to the value '1'.
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN std_ulogic;
--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from a String to an std_ulogic_vector.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : std_ulogic_vector
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE u_vector : std_ulogic_vector( 7 DOWNTO 0) ; 
--|
--|                       u_vector := From_String ("   0-ZU1010   1010");
--|                       This statement will set u_vector  equal to "0-ZU1010".
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN std_ulogic_vector;

--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from a String to an std_logic_vector.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : std_logic_vector
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE logic_vect : std_logic_vector( 7 DOWNTO 0) ; 
--|
--|                       logic_vect := From_String ("   0-ZU1010   1010");
--|                       This statement will set logic_vect  equal to "0-ZU1010".
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN std_logic_vector;
 
--+-----------------------------------------------------------------------------
--|     Function Name  : From_BinString
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from a Binary String to a bit_vector.
--|
--|     Parameters     :
--|                      str     - input ,  binary string to be converted,
--|
--|     Result         : bit_vector
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE b_vect : bit_vector( 7 DOWNTO 0) ; 
--|
--|                       b_vect := From_BinString ("   01101111   1010");
--|                       This statement will set b_vect  equal to "01101111".
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_BinString   ( CONSTANT str   : IN STRING
                              ) RETURN bit_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : From_OctString
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from an Octal String to a bit_vector.
--|
--|     Parameters     :
--|                      str     - input ,  Octal string to be converted,
--|
--|     Result         : bit_vector
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE b_vect : bit_vector( 15 DOWNTO 4) ; 
--|
--|                       b_vect := From_OctString ("   1735   1010");
--|                       This statement will set b_vect  equal to "001111011101".
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_OctString   ( CONSTANT str   : IN STRING
                              ) RETURN bit_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : From_HexString
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from a Hex String to a bit_vector.
--|
--|     Parameters     :
--|                      str     - input ,  Hex string to be converted,
--|
--|     Result         : bit_vector
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE b_vect : bit_vector( 15 DOWNTO 4) ; 
--|
--|                       b_vect := From_HexString ("   3DD   1010");
--|                       This statement will set b_vect  equal to "001111011101".
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_HexString   ( CONSTANT str   : IN STRING
                              ) RETURN bit_vector;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.1.1
--|     Overloading    : None
--|
--|     Purpose        : Convert a boolean to a String.
--|
--|     Parameters     :
--|                      val     - input  value,  BOOLEAN,
--|                      format  - input  STRING, provides the
--|                                       conversion specifications.
--|
--|     Result         : STRING  representation of a boolean.
--|
--|     NOTE           :
--|                      Default is right justified
--|
--|     Use            :
--|                      VARIABLE s_flag : String(1 TO 5); 
--|                      VARIABLE good : BOOLEAN := TRUE;
--|
--|                       s_flag := To_String ( good, "%5s" );
--|
--|-----------------------------------------------------------------------------
    FUNCTION To_String     ( CONSTANT val    : IN BOOLEAN;
                             CONSTANT format : IN STRING := "%s"
                           ) RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.1.2
--|     Overloading    : None
--|
--|     Purpose        : Convert a bit Value to a String.
--|
--|     Parameters     :
--|                      val     - input   bit.
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         : STRING  representation of a bit.
--|
--|
--|     Use            :
--|                      VARIABLE bit_string : String(1 TO 5); 
--|
--|                        bit_string := To_String ( '1', "%1s");
--|-----------------------------------------------------------------------------
    FUNCTION To_String     ( CONSTANT val      : IN BIT;
                             CONSTANT format   : IN STRING := "%s"
                           ) RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.1.3
--|     Overloading    : None
--|
--|     Purpose        : Convert a Character to a String.
--|
--|     Parameters     :
--|                      val     - input   character.
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Note           : This function allows to see the non-printable characters.
--|
--|     Result         : STRING  representation of a character.
--|
--|
--|     Use            :
--|                      VARIABLE ascii_char : String(1 TO 5);
--|
--|                         ascii_char := To_String ( d,  "%3s");
--|-----------------------------------------------------------------------------
    FUNCTION To_String ( CONSTANT val    : IN CHARACTER;
                         CONSTANT format : IN STRING := "%s"
                       ) RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.1.4
--|     Overloading    : None
--|
--|     Purpose        : Convert a severity-level to a string.
--|
--|     Parameters     :
--|                      val     - input   severity-level.
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         : STRING  representation of a severity-level.
--|
--|     Use            :
--|                      VARIABLE s_level : String(1 TO 7);
--|                      VARIABLE message : SEVERITY_LEVEL := NOTE;
--|
--|                         s_level := To_String (message,  "%7s");
--|------------------------------------------------------------------
    FUNCTION To_String ( CONSTANT val    : IN SEVERITY_LEVEL;
                         CONSTANT format : IN STRING := "%s"
                       ) RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.1.5
--|     Overloading    : None
--|
--|     Purpose        : Convert an integer  into a String according
--|                      format specification.
--|
--|     Parameters     :
--|                      val     - input  value,  INTEGER,
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         : STRING  representation of an integer.
--| 
--|     NOTE           : Format string has same meaning a in C language.
--|                      That if format is "%d " will convert an integer to
--|                      a string of length equal to number of digits in the
--|                      given inetger argument. While "%10d " return 
--|                      a string of length 10 and if the number of digits
--|                      in the integer are less than 10 it will pad the 
--|                      string with blank on the left because default        
--|                      justification is right. if number of digits are
--|                      larger than 10 it will return 10 leftmost digits. 
--|                      
--|
--|
--|     USE            :
--|                     VARIABLE str : STRING(1 TO 10);
--|                     VARIABLE val   : INTEGER := 2750;
--|
--|                          str := TO_String(val, "%10d"), 
--|-----------------------------------------------------------------------------
    FUNCTION To_String ( CONSTANT val    : IN INTEGER;
                         CONSTANT format : IN STRING := "%d"
                       ) RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.1.6
--|     Overloading    : None
--|
--|     Purpose        : Convert a real number  to a String.
--|
--|     Parameters     :
--|                      val     - input  value,  REAL,
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         : STRING  representation of a real number.
--|
--|     USE            : 
--|                     VARIABLE str : STRING(1 TO 10);
--|                     VARIABLE val   : REAL := 67.560
--|
--|                          str := TO_String(val, "%10.3f"), 
--|-----------------------------------------------------------------------------
    FUNCTION To_String ( CONSTANT val    : IN REAL;
                         CONSTANT format : IN STRING :="%f"
                       )  RETURN STRING;

--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.1.8
--|     Overloading    : None
--|
--|     Purpose        : Convert a bit_vector  to a String.
--|
--|     Parameters     :
--|                      val     - input,  BIT_VECTOR,
--|
--|     Result         : STRING  representation of a bit_vector.
--|
--|     USE            : 
--|                     VARIABLE str    : STRING(1 TO 16);
--|                     VARIABLE vect   : BIT_VECTOR (7 DOWNTO 0);
--|
--|                          str := TO_String(vect, "%16s"), 
--|
--|-----------------------------------------------------------------------------
    FUNCTION To_String ( CONSTANT val      : IN BIT_VECTOR;
                         CONSTANT format   : IN STRING :="%s"
                       )  RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.10.2
--|     Overloading    : None
--|  
--|     Purpose        : Convert an std_ulogic to a String.
--|  
--|     Parameters     :
--|                      val    - input   std_ulogic.
--|
--|     Result         : STRING  representation of std_ulogic.
--|
--|     Use            : 
--|                     VARIABLE str_ovf    : STRING(1 TO 4);
--|                     VARIABLE overflow   : std_ulogic;
--|
--|                          str_ovf := TO_String(vect, "%4s"), 
--|-----------------------------------------------------------------------------
    FUNCTION To_String     ( CONSTANT val      : IN std_ulogic;
                             CONSTANT format   : IN STRING := "%s"
                           ) RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--|
--|     Overloading    : None
--|  
--|     Purpose        : Convert an std_logic_vector to a String.
--|  
--|     Parameters     :
--|                      val     - input   std_logic_vector.
--|
--|     Result         : STRING  representation of std_logic_vector.
--|
--|     USE            : 
--|                     VARIABLE str    : STRING(1 TO 16);
--|                     VARIABLE vect   : std_logic_vector (7 DOWNTO 0);
--|
--|                          str := TO_String(vect, "%16s"), 
--|
--|-----------------------------------------------------------------------------
    FUNCTION To_String     ( CONSTANT val      : IN std_logic_vector;
                             CONSTANT format   : IN STRING := "%s"
                           ) RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--|
--|     Overloading    : None
--|  
--|     Purpose        : Convert an std_ulogic_vector to a String.
--|  
--|     Parameters     :
--|                      val     - input   std_ulogic_vector.
--|
--|     Result         : STRING  representation of std_ulogic_vector.
--|
--|     USE            : 
--|                     VARIABLE str    : STRING(1 TO 16);
--|                     VARIABLE vect   : std_ulogic_vector (7 DOWNTO 0);
--|
--|                          str := TO_String(vect, "%16s"), 
--|
--|-----------------------------------------------------------------------------
    FUNCTION To_String     ( CONSTANT val    : IN std_ulogic_vector;
                             CONSTANT format : IN STRING := "%s"
                           ) RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : Is_Alpha
--| 1.
--|     Overloading    : None
--|
--|     Purpose        : Test whether a character is a letter of the alphabet.
--|
--|     Parameters     :
--|                      c     - input   Character.
--|
--|     Result         : True if the argument c is a letter of the
--|                      alphabet, false otherwise.	 
--|
--|
--|     Use            :
--|
--|     See Also       : Is_Digit, Is_Upper, Is_Lower
--|----------------------------------------------------------------------------- 
     FUNCTION  Is_Alpha  ( CONSTANT c   : IN CHARACTER
                         ) RETURN BOOLEAN;
--+----------------------------------------------------------------------------- 
--|     Function Name  : Is_Upper
--| 1.
--|     Overloading    : None 
--|  
--|     Purpose        : Test whether a character is an upper case letter.
--|
--|     Parameters     : 
--|                      c     - input   Character.
--| 
--|     Result         : True if the argument c is an upper case letter of  
--|                      the alphabet, false otherwise.      
--| 
--| 
--|     See Also       : Is_Digit, Is_Alpha, Is_Lower
--|----------------------------------------------------------------------------- 
     FUNCTION  Is_Upper  ( CONSTANT c    : IN CHARACTER
                         ) RETURN BOOLEAN;
--+----------------------------------------------------------------------------- 
--|     Function Name  : Is_Lower
--| 1.
--|     Overloading    : None 
--|  
--|     Purpose        : Test whether a character is a lower case letter.
--|
--|     Parameters     : 
--|                      c     - input   Character.
--| 
--|     Result         : True if the argument c is a lower case letter  of  
--|                      the alphabet, false otherwise.      
--| 
--| 
--|     See Also       : Is_Digit, Is_Upper, Is_Alpha
--|----------------------------------------------------------------------------- 
      FUNCTION  Is_Lower  ( CONSTANT c    : IN CHARACTER
                          ) RETURN BOOLEAN;
--+----------------------------------------------------------------------------- 
--|     Function Name  : Is_Digit
--| 1.
--|     Overloading    : None 
--|  
--|     Purpose        : Test whether a character is  a digit 0-9. 
--|
--|     Parameters     : 
--|                      c     - input   Character.
--| 
--|     Result         : True if the argument c is a  digit, false
--|                      otherwise.      
--| 
--| 
--|     See Also       : Is_Alpha, Is_Upper, Is_Lower
--|----------------------------------------------------------------------------- 
     FUNCTION  Is_Digit  ( CONSTANT c    : IN CHARACTER
                         ) RETURN BOOLEAN;
--+----------------------------------------------------------------------------- 
--|     Function Name  : Is_Space
--| 1.
--|     Overloading    : None 
--|  
--|     Purpose        : Test whether a character is a blank, tab or newline.
--|
--|     Parameters     : 
--|                      c     - input   Character.
--| 
--|     Result         : True if the argument c is a blank or tab(HT), 
--|                      false otherwise.      
--| 
--| 
--|     See Also       : Is_Digit, Is_Upper, Is_Lower, Is_Alpha
--|----------------------------------------------------------------------------- 
     FUNCTION  Is_Space  ( CONSTANT c    : IN CHARACTER
                         ) RETURN BOOLEAN;
--+----------------------------------------------------------------------------- 
--|     Function Name  : To_Upper
--| 1.
--|     Overloading    : None 
--|  
--|     Purpose        :Convert a character to upper case.
--|
--|     Parameters     : 
--|                      c     - input   Character.
--| 
--|     Result         :  Character converted to upper case.
--| 
--| 
--|     See Also       : To_Lower, Is_Upper, Is_Lower
--|----------------------------------------------------------------------------- 
     FUNCTION  To_Upper  ( CONSTANT  c    : IN CHARACTER
                         ) RETURN CHARACTER;
--+----------------------------------------------------------------------------- 
--|     Function Name  : To_Upper
--| 1.
--|     Overloading    : None 
--|  
--|     Purpose        :Convert a string to upper case.
--|
--|     Parameters     : 
--|                      val     - input, string to be converted   
--| 
--|     Result         :  string .
--| 
--| 
--|     See Also       : To_Lower, Is_Upper, Is_Lower
--|----------------------------------------------------------------------------- 
     FUNCTION  To_Upper  ( CONSTANT  val    : IN String
                         ) RETURN STRING;
--+----------------------------------------------------------------------------- 
--|     Function Name  : To_Lower
--| 1.
--|     Overloading    : None 
--|  
--|     Purpose        : Convert a Character to lower case.
--|
--|     Parameters     : 
--|                      c     - input   Character.
--| 
--|     Result         : Character converted to lower case.
--| 
--|     See Also       : To_Upper, Is_Upper, Is_Lower
--|----------------------------------------------------------------------------- 
     FUNCTION  To_Lower  ( CONSTANT  c    : IN CHARACTER
                         ) RETURN CHARACTER;
--+----------------------------------------------------------------------------- 
--|     Function Name  : To_Lower
--| 1.
--|     Overloading    : None 
--|  
--|     Purpose        : Convert a String  to lower case.
--|
--|     Parameters     : 
--|                      val     - input  string to be converted.
--| 
--|     Result         : string
--| 
--|     See Also       : To_Upper, Is_Upper, Is_Lower
--|----------------------------------------------------------------------------- 
     FUNCTION  To_Lower  ( CONSTANT  val    : IN STRING
                         ) RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : StrCat
--| 1.2.1
--|     Overloading    : None
--|
--|     Purpose        : Concatenate two string.
--|
--|     Parameters     :
--|                      l_str    - input,  STRING,
--|                      r_str    - input,  STRING,
--|
--|     Result         : Concatenated string.
--|
--|-----------------------------------------------------------------------------
    FUNCTION StrCat   ( CONSTANT l_str  : IN STRING;
                        CONSTANT r_str  : IN STRING
                      )  RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : StrNCat
--| 1.2.2
--|     Overloading    : None
--|
--|     Purpose        : Concatenate upto n characters of r_string to l_string.
--|
--|     Parameters     :
--|                      l_str    - input,  STRING,
--|                      r_str    - input,  STRING,
--|
--|     Result         : Concatenated string.
--|
--|-----------------------------------------------------------------------------
    FUNCTION StrNCat  ( CONSTANT l_str  : IN STRING;
                        CONSTANT r_str  : IN STRING;
                        CONSTANT n      : INTEGER
                       )  RETURN STRING;
--+-----------------------------------------------------------------------------
--|     Function Name  : StrCpy
--| 1.2.3
--|     Overloading    : None
--|
--|     Purpose        : Copy r_string to l_string.
--|
--|     Parameters     :
--|                      l_str    - output,  STRING, target string
--|                      r_str    - input, STRING, source string
--|
--|     Result         : 
--|
--|     NOTE           : If the length of target string is greater than
--|                      the source string, then target string is padded
--|                      with space characters on the right side and when
--|                      the length of target string is shorter than the 
--|                      length of source string only left most characters
--|                      of the source string will be be copied to the target.
--|                      
--| 
--|     USE            :
--|                      Variable s1: string(1 TO 8);
--|
--|                       StrCpy(s1, "123456789A");
--|                       s1 will hold "12345678"      
--|-----------------------------------------------------------------------------
    PROCEDURE StrCpy   ( VARIABLE l_str : OUT STRING;
                         CONSTANT r_str : IN STRING
                       );
--+-----------------------------------------------------------------------------
--|     Function Name  : StrNCpy
--| 1.2.4
--|     Overloading    : None
--|
--|     Purpose        : Copy  at most n characters of r_string to l_string.
--|
--|     Parameters     :
--|                      l_str    - output,  STRING, target
--|                      r_str    - input, STRING,   source
--|                      n        - input, Natural, number of characters to
--|                                        to be copied.
--|
--|     Result         : l_string holds the result.
--|
--|     NOTE           : If n is less than or equal to zero then a srting
--|                      filled with blanks is returned. 
--|
--|
--|-----------------------------------------------------------------------------
    PROCEDURE  StrNCpy ( VARIABLE l_str : OUT STRING;
                         CONSTANT r_str : IN STRING;
                         CONSTANT n     : IN NATURAL
                       );
--+-----------------------------------------------------------------------------
--|     Function Name  : StrCmp
--| 
--|     Overloading    : None
--|
--|     Purpose        : Compare left input string to right input string. 
--|
--|     Parameters     :
--|                      l_str    - input,  STRING,
--|                      r_str    - input, STRING,
--|
--|     Result         : INTEGER, returns an integer less than 0 if the left string
--|                      is less than the right string, returns integer 0 if the 
--|                      the string are equal and returns an integer greater than
--|                      0 if the left string is greater than the right string.
--|
--|
--|-----------------------------------------------------------------------------
    FUNCTION StrCmp    ( CONSTANT l_str  : IN STRING;
                         CONSTANT r_str  : IN STRING
                       ) RETURN INTEGER;
--+-----------------------------------------------------------------------------
--|     Function Name  : StrNCmp
--| 
--|     Overloading    : None
--|
--|     Purpose        : Compare  at most n characters of left input string
--|                       to right input string. Returns an Integer.
--|
--|     Parameters     :
--|                      l_str    - input,  STRING,
--|                      r_str    - input, STRING,
--|                      n        - input, Natural,
--|
--|     Result         : Returns an integer less than 0 if  left_most n 
--|                      characters of the  left string is less than the
--|                      right string, returns integer 0 if both strings 
--|                      are equal, and returns an integer greater than 0 
--|                      if the left string is greater than the right string.
--|
--|-----------------------------------------------------------------------------
    FUNCTION StrNCmp   ( CONSTANT l_str : IN STRING;
                         CONSTANT r_str : IN STRING;
                         CONSTANT n     : IN Natural
                       ) RETURN INTEGER;
--+-----------------------------------------------------------------------------
--|     Function Name  : StrNcCmp
--| 
--|     Overloading    : None
--|
--|     Purpose        : Compare  to strings and determine  whether  left input 
--|                      string is less than, equal to or greater than right
--|                      input string. The comparison is Not case sensitive.
--|
--|     Parameters     :
--|                      l_str    - input,  STRING,
--|                      r_str    - input, STRING,
--|
--|     Result         : Returns an integer less than 0 if  left_most n 
--|                      characters of the  left string is less than the
--|                      right string, returns integer 0 if both strings 
--|                      are equal, and returns an integer greater than 0 
--|                      if the left string is greater than the right string.
--|
--|-----------------------------------------------------------------------------
    FUNCTION StrNcCmp   ( CONSTANT l_str : IN STRING;
                          CONSTANT r_str : IN STRING
                        ) RETURN INTEGER;
--+-----------------------------------------------------------------------------
--|     Function Name  : StrLen
--| 
--|     Overloading    : None
--|
--|     Purpose        : Returns length of a string. 
--|
--|     Parameters     :
--|                      l_str    - input,  STRING,
--|
--|     Result         : Natural 
--|
--|     NOTE           : 
--|                     This is in fact same as String'LENGTH provided
--|                     by VHDL.   
--|
--|
--|-----------------------------------------------------------------------------
    FUNCTION StrLen    ( CONSTANT l_str      : IN STRING
                       ) RETURN NATURAL;

--+-----------------------------------------------------------------------------
--|     Function Name  :Copyfile
--| 1.2.4
--|     Overloading    : None
--|
--|     Purpose        : Copy one  ASCII_TEXT file to an other ASCII_TEXT file. 
--|
--|     Parameters     :
--|                      in_fptr  -- input, ASCII_TEXT, source file
--|                      out_fptr -- output, ASCII_TEXT, destination file 
--|
--|     NOTE           :
--|
--|     USE            :
--|                     file  romdata   :  ASCII_TEXT IS  IN  "NEW_ROM.dat";
--|                     file  dest_file :  ASCII_TEXT IS  OUT "SAVE_ROM.dat"; 
--|
--|                     Copyfile(romdata, dest_file);
--|-----------------------------------------------------------------------------
    PROCEDURE Copyfile  ( VARIABLE  in_fptr  : IN ASCII_TEXT;
                          VARIABLE  out_fptr : OUT ASCII_TEXT
                          );

--+-----------------------------------------------------------------------------
--|     Function Name  :Copyfile
--| 1.2.4
--|     Overloading    : None
--|
--|     Purpose        : Copy one TEXT file to an other TEXT file. 
--|
--|     Parameters     :
--|                      in_fptr  -- input, TEXT,
--|                      out_fptr -- output, TEXT 
--|
--|     NOTE           :
--|                      This is combination of READLINE() and WRITELINE() 
--|                      procedures provided in the standard
--|                      TEXTIO package.
--|
--|     USE            :
--|                     file  in_f   :  TEXT IS  IN "data_in";
--|                     file  out_f  :  TEXT IS OUT  "save_data"; 
--|
--|                     Copyfile(in_f, out_f);
--|-----------------------------------------------------------------------------
    PROCEDURE Copyfile ( VARIABLE  in_fptr  : IN TEXT;
                         VARIABLE  out_fptr : OUT TEXT
                       );

--+-----------------------------------------------------------------------------
--|     Function Name  : fprint
--| 1.2.1
--|     Overloading    : None
--|
--|     Purpose        : Convert up to 10 arguments to a file according to 
--|                      the format specifications give by a format string.
--|
--|     Parameters     :
--|                      file_ptr  - output ASCII_TEXT, destination file
--|                      format    - input STRING, format control specifications.
--|                      arg1      - input STRING,
--|                      arg2      - input STRING,
--|                      arg3      - input STRING,
--|                      arg4      - input STRING,
--|                      arg5      - input STRING,
--|                      arg6      - input STRING,
--|                      arg7      - input STRING,
--|                      arg8      - input STRING,
--|                      arg9      - input STRING,
--|                      arg10     - input STRING
--|
--|     Result         : formated TEXT.
--|
--|     Note:          This procedure provides formated output
--|                    of upto 10 arguments.
--|
--|-----------------------------------------------------------------------------
    PROCEDURE fprint   ( VARIABLE file_ptr      : OUT ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         CONSTANT arg1          : IN STRING := "";
                         CONSTANT arg2          : IN STRING := "";
                         CONSTANT arg3          : IN STRING := "";
                         CONSTANT arg4          : IN STRING := "";
                         CONSTANT arg5          : IN STRING := "";
                         CONSTANT arg6          : IN STRING := "";
                         CONSTANT arg7          : IN STRING := "";
                         CONSTANT arg8          : IN STRING := "";
                         CONSTANT arg9          : IN STRING := "";
                         CONSTANT arg10         : IN STRING := ""
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fprint
--| 1.2.1
--|     Overloading    : None
--|
--|     Purpose        : Print up to 10 arguments to a file according to 
--|                      the specifications given by a format string.
--|
--|     Parameters     :
--|                      file_ptr      - output TEXT, destination file
--|                      line_ptr      - INOUT  LINE, pointer to a string.
--|                      format        - input STRING, format control specifications.
--|                      arg1          - input STRING,
--|                      arg2          - input STRING,
--|                      arg3          - input STRING,
--|                      arg4          - input STRING,
--|                      arg5          - input STRING,
--|                      arg6          - input STRING,
--|                      arg7          - input STRING,
--|                      arg8          - input STRING,
--|                      arg9          - input STRING,
--|                      arg10         - input STRING
--|
--|     Result         : formated TEXT.
--|
--|     Note:          This procedure provides formated output
--|                    of upto 10 arguments.
--|
--|-----------------------------------------------------------------------------
    PROCEDURE fprint  (  VARIABLE file_ptr      : OUT TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         CONSTANT arg1          : IN STRING := "";
                         CONSTANT arg2          : IN STRING := "";
                         CONSTANT arg3          : IN STRING := "";
                         CONSTANT arg4          : IN STRING := "";
                         CONSTANT arg5          : IN STRING := "";
                         CONSTANT arg6          : IN STRING := "";
                         CONSTANT arg7          : IN STRING := "";
                         CONSTANT arg8          : IN STRING := "";
                         CONSTANT arg9          : IN STRING := "";
                         CONSTANT arg10         : IN STRING := ""
                        );
--+-----------------------------------------------------------------------------
--|     Function Name  : fprint
--| 1.2.2
--|     Overloading    : None
--|
--|     Purpose        : Print up to 10 arguments to a string buffer according to 
--|                      the specifications given by a format string.
--|
--|     Parameters     :
--|                      string_buf    - output STRING,
--|                      format        - input STRING
--|                      arg1          - input STRING,
--|                      arg2          - input STRING,
--|                      arg3          - input STRING,
--|                      arg4          - input STRING,
--|                      arg5          - input STRING,
--|                      arg6          - input STRING,
--|                      arg7          - input STRING,
--|                      arg8          - input STRING,
--|                      arg9          - input STRING,
--|                      arg10         - input STRING
--|
--|     Result         : STRING  representation  of arguments.
--|
--|     Note:          This procedure provides formated output
--|                    of upto 10 arguments.
--|
--|-----------------------------------------------------------------------------
   PROCEDURE fprint    ( VARIABLE string_buf    : OUT STRING;    
                         CONSTANT format        : IN STRING;
                         CONSTANT arg1          : IN STRING := "";
                         CONSTANT arg2          : IN STRING := "";
                         CONSTANT arg3          : IN STRING := "";
                         CONSTANT arg4          : IN STRING := "";
                         CONSTANT arg5          : IN STRING := "";
                         CONSTANT arg6          : IN STRING := "";
                         CONSTANT arg7          : IN STRING := "";
                         CONSTANT arg8          : IN STRING := "";
                         CONSTANT arg9          : IN STRING := "";
                         CONSTANT arg10         : IN STRING := ""
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fscan
--| 
--|     Overloading    : None
--|
--|     Purpose        : To read text from a file according to specifications
--|                      given by a format string  and save the results into 
--|                      the corresponding arguments.
--|
--|     Parameters     :
--|                      file_ptr   - input ASCII_TEXT, input file
--|                      format     - input STRING, format control specifications.
--|                      arg1       - output STRING,
--|                      arg2       - output STRING,
--|                      arg3       - output STRING,
--|                      arg4       - output STRING,
--|                      arg5       - output STRING,
--|                      arg6       - output STRING,
--|                      arg7       - output STRING,
--|                      arg8       - output STRING,
--|                      arg9       - output STRING,
--|                      arg10      - output STRING
--|                      arg11      - output STRING,
--|                      arg12      - output STRING,
--|                      arg13      - output STRING,
--|                      arg14      - output STRING,
--|                      arg15      - output STRING,
--|                      arg16      - output STRING,
--|                      arg17      - output STRING,
--|                      arg18      - output STRING,
--|                      arg19      - output STRING,
--|                      arg20      - output STRING,
--|                      arg_count  - number of arguments passed to fscan
--|
--|     Result         : STRING  representation of given text.
--|
--|
--|     Note:          This procedure extracts upto twenty arguments
--|                    from a line in a file.
--|
--|-----------------------------------------------------------------------------
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING;
                         VARIABLE arg18         : OUT STRING;
                         VARIABLE arg19         : OUT STRING;
                         VARIABLE arg20         : OUT STRING;
                         CONSTANT arg_count     : IN INTEGER := 20
                        );
--|-----------------------------------------------------------------------------
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING;
                         VARIABLE arg18         : OUT STRING;
                         VARIABLE arg19         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
                        
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING;
                         VARIABLE arg18         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
                        
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
                        
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
     PROCEDURE fscan   ( VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING 
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fscan
--| 1.2.3
--|     Overloading    : None
--|
--|     Purpose        : To read text from a file according to specifications
--|                      given by the format string and save the results into
--|                      the corresponding arguments.
--|
--|     Parameters     :
--|                         file_ptr    - input TEXT,
--|                         line_ptr    - input_output LINE,
--|                         format      - input STRING,
--|                         arg1        - output STRING,
--|                         arg2        - output STRING,
--|                         arg3        - output STRING,
--|                         arg4        - output STRING,
--|                         arg5        - output STRING,
--|                         arg6        - output STRING,
--|                         arg7        - output STRING,
--|                         arg8        - output STRING,
--|                         arg9        - output STRING,
--|                         arg10       - output STRING
--|                         arg11       - output STRING,
--|                         arg12       - output STRING,
--|                         arg13       - output STRING,
--|                         arg14       - output STRING,
--|                         arg15       - output STRING,
--|                         arg16       - output STRING,
--|                         arg17       - output STRING,
--|                         arg18       - output STRING,
--|                         arg19       - output STRING,
--|                         arg20       - output STRING,
--|                         arg_count   - input INTEGER
--|
--|     Result         : STRING  representation of given text.
--|
--|     Algorithm      :
--|                      Read a line from the file into variable l ( which is aline).
--|                      split the format string into small tokens consisting of
--|                      printable characters and control format.
--|                      depending on control format read from l. Read an other line
--|                      from the file when length of l has become zero. and format
--|
--|
--|     Note:          This procedure extracts upto twenty arguments
--|                    from a line in a file.
--|
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING;
                         VARIABLE arg18         : OUT STRING;
                         VARIABLE arg19         : OUT STRING;
                         VARIABLE arg20         : OUT STRING;
                         CONSTANT arg_count     : IN INTEGER := 20
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING;
                         VARIABLE arg18         : OUT STRING;
                         VARIABLE arg19         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING;
                         VARIABLE arg18         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9         : OUT STRING 
                        ); 
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING 
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fscan
--| 1.2.4
--|     Overloading    : None
--|
--|     Purpose        : To read text from a string buffer according to
--|                      specifications given by a format string and save
--|                      the result into corresponding  arguments.
--|
--|     Parameters     :
--|                         string_buf     - input String,
--|                         format         - input STRING,
--|                         arg1           - output STRING,
--|                         arg2           - output STRING,
--|                         arg3           - output STRING,
--|                         arg4           - output STRING,
--|                         arg5           - output STRING,
--|                         arg6           - output STRING,
--|                         arg7           - output STRING,
--|                         arg8           - output STRING,
--|                         arg9           - output STRING,
--|                         arg10          - output STRING
--|                         arg11          - output STRING,
--|                         arg12          - output STRING,
--|                         arg13          - output STRING,
--|                         arg14          - output STRING,
--|                         arg15          - output STRING,
--|                         arg16          - output STRING,
--|                         arg17          - output STRING,
--|                         arg18          - output STRING,
--|                         arg19          - output STRING,
--|                         arg20          - output STRING,
--|                         arg_count      - input INTEGER  - the number of arguments passed to fscan
--|
--|     Result         : STRING  representation given TEXT.
--|
--|     Note:          This procedure extracts upto twenty arguments
--|                    from a string buffer.
--|
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING;
                         VARIABLE arg18         : OUT STRING;
                         VARIABLE arg19         : OUT STRING;
                         VARIABLE arg20         : OUT STRING;
                         CONSTANT arg_count     : IN INTEGER := 20
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING;
                         VARIABLE arg18         : OUT STRING;
                         VARIABLE arg19         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING;
                         VARIABLE arg18         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING;
                         VARIABLE arg17         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING;
                         VARIABLE arg16         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING;
                         VARIABLE arg15         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING;
                         VARIABLE arg14         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING;
                         VARIABLE arg13         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING;
                         VARIABLE arg12         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING;
                         VARIABLE arg11         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING;
                         VARIABLE arg2          : OUT STRING;
                         VARIABLE arg3          : OUT STRING;
                         VARIABLE arg4          : OUT STRING;
                         VARIABLE arg5          : OUT STRING;
                         VARIABLE arg6          : OUT STRING;
                         VARIABLE arg7          : OUT STRING;
                         VARIABLE arg8          : OUT STRING;
                         VARIABLE arg9          : OUT STRING;
                         VARIABLE arg10         : OUT STRING
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9         : OUT STRING 
                        ); 
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING 
                        );
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING 
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fgetc
--| 1.2.4
--|     Overloading    : None
--|
--|     Purpose        : To read the next character from a  file of type
--|                      ASCII_TEXT.
--|
--|     Parameters     :
--|                         stream    - input ASCII_TEXT,
--|
--|     Result         : Returns the ordinate value of  the character read. If
--|                      end of file is reached then return - 1
--|
--|     Note:          : The ASCII_TEXT is defined in the package Std_IOpak to 
--|                      be a  file of CHARACTERS.
--|
--|     USE:           :
--|                      VARIABLE  n : Integer;
--|                      FILE f_in   : ASCII_TEXT IS IN "design.doc";
--|                      
--|                        fgetc(n, f_in);
--|
--|                       Will return ordinal value of character in integer n
--|-----------------------------------------------------------------------------
     PROCEDURE fgetc    ( VARIABLE result  : OUT INTEGER;
                          VARIABLE stream  : IN ASCII_TEXT
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fgetc
--| 
--|     Overloading    : None
--|
--|     Purpose        : To read the next character from a  file of type TEXT.
--|
--|     Parameters     :
--|                         stream    - input TEXT,
--|                         ptr       - INOUT, LINE 
--|     Result         :Integer,  the ordinate value of  the character being read. 
--|                               -1  when end of file (EOF).
--|
--|     Note:          : The TEXT is defined in the package TEXTIO to be 
--|                      a  file of string.
--|                  
--|     USE:           :
--|                      VARIABLE  n : Integer;
--|                      FILE f_in   : TEXT IS IN "design.doc";
--|                      
--|                        fgetc(n, f_in);
--|
--|                       Will return ordinal value of character in integer n
--|-----------------------------------------------------------------------------
     PROCEDURE fgetc    ( VARIABLE result  : OUT INTEGER;
                          VARIABLE stream  : IN TEXT;
                          VARIABLE ptr     : INOUT LINE
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fgets
--| 1.2.4
--|     Overloading    : None
--|
--|     Purpose        : To read, at most, the next n characters from a file
--|                      of type ASCII_TEXT and save them to a string.
--|
--|     Parameters     :
--|                      l_str  -- output, STRING,
--|  
--|                      n      -- input, Natural, number of 
--|                                     characters to be read.
--|                      stream -- input, ASCII_TEXT,  input file.
--|     
--|     result         : string
--|
--|     Note:          : The ASCII_TEXT is defined in the package Std_IOpak to 
--|                      be a  file of CHARACTERS.
--|     
--|     USE:           :
--|                      VARIABLE  str_buf : string(1 TO 100);
--|                      FILE      f_in    : ASCII_TEXT IS IN "design.doc";
--|                      
--|                        fgets(str_buf, 50, f_in);
--|
--|                       Will read in at most 50 characters  from the file
--|                       design.doc and place them in str_buf.
--|-----------------------------------------------------------------------------
    PROCEDURE fgets  ( VARIABLE l_str   : OUT STRING;
                       CONSTANT n       : IN NATURAL;
                       VARIABLE stream  : IN ASCII_TEXT
                     );

--+-----------------------------------------------------------------------------
--|     Function Name  : fgets
--| 1.2.4
--|     Overloading    : None
--|
--|     Purpose        : To read, at most, the next n characters from a file
--|                      of type TEXT and save them to a string.
--|
--|     Parameters     :
--|                      l_str    -- output, STRING,
--|                      n        -- input, Natural, number of 
--|                                     characters to be read.
--|                      stream   -- input, TEXT,  input file.
--|                      line_ptr -- inout LINE,
--|     
--|     result         : string
--|
--|     Note:          : The TEXT is defined in the package TEXTIO to be 
--|                      a  file of string.
--|     
--|     USE:           :
--|                      VARIABLE  str_buf : string(1 TO 100);
--|                      FILE      f_in    : TEXT IS IN "design.doc";
--|                      
--|                        fgets(str_buf, 50, f_in);
--|
--|                       Will read in at most 50 characters  from the file
--|                       design.doc    and place them in str_buf.
--|-----------------------------------------------------------------------------
    PROCEDURE fgets  ( VARIABLE l_str    : OUT STRING;
                       CONSTANT n        : IN NATURAL;
                       VARIABLE stream   : IN TEXT;
                       VARIABLE line_ptr : INOUT LINE
                     );

--+---------------------------------------------------------------------------
--|     Function Name  : fgetline
--| 
--|     Overloading    : None
--|
--|     Purpose        : To read a line from the input ASCII_TEXT file and 
--|                      save into a string. 
--|
--|     Parameters     :
--|                         l_str  -- output, STRING,
--|                         stream -- input, ASCII_TEXT, input file 
--|
--|     result         : string.
--|
--|     Note:          : The ASCII_TEXT is defined in the package Std_IOpak to 
--|                      be a  file of CHARACTERS.
--|
--|     USE:           :
--|                      VARIABLE  line_buf : string(1 TO 256);
--|                      FILE      in_file : ASCII_TEXT IS IN "file_ascii_in.dat";
--|                      
--|                        fgetline(line_buf, in_file);
--|
--|                       Will read a line  from the file
--|                       file_ascii_in.dat  and place  into  line_buf.
--|-----------------------------------------------------------------------------
   PROCEDURE fgetline  ( VARIABLE l_str   : OUT STRING;
                         VARIABLE stream  : IN ASCII_TEXT 
                       );

--+---------------------------------------------------------------------------
--|     Function Name  : fgetline
--| 
--|     Overloading    : None
--|
--|     Purpose        : To read a line from the input TEXT file and 
--|                      save into a string. 
--|
--|     Parameters     :
--|                         l_str    -- output, STRING,
--|                         stream   -- input, TEXT, input file 
--|
--|     result         : string.
--|
--|     Note:          : The TEXT is defined in the package TEXTIO to be 
--|                      a  file of string.
--|     USE:           :
--|                      VARIABLE  line_buf : string(1 TO 256);
--|                      FILE      in_file : TEXT IS IN "file_text_in.dat";
--|                      
--|                        fgetline(line_buf, in_file);
--|
--|                       Will read a line  from the file
--|                       file_text_in.dat  and place  into  line_buf.
--|
--|-----------------------------------------------------------------------------
   PROCEDURE fgetline  ( VARIABLE l_str    : OUT STRING;
                         VARIABLE stream   : IN TEXT;
                         VARIABLE line_ptr : INOUT LINE
                       );

--+-----------------------------------------------------------------------------
--|     Function Name  : fputc
--| 1.2.4
--|     Overloading    : None
--|
--|     Purpose        :To  write a character to an ASCII_TEXT file. 
--|
--|     Parameters     :
--|                         c         -- input, CHARACTER,
--|                         stream    -- output ASCII_TEXT, 
--|
--|     Result         : 
--|
--|     Note:          : The ASCII_TEXT is defined in the package Std_IOpak to 
--|                      be a  file of CHARACTERS.
--|
--|                      This procedure is equivalent to VHDL WRITE(stream, c).
--|
--|     USE:           :
--|                      VARIABLE  str12 : string(1 TO 12);
--|                      FILE      out_file : ASCII_TEXT IS OUT "file_ascii_out.dat";
--|                      
--|                        str12 := "0123456789ab";
--|                        FOR i IN 1 TO 12 LOOP
--|                            fputc(str12(i), out_file);
--|                        END LOOP;
--|
--|                      Will write all the 12 characters to file
--|                       file_ascii_out.dat
--|-----------------------------------------------------------------------------
     PROCEDURE fputc    ( CONSTANT c      : IN CHARACTER;   
                          VARIABLE stream : OUT ASCII_TEXT
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fputc 
--| 1.2.4 
--|     Overloading    : None 
--| 
--|     Purpose        : To write a character to a TEXT file. 
--| 
--|     Parameters     : 
--|                         c         -- input, CHARACTER, 
--|                         stream    -- output, TEXT,  
--|                         line_ptr  -- INOUT LINE
--| 
--|     Result         : 
--| 
--|     Note:          : The STD TEXTIO package has declared TEXT as a 
--|                      file of STRING. This is not same as file of CHARACTERS.
--|                       
--|     USE:           :
--|                      VARIABLE  str12    : string(1 TO 12);
--|                      VARIABLE  l        : LINE;
--|                      FILE      out_file : TEXT IS OUT "file_text_out.dat";
--|                      
--|                        str12 := "0123456789ab";
--|                        FOR i IN 1 TO 12 LOOP
--|                            fputc(str12(i), out_file, l);
--|                        END LOOP;
--|                        fputc(LF, out_file, l);      -- line feed 
--|
--|                      Will write  contents of the str12  to file
--|                       file_text_out.dat. The characters will be kept in
--|                       the line pointer l untill line feed character is
--|                        encouneterd.
--| 
--|-----------------------------------------------------------------------------
     PROCEDURE fputc    ( CONSTANT c        : IN character;
                          VARIABLE stream   : OUT TEXT;
                          VARIABLE line_ptr : INOUT LINE 
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fputs 
--| 1.2.4 
--|     Overloading    : None 
--| 
--|     Purpose        : To write a string to an ASCII_ TEXT file. 
--| 
--|     Parameters     : 
--|                         l_str     -- input, string
--|                         stream    -- output, ASCII_TEXT,  
--| 
--|     Result         : 
--| 
--|     Note:          : The ASCII_TEXT is defined in the package Std_IOpak to 
--|                      be a  file of CHARACTERS.
--|
--|     USE:           :
--|                      VARIABLE  str_buf : string(1 TO 256);
--|                      FILE      out_file : ASCII_TEXT IS OUT "file_ascii_out.dat";
--|                      
--|                            fputs(str_buf, out_file);
--|
--|                      Will write contents of str_buf to the file
--|                       file_ascii_out.dat
--| 
--|-----------------------------------------------------------------------------
     PROCEDURE fputs    ( CONSTANT l_str      : IN STRING;
                          VARIABLE stream  : OUT ASCII_TEXT 
                        );

--+-----------------------------------------------------------------------------
--|     Function Name  : fputs 
--| 1.2.4 
--|     Overloading    : None 
--| 
--|     Purpose        : To write a string to a TEXT file. 
--| 
--|     Parameters     : 
--|                         l_str     -- input, string, 
--|                         stream    -- output, TEXT,  
--|                         line_ptr  -- INOUT LINE,
--| 
--|     Result         : 
--| 
--|     Note:          : The STD TEXTIO package has declared TEXT as a 
--|                      file of STRING. This is not same as file of CHARACTERS.
--|     USE:           :
--|                      VARIABLE  str_buf : string(1 TO 256);
--|                      VARIABLE  lptr    : LINE;
--|                      FILE      out_file : TEXT IS OUT "file_text_out.dat";
--|                      
--|                            fputs(str_buf, out_file, lptr);
--|
--|                      Will write contents of str_buf to the file
--|                       file_text_out.dat
--| 
--|-----------------------------------------------------------------------------
     PROCEDURE fputs    ( CONSTANT l_str    : IN STRING;
                          VARIABLE stream   : OUT TEXT;
                          VARIABLE line_ptr : INOUT LINE 
                        );
--+-----------------------------------------------------------------------------
--|     Function Name  : Find_Char
--| 
--|     Overloading    : None
--|
--|     Purpose        : TO find a given character in a string and 
--|                      return its position.
--|
--|     Parameters     :
--|                         l_str    - input  STRING,
--|                         c        - input Character,
--|
--|     Result         : NATURAL number representing the position of character
--|                      in the string.  returns 0 if character not found in the
--|                      string.
--|
--|     USE:           :
--|                      VARIABLE  str14 : string(1 TO 14);
--|                      VARIABLE  indx  : integer;
--|                      
--|                         str14 :="This is a test";
--|                         indx := Fid_Char(str14, 'i');
--|
--|                      Will assign value of 3 to the variable indx.
--|-----------------------------------------------------------------------------
   FUNCTION Find_Char    ( CONSTANT  l_str    : IN  STRING;
                           CONSTANT  c        : IN CHARACTER
                         ) RETURN NATURAL;
--+----------------------------------------------------------------------------- 
--|     Function Name  : Sub_Char 
--| 
--|     Overloading    : None 
--| 
--|     Purpose        : To subtitute  a new  character  at a given position
--|                      of the input  string.  
--| 
--|     Parameters     : 
--|                         l_str    - input  STRING, 
--|                         c        - input Character, 
--|                         n        - input Natural, position at which character 
--|                                          is to be substituted.
--|     Result         : STRING 
--|
--|     USE:           :
--|                      VARIABLE  str14 : string(1 TO 14);
--|                      VARIABLE  indx  : integer;
--|                      
--|                         str14 :="This is a test";
--|                         IF ((indx = Find_Char(str14, 't')) /= 0) THEN
--|                              str14 := Sub_Char(str14, 'T', indx);
--|                         END IF;
--|
--|                      Will assign  the value    "This is a Test" to str14.
--|-----------------------------------------------------------------------------
    FUNCTION Sub_Char     ( CONSTANT  l_str  : IN  STRING;
                             CONSTANT  c      : IN CHARACTER;
                             CONSTANT  n      : IN NATURAL
                           ) RETURN STRING;
--
-- related to time
--
--+-----------------------------------------------------------------------------
--|     Function Name  : From_String
--| 
--|     Overloading    : None
--|
--|     Purpose        : Convert  from a String to a time.
--|
--|     Parameters     :
--|                      str     - input ,  string to be converted,
--|
--|     Result         : Time
--|
--|     NOTE           : 
--|
--|     Use            :
--|                      VARIABLE t : time ; 
--|
--|                       t := From_String ("   893.56 us");
--|                       This statement will set t to  time 893.56 us.
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN TIME;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.1.7
--|     Overloading    : None
--|
--|     Purpose        : Convert Time   to a String.
--|
--|     Parameters     :
--|                      val     - input,  TIME,
--|                      format  - input string
--|
--|     Result         : STRING  representation of TIME.
--|
--|
--|-----------------------------------------------------------------------------
    FUNCTION To_String ( CONSTANT val    : IN TIME;
                         CONSTANT format : IN STRING := ""
                       )  RETURN STRING;

END std_iopak;




