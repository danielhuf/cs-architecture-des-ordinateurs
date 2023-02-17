library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,
        S_LUI,
        S_ADDI,
        S_ADD, 
        S_AND, 
        S_OR, 
        S_ORI,
        S_ANDI,
        S_XOR, 
        S_XORI,
        S_SUB,
        S_SLL,
        S_SRL,
        S_SRA,
        S_SRAI,
        S_SLLI,
        S_SRLI,
        S_AUIPC,
        S_BEQ,
        S_BNE,
        S_BLT,
        S_BGE,
        S_BLTU,
        S_BGEU,
        S_SLT,
        S_SLTI,
        S_SLTU,
        S_SLTIU,
        S_LB, 
        S_LH, 
        S_LW,
	LoadFromMemory, 
        S_LBU, 
        S_LHU,
        S_SB, 
        S_SH, 
        S_SW,
        SaveInTheMemory,
        S_JAL,
        S_JALR,
        ReadNextPCInstruction,
        WriteNewInstructionInPC
    );

    signal state_d, state_q : State_type;
    signal cmd_cs : PO_cs_cmd;


    function arith_sel (IR : unsigned( 31 downto 0 ))
        return ALU_op_type is
        variable res : ALU_op_type;
    begin
        if IR(30) = '0' or IR(5) = '0' then
            res := ALU_plus;
        else
            res := ALU_minus;
        end if;
        return res;
    end arith_sel;

    function logical_sel (IR : unsigned( 31 downto 0 ))
        return LOGICAL_op_type is
        variable res : LOGICAL_op_type;
    begin
        if IR(12) = '1' then
            res := LOGICAL_and;
        else
            if IR(13) = '1' then
                res := LOGICAL_or;
            else
                res := LOGICAL_xor;
            end if;
        end if;
        return res;
    end logical_sel;

    function shifter_sel (IR : unsigned( 31 downto 0 ))
        return SHIFTER_op_type is
        variable res : SHIFTER_op_type;
    begin
        res := SHIFT_ll;
        if IR(14) = '1' then
            if IR(30) = '1' then
                res := SHIFT_ra;
            else
                res := SHIFT_rl;
            end if;
        end if;
        return res;
    end shifter_sel;

