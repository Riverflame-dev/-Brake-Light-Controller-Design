------------------------------------------------------------------------------------------------------------
 --GENERIC 2-DIGIT BCD counter
------------------------------------------------------------------------------------------------------------
-- This is an entity which is binary coded decimal counter, where the range of the counter is set by two generics named MIN and MAX.
-- whenever CLEAR or RESET is asserted on the rising edge of CLOCK, the counter is set to the MIN value. if not
-- the counter will increment whenever ENABLE is asserted on the rising edge of CLOCK and will automatically 
-- roll over from the MAX value to the MIN value. The TERM output is asserted whenever the counter is at its MAX value.


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


---------------------
ENTITY BCD_COUNTER is
---------------------
GENERIC ( MAX    : natural range 0 to 99 := 10;        -- Maximum count value before rollover
          MIN    : natural range 0 to 99 := 0 );       -- Value used for CLEAR and rollover
PORT    ( RESET  : in std_logic;                       -- Active high master reset
          CLOCK  : in std_logic;                       -- Master clock
          ENABLE : in std_logic;                       -- Counter clock enable
          CLEAR  : in std_logic;                       -- Counter synchronous clear
          TERM   : out std_logic;                      -- Counter roll over indicator
          COUNT  : out std_logic_vector (7 downto 0)); -- BCD count value
END ENTITY;


----------------------------------
ARCHITECTURE RTL OF BCD_COUNTER IS
----------------------------------

-- Create unsigned vectors using generic
CONSTANT MIN_COUNT : unsigned := To_Unsigned (16 * (MIN / 10) + (MIN mod 10), 8);   
CONSTANT MAX_COUNT : unsigned := To_Unsigned (16 * (MAX / 10) + (MAX mod 10), 8);
SIGNAL VALUE       : unsigned(7 downto 0);     -- Signal driving COUNT

BEGIN

----------------------------
PROCESS (RESET, CLOCK) BEGIN
----------------------------
    if (RESET = '1') then
       VALUE <= MIN_COUNT;
    elsif (CLOCK'event and CLOCK = '1') then 
       if (CLEAR = '1') then
          VALUE <= MIN_COUNT;
       elsif (ENABLE = '1') then                   -- Three cases when enabled at rising edge:
          if (VALUE = MAX_COUNT) then		  
	     VALUE <= MIN_COUNT;		   -- a. Roll over from MAX to MIN when counts to the upper limit
	  elsif (VALUE(3 downto 0) = "1001") then  
             VALUE <= VALUE + "00000111";          -- b. Add 0111 to 1001 to get 0001 0000 when counts to 9
	  else
	     VALUE <= VALUE + "00000001";          -- c. Count up by 1 if not a nor b
          end if;  
       end if;
    end if;     
END PROCESS;  

TERM <= '1' when (VALUE = MAX_COUNT) else '0';    
COUNT <= std_logic_vector (VALUE);

END ARCHITECTURE RTL;
