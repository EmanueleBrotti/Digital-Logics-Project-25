library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_add : in std_logic_vector(15 downto 0);
        
        o_done : out std_logic;
        
        o_mem_addr: out std_logic_vector(15 downto 0);
        i_mem_data: in std_logic_vector(7 downto 0);
        o_mem_data: out std_logic_vector(7 downto 0);
        o_mem_we: out std_logic;
        o_mem_en: out std_logic
    );
end project_reti_logiche;

architecture Behaviour of project_reti_logiche is
    component inputDataPath
        port(
        I_mem_data : in std_logic_vector(7 downto 0);
        i_clk: in std_logic;
        KEnable, SEnable, CthreeEnable, CfiveEnable, IEnable, CEnable, EEnable: in std_logic;
        PRST, IRST, ERST: in std_logic;
        K, P: out std_logic_vector(15 downto 0); --p è il contatore di posizione, va da 0 a k
        E: out std_logic_vector(4 downto 0); --E carica la configurazione, va da 0 fino a 17 (compreso)
        S: out std_logic;
        Cvect: out std_logic_vector(55 downto 0); --7 elementi da 8 bit
        svect: out std_logic_vector(55 downto 0)
    );
    end component;
    
    component sumDataPath
    port(
        i_clk: in std_logic;
        Cvect: in std_logic_vector(55 downto 0); --7 elementi da 8 bit
        svect: in std_logic_vector(55 downto 0);
        TEnable, TRST: in std_logic;
        t: out std_logic_vector(1 downto 0); --va da 3 a 0
        ris: out std_logic_vector(18 downto 0) --unico valore processato, richiede il doppio dei bit per la moltiplicazione + 3 bit per le somme dei risultati intermedi
    );
    end component;
    
    component NormDataPath
    port(
        i_clk: in std_logic;
        S: in std_logic;
        Ris: in std_logic_vector(18 downto 0);
        O_mem_data: out std_logic_vector(7 downto 0)
    );
    end component;
    
    component FSA
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_start: in std_logic;
        i_add: in std_logic_vector(15 downto 0);
        
        o_done: out std_logic;
        o_mem_we: out std_logic;
        o_mem_en: out std_logic;
        o_mem_addr: out std_logic_vector(15 downto 0);
        
        E: in std_logic_vector(4 downto 0); --clock
        T: in std_logic_vector(1 downto 0);
        K, P: in std_logic_vector(15 downto 0);
        EEnable, CEnable, TEnable: out std_logic;
        PRST, TRST, ERST: out std_logic;
        
        KEnable, SEnable, CthreeEnable, CfiveEnable, IEnable: out std_logic; --registri
        IRST: out std_logic --gli in put sono gli unici che devono assolutamente partire puliti
    );
    end component;
    
    signal KEnableS, SEnableS, CthreeEnableS, CfiveEnableS, IEnableS, CEnableS, EEnableS, TEnableS: std_logic;
    signal SS: std_logic;
    signal PRSTS, IRSTS, ERSTS, TRSTS: std_logic;
    signal KS, PS: std_logic_vector(15 downto 0);
    signal RisS: std_logic_vector(18 downto 0);
    signal ES: std_logic_vector(4 downto 0);
    signal TS: std_logic_vector(1 downto 0);
    signal CvectS, SvectS: std_logic_vector(55 downto 0);