begin

    cmd.cs <= cmd_cs;

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

        -- Valeurs par défaut de cmd à définir selon les préférences de chacun
        cmd.rst               <= '0';
        cmd.ALU_op            <= ALU_plus;
        cmd.LOGICAL_op        <= LOGICAL_and;
        cmd.ALU_Y_sel         <= ALU_Y_rf_rs2;

        cmd.SHIFTER_op        <= SHIFT_ll;
        cmd.SHIFTER_Y_sel     <= SHIFTER_Y_rs2;

        cmd.RF_we             <= '0';
        cmd.RF_SIZE_sel       <= RF_SIZE_word;
        cmd.RF_SIGN_enable    <= '1';
        cmd.DATA_sel          <= DATA_from_alu;

        cmd.PC_we             <= '0';
        cmd.PC_sel            <= PC_from_mepc;

        cmd.PC_X_sel          <= PC_X_pc;
        cmd.PC_Y_sel          <= PC_Y_cst_x04;

        cmd.TO_PC_Y_sel       <= TO_PC_Y_cst_x04;

        cmd.AD_we             <= '0';
        cmd.AD_Y_sel          <= AD_Y_immI;

        cmd.IR_we             <= '0';

        cmd.ADDR_sel          <= ADDR_from_pc;
        cmd.mem_we            <= '0';
        cmd.mem_ce            <= '0';

        cmd_cs.CSR_we            <= UNDEFINED;

        cmd_cs.TO_CSR_sel        <= UNDEFINED;
        cmd_cs.CSR_sel           <= UNDEFINED;
        cmd_cs.MEPC_sel          <= UNDEFINED;

        cmd_cs.MSTATUS_mie_set   <= 'U';
        cmd_cs.MSTATUS_mie_reset <= 'U';

        cmd_cs.CSR_WRITE_mode    <= UNDEFINED;

        state_d <= state_q;

        case state_q is
            when S_Error =>
                state_d <= S_Error;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_ce <= '1';
                state_d <= S_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d <= S_Decode;

            when S_Decode =>
                
                case status.IR(6 downto 0) is
                    when "0110111" =>
                    
                        -- PC = PC + 4
                        cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                        cmd.PC_sel <= PC_from_pc;
                        cmd.PC_we <= '1';
                        state_d <= S_LUI;
                        
                    when "0010111" =>
                        -- PC = PC + 4
                        cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                        cmd.PC_sel <= PC_from_pc;
                        cmd.PC_we <= '1';
                        state_d <= S_AUIPC;
                        
                    when "1101111" =>
                    
                        state_d <= S_JAL;
                        
                    when "1100111" =>
                    
                        state_d <= S_JALR;
                        
            
                    when "1100011" =>
                            
                        case status.IR(14 downto 12) is
                            when "000" =>
                                state_d <= S_BEQ;
                                
                            when "001" =>
                                state_d <= S_BNE;

                            when "100" =>
                                state_d <= S_BLT;

                            when "101" =>
                                state_d <= S_BGE;

                            when "110" =>
                                state_d <= S_BLTU;

                            when "111" =>
                                state_d <= S_BGEU;

                            when others =>
                                state_d <= S_Error; -- Pour d ́etecter les rat ́es du d ́ecodage
                                
                        end case;
                        
                    when "0000011" =>
                        -- PC = PC + 4
                        cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                        cmd.PC_sel <= PC_from_pc;
                        cmd.PC_we <= '1';

                        case status.IR(14 downto 12) is
                            when "000" =>
                                state_d <= S_LB;
                                
                            when "001" =>
                                state_d <= S_LH;

                            when "010" =>
                                state_d <= S_LW;

                            when "100" =>
                                state_d <= S_LBU;

                            when "101" =>
                                state_d <= S_LHU;

                            when others =>
                                state_d <= S_Error; -- Pour d ́etecter les rat ́es du d ́ecodage
                                
                        end case;
                        
                    when "0100011" =>
                        -- PC = PC + 4
                        cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                        cmd.PC_sel <= PC_from_pc;
                        cmd.PC_we <= '1';
                        
                        case status.IR(14 downto 12) is
                            when "000" =>
                                state_d <= S_SB; 
                                
                            when "001" =>
                                state_d <= S_SH;

                            when "010" =>
                                state_d <= S_SW;

                            when others =>
                                state_d <= S_Error; -- Pour d ́etecter les rat ́es du d ́ecodage
                                
                        end case;
                        
                    when "0010011" =>
                        -- PC = PC + 4
                        cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                        cmd.PC_sel <= PC_from_pc;
                        cmd.PC_we <= '1';
                            
                        case status.IR(14 downto 12) is
                            when "000" =>
                                state_d <= S_ADDI;

                            when "001" =>
                                state_d <= S_SLLI;
                                
                            when "010" =>
                                state_d <= S_SLTI;
                                
                            when "011" =>
                                state_d <= S_SLTIU;

                            when "100" =>
                                state_d <= S_XORI;

                            when "101" =>
                                if status.IR(31 downto 25) = "0000000" then
                                    state_d <= S_SRLI;
                                else
                                    state_d <= S_SRAI;
                                end if;

                            when "110" =>
                                state_d <= S_ORI;

                            when "111" =>
                                state_d <= S_ANDI;
                            
                            when others =>
                                state_d <= S_Error; -- Pour d ́etecter les rat ́es du d ́ecodage

                        end case;
                        
                    when "0110011" =>
                        -- PC = PC + 4
                        cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                        cmd.PC_sel <= PC_from_pc;
                        cmd.PC_we <= '1';
                            
                        case status.IR(14 downto 12) is
                            when "000" =>
                                if status.IR(31 downto 25) = "0000000" then
                                    state_d <= S_ADD;
                                else
                                    state_d <= S_SUB;
                                end if;
                                
                            when "001" =>
                                state_d <= S_SLL;
                                
                            when "010" =>
                                state_d <= S_SLT;
                                
                            when "011" =>
                                state_d <= S_SLTU;

                            when "100" =>
                                state_d <= S_XOR;

                            when "101" =>
                                if status.IR(31 downto 25) = "0000000" then
                                    state_d <= S_SRL;
                                else
                                    state_d <= S_SRA;
                                end if;

                            when "110" =>
                                state_d <= S_OR;

                            when "111" =>
                                state_d <= S_AND;

                            when others =>
                                state_d <= S_Error; -- Pour d ́etecter les rat ́es du d ́ecodage

                        end case;

                        when others =>
                            state_d <= S_Error; -- Pour d ́etecter les rat ́es du d ́ecodag
                end case;
				
				
                -- Décodage effectif des instructions,
                -- à compléter par vos soins

