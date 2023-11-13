-- ----------------------------------------------------------------------------
--
--  Copyright (c) Mentor Graphics Corporation, 1982-1996, All Rights Reserved.
--                       UNPUBLISHED, LICENSED SOFTWARE.
--            CONFIDENTIAL AND PROPRIETARY INFORMATION WHICH IS THE
--          PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS.
--
--
-- PackageName :  std_iopak
-- Title       :  Package Body for STD_IOPAK
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
--     v1.100    |  M.K.Dhodhi  |  11/19/91   | Compatible w/ Vantage 3.650 Release 
--     v1.110    |  wdb         |  01/27/92   | compatible w/Intermetrics
--     v1.110    |  M.K.Dhodhi  |  02/13/92   | fixing bug in T0_String input time
--                                            | fixing comment in SOX_Machine
--     v1.110    |  M.K.Dhodhi  |  03/06/92   | production release
--     v1.200    |  M.K.Dhodhi  |  04/21/92   | stand alone version
--     v1.130    |  M.K.Dhodhi  |  08/03/92   | production release
--     v1.140    |  M.K.Dhodhi  |  11/05/92   | fixing real 0.0 case for To_String 
--                              |             | an extra loop in default time.
--     v1.150    |  M.K.Dhodhi  |  11/17/92   | extending fscan upto 20 arguments.
--                                            | fixing default 0 time.
--     v1.160    |  M.K.Dhodhi  |  02/11/93   | fixing Find_Char
--     v1.610    |  wrm         |  03/30/93   | fixed error assertions in From_String, From_XString
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

PACKAGE BODY std_iopak is

 -- ************************************************************************
 -- Display Banner
 -- ************************************************************************

    FUNCTION DisplayBanner return BOOLEAN is

    BEGIN
       ASSERT FALSE
           report LF &
		  "--  Initializing Std_Developerskit (Std_IOpak package v2.10)" & LF &
		  "--  Copyright by Mentor Graphics Corporation" & LF &
		  "--  [Please ignore any warnings associated with this banner.]"
           severity NOTE;
       return TRUE;
    END;

    --CONSTANT StdIOpakBanner : BOOLEAN := DisplayBanner;
    CONSTANT StdIOpakBanner : BOOLEAN := TRUE;

  TYPE char_to_hex_table  is array (character'low To character'high) of Integer;
  TYPE char_to_oct_table  is array (character'low TO character'high) of integer;
  SUBTYPE INT8 is INTEGER RANGE 0 to 7;

  CONSTANT WarningsOn : BOOLEAN := TRUE;
  CONSTANT END_OF_LINE_MARKER : STRING(1 TO 2) := LF & ' ';
  CONSTANT invalid_input : INTEGER := -201;