begin 
    C1: inputDataPath
        port map (
            i_mem_data => i_mem_data,
            i_clk => i_clk,
            KEnable => KEnableS,
            SEnable => SEnableS,
            CthreeEnable => CthreeEnableS,
            CfiveEnable => CfiveEnableS,
            IEnable => IEnableS,
            CEnable => CEnableS,
            EEnable => EEnableS,
            PRST => PRSTS,
            IRST => IRSTS, 
            ERST => ERSTS,
            K => KS,
            P => PS,
            E => ES,
            S => SS,
            Cvect => CvectS,
            svect => SvectS
        );
        
    C2: sumDataPath
        port map (
            i_clk => i_clk,
            Cvect => CvectS,
            svect => SvectS,
            TEnable => TEnableS,
            TRST => TRSTS,
            t => ts,
            ris => risS
        );
        
    c3: NormDataPath
        port map(
            i_clk => i_clk,
            S => SS,
            Ris => RisS,
            O_mem_data =>  O_mem_data
        );
    
    c4: FSA
        port map(
            i_clk => i_clk,
            i_rst => i_rst,
            i_start => i_start,
            i_add => i_add,
            
        
            o_done => o_done,
            o_mem_we => o_mem_we,
            o_mem_en => o_mem_en,
            o_mem_addr => o_mem_addr,
        
            E => ES,
            T => TS,
            K => KS,
            P => PS,
            EEnable => EEnableS,
            CEnable => CEnableS,
            TEnable => TEnableS,
            PRST => PRSTS,
            TRST => TRSTS,
            ERST => ERSTS,
        
            KEnable => KEnableS,
            SEnable => SEnableS,
            CthreeEnable => CthreeEnableS,
            CfiveEnable => CfiveEnableS,
            IEnable => IEnableS,
            IRST => IRSTS
        );
end Behaviour;

------------------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity inputDataPath is --prende gli inputs e li mette in shiftreg diversi, sceglie i coefficienti giusti per il filtro e riempe i dati in ingresso
    port(
        I_mem_data : in std_logic_vector(7 downto 0);
        i_clk: in std_logic;
        KEnable, SEnable, CthreeEnable, CfiveEnable, IEnable, CEnable, EEnable: in std_logic;
        PRST, IRST, ERST: in std_logic;
        K, P: out std_logic_vector(15 downto 0); 
        E: out std_logic_vector(4 downto 0); 
        S: out std_logic;
        Cvect: out std_logic_vector(55 downto 0);
        svect: out std_logic_vector(55 downto 0)
    );
end inputDataPath;

architecture inputBev of inputDataPath is
    signal Kshiftreg : std_logic_vector(15 downto 0);
    signal Sshiftreg : std_logic_vector(7 downto 0);
    signal Cthreeshiftreg, Cfiveshiftreg, Ishiftreg: std_logic_vector(55 downto 0); 
    signal Pcount : unsigned(15 downto 0);
    signal Ecount: unsigned(4 downto 0);
    signal PequalsK: std_logic; --solo per facilità di scrittura, usato dai dati in ingresso
