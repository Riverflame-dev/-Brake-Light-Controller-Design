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
entity DEBOUNCE is
--------------------------------
    GENERIC ( DELAY  :     natural := 10 );   
    port    ( RESET  : in  std_logic;                  	-- Active high master reset
              ENABLE : in  std_logic;
              CLOCK  : in  std_logic;
              DIN  	 : in  std_logic;                   -- Fast time set control
              DOUT   : out std_logic     ); 
end entity;

--------------------------
ARCHITECTURE RTL OF DEBOUNCE IS
--------------------------
    SIGNAL DINFF  : std_logic;
    SIGNAL DOUTFF : std_logic;
    SIGNAL COUNT  : natural range 0 to DELAY - 1;

BEGIN 

    -- Process to implement DELAY COUNTER 
    ---------------------------------------------- 
    DELAY_COUNTER: PROCESS (RESET, CLOCK) BEGIN 
    ----------------------------------------------
        if (RESET = '1') then
            COUNT <= DELAY - 1;
        elsif (CLOCK'event and CLOCK = '1') then 
            if (ENABLE = '1') then
                if (COUNT > 0) then
                    COUNT  <= COUNT - 1;
                elsif (DINFF /= DOUTFF) then
                    COUNT  <= DELAY - 1;
                end if;
           end if;
        end if;     
    END PROCESS;
    
    -- Process to update DINFF and DOUTFF 
    ---------------------------------------------- 
    OUTPUT_PROCESS: PROCESS (RESET, CLOCK) BEGIN 
    ----------------------------------------------
        if (RESET = '1') then
            DINFF  <= '0';
            DOUTFF <= '0';
        elsif (CLOCK'event and CLOCK = '1') then
            if (ENABLE = '1') then
                DINFF <= DIN;
                if (COUNT = 0) then
                    DOUTFF <= DINFF;
                end if;
            end if; 
        end if;     
    END PROCESS;
    
    DOUT <= DOUTFF;
    
END ARCHITECTURE;