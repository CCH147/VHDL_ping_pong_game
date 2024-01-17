
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity game is
    port(
        clk                                   : in  std_logic;
        Rst                                   : in  std_logic; 
        sw1                                   : in  std_logic;
        sw2                                   : in  std_logic;
        LED                                   : out std_logic_vector(7 downto 0);  -- 4-bit 
        seg                                   : out std_logic_vector(6 downto 0);  -- 7seg L分數 (gfedcba) 
        seg1                                  : out std_logic_vector(6 downto 0)  -- 7seg R分數 (gfedcba) 
        );
end game;

architecture Behavioral of game is
    Type state is ( L0,L1,L2,L3,L4,L5,L6,L7,
                    R0,R1,R2,R3,R4,R5,R6,R7,
                    Lhit,Rhit,
                    Lserve,Rserve,
                    Lwin,Rwin
                   );
    signal current_state         : state;
    signal ping                  : std_logic_vector(7 downto 0);
    signal divclk                : std_logic_vector(26 downto 0);--定義 除頻 訊號
    signal fclk                  : std_logic;                    --定義 除頻 clk
    signal Lscore                : std_logic_vector(3 downto 0);
    signal Rscore                : std_logic_vector(3 downto 0);
    begin
    
    FD:process(clk,Rst)    --除頻器
    begin
        if (Rst = '1') then
            divclk <= (others=>'0');
        elsif (rising_edge(clk)) then
            divclk <= divclk + 1;
        end if;
    end process FD;  
    fclk <= divclk(25); --約 2 Hz
    
    process(fclk,Rst,sw1,sw2)
    begin
        if ( Rst = '1') then
            Lscore <= "0000";
            Rscore <= "0000";
            ping <= "11111111";
            if  (sw1 = '1') then
                current_state <= Lserve;
            end if;
            if  (sw2 = '1') then
                current_state <= Rserve;
            end if;
        elsif (rising_edge(fclk) and Rst = '0' ) then
            case current_state is
                when Lserve =>
                    if sw1 = '1' then 
                        current_state <= L0;
                    end if;
                when Rserve =>
                    if sw2 = '1' then
                        current_state <= R0;
                    end if;
                when Rhit =>
                    if sw2 = '1' then
                        current_state <= R1;
                    else 
                        ping <= "00000000";
                        current_state <= Lwin;
                    end if;
                when Lhit =>
                    if sw1 = '1' then
                        current_state <= L1;
                    else 
                        ping <= "00000000";
                        current_state <= Rwin;
                    end if;
                when Lwin =>
                    Lscore <= Lscore + 1;
                    if Lscore = "0011" then
                        ping <= "00001111";
                    else
                        current_state <= Rserve;
                    end if;
                when Rwin =>
                    Rscore <= Rscore + 1;
                    if Rscore = "0011" then
                        ping <= "11110000";
                    else
                        current_state <= Lserve;
                    end if;
                when  L0    =>
                    ping <= "00000001";
                    current_state <= L1;
                when  L1    =>
                    ping <= "00000010";
                    current_state <= L2;
                when  L2    =>
                    ping <= "00000100";
                    current_state <= L3;                 
                when  L3    =>
                    ping <= "00001000";
                    current_state <= L4;
                when  L4   =>
                    ping <= "00010000";
                    current_state <= L5;
                when  L5    =>
                    ping <= "00100000";
                    current_state <= L6;
                when  L6    =>
                    ping <= "01000000";
                    current_state <= L7;
                when  L7    =>
                    ping <= "10000000";
                    current_state <= Rhit;
                when  R0    =>
                    ping <= "10000000";
                    current_state <= R1;
                when  R1    =>
                    ping <= "01000000";
                    current_state <= R2;
                when  R2    =>
                    ping <= "00100000";
                    current_state <= R3;                 
                when  R3    =>
                    ping <= "00010000";
                    current_state <= R4;
                when  R4   =>
                    ping <= "00001000";
                    current_state <= R5;
                when  R5    =>
                    ping <= "00000100";
                    current_state <= R6;
                when  R6    =>
                    ping <= "00000010";
                    current_state <= R7;
                when  R7    =>
                    ping <= "00000001";
                    current_state <= Lhit;
            end case;
        end if;
    end process;
    LED <= ping;
    
    with Lscore select --7段顯示 (解碼器)
    seg <= "1000000" when "0000",
           "1111001" when "0001",
           "0100100" when "0010",
           "0110000" when "0011",
           "0011001" when "0100",
           "0010010" when "0101",
           "0000011" when "0110",
           "1111000" when "0111",
           "0000000" when "1000",
           "0011000" when "1001",
           "1111111" when others;
        
    with Rscore select --7段顯示 (解碼器)
    seg1 <= "1000000" when "0000",
            "1111001" when "0001",
            "0100100" when "0010",
            "0110000" when "0011",
            "0011001" when "0100",
            "0010010" when "0101",
            "0000011" when "0110",
            "1111000" when "0111",
            "0000000" when "1000",
            "0011000" when "1001",
            "1111111" when others;
            


end Behavioral;