begin
    process(i_clk) 
    begin
        if rising_edge(i_clk) then
            if KEnable = '1' then --shiftreg k
                Kshiftreg <= Kshiftreg(7 downto 0) & I_mem_data; --shift a sinistra
            end if;
            
            if SEnable='1' then --shiftreg s
                Sshiftreg <= I_mem_data; 
            end if;
            
            if CthreeEnable = '1' then --shiftreg C ordine 3
                Cthreeshiftreg <= Cthreeshiftreg(47 downto 0) & I_mem_data; 
            end if;
            
            if CfiveEnable = '1' then --shiftreg C ordine 3
                Cfiveshiftreg <= Cfiveshiftreg(47 downto 0) & I_mem_data;
            end if;
        end if;
    end process;
    
    PequalsK <= '1' when (unsigned(kshiftreg) = Pcount) else '0'; 
    
    process(i_clk, IRST) --faccio lo shiftreg degli input separato per facilità, durante un reset si annulla
    begin
        if IRST='1' then
            Ishiftreg <= (others => '0'); --reset
        elsif rising_edge(i_clk) then --non voglio che succedino entrambe contemporaneamente
            if IEnable = '1' then
                if PequalsK='0' then --quando finisco i dati in ingresso (P=K) riempio di 0 per terminare gli ultimi calcoli
                    Ishiftreg <= (Ishiftreg(47 downto 0) & I_mem_data); 
                else 
                    Ishiftreg <= (Ishiftreg(47 downto 0) & "00000000"); 
                end if;
            end if;
        end if;
    end process;
    
    process(i_clk, PRST) --counter da 0 a k
    begin
        if PRST = '1' then
            Pcount <= (others => '0');
        elsif rising_edge(i_clk) then
            if CEnable='1' then 
                if Pcount < unsigned(kshiftreg) then
                    Pcount <= Pcount+1; 
                end if;
            end if;
        end if;
    end process;
    
    process(i_clk, ERST) --counter da 0 a 17
    begin
        if ERST = '1' then
            Ecount <= (others => '0');
        elsif rising_edge(i_clk) then
            if EEnable='1' then
                if Ecount < 17  then
                    Ecount <= Ecount+1;
                end if;
            end if;
        end if;
    end process;
    
    K <= Kshiftreg; --assegnamento degli shiftreg
    S <= Sshiftreg(0); --mi interessa solo il bit meno significativo
    cvect <= ("00000000" & Cthreeshiftreg(47 downto 8) & "00000000") when Sshiftreg(0)='0' else Cfiveshiftreg; --sceglie i coefficienti giusti in base al valore di S
    --il filtro di ordine 3 non userà mai i coefficienti più esterni -> li rendo nulli per poterli sommare
    svect <= Ishiftreg;
    P <= std_logic_vector(Pcount);
    E <= std_logic_vector(Ecount);
    
    
end inputBev;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sumDataPath is --gestisce le somme tra coefficienti e il counter per gli elementi iniziali
    port(
        i_clk: in std_logic;
        Cvect: in std_logic_vector(55 downto 0); --7 elementi da 8 bit
        svect: in std_logic_vector(55 downto 0);
        TEnable, TRST: in std_logic;
        t: out std_logic_vector(1 downto 0); --va da 3 a 0
        ris: out std_logic_vector(18 downto 0) --unico valore processato, richiede il doppio dei bit per la moltiplicazione
    );
end sumDataPath;

architecture sumBev of sumDataPath is
    signal Tcount: unsigned(1 downto 0);
    signal Rreg: signed(18 downto 0);
    signal c0, c1, c2, c3, c4, c5, c6: signed(7 downto 0); --escono più righe ma lo rende facile da leggere
    signal s0, s1, s2, s3, s4, s5, s6: signed(7 downto 0);
    
begin

    c0 <= signed(cvect(55 downto 48)); --il primo messo nello shiftreg 
    c1 <= signed(cvect(47 downto 40));
    c2 <= signed(cvect(39 downto 32));
    c3 <= signed(cvect(31 downto 24));
    c4 <= signed(cvect(23 downto 16));
    c5 <= signed(cvect(15 downto 8));
    c6 <= signed(cvect(7 downto 0));
    s0 <= signed(svect(55 downto 48)); --l'input più vecchio
    s1 <= signed(svect(47 downto 40));
    s2 <= signed(svect(39 downto 32));
    s3 <= signed(svect(31 downto 24));
    s4 <= signed(svect(23 downto 16));
    s5 <= signed(svect(15 downto 8));
    s6 <= signed(svect(7 downto 0));

    process(i_clk, TRST) --clock fino a 3
    begin
        if TRST='1' then
            Tcount <= "00";
        elsif rising_edge(i_clk) then
            if TEnable='1' then
                if Tcount<3 then 
                    Tcount <= Tcount + 1;
                end if;
            end if;
        end if;
    end process; 
    
    process(i_clk) --registro del risultato
    begin
        if rising_edge(i_clk) then
             Rreg <= resize((s0 * c0), 19) + resize((s1 * c1), 19) + resize((s2 * c2), 19) + resize((s3 * c3), 19) + resize((s4 * c4), 19) + resize((s5 * c5), 19) + resize((s6 * c6), 19);
             
             
             
        end if;
    end process;
    
    T <= std_logic_vector(Tcount);
    Ris <= std_logic_vector(Rreg);
    
