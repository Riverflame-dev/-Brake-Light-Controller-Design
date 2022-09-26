------------------------------------------------------------------------------------------------------------
--  SEVEN SEGMENT 
------------------------------------------------------------------------------------------------------------
-- This an enity that is seven sgement display used for displaying the time for a digital clock. 
-- It uses Three BCD encoded input values (HR, MIN, and SEC) represent the hours, minutes, and seconds for.
-- the current time. A discrete bit (AMPM) is used to indicate the AM/PM status, with '0' indicating AM. 
-- The circuit is controlled by an ENABLE input which is used as a clock enable, and a CLEAR input which 
-- is used to synchronously clear the display.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-----------------------
ENTITY SEVEN_SEGMENT IS
----------------------- 
PORT ( RESET   : in  std_logic;                      -- Active high master reset 
       CLOCK   : in  std_logic;                      -- Master clock 
       ENABLE  : in  std_logic;                      -- Clock enable 
       CLEAR   : in  std_logic;                      -- Synchronous clear 
       HR      : in  std_logic_vector (7 downto 0);  -- BCD encoded hour value 
       MIN     : in  std_logic_vector (7 downto 0);  -- BCD encoded minute value 
       SEC     : in  std_logic_vector (7 downto 0);  -- BCD encoded second value 
       AMPM    : in  std_logic;                      -- AM ('0') / PM ('1') indicator 
       DIGIT   : out std_logic_vector (1 to 8);     -- 7-segment digit enable 
       SEGMENT : out std_logic_vector (1 to 8));    -- 7-segment segment enable
END ENTITY;


------------------------------------
ARCHITECTURE RTL OF SEVEN_SEGMENT IS
------------------------------------
   
    IMPURE FUNCTION To_Segment (DATA : std_logic_vector (3 downto 0)) RETURN std_logic_vector IS BEGIN
        case DATA is 
            when "0000" => return "1111110"; -- "0" 
            when "0001" => return "0110000"; -- "1" 
            when "0010" => return "1101101"; -- "2"
            when "0011" => return "1111001"; -- "3" 
            when "0100" => return "0110011"; -- "4" 
            when "0101" => return "1011011"; -- "5" 
            when "0110" => return "1011111"; -- "6" 
            when "0111" => return "1110000"; -- "7"
            when "1000" => return "1111111"; -- "8"
            when "1001" => return "1111011"; -- "9"
            when "1010" => return "1110111"; -- "A"
            when "1011" => return "0011111"; -- "B"
            when "1100" => return "1001110"; -- "C"
            when "1101" => return "0111101"; -- "D"
            when "1110" => return "1001111"; -- "E"
            when "1111" => return "1000111"; -- "F"
            when others => return "0000001"; -- Use a "dash" character for an unknown value end case; 
        end case;
    END To_Segment;
    
    SIGNAL DECODE : std_logic_vector (0 to 7);
    SIGNAL SEG    : std_logic_vector (1 to 8);
    SIGNAL COUNT  : natural range 0 to 7;

BEGIN

    -------------------------------------
    U_COUNT: PROCESS (RESET, CLOCK) BEGIN
    -------------------------------------
        if (RESET = '1') then
           COUNT  <= 0;
        elsif (CLOCK'event and CLOCK = '1') then 
            if (CLEAR = '1') then
                COUNT <= 0;
            elsif (ENABLE = '1') then
                if (COUNT = 7) then
                    COUNT <= 0;
                else
                    COUNT <= COUNT + 1; 
                end if;  
            end if;
        end if;     
    END PROCESS; 
    
    ---------------------------------------
    U_DIG_SEG: PROCESS (RESET, CLOCK) BEGIN
    ---------------------------------------
        if (RESET = '1') then
           DECODE <= (others => '0');
           SEG    <= (others => '0');
        elsif (CLOCK'event and CLOCK = '1') then 
            if (CLEAR = '1') then
                DECODE <= (others => '0');
                SEG    <= (others => '0');
            elsif (ENABLE = '1') then
                DECODE <= (others => '0');
                DECODE (COUNT) <= '1';
                if (COUNT = 7) then
                    if (AMPM = '0') then
                        SEG <= "11101110";
                    else
                        SEG <= "11001110";
                    end if;
                else
                    case COUNT is
                        when 0      => if (HR (7 downto 4) = x"0") then
                                           SEG <= (others => '0');
                                       else
                                           SEG <= To_Segment (HR (7 downto 4)) & '0';
                                       end if;
                        when 1      => SEG <= To_Segment (HR (3 downto 0)) & '1';
                        when 2      => SEG <= To_Segment (MIN(7 downto 4)) & '0';
                        when 3      => SEG <= To_Segment (MIN(3 downto 0)) & '1';
                        when 4      => SEG <= To_Segment (SEC(7 downto 4)) & '0';
                        when 5      => SEG <= To_Segment (SEC(3 downto 0)) & '0';
                        when others => SEG <= "00000000";
                    end case;
                end if;
            end if;
        end if;     
    END PROCESS; 

    DIGIT(1 to 8)  <= DECODE (0 to 7);                
    SEGMENT        <= SEG;
    
END ARCHITECTURE RTL;