---------- Instructions avec immediat de type U ----------

        when S_LUI =>

            -- rd <- ImmU + 0
            cmd.PC_X_sel <= PC_X_cst_x00;
            cmd.PC_Y_sel <= PC_Y_immU;
            cmd.RF_we <= '1';
            cmd.DATA_sel <= DATA_from_pc;
            -- lecture [PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;
                  

        when S_AUIPC =>

            -- rd <- ImmU + 0
            cmd.PC_X_sel <= PC_X_pc;
            cmd.PC_Y_sel <= PC_Y_immU;
            cmd.RF_we <= '1';
            cmd.DATA_sel <= DATA_from_pc;
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;

    ---------- Instructions arithmétiques et logiques ----------
        when S_ADD =>

            --rd <- rs1 + rs2
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            cmd.ALU_op <= ALU_plus;
            cmd.DATA_sel <= DATA_from_alu;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;


        when S_ADDI =>

            -- rd <- ImmU + rs1
            cmd.ALU_Y_sel <= ALU_Y_immI;
            cmd.ALU_op <= ALU_plus;
            cmd.DATA_sel <= DATA_from_alu;
            cmd.RF_we <= '1';
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;
            

        when S_SUB =>

            --rd <- rs1 - rs2
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            cmd.ALU_op <= ALU_minus;
            cmd.DATA_sel <= DATA_from_alu;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;


        when S_AND => 

            --rd <- rs1 & rs2
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            cmd.LOGICAL_op <= LOGICAL_and;
            cmd.DATA_sel <= DATA_from_logical;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_OR =>

            --rd <- rs1 | rs2
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            cmd.LOGICAL_op <= LOGICAL_or;
            cmd.DATA_sel <= DATA_from_logical;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_XOR =>

            --rd <- rs1 xor rs2
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            cmd.LOGICAL_op <= LOGICAL_xor;
            cmd.DATA_sel <= DATA_from_logical;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_SRL =>

            --rd <- rs1 >> rs2
            cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
            cmd.SHIFTER_op <= SHIFT_rl;
            cmd.DATA_sel <= DATA_from_shifter;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_SRA =>

            --rd <- rs1 >>> rs2
            cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
            cmd.SHIFTER_op <= SHIFT_ra;
            cmd.DATA_sel <= DATA_from_shifter;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  
                

        when S_SLL =>

            --rd <- rs1 << rs2
            cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
            cmd.SHIFTER_op <= SHIFT_ll;
            cmd.DATA_sel <= DATA_from_shifter;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_ORI =>

            --rd <- rs1 | immI
            cmd.ALU_Y_sel <= ALU_Y_immI;
            cmd.LOGICAL_op <= LOGICAL_or;
            cmd.DATA_sel <= DATA_from_logical;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_ANDI =>

            --rd <- rs1 & immI
            cmd.ALU_Y_sel <= ALU_Y_immI;
            cmd.LOGICAL_op <= LOGICAL_and;
            cmd.DATA_sel <= DATA_from_logical;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_XORI =>

            --rd <- rs1 xor immI
            cmd.ALU_Y_sel <= ALU_Y_immI;
            cmd.LOGICAL_op <= LOGICAL_xor;
            cmd.DATA_sel <= DATA_from_logical;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_SRAI =>

            --rd <- rs1 >>> immI
            cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
            cmd.SHIFTER_op <= SHIFT_ra;
            cmd.DATA_sel <= DATA_from_shifter;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_SLLI =>

            --rd <- rs1 << immI
            cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
            cmd.SHIFTER_op <= SHIFT_ll;
            cmd.DATA_sel <= DATA_from_shifter;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch;  


        when S_SRLI =>

            --rd <- rs1 >>> immI
            cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
            cmd.SHIFTER_op <= SHIFT_rl;
            cmd.DATA_sel <= DATA_from_shifter;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';
            -- next state
            state_d <= S_Fetch; 


        when S_SLT => 

        --rs1 < rs2 ⇒ rd ← 0 31 ∥ 1
        --rs1 ≥ rs2 ⇒ rd ← 0 32
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            cmd.DATA_sel <= DATA_from_slt;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';       
            -- next state
            state_d <= S_Fetch;


        when S_SLTI =>

        --rs1 < (IR20 31 ∥ IR31...20) ⇒ rd ← 0 31 ∥ 1
        --rs1 ≥ (IR20 31 ∥ IR31...20) ⇒ rd ← 0 32
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            cmd.DATA_sel <= DATA_from_slt;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';                    
            -- next state
            state_d <= S_Fetch;


        when S_SLTU =>

        --(0 ∥ rs1) < (0 ∥ rs2) ⇒ rd ← 0  31 ∥ 1
        --(0 ∥ rs1) ≥ (0 ∥ rs2) ⇒ rd ← 0 32
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            cmd.DATA_sel <= DATA_from_slt;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';         
            -- next state
            state_d <= S_Fetch;


        when S_SLTIU =>

        --(0 ∥ rs1) < (0 ∥ (IR20 31 ∥ IR31...20)) ⇒ rd ← 0 31 ∥ 1
        --(0 ∥ rs1 ≥ 0 ∥ (IR20 31 ∥ IR31...20)) ⇒ rd ← 0 32
            cmd.ALU_Y_sel <= ALU_Y_immI;
            cmd.DATA_sel <= DATA_from_slt;
            cmd.RF_we <= '1'; 
            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';            
            -- next state
            state_d <= S_Fetch;
             

    ---------- Instructions de saut ----------

        when S_BEQ =>

            --rs1 = rs2 ⇒ pc ← pc + cst
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            if (status.JCOND) then
                -- pc ← pc + cst
                cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                cmd.PC_sel <= PC_from_pc;  
                cmd.PC_we <= '1';
            else
                -- pc ← pc + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
            end if;

            state_d <= WriteNewInstructionInPC;


        when S_BNE =>

            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
            --rs1 ̸= rs2 ⇒ pc ← pc + cst
            if(status.JCOND) then
                -- pc ← pc + cst
                cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                cmd.PC_sel <= PC_from_pc;  
                cmd.PC_we <= '1';
            else
                -- pc ← pc + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
            end if;

            state_d <= WriteNewInstructionInPC;


        when S_BLT =>

        --rs1 < rs2 ⇒ pc ← pc + cst
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;

            if(status.JCOND) then
                -- pc ← pc + cst
                cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                cmd.PC_sel <= PC_from_pc;  
                cmd.PC_we <= '1';
            else
                -- pc ← pc + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
            end if;

            state_d <= WriteNewInstructionInPC;


        when S_BGE =>

            --rs1 ≥ rs2 ⇒ pc ← pc + cst
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;

            if(status.JCOND) then
                -- pc ← pc + cst
                cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                cmd.PC_sel <= PC_from_pc;  
                cmd.PC_we <= '1';
            else
                -- pc ← pc + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
            end if;

            state_d <= WriteNewInstructionInPC;


        when S_BLTU =>

            --rs1 usg < rs2 ⇒ pc ← pc + cst
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;

            if(status.JCOND) then
                -- pc ← pc + cst
                cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                cmd.PC_sel <= PC_from_pc;  
                cmd.PC_we <= '1';
            else
                -- pc ← pc + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
            end if;

            -- next state
            state_d <= WriteNewInstructionInPC;


        when S_BGEU =>

            --rs1  usg≥ rs2 ⇒ pc ← pc + cst
            cmd.ALU_Y_sel <= ALU_Y_rf_rs2;

            if(status.JCOND) then
                -- pc ← pc + cst
                cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                cmd.PC_sel <= PC_from_pc;  
                cmd.PC_we <= '1';
            else
                -- pc ← pc + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
            end if;

            state_d <= WriteNewInstructionInPC;
            
            
---------- Instructions de chargement à partir de la mémoire ----------

	when S_LW => 

		-- lw rd, imm(rs1)
		cmd.AD_Y_sel <=	AD_Y_immI; 
		cmd.AD_we <= '1'; 
		cmd.ADDR_sel <= ADDR_from_ad; 
		cmd.mem_ce <= '1';
		
		--Adjusting Parameters to the load--
		cmd.RF_SIZE_sel <= RF_SIZE_word; -- load word in rf 
		cmd.RF_SIGN_enable    <= '0'; -- set sign extention
		
		state_d <= LoadFromMemory;

        when S_LB =>

            -- rd <- mem[immi + rs1] mem[immi + rs1]
            cmd.AD_Y_sel <= AD_Y_immI;
            cmd.ADDR_sel <= ADDR_from_ad;
            -- lecture mem[rd]
            cmd.AD_we <= '1';
            cmd.mem_ce <= '1';
            
            --Adjusting Parameters to the load--
            cmd.RF_SIZE_sel <= RF_SIZE_byte;
            cmd.RF_SIGN_enable <= '1';   

            -- next state
            state_d <= LoadFromMemory;


        when S_LBU =>

            -- rd ← 0 24 ∥ mem[(IR20 31 ∥ IR31...20) + rs1]
            cmd.AD_Y_sel <= AD_Y_immI;
            cmd.ADDR_sel <= ADDR_from_ad;
            -- lecture mem[rd]
            cmd.AD_we <= '1';
            cmd.mem_ce <= '1';
            
            --Adjusting Parameters to the load--
            
            cmd.RF_SIZE_sel <= RF_SIZE_byte;
            cmd.RF_SIGN_enable <= '0';   

            -- next state
            state_d <= LoadFromMemory;


        when S_LH =>

            -- rd ← mem[(IR20 31 ∥ IR31...20) + rs1] 16 15 ∥ mem[(IR20 31 ∥ IR31...20) + rs1]15
            cmd.AD_Y_sel <= AD_Y_immI;
            cmd.ADDR_sel <= ADDR_from_ad;
            -- lecture mem[rd]
            cmd.AD_we <= '1';
            cmd.mem_ce <= '1';
            
            --Adjusting Parameters to the load--
            
            cmd.RF_SIZE_sel <= RF_SIZE_half;
            cmd.RF_SIGN_enable <= '1';   

            -- next state
            state_d <= LoadFromMemory;


        when S_LHU =>

            -- rd ← 0 16 ∥ mem[(IR20 31 ∥ IR31...20) + rs1]15...0
            cmd.AD_Y_sel <= AD_Y_immI;
            cmd.ADDR_sel <= ADDR_from_ad;
            -- lecture mem[rd]
            cmd.AD_we <= '1';
            cmd.mem_ce <= '1';
            
            --Adjusting Parameters to the load--
            
            cmd.RF_SIZE_sel <= RF_SIZE_half;
            cmd.RF_SIGN_enable <= '0';   

            -- next state
            state_d <= LoadFromMemory;
----------  ----------
	when LoadFromMemory =>
		cmd.DATA_sel <= DATA_from_mem;  -- write data in rf
		cmd.RF_we <= '1'; -- write enable in rf
		state_d <= ReadNextPCInstruction;
            
---------- Instructions de sauvegarde en mémoire ----------

	when S_SW => -- store a word in memory
		cmd.AD_Y_sel <=	AD_Y_immS; -- selects immS to add with rs1
		cmd.AD_we <= '1'; -- enable AD

		-- next state
		state_d <= SaveInTheMemory;


        when S_SB =>

            -- mem[cst + rs1] <= rs2 7 lowers bits
            cmd.AD_Y_sel <= AD_Y_immS;
            cmd.AD_we <= '1';

            -- next state
            state_d <= SaveInTheMemory;


        when S_SH =>

            -- mem[cst + rs1] ← rs2 15 lowers bits
            cmd.AD_Y_sel <= AD_Y_immS;
            cmd.AD_we <= '1';

            -- next state
            state_d <= SaveInTheMemory;

---------- Instruction to save in the memory----------

	when SaveInTheMemory => -- clock to read/write in memory (coming from AD)
		cmd.ADDR_sel <= ADDR_from_ad; -- selects data from AD to memory
		cmd.mem_ce <= '1'; -- enable lecture in memory
		cmd.mem_we <= '1'; -- enable writing in memory
		state_d <= ReadNextPCInstruction;

---------- Deuxieme instruction aprés saufgarder dans la memoire ----------

        when ReadNextPCInstruction =>

            -- lecture mem[PC]
            cmd.ADDR_sel <= ADDR_from_pc;
            cmd.mem_ce <= '1';
            cmd.mem_we <= '0';            
            -- next state
            state_d <= S_Fetch;        


---------- Instructions d'accès aux CSR ----------

        when S_JAL =>

            -- rd ← pc + 4
            cmd.PC_X_sel <= PC_X_pc;
            cmd.PC_Y_sel <= PC_Y_cst_x04;
            cmd.RF_we <= '1';
            cmd.DATA_sel <= DATA_from_pc;
            
             -- pc ← pc + cst
	    cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;
            cmd.PC_sel <= PC_from_pc; 
	    cmd.PC_we <= '1';
	    
	    state_d <= WriteNewInstructionInPC;
            

        when S_JALR =>

            -- rd ← pc + 4
            cmd.PC_X_sel <= PC_X_pc;
            cmd.PC_Y_sel <= PC_Y_cst_x04;
            cmd.DATA_sel <= DATA_from_pc;
            cmd.RF_we <= '1';
            
            cmd.ALU_Y_sel <= ALU_Y_immI;
            cmd.ALU_op <= ALU_plus;
            cmd.PC_sel <= PC_from_alu; 
            cmd.PC_we <= '1';
            
            -- next state
	    state_d <= WriteNewInstructionInPC;
                        
	    	    
	when WriteNewInstructionInPC =>
	    -- lecture mem[PC]
	    cmd.ADDR_sel <= ADDR_from_pc;
	    cmd.mem_ce <= '1';
	    cmd.mem_we <= '0';
	    -- next state
	    state_d <= S_Fetch;
            
            when others => null;
        end case;


    end process FSM_comb;

end architecture;