end sumBev;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity NormDataPath is
    port(
        i_clk: in std_logic;
        S: in std_logic;
        Ris: in std_logic_vector(18 downto 0);
        O_mem_data: out std_logic_vector(7 downto 0)
    );
end NormDataPath;

architecture NormBev of NormDataPath is
    signal N: signed(1 downto 0); --controlla se ris < 0
    signal fiveDiv, threeDiv, total: signed(18 downto 0); --5° ha shift in comune mentre 3° aggiunge valori
    --le operazioni usano 2 byte, taglio alla fine
    signal s1024, s64, s16, s256: signed(18 downto 0);
    signal noReg: std_logic_vector(7 downto 0); 
begin
    N <= "01" when signed(Ris) < 0 else "00"; --avrei anche potuto controllare solo il bit del segno
    
    
    s16 <= shift_right(signed(ris), 4);
    s64 <= shift_right(signed(ris), 6);
    s256 <= shift_right(signed(ris), 8);
    s1024 <= shift_right(signed(ris), 10);
    
    
    fiveDiv <= (s1024 + s64 + N + N);
    threeDiv <= (s256 + s16 + N + N) when s='0' else (others => '0'); --aggiungo valori solo se s=0-> ordine 3
    total <= fiveDiv + threeDiv;
    
    process(i_clk) --registro del risultato
    begin
        if rising_edge(i_clk) then
            if total > 127 then --saturazione del dato in caso sfociasse il range
                Noreg <= "01111111";
            elsif total < -128 then
                Noreg <= "10000000";
            else
                Noreg <= std_logic_vector(total(7 downto 0)); --taglio il risultato agli 8 meno significativi
            end if;
        end if;
    end process;
    
    O_mem_data <= Noreg;
    
end NormBev;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSA is
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_start: in std_logic;
        i_add: in std_logic_vector(15 downto 0);
        
        
        o_done: out std_logic;
        o_mem_we: out std_logic;
        o_mem_en: out std_logic;
        o_mem_addr: out std_logic_vector(15 downto 0);
        
        E: in std_logic_vector(4 downto 0); --clock
        T: in std_logic_vector(1 downto 0);
        K, P: in std_logic_vector(15 downto 0);
        EEnable, CEnable, TEnable: out std_logic;
        PRST, TRST, ERST: out std_logic;
        
        KEnable, SEnable, CthreeEnable, CfiveEnable, IEnable: out std_logic; --registri
        IRST: out std_logic 
    );
end FSA;

architecture FSABev of FSA is
    type state is (START, E1, I2, R3, L, W, RF, DONE);
    signal curr_state, next_state: state;
