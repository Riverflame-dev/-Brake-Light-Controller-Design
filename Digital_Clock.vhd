------------------------------------------------------------------------------------------------------------
--  6 DIGIT DIGITAL CLOCK
------------------------------------------------------------------------------------------------------------
-- This is an enitity for a 12-hour format digital clock with an AM/PM indicator bit. The hour, minute, and  
-- second values are BCD encoded in separate 8-bit bus outputs. ENABLE line provides a one pulse-per-second 
-- time base to the clock, which only increments the counters when the ENABLE line is asserted on the rising 
-- edge of CLOCK.  Asserting the CLEAR input on a clock edge sets the clock to 01:00:00 AM


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;


-----------------------
ENTITY DIGITAL_CLOCK is
-----------------------
PORT ( RESET   : in std_logic;                      -- Active high master reset
       CLOCK   : in std_logic;                      -- Master clock
       ENABLE  : in std_logic;                      -- Clock enable
       CLEAR   : in std_logic;                      -- Synchronous clear
       HR      : out std_logic_vector (7 downto 0); -- BCD encoded hour value
       MIN     : out std_logic_vector (7 downto 0); -- BCD encoded minute value
       SEC     : out std_logic_vector (7 downto 0); -- BCD encoded second value
       AMPM    : out std_logic                   ); -- AM ('0') / PM ('1') indicator
END ENTITY;

----------------------------------
ARCHITECTURE RTL OF DIGITAL_CLOCK IS
----------------------------------
   COMPONENT BCD_COUNTER IS
   	generic ( MAX    : natural range 0 to 99 := 10;        -- Maximum count value before rollover
          	  MIN    : natural range 0 to 99 := 0 );       -- Value used for CLEAR and rollover
	port    ( RESET  : in std_logic;                       -- Active high master reset
          	  CLOCK  : in std_logic;                       -- Master clock
          	  ENABLE : in std_logic;                       -- Counter clock enable
          	  CLEAR  : in std_logic;                       -- Counter synchronous clear
          	  TERM   : out std_logic;                      -- Counter roll over indicator
          	  COUNT  : out std_logic_vector (7 downto 0)); -- BCD count value
   END COMPONENT;

   SIGNAL HOUR   : std_logic_vector (7 downto 0) ;     -- Signal driving HR port
   SIGNAL MINUTE : std_logic_vector (7 downto 0) ;     -- Signal driving MIN port
   SIGNAL SECOND : std_logic_vector (7 downto 0) ;     -- Signal driving SEC port

   SIGNAL AOP      : std_logic ;   -- Signal driving AMPM port
   SIGNAL SEC_TERM : std_logic ;   
   SIGNAL MIN_TERM : std_logic ;
   SIGNAL MIN_ENA  : std_logic ;
   SIGNAL HR_TERM  : std_logic ;
   SIGNAL HR_ENA   : std_logic ;

BEGIN

   -------------------
   U_SEC : BCD_COUNTER    -- Instantiation BCD counter to count seconds 
   -------------------
	GENERIC MAP ( MAX    => 59,       
		      MIN    => 0    )
	PORT MAP    ( COUNT  => SECOND,
		      RESET  => RESET,     
		      CLOCK  => CLOCK,
		      ENABLE => ENABLE,      
		      CLEAR  => CLEAR,       
		      TERM   => SEC_TERM );   

   -------------------
   U_MIN : BCD_COUNTER   -- Instantiation BCD counter to count minutes 
   -------------------
	GENERIC MAP ( MAX    => 59,
		      MIN    => 0    )
	PORT MAP    ( COUNT  => MINUTE,
		      RESET  => RESET,     
		      CLOCK  => CLOCK,       
		      ENABLE => MIN_ENA,      
		      CLEAR  => CLEAR,       
		      TERM   => MIN_TERM ); 

   ------------------
   U_HR : BCD_COUNTER    -- Instantiation BCD counter to count hours
   ------------------
	GENERIC MAP ( MAX    => 12,
		      MIN    => 1     )
	PORT MAP    ( COUNT  => HOUR,
		      RESET  => RESET,       
		      CLOCK  => CLOCK,      
		      ENABLE => HR_ENA,      
		      CLEAR  => CLEAR,       
		      TERM   => HR_TERM );   

   ----------------------------
   PROCESS (RESET, CLOCK) BEGIN    -- Process to indicate AM and PM
   ----------------------------
       if (RESET = '1') then  
          AOP <= '0';
       elsif (CLOCK'event and CLOCK = '1') then
          if (CLEAR = '1') then
       	     AOP <= '0';
          elsif (HR_ENA = '1' and HOUR = x"11") then
	     AOP <= not AOP;     -- Taggles AOP when hour counts up to 12
          end if;  
       end if;     
   END PROCESS;  

   -- Drive the enables 

   MIN_ENA <= ENABLE and SEC_TERM;      
   HR_ENA  <= MIN_ENA and MIN_TERM;
   
   -- Drive the output ports

   SEC     <= SECOND;
   MIN     <= MINUTE;
   HR      <= HOUR;
   AMPM    <= AOP;

END ARCHITECTURE RTL;
