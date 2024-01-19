
library IEEE;
use IEEE.MATH_REAL.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;


entity game is
    port(
        clk                                   : in  std_logic;
        Rst                                   : in  std_logic; 
        sw1                                   : in  std_logic;                     -- 玩家1
        sw2                                   : in  std_logic;                     -- 玩家2                                 
        LED                                   : out std_logic_vector(7 downto 0);  -- LED ball 
        seg                                   : out std_logic_vector(6 downto 0);  -- 7seg L分數 (gfedcba) 
        seg1                                  : out std_logic_vector(6 downto 0)   -- 7seg R分數 (gfedcba) 
        );
end game;

architecture Behavioral of game is
    Type state is ( start,
                    Lhit,Rhit,
                    Lserve,Rserve,
                    Lwin,Rwin
                   );
    signal current_state         : state;
    signal ping                  : std_logic_vector(7 downto 0);  --ping pong ball LED
    signal divclk                : std_logic_vector(26 downto 0); --定義 除頻 訊號
    signal fclk                  : std_logic;                     --定義 除頻 clk
    signal Lscore                : std_logic_vector(3 downto 0);  --L分數
    signal Rscore                : std_logic_vector(3 downto 0);  --R分數
    begin
    
    FD:process(clk,Rst)    --除頻器
    begin
        if (Rst = '1') then
            divclk <= (others=>'0');
        elsif (rising_edge(clk)) then
            divclk <= divclk + 1;
        end if;
    end process FD;  
    fclk <= divclk(26);    --約 2.9 Hz
    
    
    process(fclk,Rst,sw1,sw2)
    begin
        if ( Rst = '1') then
            Lscore <= "0000";
            Rscore <= "0000";
            ping <= "11111111";
            current_state <= start;
        elsif ( fclk 'event and fclk = '1') then            
            case current_state is
                when start =>
                if     (sw1 = '1') then
                    Lscore <= "0000";
                    Rscore <= "0000";
                    current_state <= Lserve;
                elsif  (sw2 = '1') then
                    Lscore <= "0000";
                    Rscore <= "0000";
                    current_state <= Rserve;
                end if;
                when Lserve =>
                    ping <= "00000001";
                    if sw1 = '1' then 
                        current_state <= Lhit;
                    end if;
                when Rserve =>
                    ping <= "10000000";
                    if sw2 = '1' then
                        current_state <= Rhit;
                    end if;
                when Lwin =>
                    if Lscore = "0011" then
                        ping <= "00001111";
                        Lscore <= "0000";
                        Rscore <= "0000";
                        current_state <= start;
                    else
                        ping <= "0000" & Lscore(3 downto 0);
                        current_state <= Rserve;
                    end if;
                when Rwin =>
                    if Rscore = "0011" then
                        ping <= "11110000";
                        Lscore <= "0000";
                        Rscore <= "0000";
                        current_state <= start;
                    else
                        ping <= (Rscore(0)& Rscore(1)& Rscore(2)& Rscore(3)) & "0000";
                        current_state <= Lserve;
                    end if;
                when  Lhit    =>
                    if    (ping(7) = '1' and sw2 = '1') then
                        current_state <= Rhit;
                    elsif (ping(7) = '0' and sw2 = '1') then
                        Lscore <= Lscore + 1;
                        ping <= "00000000";
                        current_state <= Lwin;
                    elsif (ping(7) = '1' and sw2 = '0') then
                        Lscore <= Lscore + 1;
                        ping <= "00000000";
                        current_state <= Lwin;
                    else
                        ping <= ping(6 downto 0) & ping(7);
                    end if;
                when  Rhit    =>
                    if    (ping(0) = '1' and sw1 = '1') then
                        current_state <= Lhit;
                    elsif (ping(0) = '0' and sw1 = '1') then
                        Rscore <= Rscore + 1;
                        ping <= "00000000";
                        current_state <= Rwin;
                    elsif (ping(0) = '1' and sw1 = '0') then
                        Rscore <= Rscore + 1;
                        ping <= "00000000";
                        current_state <= Rwin;
                    else
                        ping <= ping(0) & ping(7 downto 1);
                    end if;
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