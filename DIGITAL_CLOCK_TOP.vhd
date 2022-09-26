------------------------------------------------------------------------------------------------------------
--  
------------------------------------------------------------------------------------------------------------
--  
--  
--  
-- 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--------------------------------
entity DIGITAL_CLOCK_TOP is
--------------------------------
    port  ( RESET 	: in  std_logic;                  	-- Active high master reset
            CLOCK 	: in  std_logic;                  	-- Master clock(100Mhz)
            FAST  	: in  std_logic;                   	-- Fast time set control
            SLOW   	: in  std_logic;					-- Slow time set control
            TEST 	: in  std_logic;                    -- Clock divider bypass
            DIGIT   : out std_logic_vector (1 to 8);  	-- 7-segment display digit enable
            SEGMENT : out std_logic_vector (1 to 8));	-- 7-segment display segment enable
end entity;

--------------------------
ARCHITECTURE RTL OF DIGITAL_CLOCK_TOP IS
--------------------------
    COMPONENT SEVEN_SEGMENT IS
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
    END COMPONENT;


    COMPONENT DIGITAL_CLOCK is
    PORT ( RESET   : in  std_logic;                      -- Active high master reset
           CLOCK   : in  std_logic;                      -- Master clock
           ENABLE  : in  std_logic;                      -- Clock enable
           CLEAR   : in  std_logic;                      -- Synchronous clear
           HR      : out std_logic_vector (7 downto 0); -- BCD encoded hour value
           MIN     : out std_logic_vector (7 downto 0); -- BCD encoded minute value
           SEC     : out std_logic_vector (7 downto 0); -- BCD encoded second value
           AMPM    : out std_logic                   ); -- AM ('0') / PM ('1') indicator
    END COMPONENT;
    
    
    COMPONENT DEBOUNCE is
    GENERIC ( DELAY  :     natural := 10 );   
    PORT    ( RESET  : in  std_logic;                  	-- Active high master reset
              ENABLE : in  std_logic;
              CLOCK  : in  std_logic;
              DIN  	 : in  std_logic;                   -- Fast time set control
              DOUT   : out std_logic     ); 
    END COMPONENT;

    SIGNAL HOUR   : std_logic_vector (7 downto 0) ;     -- Signal driving HR port
    SIGNAL MINUTE : std_logic_vector (7 downto 0) ;     -- Signal driving MIN port
    SIGNAL SECOND : std_logic_vector (7 downto 0) ;     -- Signal driving SEC port
    SIGNAL AOP    : std_logic := '0';   -- Signal driving AMPM port

    constant  RATE_1600HZ : natural := 62500;
    signal    DIV_1600HZ  : natural range 0 to RATE_1600HZ - 1;
    signal    ENA_1600HZ  : std_logic;

    signal    ENA_200HZ   : std_logic;
    signal    ENA_NHZ     : std_logic;

    signal    COUNT       : natural range 0 to 199;
    
    signal    FAST_D      : std_logic; 
    signal    SLOW_D      : std_logic; 
    
    SIGNAL    DIGIT_TEMP  : std_logic_vector (1 to 8);

BEGIN 

   -------------------
   U_SEVEN : SEVEN_SEGMENT    -- Instantiation SEVEN_SEGMENT
   -------------------
	PORT MAP ( RESET   => RESET,                   
               CLOCK   => CLOCK,                   
               ENABLE  => ENA_1600HZ,                
               CLEAR   => '0',                     
               HR      => HOUR,
               MIN     => MINUTE,
               SEC     => SECOND,
               AMPM    => AOP,
               DIGIT   => DIGIT_TEMP,   -- Internal signal?
               SEGMENT => SEGMENT     );      
    
    -------------------
    U_DIGITAL : DIGITAL_CLOCK    -- Instantiation DIGITAL_CLOCK
    -------------------
	PORT MAP ( RESET  => RESET,                   
               CLOCK  => CLOCK,                   
               ENABLE => ENA_NHZ,                
               CLEAR  => '0',                     
               HR     => HOUR,
               MIN    => MINUTE,
               SEC    => SECOND,
               AMPM   => AOP          );   
    
    -------------------
    U_FAST : DEBOUNCE    -- Instantiation SEVEN_SEGMENT
    -------------------
	GENERIC MAP ( DELAY  => 16 )
	PORT MAP    ( RESET  => RESET,                   
                  CLOCK  => CLOCK,                   
                  ENABLE => ENA_1600HZ,                
                  DIN    => FAST,                     
                  DOUT   => FAST_D    );   
    
    -------------------
    U_SLOW : DEBOUNCE    -- Instantiation SEVEN_SEGMENT
    -------------------
	GENERIC MAP ( DELAY  => 16 )
	PORT MAP    ( RESET  => RESET,                   
                  CLOCK  => CLOCK,                   
                  ENABLE => ENA_1600HZ,                
                  DIN    => SLOW,                     
                  DOUT   => SLOW_D    );  
                  
                  
   ENA_200HZ <= ENA_1600HZ and DIGIT_TEMP(7);

  ---------------------------------------------
  DIV_1600HZ_PROCESS: process (RESET, CLOCK) begin
  ---------------------------------------------
        if (RESET = '1') then
            DIV_1600HZ  <=  0;
            ENA_1600HZ  <= '0';
        elsif (CLOCK'event and CLOCK = '1') then
            if (TEST = '1') then
                ENA_1600HZ  <= '1';
            elsif(DIV_1600HZ = 0) then
                DIV_1600HZ  <= RATE_1600HZ - 1;
                ENA_1600HZ  <= '1';
            else
                DIV_1600HZ  <= DIV_1600HZ - 1;
                ENA_1600HZ  <= '0';
            end if;
        end if;
    end process;
  
 
    --------------------------------------------
    COUNTER_NHZ_PROCESS: process (CLOCK, RESET) begin
    --------------------------------------------
        if(RESET = '1')then
            COUNT   <= 199;
            ENA_NHZ <= '0';
        elsif(CLOCK'event and CLOCK = '1')then
            if (FAST_D = '1') then  
                ENA_NHZ <= ENA_1600HZ;
                COUNT   <= 199;
            elsif (ENA_200HZ = '0') then
                ENA_NHZ <= '0';  
            elsif (COUNT > 0) then
                COUNT <= COUNT - 1;
                ENA_NHZ <= '0';
            else
                ENA_NHZ <= '1';
                if (SLOW_D = '0') then
                    COUNT <= 199;
                else
                    COUNT <= 99;
                end if;
            end if;
        end if;
    end process;
      
    DIGIT <= DIGIT_TEMP;

END ARCHITECTURE;