-- ------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------
--        P L E A S E       N O T E 
--    Following routines are hidden, they are not visible to the user of
--    this package but are used internally 
-- -----------------------------------------------------------------------------
--+-----------------------------------------------------------------------------
--|     Procedure Name  : S_Machine 
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Finite State automaton to recognise a string format.
--|                      format will be broken into field width, precision
--|                      and justification (left or right).
--|
--|     Parameters     : fwidth        -- output, INTEGER, field width
--|                      precision     -- output, INTEGER, precison 
--|                      justify -- OUTPUT, BIT 
--|                                       '0' right justified,
--|                                        '1' left justified 
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         :  
--|
--|     NOTE           :
--|                      This procedure is
--|                      called in the function To_String.  
--|
--|     Use            :
--|                    VARIABLE   fmt : STRING(1 TO format'LENGTH) := format;
--|                    VARIABLE fw       : INTEGER;
--|                    VARIABLE precis   : INTEGER;
--|                    VARIABLE justfy    : BIT; 
--|
--|                    S_Machine(fw, precis, justy, fmt); 
--|
--|-----------------------------------------------------------------------------
   PROCEDURE S_Machine ( VARIABLE fwidth     : OUT INTEGER;
                         VARIABLE precison   : OUT INTEGER;
                         VARIABLE justify    : OUT BIT;
                         CONSTANT format     : IN STRING 
                       ) IS
    VARIABLE state : INT8 := 0;
    VARIABLE fmt   : STRING(1 TO format'LENGTH) := format;
    VARIABLE ch    : CHARACTER;
    VARIABLE index : INTEGER := 1;
    VARIABLE fw    : INTEGER := 0;
    VARIABLE pr    : INTEGER := 0;

   BEGIN
   -- make sure first character is '%' if not error
     ch := fmt(index);
     IF (fmt(index) /= '%') THEN
          ASSERT false
          REPORT " Format Error  --- first character of format " & 
                 " is not '%' as expected." 
          SEVERITY ERROR;
          RETURN;
     END IF;
     justify := '0';  -- default is right justification

     WHILE (state /= 3) LOOP 
        IF (index < format'LENGTH) THEN
           index := index + 1;
           ch := fmt(index);
           CASE state IS
                WHEN 0   =>
                         IF (ch ='-') THEN
                           state := 1;           -- justify
                         ELSIF (ch >= '0'  AND ch <= '9') THEN
                           fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                           state := 2;            -- digits
                         ELSIF (ch = 's') THEN
                           state := 3;            -- end state
                         ELSIF (ch = '.') THEN
                           state := 4;
                         ELSIF (ch = '%') THEN
                           state := 5;
                         ELSE 	
                           state := 6;    -- error       
                         END IF;

                WHEN 1   =>
                         justify := '1';      -- left justfy
                         IF (ch >= '0' AND ch <= '9') THEN
                           fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                           state := 2;
                         ELSIF (ch = '.') THEN
                           state := 4;
			 ELSIF (ch = 's') THEN
			   state := 3;
			   justify := '0';   -- %-s is equivalent to %s
                         ELSE
                            state := 6;    -- error
                         END IF;

                WHEN 2   =>    -- 
                          IF (ch >= '0' AND ch <= '9') THEN
                            fw := fw * 10 + CHARACTER'POS(ch)
                                          - CHARACTER'POS('0');
                            state := 2;
                          ELSIF (ch = 's') THEN
                            state := 3;
                          ELSIF (ch = '.') THEN
                            state := 4;
                          ELSE
                            state := 6;      -- error
                          END IF;

                WHEN 3   =>     -- s  state 
                        -- s format successfully recognized exit now.
                          EXIT;
 
                WHEN 4   =>   -- . state
                          IF (ch >= '0' AND ch <= '9') THEN
                            pr := CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                            state := 7;
                          ELSE
                            state := 6;  -- error
                          END IF; 
                   
                WHEN 5   =>   --  print %  
                          EXIT;

                WHEN 6  =>   -- error state
                         -- print error message
                           ASSERT false
                           REPORT " Format error  --- expected %s format " 
                           SEVERITY ERROR;
                           EXIT;

                WHEN 7  =>
                        -- precision
                          IF (ch >= '0' AND ch <= '9') THEN
                            pr := pr * 10 + CHARACTER'POS(ch)
                                          - CHARACTER'POS('0'); 
                            state := 7; 
                          ELSIF (ch = 's') THEN
                            state := 3;
                          ELSE
                            state := 6;  -- error
                          END IF;
           END CASE;
        ELSE 
	   assert false
	   report " Format Error:   Observed =" & fmt &LF
                & "                 Expected = %s    (detected by S_Machine) "
           severity ERROR;
           exit;
        END IF;    

     END LOOP;

     IF (fw > max_string_len) THEN
           fwidth := max_string_len;
     ELSE
           fwidth := fw;
     END IF;

     precison := pr;
     RETURN;
   END;

--+-----------------------------------------------------------------------------
--|     Function Name  : SOX_Machine 
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Finite State automaton to recognise a binary_vector
--|                      to a string format.
--|                      format will be broken into field width, precision
--|                      and justification (left or right) and notation (binary,
--|                      octal or hex ).
--|
--|     Parameters     : fwidth        -- output, INTEGER, field width
--|                      precision     -- output, INTEGER, precison 
--|                      justify       -- OUTPUT, BIT 
--|                                       '0' right justified,
--|                                        '1' left justified 
--|                      str_type      -- output, character, 
--|                                    -- can be any of the characters  s, O (o),  X (x)
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         :  
--|
--|     NOTE           :
--|                      This procedure is
--|                      called in the function To_String.  
--|
--|     Use            :
--|                    VARIABLE   fmt : STRING(1 TO format'LENGTH) := format;
--|                    VARIABLE fw       : INTEGER;
--|                    VARIABLE precis   : INTEGER;
--|                    VARIABLE justfy   : BIT; 
--|                    VARIABLE sttype   : Character;
--|
--|                    SOX_Machine(fw, precis, justy, sttype,fmt); 
--|
--|-----------------------------------------------------------------------------
   PROCEDURE SOX_Machine ( VARIABLE fwidth     : OUT INTEGER;
                           VARIABLE precison   : OUT INTEGER;
                           VARIABLE justify    : OUT BIT;
                           VARIABLE str_type   : OUT character;
                           CONSTANT format     : IN STRING 
                         ) IS
    VARIABLE state : INT8 := 0;
    VARIABLE fmt   : STRING(1 TO format'LENGTH) := format;
    VARIABLE ch    : CHARACTER;
    VARIABLE index : INTEGER := 1;
    VARIABLE fw    : INTEGER := 0;
    VARIABLE pr    : INTEGER := 0;

   BEGIN
   -- make sure first character is '%' if not error
     ch := fmt(index);
     IF (fmt(index) /= '%') THEN
          ASSERT false
          REPORT " Format Error  --- first character of format " & 
                 " is not '%' as expected." 
          SEVERITY ERROR;
          RETURN;
     END IF;
     justify := '0';  -- default is right justification

     WHILE (state /= 3) LOOP 
        IF (index < format'LENGTH) THEN
           index := index + 1;
           ch := fmt(index);
           CASE state IS
                WHEN 0   =>
                         IF (ch ='-') THEN
                           state := 1;           -- justify
                         ELSIF (ch >= '0'  AND ch <= '9') THEN
                           fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                           state := 2;            -- digits
                         ELSIF ((ch = 's') OR (ch = 'o') OR (ch ='O')
                                   OR (ch = 'x') OR (ch = 'X')) THEN
                           state := 3;            -- end state
                           str_type := ch;
                         ELSIF (ch = '.') THEN
                           state := 4;
                         ELSIF (ch = '%') THEN
                           state := 5;
                         ELSE 	
                           state := 6;    -- error       
                         END IF;

                WHEN 1   =>
                         justify := '1';      -- left justfy
                         IF (ch >= '0' AND ch <= '9') THEN
                           fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                           state := 2;
                         ELSIF (ch = '.') THEN
                           state := 4;
			 ELSIF ((ch = 's') OR (ch = 'o') OR (ch ='O')
                                   OR (ch = 'x') OR (ch = 'X')) THEN
			   state := 3;
			   justify := '0';   -- %- is equivalent to %
                         ELSE
                            state := 6;    -- error
                         END IF;

                WHEN 2   =>    -- 
                          IF (ch >= '0' AND ch <= '9') THEN
                            fw := fw * 10 + CHARACTER'POS(ch)
                                          - CHARACTER'POS('0');
                            state := 2;
                          ELSIF ((ch = 's') OR (ch = 'o') OR (ch ='O')
                                   OR (ch = 'x') OR (ch = 'X')) THEN
                             state := 3;            -- end state
                            str_type := ch;
                          ELSIF (ch = '.') THEN
                            state := 4;
                          ELSE
                            state := 6;      -- error
                          END IF;

                WHEN 3   =>     -- sox  state 
                        -- sox format successfully recognized exit now.
                          EXIT;
 
                WHEN 4   =>   -- . state
                          IF (ch >= '0' AND ch <= '9') THEN
                            pr := CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                            state := 7;
                          ELSE
                            state := 6;  -- error
                          END IF; 
                   
                WHEN 5   =>   --  print %  
                          EXIT;

                WHEN 6  =>   -- error state
                         -- print error message
                           ASSERT false
                           REPORT " Format error  --- expected %s format " 
                           SEVERITY ERROR;
                           EXIT;

                WHEN 7  =>
                        -- precision
                          IF (ch >= '0' AND ch <= '9') THEN
                            pr := pr * 10 + CHARACTER'POS(ch)
                                          - CHARACTER'POS('0'); 
                            state := 7; 
                          ELSIF ((ch = 's') OR (ch = 'o') OR (ch ='O')
                                   OR (ch = 'x') OR (ch = 'X')) THEN
                            state := 3;            -- end state
                            str_type := ch;
                          ELSE
                            state := 6;  -- error
                          END IF;
           END CASE;
        ELSE 
	   assert false
	   report " Format Error:   Observed =" & fmt &LF 
                & "                 Expected = %s    or  %o  r %x    (detected by SOX_Machine) "
           severity ERROR;
           exit;
        END IF;    

     END LOOP;

     IF (fw > max_string_len) THEN
           fwidth := max_string_len;
     ELSE
           fwidth := fw;
     END IF;

     precison := pr;
     RETURN;
   END;

--+-----------------------------------------------------------------------------
--|     Function Name  : F_Machine 
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Finite State automaton to recognise real number format.
--|                      format will be broken into field width, precision
--|                      and justification (left or right).
--|
--|     Parameters     : fwidth        -- output, INTEGER, field width
--|                      precision     -- output, INTEGER, Precision
--|                      justify -- OUTPUT, BIT 
--|                                            '0' right justified,
--|                                            '1' left justified 
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         : INTEGER, length of output string.
--|
--|     NOTE           :
--|                      This procedure is
--|                      called in the funtion To_String  when need to  
--|                      a real number string.
--|
--|     Use            :
--|                    VARIABLE   fmt : STRING(1 TO format'LENGTH) := format;
--|                    VARIABLE fw       : INTEGER;
--|                    VARIABLE precis   : INTEGER;
--|                    VARIABLE justfy    : BIT; 
--|
--|                    F_Machine(fw, precis, justy, fmt); 
--|
--|
--|-----------------------------------------------------------------------------
   PROCEDURE F_Machine ( VARIABLE fwidth     : OUT INTEGER;
                         VARIABLE precison   : OUT INTEGER;
                         VARIABLE justify    : OUT BIT;
                         CONSTANT format     : IN STRING 
                       ) IS
     VARIABLE state :  INT8 := 0;      --  starting state
     VARIABLE fmt   : STRING(1 TO format'LENGTH) := format;
     VARIABLE ch    : CHARACTER;
     VARIABLE index : INTEGER := 1;
     VARIABLE fw    : INTEGER := 0;
     VARIABLE pr    : INTEGER := 0;

   BEGIN

   -- make sure first character is '%' if not error
     ch := fmt(index);
     IF (fmt(index) /= '%') THEN
           ASSERT false
           REPORT " Format Error  --- first character of format " & 
                  " is not '%' as expected." 
           SEVERITY ERROR;
           return;
     END IF;
     justify := '0';  -- default is right justification
 
     WHILE (state /= 3) LOOP 
        IF (index < format'LENGTH) THEN
           index := index + 1;
           ch := fmt(index);
           CASE state IS
                  WHEN 0   =>
                          IF (ch ='-') THEN
                            state := 1;           -- justify
                          ELSIF (ch >= '0'  AND ch <= '9') THEN
                            fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                            state := 2;            -- digits
                          ELSIF (ch = 'f') THEN
                            state := 3;            -- end state
                          ELSIF (ch = '.') THEN
                            state := 4;
                          ELSIF (ch = '%') THEN
                            state := 5;
                          ELSE 	
                            state := 6;    -- error       
                          END IF;

                  WHEN 1   =>
                          justify := '1';      -- left justfy
                          IF (ch >= '0' AND ch <= '9') THEN
                            fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                            state := 2;
                          ELSIF (ch = '.') THEN
                            state := 4;
 			  ELSIF (ch = 'f') THEN
			    state := 3;
			    justify := '0';   -- %-f is equivalent to %f
                          ELSE
                            state := 6;    -- error
                          END IF;

                  WHEN 2   =>    -- 
                          IF (ch >= '0' AND ch <= '9') THEN
                             fw := fw * 10 + CHARACTER'POS(ch)
                                           - CHARACTER'POS('0');
                             state := 2;
                          ELSIF (ch = 'f') THEN
                             state := 3;
                          ELSIF (ch = '.') THEN
                             state := 4;
                          ELSE
                             state := 6;
                          END IF;

                  WHEN 3  =>     -- f  state
                           -- fromat successfully recognized, exit now.
                           EXIT;
 
                  WHEN 4   =>   -- . state
                           IF (ch >= '0' AND ch <= '9') THEN
                              pr :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                              state := 7;
                           ELSE
                              state := 6;  -- error
                           END IF; 
                   
                  WHEN 5   =>   --  print %  
                           EXIT;

                  WHEN 6  =>   -- error state
                                 -- print error message
                           ASSERT false
                           REPORT " Format Error --- expected %f format. "
                           SEVERITY ERROR;
                           EXIT;

                  WHEN 7  =>
                                -- precision
                           IF (ch >= '0' AND ch <= '9') THEN
                              pr := pr * 10 + CHARACTER'POS(ch)
                                            - CHARACTER'POS('0'); -- to_digit
                              state := 7;
                            ELSIF (ch = 'f') THEN
                              state := 3;
                            ELSE
                              state := 6;  -- error
                            END IF;
           END CASE;
        ELSE 
	   assert false
	   report " Format Error:   Observed =" & fmt &LF
                & "                 Expected = %f      (detected by F_Machine) "
           severity ERROR;
           exit;
        END IF;    

     END LOOP;

     IF (fw > max_string_len) THEN
	fwidth := max_string_len;
     ELSE
	fwidth := fw;
     END IF;

     IF (pr=0) THEN
	precison := 6;            -- use default precision
     ELSE
	precison := pr;
     END IF;
     RETURN;
   END F_Machine;
--+-----------------------------------------------------------------------------
--|     Function Name  : D_Machine 
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Finite State automaton to recognise integer format.
--|                      format will be broken into field width, precision
--|                      and justification (left or right).
--|
--|     Parameters     : fwidth        -- output, INTEGER, field width
--|                      precision     -- output, INTEGER, Precision
--|                      justify -- OUTPUT, BIT 
--|                                            '0' right justified,
--|                                            '1' left justified 
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         : INTEGER, length of output string.
--|
--|     NOTE           :
--|                      This procedure is
--|                      called in the funtion To_String  when need to  
--|                      a real number string.
--|
--|     Use            :
--|                    VARIABLE   fmt : STRING(1 TO format'LENGTH) := format;
--|                    VARIABLE fw       : INTEGER;
--|                    VARIABLE precis   : INTEGER;
--|                    VARIABLE justfy    : BIT; 
--|
--|                    D_Machine(fw, precis, justy, fmt); 
--|
--|-----------------------------------------------------------------------------
   PROCEDURE D_Machine ( VARIABLE fwidth     : OUT INTEGER;
                         VARIABLE precison   : OUT INTEGER;
                         VARIABLE justify    : OUT BIT;
                         CONSTANT format     : IN STRING 
                       ) IS
     VARIABLE state :  INT8 := 0;      --  starting state
     VARIABLE fmt   : STRING(1 TO format'LENGTH) := format;
     VARIABLE ch    : CHARACTER;
     VARIABLE index : INTEGER := 1;
     VARIABLE fw    : INTEGER := 0;
     VARIABLE pr    : INTEGER := 0;

   BEGIN
   -- make sure first character is '%' if not error
     ch := fmt(index);
     IF (fmt(index) /= '%') THEN
           ASSERT false
           REPORT " Format Error  --- first character of format " & 
                  " is not '%' as expected." 
           SEVERITY ERROR;
           return;
     END IF;
     justify := '0';  -- default is right justification
     WHILE (state /= 3) LOOP 
        IF (index < format'LENGTH) THEN
           index := index + 1;
           ch := fmt(index);
           CASE state IS
              WHEN 0  => IF (ch ='-') THEN
                            state := 1;           -- justify
                          ELSIF (ch >= '0'  AND ch <= '9') THEN   -- to_digit
                            fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); 
                            state := 2;            -- digits state
                          ELSIF (ch = 'd') THEN
                            state := 3;            -- end state
                          ELSIF (ch = '.') THEN
                            state := 4;
                          ELSIF (ch = '%') THEN
                            state := 5;
                          ELSE 	
                            state := 6;    -- error       
                          END IF;

              WHEN 1   => justify := '1';      -- left justfy
                          IF (ch >= '0' AND ch <= '9') THEN      -- to_digit
                            fw := CHARACTER'POS(ch) - CHARACTER'POS('0');
                            state := 2;
                          ELSIF (ch = '.') THEN
                            state := 4;
			  ELSIF (ch = 'd') THEN
			    state := 3;
			    justify := '0';   -- %-d is equivalent to %d
                          ELSE
                            state := 6;    -- error
                          END IF;

              WHEN 2   =>    -- digits state
                          IF (ch >= '0' AND ch <= '9') THEN
                             fw := fw * 10 + CHARACTER'POS(ch)
                                           - CHARACTER'POS('0');
                             state := 2;
                          ELSIF (ch = 'd') THEN
                             state := 3;
                          ELSIF (ch = '.') THEN
                             state := 4;
                          ELSE
                             state := 6;
                          END IF;

              WHEN 3  =>   -- d  state
                           -- fromat successfully recognized, exit now.
                           EXIT;
 
              WHEN 4   =>   -- . state
                           IF (ch >= '0' AND ch <= '9') THEN
                              pr :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); -- to_digit
                              state := 7;
                           ELSE
                              state := 6;  -- error
                           END IF; 
                   
              WHEN 5   => --  print %  
                           EXIT;

              WHEN 6  =>   -- error state
                                 -- print error message
                           ASSERT false
                           REPORT " Format Error --- expected %f format. "
                           SEVERITY ERROR;
                           EXIT;

              WHEN 7  =>  -- precision
                          IF (ch >= '0' AND ch <= '9') THEN
                              pr := pr * 10 + CHARACTER'POS(ch)
                                            - CHARACTER'POS('0'); -- to_digit
                              state := 7;
                          ELSIF (ch = 'd') THEN
                              state := 3;
                          ELSE
                              state := 6;  -- error
                          END IF;
           END CASE;
        ELSE 
	   assert false
	   report " Format Error:   Observed =" & fmt &LF 
                & "                 Expected = %d      (detected by D_Machine) "
           severity ERROR;
           exit;
        END IF;    
     END LOOP;
   -- decide field width (fwidth)
     IF (fw > max_string_len) THEN
	fwidth := max_string_len;
     ELSE
	fwidth := fw;
     END IF;
     precison := pr;   -- set precision
     RETURN;
   END D_Machine;
   ----------------------------------------------------------
    -- Function Name : i_TRUNC 
    -- hidden
    -- Parameters :
    --       in  :: Real_val : real;
    -- Returns    : Integer portions of a real number 
    -- Purpose    : TO obtain the integer part of a general real
    -- Notes      :
    ----------------------------------------------------------
    FUNCTION i_TRUNC ( CONSTANT real_val : IN real
                    ) RETURN integer IS
        VARIABLE rval : real;
        VARIABLE i : integer;
    begin
     -- find the integer value  rounded to  integer number less than
     -- the real value. if the real number is 0.0 then return 0
        if (real_val = 0.0) then
             i := 0;
        else   
             rval := real_val - 0.5;  
             i :=  INTEGER(rval);
        end if;             
        RETURN i;
    END i_TRUNC;

    -------------------------------------------------------
    -- Function Name : i_FRAC
    -- hidden
    -- Parameters :
    --       in  :: Real_val : real;
    -- Returns    : Fractional portion of the real and no of fractional
    --              digits present
    -- Purpose    : to obtain the fractional part of a general real
    -- Notes      :
    ----------------------------------------------------------
    PROCEDURE i_FRAC ( CONSTANT real_val : IN real;
                       VARIABLE f_val     : OUT INTEGER; 
	               VARIABLE f_digits : OUT INTEGER
                     )  IS
        VARIABLE rval : real;
        VARIABLE ival : integer;
        VARIABLE i : integer := 0;
    begin
        ival := i_TRUNC(real_val);
        rval := real_val - REAL(ival);
        i := INTEGER(rval * 1000000.0);
	IF (i>=0 and i<=9) THEN
		f_digits := 1;
	ELSIF (i>=10 and i<=99) THEN
		f_digits := 2;

	ELSIF (i>=10 and i<=99) THEN
		f_digits := 2;

	ELSIF (i>=100 and i<=999) THEN
		f_digits := 3;

	ELSIF (i>=1000 and i<=9999) THEN
		f_digits := 4;

	ELSIF (i>=10000 and i<=99999) THEN
		f_digits := 5;

	ELSIF (i>=100000 and i<=999999) THEN
		f_digits := 6;
        ELSE 
	       f_digits := 0;
        END IF;
	
        f_val := i;
        return;

    end i_FRAC;
--|-----------------------------------------------------------------------------

--+----------------------------------------------------------------------------- 
--|     Function Name  : Is_White
--| hidden.
--|     Overloading    : None 
--|  
--|     Purpose        : Test whether a character is a blank, a tab or 
--|                      a newline character.
--|
--|     Parameters     : 
--|                      c     - input   Character.
--| 
--|     Result         :Booelan -- True if the argument c is a blank or a tab(HT), 
--|                     or a line feed (LF), or carriage return (CR). false otherwise.   
--| 
--| 
--|     See Also       : Is_Space
--|----------------------------------------------------------------------------- 
     FUNCTION  Is_White  ( CONSTANT c    : IN CHARACTER
                         ) RETURN BOOLEAN IS
         VARIABLE result : BOOLEAN;
     BEGIN
        IF ( (c = ' ') OR (c = HT)  OR (c = CR) OR (c=LF) ) THEN
             result := TRUE;
        ELSE
             result := FALSE;
        END IF;
        RETURN result;

     END; 

--+-----------------------------------------------------------------------------
--|     Function Name  : Find_NonBlank
--| hidden 
--|     Overloading    : for extra parameter - index (see below)
--|
--|     Purpose        : Find first non_blank character in a string.
--|
--|     Parameters     :
--|                      str_in    - input ,  
--|
--|     Result         : Natural, index of non_blank character. If string
--|                      has all the white character then str_in'LENGTH is
--|                      returned;
--|
--|     NOTE           :
--|
--|     Use            :
--|                      VARIABLE s_flag : String(1 TO 10) := "      TRUE"; 
--|                      VARIABLE idx: Natural 
--|
--|                       idx := Find_NonBlank (s_flag);
--|
--|-----------------------------------------------------------------------------
   FUNCTION Find_NonBlank  ( CONSTANT str_in   : IN STRING
                           ) RETURN NATURAL IS
      VARIABLE str_copy :  STRING (1 TO str_in'LENGTH) := str_in;
      VARIABLE index    :  Natural := 1;
      VARIABLE ch       :  character;
       
    BEGIN
          loop
            EXIT WHEN ( (index > str_in'LENGTH) or (str_copy(index) = NUL) );
            if Is_White(str_copy(index)) then
                index := index + 1;
            else
                EXIT;
            end if;
          end loop;
          return index;
--      
-- old code
-- 
--        ch := str_copy(index);
--        while ( ( index < str_in'LENGTH) AND (Is_White(ch) ) ) LOOP
--        	index := index + 1;
--              ch := str_copy(index);
--        end LOOP;
--        return index;
    END;

    
--+-----------------------------------------------------------------------------
--|     Function Name  : Find_NonBlank
--| hidden 
--|     Overloading    : for no index parameter - see abov
--|
--|     Purpose        : Find first non_blank character in a string, starting
--|                      from position indicated by index.
--|
--|     Parameters     : str_in    - input string ,   
--|                      index     - input NATURAL
--|
--|     Result         : Natural, index of non_blank character. If string
--|                      has all the white character then str_in'LENGTH is
--|                      returned;
--|
--|     NOTE           : assumes string has left index of 1
--|
--|     Use            :
--|                      VARIABLE s_flag : String(1 TO 10) := "      TRUE"; 
--|                      VARIABLE idx: Natural 
--|
--|                       idx := Find_NonBlank (s_flag);
--|
--|-----------------------------------------------------------------------------
   FUNCTION Find_NonBlank  ( CONSTANT str_in   : IN STRING;
                             CONSTANT index    : IN NATURAL
                           ) RETURN NATURAL IS
                           
      VARIABLE ch       :  character;
      VARIABLE indx     :  integer := index;
       
    BEGIN
          loop
            EXIT WHEN ( (indx > str_in'LENGTH) or (str_in(indx) = NUL) );
            if Is_White(str_in(indx)) then
                indx := indx + 1;
            else
                EXIT;
            end if;
          end loop;
          return indx;
    END;

    
--+-----------------------------------------------------------------------------
--|     Function Name  : get_token
--| hidden
--|     Overloading    : None
--|
--|     Purpose        :  To get  a token from  a format string.
--|                        used in fprint procedure.
--|                   
--|
--|     Parameters     :
--|                      format   -- input, STRING,
--|                      index    -- input_output, INTEGER, 
--|                                  at input it represents the beginning 
--|                                  position of the word in the format 
--|                                  string. When procedure terminates
--|                                  index represent the end of word. 
--|                      token    -- output, STRING, holds the result. 
--|
--|     NOTE           :
--|
--| ---------------------------------------------------------------------------
    PROCEDURE get_token   ( CONSTANT format : IN STRING;
                             VARIABLE index   : INOUT INTEGER;
                             VARIABLE token  : OUT STRING
                           ) IS
          VARIABLE fmt     : STRING(1 TO format'LENGTH) := format;
          VARIABLE indx     : INTEGER := index;
          VARIABLE res_str : STRING(1 TO max_token_len); 
                                               -- % - fw.precison s
          VARIABLE i       : INTEGER := 1;
    BEGIN
      -- make sure it is a format string
         ASSERT (fmt(indx) = '%')
         REPORT " get_token  --- not a format string "
         SEVERITY ERROR;
         res_str(i) := fmt(indx);
 
         fmt_loop: LOOP
                   i := i + 1;
                   indx := indx + 1;
                   res_str(i) := fmt(indx);
                   EXIT fmt_loop WHEN  ( fmt(indx) = 's');
         END LOOP;

         index := indx;
         token(1 TO i) := res_str(1 to i);   -- fixing bug
         RETURN;                
    END; 

--+-----------------------------------------------------------------------------
--|     Function Name  : print_str_buf
--| 
--|     Overloading    : None
--|
--|     Purpose        : Prints a string according to format specification to a
--|                      buffer string. 
--|
--|     Parameters     :
--|                         buf      - input_output, string,
--|                         index    - input_output, integer
--|                         format   - input STRING,
--|                         arg      - input STRING,
--|
--|     Result         : formated LINE. 
--|
--|     NOTE           : This will be called in the fprint to print each
--|                      individual argument. 
--|
--|
--|-----------------------------------------------------------------------------
   PROCEDURE print_str_buf (VARIABLE buf     : INOUT string;
                            VARIABLE index   : INOUT integer;
                            CONSTANT format  : IN STRING;
                            CONSTANT arg     : IN STRING
                           ) IS
           VARIABLE fmt         : STRING(1 TO format'LENGTH) := format;
           VARIABLE arg_copy    : STRING(1 TO arg'LENGTH) := arg;
           VARIABLE result      : STRING(1 TO max_string_len);
           VARIABLE non_nul_str : STRING(1 TO arg'LENGTH);
           VARIABLE len         : INTEGER := 0;
           VARIABLE fw       : INTEGER;
           VARIABLE precis   : INTEGER;
           VARIABLE justfy    : BIT;

     BEGIN
     -- call procedure S_Machine to split the format string
        S_Machine(fw, precis, justfy, fmt);

        IF ((precis = 0) OR (precis > arg'LENGTH)) THEN
		precis := arg'LENGTH;
        END IF;
     
     -- check for the null argument
        IF ((arg'LENGTH = 0)  AND (fw = 0)) THEN
            return;

        ELSIF ((arg'LENGTH = 0) AND (fw /= 0)) THEN
            result(1 TO fw) := (OTHERS => ' ');
                                         
        ELSIF (arg'LENGTH /= 0) THEN       -- argument is not null 

        -- copy arg until NUL character encountered or precis  to the non_nul_str;
    
           FOR i IN 1 TO precis LOOP
            	EXIT when (arg_copy(i) = NUL);
                len := len + 1;
                non_nul_str(len) := arg_copy(i);
           END LOOP;

           IF (len > fw) THEN
            	fw := len;
           END IF;

           IF (justfy = '1') THEN
            	result(1 TO len) := non_nul_str(1 to len);  --modifying
           	FOR i IN len + 1 TO fw LOOP
                	result(i) := ' ';
                END LOOP;
           ELSE
            	FOR i IN 1 TO fw - len LOOP
            		result(i) := ' ';
           	END LOOP;
          	result(fw - len + 1 TO fw) := non_nul_str(1 to len); -- modifying
           END IF;
        END IF;

        for i IN 1 TO fw LOOP
            EXIT when (index > buf'LENGTH);
            buf(index) := result(i);
	    index := index + 1;
        END LOOP;

	IF (index <= buf'LENGTH) THEN
	     buf(index) := ' ';           -- leave one blank between two strings.
	     index := index - 1;
        END IF;	
        RETURN;

     -- That's all  
     END;  


--+-----------------------------------------------------------------------------
--|     Function Name  : print_str
--| 
--|     Overloading    : None
--|
--|     Purpose        : Prints a string according to format specification. 
--|
--|     Parameters     :
--|                         ll       - input_output, LINE,
--|                         format   - input STRING,
--|                         arg      - input STRING,
--|
--|     Result         : formated LINE. 
--|
--|     NOTE           : This will be called in the fprint to print each
--|                      individual argument. 
--|
--|
--|-----------------------------------------------------------------------------
   PROCEDURE print_str (VARIABLE ll      : INOUT LINE;
                        CONSTANT format  : IN STRING;
                        CONSTANT arg     : IN STRING
                        ) IS
           VARIABLE fmt         : STRING(1 TO format'LENGTH) := format;
           VARIABLE arg_copy    : STRING(1 TO arg'LENGTH) := arg;
           VARIABLE result      : STRING(1 TO max_string_len);
           VARIABLE non_nul_str : STRING(1 TO arg'LENGTH);
           VARIABLE len         : INTEGER := 0;
           VARIABLE fw       : INTEGER;
           VARIABLE precis   : INTEGER;
           VARIABLE justfy    : BIT;

     BEGIN
     -- call procedure S_Machine to split the format string
        S_Machine(fw, precis, justfy, fmt);
        
        IF ((precis = 0) OR (precis > arg'LENGTH)) THEN
		precis := arg'LENGTH;
        END IF;
     
     -- check for the null argument
        IF ((arg'LENGTH = 0)  AND (fw = 0)) THEN
            return;

        ELSIF ((arg'LENGTH = 0) AND (fw /= 0)) THEN
            result(1 TO fw) := (OTHERS => ' ');
                                         
        ELSIF (arg'LENGTH /= 0) THEN       -- argument is not null 
        -- copy arg until NUL character to the non_nul_str;
           FOR i IN 1 TO precis LOOP
            	EXIT when (arg_copy(i) = NUL);
                len := len + 1;
                non_nul_str(len) := arg_copy(i);
           END LOOP;
    
           IF ( len > fw) THEN
            	fw := len;
           END IF;

           IF (justfy = '1') THEN
            	result(1 TO len) := non_nul_str(1 to len);  -- modifying
           	FOR i IN len + 1 TO fw LOOP
                	result(i) := ' ';
                END LOOP;
           ELSE
            	FOR i IN 1 TO fw - len LOOP
            		result(i) := ' ';
           	END LOOP;
          	result(fw - len + 1 TO fw) := non_nul_str(1 to len); -- modifying
           END IF;
        END IF;
        WRITE(ll, result(1 TO fw));
        RETURN;

     -- That's all  
     END;  


--+-----------------------------------------------------------------------------
--|     Function Name  : print_str
--| 
--|     Overloading    : None
--|
--|     Purpose        : writes a string according to format specification to an
--|                      ascii_text file 
--|
--|     Parameters     :
--|                         asc_file  - input, ASCII_TEXT,
--|                         format   - input STRING,
--|                         arg      - input STRING,
--|
--|     Result         : formated LINE. 
--|
--|     NOTE           : This will be called in the fprint to print each
--|                      individual argument. 
--|
--|
--|-----------------------------------------------------------------------------
   PROCEDURE print_str (VARIABLE asc_file  : OUT ASCII_TEXT;
                        CONSTANT format    : IN STRING;
                        CONSTANT arg       : IN STRING
                        ) IS
           VARIABLE fmt         : STRING(1 TO format'LENGTH) := format;
           VARIABLE arg_copy    : STRING(1 TO arg'LENGTH) := arg;
           VARIABLE result      : STRING(1 TO max_string_len);
           VARIABLE non_nul_str : STRING(1 TO arg'LENGTH);
           VARIABLE len         : INTEGER := 0;
           VARIABLE fw          : INTEGER;
           VARIABLE precis      : INTEGER;
           VARIABLE justfy      : BIT;

     BEGIN
     -- call procedure S_Machine to split the format string
        S_Machine(fw, precis, justfy, fmt);
     
        IF ((precis = 0) OR (precis > arg'LENGTH)) THEN
		precis := arg'LENGTH;
        END IF;

     -- check for the null argument
        IF ((arg'LENGTH = 0)  AND (fw = 0)) THEN
            return;

        ELSIF ((arg'LENGTH = 0) AND (fw /= 0)) THEN
            result(1 TO fw) := (OTHERS => ' ');
                                         
        ELSIF (arg'LENGTH /= 0) THEN       -- argument is not null 
        -- copy arg until NUL  character encountered or precison  to the non_nul_str;
           FOR i IN 1 TO precis LOOP
            	EXIT when (arg_copy(i) = NUL);
                len := len + 1;
                non_nul_str(len) := arg_copy(i);
           END LOOP;
    
           IF (len > fw) THEN
            	fw := len;
           END IF;

           IF (justfy = '1') THEN
            	result(1 TO len) := non_nul_str(1 to len); -- modifying
           	FOR i IN len + 1 TO fw LOOP
                	result(i) := ' ';
                END LOOP;
           ELSE
            	FOR i IN 1 TO fw - len LOOP
            		result(i) := ' ';
           	END LOOP;
          	result(fw - len + 1 TO fw) := non_nul_str(1 to len); -- modifying
           END IF;
        END IF;

        FOR i IN 1 TO fw LOOP
          WRITE(asc_file, result(i));
        END LOOP;

        RETURN;

     -- That's all  
     END;  


      
-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
--              V I S I B L E   ROUTINES  START HERE
--------------------------------------------------------------------------------
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
--|                      VARIABLE OK : BOOLEAN 
--|
--|                       OK := From_String (s_flag);
--|
--|-----------------------------------------------------------------------------
   FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN boolean IS
      VARIABLE str_copy : STRING (1 TO str'LENGTH) := To_Upper(str);
      VARIABLE index    : Natural;
      VARIABLE ch       : character;
      VARIABLE result   : boolean ;
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_String  -- input string has zero length.  Boolean case"
                severity ERROR;
                RETURN FALSE;
        END IF;
        -- find the position of the first non_white character
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_String  --- input string is empty  ";
                RETURN FALSE; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_String  -- first non_white character is a NUL ";
                RETURN FALSE;
        END IF;
        ch := str_copy(index);
        CASE ch IS
            WHEN 'F'  =>   IF ((str'length - index) < 4 ) THEN
                              result := FALSE;
                              assert false
                              report " From_String  --- input string has too few characters."
                              severity ERROR;
                           ELSIF ( ((str'length - index) = 4 ) AND 
                              (str_copy(index TO index+4) = "FALSE") ) THEN
                              result := FALSE;                          
                           ELSIF ( (str_copy(index TO index + 4) = "FALSE") 
                                     AND( (str_copy(index + 5) = NUL) OR 
                                           Is_White( str_copy(index + 5) ) ) )  THEN
                              result := FALSE;
                           ELSE
                              result := FALSE;
                              assert false
                              report " From_String  --- mismatch in boolean  "
                              severity ERROR;
                           END IF;   

            WHEN 'T'  =>   IF ((str'length - index) < 3 ) THEN
                              result := FALSE;
	                      assert false
        	              report " From_String  --- input string has too few characters "
                	      severity ERROR;
	                   ELSIF ( (( str'length - index ) = 3) AND
                              (str_copy(index TO index + 3 ) = "TRUE")) THEN
	                      result := TRUE;
        	           ELSIF ((str_copy(index TO index + 3) = "TRUE")
                                     AND( (str_copy(index + 4) = NUL) OR 
                                           Is_White( str_copy(index + 4) ) ) )  THEN
                	      result := TRUE;
	                   ELSE
        	              result := FALSE;
                	      assert false
	                      report "From_String  --- mismatch in boolean  "
        	              severity ERROR;                          
                	   END IF;   

           WHEN OTHERS =>  result := FALSE;
                           assert false
      		           report " From_String  --- cannot find a boolean   "
                           severity ERROR;                          
                      
	END CASE;
        RETURN result;

    END;

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
                           ) RETURN bit IS
      VARIABLE str_copy : STRING (1 TO str'LENGTH) := str;
      VARIABLE index    : Natural;
      VARIABLE ch       : character;
      VARIABLE result   : bit ;

    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_String  --- input string has zero length"
                severity ERROR;
                RETURN '0';
        END IF;
        -- find the position of the first non_white character
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_String  --- input string is empty  ";
                RETURN '0'; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_String  -- first non_white character is a NUL ";
                RETURN '0';
        END IF;

        ch := str_copy(index);
        CASE ch IS
           WHEN '1'    => result := '1';
           WHEN '0'    => result := '0';
           WHEN OTHERS => assert false
                           REPORT "From_String(str(" & To_String(index) & ") => " 
                                & To_String(ch) & ") is an invalid character "
                           severity ERROR;
                          result := '0';      
        END CASE;
        RETURN RESULT;

    END;

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
                           ) RETURN severity_level IS

      VARIABLE str_copy : STRING (1 TO str'LENGTH):= To_Upper(str);
      VARIABLE index    : Natural;
      VARIABLE ch       : character;
      VARIABLE result   : SEVERITY_LEVEL ;
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_String  --- input string has zero length "
                severity ERROR;
                RETURN NOTE;
        END IF;
        -- find the position of the first non_white character
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_String  --- input string is empty  ";
                RETURN NOTE; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_String  -- first non_white character is a NUL ";
                RETURN NOTE;
        END IF;

        ch := str_copy(index);
        CASE ch IS
            WHEN 'N'    => result := NOTE;
	                   IF ((str'length - index) < 3 ) THEN
        	              assert false
                	      report " From_String  --- input string has too few characters."
	                      severity ERROR;

        	           ELSIF ( (( str'length - index ) = 3) AND
                              (str_copy(index TO index + 3 ) = "NOTE")) THEN
                	      result := NOTE;
	                   ELSIF ((str_copy(index TO index + 3) = "NOTE")
                                     AND( (str_copy(index + 4) = NUL) OR 
                                          Is_White( str_copy(index + 4) ) ) )  THEN
        	              result := NOTE;
                	   ELSE
	                       assert false
        	               report " From_String  --- mismatch  in  string "
                	       severity ERROR;
	                   END IF;   

           WHEN 'W'     => result := NOTE;
	                   IF ((str'length - index) < 6 ) THEN
        	              assert false
                	      report " From_String  --- input string has too few characters."
	                      severity ERROR;

	                   ELSIF ( (( str'length - index ) = 6) AND
                              (str_copy(index TO index + 6) = "WARNING")) THEN
        	              result := WARNING;
                	   ELSIF ((str_copy(index TO index + 6) = "WARNING") 
                                     AND( (str_copy(index + 7) = NUL) OR 
                                           Is_White( str_copy(index + 7) ) ) )  THEN
	                      result := WARNING;
        	           ELSE
                	       assert false
	 	               report " From_String  --- mismatch  in  string "
                	       severity ERROR;
	                   END IF;   

           WHEN 'E'     => result := NOTE;
	                   IF ((str'length - index) < 4 ) THEN
        	              assert false
                	      report " From_String  --- input string has too few characters."
	                      severity ERROR;

        	           ELSIF ( (( str'length - index ) = 4) AND
                                 (str_copy(index TO index + 4) = "ERROR")) THEN
                	      result := ERROR;
	                   ELSIF ((str_copy(index TO index + 4) = "ERROR")
                                     AND( (str_copy(index + 5) = NUL) OR 
                                          Is_White( str_copy(index + 5) ) ) )  THEN
        	              result := ERROR;
                	   ELSE
	                      assert false
        	              report " From_String  --- mismatch  in  string "
                	      severity ERROR;
	                   END IF;   
        
	   WHEN 'F'     => result := NOTE;
	                   IF ((str'length - index) < 6 ) THEN
        	              assert false
                	      report " From_String  --- input string has too few characters."
	                      severity ERROR;

        	           ELSIF ( (( str'length - index ) = 6) AND
                                  (str_copy(index TO index + 6) = "FAILURE")) THEN
                	      result := FAILURE;
	                   ELSIF ((str_copy(index TO index + 6) = "FAILURE")
                                     AND( (str_copy(index + 7) = NUL) OR 
                                           Is_White( str_copy(index + 7) ) ) )  THEN
        	              result := FAILURE;
                	   ELSE
		              assert false
                	      report " From_String  --- mismatch  in  string "
	                      severity ERROR;
           	           END IF;   

           WHEN OTHERS =>  result := NOTE;
	                      assert false
        	              report " From_String  --- cannot find a severity-level   "
                	      severity ERROR;                          
	END CASE;
        return result;

    END;

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
                           ) RETURN character IS
      VARIABLE str_copy : STRING (1 TO str'LENGTH) := str;
      VARIABLE index    : Natural;
      VARIABLE ch       : character;
      VARIABLE result   : character;
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_String  --- input string has a null range "
                severity ERROR;
                RETURN NUL;

        END IF;
        -- left most character of the string is returned
        result  := str_copy(1);
        IF (result = NUL) THEN
		assert false
		report " From_String  --- First character is a NUL  "
                severity ERROR;
        END IF;
        return result;

    END;

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
                           ) RETURN INTEGER IS
      VARIABLE str_copy : STRING (1 TO str'LENGTH) := str;
      VARIABLE index    : Natural;
      VARIABLE ch       : character;
      VARIABLE result   : INTEGER := 0;
      VARIABLE neg_sign : boolean := false;
      VARIABLE invalid  : boolean := false;
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_String  --- input string has zero length "
                severity ERROR;
                RETURN INTEGER'LEFT;
        END IF;
        -- find the position of the first non_white character
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_String  --- input string is empty  ";
                RETURN INTEGER'LEFT; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_String  -- first non_white character is a NUL ";
                RETURN INTEGER'LEFT;
        END IF;
        ch := str_copy(index);
       -- check for - sign or + sign
        IF (ch = '-') Then
            neg_sign := NOT neg_sign;
            index := index + 1;
            ch := str_copy(index);      -- get_char
        elsif (ch = '+') then
            index := index + 1;
            ch := str_copy(index);      -- get_char
        END IF;
        
      -- Strip off leading zero's
        While ( (ch = '0')  AND (index < str'LENGTH)) LOOP
              index := index + 1;
              ch := str_copy(index);     -- get_char
        END LOOP;
        For i in index TO str'LENGTH LOOP
               ch := str_copy(i);
               if (Is_Digit(ch)) then
                    result := result * 10 + ( CHARACTER'POS(ch)       
                                              - CHARACTER'POS('0') );  -- to digit
               elsif ((Is_White(ch))  OR (ch = NUL)) THEN
                    exit; 
               else 
                    invalid := TRUE;
                    result := INTEGER'LEFT;
                    ASSERT FALSE
                    REPORT "From_String(str(" & To_String(i) & ") => " 
                                & To_String(ch) & ") is an invalid character "
                    SEVERITY ERROR;
                    exit;
               end if;
        end loop;
        if ( neg_sign  AND (not invalid) )THEN
            result := - result;
        END IF;
        return result;

    END;

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
                           ) RETURN REAL IS
      VARIABLE str_copy   : STRING (1 TO str'LENGTH) := str;
      VARIABLE index      : Natural;
      VARIABLE digit_val  : Integer;
      VARIABLE power      : Integer;
      VARIABLE integ_part : Integer := 0;    
      VARIABLE fract_part : Integer := 0;    
      VARIABLE r          : real := 0.0;
      VARIABLE ch         : character;
      VARIABLE neg_sign   : boolean := false;
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_String  --- input string has zero length "
                severity ERROR;
                RETURN REAL'LEFT;

        END IF;
        -- find the position of the first non_white character
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_String  --- input string is empty  ";
                RETURN REAL'LEFT; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_String  -- first non_white character is a NUL ";
                RETURN REAL'LEFT;
        END IF;
        ch  := str_copy(index);
       -- check for - sign or + sign
        IF (ch = '-') Then
            neg_sign := NOT neg_sign;
            index := index + 1;
            ch := str_copy(index);      -- get_char
        elsif (ch = '+') then
            index := index + 1;
            ch := str_copy(index);      -- get_char
        END IF;

      -- Strip off leading zero's
        While ( (ch = '0')  AND (index < str'LENGTH)) LOOP
              index := index + 1;
              ch := str_copy(index);     -- get_char
        END LOOP;

      -- convert the integeral part by going through the loop
      -- until '.' is encountered 

        WHILE  ((ch /= '.') AND (index < str'LENGTH)) LOOP
                
               if (Is_digit(ch)) THEN
                    integ_part := integ_part * 10 + ( CHARACTER'POS(ch)       
                                              - CHARACTER'POS('0') );  -- to digit
               else 
       	            ASSERT FALSE
                    REPORT "From_String(str(" & To_String(index) & ") => " 
                                & To_String(ch) & ") is an invalid character "
                    SEVERITY ERROR;
                    return real'LEFT;
               end if;
               index := index + 1;
               ch := str_copy(index); 
        END LOOP;
      -- convert the fractional part to real value
      --       
        if ( ch = '.') THEN
            index := index + 1;
        END IF;
        power := 0;
        For i IN index TO str'LENGTH LOOP
               ch := str_copy(i);
               if (Is_digit(ch)) THEN
	            power := power + 1; 
                    fract_part := fract_part * 10 + ( CHARACTER'POS(ch)       
                                              - CHARACTER'POS('0') );  -- to digit
               elsif ((Is_White(ch)) OR (ch = NUL)) THEN
              	    exit;
               else 
       	            ASSERT FALSE
                    REPORT "From_String(str(" & To_String(i) & ") => " 
                                & To_String(ch) & ") is an invalid character "
         	                SEVERITY ERROR;
                    return real'LEFT;
               end if;
        end loop;
        
        r := real(integ_part) + real(fract_part) / 10.0 ** power;
        if neg_sign THEN
            r := - r;
        END IF;
	return r;      
    END;
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
                           ) RETURN std_ulogic IS
      VARIABLE str_copy : STRING (1 TO str'LENGTH) := To_Upper(str);
      VARIABLE index    : Natural;
      VARIABLE ch       : character;
      VARIABLE result   : std_ulogic;
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_String  --- input string has zero length "
                severity ERROR;
                RETURN 'U';
    	END IF;
        -- find the position of the first non-white character.
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_String  --- input string is empty  ";
                RETURN 'U'; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_String  -- first non_white character is a NUL ";
                RETURN 'U';
        END IF;
    	ch := str_copy(index);
    	CASE ch IS
              WHEN 'U'      => 	result := 'U';
       	      WHEN 'X'      =>  result := 'X';
              WHEN '0'      =>  result := '0';
       	      WHEN '1'      =>  result := '1';
              WHEN 'Z'      =>  result := 'Z';
              WHEN 'W'      =>  result := 'W';
              WHEN 'L'      =>  result := 'L';
              WHEN 'H'      =>  result := 'H';
              WHEN '-'      =>  result := '-';
              WHEN OTHERS   =>
                                result := 'U'; 
                   	        ASSERT FALSE
                                REPORT "From_String(str(" & To_String(index) & ") => " 
                                & To_String(ch) & ") is an invalid character "
         	                SEVERITY ERROR;
        END CASE;
        return result;

    END;

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
                           ) RETURN std_ulogic_vector IS
        VARIABLE str_copy : STRING ( 1 to str'LENGTH ) := To_Upper(str);
        VARIABLE invalid  : boolean := false;
        VARIABLE index    : Natural;
        VARIABLE ch       : character;
        VARIABLE i, idx   : Integer;
        VARIABLE r        : std_ulogic_vector(1 TO str'length);
        VARIABLE result   : std_ulogic_vector(str'length-1 downto 0);
    BEGIN
        if (StrLen (str) = 0) THEN
            assert false report " From String  --- input string has zero length ";
            return "";
        end if;
        -- find the position of the first non-white character.
        index := Find_NonBlank(str_copy); 
        IF (index > str'length) THEN
		assert false
		report " From_String  --- input string is empty  ";
                RETURN ""; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_String  -- first non_white character is a NUL ";
                RETURN "";
        END IF;
        i := 0;
        FOR idx IN index TO str'length LOOP
            i := i + 1;
    	    ch := str_copy(idx);
    		CASE ch IS
    	          WHEN 'U'      => r(i) := 'U';
            	  WHEN 'X'      => r(i) := 'X';
    	          WHEN '0'      => r(i) := '0';
            	  WHEN '1'      => r(i) := '1';
    	          WHEN 'Z'      => r(i) := 'Z';
            	  WHEN 'W'      => r(i) := 'W';
    	          WHEN 'L'      => r(i) := 'L';
            	  WHEN 'H'      => r(i) := 'H';
    	          WHEN '-'      => r(i) := '-';
                  WHEN NUL      => i := i - 1; -- last index was the non-NUL
                                   exit;
            	  WHEN OTHERS  	=> IF (NOT Is_White(ch)) THEN
                                     -- a non  binary value was passed
                                       ASSERT (invalid)
                                          REPORT "From_String(str(" & To_String(idx) & ") => " 
                                                 & To_String(ch) & ") is an invalid character "
                                          SEVERITY ERROR;
                                       invalid := TRUE;
                                   else
                                       i := i - 1; -- last index was the non-white
                                       EXIT; -- found a white space !
                                   END IF;
                END CASE;
    	END LOOP;
        if invalid THEN
            for k in 1 to i loop
                r(k) := 'U'; -- fill with 'U's
            end loop;
        end if;
        result (i-1 downto 0) := r(1 to i);
        return result(i-1 downto 0);
    END;

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
                           ) RETURN std_logic_vector IS
        VARIABLE str_copy : STRING ( 1 to str'LENGTH ) := To_Upper(str);
        VARIABLE invalid  : boolean := false;
        VARIABLE index    : Natural;
        VARIABLE ch       : character;
        VARIABLE i, idx   : Integer;
        VARIABLE r        : std_logic_vector(1 TO str'length);
        VARIABLE result   : std_logic_vector(str'length-1 downto 0);
    BEGIN
        if (StrLen (str) = 0) THEN
            assert false report " From String  --- input string has zero length ";
            return "";
        end if;
        -- find the position of the first non-white character.
        index := Find_NonBlank(str_copy); 
        IF (index > str'length) THEN
		assert false
		report " From_String  --- input string is empty  ";
                RETURN ""; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_String  -- first non_white character is a NUL ";
                RETURN "";
        END IF;
         
        i := 0;
        FOR idx IN index TO str'length LOOP
            i := i + 1;
    	    ch := str_copy(idx);
    		CASE ch IS
    	          WHEN 'U'      => r(i) := 'U';
            	  WHEN 'X'      => r(i) := 'X';
    	          WHEN '0'      => r(i) := '0';
            	  WHEN '1'      => r(i) := '1';
    	          WHEN 'Z'      => r(i) := 'Z';
            	  WHEN 'W'      => r(i) := 'W';
    	          WHEN 'L'      => r(i) := 'L';
            	  WHEN 'H'      => r(i) := 'H';
    	          WHEN '-'      => r(i) := '-';
                  WHEN NUL      => i := i - 1; -- last index was the non-NUL
                                   exit;
            	  WHEN OTHERS  	=> IF (NOT Is_White(ch)) THEN
                                     -- a non  binary value was passed
                                     ASSERT (invalid)
                                        REPORT "From_String(str(" & To_String(idx) & ") => " 
                                               & To_String(ch) & ") is an invalid character"
                                        SEVERITY ERROR;
                                     invalid := TRUE;
                                   ELSE
                                     i := i - 1; -- last index was the non-white
                                     EXIT; -- found a white space !
                                   END IF;
            END CASE;
    	END LOOP;
        if invalid THEN
            for k in 1 to i loop
                r(k) := 'U'; -- fill with 'U's
            end loop;
        end if;
        result (i-1 downto 0) := r(1 to i);
        return result(i-1 downto 0);
    END;

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
                              ) RETURN bit_vector IS
      VARIABLE str_copy : STRING (1 TO str'LENGTH) := To_Upper(str);
      VARIABLE index    : Natural;
      VARIABLE ch       : character;
      VARIABLE i, idx   : Integer;
      VARIABLE invalid  : boolean := false;
      VARIABLE r        : bit_vector(1 TO str'length);
      VARIABLE result   : bit_vector(str'length - 1 DOWNTO 0) ;
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_BinString  --- input string has a zero length ";
                RETURN "";
        ELSIF  (str(str'LEFT) = NUL) THEN
		assert false
		report " From_BinString  --- input string has nul character "
                       &" at the LEFT position "
                severity ERROR;
                RETURN "";
	END IF;
        -- find the position of the first non_white character
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_BinString  --- input string is empty  ";
                RETURN ""; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_BinString  -- first non_white character is a NUL ";
                RETURN "";
        END IF;

        i := 0;
        FOR idx IN index TO  str'length LOOP
                i := i + 1;
		ch := str_copy(idx);
		CASE ch IS
	          	WHEN '0'    => r(i) := '0';
        	  	WHEN '1'    => r(i) := '1';
        	  	WHEN NUL    => i := i - 1;      -- last index was the non-NUL
                                       exit;
        	  	WHEN OTHERS => IF (NOT IS_White(ch)) THEN
                            	          -- a non  binary value was passed
        	       		          ASSERT (invalid)
                                             REPORT "From_BinString(str(" & To_String(idx) & ") => " 
                                                    & To_String(ch) & ") is an invalid character"
                                             SEVERITY ERROR;
                                          invalid := TRUE;
                                        else
                                           i := i - 1;   -- last index was the non-NUL
                                           exit;
                                        end if;
       	       	END CASE;
	END LOOP;
     -- check for invalid character in the string
        if ( invalid ) THEN
           r(1 TO i) := (OTHERS => '0');
        end if;
        result(i-1 DOWNTO 0) := r(1 TO i);
        return result(i - 1 DOWNTO 0);     -- return slice of result
 
    END;

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
                           ) RETURN bit_vector IS
      CONSTANT len         : Integer := 3 * str'LENGTH;
      CONSTANT oct_dig_len : Integer := 3;
      VARIABLE str_copy    : STRING (1 TO str'LENGTH) := To_Upper(str);
      VARIABLE index       : Natural;
      VARIABLE ch          : character;
      VARIABLE i, idx      : Integer;
      VARIABLE invalid     : boolean := false;
      VARIABLE r           : bit_vector( 1 TO len) ;
      VARIABLE result      : bit_vector(len - 1 DOWNTO 0) ;
      CONSTANT bin_zero    : bit_vector(1 to 3) := "000"; -- this done for Mentor unsupported feature
      CONSTANT bin_one     : bit_vector(1 to 3) := "001";
      CONSTANT bin_two     : bit_vector(1 to 3) := "010";
      CONSTANT bin_three   : bit_vector(1 to 3) := "011";
      CONSTANT bin_four    : bit_vector(1 to 3) := "100";
      CONSTANT bin_five    : bit_vector(1 to 3) := "101";
      CONSTANT bin_six     : bit_vector(1 to 3) := "110";
      CONSTANT bin_seven   : bit_vector(1 to 3) := "111";
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_OctString  --- input string has zero length ";
                RETURN "";
        ELSIF  (str(str'LEFT) = NUL) THEN
		assert false
		report " From_OctString  --- input string has nul character"
                        & " at the LEFT position "
                severity ERROR;
                RETURN "";              -- null  bit_vector
	END IF;
        -- find the position of the first non_white character
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_OctString  --- input string is empty  ";
                RETURN ""; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_OctString  -- first non_white character is a NUL ";
                RETURN "";
        END IF;

        i := 0;
        FOR idx IN index TO  str'length LOOP
		ch := str_copy(idx);
                EXIT WHEN ((Is_White(ch)) OR (ch = NUL));                
		CASE ch IS
	          WHEN '0'      => r(i+1 TO i+oct_dig_len) := bin_zero;
        	  WHEN '1'      => r(i+1 TO i+oct_dig_len) := bin_one;
        	  WHEN '2'      => r(i+1 TO i+oct_dig_len) := bin_two;
        	  WHEN '3'      => r(i+1 TO i+oct_dig_len) := bin_three;
        	  WHEN '4'      => r(i+1 TO i+oct_dig_len) := bin_four;
        	  WHEN '5'      => r(i+1 TO i+oct_dig_len) := bin_five;
        	  WHEN '6'      => r(i+1 TO i+oct_dig_len) := bin_six;
        	  WHEN '7'      => r(i+1 TO i+oct_dig_len) := bin_seven;
       	  	  WHEN NUL      =>  exit;
        	  WHEN OTHERS  	=>   -- a non  binary value was passed
        	       		    ASSERT (invalid)
                                       REPORT "From_OctString(str(" & To_String(idx) & ") => " 
                                              & To_String(ch) & ") is an invalid character"
                                       SEVERITY ERROR;
                                    invalid := TRUE;
       	       	END CASE;
                i := i + oct_dig_len;
	END LOOP;
     -- check for invalid character in the string
        if ( invalid ) THEN
           r(1 TO i) := (OTHERS => '0');
        end if;
        result(i - 1 DOWNTO 0) := r(1 TO i);
        return result(i-1 DOWNTO 0);     -- return slice of result

    END;

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
                               ) RETURN bit_vector IS

      CONSTANT len          : Integer := 4 * str'LENGTH;
      CONSTANT hex_dig_len  : Integer := 4;
      VARIABLE str_copy     : STRING (1 TO str'LENGTH) := To_Upper(str);
      VARIABLE index        : Natural;
      VARIABLE ch           : character;
      VARIABLE i, idx       : Integer;
      VARIABLE invalid      : boolean := false;
      VARIABLE r            : bit_vector(1 TO len) ;
      VARIABLE result       : bit_vector(len - 1 DOWNTO 0);
      CONSTANT bin_zero     : bit_vector(1 to 4) := "0000";  -- this done for Mentor unsupported feature
      CONSTANT bin_one      : bit_vector(1 to 4) := "0001";
      CONSTANT bin_two      : bit_vector(1 to 4) := "0010";
      CONSTANT bin_three    : bit_vector(1 to 4) := "0011";
      CONSTANT bin_four     : bit_vector(1 to 4) := "0100";
      CONSTANT bin_five     : bit_vector(1 to 4) := "0101";
      CONSTANT bin_six      : bit_vector(1 to 4) := "0110";
      CONSTANT bin_seven    : bit_vector(1 to 4) := "0111";
      CONSTANT bin_eight    : bit_vector(1 to 4) := "1000";
      CONSTANT bin_nine     : bit_vector(1 to 4) := "1001";
      CONSTANT bin_ten      : bit_vector(1 to 4) := "1010";
      CONSTANT bin_eleven   : bit_vector(1 to 4) := "1011";
      CONSTANT bin_twelve   : bit_vector(1 to 4) := "1100";
      CONSTANT bin_thirteen : bit_vector(1 to 4) := "1101";
      CONSTANT bin_fourteen : bit_vector(1 to 4) := "1110";
      CONSTANT bin_fifteen  : bit_vector(1 to 4) := "1111";
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_HexString  --- input string has zero length ";
                RETURN "";

        ELSIF  (str(str'LEFT) = NUL) THEN
		assert false
		report " From_HexString  --- input string has nul character"
                        & " at the LEFT position "
                severity ERROR;
                RETURN "";  -- null  bit_vector
	END IF;
        -- find the position of the first non_white character
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_HexString  --- input string is empty  ";
                RETURN ""; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false report " From_HexString  -- first non_white character is a NUL ";
                RETURN "";
        END IF;

        i := 0;
        FOR idx IN index TO  str'length LOOP
		ch := str_copy(idx);
                EXIT WHEN ((Is_White(ch)) OR (ch = NUL));                
		CASE ch IS
	          WHEN '0'        => r(i+1 TO i+ hex_dig_len) := bin_zero;
        	  WHEN '1'        => r(i+1 TO i+ hex_dig_len) := bin_one;
        	  WHEN '2'        => r(i+1 TO i+ hex_dig_len) := bin_two;
        	  WHEN '3'        => r(i+1 TO i+ hex_dig_len) := bin_three;
        	  WHEN '4'        => r(i+1 TO i+ hex_dig_len) := bin_four;
        	  WHEN '5'        => r(i+1 TO i+ hex_dig_len) := bin_five;
        	  WHEN '6'        => r(i+1 TO i+ hex_dig_len) := bin_six;
        	  WHEN '7'        => r(i+1 TO i+ hex_dig_len) := bin_seven;
        	  WHEN '8'        => r(i+1 TO i+ hex_dig_len) := bin_eight;
        	  WHEN '9'        => r(i+1 TO i+ hex_dig_len) := bin_nine;
        	  WHEN 'A' | 'a'  => r(i+1 TO i+ hex_dig_len) := bin_ten;
        	  WHEN 'B' | 'b'  => r(i+1 TO i+ hex_dig_len) := bin_eleven;
        	  WHEN 'C' | 'c'  => r(i+1 TO i+ hex_dig_len) := bin_twelve;
        	  WHEN 'D' | 'd'  => r(i+1 TO i+ hex_dig_len) := bin_thirteen;
        	  WHEN 'E' | 'e'  => r(i+1 TO i+ hex_dig_len) := bin_fourteen;
        	  WHEN 'F' | 'f'  => r(i+1 TO i+ hex_dig_len) := bin_fifteen;
       	  	  WHEN NUL        => exit;
        	  WHEN OTHERS  	  => -- a non  binary value was passed
         	       		     ASSERT (invalid)
                                        REPORT "From_HexString(str(" & To_String(idx) & ") => " 
                                               & To_String(ch) & ") is an invalid character"
                                        SEVERITY ERROR;
                                     invalid := TRUE;
       	       	END CASE;
                i := i + hex_dig_len;
	END LOOP;
     -- check for invalid character in the string
        if ( invalid ) THEN
           r(1 TO i) := (OTHERS => '0');
        end if;
        result(i - 1 DOWNTO 0) := r(1 TO i);
        return result(i - 1 DOWNTO 0);     -- return slice of result

    END;

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
                           ) RETURN STRING IS
       VARIABLE fmt       : STRING(1 TO format'LENGTH) := format;
       VARIABLE result    : STRING(1 TO max_string_len);
       VARIABLE buf_str   : STRING(1 TO 5) := (OTHERS => ' ');
       VARIABLE str_len   : INTEGER;
       VARIABLE fw        : INTEGER;
       VARIABLE precis1   : INTEGER;
       VARIABLE justfy    : BIT;
       CONSTANT FALSE_STR : STRING(1 to 5) := "FALSE";  -- for mentor unsupported feature
       CONSTANT TRUE_STR  : STRING(1 to 4) := "TRUE";
 
    BEGIN
    -- call procedure S_Machine to split the format string into  
    -- field width, precision, and justification(left or right).
    -- procedure S_Machine will issue the proper error messages.
       S_Machine(fw, precis1, justfy, fmt);

       CASE val IS
          WHEN FALSE
                        =>  
                           str_len := 5;     
                           buf_str(1 TO str_len) := FALSE_STR;

                           IF ((precis1 = 0)  OR (precis1 > str_len)) THEN
				precis1 := str_len;
                           END IF;

                           IF (fw = 0) THEN 
                           	fw := precis1;
                           END IF;
                            
                           IF (precis1 >= fw) THEN
                                return(buf_str(1 TO precis1));
                           ELSE
				result(precis1 + 1 TO fw) := (OTHERS => ' ');
                        
                           END IF;                       
          WHEN TRUE
                        =>  
                           str_len := 4;     
                           buf_str(1 TO str_len) := TRUE_STR;

                           IF ((precis1 = 0)  OR (precis1 > str_len)) THEN
				precis1 := str_len;
                           END IF;

                           IF (fw = 0) THEN 
                           	fw := precis1;
                           END IF;
                            
                           IF (precis1 >= fw) THEN
                                return(buf_str(1 TO precis1));
                           ELSE
				result(precis1 + 1 TO fw) := (OTHERS => ' ');
                        
                           END IF;                       

       END CASE;

       IF (justfy = '1') THEN    -- left jsutify
          return (buf_str(1 TO precis1) & result(precis1 + 1 TO fw));
       ELSE                      -- right justified
          return( result(precis1 + 1 TO fw) & buf_str(1 TO precis1));
       END IF;

    -- That's all

    END;
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
                           ) RETURN STRING IS
       VARIABLE fmt     : STRING(1 TO format'LENGTH) := format;
       VARIABLE result  : STRING(1 TO max_string_len);
       VARIABLE fw      : INTEGER;
       VARIABLE precis  : INTEGER;
       VARIABLE justfy  : BIT; 
 
    BEGIN
    --
    -- call procedure S_Machine to split the format string into
    -- field width, precision, and justification(left or right).
    --
       S_Machine(fw, precis, justfy, fmt);
        
       IF (fw < 1) THEN
           fw := 1;
       END IF;
    -- fill result from 1 to fw with blanks
         result(1 TO fw) := (OTHERS => ' ');
 
       CASE val IS
        
          WHEN '1'  => 
                          IF (justfy = '1') THEN     -- left justify
                                result(1)  := '1';
                           ELSE                       -- right justify
                                result (fw) := '1';
                           END if;

          WHEN '0'  =>     IF (justfy = '1') THEN     -- left justify
                                result(1)  := '0';
                           ELSE                       -- right justify
                                result (fw) := '0';
                           END if;
       END CASE;
       RETURN result(1 TO fw);   -- return a slice.
    END;

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
--|                      FOR non_printable characters if precision is less than
--|                      3 it will be automatically set to 3.
--|
--|                      Default precision will be set to eigther 3 or 1
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
                       ) RETURN STRING IS
       VARIABLE fmt     : STRING(1 TO format'LENGTH) := format;
       VARIABLE result  : STRING(1 TO max_string_len);  
       VARIABLE fw      : INTEGER;
       VARIABLE precis  : INTEGER;
       VARIABLE justfy  : BIT;
       VARIABLE str2    : STRING(1 to 2);
       VARIABLE str3    : STRING(1 to 3);
       
        
  
    BEGIN 
    -- 
    -- call procedure S_Machine to split the format string into 
    -- field width, precision, and justification(left or right). 
    -- 
       S_Machine(fw, precis, justfy, fmt); 
       
    -- since purpose of this routine to see input characters even if
    -- they are non_printable, precision 3 for non_printable and 1 for
    -- graphic characters.

      IF ((val >= NUL AND val <= USP)  AND (fw < 3)) THEN
	fw := 3;
      ELSIF ((val = DEL) AND (fw < 3)) THEN
        fw := 3;
      ELSIF (fw = 0) THEN 
        fw := 1;
      END IF;

      FOR i IN 1 TO fw LOOP
        result(i) := ' ';
      END LOOP;
     
       CASE val is
            WHEN NUL    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "NUL"; 
                           ELSE                       -- right justify
                                str3 := "NUL";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN SOH    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "SOH"; 
                           ELSE                       -- right justify
                                str3 := "SOH";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN STX    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "STX"; 
                           ELSE                       -- right justify
                                str3 := "STX";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN ETX    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "ETX"; 
                           ELSE                       -- right justify
                                str3 := "ETX";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN EOT    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "EOT"; 
                           ELSE                       -- right justify
                                str3 := "EOT";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN ENQ    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "ENQ"; 
                           ELSE                       -- right justify
                                str3 := "ENQ";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN ACK    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "ACK"; 
                           ELSE                       -- right justify
                                str3 := "ACK";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN BEL    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "BEL"; 
                           ELSE                       -- right justify
                                str3 := "BEL";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN BS     => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 2)  := "BS"; 
                           ELSE                       -- right justify
                                str2 := "BS";   -- fix for mentor unsupported feature
                                result (fw - 1 TO fw) := str2;
                           END if; 
            WHEN HT     => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 2)  := "HT"; 
                           ELSE                       -- right justify
                                str2 := "HT";   -- fix for mentor unsupported feature
                                result (fw - 1 TO fw) := str2;
                           END if; 
            WHEN LF     => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 2)  := "LF"; 
                           ELSE                       -- right justify
                                str2 := "LF";   -- fix for mentor unsupported feature
                                result (fw - 1 TO fw) := str2;
                           END if; 
            WHEN VT     => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 2)  := "VT"; 
                           ELSE                       -- right justify
                                str2 := "VT";   -- fix for mentor unsupported feature
                                result (fw - 1 TO fw) := str2;
                           END if; 
            WHEN FF     => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 2)  := "FF"; 
                           ELSE                       -- right justify
                                str2 := "FF";   -- fix for mentor unsupported feature
                                result (fw - 1 TO fw) := str2;
                           END if; 
            WHEN CR     => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 2)  := "CR"; 
                           ELSE                       -- right justify
                                str2 := "CR";   -- fix for mentor unsupported feature
                                result (fw - 1 TO fw) := str2;
                           END if; 
            WHEN SO     => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 2)  := "SO"; 
                           ELSE                       -- right justify
                                str2 := "SO";   -- fix for mentor unsupported feature
                                result (fw - 1 TO fw) := str2;
                           END if; 
            WHEN SI     => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 2)  := "SI"; 
                           ELSE                       -- right justify
                                str2 := "SI";   -- fix for mentor unsupported feature
                                result (fw - 1 TO fw) := str2;
                           END if; 
            WHEN DLE    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "DLE"; 
                           ELSE                       -- right justify
                                str3 := "DLE";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN DC1    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "DC1"; 
                           ELSE                       -- right justify
                                str3 := "DC1";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN DC2    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "DC2"; 
                           ELSE                       -- right justify
                                str3 := "DC2";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN DC3    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "DC3"; 
                           ELSE                       -- right justify
                                str3 := "DC3";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN DC4    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "DC4"; 
                           ELSE                       -- right justify
                                str3 := "DC4";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN NAK    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "NAK"; 
                           ELSE                       -- right justify
                                str3 := "NAK";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN SYN    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "SYN"; 
                           ELSE                       -- right justify
                                str3 := "SYN";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN ETB    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "ETB"; 
                           ELSE                       -- right justify
                                str3 := "ETB";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN CAN    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "CAN"; 
                           ELSE                       -- right justify
                                str3 := "CAN";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN EM     => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 2)  := "EM"; 
                           ELSE                       -- right justify
                                str2 := "EM";   -- fix for mentor unsupported feature
                                result (fw - 1 TO fw) := str2;
                           END if; 
            WHEN SUB    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "SUB"; 
                           ELSE                       -- right justify
                                str3 := "SUB";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN ESC    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "ESC"; 
                           ELSE                       -- right justify
                                str3 := "ESC";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN FSP    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "FSP"; 
                           ELSE                       -- right justify
                                str3 := "FSP";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN GSP    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "GSP"; 
                           ELSE                       -- right justify
                                str3 := "GSP";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN RSP    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "RSP"; 
                           ELSE                       -- right justify
                                str3 := "RSP";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN USP    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "USP"; 
                           ELSE                       -- right justify
                                str3 := "USP";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN DEL    => 
                           IF (justfy = '1') THEN     -- left justify
                                result(1 TO 3)  := "DEL"; 
                           ELSE                       -- right justify
                                str3 := "DEL";   -- fix for mentor unsupported feature
                                result (fw - 2 TO fw) := str3;
                           END if; 
            WHEN OTHERS =>       
                           IF (justfy = '1') THEN     -- left justify
                                result(1)  := val; 
                           ELSE                       -- right justify 
                                result (fw) := val;
                           END if; 
       END CASE;
       RETURN result(1 TO fw);  -- return a slice
    END;
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
                       ) RETURN STRING IS
       VARIABLE fmt         : STRING(1 TO format'LENGTH) := format;
       VARIABLE result      : STRING(1 TO max_string_len);
       VARIABLE buf_str     : STRING(1 TO 10);  -- severity-level is maximum 7 characters
       VARIABLE str_len     : INTEGER;
       VARIABLE fw          : INTEGER;
       VARIABLE precis2     : INTEGER;
       VARIABLE justfy      : BIT;
       CONSTANT NOTE_STR    : STRING(1 to 4) := "NOTE";  -- fix for mentor unsupported feature
       CONSTANT WARNING_STR : STRING(1 to 7) := "WARNING";
       CONSTANT ERROR_STR   : STRING(1 to 5) := "ERROR";
       CONSTANT FAILURE_STR : STRING(1 to 7) := "FAILURE";
 
    BEGIN
    -- call procedure S_Machine to split the format string into  
    -- field width, precision, and justification(left or right).
    --
      S_Machine(fw, precis2, justfy, fmt);
        
      CASE val IS
          WHEN NOTE 
                        => 
                           str_len := 4;     
                           buf_str(1 TO str_len) := NOTE_STR;

                           IF ((precis2 = 0)  OR (precis2 > str_len)) THEN
				precis2 := str_len;
                           END IF;

                           IF (fw = 0) THEN 
                           	fw := precis2;
                           END IF;
                            
                           IF (precis2 >= fw) THEN
                                return(buf_str(1 TO precis2));
                           ELSE
				result(precis2 + 1 TO fw) := (OTHERS => ' ');
                        
                           END IF;                       
            
          WHEN WARNING =>
                           str_len := 7;     
                           buf_str(1 TO str_len) := WARNING_STR;

                           IF ((precis2 = 0)  OR (precis2 > str_len)) THEN
				precis2 := str_len;
                           END IF;

                           IF (fw = 0) THEN 
                           	fw := precis2;
                           END IF;
                            
                           IF (precis2 >= fw) THEN
                                return(buf_str(1 TO precis2));
                           ELSE
				result(precis2 + 1 TO fw) := (OTHERS => ' ');
                           END IF;                       

            WHEN ERROR   => 
                           str_len := 5;     
                           buf_str(1 TO str_len) := ERROR_STR;

                           IF ((precis2 = 0)  OR (precis2 > str_len)) THEN
				precis2 := str_len;
                           END IF;

                           IF (fw = 0) THEN 
                           	fw := precis2;
                           END IF;
                            
                           IF (precis2 >= fw) THEN
                                return(buf_str(1 TO precis2));
                           ELSE
				result(precis2 + 1 TO fw) := (OTHERS => ' ');
                           END IF;                       

            WHEN FAILURE => 
                           str_len := 7;     
                           buf_str(1 TO str_len) := FAILURE_STR;

                           IF ((precis2 = 0)  OR (precis2 > str_len)) THEN
				precis2 := str_len;
                           END IF;

                           IF (fw = 0) THEN 
                           	fw := precis2;
                           END IF;
                            
                           IF (precis2 >= fw) THEN
                                return(buf_str(1 TO precis2));
                           ELSE
				result(precis2 + 1 TO fw) := (OTHERS => ' ');
                           END IF;                       

        END CASE;
       IF (justfy = '1') THEN    -- left jsutify
          return ( buf_str(1 TO precis2) & result(precis2 + 1 TO fw));
       ELSE                      -- right justified
          return (result(precis2 + 1 TO fw) & buf_str(1 TO precis2));
       END IF;

    -- That's all

    END;
 
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
                       ) RETURN STRING IS
	VARIABLE buf        : string(max_string_len DOWNTO 1) ; -- implicitly == NUL
        VARIABLE rbuf       : string(max_string_len DOWNTO 1) ;
        VARIABLE result     : string(1 TO max_string_len) ;
        VARIABLE str_index  : integer := 0;
        VARIABLE ival       : integer;
        VARIABLE format_cpy : STRING(1 TO format'LENGTH) := format;
        VARIABLE indx       : INTEGER;  
        VARIABLE fw         : INTEGER;  -- field width
        VARIABLE precis     : INTEGER;
        VARIABLE justy      : BIT := '0';

    BEGIN
    -- convert to positive number
      ival := ABS(val);
      IF ival = 0 then
	str_index := str_index + 1;
        buf(str_index) := '0';
      ELSE
	int_loop : LOOP
        	str_index := str_index + 1;
		CASE (ival MOD 10) IS
                     WHEN 0 => buf (str_index) := '0';
                     WHEN 1 => buf (str_index) := '1';
                     WHEN 2 => buf (str_index) := '2';
                     WHEN 3 => buf (str_index) := '3';
                     WHEN 4 => buf (str_index) := '4';
                     WHEN 5 => buf (str_index) := '5';
                     WHEN 6 => buf (str_index) := '6';
                     WHEN 7 => buf (str_index) := '7';
                     WHEN 8 => buf (str_index) := '8';
                     WHEN 9 => buf (str_index) := '9';
                     WHEN OTHERS => null; -- do nothing
		END CASE;
                ival := ival / 10;
                EXIT int_loop WHEN ival=0; 
	END LOOP;
      END IF;
 
        -- call procedure D_Machine to split the format string into  
        -- field width, and justification(left or right) and precision
        D_Machine(fw, precis, justy, format_cpy);

        IF (precis > str_index) THEN      -- pad with zeros to make up precision
            buf(precis DOWNTO str_index + 1) := (OTHERS => '0');
            str_index := precis;
        END IF;

        -- Handle the negative numbers here...
        IF val < 0 then
            str_index := str_index + 1;
            buf (str_index) := '-';
        END IF;

	-- return the result according to field width and justification
	IF (fw > str_index) THEN
           case justy IS 
                WHEN '0' =>
                     buf(fw DOWNTO str_index + 1) := (OTHERS => ' ');
                     return buf(fw DOWNTO 1);
		WHEN '1' =>
                     rbuf(fw - str_index  DOWNTO  1) := (OTHERS => ' ');
                      result(1 TO str_index) := buf(str_index DOWNTO 1);
                      indx := str_index;
                      FOR i IN fw DOWNTO str_index+1 LOOP
                        indx := indx + 1;
                        result(indx) := ' ';
                      END LOOP;
                     return result(1 TO fw);
                WHEN OTHERS =>
                     ASSERT NOT WarningsOn
                     report " To_String  --- error in justification "
                     SEVERITY WARNING;
                     return buf(str_index DOWNTO 1);
            end case;
	ELSE           -- fw is lessthan or equal to std_index
	    return buf(str_index DOWNTO 1);
	END IF;

       -- That's all
    END;
 
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
                         CONSTANT format : IN STRING := "%f"
                       )  RETURN STRING IS
        VARIABLE tbuf        : string(max_string_len DOWNTO 1) ; -- implicitly == NUL
        VARIABLE rbuf        : string(max_string_len DOWNTO 1);
        VARIABLE result      : string(1 TO max_string_len);
        VARIABLE str_index   : Natural := 0;
        VARIABLE rval        : real;
        VARIABLE int_val     : INTEGER;
        VARIABLE frac_digits : INTEGER;
        VARIABLE fract_val   : INTEGER;
        VARIABLE format_cpy  : string(1 TO format'length) := format;
        VARIABLE fw_actual   : integer;  -- actual field width
        VARIABLE indx        : integer;  
        VARIABLE pr_actual   : integer;  -- actual precision
        VARIABLE fw          : integer;  -- field width
        VARIABLE precis      : integer;  -- precision
        VARIABLE justy       : BIT := '0';  -- justification
        VARIABLE neg_sign    : BOOLEAN := false ;
    BEGIN
    -- Handle the negative numbers here...
      if val < 0.0 then
         neg_sign := NOT neg_sign;
      end if;
 
      rval := ABS (val);
      int_val := i_TRUNC(rval);
      i_Frac(rval, fract_val, frac_digits);

      -- call procedure F_Machine to split the format string into
      -- field width, precision, and justification

      F_Machine(fw, precis, justy, format_cpy);  
  
      -- convert fractional part to a string
      IF fract_val = 0 then
	str_index := str_index + 1;
        tbuf(str_index) := '0';
      ELSE
         fract_loop : LOOP
                  str_index := str_index + 1;

                  CASE (fract_val MOD 10) IS
                     WHEN 0 => tbuf (str_index) := '0';
                     WHEN 1 => tbuf (str_index) := '1';
                     WHEN 2 => tbuf (str_index) := '2';
                     WHEN 3 => tbuf (str_index) := '3';
                     WHEN 4 => tbuf (str_index) := '4';
                     WHEN 5 => tbuf (str_index) := '5';
                     WHEN 6 => tbuf (str_index) := '6';
                     WHEN 7 => tbuf (str_index) := '7';
                     WHEN 8 => tbuf (str_index) := '8';
                     WHEN 9 => tbuf (str_index) := '9';
                     WHEN OTHERS => null; -- do nothing
                  END CASE;
                  fract_val := fract_val / 10;
                  EXIT fract_loop WHEN fract_val=0; 
            END LOOP;
        END IF;
        -- add leading zeros of fractional part

        FOR i IN 1 to 6 - frac_digits LOOP
		str_index := str_index + 1;
                tbuf(str_index) := '0';
        END LOOP;

        pr_actual := str_index;    -- actual precision of give real number
 
        IF (precis > str_index) THEN
		rbuf(precis - str_index DOWNTO 1) := (OTHERS => '0');
                rbuf(precis DOWNTO precis - str_index + 1) := tbuf(str_index DOWNTO 1);
        ELSE
                rbuf(precis DOWNTO 1) := tbuf(str_index DOWNTO str_index - precis + 1);
        END IF;

     -- decimal point
        str_index := precis + 1;
	rbuf(str_index) := '.';
   
     -- integer part of a real number        

        IF int_val = 0 then
            str_index := str_index + 1;
            rbuf(str_index) := '0';
        ELSE
           int_loop : LOOP
                  str_index := str_index + 1;

                  CASE (int_val MOD 10) IS
                     WHEN 0 => rbuf (str_index) := '0';
                     WHEN 1 => rbuf (str_index) := '1';
                     WHEN 2 => rbuf (str_index) := '2';
                     WHEN 3 => rbuf (str_index) := '3';
                     WHEN 4 => rbuf (str_index) := '4';
                     WHEN 5 => rbuf (str_index) := '5';
                     WHEN 6 => rbuf (str_index) := '6';
                     WHEN 7 => rbuf (str_index) := '7';
                     WHEN 8 => rbuf (str_index) := '8';
                     WHEN 9 => rbuf (str_index) := '9';
                     WHEN OTHERS => null; -- do nothing
                  END CASE;
                  int_val := int_val / 10;
                  EXIT int_loop WHEN int_val=0; 
            END LOOP;
        END IF;
      -- negative sign
	IF neg_sign THEN
		str_index := str_index + 1;
		rbuf(str_index) := '-';
        END IF;
        fw_actual := str_index;      -- actual field width of real
        IF (fw <= fw_actual) THEN
		return rbuf(fw_actual DOWNTO 1);
        ELSIF (justy = '0') THEN      -- right justify
            For i In fw DOWNTO fw_actual + 1 LOOP
		rbuf(i) := ' ';
            END LOOP;
	    return rbuf(fw DOWNTO 1);
        ELSIF (justy = '1' ) THEN   -- left justify
            result(1 TO fw_actual) := rbuf(fw_actual DOWNTO 1);
            indx := fw_actual;
            For i In  fw - fw_actual DOWNTO 1 LOOP
                indx := indx + 1;
		result(indx) := ' ';
            END LOOP;	     		
            return result(1 TO indx);
        END IF;
      -- That's all
    END;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_OctString
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Convert a bit_vector  to a octal String.
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
    FUNCTION To_OctString ( CONSTANT val      : IN BIT_VECTOR;
                            CONSTANT format   : IN STRING := "%o"
                          )  RETURN STRING IS
      CONSTANT reslen     : INTEGER := val'LENGTH;
      CONSTANT oct_bits   : INTEGER := 3;
      VARIABLE last_bits  : INTEGER;
      VARIABLE oct_len    : NATURAL;
      VARIABLE loc_result : STRING(1 TO reslen);
      VARIABLE oct_result : STRING(1 TO reslen) := (OTHERS => ' ');
--    VARIABLE oct_str    : STRING(1 TO oct_bits); -- Intermetrics can't handle this on the case statement below!
      VARIABLE oct_str    : STRING(1 TO 3       );
      VARIABLE bv         : BIT_VECTOR(1 TO reslen) := val;
      VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
      VARIABLE result     : STRING(1 TO max_string_len);
      VARIABLE fw         : INTEGER;
      VARIABLE precis     : INTEGER;
      VARIABLE justfy     : BIT;
      VARIABLE str_type   : CHARACTER;
      VARIABLE index      : INTEGER;

    BEGIN
    -- 
    -- convert Bit_Vector to string without taking care of format 

        FOR i IN reslen DOWNTO 1 LOOP
              IF ( bv(i) = '1') THEN 
		 loc_result(i) := '1';
              ELSE                   -- bv(i) = '0' 
                 loc_result(i) := '0';
              END IF;
        END LOOP;
      
    -- call procedure SOX_Machine to split the format string into
    -- field width, precision, and justification(left or right), and 
    -- string_type ( binary, octal or hex)

       SOX_Machine(fw, precis, justfy, str_type, fmt);
    -- set the field width and precison propoerly
      IF ((precis = 0) OR (precis > reslen)) THEN
      	   precis := reslen;
      END IF;

      last_bits := precis MOD oct_bits;
      IF (last_bits = 0) THEN
          oct_len := precis / oct_bits;
      ELSE 
          oct_len := precis /oct_bits + 1;
      END IF;

      index := precis;
      FOR i IN oct_len  DOWNTO 1 LOOP
            IF ( i = 1) AND (last_bits /= 0) THEN
              oct_str(1 TO oct_bits - last_bits) := (OTHERS => '0');
              oct_str(oct_bits - last_bits + 1 TO oct_bits) := loc_result(1 TO last_bits);
            ELSE
                oct_str := loc_result(index - 2 TO index);
            END IF;
            CASE oct_str IS
			WHEN "000" => oct_result(i) := '0'; 
			WHEN "001" => oct_result(i) := '1'; 
			WHEN "010" => oct_result(i) := '2'; 
			WHEN "011" => oct_result(i) := '3'; 
			WHEN "100" => oct_result(i) := '4'; 
			WHEN "101" => oct_result(i) := '5'; 
			WHEN "110" => oct_result(i) := '6'; 
			WHEN "111" => oct_result(i) := '7'; 
                   	WHEN OTHERS => null; 
            END CASE;
            index := index - oct_bits;
      END LOOP;

      IF (fw < oct_len) THEN
            fw := oct_len;
      END IF;

      IF (oct_len >= fw) THEN
      	  return(oct_result(1 TO oct_len));
      ELSE
          result(oct_len+1 TO fw) := (OTHERS => ' ');
      END IF;

      -- Now according to justification return the result;
      IF (justfy = '1') THEN                    -- left justify
         return (oct_result(1 TO oct_len) & result(oct_len+1 TO fw));
      ELSE                                      -- right justify
         return( result(oct_len + 1 TO fw) & oct_result(1 TO oct_len));
      END IF;
 
    END;

--+-----------------------------------------------------------------------------
--|     Function Name  : To_HexString
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Convert a bit_vector  to a octal String.
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
--|                          str := TO_String(vect, "%4x"), 
--|
--|-----------------------------------------------------------------------------
    FUNCTION To_HexString ( CONSTANT val      : IN BIT_VECTOR;
                            CONSTANT format   : IN STRING := "%x"
                          )  RETURN STRING IS
      CONSTANT reslen     : INTEGER := val'LENGTH;
      CONSTANT hex_bits   : INTEGER := 4;
      VARIABLE last_bits   : INTEGER;
      VARIABLE hex_len    : NATURAL;
      VARIABLE loc_result : STRING(1 TO reslen);
      VARIABLE hex_result : STRING(1 TO reslen) := (OTHERS => ' ');
--    VARIABLE hex_str    : STRING(1 TO hex_bits); -- Intermetrics can't handle this on the case statement below!
      VARIABLE hex_str    : STRING(1 TO 4       );
      VARIABLE bv         : BIT_VECTOR(1 TO reslen) := val;
      VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
      VARIABLE result     : STRING(1 TO max_string_len);
      VARIABLE fw         : INTEGER;
      VARIABLE precis     : INTEGER;
      VARIABLE justfy     : BIT;
      VARIABLE str_type   : CHARACTER;
      VARIABLE index      : INTEGER;

    BEGIN
    -- 
    -- convert Bit_Vector to string without taking care of format 

        FOR i IN reslen DOWNTO 1 LOOP
              IF ( bv(i) = '1') THEN 
		 loc_result(i) := '1';
              ELSE                   -- bv(i) = '0' 
                 loc_result(i) := '0';
              END IF;
        END LOOP;
      
    -- call procedure SOX_Machine to split the format string into
    -- field width, precision, and justification(left or right), and 
    -- string_type ( binary, octal or hex)

       SOX_Machine(fw, precis, justfy, str_type, fmt);
    -- set the field width and precison propoerly
      IF ((precis = 0) OR (precis > reslen)) THEN
      	   precis := reslen;
      END IF;

      last_bits := precis MOD hex_bits;
      IF (last_bits = 0) THEN
          hex_len := precis / hex_bits;
      ELSE 
          hex_len := precis /hex_bits + 1;
      END IF;

      index := precis;
      FOR i IN hex_len  DOWNTO 1 LOOP
            IF ( i = 1) AND (last_bits /= 0) THEN
              hex_str(1 TO hex_bits - last_bits) := (OTHERS => '0');
              hex_str(hex_bits - last_bits + 1 TO hex_bits) := loc_result(1 TO last_bits);
            ELSE
                hex_str := loc_result(index - 3 TO index);
            END IF;
            CASE hex_str IS
			WHEN "0000" => hex_result(i) := '0'; 
			WHEN "0001" => hex_result(i) := '1'; 
			WHEN "0010" => hex_result(i) := '2'; 
			WHEN "0011" => hex_result(i) := '3'; 
			WHEN "0100" => hex_result(i) := '4'; 
			WHEN "0101" => hex_result(i) := '5'; 
			WHEN "0110" => hex_result(i) := '6'; 
			WHEN "0111" => hex_result(i) := '7'; 
                        WHEN "1000" => hex_result(i) := '8'; 
			WHEN "1001" => hex_result(i) := '9'; 
			WHEN "1010" => hex_result(i) := 'A'; 
			WHEN "1011" => hex_result(i) := 'B'; 
			WHEN "1100" => hex_result(i) := 'C'; 
			WHEN "1101" => hex_result(i) := 'D'; 
			WHEN "1110" => hex_result(i) := 'E'; 
			WHEN "1111" => hex_result(i) := 'F'; 
                 	WHEN OTHERS => null; 
            END CASE;
            index := index - hex_bits;
      END LOOP;

      IF (fw < hex_len) THEN
            fw := hex_len;
      END IF;

      IF (hex_len >= fw) THEN
      	  return(hex_result(1 TO hex_len));
      ELSE
          result(hex_len+1 TO fw) := (OTHERS => ' ');
      END IF;

      -- Now according to justification return the result;
      IF (justfy = '1') THEN                    -- left justify
         return (hex_result(1 TO hex_len) & result(hex_len+1 TO fw));
      ELSE                                      -- right justify
         return( result(hex_len + 1 TO fw) & hex_result(1 TO hex_len));
      END IF;
 
    END;

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
                         CONSTANT format   : IN STRING := "%s"
                       )  RETURN STRING IS
      CONSTANT reslen     : INTEGER := val'LENGTH;
      VARIABLE loc_result : STRING(1 TO reslen);
      VARIABLE bv         : BIT_VECTOR(1 TO reslen) := val;
      VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
      VARIABLE result     : STRING(1 TO max_string_len);
      VARIABLE fw         : INTEGER;
      VARIABLE precis     : INTEGER;
      VARIABLE justfy     : BIT;
      VARIABLE str_type   : CHARACTER;
      VARIABLE index      : INTEGER;

   BEGIN
     -- call procedure SOX_Machine to split the format string into
     -- field width, precision, and justification(left or right), and 
     -- string_type ( binary, octal or hex)
       SOX_Machine(fw, precis, justfy, str_type, fmt);
       CASE str_type IS
      	  WHEN  's' => 
                 -- convert Bit_Vector to string without taking care of format 
                  FOR i IN reslen DOWNTO 1 LOOP
                      IF ( bv(i) = '1') THEN 
	         	 loc_result(i) := '1';
                      ELSE                   -- bv(i) = '0' 
                         loc_result(i) := '0';
                      END IF;
                  END LOOP;
                -- set the field width and precison propoerly
                  IF ((precis = 0) OR (precis > reslen)) THEN
         	  	precis := reslen;
                  END IF;

                  IF (fw < val'LENGTH) THEN
                          fw := val'LENGTH;
                  END IF;

                  IF (precis >= fw) THEN
                 	  return(loc_result(1 TO precis));
                  ELSE
                          result(precis+1 TO fw) := (OTHERS => ' ');
                  END IF;

                  -- Now according to justification return the result;
                  IF (justfy = '1') THEN                    -- left justify
                          return (loc_result(1 TO precis) & result(precis+1 TO fw));
                  ELSE                                      -- right justify
                          return( result(precis+1 TO fw) & loc_result(1 TO precis));
                  END IF;

            WHEN 'o' | 'O' =>  return(To_OctString(val, format));

            WHEN  'x' | 'X' =>  return(TO_HexString(val, format));

            WHEN OTHERS     =>  --ASSERT false
	                        --report " To_String (bit_vector case)-- format error "
                                --SEVERITY ERROR;
                                return result;
        END CASE;
   END To_String;
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
                           ) RETURN STRING IS
   
       VARIABLE fmt     : STRING(1 TO format'LENGTH) := format;
       VARIABLE result  : STRING(1 TO max_string_len);
       VARIABLE fw      : INTEGER;
       VARIABLE precis  : INTEGER;
       VARIABLE justify : BIT;
 
    BEGIN
    -- call procedure S_Machine to split the format string into
    -- field width, precision, and justification(left or right).
    --
       S_Machine(fw, precis, justify, fmt);
  
       IF (fw < 1) THEN
          fw := 1;
       END IF;
    -- fill result from 1 to fw with blanks
      result(1 TO fw) := (OTHERS => ' ');
      CASE val IS
          WHEN 'U'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'U';
                           ELSE                      -- right justify
                                result(fw) := 'U';
                           END IF;

          WHEN 'X'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'X';
                           ELSE                      -- right justify
                                result(fw) := 'X';
                           END IF;

          WHEN '0'      => IF (justify = '1') THEN   -- left justify
                                result(1) := '0';
                           ELSE                      -- right justify
                                result(fw) := '0';
                           END IF;

          WHEN '1'      => IF (justify = '1') THEN   -- left justify
                                result(1) := '1';
                           ELSE                      -- right justify
                                result(fw) := '1';
                           END IF;

          WHEN 'Z'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'Z';
                           ELSE                      -- right justify
                                result(fw) := 'Z';
                           END IF;

          WHEN 'W'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'W';
                           ELSE                      -- right justify
                                result(fw) := 'W';
                           END IF;

          WHEN 'L'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'L';
                           ELSE                      -- right justify
                                result(fw) := 'L';
                           END IF;

          WHEN 'H'      => IF (justify = '1') THEN   -- left justify
                                result(1) := 'H';
                           ELSE                      -- right justify
                                result(fw) := 'H';
                           END IF;

          WHEN '-'      => IF (justify = '1') THEN   -- left justify
                                result(1) := '-';
                           ELSE                      -- right justify
                                result(fw) := '-';
                           END IF;

          WHEN OTHERS   => -- An unknown std_ulogic value was passed
                           ASSERT FALSE
                           REPORT "To_String - Unknown std_ulogic value"
                           SEVERITY ERROR;
        END CASE;
        RETURN result(1 TO fw);
    END To_String;
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
                           ) RETURN STRING IS
      CONSTANT reglen     : INTEGER := val'LENGTH;
      VARIABLE loc_result : STRING(1 TO reglen);
      VARIABLE slv         : std_logic_vector(1 TO reglen) := val;
      VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
      VARIABLE result     : STRING(1 TO max_string_len);
      VARIABLE fw         : INTEGER;
      VARIABLE precis     : INTEGER;
      VARIABLE justfy     : BIT;
 
    BEGIN
    -- Convert to string without taking care of the format.
      FOR i IN reglen  DOWNTO 1 LOOP
         CASE slv(i) IS
            WHEN 'U'      => loc_result(i) := 'U';
            WHEN 'X'      => loc_result(i) := 'X';
            WHEN '0'      => loc_result(i) := '0';
            WHEN '1'      => loc_result(i) := '1';
            WHEN 'Z'      => loc_result(i) := 'Z';
            WHEN 'W'      => loc_result(i) := 'W';
            WHEN 'L'      => loc_result(i) := 'L';
            WHEN 'H'      => loc_result(i) := 'H';
            WHEN '-'      => loc_result(i) := '-';
            WHEN OTHERS   => -- An unknown std_logic value was passed
                             ASSERT FALSE
                             REPORT "To_String -- Unknown std_logic_vector value"
                             SEVERITY ERROR;
         END CASE;
      END LOOP;
    -- call procedure S_Machine to split the format string into
    -- field width, precision, and justification(left or right).
    --
      S_Machine(fw, precis, justfy, fmt);
    -- set the field width and precison propoerly
      IF ((precis = 0) OR (precis > reglen)) THEN
      	   precis := reglen;
      END IF;
      IF (fw < val'LENGTH) THEN
           fw := val'LENGTH;
      END IF;
      IF (precis >= fw) THEN
	  return(loc_result(1 TO precis));
      ELSE
          result(precis+1 TO fw) := (OTHERS => ' ');
      END IF;
    -- Now according to justification return the result;
      IF (justfy = '1') THEN                    -- left justify
           return (loc_result(1 TO precis) & result(precis+1 TO fw));
      ELSE                                      -- right justify
           return( result(precis+1 TO fw) & loc_result(1 TO precis));
      END IF;
    END To_String;
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
                           ) RETURN STRING IS
      CONSTANT reglen : INTEGER := val'LENGTH;
      VARIABLE loc_result : STRING(1 TO reglen);
      VARIABLE slv        : std_ulogic_vector(1 TO reglen) := val;
      VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
      VARIABLE result     : STRING(1 TO max_string_len);
      VARIABLE fw         : INTEGER;
      VARIABLE precis     : INTEGER;
      VARIABLE justfy     : BIT;
 
    BEGIN
    -- Convert to string without taking care of the format.
        FOR i IN reglen  DOWNTO 1 LOOP
          CASE slv(i) IS
            WHEN 'U'      => loc_result(i) := 'U';
            WHEN 'X'      => loc_result(i) := 'X';
            WHEN '0'      => loc_result(i) := '0';
            WHEN '1'      => loc_result(i) := '1';
            WHEN 'Z'      => loc_result(i) := 'Z';
            WHEN 'W'      => loc_result(i) := 'W';
            WHEN 'L'      => loc_result(i) := 'L';
            WHEN 'H'      => loc_result(i) := 'H';
            WHEN '-'      => loc_result(i) := '-';
            WHEN OTHERS   => -- An unknown std_logic value was passed
                             ASSERT FALSE
                             REPORT "To_String -- Unknown std_logic_vector value"
                             SEVERITY ERROR;
          END CASE;
       END LOOP;
     -- call procedure S_Machine to split the format string into
     -- field width, precision, and justification(left or right).
     --
       S_Machine(fw, precis, justfy, fmt);
    -- set the field width and precison propoerly
      IF ((precis = 0) OR (precis > reglen)) THEN
      	   precis := reglen;
      END IF;
      IF (fw < val'LENGTH) THEN
           fw := val'LENGTH;
      END IF;
      IF (precis >= fw) THEN
	  return(loc_result(1 TO precis));
      ELSE
          result(precis+1 TO fw) := (OTHERS => ' ');
      END IF;
    -- Now according to justification return the result;
      IF (justfy = '1') THEN                    -- left justify
           return (loc_result(1 TO precis) & result(precis+1 TO fw));
      ELSE                                      -- right justify
           return( result(precis+1 TO fw) & loc_result(1 TO precis));
      END IF;
    END To_String;
--
-- character Handling Functions
--
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
--|     Use            : VARIABLE ch : character;
--|                      
--|                       While (Is_Alpha(ch)) LOOP
--|                             -- do somthing
--|                          END LOOP;
--|
--|     See Also       : Is_Digit, Is_Upper, Is_Lower
--|----------------------------------------------------------------------------- 
     FUNCTION  Is_Alpha  ( CONSTANT c   : IN CHARACTER
                         ) RETURN BOOLEAN IS

         VARIABLE result : BOOLEAN := false; 
     BEGIN
          IF ( (c >= 'a' AND c <= 'z') OR ( c >= 'A' AND c <= 'Z')) THEN
                result := TRUE;
          ELSE
                result := FALSE;
          END IF;
          RETURN result;
     END Is_Alpha;
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
--|     Use            : VARIABLE ch : character;
--|                      
--|                       IF (IS_Upper(ch)) THEN
--|                           
--|                             -- do somthing
--|                       ELSE
--|                                 -- do alternate action
--|                       END IF;
--|
--|     See Also       : Is_Digit, Is_Alpha, Is_Lower
--|----------------------------------------------------------------------------- 
     FUNCTION  Is_Upper  ( CONSTANT c    : IN CHARACTER
                         ) RETURN BOOLEAN IS
         VARIABLE result : BOOLEAN := false;
     BEGIN
         IF ( c >= 'A' AND c <= 'Z') THEN 
               result := TRUE; 
        ELSE 
               result := FALSE; 
          END IF; 
          RETURN result; 
     END Is_Upper; 
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
                          ) RETURN BOOLEAN IS
        VARIABLE result : BOOLEAN := false;
     BEGIN
         IF ( c >= 'a' AND c <= 'z' ) THEN 
                result := TRUE; 
          ELSE 
                result := FALSE; 
          END IF; 
          RETURN result; 
     END Is_Lower; 
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
                         ) RETURN BOOLEAN IS
         VARIABLE result : BOOLEAN; 
     BEGIN
        IF (c >= '0' and c <= '9') THEN
             result := TRUE;
        ELSE
             result := FALSE;
        END IF;
        RETURN result;
     END Is_Digit;
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
                         ) RETURN BOOLEAN IS
         VARIABLE result : BOOLEAN;
     BEGIN
        IF (c = ' ' OR   c = HT ) THEN
             result := TRUE;
        ELSE
             result := FALSE;
        END IF;
        RETURN result;
     END Is_Space; 
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
                         ) RETURN CHARACTER IS
         VARIABLE result : CHARACTER := c; 
     BEGIN
           IF ( c >= 'a' and c <= 'z') THEN
              result := CHARACTER'VAL( CHARACTER'POS(c) 
                                       - CHARACTER'POS('a')
                                       + CHARACTER'POS('A') );
           END IF;
           RETURN  result;
     END To_Upper;
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
                         ) RETURN STRING IS
        VARIABLE result   : string (1 TO val'LENGTH) := val;
        VARIABLE ch       : character;
    BEGIN
        FOR i IN 1 TO val'LENGTH LOOP
            ch := result(i);
            EXIT WHEN ((ch = NUL) OR (ch = nul));
            IF ( ch >= 'a' and ch <= 'z') THEN
    	          result(i) := CHARACTER'VAL( CHARACTER'POS(ch) 
                                       - CHARACTER'POS('a')
                                       + CHARACTER'POS('A') );
            END IF;
    	END LOOP;
    	RETURN result;
    END To_Upper;
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
                         ) RETURN CHARACTER IS
         VARIABLE result : CHARACTER := c;
      BEGIN
          IF ( c >= 'A' and c <= 'Z') THEN 
              result := CHARACTER'VAL( CHARACTER'POS(c) 
                                       - CHARACTER'POS('A')
                                       + CHARACTER'POS('a') );
          END IF; 
          RETURN  result; 
      END To_Lower; 
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
                        ) RETURN STRING IS
        VARIABLE result   : string (1 TO val'LENGTH) := val;
        VARIABLE ch       : character;
    BEGIN
         FOR i IN 1 TO val'LENGTH LOOP
    	    ch := result(i);
            EXIT  WHEN ((ch = NUL) OR (ch = nul));
            IF ( ch >= 'A' and ch <= 'Z') THEN
    	          result(i) := CHARACTER'VAL( CHARACTER'POS(ch) 
                                       - CHARACTER'POS('A')
                                       + CHARACTER'POS('a') );
            END IF;
    	END LOOP;
    	RETURN result;
   END To_Lower; 
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
                      )  RETURN STRING IS
       CONSTANT len_l      : INTEGER := StrLen(l_str);
       CONSTANT len_r      : INTEGER := StrLen(r_str);
       CONSTANT len_result : INTEGER := len_l + len_r;
       VARIABLE  l         : STRING ( 1 to l_str'length) := l_str;
       VARIABLE  r         : STRING ( 1 to r_str'length) := r_str;
       VARIABLE result     : STRING (1 to len_result);
    BEGIN
        If (len_result /= 0) THEN
            result (1 to len_l) := l ( 1 to len_l);
            result (len_l+1 to len_result) := r ( 1 to len_r );
            RETURN result;
        else 
            return "";
        end if;
      
    END StrCat;
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
                       )  RETURN STRING IS
       CONSTANT len_l      : INTEGER := StrLen(l_str);
       CONSTANT len_result : INTEGER := len_l + n;
       VARIABLE  l         : STRING ( 1 to l_str'length) := l_str;
       VARIABLE  r         : STRING ( 1 to r_str'length) := r_str;
       VARIABLE result       : STRING (1 TO len_result);

    BEGIN
          IF (len_result = 0) THEN
             return "";
          END IF;
          IF ((n <= 0) OR (r_str'LENGTH = 0)) THEN
              result(1 TO len_l) := l(1 To len_l);
          ELSE 
              result(1 TO len_l) := l(1 TO len_l);
              FOR i IN 1 TO n LOOP
                   result(len_l + i) := r(i);
                   EXIT when ((r(i) = NUL) OR
                             (i >= r_str'LENGTH));
              END LOOP;
          END IF;
          RETURN result; 
    END StrNCat;
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
                         CONSTANT r_str : IN  STRING) IS
       VARIABLE  l_len     : integer := l_str'LENGTH;
       VARIABLE  r_len     : integer := r_str'LENGTH;
       VARIABLE  r         : STRING ( 1 to r_len) := r_str;
       VARIABLE result     : STRING (1 to l_len);
       VARIABLE indx       : integer := 1;
    BEGIN
    
--  removed because it is not needed and because other routines call strcpy
--  and they should not generate a strcpy error
--       assert (l_len > 0)
--          report "StrCpy:  target string is of zero length "
--          severity ERROR;
              
       while ( (indx <= r_len) and (indx <= l_len) and (r(indx) /= NUL) ) loop
          result(indx) := r(indx);
          indx := indx + 1;
       end loop;
       if (indx <= l_len) then
          result(indx) := NUL;
       end if;
       l_str := result;
       return;
    END StrCpy;
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
                       ) IS
       VARIABLE  l_len     : integer := l_str'LENGTH;
       VARIABLE  r_len     : integer := r_str'LENGTH;
       VARIABLE  r         : STRING ( 1 to r_len) := r_str;
       VARIABLE result     : STRING (1 to l_len);
       VARIABLE indx       : integer := 1;
    BEGIN

--   removed - for reason see strcpy
--       assert (l_len > 0)
--          report "StrNCpy:  target string is of zero length "
--          severity ERROR;
              
       while ( (indx <= r_len) and (indx <= l_len) and (r(indx) /= NUL) and (indx <= n) ) loop
          result(indx) := r(indx);
          indx := indx + 1;
       end loop;
       if (indx <= l_len) then
          result(indx) := NUL;
       end if;
       l_str := result;
       return;
    END StrNCpy; 
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
                       ) RETURN INTEGER IS
       VARIABLE ls     : STRING(1 TO l_str'LENGTH) := l_str;
       VARIABLE rs     : STRING(1 TO r_str'LENGTH) := r_str;
       VARIABLE lv, rv : INTEGER;
       VARIABLE i      : INTEGER := 1;
    BEGIN
          WHILE ( (i <= ls'LENGTH) and (i <= rs'LENGTH) and (ls(i) /= NUL) and (rs(i) /= NUL) ) LOOP
             if ( ls(i) /= rs(i) ) then
                return (CHARACTER'POS(ls(i)) - CHARACTER'POS(rs(i)));
             end if;
             i := i + 1;
          END LOOP;
          
          if ( i > ls'LENGTH) then
            lv := 0;
          else
            lv := CHARACTER'POS(ls(i));
          end if;
          
          if ( i > rs'LENGTH) then
            rv := 0;
          else
            rv := CHARACTER'POS(rs(i));
          end if;

          return (lv - rv);
    END StrCmp;
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
                       ) RETURN INTEGER IS
       VARIABLE ls     : STRING(1 TO l_str'LENGTH) := l_str;
       VARIABLE rs     : STRING(1 TO r_str'LENGTH) := r_str;
       VARIABLE i      : INTEGER := 1;
       VARIABLE lv, rv : INTEGER;
     BEGIN
	IF ( n <= 0) THEN
              RETURN (0);
        ELSE
          WHILE ( (i <= ls'LENGTH) and (i <= rs'LENGTH) and (ls(i) /= NUL) and (rs(i) /= NUL) and (i <= n) ) LOOP
             if ( ls(i) /= rs(i) ) then
                return (CHARACTER'POS(ls(i)) - CHARACTER'POS(rs(i)));
             end if;
             i := i + 1;
          END LOOP;

          if ( i > n ) then
             return 0;
          end if;
          
          if ( i > ls'LENGTH) then
            lv := 0;
          else
            lv := CHARACTER'POS(ls(i));
          end if;
          
          if ( i > rs'LENGTH) then
            rv := 0;
          else
            rv := CHARACTER'POS(rs(i));
          end if;

          return (lv - rv);
  	END IF;
     END StrNCmp;
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
                        ) RETURN INTEGER IS

       VARIABLE ls     : STRING(1 TO l_str'LENGTH);
       VARIABLE rs     : STRING(1 TO r_str'LENGTH);
       VARIABLE lv, rv : INTEGER;
       VARIABLE i      : INTEGER := 1;

    BEGIN
	-- convert both strings to upper case
          ls := To_Upper(l_str);
          rs := To_Upper(r_str);

          WHILE ( (i <= ls'LENGTH) and (i <= rs'LENGTH) and (ls(i) /= NUL) and (rs(i) /= NUL) ) LOOP
             if ( ls(i) /= rs(i) ) then
                return (CHARACTER'POS(ls(i)) - CHARACTER'POS(rs(i)));
             end if;
             i := i + 1;
          END LOOP;
          
          if ( i > ls'LENGTH) then
            lv := 0;
          else
            lv := CHARACTER'POS(ls(i));
          end if;
          
          if ( i > rs'LENGTH) then
            rv := 0;
          else
            rv := CHARACTER'POS(rs(i));
          end if;

          return (lv - rv);
    END StrNcCmp;
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
                       ) RETURN NATURAL IS
        VARIABLE len   : natural := 0;
    BEGIN
        length_check : for i in l_str'range loop
            EXIT length_check WHEN l_str(i) = NUL;
            len := len + 1;
        end loop;
        return len;
    END StrLen;
--
-- FILE I/O
--

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
                        ) IS
	VARIABLE ch  : character;   
    BEGIN
	WHILE NOT ENDFILE(in_fptr) LOOP
		READ(in_fptr, ch);
		WRITE(out_fptr, ch);
        END LOOP;
        RETURN;
    END Copyfile;

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
                       ) IS
       VARIABLE ll : LINE;       -- LINE is declared in TEXTIO   

    BEGIN
         WHILE NOT ENDFILE(in_fptr) LOOP
                READLINE(in_fptr, ll);      -- call procedure from TEXTIO
                WRITELINE(out_fptr, ll);
         END LOOP;
         DEALLOCATE(ll);
         RETURN;
    END Copyfile;

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
                         CONSTANT arg6          : IN STRING := "" ;
                         CONSTANT arg7          : IN STRING := "";
                         CONSTANT arg8          : IN STRING := "";
                         CONSTANT arg9          : IN STRING := "" ;
                         CONSTANT arg10         : IN STRING := ""
                        ) IS
           VARIABLE arg        : STRING(1 TO max_string_len); 
           VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
           VARIABLE index      : INTEGER := 0;
           VARIABLE ch         : CHARACTER;
           VARIABLE lookahead  : CHARACTER;
           VARIABLE tokn       : STRING(1 TO max_token_len);
           VARIABLE ArgNum     : INTEGER RANGE 1 TO 11;
    BEGIN
    --
      IF (format'LENGTH = 0) THEN
	assert false
	report " fprint --- format string is null "
        severity ERROR;
        return;
      END IF;

      ArgNum := 1;
      WHILE (true) LOOP
           index := index + 1;
           ch := fmt(index);
            
           IF (index < format'LENGTH) THEN
               lookahead := fmt(index+1);
           ELSE
                lookahead := ' ';
           END IF;
 
           IF (( ch = '%') AND (lookahead = '%'))  THEN   
           	index := index + 1;            -- print % character
                WRITE(file_ptr, ch);

           ELSIF ((ch = '\') AND (lookahead ='n')) THEN   -- new line
                index := index + 1;            
                ch := LF;
                WRITE(file_ptr, ch);            

           ELSIF (ch = '%') AND (lookahead /= '%') THEN  
                                                      -- format %s expected
                EXIT WHEN (ArgNum > 10); -- only first 10 argments will be printed
                tokn := (OTHERS => ' ');     -- fill token with blank space
                get_token(fmt, index, tokn);

               --   select argument number 1 to 10
                 Case ArgNum IS
                    WHEN 1 =>
                             IF (arg1 /= "") THEN
	                             print_str(file_ptr, tokn, arg1);
                             ELSE 
                                EXIT;
                             END IF;

                    WHEN 2 =>
                             IF (arg2 /= "") THEN
	                             print_str(file_ptr, tokn, arg2);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 3 =>
                             IF (arg3 /= "") THEN
	                             print_str(file_ptr, tokn, arg3);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 4 =>
                             IF (arg4 /= "") THEN
	                             print_str(file_ptr, tokn, arg4);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 5 =>
                             IF (arg5 /= "") THEN
	                             print_str(file_ptr, tokn, arg5);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 6 =>
                             IF (arg6 /= "") THEN
	                             print_str(file_ptr, tokn, arg6);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 7 =>
                             IF (arg7 /= "") THEN
	                             print_str(file_ptr, tokn, arg7);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 8 =>
                             IF (arg8 /= "") THEN
	                             print_str(file_ptr, tokn, arg8);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 9 =>
                             IF (arg9 /= "") THEN
	                             print_str(file_ptr, tokn, arg9);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 10 =>
                             IF (arg10 /= "") THEN
	                        print_str(file_ptr, tokn, arg10);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 11 => -- should not happen
                               Assert false
                               Report "fprint -- ASCII_TEXT, arguments > 10 "
                               SEVERITY ERROR;                             
                END CASE;     
                ArgNum := ArgNum + 1;

           ELSIF (ch /= '%') THEN        -- printable characters
                WRITE(file_ptr, ch);
           END IF;
           EXIT WHEN (index = format'LENGTH);
         END LOOP;                                --  end of while true loop
       
      -- That's it
     END fprint;

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
                         CONSTANT arg6          : IN STRING := "" ;
                         CONSTANT arg7          : IN STRING := "";
                         CONSTANT arg8          : IN STRING := "";
                         CONSTANT arg9          : IN STRING := "" ;
                         CONSTANT arg10         : IN STRING := ""
                        ) IS
        VARIABLE arg    : STRING(1 TO max_string_len); 
        VARIABLE fmt    : STRING(1 TO format'LENGTH) := format;
        VARIABLE index  : INTEGER := 0;
        VARIABLE ch     : CHARACTER;
	VARIABLE lookahead  : CHARACTER;
	VARIABLE tokn       : STRING(1 TO max_token_len);
	VARIABLE ArgNum     : INTEGER RANGE 1 TO 11;

     BEGIN
     -- check for null format string
       IF (format'LENGTH = 0) THEN
	  assert false
  	  report " fprint --- format string is null "
          severity ERROR;
          return;
       END IF;
      -- initialize index to 0 and ArgNum to 1
       index := 0;
       ArgNum := 1;
       WHILE (true) LOOP
           index := index + 1;
           ch := fmt(index);
            
           IF (index < format'LENGTH) THEN
               lookahead := fmt(index+1);
           ELSE
                lookahead := ' ';
           END IF;
 
           IF (( ch = '%') AND (lookahead = '%'))  THEN   
           	index := index + 1;            -- print % character
                WRITE(line_ptr, ch);

           ELSIF ((ch = '\') AND (lookahead ='n')) THEN   -- new line
                index := index + 1;            
                WRITELINE(file_ptr, line_ptr);            
                DEALLOCATE(line_ptr);
           ELSIF (ch = '%') AND (lookahead /= '%') THEN  
                                                      -- format %s expected
                EXIT WHEN (ArgNum > 10); -- only first 10 argments will be printed
                tokn := (OTHERS => ' ');     -- fill token with blank space
                get_token(fmt, index, tokn);

               --   select argument number 1 to 10
                Case ArgNum IS
                    WHEN 1 => IF (arg1 /= "") THEN
	                             print_str(line_ptr, tokn, arg1);
                              ELSE 
                                  EXIT;
                              END IF;

                    WHEN 2 => IF (arg2 /= "") THEN
	                             print_str(line_ptr, tokn, arg2);
                              ELSE 
                                 EXIT;
                              END IF;
                    WHEN 3 => IF (arg3 /= "") THEN
	                             print_str(line_ptr, tokn, arg3);
                              ELSE 
                                 EXIT;
                              END IF;

                    WHEN 4 => IF (arg4 /= "") THEN
	                             print_str(line_ptr, tokn, arg4);
                              ELSE 
                                 EXIT;
                              END IF;

                    WHEN 5 => IF (arg5 /= "") THEN
	                             print_str(line_ptr, tokn, arg5);
                              ELSE 
                                 EXIT;
                              END IF;

                    WHEN 6 => IF (arg6 /= "") THEN
	                             print_str(line_ptr, tokn, arg6);
                              ELSE 
                                 EXIT;
                              END IF;

                    WHEN 7 => IF (arg7 /= "") THEN
	                             print_str(line_ptr, tokn, arg7);
                              ELSE 
                                 EXIT;
                              END IF;

                    WHEN 8 => IF (arg8 /= "") THEN
	                             print_str(line_ptr, tokn, arg8);
                              ELSE 
                                 EXIT;
                              END IF;

                    WHEN 9 => IF (arg9 /= "") THEN
	                             print_str(line_ptr, tokn, arg9);
                              ELSE 
                                 EXIT;
                              END IF;

                    WHEN 10 => IF (arg10 /= "") THEN
	                             print_str(line_ptr, tokn, arg10);
                               ELSE 
                                  EXIT;
                               END IF;

                    WHEN 11 => -- should not happen
                               Assert false
                               Report "fprint -- TEXT, arguments > 10 "
                               SEVERITY ERROR;                             
                END CASE;     
              -- increment the argument number
                ArgNum := ArgNum + 1;
                
           ELSIF (ch /= '%') THEN        -- printable characters
                WRITE(line_ptr, ch);
           END IF;
           EXIT WHEN (index = format'LENGTH);
         END LOOP;                                --  end of while true loop
      -- That's it
      END fprint;
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
                         CONSTANT arg9          : IN STRING := "" ;
                         CONSTANT arg10         : IN STRING := ""
                        ) IS
        VARIABLE rbuf       : STRING(1 TO string_buf'LENGTH); 
        VARIABLE arg        : STRING(1 TO max_string_len); 
        VARIABLE fmt        : STRING(1 TO format'LENGTH) := format;
        VARIABLE index      : INTEGER := 0;
        VARIABLE buf_indx   : INTEGER := 0;
        VARIABLE ch         : CHARACTER;
	VARIABLE lookahead  : CHARACTER;
	VARIABLE tokn       : STRING(1 TO max_token_len);
	VARIABLE ArgNum     : INTEGER RANGE 1 TO 11;

     BEGIN
     -- check for null format string
       IF (format'LENGTH = 0) THEN
	  assert false
  	  report " fprint --- format string is null "
          severity ERROR;
          return;
       END IF;

       index := 0;
       ArgNum := 1;
       WHILE (true) LOOP
           index := index + 1;
           buf_indx := buf_indx + 1;
           ch := fmt(index);
            
           IF (index < format'LENGTH) THEN
               lookahead := fmt(index+1);
           ELSE
                lookahead := ' ';
           END IF;
 
           IF (( ch = '%') AND (lookahead = '%'))  THEN   
                rbuf(buf_indx) := ch;
           	index := index + 1;            -- print % character

           ELSIF ((ch = '\') AND (lookahead ='n')) THEN   -- new line
                ch := LF;
		rbuf(buf_indx) := ch;
                index := index + 1;            

           ELSIF (ch = '%') AND (lookahead /= '%') THEN  
                                                      -- format %s expected
                EXIT WHEN (ArgNum > 10); -- only first 10 argments will be printed
                tokn := (OTHERS => ' ');     -- fill token with blank space
                get_token(fmt, index, tokn);

               --   select argument number 1 to 10

                Case ArgNum IS
                    WHEN 1 =>
                             IF (arg1 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg1);
                             ELSE 
                                EXIT;
                             END IF;

                    WHEN 2 =>
                             IF (arg2 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg2);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 3 =>
                             IF (arg3 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg3);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 4 =>
                             IF (arg4 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg4);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 5 =>
                             IF (arg5 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg5);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 6 =>
                             IF (arg6 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg6);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 7 =>
                             IF (arg7 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg7);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 8 =>
                             IF (arg8 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg8);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 9 =>
                             IF (arg9 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg9);
                             ELSE 
                                EXIT;
                             END IF;
                    WHEN 10 =>
                             IF (arg10 /= "") THEN
	                            print_str_buf(rbuf, buf_indx, tokn, arg10);
                             ELSE 
                                EXIT;
                             END IF;

                    WHEN 11 => -- should not happen
                               Assert false
                               Report "fprint -- String buffer, arguments > 10 "
                               SEVERITY ERROR;                             
                END CASE;     
              -- increment the argument number
                ArgNum := ArgNum + 1;
                
           ELSIF (ch /= '%') THEN        -- printable characters
		rbuf(buf_indx) := ch;
           END IF;
           EXIT WHEN ((index >= format'LENGTH) OR ( buf_indx >= string_buf'LENGTH)) ;    
         END LOOP;                                --  end of while true loop

         IF (buf_indx > string_buf'LENGTH) THEN
		string_buf := rbuf;
         ELSIF (buf_indx = string_buf'LENGTH) THEN
		string_buf := rbuf;
--	          If (rbuf(buf_indx) = ' ') THEN
--         	     string_buf(buf_indx) := NUL;
--                end if;
	 ELSE	
		string_buf(1 TO buf_indx) := rbuf(1 To buf_indx);
		string_buf(buf_indx + 1) := NUL;
         END IF;
       
         return;
      -- That's it
      END fprint;

--+----------------------------------------------------------------------------- 
--|     Function Name  : ffgetc
--| 
--|     Overloading    : Text, ASCII_TEXT
--|  
--|     Purpose        : to read the next character from a file
--|                      
--|
--|     Parameters     : result - output character  -- returned char
--|                      eof    - output BOOLEAN    -- TRUE if end of file reached
--|                      stream - in ASCII_TEXT     -- file 
--|                      
--|     Notes          : returns with eof true if end of file is reached
--|
--|----------------------------------------------------------------------------- 

     PROCEDURE ffgetc    ( VARIABLE result : OUT CHARACTER;
                           VARIABLE eof    : OUT BOOLEAN;
                           VARIABLE stream : IN ASCII_TEXT
                         ) IS

        VARIABLE end_file : BOOLEAN;

     BEGIN
        end_file := ENDFILE(stream);
        if (not end_file) then
           READ(stream, result);
        end if;
        eof := end_file;
        return;
     END;
   

--+-----------------------------------------------------------------------------
--|     Procedure Name : scan_for_match
--|.hidden
--|     Overloading    : TEXT and ASCII_TEXT
--|
--|     Purpose        : To scan file skipping over blank spaces and newline
--|                      characters until a non-whitespace character is found.
--|                      If that character matches match_char then mismatch is
--|                      return false otherwise its TRUE.
--|
--|                      handles all three END_OF_LINE_MARKERS (LF, CR, and CR & LF)
--|
--|     Parameters     : fptr       : IN ASCII_TEXT
--|                      match_char : IN CHARACTER
--|                      eof        : INOUT BOOLEAN
--|                      mismatch   : OUT BOOLEAN
--|
--|-----------------------------------------------------------------------------


   procedure scan_for_match ( VARIABLE fptr       : IN ASCII_TEXT;
                              CONSTANT match_char : IN CHARACTER;
                              VARIABLE eof        : INOUT BOOLEAN;
                              VARIABLE mismatch   : OUT BOOLEAN ) is

      VARIABLE ch : CHARACTER;
      VARIABLE cont : BOOLEAN;

   begin
      if ( END_OF_LINE_MARKER = (LF, ' ') ) then
         mismatch := FALSE;
         ffgetc (ch, eof, fptr);
         while ( (is_space(ch) or ( (ch = LF) and (match_char /= LF) ) ) and (not eof) ) loop
            ffgetc (ch, eof, fptr);
         end loop;
         if (not eof) then
            mismatch := (ch /= match_char);
         end if;
      elsif ( END_OF_LINE_MARKER = (CR, ' ') ) then
         mismatch := FALSE;
         ffgetc (ch, eof, fptr);
         while ( (is_space(ch) or ( (ch = CR) and (match_char /= CR) ) ) and (not eof) ) loop
            ffgetc (ch, eof, fptr);
         end loop;
         if (not eof) then
            mismatch := (ch /= match_char);
         end if;
      else  -- END_OF_LINE_MARKER = CR & LF
         mismatch := FALSE;
         cont := TRUE;
         ffgetc (ch, eof, fptr);
         while ( cont ) loop
            while ( (is_space(ch) or ( ( (ch = CR) or (ch = LF) ) and (match_char /= CR) ) ) and (not eof) ) loop
               ffgetc (ch, eof, fptr);
            end loop;
            CONT := FALSE;
            if ( (match_char = CR) and (ch = CR) ) then
               ffgetc(ch, eof, fptr);
               cont := (ch /= LF);
               if (not cont) then
                  return;
               end if;  
            end if;
         end loop;
         if (not eof) then
            mismatch := (ch /= match_char);
         end if;
      end if;
      return;
    end;

    
--+-----------------------------------------------------------------------------
--|     Procedure Name : get_fw
--|.hidden
--|     Overloading    : NONE
--|
--|     Purpose        : get the field width from the format string
--|                      assumes index is pointing at first digit
--|                      will end with index pointing a forth character
--|                      or first non-digit, which ever comes first
--|
--|     Parameters     : fmt         : IN STRING
--|                      index       : INOUT INTEGER
--|
--|
--|-----------------------------------------------------------------------------

    procedure get_fw ( VARIABLE fmt          : IN STRING;
                       VARIABLE index        : INOUT INTEGER;
                       VARIABLE field_width  : INOUT INTEGER ) is

        variable count : integer := 3;
        variable fw    : integer := 0;
        
    begin
       while ( (count > 0) and is_digit(fmt(index)) ) loop
          fw := (fw * 10) + (CHARACTER'POS(fmt(index)) - 48);
          index := index + 1;
          count := count - 1;
       end loop;
       field_width := fw;
       return;
    end;

--+-----------------------------------------------------------------------------
--|     Function Name  : fscan
--| 1.2.3
--|     Overloading    : TEXT, ASCII_TEXT, string_buffer
--|
--|     Purpose        : To read text from a file according to specifications
--|                      given by the format string and save the results into
--|                      the corresponding arguments.
--|
--|     Parameters     :
--|                         file_ptr      - input ASCII_TEXT,
--|                         format        - input STRING,
--|                         arg1          - output STRING,
--|                         arg2          - output STRING,
--|                         arg3          - output STRING,
--|                         arg4          - output STRING,
--|                         arg5          - output STRING,
--|                         arg6          - output STRING,
--|                         arg7          - output STRING,
--|                         arg8          - output STRING,
--|                         arg9          - output STRING,
--|                         arg10         - output STRING
--|                         arg11         - output STRING,
--|                         arg12         - output STRING,
--|                         arg13         - output STRING,
--|                         arg14         - output STRING,
--|                         arg15         - output STRING,
--|                         arg16         - output STRING,
--|                         arg17         - output STRING,
--|                         arg18         - output STRING,
--|                         arg19         - output STRING,
--|                         arg20         - output STRING
--|                         arg_count     - input integer,  -- # of arguments in calling procedure
--|
--|     Result         : STRING  representation given ASCII_TEXT.
--|
--|     Note:          This procedure extracts upto twenty arguments
--|                    from a line in a file.
--|                    If a %s(or whatever) is used without a digit then a space
--|                    must the string in the file inorder for the next argument to
--|                    be read in or for a match with the next literal to occur properly
--|
--|                    NOTE that when there is a %t if a time unit follows in the format string
--|                    it is skipped over (i.e. not treated as a matching string).
--|-----------------------------------------------------------------------------
    PROCEDURE fscan    ( VARIABLE file_ptr      : IN ASCII_TEXT;
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
                        ) IS
           VARIABLE fmt         : STRING(1 TO format'LENGTH) := format;  -- hold format
           VARIABLE index       : INTEGER := 1;                          -- index into fmt
           VARIABLE fmt_len     : INTEGER;                               -- length of format
           VARIABLE ch          : CHARACTER;                             -- present character read from file
           VARIABLE fchar       : CHARACTER;                             -- present format character
           VARIABLE look_ahead  : CHARACTER;                             -- next format character
           VARIABLE mismatch    : BOOLEAN := FALSE;                      -- TRUE if mismatch between format literal
                                                                         --    and file character
           VARIABLE eof         : BOOLEAN := FALSE;                      -- TRUE if end of file
           VARIABLE field_width : integer;                               -- field width
           VARIABLE string_type : CHARACTER;                             -- type of string specified by format
           VARIABLE arg_num     : INTEGER := 0;                          -- number of argument currently being read
           VARIABLE arg         : string(1 to MAX_STRING_LEN+1);         -- used to temporarily hold argument
           VARIABLE premature_end : BOOLEAN := FALSE;                    -- true if end of file reached prematurely
           VARIABLE t_follow      : string(1 to 5);                      -- checks for time_unit following %t
           VARIABLE ii, jj        : INTEGER;

    BEGIN
       -- make return strings empty
       arg1(arg1'left)   := NUL;
       arg2(arg2'left)   := NUL;
       arg3(arg3'left)   := NUL;
       arg4(arg4'left)   := NUL;
       arg5(arg5'left)   := NUL;
       arg6(arg6'left)   := NUL;
       arg7(arg7'left)   := NUL;
       arg8(arg8'left)   := NUL;
       arg9(arg9'left)   := NUL;
       arg10(arg10'left) := NUL;
       arg11(arg11'left) := NUL;
       arg12(arg12'left) := NUL;
       arg13(arg13'left) := NUL;
       arg14(arg14'left) := NUL;
       arg15(arg15'left) := NUL;
       arg16(arg16'left) := NUL;
       arg17(arg17'left) := NUL;
       arg18(arg18'left) := NUL;
       arg19(arg19'left) := NUL;
       arg20(arg20'left) := NUL;

       index := Find_NonBlank(fmt, index);
       fmt_len := StrLen(fmt);
       if ( index > fmt_len ) then
          assert FALSE
             report "fscan (ASCII_TEXT)  -- empty format string."
             severity ERROR;
          return;
       end if;

       eof := ENDFILE(file_ptr);

       while ( (not eof) and (index <= fmt_len) ) loop
       
          fchar := fmt(index);
          look_ahead := NUL;
          mismatch := FALSE;
          if (index < fmt_len) then
             look_ahead := fmt(index+1);
          else
             look_ahead := ' ';
          end if;

                    
          if ( (fchar = '\') and (look_ahead = 'n') ) then    --  \n
             if ( END_OF_LINE_MARKER = (LF, ' ') ) then
                scan_for_match (file_ptr, LF, eof, mismatch);
             else
                scan_for_match (file_ptr, CR, eof, mismatch);
             end if;
             index := index + 2;
          elsif ( (fchar = '%') and (look_ahead = '%') ) then -- check for literal %
             scan_for_match (file_ptr, '%', eof, mismatch);
             index := index + 2;
          elsif (fchar = '%') then
             if (arg_num = arg_count) then
                assert FALSE
                   report "fscan (ASCII_TEXT)  -- number of format specifications exceed argument count"
                   severity ERROR;
                return;
             end if;
             arg_num := arg_num + 1;
             field_width := 0;
             index := index + 1;
             if (is_digit(look_ahead)) then
                get_fw (fmt, index, field_width);
             end if;
             if (index <= fmt_len) then
                string_type := fmt(index);
                index := index + 1;
             else
                assert FALSE
                   report "fscan (ASCII_TEXT)  -- error in format specification"
                   severity ERROR;
                   return;
             end if;
             
             case string_type is
                when 'c'               =>  if (field_width = 0) then
                                              field_width := 1;
                                           end if;
                                           ii := 1;
                                           while (field_width > 0) loop
                                              ffgetc(ch, eof, file_ptr);
                                              exit when ( eof );
                                              arg(ii) := ch;
                                              ii := ii + 1;
                                              field_width := field_width - 1;
                                           end loop;
                                           arg(ii) := NUL;
                                           premature_end := ( eof and (ii = 1) );
                                              
                when 'd' | 'f' | 's' |
                     'o' | 'x' | 'X' | 
                     't'               =>  -- skip over time unit if it follows %t
                                           if ( string_type = 't') then
                                              t_follow := (others => ' ');
                                              ii := index;
                                              jj := 2;
                                              if ( (ii < fmt_len) and is_space(fmt(ii)) ) then
                                                 ii := ii + 1;
                                                 while ( (ii <= fmt_len) and (not is_space(fmt(ii))) and (jj <= 5) ) loop
                                                    t_follow(jj) := fmt(ii);
                                                    ii := ii + 1;
                                                    jj := jj + 1;
                                                 end loop;
                                                 if ( strcmp(t_follow, " fs  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " ps  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " ns  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " us  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " ms  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " sec ") = 0 ) then
                                                    index := index + 4;
                                                 elsif ( strcmp(t_follow, " min ") = 0 ) then
                                                    index := index + 4;
                                                 elsif ( strcmp(t_follow, " hr  ") = 0 ) then
                                                    index := index + 3;
                                                 end if;
                                              end if;
                                           end if;
                                           if ( field_width = 0 ) then
                                              field_width := MAX_STRING_LEN + 1;
                                           end if;
                                           ffgetc (ch, eof, file_ptr); -- skip over carrage return and line feed and spaces
                                           while ( (is_space(ch) or (ch = LF) or (ch = CR) ) and (not eof) ) loop
                                              ffgetc(ch, eof, file_ptr);
                                           end loop;
                                           ii := 1;
                                           loop
                                              exit when ( eof or is_space(ch) or (ch = LF) or (ch = CR) );
                                              arg(ii) := ch;
                                              ii := ii + 1;
                                              field_width := field_width - 1;
                                              exit when (field_width = 0);
                                              ffgetc(ch, eof, file_ptr);
                                           end loop;
                                           if ( (string_type = 't') and (not eof) and (field_width > 1) and (ch /= LF) and (ch /= CR) ) then
                                              arg(ii) := ' ';
                                              ii := ii + 1;
                                              field_width := field_width - 1;
                                              ffgetc(ch, eof, file_ptr);
                                              loop
                                                 exit when ( eof or is_space(ch) or (ch = LF) or (ch = CR) );
                                                 arg(ii) := ch;
                                                 ii := ii + 1;
                                                 field_width := field_width - 1;
                                                 exit when (field_width = 0);
                                                 ffgetc(ch, eof, file_ptr);
                                              end loop;
                                           end if;
                                           arg(ii) := NUL;
                                           premature_end := ( eof and (ii = 1) );

                when others            =>  assert FALSE
                                              report "fscan (ASCII_TEXT)  -- error in format specification"
                                              severity ERROR;
                                           return;
             end case;
             case arg_num is
                when 1       => strcpy(arg1,  arg);
                when 2       => strcpy(arg2,  arg);
                when 3       => strcpy(arg3,  arg);
                when 4       => strcpy(arg4,  arg);
                when 5       => strcpy(arg5,  arg);
                when 6       => strcpy(arg6,  arg);
                when 7       => strcpy(arg7,  arg);
                when 8       => strcpy(arg8,  arg);
                when 9       => strcpy(arg9,  arg);
                when 10      => strcpy(arg10, arg);
                when 11      => strcpy(arg11, arg);
                when 12      => strcpy(arg12, arg);
                when 13      => strcpy(arg13, arg);
                when 14      => strcpy(arg14, arg);
                when 15      => strcpy(arg15, arg);
                when 16      => strcpy(arg16, arg);
                when 17      => strcpy(arg17, arg);
                when 18      => strcpy(arg18, arg);
                when 19      => strcpy(arg19, arg);
                when 20      => strcpy(arg20, arg);
                when others  => assert FALSE
                                   report "fscan (ASCII_TEXT)  -- internal error"
                                   severity ERROR;
                                return;
             end case;
          else                     -- compare for literal
             scan_for_match (file_ptr, fchar, eof, mismatch);
             index := index + 1;
          end if;

          if (mismatch) then
             assert NOT WarningsOn
                report "fscan (ASCII_TEXT)  -- format string literal mismatch"
                severity WARNING;
             return;
          end if;
          
          index := Find_NonBlank(fmt, index);
       end loop;

       index := Find_NonBlank(fmt, index);
       assert ( not (WarningsOn and ( (eof and (index <= fmt_len)) or premature_end) ) )
          report "fscan (ASCII TEXT)  -- unexpected end of file"
          severity WARNING;
       

    END fscan;

          
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING ;
                         VARIABLE arg17         : OUT STRING ;
                         VARIABLE arg18         : OUT STRING ;
                         VARIABLE arg19         : OUT STRING 
                        ) IS
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
          fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
                arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16,
                arg17, arg18, arg19, dummy_arg20, 19);
          return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING ;
                         VARIABLE arg17         : OUT STRING ;
                         VARIABLE arg18         : OUT STRING 
                        ) IS
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;        
   BEGIN
     -- call procedure fscan with 20 arguments
          fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
                arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16,
                arg17, arg18, dummy_arg19, dummy_arg20, 18);
          return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING ;
                         VARIABLE arg17         : OUT STRING
                        ) IS
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
          fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
                arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16,
                arg17, dummy_arg18, dummy_arg19, dummy_arg20, 17);
          return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING
                        ) IS
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
          fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
                arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16,
                dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 16);
          return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING 
                        ) IS
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
             arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15,
             dummy_arg16, dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 15);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING
                        ) IS
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
              arg8, arg9, arg10, arg11, arg12, arg13, arg14, dummy_arg15,
              dummy_arg16, dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 14);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING
                        ) IS
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
             arg8, arg9, arg10, arg11, arg12, arg13,
             dummy_arg14, dummy_arg15, dummy_arg16,
             dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 13);
          return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING
                        ) IS
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
             arg8, arg9, arg10, arg11, arg12, 
             dummy_arg13, dummy_arg14, dummy_arg15, dummy_arg16,
             dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 12);
        return;
   END;
--|----------------------------------------------------------------------------
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING
                        ) IS
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
             arg8, arg9, arg10, arg11, dummy_arg12,
             dummy_arg13, dummy_arg14, dummy_arg15, dummy_arg16,
             dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 11);
        return;
   END;
--|----------------------------------------------------------------------------
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING 

                       ) IS
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
             arg8, arg9, arg10, dummy_arg11, dummy_arg12,
             dummy_arg13, dummy_arg14, dummy_arg15, dummy_arg16,
             dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 10);
        return;
   END;
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
                         VARIABLE arg9         : OUT STRING 
                        ) IS
        VARIABLE dummy_arg10         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
             arg8, arg9, dummy_arg10, dummy_arg11, dummy_arg12,
             dummy_arg13, dummy_arg14, dummy_arg15, dummy_arg16,
             dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 9);
        return;
   END;
--|----------------------------------------------------------------------------
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
                        ) IS
        VARIABLE dummy_arg9          :  STRING(1 TO 10);
        VARIABLE dummy_arg10         :  STRING(1 TO 10);
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
             arg8, dummy_arg9, dummy_arg10, dummy_arg11, dummy_arg12,
             dummy_arg13, dummy_arg14, dummy_arg15, dummy_arg16,
             dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 8);
        return;
   END;
--|----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING 
                        ) IS
        VARIABLE dummy_arg8         :  STRING(1 TO 10);
        VARIABLE dummy_arg9         :  STRING(1 TO 10);
        VARIABLE dummy_arg10         :  STRING(1 TO 10);
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6, arg7,
             dummy_arg8, dummy_arg9, dummy_arg10, dummy_arg11, dummy_arg12,
             dummy_arg13, dummy_arg14, dummy_arg15, dummy_arg16,
             dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 7);
        return;
   END;
--|----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING 
                        ) IS
        VARIABLE dummy_arg7         :  STRING(1 TO 10); 
        VARIABLE dummy_arg8         :  STRING(1 TO 10); 
        VARIABLE dummy_arg9         :  STRING(1 TO 10);
        VARIABLE dummy_arg10        :  STRING(1 TO 10);
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5, arg6,
             dummy_arg7, dummy_arg8, dummy_arg9, dummy_arg10,
             dummy_arg11, dummy_arg12, dummy_arg13, dummy_arg14, dummy_arg15,
             dummy_arg16, dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 6);
        return;
   END;
--|----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING 
                        ) IS
        VARIABLE dummy_arg6         :  STRING(1 TO 10); 
        VARIABLE dummy_arg7         :  STRING(1 TO 10);
        VARIABLE dummy_arg8         :  STRING(1 TO 10);
        VARIABLE dummy_arg9         :  STRING(1 TO 10);
        VARIABLE dummy_arg10         :  STRING(1 TO 10);
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  arg5,
             dummy_arg6, dummy_arg7, dummy_arg8, dummy_arg9, dummy_arg10,
             dummy_arg11, dummy_arg12, dummy_arg13, dummy_arg14, dummy_arg15,
             dummy_arg16, dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 5);
        return;
   END;
--|----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING 
                        ) IS
        VARIABLE dummy_arg5         :  STRING(1 TO 10);
        VARIABLE dummy_arg6         :  STRING(1 TO 10);
        VARIABLE dummy_arg7         :  STRING(1 TO 10); 
        VARIABLE dummy_arg8         :  STRING(1 TO 10);
        VARIABLE dummy_arg9         :  STRING(1 TO 10);
        VARIABLE dummy_arg10         :  STRING(1 TO 10);
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, arg4,  dummy_arg5,
             dummy_arg6, dummy_arg7, dummy_arg8, dummy_arg9, dummy_arg10,
             dummy_arg11, dummy_arg12, dummy_arg13, dummy_arg14, dummy_arg15,
             dummy_arg16, dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 4);
        return;
   END;
--|----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING 
                        ) IS
        VARIABLE dummy_arg4         :  STRING(1 TO 10);
        VARIABLE dummy_arg5         :  STRING(1 TO 10);
        VARIABLE dummy_arg6         :  STRING(1 TO 10);
        VARIABLE dummy_arg7         :  STRING(1 TO 10);
        VARIABLE dummy_arg8         :  STRING(1 TO 10);
        VARIABLE dummy_arg9         :  STRING(1 TO 10);
        VARIABLE dummy_arg10         :  STRING(1 TO 10);
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, arg3, dummy_arg4,  dummy_arg5,
             dummy_arg6, dummy_arg7, dummy_arg8, dummy_arg9, dummy_arg10,
             dummy_arg11, dummy_arg12, dummy_arg13, dummy_arg14, dummy_arg15,
             dummy_arg16, dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 3);
        return;
   END;
--|----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING 
                        ) IS
        VARIABLE dummy_arg3         :  STRING(1 TO 10);
        VARIABLE dummy_arg4         :  STRING(1 TO 10);
        VARIABLE dummy_arg5         :  STRING(1 TO 10);
        VARIABLE dummy_arg6         :  STRING(1 TO 10); 
        VARIABLE dummy_arg7         :  STRING(1 TO 10);
        VARIABLE dummy_arg8         :  STRING(1 TO 10);
        VARIABLE dummy_arg9         :  STRING(1 TO 10);
        VARIABLE dummy_arg10         :  STRING(1 TO 10);
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, arg2, dummy_arg3, dummy_arg4,
            dummy_arg5,dummy_arg6,dummy_arg7,dummy_arg8,dummy_arg9,dummy_arg10,
             dummy_arg11, dummy_arg12, dummy_arg13, dummy_arg14, dummy_arg15,
             dummy_arg16, dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 2);
        return;
   END;
--|----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN ASCII_TEXT;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING 
                        ) IS
        VARIABLE dummy_arg2         :  STRING(1 TO 10); 
        VARIABLE dummy_arg3         :  STRING(1 TO 10);
        VARIABLE dummy_arg4         :  STRING(1 TO 10);
        VARIABLE dummy_arg5         :  STRING(1 TO 10);
        VARIABLE dummy_arg6         :  STRING(1 TO 10); 
        VARIABLE dummy_arg7         :  STRING(1 TO 10);
        VARIABLE dummy_arg8         :  STRING(1 TO 10);
        VARIABLE dummy_arg9         :  STRING(1 TO 10);
        VARIABLE dummy_arg10         :  STRING(1 TO 10);
        VARIABLE dummy_arg11         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg12         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg13         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg14         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg15         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg16         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg17         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg18         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg19         :  STRING(1 TO 10);  -- dummy string;
        VARIABLE dummy_arg20         :  STRING(1 TO 10);  -- dummy string;
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, format, arg1, dummy_arg2, dummy_arg3, dummy_arg4,
            dummy_arg5,dummy_arg6,dummy_arg7,dummy_arg8,dummy_arg9,dummy_arg10,
             dummy_arg11, dummy_arg12, dummy_arg13, dummy_arg14, dummy_arg15,
             dummy_arg16, dummy_arg17, dummy_arg18, dummy_arg19, dummy_arg20, 1);
        return;
   END;


--+----------------------------------------------------------------------------- 
--|     Function Name  : ffgetc
--| 
--|     Overloading    : Text, ASCII_TEXT, string_buf
--|  
--|     Purpose        : to read the next character from a file
--|                      
--|
--|     Parameters     : result - output character  -- returned char
--|                      eof    - output BOOLEAN    -- TRUE if end of file reached
--|                      stream - in TEXT           -- file 
--|                      ptr    - inout line        -- line buffer
--|                      
--| 
--|     Result         : next character from the specified file.
--|                      returns LF if the end of the line is reached.
--|                      return with eof true if end of file is reached
--|                     
--|----------------------------------------------------------------------------- 

     PROCEDURE ffgetc    ( VARIABLE result : OUT CHARACTER;
                           VARIABLE eof    : OUT BOOLEAN;
                           VARIABLE stream : IN TEXT;
                           VARIABLE ptr    : INOUT LINE
                         ) IS

     BEGIN
        eof := FALSE;
        if ( ptr = NULL) then
           if ( not ENDFILE(stream) ) then
              READLINE(stream, ptr);
              read(ptr, result);
           else
              result := NUL;
              eof := TRUE;
           end if;
        elsif (  ptr.all'LENGTH = 0 ) then  -- vantage ENDLINE function does not compile
           if ( not ENDFILE(stream) ) then
              READLINE(stream, ptr);
              result := LF;
           else
              result := NUL;
              eof := TRUE;
           end if;
        else
           read(ptr, result);
        end if;
        return;
     END;
   
   
--+-----------------------------------------------------------------------------
--|     Procedure Name : scan_for_match
--|.hidden
--|     Overloading    : TEXT and ASCII_TEXT and string_buf
--|
--|     Purpose        : To scan file skipping over blank spaces and newline
--|                      characters until a non-whitespace character is found.
--|                      If that character matches match_char then mismatch is
--|                      return false otherwise its TRUE.
--|
--|     Parameters     : fptr       : IN TEXT
--|                      lptr       : INOUT LINE
--|                      match_char : IN CHARACTER
--|                      eof        : INOUT BOOLEAN
--|                      mismatch   : OUT BOOLEAN
--|
--|-----------------------------------------------------------------------------


   procedure scan_for_match ( VARIABLE fptr       : IN TEXT;
                              VARIABLE lptr       : INOUT LINE;
                              CONSTANT match_char : IN CHARACTER;
                              VARIABLE eof        : INOUT BOOLEAN;
                              VARIABLE mismatch   : OUT BOOLEAN ) is

      VARIABLE ch : CHARACTER;

   begin
      mismatch := FALSE;
      ffgetc (ch, eof, fptr, lptr);
      while ( (is_space(ch) or ( (ch = LF) and (match_char /= LF) ) ) and (not eof) ) loop
         ffgetc (ch, eof, fptr, lptr);
      end loop;
      if (not eof) then
         mismatch := (ch /= match_char);
      end if;
      return;
    end;
    
   
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
--|                         file_ptr      - input TEXT,
--|                         line_ptr      - input_output LINE,
--|                         format        - input STRING,
--|                         arg1          - output STRING,
--|                         arg2          - output STRING,
--|                         arg3          - output STRING,
--|                         arg4          - output STRING,
--|                         arg5          - output STRING,
--|                         arg6          - output STRING,
--|                         arg7          - output STRING,
--|                         arg8          - output STRING,
--|                         arg9          - output STRING,
--|                         arg10         - output STRING
--|                         arg11         - output STRING,
--|                         arg12         - output STRING,
--|                         arg13         - output STRING,
--|                         arg14         - output STRING,
--|                         arg15         - output STRING,
--|                         arg16         - output STRING,
--|                         arg17         - output STRING,
--|                         arg18         - output STRING,
--|                         arg19         - output STRING,
--|                         arg20         - output STRING
--|                         arg_count     - input integer,  -- # of arguments in calling procedure
--|
--|     Result         : STRING  representation given TEXT.
--|
--|     Note:          This procedure extracts upto twenty arguments
--|                    from a line in a file.
--|                    If a %s(or whatever) is used without a digit then a space
--|                    must the string in the file inorder for the next argument to
--|                    be read in or for a match with the next literal to occur properly
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
                        ) IS
           VARIABLE fmt         : STRING(1 TO format'LENGTH) := format;  -- hold format
           VARIABLE index       : INTEGER := 1;                          -- index into fmt
           VARIABLE fmt_len     : INTEGER;                               -- length of format
           VARIABLE ch          : CHARACTER;                             -- present character read from file
           VARIABLE fchar       : CHARACTER;                             -- present format character
           VARIABLE look_ahead  : CHARACTER;                             -- next format character
           VARIABLE mismatch    : BOOLEAN := FALSE;                      -- TRUE if mismatch between format literal
                                                                         --    and file character
           VARIABLE eof         : BOOLEAN := FALSE;                      -- TRUE if end of file
           VARIABLE field_width : integer;                               -- field width
           VARIABLE string_type : CHARACTER;                             -- type of string specified by format
           VARIABLE arg_num     : INTEGER := 0;                          -- number of argument currently being read
           VARIABLE arg         : string(1 to MAX_STRING_LEN+1);         -- used to temporarily hold argument
           VARIABLE premature_end : BOOLEAN := FALSE;                    -- true if end of file reached prematurely
           VARIABLE t_follow      : string(1 to 5);                      -- used to check for time unit following %t
           VARIABLE ii, jj        : INTEGER;

    BEGIN
       -- make return strings empty
       arg1(arg1'left)   := NUL;
       arg2(arg2'left)   := NUL;
       arg3(arg3'left)   := NUL;
       arg4(arg4'left)   := NUL;
       arg5(arg5'left)   := NUL;
       arg6(arg6'left)   := NUL;
       arg7(arg7'left)   := NUL;
       arg8(arg8'left)   := NUL;
       arg9(arg9'left)   := NUL;
       arg10(arg10'left) := NUL;
       arg11(arg11'left) := NUL;
       arg12(arg12'left) := NUL;
       arg13(arg13'left) := NUL;
       arg14(arg14'left) := NUL;
       arg15(arg15'left) := NUL;
       arg16(arg16'left) := NUL;
       arg17(arg17'left) := NUL;
       arg18(arg18'left) := NUL;
       arg19(arg19'left) := NUL;
       arg20(arg20'left) := NUL;

       index := Find_NonBlank(fmt, index);
       fmt_len := StrLen(fmt);
       if ( index > fmt_len ) then
          assert FALSE
             report "fscan (TEXT)  -- empty format string."
             severity ERROR;
          return;
       end if;

       eof := ENDFILE(file_ptr) and ( (line_ptr = NULL) or (line_ptr.all'LENGTH = 0) );  -- vantage ENDLINE function does not compile

       while ( (not eof) and (index <= fmt_len) ) loop
       
          fchar := fmt(index);
          look_ahead := NUL;
          mismatch := FALSE;
          if (index < fmt_len) then
             look_ahead := fmt(index+1);
          else
             look_ahead := ' ';
          end if;

                    
          if ( (fchar = '\') and (look_ahead = 'n') ) then    --  \n
             scan_for_match (file_ptr, line_ptr, LF, eof, mismatch);
             index := index + 2;
          elsif ( (fchar = '%') and (look_ahead = '%') ) then -- check for literal %
             scan_for_match (file_ptr, line_ptr, '%', eof, mismatch);
             index := index + 2;
          elsif (fchar = '%') then
             if (arg_num = arg_count) then
                assert FALSE
                   report "fscan (TEXT)  -- number of format specifications exceed argument count"
                   severity ERROR;
                return;
             end if;
             arg_num := arg_num + 1;
             field_width := 0;
             index := index + 1;
             if (is_digit(look_ahead)) then
                get_fw (fmt, index, field_width);
             end if;
             if (index <= fmt_len) then
                string_type := fmt(index);
                index := index + 1;
             else
                assert FALSE
                   report "fscan (TEXT)  -- error in format specification"
                   severity ERROR;
                   return;
             end if;
             
             case string_type is
                when 'c'               =>  if (field_width = 0) then
                                              field_width := 1;
                                           end if;
                                           ii := 1;
                                           while (field_width > 0) loop
                                              ffgetc(ch, eof, file_ptr, line_ptr);
                                              exit when ( eof );
                                              arg(ii) := ch;
                                              ii := ii + 1;
                                              field_width := field_width - 1;
                                           end loop;
                                           arg(ii) := NUL;
                                           premature_end := ( eof and (ii = 1) );
                                              
                when 'd' | 'f' | 's' |
                     'o' | 'x' | 'X' | 
                     't'               =>  -- skip over time unit if it follows %t
                                           if ( string_type = 't') then
                                              t_follow := (others => ' ');
                                              ii := index;
                                              jj := 2;
                                              if ( (ii < fmt_len) and is_space(fmt(ii)) ) then
                                                 ii := ii + 1;
                                                 while ( (ii <= fmt_len) and (not is_space(fmt(ii))) and (jj <= 5) ) loop
                                                    t_follow(jj) := fmt(ii);
                                                    ii := ii + 1;
                                                    jj := jj + 1;
                                                 end loop;
                                                 if ( strcmp(t_follow, " fs  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " ps  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " ns  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " us  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " ms  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " sec ") = 0 ) then
                                                    index := index + 4;
                                                 elsif ( strcmp(t_follow, " min ") = 0 ) then
                                                    index := index + 4;
                                                 elsif ( strcmp(t_follow, " hr  ") = 0 ) then
                                                    index := index + 3;
                                                 end if;
                                              end if;
                                           end if;
                                           if ( field_width = 0 ) then
                                              field_width := MAX_STRING_LEN + 1;
                                           end if;
                                           ffgetc (ch, eof, file_ptr, line_ptr);
                                           while ( (is_space(ch) or (ch = LF) ) and (not eof) ) loop
                                              ffgetc(ch, eof, file_ptr, line_ptr);
                                           end loop;
                                           ii := 1;
                                           loop
                                              exit when ( eof or is_space(ch) or (ch = LF) );
                                              arg(ii) := ch;
                                              ii := ii + 1;
                                              field_width := field_width - 1;
                                              exit when (field_width = 0);
                                              ffgetc(ch, eof, file_ptr, line_ptr);
                                           end loop;
                                           if ( (string_type = 't') and (not eof) and (field_width > 1) and (ch /= LF) ) then
                                              arg(ii) := ' ';
                                              ii := ii + 1;
                                              field_width := field_width - 1;
                                              ffgetc(ch, eof, file_ptr, line_ptr);
                                              loop
                                                 exit when ( eof or is_space(ch) or (ch = LF) );
                                                 arg(ii) := ch;
                                                 ii := ii + 1;
                                                 field_width := field_width - 1;
                                                 exit when (field_width = 0);
                                                 ffgetc(ch, eof, file_ptr, line_ptr);
                                              end loop;
                                           end if;
                                           arg(ii) := NUL;
                                           premature_end := ( eof and (ii = 1) );

                when others            =>  assert FALSE
                                              report "fscan (TEXT)  -- error in format specification"
                                              severity ERROR;
                                           return;
             end case;
             case arg_num is
                when 1       => strcpy(arg1,  arg);
                when 2       => strcpy(arg2,  arg);
                when 3       => strcpy(arg3,  arg);
                when 4       => strcpy(arg4,  arg);
                when 5       => strcpy(arg5,  arg);
                when 6       => strcpy(arg6,  arg);
                when 7       => strcpy(arg7,  arg);
                when 8       => strcpy(arg8,  arg);
                when 9       => strcpy(arg9,  arg);
                when 10      => strcpy(arg10, arg);
                when 11      => strcpy(arg11, arg);
                when 12      => strcpy(arg12, arg);
                when 13      => strcpy(arg13, arg);
                when 14      => strcpy(arg14, arg);
                when 15      => strcpy(arg15, arg);
                when 16      => strcpy(arg16, arg);
                when 17      => strcpy(arg17, arg);
                when 18      => strcpy(arg18, arg);
                when 19      => strcpy(arg19, arg);
                when 20      => strcpy(arg20, arg);
                when others  => assert FALSE
                                   report "fscan (TEXT)  -- internal error"
                                   severity ERROR;
                                return;
             end case;
          else                     -- compare for literal
             scan_for_match (file_ptr, line_ptr, fchar, eof, mismatch);
             index := index + 1;
          end if;

          if (mismatch) then
             assert NOT WarningsOn
                report "fscan (TEXT)  -- format string literal mismatch"
                severity WARNING;
             return;
          end if;
          
          index := Find_NonBlank(fmt, index);
       end loop;

       index := Find_NonBlank(fmt, index);
       assert ( not (WarningsOn and ( (eof and (index <= fmt_len)) or premature_end) ) )
          report "fscan (TEXT)  -- unexpected end of file"
          severity WARNING;
       
    END fscan;

--|----------------------------------------------------------------------------
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING ;
                         VARIABLE arg17         : OUT STRING ;
                         VARIABLE arg18         : OUT STRING ;
                         VARIABLE arg19         : OUT STRING 
                        ) IS
        VARIABLE dumy_arg20         :  STRING(1 TO 10);
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, arg16, arg17, arg18,
              arg19, dumy_arg20, 19);
        return;
   END fscan;
--|----------------------------------------------------------------------------
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING ;
                         VARIABLE arg17         : OUT STRING ;
                         VARIABLE arg18         : OUT STRING 
                       ) IS
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);        
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, arg16, arg17, arg18,
              dumy_arg19, dumy_arg20, 18);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING ;
                         VARIABLE arg17         : OUT STRING 
                        ) IS
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, arg16, arg17, dumy_arg18,
              dumy_arg19, dumy_arg20, 17);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING 
                        ) IS
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);        
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, arg16, dumy_arg17, dumy_arg18,
              dumy_arg19, dumy_arg20, 16);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING
                        ) IS
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, dumy_arg16, dumy_arg17,
              dumy_arg18, dumy_arg19, dumy_arg20, 15);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING
                        ) IS
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 14);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING 
                        ) IS
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 13);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING
                        ) IS
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);                
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 12);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING
                        ) IS
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);                        
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, dumy_arg12,
              dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 11);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING
                        ) IS
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, dumy_arg11,
              dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 10);
        return;
   END;
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
                         VARIABLE arg9          : OUT STRING
                        ) IS
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);        
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, dumy_arg10, dumy_arg11,
              dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 9);
        return;
   END;
--|----------------------------------------------------------------------------
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
                        ) IS
        VARIABLE dumy_arg9          :  STRING(1 TO 10); 
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);        
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, dumy_arg9, dumy_arg10, dumy_arg11,
              dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 8);
        return;
   END;
--|---------------------------------------------------------------------------
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
                        ) IS
        VARIABLE dumy_arg8          :  STRING(1 TO 10);
        VARIABLE dumy_arg9          :  STRING(1 TO 10); 
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);        
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, dumy_arg8, dumy_arg9, dumy_arg10, dumy_arg11,
              dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 7);
        return;
   END;
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
                        ) IS
        VARIABLE dumy_arg7          :  STRING(1 TO 10);
        VARIABLE dumy_arg8          :  STRING(1 TO 10);
        VARIABLE dumy_arg9          :  STRING(1 TO 10); 
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);        
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 6);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg6          :  STRING(1 TO 10); 
        VARIABLE dumy_arg7          :  STRING(1 TO 10);
        VARIABLE dumy_arg8          :  STRING(1 TO 10);
        VARIABLE dumy_arg9          :  STRING(1 TO 10); 
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);        
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 5);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg5          :  STRING(1 TO 10);
        VARIABLE dumy_arg6          :  STRING(1 TO 10); 
        VARIABLE dumy_arg7          :  STRING(1 TO 10);
        VARIABLE dumy_arg8          :  STRING(1 TO 10);
        VARIABLE dumy_arg9          :  STRING(1 TO 10); 
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);        
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, arg4, 
              dumy_arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 4);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg4          :  STRING(1 TO 10);
        VARIABLE dumy_arg5          :  STRING(1 TO 10);
        VARIABLE dumy_arg6          :  STRING(1 TO 10); 
        VARIABLE dumy_arg7          :  STRING(1 TO 10);
        VARIABLE dumy_arg8          :  STRING(1 TO 10);
        VARIABLE dumy_arg9          :  STRING(1 TO 10); 
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);        
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, arg3, dumy_arg4, 
              dumy_arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 3);
        return;
   END;



--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg3         :  STRING(1 TO 10);
        VARIABLE dumy_arg4          :  STRING(1 TO 10);
        VARIABLE dumy_arg5          :  STRING(1 TO 10);
        VARIABLE dumy_arg6          :  STRING(1 TO 10); 
        VARIABLE dumy_arg7          :  STRING(1 TO 10);
        VARIABLE dumy_arg8          :  STRING(1 TO 10);
        VARIABLE dumy_arg9          :  STRING(1 TO 10); 
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);        
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, arg2, dumy_arg3, dumy_arg4, 
              dumy_arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 2);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   VARIABLE file_ptr      : IN TEXT;
                         VARIABLE line_ptr      : INOUT LINE;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg2          :  STRING(1 TO 10); 
        VARIABLE dumy_arg3          :  STRING(1 TO 10);
        VARIABLE dumy_arg4          :  STRING(1 TO 10);
        VARIABLE dumy_arg5          :  STRING(1 TO 10);
        VARIABLE dumy_arg6          :  STRING(1 TO 10); 
        VARIABLE dumy_arg7          :  STRING(1 TO 10);
        VARIABLE dumy_arg8          :  STRING(1 TO 10);
        VARIABLE dumy_arg9          :  STRING(1 TO 10); 
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);        
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(file_ptr, line_ptr, format, arg1, dumy_arg2, dumy_arg3, dumy_arg4, 
              dumy_arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 1);
        return;
   END;


--+----------------------------------------------------------------------------- 
--|     Function Name  : ffgetc
--| 
--|     Overloading    : Text, ASCII_TEXT, string_buf
--|  
--|     Purpose        : to read the next character from a file
--|                      
--|
--|     Parameters     : result - output character  -- returned char
--|                      eof    - output BOOLEAN    -- TRUE if end of file reached
--|                      stream - in string         -- file
--|                      ptr    - inout INTEGER     -- index into string buf
--|                      
--|     Notes          : returns with eof true if end of string is reached
--|                    : assumes a string starting at an index of 1
--|
--|----------------------------------------------------------------------------- 

     PROCEDURE ffgetc    ( VARIABLE result : OUT CHARACTER;
                           VARIABLE eof    : OUT BOOLEAN;
                           VARIABLE stream : IN STRING;
                           VARIABLE ptr    : INOUT INTEGER
                         ) IS

        VARIABLE end_file : BOOLEAN;  -- refers to end of string

     BEGIN
        end_file := ( (ptr > stream'LENGTH) or (stream(ptr) = NUL) );
        if (not end_file) then
           result := stream(ptr);
           ptr := ptr + 1;
        end if;
        eof := end_file;
        return;
     END;
   

--+-----------------------------------------------------------------------------
--|     Procedure Name : scan_for_match
--|.hidden
--|     Overloading    : TEXT and ASCII_TEXT and string_buf
--|
--|     Purpose        : To scan file skipping over blank spaces and newline
--|                      characters until a non-whitespace character is found.
--|                      If that character matches match_char then mismatch is
--|                      return false otherwise its TRUE.
--|
--|                      handles all three END_OF_LINE_MARKERS (LF, CR, and CR & LF)
--|
--|     Parameters     : str        : IN STRING
--|                      ptr        : INOUT INTEGER
--|                      match_char : IN CHARACTER
--|                      eof        : INOUT BOOLEAN
--|                      mismatch   : OUT BOOLEAN
--|
--|-----------------------------------------------------------------------------


   procedure scan_for_match ( VARIABLE str        : IN STRING;
                              VARIABLE ptr        : INOUT INTEGER;
                              CONSTANT match_char : IN CHARACTER;
                              VARIABLE eof        : INOUT BOOLEAN;
                              VARIABLE mismatch   : OUT BOOLEAN ) is

      VARIABLE ch : CHARACTER;
      VARIABLE cont : BOOLEAN;

   begin
      if ( END_OF_LINE_MARKER = (LF, ' ') ) then
         mismatch := FALSE;
         ffgetc (ch, eof, str, ptr);
         while ( (is_space(ch) or ( (ch = LF) and (match_char /= LF) ) ) and (not eof) ) loop
            ffgetc (ch, eof, str, ptr);
         end loop;
         if (not eof) then
            mismatch := (ch /= match_char);
         end if;
      elsif ( END_OF_LINE_MARKER = (CR, ' ') ) then
         mismatch := FALSE;
         ffgetc (ch, eof, str, ptr);
         while ( (is_space(ch) or ( (ch = CR) and (match_char /= CR) ) ) and (not eof) ) loop
            ffgetc (ch, eof, str, ptr);
         end loop;
         if (not eof) then
            mismatch := (ch /= match_char);
         end if;
      else  -- END_OF_LINE_MARKER = CR & LF
         mismatch := FALSE;
         cont := TRUE;
         ffgetc (ch, eof, str, ptr);
         while ( cont ) loop
            while ( (is_space(ch) or ( ( (ch = CR) or (ch = LF) ) and (match_char /= CR) ) ) and (not eof) ) loop
               ffgetc (ch, eof, str, ptr);
            end loop;
            CONT := FALSE;
            if ( (match_char = CR) and (ch = CR) ) then
               ffgetc(ch, eof, str, ptr);
               cont := (ch /= LF);
               if (not cont) then
                  return;
               end if;  
            end if;
         end loop;
         if (not eof) then
            mismatch := (ch /= match_char);
         end if;
      end if;
      return;
    end;

    

   
--+-----------------------------------------------------------------------------
--|     Function Name  : fscan
--| 1.2.4
--|     Overloading    : TEXT, ASCII_TEXT, and string_buf
--|
--|     Purpose        : To read text from a string buffer according to
--|                      specifications given by a format string and save
--|                      the result into corresponding  arguments.
--|
--|     Parameters     :
--|                         string_buf    - input string,
--|                         format        - input STRING,
--|                         arg1          - output STRING,
--|                         arg2          - output STRING,
--|                         arg3          - output STRING,
--|                         arg4          - output STRING,
--|                         arg5          - output STRING,
--|                         arg6          - output STRING,
--|                         arg7          - output STRING,
--|                         arg8          - output STRING,
--|                         arg9          - output STRING,
--|                         arg10         - output STRING
--|                         arg11         - output STRING,
--|                         arg12         - output STRING,
--|                         arg13         - output STRING,
--|                         arg14         - output STRING,
--|                         arg15         - output STRING,
--|                         arg16         - output STRING,
--|                         arg17         - output STRING,
--|                         arg18         - output STRING,
--|                         arg91         - output STRING,
--|                         arg20         - output STRING,
--|                         arg_count     - input INTEGER  -  number of argumetns passed to fscan
--|
--|     Result         : STRING  representation given TEXT.
--|
--|     Note:          This procedure extracts upto twenty arguments
--|                    from a string buffer.
--|
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf     : IN STRING;
                         CONSTANT format         : IN STRING;
                         VARIABLE arg1           : OUT STRING;
                         VARIABLE arg2           : OUT STRING;
                         VARIABLE arg3           : OUT STRING;
                         VARIABLE arg4           : OUT STRING;
                         VARIABLE arg5           : OUT STRING;
                         VARIABLE arg6           : OUT STRING;
                         VARIABLE arg7           : OUT STRING;
                         VARIABLE arg8           : OUT STRING;
                         VARIABLE arg9           : OUT STRING;
                         VARIABLE arg10          : OUT STRING;
                         VARIABLE arg11          : OUT STRING;
                         VARIABLE arg12          : OUT STRING;
                         VARIABLE arg13          : OUT STRING;
                         VARIABLE arg14          : OUT STRING;
                         VARIABLE arg15          : OUT STRING;
                         VARIABLE arg16          : OUT STRING;
                         VARIABLE arg17          : OUT STRING;
                         VARIABLE arg18          : OUT STRING;
                         VARIABLE arg19          : OUT STRING;
                         VARIABLE arg20          : OUT STRING;
                         CONSTANT arg_count       : IN INTEGER := 20
                        ) IS
           VARIABLE str_buffer  : STRING(1 TO string_buf'LENGTH) := string_buf;  -- hold string buffer
           VARIABLE fmt         : STRING(1 TO format'LENGTH) := format;          -- hold format
           VARIABLE index       : INTEGER := 1;                                  -- index into fmt
           VARIABLE str_indx    : INTEGER := 1;                                  -- index into str_buffer
           VARIABLE fmt_len     : INTEGER;                                       -- length of format
           VARIABLE ch          : CHARACTER;                                     -- present character read from string buffer
           VARIABLE fchar       : CHARACTER;                                     -- present format character
           VARIABLE look_ahead  : CHARACTER;                                     -- next format character
           VARIABLE mismatch    : BOOLEAN := FALSE;                              -- TRUE if mismatch between format literal
                                                                                 --    and string buffer character
           VARIABLE eof         : BOOLEAN := FALSE;                              -- TRUE if end of string buffer
           VARIABLE field_width : integer;                                       -- field width
           VARIABLE string_type : CHARACTER;                                     -- type of string specified by format
           VARIABLE arg_num     : INTEGER := 0;                                  -- number of argument currently being read
           VARIABLE arg         : string(1 to MAX_STRING_LEN+1);                 -- used to temporarily hold argument
           VARIABLE premature_end : BOOLEAN := FALSE;                            -- true if end of string buffer reached prematurely
           VARIABLE t_follow      : string(1 to 5);                              -- used to check for time unit following %t
           VARIABLE ii, jj        : INTEGER;

    BEGIN
       -- make return strings empty
       arg1(arg1'left)   := NUL;
       arg2(arg2'left)   := NUL;
       arg3(arg3'left)   := NUL;
       arg4(arg4'left)   := NUL;
       arg5(arg5'left)   := NUL;
       arg6(arg6'left)   := NUL;
       arg7(arg7'left)   := NUL;
       arg8(arg8'left)   := NUL;
       arg9(arg9'left)   := NUL;
       arg10(arg10'left) := NUL;
       arg11(arg11'left) := NUL;
       arg12(arg12'left) := NUL;
       arg13(arg13'left) := NUL;
       arg14(arg14'left) := NUL;
       arg15(arg15'left) := NUL;
       arg16(arg16'left) := NUL;
       arg17(arg17'left) := NUL;
       arg18(arg18'left) := NUL;
       arg19(arg19'left) := NUL;
       arg20(arg20'left) := NUL;

       index := Find_NonBlank(fmt, index);
       fmt_len := StrLen(fmt);
       if ( index > fmt_len ) then
          assert FALSE
             report "fscan (String Buffer)  -- empty format string."
             severity ERROR;
          return;
       end if;

       eof := ( (str_indx > str_buffer'length) or (str_buffer(str_indx) = NUL) );

       while ( (not eof) and (index <= fmt_len) ) loop
       
          fchar := fmt(index);
          look_ahead := NUL;
          mismatch := FALSE;
          if (index < fmt_len) then
             look_ahead := fmt(index+1);
          else
             look_ahead := ' ';
          end if;

                    
          if ( (fchar = '\') and (look_ahead = 'n') ) then    --  \n
             if ( END_OF_LINE_MARKER = (LF, ' ') ) then
                scan_for_match (str_buffer, str_indx, LF, eof, mismatch);
             else
                scan_for_match (str_buffer, str_indx, CR, eof, mismatch);
             end if;
             index := index + 2;
          elsif ( (fchar = '%') and (look_ahead = '%') ) then -- check for literal %
             scan_for_match (str_buffer, str_indx, '%', eof, mismatch);
             index := index + 2;
          elsif (fchar = '%') then
             if (arg_num = arg_count) then
                assert FALSE
                   report "fscan (String Buffer)  -- number of format specifications exceed argument count"
                   severity ERROR;
                return;
             end if;
             arg_num := arg_num + 1;
             field_width := 0;
             index := index + 1;
             if (is_digit(look_ahead)) then
                get_fw (fmt, index, field_width);
             end if;
             if (index <= fmt_len) then
                string_type := fmt(index);
                index := index + 1;
             else
                assert FALSE
                   report "fscan (String Buffer)  -- error in format specification"
                   severity ERROR;
                   return;
             end if;
             
             case string_type is
                when 'c'               =>  if (field_width = 0) then
                                              field_width := 1;
                                           end if;
                                           ii := 1;
                                           while (field_width > 0) loop
                                              ffgetc(ch, eof, str_buffer, str_indx);
                                              exit when ( eof );
                                              arg(ii) := ch;
                                              ii := ii + 1;
                                              field_width := field_width - 1;
                                           end loop;
                                           arg(ii) := NUL;
                                           premature_end :=  (eof and (ii = 1) );
                                           
                when 'd' | 'f' | 's' |
                     'o' | 'x' | 'X' | 
                     't'               =>  -- skip over time unit if it follows %t
                                           if ( string_type = 't') then
                                              t_follow := (others => ' ');
                                              ii := index;
                                              jj := 2;
                                              if ( (ii < fmt_len) and is_space(fmt(ii)) ) then
                                                 ii := ii + 1;
                                                 while ( (ii <= fmt_len) and (not is_space(fmt(ii))) and (jj <= 5) ) loop
                                                    t_follow(jj) := fmt(ii);
                                                    ii := ii + 1;
                                                    jj := jj + 1;
                                                 end loop;
                                                 if ( strcmp(t_follow, " fs  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " ps  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " ns  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " us  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " ms  ") = 0 ) then
                                                    index := index + 3;
                                                 elsif ( strcmp(t_follow, " sec ") = 0 ) then
                                                    index := index + 4;
                                                 elsif ( strcmp(t_follow, " min ") = 0 ) then
                                                    index := index + 4;
                                                 elsif ( strcmp(t_follow, " hr  ") = 0 ) then
                                                    index := index + 3;
                                                 end if;
                                              end if;
                                           end if;
                                           if ( field_width = 0 ) then
                                              field_width := MAX_STRING_LEN + 1;
                                           end if;
                                           ffgetc (ch, eof, str_buffer, str_indx); -- skip over carrage return and line feed and spaces
                                           while ( (is_space(ch) or (ch = LF) or (ch = CR) ) and (not eof) ) loop
                                              ffgetc(ch, eof, str_buffer, str_indx);
                                           end loop;
                                           ii := 1;
                                           loop
                                              exit when ( eof or is_space(ch) or (ch = LF) or (ch = CR) );
                                              arg(ii) := ch;
                                              ii := ii + 1;
                                              field_width := field_width - 1;
                                              exit when (field_width = 0);
                                              ffgetc(ch, eof, str_buffer, str_indx);
                                           end loop;
                                           if ( (string_type = 't') and (not eof) and (field_width > 1) and (ch /= LF) and (ch /= CR) ) then
                                              arg(ii) := ' ';
                                              ii := ii + 1;
                                              field_width := field_width - 1;
                                              ffgetc(ch, eof, str_buffer, str_indx);
                                              loop
                                                 exit when ( eof or is_space(ch) or (ch = LF) or (ch = CR) );
                                                 arg(ii) := ch;
                                                 ii := ii + 1;
                                                 field_width := field_width - 1;
                                                 exit when (field_width = 0);
                                                 ffgetc(ch, eof, str_buffer, str_indx);
                                              end loop;
                                           end if;
                                           arg(ii) := NUL;
                                           premature_end := ( eof and (ii = 1) );

                when others            =>  assert FALSE
                                              report "fscan (String Buffer)  -- error in format specification"
                                              severity ERROR;
                                           return;
             end case;
             case arg_num is
                when 1       => strcpy(arg1,  arg);
                when 2       => strcpy(arg2,  arg);
                when 3       => strcpy(arg3,  arg);
                when 4       => strcpy(arg4,  arg);
                when 5       => strcpy(arg5,  arg);
                when 6       => strcpy(arg6,  arg);
                when 7       => strcpy(arg7,  arg);
                when 8       => strcpy(arg8,  arg);
                when 9       => strcpy(arg9,  arg);
                when 10      => strcpy(arg10, arg);
                when 11      => strcpy(arg11, arg);
                when 12      => strcpy(arg12, arg);
                when 13      => strcpy(arg13, arg);
                when 14      => strcpy(arg14, arg);
                when 15      => strcpy(arg15, arg);
                when 16      => strcpy(arg16, arg);
                when 17      => strcpy(arg17, arg);
                when 18      => strcpy(arg18, arg);
                when 19      => strcpy(arg19, arg);
                when 20      => strcpy(arg20, arg);
                when others  => assert FALSE
                                   report "fscan (String Buffer)  -- internal error"
                                   severity ERROR;
                                return;
             end case;
          else                     -- compare for literal
             scan_for_match (str_buffer, str_indx, fchar, eof, mismatch);
             index := index + 1;
          end if;

          if (mismatch) then
             assert NOT WarningsOn
                report "fscan (String Buffer)  -- format string literal mismatch"
                severity WARNING;
             return;
          end if;
          
          index := Find_NonBlank(fmt, index);
       end loop;

       index := Find_NonBlank(fmt, index);
       assert ( not (WarningsOn and ( (eof and (index <= fmt_len)) or premature_end) ) )
          report "fscan (String BUffer)  -- unexpected end of string"
          severity WARNING;

    END fscan;

                        
--|---------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf      : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING ;
                         VARIABLE arg17         : OUT STRING ;
                         VARIABLE arg18         : OUT STRING ;
                         VARIABLE arg19         : OUT STRING
                       ) IS
        VARIABLE dumy_arg20         :  STRING(1 TO 10);        
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, arg16, arg17, arg18,
              arg19, dumy_arg20, 19);
        return;
   END;
--|---------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf      : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING ;
                         VARIABLE arg17         : OUT STRING ;
                         VARIABLE arg18         : OUT STRING 
                       ) IS
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);        
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, arg16, arg17, arg18,
              dumy_arg19, dumy_arg20, 18);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf      : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING ;
                         VARIABLE arg17         : OUT STRING 
                        ) IS
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, arg16, arg17, dumy_arg18,
              dumy_arg19, dumy_arg20, 17);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf      : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING ;
                         VARIABLE arg16         : OUT STRING 
                        ) IS
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);        
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, arg16, dumy_arg17, dumy_arg18,
              dumy_arg19, dumy_arg20, 16);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf      : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING ;
                         VARIABLE arg15         : OUT STRING
                        ) IS
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, arg15, dumy_arg16, dumy_arg17,
              dumy_arg18, dumy_arg19, dumy_arg20, 15);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf      : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING ;
                         VARIABLE arg14         : OUT STRING
                        ) IS
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 14);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf      : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING ;
                         VARIABLE arg13         : OUT STRING 
                        ) IS
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 13);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf      : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING ;
                         VARIABLE arg12         : OUT STRING
                        ) IS
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);                
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12,
              dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 12);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING ;
                         VARIABLE arg11         : OUT STRING
                        ) IS
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);                        
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, arg11, dumy_arg12,
              dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 11);
        return;
   END;
--|-----------------------------------------------------------------------------
   PROCEDURE fscan   (   CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING ;
                         VARIABLE arg8          : OUT STRING ;
                         VARIABLE arg9          : OUT STRING ;
                         VARIABLE arg10         : OUT STRING
                        ) IS
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, arg10, dumy_arg11,
              dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 10);
        return;
   END;
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
                        ) IS
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, arg9, dumy_arg10, dumy_arg11,
              dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 9);
        return;
   END;
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
                        ) IS
        VARIABLE dumy_arg9         :  STRING(1 TO 10);
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, arg8, dumy_arg9, dumy_arg10, dumy_arg11,
              dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 8);
        return;
   END;
--|----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING ;
                         VARIABLE arg7          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg8         :  STRING(1 TO 10);
        VARIABLE dumy_arg9         :  STRING(1 TO 10);
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, arg7, dumy_arg8, dumy_arg9, dumy_arg10, dumy_arg11,
              dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15, dumy_arg16,
              dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 7);
        return;
   END;
--|----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING ;
                         VARIABLE arg6          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg7         :  STRING(1 TO 10);
        VARIABLE dumy_arg8         :  STRING(1 TO 10);
        VARIABLE dumy_arg9         :  STRING(1 TO 10);
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 6);
        return;
   END;
--|-----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING ;
                         VARIABLE arg5          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg6         :  STRING(1 TO 10); 
        VARIABLE dumy_arg7         :  STRING(1 TO 10);
        VARIABLE dumy_arg8         :  STRING(1 TO 10);
        VARIABLE dumy_arg9         :  STRING(1 TO 10);
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 5);
        return;
   END;
--|----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING ;
                         VARIABLE arg4          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg5         :  STRING(1 TO 10);
        VARIABLE dumy_arg6         :  STRING(1 TO 10); 
        VARIABLE dumy_arg7         :  STRING(1 TO 10);
        VARIABLE dumy_arg8         :  STRING(1 TO 10);
        VARIABLE dumy_arg9         :  STRING(1 TO 10);
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, arg4, 
              dumy_arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 4);
        return;
   END;
--|----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING ;
                         VARIABLE arg3          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg4         :  STRING(1 TO 10);
        VARIABLE dumy_arg5         :  STRING(1 TO 10);
        VARIABLE dumy_arg6         :  STRING(1 TO 10); 
        VARIABLE dumy_arg7         :  STRING(1 TO 10);
        VARIABLE dumy_arg8         :  STRING(1 TO 10);
        VARIABLE dumy_arg9         :  STRING(1 TO 10);
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, arg3, dumy_arg4, 
              dumy_arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 3);
        return;
   END;
--|----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING ;
                         VARIABLE arg2          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg3         :  STRING(1 TO 10);
        VARIABLE dumy_arg4         :  STRING(1 TO 10);
        VARIABLE dumy_arg5         :  STRING(1 TO 10);
        VARIABLE dumy_arg6         :  STRING(1 TO 10); 
        VARIABLE dumy_arg7         :  STRING(1 TO 10);
        VARIABLE dumy_arg8         :  STRING(1 TO 10);
        VARIABLE dumy_arg9         :  STRING(1 TO 10);
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, arg2, dumy_arg3, dumy_arg4, 
              dumy_arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 2);
        return;
   END;
--|----------------------------------------------------------------------------
       PROCEDURE fscan ( CONSTANT string_buf    : IN STRING;
                         CONSTANT format        : IN STRING;
                         VARIABLE arg1          : OUT STRING 
                        ) IS
        VARIABLE dumy_arg2         :  STRING(1 TO 10); 
        VARIABLE dumy_arg3         :  STRING(1 TO 10);
        VARIABLE dumy_arg4         :  STRING(1 TO 10);
        VARIABLE dumy_arg5         :  STRING(1 TO 10);
        VARIABLE dumy_arg6         :  STRING(1 TO 10); 
        VARIABLE dumy_arg7         :  STRING(1 TO 10);
        VARIABLE dumy_arg8         :  STRING(1 TO 10);
        VARIABLE dumy_arg9         :  STRING(1 TO 10);
        VARIABLE dumy_arg10         :  STRING(1 TO 10);
        VARIABLE dumy_arg11         :  STRING(1 TO 10);
        VARIABLE dumy_arg12         :  STRING(1 TO 10);
        VARIABLE dumy_arg13         :  STRING(1 TO 10);
        VARIABLE dumy_arg14         :  STRING(1 TO 10);
        VARIABLE dumy_arg15         :  STRING(1 TO 10);
        VARIABLE dumy_arg16         :  STRING(1 TO 10);
        VARIABLE dumy_arg17         :  STRING(1 TO 10);
        VARIABLE dumy_arg18         :  STRING(1 TO 10);
        VARIABLE dumy_arg19         :  STRING(1 TO 10);
        VARIABLE dumy_arg20         :  STRING(1 TO 10);                
   BEGIN
     -- call procedure fscan with 20 arguments
        fscan(string_buf, format, arg1, dumy_arg2, dumy_arg3, dumy_arg4, 
              dumy_arg5, dumy_arg6, dumy_arg7, dumy_arg8, dumy_arg9, dumy_arg10,
              dumy_arg11, dumy_arg12,   dumy_arg13, dumy_arg14, dumy_arg15,
              dumy_arg16, dumy_arg17, dumy_arg18, dumy_arg19, dumy_arg20, 1);
        return;
   END;

--+----------------------------------------------------------------------------
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
                       )  IS
        VARIABLE ch    :  CHARACTER;
     BEGIN
        IF ( NOT ENDFILE(stream)) THEN
		READ(stream, ch); 
	        result := CHARACTER'POS(ch);
        ELSE
                result := -1;              -- end of file
        END IF;
        return;

     END;

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
--|
--|     Problems       :  When reading last line of file, if it is terminated with
--|                       an end of line marker then when the end of the last line is
--|                       reached the final eol will not be returned (instead -1 will be
--|                       returned).
--|
--|-----------------------------------------------------------------------------
     PROCEDURE fgetc    ( VARIABLE result  : OUT INTEGER;
                          VARIABLE stream  : IN TEXT;
                          VARIABLE ptr     : INOUT LINE
                        ) IS
        VARIABLE ch         : character;

     BEGIN
        if ( (ptr /= NULL) and (ptr'LENGTH /= 0) ) then
           READ(ptr, ch);
           result := CHARACTER'POS(ch);
        elsif ( not ENDFILE(stream) ) then
           if ( ptr /= NULL)  then -- ptr'length = 0
              READLINE(stream, ptr);
              result := 10;  -- ascii code for LF (line feed)
           else                   -- ptr = null (this should mean its at the beginning of the file)
              READLINE(stream, ptr);
              READ(ptr, ch);
              result := CHARACTER'POS(ch);
           end if;
        else
           result := -1;  -- end of file
        end if;
        return;
     END;

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
                     ) IS
        VARIABLE ch          : CHARACTER;
        VARIABLE lstr_cpy    : STRING(1 TO n);
        VARIABLE index       : NATURAL := 0;
    BEGIN
          IF (n=0) THEN
              if (l_str'LENGTH > 0 ) then
                 l_str(l_str'LEFT) := NUL;
              end if;
              return;
          ELSE
              assert ( not (WarningsON and ENDFILE(stream)) )
                 report "fgets (ASCII_TEXT)  -- attempt to read past end of file"
                 severity WARNING;
               
               while ( NOT ENDFILE(stream) ) LOOP
                       READ(stream, ch);
                       index := index + 1;
                       lstr_cpy(index) := ch;
                       EXIT when ((index >= n) OR (ch = END_OF_LINE_MARKER(1)));
               END LOOP;
          END IF;

        -- determine the length of string and place charcaters
          IF (l_str'LENGTH <=  n) THEN
		l_str := lstr_cpy(1 TO l_str'LENGTH);
          ELSE
		l_str(1 TO n) := lstr_cpy;
                l_str(n+1) := NUL;
          END IF;

          RETURN;
       END;

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
                     ) IS
                     
        VARIABLE ch      : character;
        VARIABLE str     : STRING( 1 TO n+1);
        VARIABLE counter : integer := 0;

     BEGIN
     --
        if ( (line_ptr = NULL) or (line_ptr'LENGTH = 0) ) then
           if (ENDFILE(stream)) then
              assert (not WarningsON)
                 report "fgets (text)  -- attempt to read past end of file"
                 severity WARNING;
              str(1) := NUL;
              strcpy(l_str, str);
              return;
           else
              READLINE(stream, line_ptr);
           end if;
        end if;
        for i IN 1 to n loop
           exit when ( (line_ptr = NULL) or (line_ptr'LENGTH = 0) );
           READ(line_ptr, ch);
           str(i) := ch;
           counter := counter + 1;
        end loop;
        str(counter + 1) := NUL;
        strcpy(l_str, str);
	RETURN;
     END;

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
                       ) IS
        VARIABLE ch        : character := ' ';
        VARIABLE indx      : integer := 0;
        VARIABLE str_copy  : STRING(1 TO max_string_len);
   BEGIN
   --
      IF ENDFILE(stream) THEN 
	assert Not WarningsOn
   	   report " fgetline (ASCII_TEXT)  --- end of file, nothing to read."
           severity WARNING;
        if (l_str'LENGTH > 0 ) then
           l_str(l_str'LEFT) := NUL;
        end if;
        return;
      ELSE
        while ( (not ENDFILE(stream)) and (ch /= END_OF_LINE_MARKER(1)) ) loop
           READ(stream, ch);
           indx := indx + 1;
           str_copy(indx) := ch;
        end loop;
        -- determine the length and place characters
        IF (l_str'LENGTH <=  indx) THEN
		l_str := str_copy(1 TO l_str'LENGTH);
        ELSE
		l_str(1 TO indx) := str_copy(1 TO indx);
        	l_str(indx+1) := NUL;
        END IF;          
        RETURN;
     END IF;

   END;

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
                       ) IS
        VARIABLE str_copy   : STRING(1 TO max_string_len + 1);
        VARIABLE ch         : character;
        VARIABLE indx       : NATURAL := 0;
   BEGIN
      If ( (line_ptr /= NULL) and (line_ptr'LENGTH > 0) ) then
          NULL;
      elsif ( not ENDFILE(stream) ) then
         READLINE(stream, line_ptr);
      else
         assert NOT WarningsOn
            report " fgetline (TEXT)  --- end of file, nothing to read."
            severity WARNING;
         l_str(l_str'left) := NUL;
         return;
      end if;
      while ( (line_ptr /= NULL) and (line_ptr'length /= 0) ) loop
         READ(line_ptr,ch);
         indx := indx + 1;
         str_copy(indx) := ch;
      end loop;
      str_copy(indx + 1) := NUL;
      strcpy(l_str, str_copy);
      return;
   END;

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
                        ) IS
       BEGIN
            WRITE(stream, c);    -- built_in write
       END;

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
                        ) IS

     BEGIN
          if ( (c = LF) or (c = CR) ) THEN
             WRITELINE(stream, line_ptr);
             DEALLOCATE(line_ptr);
          else
             write(line_ptr, c);
          END IF;
          RETURN;
     END;

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
                        ) IS
        VARIABLE str_copy : String (1 TO l_str'LENGTH) := l_str;
	VARIABLE ch       : character;  
     BEGIN
          FOR i IN 1 TO l_str'LENGTH LOOP
		ch := str_copy(i);
		exit when (ch = NUL);
		write (stream, ch);
          END LOOP;

          write (stream, END_OF_LINE_MARKER(1));
          return;

     END fputs;

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
                        ) IS

    
     BEGIN
        FOR i IN  l_str'RANGE LOOP
           exit when (l_str(i)= NUL);
           WRITE(line_ptr, l_str(i));
        END LOOP;
        WRITELINE(stream, line_ptr);
        DEALLOCATE(line_ptr);
        RETURN;
     END fputs;

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
                         ) RETURN NATURAL IS
         VARIABLE result     : NATURAL := 0;
         VARIABLE index      : INTEGER := 0;
         VARIABLE lstr_cpy   : STRING(1 TO l_str'LENGTH) := l_str;
   BEGIN
         While ( index  < l_str'LENGTH) LOOP
               index  := index  + 1;
               IF (lstr_cpy(index) = NUL) THEN
		 EXIT;
               END IF;
               IF ( c = lstr_cpy(index)) THEN
                 result := index;
                 EXIT;
               END IF;
         END LOOP; 
         RETURN result;
   END;
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
                           ) RETURN STRING IS
         VARIABLE result : STRING(1 TO l_str'LENGTH) := l_str;
     BEGIN 
            IF (n <= l_str'LENGTH) THEN
                result(n) := c;
            ELSE
                  ASSERT NOT WarningsOn
                  REPORT " Sub_Char --- n out of range "
                  SEVERITY WARNING;
            END IF;
            RETURN  result;
     END Sub_Char;
























--+-----------------------------------------------------------------------------
--|     Function Name  : T_Machine 
--| hidden
--|     Overloading    : None
--|
--|     Purpose        : Finite State automaton to recognise a time format.
--|                      format will be broken into field width, precision
--|                      and justification (left or right) and time_unit (tu);
--|
--|     Parameters     : fwidth        -- output, INTEGER, field width
--|                      precision     -- output, INTEGER, precison 
--|                      justify       -- OUTPUT, BIT 
--|                                       '0' right justified,
--|                                        '1' left justified 
--|                      t_unit            -- output, STRING, time unit of
--|                                         result
--|                      format  - input  STRING, provides the
--|                        conversion specifications.
--|
--|     Result         :  
--|
--|     NOTE           :
--|                      This procedure is
--|                      called in the function To_String.  
--|
--|     Use            :
--|                    VARIABLE   fmt : STRING(1 TO format'LENGTH) := format;
--|                    VARIABLE fw       : INTEGER;
--|                    VARIABLE precis   : INTEGER;
--|                    VARIABLE justfy    : BIT; 
--|                    VARIABLE tu        : STRING(1 TO 2);
--|
--|                    T_Machine(fw, precis, justy,i tu,  fmt); 
--|
--|-----------------------------------------------------------------------------

   PROCEDURE T_Machine ( VARIABLE fwidth     : OUT INTEGER;
                         VARIABLE precison   : OUT INTEGER;
                         VARIABLE justify    : OUT BIT;
                         VARIABLE t_unit     : OUT time_unit_type;
                         CONSTANT format     : IN STRING 
                       ) IS
    VARIABLE state   : INT8 := 0;
    VARIABLE fmt     : STRING(1 TO format'LENGTH);
    VARIABLE ch      : CHARACTER;
    VARIABLE index   : INTEGER := 1;
    VARIABLE fw      : INTEGER := 0;
    VARIABLE pr      : INTEGER := -1;
    VARIABLE tu      : STRING(1 TO 3) := (others =>' ');
    VARIABLE tu_indx : INTEGER := 0;
    VARIABLE e_flag  : boolean := false;

   BEGIN
      fmt := To_Lower(format);
   -- make sure first character is '%' if not error
     ch := fmt(index);
     IF (fmt(index) /= '%') THEN
           ASSERT false
           REPORT " Format Error  --- first character of format " & 
                  " is not '%' as expected." 
           SEVERITY ERROR;
           return;
     END IF;
     justify := '0';  -- default is right justification
     WHILE (state /= 3) LOOP 
        if (index < format'LENGTH) THEN
           index := index + 1;
           ch := fmt(index);
           CASE state IS
               WHEN 0  => IF (ch ='-') THEN
                            state := 1;           -- justify
                          ELSIF (ch >= '0'  AND ch <= '9') THEN   -- to_digit
                            fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0');
                            state := 2;            -- digits state
                          ELSIF (ch = 't') THEN
                            state := 3;            -- end state
                          ELSIF (ch = '.') THEN
                            state := 4;
                          ELSIF (ch = '%') THEN
                            state := 5;
                          ELSE 	
                            state := 6;    -- error       
                          END IF;

               WHEN 1  => justify := '1';      -- left justfy
                          IF (ch >= '0' AND ch <= '9') THEN    -- to_digit
                            fw :=  CHARACTER'POS(ch) - CHARACTER'POS('0');
                            state := 2;
                          ELSIF (ch = '.') THEN
                            state := 4;
			  ELSIF (ch = 't') THEN
			    justify := '0';  -- %-t is equivalent to %t
			    state := 3;
                          ELSE
                            state := 6;    -- error
                          END IF;

               WHEN 2   =>    --  digits-state
                          IF (ch >= '0' AND ch <= '9') THEN
                             fw := fw * 10 + CHARACTER'POS(ch)
                                           - CHARACTER'POS('0');
                             state := 2;
                          ELSIF (ch = 't') THEN
                             state := 3;
                          ELSIF (ch = '.') THEN
                             state := 4;
                          ELSE
                             state := 6;
                          END IF;

               WHEN 3  =>     -- t  state
                          -- fromat successfully recognized, exit now.
                          EXIT;
 
               WHEN 4   =>   -- . state
                          IF (ch >= '0' AND ch <= '9') THEN      -- to_digit
                             pr :=  CHARACTER'POS(ch) - CHARACTER'POS('0');
                             state := 7;
                          ELSE
                             state := 6;  -- error
                          END IF; 
                   
               WHEN 5   =>   --  print %  
                          EXIT;

               WHEN 6  =>   -- error state
                            -- print error message
                          ASSERT false
                          REPORT " Format Error --- expected %t format. "
                          SEVERITY ERROR;
                          EXIT;

               WHEN 7  =>  -- precision
                          IF (ch >= '0' AND ch <= '9') THEN
                             pr := pr * 10 + CHARACTER'POS(ch)
                                           - CHARACTER'POS('0'); -- to_digit
                             state := 7;
                          ELSIF (ch = 't') THEN
                             state := 3;
                          ELSE
                             state := 6;  -- error
                          END IF;
           END CASE;
        ELSE 
	   assert false
	   report " Format Error:   Observed =" & fmt &LF
                & "                 Expected = %t unit      (detected by T_Machine) "
           severity ERROR;
           e_flag := true;
           exit;
        END IF;    
     END LOOP;
  
     IF (Not e_flag) THEN         
         index := index + 1;
	 if (index < format'LENGTH) then
            ch := fmt(index);
	 end if;
         while ((index < format'LENGTH) AND Is_Space(ch)) LOOP
	      index := index + 1;
	      ch := fmt(index);
         END LOOP; 

	 if (index < format'LENGTH) then
            If (ch >='a' AND ch <='z') THEN
               tu(1) := ch;
               tu(2) := fmt(index + 1);
               if (format'Length >= index + 2) then 
	               tu(3) := fmt(index+2);
               end if;
            END IF;
	 end if;
                -- this case statement decides the time unit.
         CASE tu IS
             WHEN "fs "  =>  t_unit := t_fs;
             WHEN "ps "  =>  t_unit := t_ps;
             WHEN "ns "  =>  t_unit := t_ns;
             WHEN "us "  =>  t_unit := t_us;
             WHEN "ms "  =>  t_unit := t_ms;
             WHEN "sec"  =>  t_unit := t_sec;
             WHEN "min"  =>  t_unit := t_min;
             WHEN "hr "  =>  t_unit := t_hr;
             WHEN OTHERS => ASSERT false
                            REPORT " Format error  ---  time unit is not specified " 
                             & "correctly  in the format string "
                            SEVERITY ERROR;
         END CASE;
     END IF;
   -- decide field width (fwidth)
     IF (fw > max_string_len) THEN
	fwidth := max_string_len;
     ELSE
	fwidth := fw;
     END IF;
   -- decide precision
     IF (pr = -1) THEN
	precison := 6;            -- use default precision
     ELSE
	precison := pr;
     END IF;
     RETURN;
   END T_Machine;
   
--+-----------------------------------------------------------------------------
--|     Function Name  : Default_Time
--| hidden
--|     Overloading    : None
--|

--|     Purpose        : Convert 64 bit Time value to a String with
--|                      default  length of 12.


--|
--|     Parameters     :
--|                      val     - input,  TIME,
--|
--|     Result         : STRING  representation of TIME.
--|                        
--|     NOTE           : This function converts input time to an appropriate
--|                      time units such that it can be represented in a string
--|                      length 7 (xxx.xxx). Then  4 places for unit

--|                      ( hr, min, sec, ms ps etc.) are needed and one more for

--|                       sign ( -/+ ). IF time is positive then sign position is 
--|                       left blank. This way this function will return a string
--|                       of length 12.
--|                        signXXX.XXX Unit  ( sign takes one location and units 3). 
--|
--|
--|-----------------------------------------------------------------------------


    FUNCTION Default_Time ( CONSTANT val    : IN TIME
                            )  RETURN STRING IS
            VARIABLE tval : time;
            VARIABLE ival : integer := 0;
            VARIABLE fval : integer := 0;
            VARIABLE same_unit : Boolean := false; 
            VARIABLE sign   : character := ' ';
            VARIABLE prefix : string(1 to 7) := "   .   ";
            VARIABLE suffix : string(1 to 4) := "    ";
            VARIABLE digit  : integer range 0 to 9;
            type char10 is array (Integer range 0 to 9) of character;
            CONSTANT lookup : char10 := ( '0','1','2','3','4','5','6','7','8','9');
        BEGIN
        --  Handling sign 
            IF    ( val < 0 ns  ) THEN 
                   sign := '-'; 
                   tval := - val;
            ELSE
                   sign := ' '; 
                   tval :=   val;
            END IF;
         -- selecting proper unit dynamically

         -- check for 0 time (whether input time is 0 fs, 0 ps, 0 ns etc)

         -- it will be treated as 0 ns / 1000000 internally. We will provide default
         -- time as 0.000 ns.
         --
           IF (tval = 0 ns) then
              ival   := 0;
              suffix := " ns "; 

           ELSIF  ( tval >= 1 hr  ) then
              ival :=  (tval / 1 min  ); -- gives it in terms of 60's 
                                                 -- of min
              suffix := " hr ";
              fval := (ival mod 60);
              ival := (1000 * (ival/60)) + ( fval * 1000 / 60);
           ELSIF ( tval >= 1 min ) then
              ival :=  (tval / 1 sec); -- gives it in terms of 60's of sec
              suffix := " min";
              fval := ival mod 60;
              ival := (1000 * (ival/60)) + (fval * 1000 / 60);

           ELSIF ( tval >= 1 sec ) then
              ival := tval / 1 ms; -- gives it in terms of 1000's of ms
              suffix := " sec";
           ELSIF ( tval >= 1 ms  ) then
              ival := tval / 1 us; -- gives it in terms of 1000's of us
              suffix := " ms ";


           ELSIF (tval >= 1 us) then  
              ival := tval / 1 ns; -- gives it in terms of 1000s of ns 
              suffix := " us ";


           ELSIF ( tval >= 1 ns) THEN
	      suffix := " ns ";
	      if ( (1 ns / 1000) = 0 ns ) then
	         ival := tval / (1 ns);
		 same_unit := TRUE;
	      else
                 ival := tval / (1 ns / 1000); -- gives it in terms of 1000s of 1 ns / 1000
	      end if;
              


           ELSIF ( tval >= (1 ns / 1000) ) THEN
	      suffix := " ps ";
	      if ( (1 ns / 1000000) = 0 ns ) then
	         ival := tval / (1 ns / 1000);
		 same_unit := TRUE;
              else
                 ival := tval / (1 ns / 1000000); -- gives it in terms of 1000s of 1 ns / 1000000
	      end if;

           ELSIF ( tval >= (1 ns / 1000000) ) THEN			
              ival := tval / (1 ns / 1000000); 
              suffix := " fs ";
              same_unit := TRUE;
           END IF;
         --  converting to XXX.XXX format 
           IF ( same_unit ) THEN
                prefix(5 TO 7) := (OTHERS => '0');
           ELSE
	        FOR i IN 7 DOWNTO 5 LOOP
        	        digit := ival mod 10;
                	ival := ival / 10;
	                prefix (i) := lookup(digit);
                END  LOOP;
           END IF;
           FOR i IN 3 DOWNTO  1 LOOP
                digit := ival mod 10;
                ival := ival / 10;
                prefix (i) := lookup(digit);
           END  LOOP;
         -- get rid of leading zero's
           leading_zero_kill : FOR i IN 1 to 2 LOOP
                exit leading_zero_kill WHEN (prefix(i) /= '0');
                IF (prefix(i) = '0') THEN 
                     prefix (i) := ' '; 
                 END IF;
           END LOOP;
	   if (prefix(2) = ' ') then
	      return ( "  " & sign & prefix(3 to 7) & suffix);
	   elsif (prefix(1) = ' ') then
	      return ( ' ' & sign & prefix(2 to 7) & suffix);
	   else
	      RETURN (sign & prefix & suffix);
	   end if;
        END Default_Time;

--+-----------------------------------------------------------------------------
--|     Function Name  : Time_String
--| hidden
--|     Overloading    : None
--|

--|     Purpose        : Convert 64 bit Time  value to a String based upon fs

--|
--|     Parameters     : val     - input,  TIME positive val,
--|

--|     Result         : A STRING of length 20 representing  TIME.

--|
--|
--|-----------------------------------------------------------------------------
    FUNCTION Time_String ( CONSTANT val    : IN TIME )  RETURN STRING IS


        CONSTANT buf_len : INTEGER := 20;

        TYPE     t_to_int_type is array (1 to 6) of integer;

	VARIABLE t_to_int      : t_to_int_type := (others => 0);
        VARIABLE tbuf	       : STRING(1 to buf_len) := (others => '0'); 
	VARIABLE ival	       : integer;
	VARIABLE tval	       : time := val;
        VARIABLE i, index      : integer;
	VARIABLE min_str_index : integer;
	VARIABLE time_unit     : time;
	VARIABLE min_time_unit : time;
	VARIABLE start_int_ind : integer;
	VARIABLE num, counter  : integer;

    BEGIN
       -- identify minimum time unit
       min_time_unit := 1 ns / 1000000;
       if ( min_time_unit > 0 ns ) then    -- fs
	   start_int_ind := 1;
       else
          min_time_unit := 1 ns / 1000;
	  if ( min_time_unit > 0 ns ) then    -- ps
	     start_int_ind := 2;
	  else		                       -- ns
	     min_time_unit := 1 ns;
	     start_int_ind := 3;
	  end if;
       end if;

       -- get minimum string index
       min_str_index := 1;

       if (min_time_unit = (1 ns / 1000)) then
          min_str_index := 4;
       elsif (min_time_unit = 1 ns) then
          min_str_index := 7;
       end if;


       -- get starting time_unit and starting integer array index
       time_unit := min_time_unit;
       for i in 1 to (((buf_len - min_str_index)/3)-1) loop
          time_unit := time_unit * 1000;
	  start_int_ind := start_int_ind + 1;
       end loop;
       -- start_int_ind now is at the maximum value

       -- get integer equivalent
       -- start with maximum time_unit and work down to minimum
       i := start_int_ind;
       while time_unit > 0 ns loop
          t_to_int(i) := tval /  time_unit;
	  tval := tval - t_to_int(i) * time_unit;
	  time_unit := time_unit/1000;
	  i := i - 1;
       end loop;
       index := i + 1;

       -- convert intpeger array to a string
       i := buf_len - min_str_index + 1;
       counter := 0;
       while i > 0 loop
          if (counter mod 3 = 0) and (index <= start_int_ind) then
	     num := t_to_int(index);
	     index := index + 1;
	  end if;
	  tbuf(i) := CHARACTER'VAL(CHARACTER'POS('0') + (num mod 10));
	  num := num/10;
	  i := i - 1;
	  counter := counter + 1;
       end loop;
       return tbuf;
    END Time_String;	

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
--|                       t := From_String ("   893.56 ns");
--|                       This statement will set t to  time 893.56 ns.
--|
--|-----------------------------------------------------------------------------
    FUNCTION From_String   ( CONSTANT str   : IN STRING
                           ) RETURN TIME IS
      VARIABLE result     : TIME;
      VARIABLE fract_t    : TIME;
      VARIABLE state      : INT8;
      VARIABLE str_copy   : STRING (1 TO str'LENGTH):= To_Upper(str);
      VARIABLE index      : Natural;
      VARIABLE power      : Natural := 0;
      VARIABLE num        : Integer := 0;    
      VARIABLE fract_num  : Integer := 0;    
      VARIABLE ch         : character;
      VARIABLE neg_sign   : boolean := false;
      VARIABLE tu         : string(1 To 3) := (OTHERS => ' ');
      VARIABLE tu_indx    : INTEGER := 0;
      VARIABLE parse_err  : BOOLEAN := FALSE;
       
    BEGIN
      -- Check for null input
        IF (str'LENGTH = 0) THEN
		assert false
		report " From_String  --- input string has a null range "
                severity ERROR;
                RETURN TIME'LEFT;
        END IF;
      -- find the position of the first non_white character      
        index := Find_NonBlank(str_copy);
        IF (index > str'length) THEN
		assert false
		report " From_String   --- input string is empty  ";
                RETURN TIME'LEFT; 
        ELSIF (str_copy(index)=NUL) THEN
		assert false 
                report " From_String  -- first non_white character is a NUL ";
                RETURN TIME'LEFT;
        END IF;
        ch  := str_copy(index);
       -- check for - sign or + sign
        IF (ch = '-') Then
            neg_sign := NOT neg_sign;
            index := index + 1;
            ch := str_copy(index);      -- get_char
        elsif (ch = '+') then
            index := index + 1;
            ch := str_copy(index);      -- get_char
        END IF;

      -- Strip off leading zero's
        While ( (ch = '0')  AND (index < str'LENGTH)) LOOP
              index := index + 1;
              ch := str_copy(index);     -- get_char
        END LOOP;
      -- if all zero's make sure that final zero remains
        if ( (NOT Is_Digit(ch)) and (index > 1) and (str_copy(index - 1) = '0') ) then
           index := index - 1;
           ch := str_copy(index);
        end if;
        WHILE (true) LOOP 
            CASE state IS
               WHEN 0  => IF (ch >= '0'  AND ch <= '9') THEN      -- to_digit
                              num :=  CHARACTER'POS(ch) - CHARACTER'POS('0'); 
                              state := 1; 
                          ELSIF (ch = '.') THEN
                             state := 2;
                          ELSE 	
                             state := 4;    -- error       
                          END IF;

               WHEN 1   =>    -- 
                         IF (ch >= '0' AND ch <= '9') THEN
                            num := num * 10 + CHARACTER'POS(ch)
                                          - CHARACTER'POS('0');
                            state := 1;
                         ELSIF (ch = '.') THEN
                            state := 2;
                         ELSIF ((Is_White(ch)) OR (ch = NUL)) THEN
                            state := 3;
                         ELSE
                            state := 4;      -- error
                         END IF;

               WHEN 2   =>   -- . state
                         IF (ch >= '0' AND ch <= '9') THEN
                           fract_num := fract_num * 10 + CHARACTER'POS(ch)
                                          - CHARACTER'POS('0');
                            power := power + 1;
                           state := 2;

                         ELSIF ((Is_White(ch)) OR (ch = NUL)) THEN
                            state := 3;
                         ELSE
                           state := 6;  -- error
                         END IF; 
 
               WHEN 3   =>  -- space between time value and unit
                         IF ((Is_White(ch)) OR (ch=NUL)) THEN
                              state := 3;
                         ELSIF (ch >= 'A' AND ch <= 'Z') THEN
                            tu_indx := tu_indx + 1;
                            tu(tu_indx) := ch;             
                            state := 5;
                         ELSE
                           state := 4;
                         END IF;
 
                WHEN 4  =>   -- error state
                          ASSERT false
                          REPORT " From_String   --- invalid character encountered " 
                          SEVERITY ERROR;
                          parse_err := TRUE;
                          EXIT;

                WHEN 5   =>     -- end  state 
                         IF ((ch >= 'A' AND ch <= 'Z') AND (tu_indx < 3)) THEN
                            tu_indx := tu_indx + 1;
                            tu(tu_indx) := ch;             
                            state := 5;
			 ELSIF ( IS_White(ch) OR (tu_indx = 3) OR (ch=NUL)) THEN
				exit;
                         ELSE
                           state := 4;
			 END IF;
                WHEN OTHERS =>  ASSERT false
                                REPORT " From_String(time)  ---  time string in incorrect format"
                                SEVERITY ERROR;
                                parse_err := TRUE;
                                exit;

              END CASE;
              index := index + 1;
              EXIT when index > str'LENGTH;
              ch := str_copy(index);
          END LOOP;

          if (parse_err) then
             return TIME'LEFT;
          end if;

	  IF (neg_sign) THEN
		num := - num;
                fract_num := - fract_num;
          END IF;
        -- this case statement decides the time unit.
          CASE tu IS

             WHEN "FS " =>
	                  if (1 ns / 1000000) /= 0 ns then
                             fract_t := (fract_num * (1 ns / 1000000)) / (10 ** power);
                             result := (num * (1 ns / 1000000))  + fract_t;
			  else
			     if (1 ns / 1000) /= 0 ns then
			        result := num / 1000 * (1 ns / 1000);
			     else
			        result := num / 1000000 * 1 ns;
			     end if;
			  end if;


             WHEN "PS " =>
	                  if ( 1 ns / 1000) /= 0 ns then
                             fract_t := (fract_num * (1 ns / 1000)) / (10 ** power);
                             result := (num * (1 ns / 1000))  + fract_t;
			  else
			     result := num / 1000 * 1 ns;
			  end if;

             WHEN "NS " =>
                          fract_t := (fract_num * 1 NS) / (10 ** power);
                          result := (num * 1 NS)  + fract_t;
             WHEN "US " =>
                          fract_t := (fract_num * 1 US) / (10 ** power);

                          result := (num * 1 US)  + fract_t;


             WHEN "MS " =>
                          fract_t := (fract_num * 1 MS) / (10 ** power);
                          result := (num * 1 MS)  + fract_t;


             WHEN "SEC" =>
                          fract_t := (fract_num * 1 SEC) / (10 ** power);
                          result := (num * 1 SEC)  + fract_t;
             WHEN "MIN" =>
                          fract_t := (fract_num * 1 MIN) / (10 ** power);
                          result := (num * 1 MIN)  + fract_t;
             WHEN "HR " =>
                          fract_t := (fract_num * 1 HR) / (10 ** power);
                          result := (num * 1 HR)  + fract_t;


             WHEN OTHERS =>

                          ASSERT false
                            REPORT "From_String --- time base not specified or incorrectly specified"
                            SEVERITY ERROR;

                            
                          return TIME'LEFT;
          END CASE;
	return result;      
    END From_String;
--+-----------------------------------------------------------------------------
--|     Function Name  : To_String
--| 1.1.7
--|     Overloading    : None
--|
--|     Purpose        : Convert Time   to a String.
--|
--|     Parameters     :
--|                      val     - input,  TIME,
--|
--|     Result         : STRING  representation of TIME.
--|
--|
--|-----------------------------------------------------------------------------
    FUNCTION To_String ( CONSTANT val    : IN TIME;
                         CONSTANT format : IN STRING := ""
                       )  RETURN STRING IS

        VARIABLE tbuf       : STRING(max_string_len DOWNTO 1) ; -- implicitly == NUL
        VARIABLE str_len    : NATURAL;  --  actual length of time string
        VARIABLE rbuf       : STRING(max_string_len DOWNTO 1);
        VARIABLE result     : string(1 TO max_string_len);
        VARIABLE r_index    : Natural := 0;
        VARIABLE t_index    : Natural := 0;
        VARIABLE str_index  : Natural := 0;
        VARIABLE tval       : TIME;
        VARIABLE ival       : INTEGER;
        VARIABLE period_loc : NATURAL;
        VARIABLE left_digits  : NATURAL;
        VARIABLE format_cpy : string(1 TO format'length) := format;
        VARIABLE pr_actual  : integer;  -- actual precision
        VARIABLE indx       : integer;  
        VARIABLE fw         : integer;  -- field width
        VARIABLE precis     : integer;  -- precision
        VARIABLE justy      : BIT := '0';  -- justification
        VARIABLE tunit      : time_unit_type;
        VARIABLE suffix     : STRING(1 TO 4);
        VARIABLE neg_sign  : BOOLEAN := false ;
    BEGIN

          -- IF no format is specified then  the result will be provided
          -- in the  dynamic default time unit. 
            IF (format = "") THEN 
                     return(Default_Time(val)); 
            END IF;
           -- handle sign 
            IF  ( val < 0 ns ) THEN 
                    neg_sign := NOT neg_sign; 
                    tval := - val;
            ELSE
                    tval :=   val;
            END IF;
           -- convert time to string without any format
           -- by calling Time_String().  first determine the length  

             str_index := 20;

             tbuf(str_index downto 1) := Time_String(tval);

       -- call procedure T-Machine to split format string into field width fw
       -- precision, justification and desired time unit ( time unit in which
       -- the result string is to be represented).
	T_Machine(fw, precis, justy, tunit, format);

       -- determine the desired output time unit and insert the decimal point 
       -- at proper location in the string and save the result int rbuf.  
        CASE tunit is

         WHEN t_sec  | t_min | t_hr =>
                period_loc := 16;

                rbuf(period_loc - 1 DOWNTO 1) := tbuf(period_loc -1  DOWNTO 1);
                rbuf(period_loc) := '.';
                rbuf(str_index + 1 DOWNTO period_loc + 1) := 
                                             tbuf(str_index DOWNTO period_loc);

                suffix := " sec";

         WHEN t_ms => 
                period_loc := 13;

                rbuf(period_loc - 1 DOWNTO 1) := tbuf(period_loc -1  DOWNTO 1);
                rbuf(period_loc) := '.';
                rbuf(str_index + 1 DOWNTO period_loc + 1) := 
                                             tbuf(str_index DOWNTO period_loc);

                suffix := " ms ";
         WHEN t_us => 
                period_loc := 10;
                rbuf(period_loc - 1 DOWNTO 1) := tbuf(period_loc -1  DOWNTO 1);
                rbuf(period_loc) := '.';
                rbuf(str_index + 1 DOWNTO period_loc + 1) := 
                                             tbuf(str_index DOWNTO period_loc);
                suffix := " us ";

       	 WHEN t_ns =>
                period_loc := 7;

                rbuf(period_loc - 1 DOWNTO 1) := tbuf(period_loc -1  DOWNTO 1);

                rbuf(period_loc) := '.';
                rbuf(str_index + 1 DOWNTO period_loc + 1) := 
                                             tbuf(str_index DOWNTO period_loc);
                suffix := " ns ";                        
     
  	 WHEN t_ps =>
                period_loc := 4;


                rbuf(period_loc - 1 DOWNTO 1) := tbuf(period_loc -1  DOWNTO 1);

                rbuf(period_loc) := '.';
                rbuf(str_index + 1 DOWNTO period_loc + 1) := 
                                             tbuf(str_index DOWNTO period_loc);

                suffix := " ps ";                        	            
                         
         WHEN t_fs =>
                period_loc := 1;
                rbuf(period_loc) := '.';

                rbuf(str_index + 1 DOWNTO period_loc + 1) := 
                                             tbuf(str_index DOWNTO period_loc);

                suffix := " fs ";
  
         WHEN OTHERS => null;
	END CASE;
        str_index := str_index + 1;   -- to take care of decimal point

	-- kill leading zero's
        Kill_ZERO :  LOOP
            EXIT Kill_ZERO WHEN (rbuf(str_index) /= '0');
            IF (rbuf(str_index) = '0') THEN
                str_index := str_index - 1;
            END IF;
        END LOOP;  
        
        -- keep one zero before the decimal point
        IF (rbuf(str_index) = '.') THEN
               str_index := str_index + 1;
               rbuf(str_index) := '0';
        END IF;
        
        -- insert the negative sign if it exists
	IF neg_sign THEN
		str_index := str_index + 1;
		rbuf(str_index) := '-';
        END IF;

	--   calculate the number of digits including negative sign in the 
	--   string to the left of decimal point
        left_digits := str_index - period_loc;
	IF (precis /= 0) THEN
            str_len := left_digits + 1 + precis;
	ELSE
	    str_len := left_digits;
	END IF;
        
	-- copy rbuf to tbuf according to the desired format
	-- first copy the precison part
        -- check if precision > period_loc -1
        IF (precis > period_loc - 1) THEN
            t_index := precis + 1; 
            FOR i IN period_loc downto 1 LOOP
              tbuf(t_index) := rbuf(i);
              t_index := t_index - 1;
            END LOOP;
            tbuf(t_index downto 1) := (OTHERS => '0');
        ELSIF (precis = period_loc - 1) THEN
	    tbuf(precis + 1 downto 1) := rbuf(period_loc downto 1);
        ELSE -- copy as much portion you can
            r_index := period_loc;
            FOR i IN precis + 1 downto 1 LOOP
              tbuf(i) := rbuf(r_index);
              r_index := r_index - 1;
            END LOOP;          
        END IF;
        -- copy the part to the left of period
        tbuf(str_len DOWNTO str_len - left_digits + 1) := 
                                 rbuf(str_index DOWNTO period_loc + 1);

	-- match the desired field width
	-- ** was (fw > str_index)
	IF (fw > str_len) THEN
           case justy IS 
                WHEN '0' =>   -- right justification
                     tbuf(fw DOWNTO str_len + 1) := (OTHERS => ' ');
                     result( 1 TO fw) := tbuf(fw DOWNTO 1);
                     return (result(1 TO fw) & suffix);
		WHEN '1' =>
                     result( 1 TO str_len) := tbuf(str_len DOWNTO 1);
                     result(str_len + 1 TO str_len + 4) := suffix;
                      indx := str_len + 4;
                      for i IN fw - str_len DOWNTO 1 LOOP
                          indx := indx + 1;
                          result(indx) := ' ';
                      end LOOP;
                     return result(1 TO indx);
                WHEN OTHERS =>   -- left justification
                     ASSERT NOT WarningsOn
                     report " To_String  --- error in justification "
                     SEVERITY WARNING;
                     result(1 TO str_len) := tbuf(str_len DOWNTO 1);
                     return (result(1 TO str_len) & suffix);
            end case;
	ELSE           -- fw is lessthan or equal to std_len
            result(1 TO str_len) := tbuf(str_len DOWNTO 1);
	    return (result(1 TO str_len) & suffix);
        END IF;
      -- That's all
    END To_String;
--
-- end of the std_iopak body
END std_iopak;
