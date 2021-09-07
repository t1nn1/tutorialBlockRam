----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/06/2021 09:23:58 AM
-- Design Name: 
-- Module Name: pushData - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- VHDL 2008 xD
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pushData is
    Port ( 
           startImpuls : in std_ulogic; --- is the button input here!
           clk : in STD_LOGIC;
           dataOut : out STD_LOGIC_VECTOR (31 downto 0);
           adr : out STD_LOGIC_VECTOR (31 downto 0);
           EN : out STD_LOGIC;
           WE : out std_logic_vector (3 downto 0) 
           );
end pushData;

architecture Behaviorals of pushData is
    signal startImpulsLocal : std_ulogic;
    signal writeEnable_f : std_ulogic := '0';
    signal currentLEDStatus : integer range 0 to 15 := 0; -- stores 4 LED - status....
    signal bramAdr : STD_LOGIC_VECTOR (31 downto 0 ) ;--:= x"0000";
    signal inttest : integer range 0 to 1;
    
    signal counter: integer range 0 to 15; --- ok this counter counts up for indexing the current adress .........
    type t_Memory is array (0 to 15) of std_logic_vector(31 downto 0);
    signal r_Mem : t_Memory;
    signal clockCounter : integer range 0 to 12048192 :=0;
 
----------------------------------------------------------------
begin
--- this are just data, which should sent out one after another!
    r_Mem(0) <= x"00000000";
    r_Mem(1) <= x"00000001";
    r_Mem(2) <= x"00000002";
    r_Mem(3) <= x"00000003";
    r_Mem(4) <= x"00000004";
    r_Mem(5) <= x"00000005";
    r_Mem(6) <= x"00000006";
    r_Mem(7) <= x"00000007";
    r_Mem(8) <= x"00000008";
    r_Mem(9) <= x"00000009";
    r_Mem(10) <= x"0000000A";
    r_Mem(11) <= x"0000000B";
    r_Mem(12) <= x"0000000C";
    r_Mem(13) <= x"0000000D";
    r_Mem(14) <= x"0000000E";
    r_Mem(15) <= x"0000000F";
---
 ---startImpulsLocal <= startImpuls; --- LATCH?

   
 startCondition : process (clk)
    begin
  
      if (rising_edge (clk) ) then
      
        
        startImpulsLocal<=startImpuls; -- update after each clock cycle :) -- start impuls is the button state!
       -----   start condition!
          if(startImpulsLocal = '0' and startImpuls = '1' ) then -- LATCH?
          -- there was an impulse to start the process!
          -- enable write 16 bars flag...
             writeEnable_f <= '1';
          end if;
--       ------- if impuls was there write 16 led status  into the bram!
          if ( writeEnable_f = '1') then
                            clockCounter <= clockCounter + 1; 
                             if (clockCounter > 10000000) then ---- only if about 3 clock cycles occured... it can control for one clock the BRAM!
                                        if(bramAdr < x"0000000F")then -- if adress still 
                                            --- set next adress and data for BRAM
                                            --- do this because output is std logic... 
                                            bramAdr <= std_logic_vector(to_unsigned(to_integer(unsigned(bramAdr))+1,bramAdr'length)); -- just add 1 to the adress xD
                                            counter <= counter +1; ----for the next data packet----
                                            --dataOut <= x"000F"; -- please change this soon
                                            dataOut<= r_Mem(counter);-- send data
                                            adr <= bramAdr; 
                                            EN <= '1';
                                            WE <= "1111";
                                              if(counter > 14) then  -- this counter selects an adress by index....
                                                    counter <= 0; --- next round !!!
                                              end if;
                                        elsif( bramAdr >= x"0000000F") then --- if = 15 ! ... attention----- RESET
                                             -- disable writing
                                             writeEnable_f <= '0';
                                             EN <= '0';
                                             WE <= "0000";                            
                                        end if;
                                 clockCounter <= 0; ----- reset the clock counter.... after e.g. 3 clock cycles..
                               end if; 
                               
                               
             else -- if no impuls was there
             
            end if;
      end if;  
     
    end process;

end Behaviorals;