begin

    process(i_clk, i_rst) --gestione degli stati + reset
    begin
        if i_rst = '1' then --reset asincrono
            curr_state <= START;
        elsif rising_edge(i_clk) then
            curr_state <= next_state;
        end if;
    end process;
    
    process (curr_state, i_start, E, T) --stato prossimo
    begin
        next_state <= curr_state; --caso di default
        
        case curr_state is
            when START=>
                if i_start='1' then
                    next_state <= E1;
                end if;
            WHEN E1=>
                if unsigned(E) > 16 then --supera 16 -> ho letto 17 input (la configurazione)
                    next_state <= I2;
                end if;
            WHEN I2 =>
                if unsigned(T) = 3 then --ho caricato 3 elementi non processati  + 1 da processare
                    next_state <= R3;
                end if;
            WHEN R3 =>
                next_state <= L; --stato intermedio che resetta alcuni componenti
            WHEN L =>
                next_state <= W;
            WHEN W =>
                if unsigned(T) = 3 then --ho elaborato tutti i dati
                    next_state <= RF;
                else 
                    next_state <= L;
                end if;
            WHEN RF => --il problema chiede di finire i caricamenti in memo prima di done
                next_state <= DONE;
            WHEN DONE =>
                if i_start='0' then
                    next_state <= START;
                end if;
        end case;
    end process;
    
    process (curr_state, e, T, p, i_rst, i_add, k) --valori dello stato attuale, l'ho diviso in 2 processi diversi per semplicità
    begin --avrei dovuto dividere ulteriormente il processo per una minore sensibility list, ma visto che non viene valutata la performance
    --in molte parti del codice ho preferito la facilità di lettura
    --inizializzazione dei valori di default, stati diversi li modificheranno:
        
        PRST <= '0';
        TRST <= '0';
        IRST <= '0';
        ERST <= '0';
        
        KEnable <= '0';
        SEnable <= '0';
        CThreeEnable <= '0';
        CFiveEnable <= '0';
        IEnable <= '0';
        CEnable <= '0';
        TEnable <= '0';
        EEnable <= '0';
        o_mem_en <= '0';
        o_mem_we <= '0';
        o_mem_addr <= (others=>'0');
        o_done <= '0';
        
        if i_rst = '1' then --non voglio assolutamente che uno stato possa sovrascrivere il reset
            ERST <= '1';
            TRST <= '1';
            IRST <= '1';
            PRST <= '1';
        else 
        case curr_state is
            --start non fa niente 
            WHEN START => null;
            WHEN E1=>
                EEnable <= '1'; -- E conta quanti parametri di configurazione ho inserito
                o_mem_en <= '1';
                o_mem_addr <= std_logic_vector(unsigned(i_add) + resize(unsigned(E), 16) ); --quando leggo avrò incrementato E di 1
                if unsigned(e) < 3 then --controllo dove salvare il dato
                    KEnable <= '1';
                elsif unsigned(e) = 3 then --uno è s
                    SEnable <= '1';
                elsif unsigned(e) < 11 then --7 sono cthree
                    CthreeEnable <= '1';
                else --gli altri sono cfive
                    CfiveEnable <= '1';
                end if;
                
            WHEN I2 => --legge i primi 4 dati in ingresso
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + unsigned(P) + 18); 
                    o_mem_en <= '1';
                    IEnable <= '1';
                    CEnable <= '1';
                    TEnable <= '1';
                
            WHEN R3 => --stato semplice di reset
                TRST <= '1';
                ERST <= '1';
                IEnable <= '1';
            WHEN L =>
                 o_mem_en <= '1';
                 
                 o_mem_addr <= std_logic_vector(unsigned(i_add) + unsigned(P) + 18 + resize(unsigned(T), 16));
                 
                 if (unsigned(p) < unsigned(k)) then --se p<k ho ancora elementi da caricare, altrimenti finisco gli ultimi
                     CEnable <= '1';
                 else
                     TEnable <= '1';
                 end if; 
                
            WHEN W =>
                IEnable <= '1';
                o_mem_en <= '1';
                o_mem_we <= '1';
                
                --ho un offset di 4 elementi caricati dalla partenza + post lettura ho p++ -> 17-5 = 12
                 o_mem_addr <= std_logic_vector(unsigned(i_add) + unsigned(P) + 12 + resize(unsigned(T), 16) + unsigned(k));
            
            WHEN RF => 
                --pulizia per la prossima elaborazione
                ERST <= '1';
                TRST <= '1';
                IRST <= '1';
                PRST <= '1';
                --caricamento ultimo dato
                o_mem_en <= '1';
                o_mem_we <= '1';
                o_mem_addr <= std_logic_vector(unsigned(i_add) + unsigned(k) + unsigned(k) + 16);
                
            WHEN DONE => --potevo unirlo a RF ma l'ho tenuto separato per pulizia
                o_done <= '1';
        end case;
        end if;
        
    end process;

end FSABev;
