--
-- Copyright 2019 International Business Machines
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_ARITH.all;

library work;
use work.Stream_pkg.all;

entity action_example is
    generic (
        -- Parameters of Axi Master Bus Interface AXI_CARD_MEM0 ; to DDR memory
        C_AXI_CARD_MEM0_ID_WIDTH     : integer   := 2;
        C_AXI_CARD_MEM0_ADDR_WIDTH   : integer   := 33;
        C_AXI_CARD_MEM0_DATA_WIDTH   : integer   := 512;
        C_AXI_CARD_MEM0_AWUSER_WIDTH : integer   := 1;
        C_AXI_CARD_MEM0_ARUSER_WIDTH : integer   := 1;
        C_AXI_CARD_MEM0_WUSER_WIDTH  : integer   := 1;
        C_AXI_CARD_MEM0_RUSER_WIDTH  : integer   := 1;
        C_AXI_CARD_MEM0_BUSER_WIDTH  : integer   := 1;

        -- Parameters of Axi Slave Bus Interface AXI_CTRL_REG
        C_AXI_CTRL_REG_DATA_WIDTH    : integer   := 32;
        C_AXI_CTRL_REG_ADDR_WIDTH    : integer   := 32;

        -- Parameters of Axi Master Bus Interface AXI_HOST_MEM ; to Host memory
        C_AXI_HOST_MEM_ID_WIDTH      : integer   := 2;
        C_AXI_HOST_MEM_ADDR_WIDTH    : integer   := 64;
        C_AXI_HOST_MEM_DATA_WIDTH    : integer   := 512;
        C_AXI_HOST_MEM_AWUSER_WIDTH  : integer   := 1;
        C_AXI_HOST_MEM_ARUSER_WIDTH  : integer   := 1;
        C_AXI_HOST_MEM_WUSER_WIDTH   : integer   := 1;
        C_AXI_HOST_MEM_RUSER_WIDTH   : integer   := 1;
        C_AXI_HOST_MEM_BUSER_WIDTH   : integer   := 1;
        INT_BITS                     : integer   := 64;
        CONTEXT_BITS                 : integer   := 8
    );
    port (
        action_clk              : in STD_LOGIC;
        action_rst_n            : in STD_LOGIC;
        int_req_ack             : in STD_LOGIC;
        int_req                 : out std_logic;
        int_src                 : out std_logic_vector(INT_BITS-1 DOWNTO 0);
        int_ctx                 : out std_logic_vector(CONTEXT_BITS-1 DOWNTO 0);

        --

        -- Ports of Axi Slave Bus Interface AXI_CTRL_REG
        axi_ctrl_reg_awaddr     : in std_logic_vector(C_AXI_CTRL_REG_ADDR_WIDTH-1 downto 0);
		-- axi_ctrl_reg_awprot : in std_logic_vector(2 downto 0);
        axi_ctrl_reg_awvalid    : in std_logic;
        axi_ctrl_reg_awready    : out std_logic;
        axi_ctrl_reg_wdata      : in std_logic_vector(C_AXI_CTRL_REG_DATA_WIDTH-1 downto 0);
        axi_ctrl_reg_wstrb      : in std_logic_vector((C_AXI_CTRL_REG_DATA_WIDTH/8)-1 downto 0);
        axi_ctrl_reg_wvalid     : in std_logic;
        axi_ctrl_reg_wready     : out std_logic;
        axi_ctrl_reg_bresp      : out std_logic_vector(1 downto 0);
        axi_ctrl_reg_bvalid     : out std_logic;
        axi_ctrl_reg_bready     : in std_logic;
        axi_ctrl_reg_araddr     : in std_logic_vector(C_AXI_CTRL_REG_ADDR_WIDTH-1 downto 0);
        -- axi_ctrl_reg_arprot  : in std_logic_vector(2 downto 0);
        axi_ctrl_reg_arvalid    : in std_logic;
        axi_ctrl_reg_arready    : out std_logic;
        axi_ctrl_reg_rdata      : out std_logic_vector(C_AXI_CTRL_REG_DATA_WIDTH-1 downto 0);
        axi_ctrl_reg_rresp      : out std_logic_vector(1 downto 0);
        axi_ctrl_reg_rvalid     : out std_logic;
        axi_ctrl_reg_rready     : in std_logic;

        -- Ports of Axi Master Bus Interface AXI_HOST_MEM
        -- to HOST memory
        axi_host_mem_awaddr   : out std_logic_vector(C_AXI_HOST_MEM_ADDR_WIDTH-1 downto 0);
        axi_host_mem_awlen    : out std_logic_vector(7 downto 0);
        axi_host_mem_awsize   : out std_logic_vector(2 downto 0);
        axi_host_mem_awburst  : out std_logic_vector(1 downto 0);
        axi_host_mem_awlock   : out std_logic_vector(1 downto 0);
        axi_host_mem_awcache  : out std_logic_vector(3 downto 0);
        axi_host_mem_awprot   : out std_logic_vector(2 downto 0);
        axi_host_mem_awregion : out std_logic_vector(3 downto 0);
        axi_host_mem_awqos    : out std_logic_vector(3 downto 0);
        axi_host_mem_awvalid  : out std_logic;
        axi_host_mem_awready  : in std_logic;
        axi_host_mem_wdata    : out std_logic_vector(C_AXI_HOST_MEM_DATA_WIDTH-1 downto 0);
        axi_host_mem_wstrb    : out std_logic_vector(C_AXI_HOST_MEM_DATA_WIDTH/8-1 downto 0);
        axi_host_mem_wlast    : out std_logic;
        axi_host_mem_wvalid   : out std_logic;
        axi_host_mem_wready   : in std_logic;
        axi_host_mem_bresp    : in std_logic_vector(1 downto 0);
        axi_host_mem_bvalid   : in std_logic;
        axi_host_mem_bready   : out std_logic;
        axi_host_mem_araddr   : out std_logic_vector(C_AXI_HOST_MEM_ADDR_WIDTH-1 downto 0);
        axi_host_mem_arlen    : out std_logic_vector(7 downto 0);
        axi_host_mem_arsize   : out std_logic_vector(2 downto 0);
        axi_host_mem_arburst  : out std_logic_vector(1 downto 0);
        axi_host_mem_arlock   : out std_logic_vector(1 downto 0);
        axi_host_mem_arcache  : out std_logic_vector(3 downto 0);
        axi_host_mem_arprot   : out std_logic_vector(2 downto 0);
        axi_host_mem_arregion : out std_logic_vector(3 downto 0);
        axi_host_mem_arqos    : out std_logic_vector(3 downto 0);
        axi_host_mem_arvalid  : out std_logic;
        axi_host_mem_arready  : in std_logic;
        axi_host_mem_rdata    : in std_logic_vector(C_AXI_HOST_MEM_DATA_WIDTH-1 downto 0);
        axi_host_mem_rresp    : in std_logic_vector(1 downto 0);
        axi_host_mem_rlast    : in std_logic;
        axi_host_mem_rvalid   : in std_logic;
        axi_host_mem_rready   : out std_logic;
		--      axi_host_mem_error    : out std_logic;
        axi_host_mem_arid     : out std_logic_vector(C_AXI_HOST_MEM_ID_WIDTH-1 downto 0);
        axi_host_mem_aruser   : out std_logic_vector(C_AXI_HOST_MEM_ARUSER_WIDTH-1 downto 0);
        axi_host_mem_awid     : out std_logic_vector(C_AXI_HOST_MEM_ID_WIDTH-1 downto 0);
        axi_host_mem_awuser   : out std_logic_vector(C_AXI_HOST_MEM_AWUSER_WIDTH-1 downto 0);
        axi_host_mem_bid      : in std_logic_vector(C_AXI_HOST_MEM_ID_WIDTH-1 downto 0);
        axi_host_mem_buser    : in std_logic_vector(C_AXI_HOST_MEM_BUSER_WIDTH-1 downto 0);
        axi_host_mem_rid      : in std_logic_vector(C_AXI_HOST_MEM_ID_WIDTH-1 downto 0);
        axi_host_mem_ruser    : in std_logic_vector(C_AXI_HOST_MEM_RUSER_WIDTH-1 downto 0);
        axi_host_mem_wuser    : out std_logic_vector(C_AXI_HOST_MEM_WUSER_WIDTH-1 downto 0)
);
end action_example;

architecture action_example of action_example is


 -- --
 -- -- ILA core
 -- --
 -- component ila_p16 is
 --   port (
 --     clk    : IN    STD_LOGIC;
 --     probe0 : IN    STD_LOGIC_VECTOR(15 downto 0)
 --   );  -- : 
 -- end component ila_p16;

  type   state_t    is (IDLE, STARTING, RUNNING, FINISH);

  type reg_type_read is record
    state                 : state_t;
    addr                  : std_logic_vector( 63 downto 0);
    counter_q             : std_logic_vector( 31 downto 0);
    idle                  : std_logic;
    ready                 : std_logic;
    done                  : std_logic;
  end record;
  
  type reg_type_write is record
    state                 : state_t;
    addr                  : std_logic_vector( 63 downto 0);
    counter_q             : std_logic_vector( 23 downto 0);
    idle                  : std_logic;
    ready                 : std_logic;
    done                  : std_logic;
  end record;
  
	signal read_r           : reg_type_read;
	signal read_d           : reg_type_read;
	signal write_r          : reg_type_write;
	signal write_d          : reg_type_write;

--        type   read_state_t    is (IDLE, START_READING, READING);
--        signal read_state        : read_state_t;


    signal reg_0x20         : std_logic_vector(31 downto 0);
    signal reg_0x30         : std_logic_vector(31 downto 0);
    signal reg_0x34         : std_logic_vector(31 downto 0);
    signal reg_0x38         : std_logic_vector(31 downto 0);
    signal reg_0x3c         : std_logic_vector(31 downto 0);
    signal reg_0x40         : std_logic_vector(31 downto 0);
    signal reg_0x44         : std_logic_vector(31 downto 0);
    signal reg_0x48         : std_logic_vector(31 downto 0);
    signal reg_0x4c         : std_logic_vector(31 downto 0);
    signal app_start        : std_logic;
    signal app_done         : std_logic;
    signal app_ready        : std_logic;
    signal app_idle         : std_logic;
    signal axi_host_mem_awvalid_in: std_logic;
    signal axi_host_mem_arvalid_in: std_logic;

    signal dma_rd_req        : std_logic;
    signal dma_rd_req_ack    : std_logic;
    signal rd_addr           : std_logic_vector( 63 downto 0);
    signal rd_len            : std_logic_vector(  7 downto 0);
    signal dma_rd_data       : std_logic_vector(511 downto 0);
    signal dma_rd_data_valid : std_logic;
    signal dma_rd_data_taken : std_logic;

    signal dma_wr_req        : std_logic;
    signal dma_wr_req_ack    : std_logic;
    signal wr_addr           : std_logic_vector( 63 downto 0);
    signal wr_len            : std_logic_vector(  7 downto 0);
    signal wr_data           : std_logic_vector(511 downto 0);
    signal dma_wr_data_strobe: std_logic_vector( 63  downto 0);
    signal dma_wr_data_last  : std_logic;
    signal dma_wr_ready      : std_logic;
    signal dma_wr_bready     : std_logic;
    signal dma_wr_done       : std_logic;

    signal reg0_ready        : std_logic;
    signal reg0_valid        : std_logic;
    signal reg0_data         : std_logic_vector(511 downto 0);

    signal int_enable        : std_logic;
		
	signal action_rst       : std_logic;
		
	signal serializer_out_valid  : std_logic;
    signal serializer_out_ready  : std_logic;
    signal serializer_out_data   : std_logic_vector( 31  downto 0);
    signal serializer_out_count  : std_logic_vector( 0  downto 0);
    signal serializer_out_last   : std_logic;
		
	signal valid_in  : std_logic;
    signal ready_in  : std_logic;
    signal data_in   : std_logic_vector( 31  downto 0);

	signal label_o      : std_logic_vector( 9  downto 0);
	signal label_valid   : std_logic;

	signal wr_count: std_logic_vector( 23  downto 0);
	signal wr_count_q: std_logic_vector( 23  downto 0);
		
	component ResNet18_Top is
	port(
		     		i_sclk     : in std_logic;
              		i_rstp     : in std_logic;
			        
	      		    i_valid   : in std_logic;
              		o_ready  : out std_logic;
              		i_tdata    : in std_logic_vector( 31 downto 0);
              
	      		    o_valid   : out std_logic;
              		i_ready  : in std_logic;
              		o_tdata    : out std_logic_vector( 9 downto 0)
		);
	end component ResNet18_Top;
    
        function or_reduce (signal arg : std_logic_vector) return std_logic is
          variable result : std_logic;

        begin
          result := '0';
          for i in arg'low to arg'high loop
            result := result or arg(i);
          end loop;  -- i
          return result;
        end or_reduce;


begin

    int_ctx <= reg_0x20(CONTEXT_BITS - 1 downto 0);
    int_src <= reg_0x4c & reg_0x48; 


-- Instantiation of Axi Bus Interface AXI_CTRL_REG
action_axi_slave_inst : entity work.action_axi_slave
    generic map (
        C_S_AXI_DATA_WIDTH  => C_AXI_CTRL_REG_DATA_WIDTH,
        C_S_AXI_ADDR_WIDTH  => C_AXI_CTRL_REG_ADDR_WIDTH
    )
    port map (
        -- config reg ; bit 0 => disable dma and
        -- just count down the length regsiter
        int_enable_o    => int_enable,
        reg_0x10_i      => x"1014_2000",  -- action type
        reg_0x14_i      => x"0000_0000",  -- action version
        reg_0x20_o      => reg_0x20,
        reg_0x30_o      => reg_0x30,
        -- low order source address
        reg_0x34_o      => reg_0x34,
        -- high order source  address
        reg_0x38_o      => reg_0x38,
        -- low order destination address
        reg_0x3c_o      => reg_0x3c,
        -- high order destination address
        reg_0x40_o      => reg_0x40,
        -- number of bytes to copy
        reg_0x44_o      => reg_0x44,
        reg_0x48_o      => reg_0x48,
        reg_0x4c_o      => reg_0x4c,
        app_start_o     => app_start,
        app_done_i      => app_done,
        app_ready_i     => app_ready,
        app_idle_i      => app_idle,
        -- User ports ends
        S_AXI_ACLK  => action_clk,
        S_AXI_ARESETN   => action_rst_n,
        S_AXI_AWADDR    => axi_ctrl_reg_awaddr,
        -- S_AXI_AWPROT    => axi_ctrl_reg_awprot,
        S_AXI_AWVALID   => axi_ctrl_reg_awvalid,
        S_AXI_AWREADY   => axi_ctrl_reg_awready,
        S_AXI_WDATA => axi_ctrl_reg_wdata,
        S_AXI_WSTRB => axi_ctrl_reg_wstrb,
        S_AXI_WVALID    => axi_ctrl_reg_wvalid,
        S_AXI_WREADY    => axi_ctrl_reg_wready,
        S_AXI_BRESP => axi_ctrl_reg_bresp,
        S_AXI_BVALID    => axi_ctrl_reg_bvalid,
        S_AXI_BREADY    => axi_ctrl_reg_bready,
        S_AXI_ARADDR    => axi_ctrl_reg_araddr,
        -- S_AXI_ARPROT    => axi_ctrl_reg_arprot,
        S_AXI_ARVALID   => axi_ctrl_reg_arvalid,
        S_AXI_ARREADY   => axi_ctrl_reg_arready,
        S_AXI_RDATA => axi_ctrl_reg_rdata,
        S_AXI_RRESP => axi_ctrl_reg_rresp,
        S_AXI_RVALID    => axi_ctrl_reg_rvalid,
        S_AXI_RREADY    => axi_ctrl_reg_rready
    );

-- Instantiation of Axi Bus Interface AXI_HOST_MEM
action_dma_axi_master_inst : entity work.action_axi_master
    generic map (

        C_M_AXI_ID_WIDTH    => C_AXI_HOST_MEM_ID_WIDTH,
        C_M_AXI_ADDR_WIDTH  => C_AXI_HOST_MEM_ADDR_WIDTH,
        C_M_AXI_DATA_WIDTH  => C_AXI_HOST_MEM_DATA_WIDTH,
        C_M_AXI_AWUSER_WIDTH    => C_AXI_HOST_MEM_AWUSER_WIDTH,
        C_M_AXI_ARUSER_WIDTH    => C_AXI_HOST_MEM_ARUSER_WIDTH,
        C_M_AXI_WUSER_WIDTH => C_AXI_HOST_MEM_WUSER_WIDTH,
        C_M_AXI_RUSER_WIDTH => C_AXI_HOST_MEM_RUSER_WIDTH,
        C_M_AXI_BUSER_WIDTH => C_AXI_HOST_MEM_BUSER_WIDTH
    )
    port map (

        dma_rd_req_i            => dma_rd_req,
        dma_rd_addr_i           => rd_addr,
        dma_rd_len_i            => rd_len,
        dma_rd_req_ack_o        => dma_rd_req_ack,
        dma_rd_data_o           => dma_rd_data,
        dma_rd_data_valid_o     => dma_rd_data_valid,
        dma_rd_data_taken_i     => dma_rd_data_taken,
        dma_rd_context_id       => reg_0x20(C_AXI_HOST_MEM_ARUSER_WIDTH - 1 downto 0),

        dma_wr_req_i            => dma_wr_req,
        dma_wr_addr_i           => wr_addr,
        dma_wr_len_i            => wr_len,
        dma_wr_req_ack_o        => dma_wr_req_ack,
        dma_wr_data_i           => wr_data,
        dma_wr_data_strobe_i    => dma_wr_data_strobe,
        dma_wr_data_last_i      => dma_wr_data_last,
        dma_wr_ready_o          => dma_wr_ready,
        dma_wr_bready_i         => dma_wr_bready,
        dma_wr_done_o           => dma_wr_done,
        dma_wr_context_id       => reg_0x20(C_AXI_HOST_MEM_AWUSER_WIDTH - 1 downto 0),


        M_AXI_ACLK  => action_clk,
        M_AXI_ARESETN   => action_rst_n,
        M_AXI_AWID  => axi_host_mem_awid,
        M_AXI_AWADDR    => axi_host_mem_awaddr,
        M_AXI_AWLEN => axi_host_mem_awlen,
        M_AXI_AWSIZE    => axi_host_mem_awsize,
        M_AXI_AWBURST   => axi_host_mem_awburst,
        M_AXI_AWLOCK    => axi_host_mem_awlock,
        M_AXI_AWCACHE   => axi_host_mem_awcache,
        M_AXI_AWPROT    => axi_host_mem_awprot,
        M_AXI_AWQOS => axi_host_mem_awqos,
        M_AXI_AWUSER    => axi_host_mem_awuser,
        M_AXI_AWVALID   => axi_host_mem_awvalid_in,
        M_AXI_AWREADY   => axi_host_mem_awready,
        M_AXI_WDATA => axi_host_mem_wdata,
        M_AXI_WSTRB => axi_host_mem_wstrb,
        M_AXI_WLAST => axi_host_mem_wlast,
        M_AXI_WUSER => axi_host_mem_wuser,
        M_AXI_WVALID    => axi_host_mem_wvalid,
        M_AXI_WREADY    => axi_host_mem_wready,
        M_AXI_BID   => axi_host_mem_bid,
        M_AXI_BRESP => axi_host_mem_bresp,
        M_AXI_BUSER => axi_host_mem_buser,
        M_AXI_BVALID    => axi_host_mem_bvalid,
        M_AXI_BREADY    => axi_host_mem_bready,
        M_AXI_ARID  => axi_host_mem_arid,
        M_AXI_ARADDR    => axi_host_mem_araddr,
        M_AXI_ARLEN => axi_host_mem_arlen,
        M_AXI_ARSIZE    => axi_host_mem_arsize,
        M_AXI_ARBURST   => axi_host_mem_arburst,
        M_AXI_ARLOCK    => axi_host_mem_arlock,
        M_AXI_ARCACHE   => axi_host_mem_arcache,
        M_AXI_ARPROT    => axi_host_mem_arprot,
        M_AXI_ARQOS => axi_host_mem_arqos,
        M_AXI_ARUSER    => axi_host_mem_aruser,
        M_AXI_ARVALID   => axi_host_mem_arvalid_in,
        M_AXI_ARREADY   => axi_host_mem_arready,
        M_AXI_RID   => axi_host_mem_rid,
        M_AXI_RDATA => axi_host_mem_rdata,
        M_AXI_RRESP => axi_host_mem_rresp,
        M_AXI_RLAST => axi_host_mem_rlast,
        M_AXI_RUSER => axi_host_mem_ruser,
        M_AXI_RVALID    => axi_host_mem_rvalid,
        M_AXI_RREADY    => axi_host_mem_rready
    );

    rd_len <= x"04"; 
    wr_len <= x"00"; 

    
    axi_host_mem_awvalid <= axi_host_mem_awvalid_in;
    axi_host_mem_arvalid <= axi_host_mem_arvalid_in;

    action_rst <= not action_rst_n;
	
	seq_process: process(action_clk ) is
    begin
      if (rising_edge (action_clk)) then
        if ( action_rst_n = '0' ) then
          read_r.state     <= IDLE;
          read_r.done      <= '0';
          read_r.ready     <= '1';
          read_r.idle      <= '1';
          read_r.addr      <= (others => '0');
          read_r.counter_q <= (others => '0');
          write_r.state    <= IDLE;
          write_r.done     <= '0';
          write_r.ready    <= '1';
          write_r.idle     <= '1';
          write_r.addr     <= (others => '0');
          write_r.counter_q<= (others => '0');
        else
          read_r <= read_d;
          write_r <= write_d;
        end if;
      end if;
    end process;

    read_comb_process: process(read_r, read_d, app_start, reg_0x34, reg_0x38, reg_0x44, dma_rd_req_ack, reg0_ready, dma_rd_data_valid) is
	variable v: reg_type_read;
    begin
	  --signal defaults
      v := read_r;
      dma_rd_data_taken <= '0';
      dma_rd_req        <= '0';

          -- State machine for reading (1 bus word at the time)
          case read_r.state is
            when IDLE  =>
	      v.idle              := '1';
              v.ready             := '1';
              v.done              := '0';
              v.addr              := (63 downto 0 => '0');
              v.counter_q         := (31 downto 0 => '0');

              if app_start = '1' then		
		v.state           := STARTING;
                v.idle            := '0';
                v.ready           := '0';
                v.done            := '0';
                v.addr            := reg_0x38 & reg_0x34;
                v.counter_q       := reg_0x44;
              end if;
            when STARTING =>
              dma_rd_req          <= '1';
              v.state             := RUNNING;
            when RUNNING =>
              if dma_rd_req_ack = '1' then
                v.counter_q := read_r.counter_q - (C_AXI_HOST_MEM_DATA_WIDTH/8)*5;
                v.addr   := read_r.addr + (C_AXI_HOST_MEM_DATA_WIDTH/8)*5;
              end if;

              if reg0_ready = '1' and dma_rd_data_valid = '1' then

                dma_rd_data_taken <= '1';
                dma_rd_req     <= '1'; -- next read
              end if;

              if read_r.counter_q < ((C_AXI_HOST_MEM_DATA_WIDTH/8)*5) then
                v.done   := '1';
                v.state  := IDLE;
              end if;

            when others => null;
          end case;
        read_d <= v;
    end process;

--Do something with the data in reg0. 
--For now, in this example, we will just discard the data.
    
	reg0_data  <= dma_rd_data;
	reg0_valid <= dma_rd_data_valid;

	dma_wr_bready <= '1';
	dma_wr_data_last   <= '1';
	
	wr_count_q <= conv_std_logic_vector((conv_integer(reg_0x44)-7753920),24);
	wr_count <= conv_std_logic_vector((conv_integer(wr_count_q)/200704),24);
	
	write_comb_process: process(write_r, write_d, app_start, reg_0x3c, reg_0x40, reg_0x44, dma_wr_ready, label_valid, dma_wr_req_ack) is
      variable v: reg_type_write;
    begin
      --signal defaults
      v := write_r;
      dma_wr_req         <= '0';
      dma_wr_data_strobe <= (63 downto 0 => '0');
      -- State machine for writing (1 bus word at the time)
      case write_r.state is
        when IDLE  =>
          v.idle               := '1';
          v.ready              := '1';
          v.done               := '0';
          v.addr               := (63 downto 0 => '0');
          v.counter_q          := (23 downto 0 => '0');
          
          if app_start = '1' then
            v.state            := RUNNING;
            v.idle             := '0';
            v.ready            := '0';
            v.done             := '0';
            v.addr             := reg_0x40 & reg_0x3c;
			v.counter_q        :=	wr_count;
          end if;

        when RUNNING =>
          if dma_wr_ready = '1' and label_valid = '1' then
            dma_wr_req         <= '1';
            dma_wr_data_strobe <= "0000000000000000000000000000000000000000000000000000000000000001";

            --increase counter
            v.counter_q        := write_r.counter_q - 1;
            v.addr             := write_r.addr + (C_AXI_HOST_MEM_DATA_WIDTH/8);
		   end if;

           if write_r.counter_q = 0 then
             v.state          := FINISH;
           end if;
          
        when FINISH =>
		  if dma_wr_ready = '1' then
            dma_wr_req         <= '1';
          end if;

          if dma_wr_req_ack = '1' then
            v.state            := IDLE;
            v.done             := '1';
          end if;
        when others => null;
      end case;
      write_d <= v;
    end process;	     
	  
	--Connect Signals
    action_rst <= not action_rst_n;
    wr_addr <= write_r.addr;
    rd_addr <= read_r.addr;
    app_idle <= read_r.idle and write_r.idle;
    app_done <= write_r.done;
    app_ready <= read_r.ready and write_r.ready;
    wr_data(511 downto 10) <= (others => '0');
    wr_data(9 downto 0) <= label_o;

 GearboxSerializer: StreamGearboxSerializer
    generic map (
      ELEMENT_WIDTH   => 32,
      CTRL_WIDTH      => 0,
      IN_COUNT_MAX    => 16,
      IN_COUNT_WIDTH  => 5,
      OUT_COUNT_MAX   => 1,
      OUT_COUNT_WIDTH => 1
    )
    port map (
	  clk      => action_clk,  
	  reset    => action_rst,  
		
	  in_valid  =>    reg0_valid,               
	  in_ready  =>    reg0_ready,                    
	  in_data   =>    reg0_data,               
	  in_count  =>    "10000",                  
	  in_last   =>    '1',                 

	  out_valid =>    serializer_out_valid,                 
      out_ready =>    serializer_out_ready,            
	  out_data  =>    serializer_out_data,                
	  out_count =>    serializer_out_count,                  
   	  out_last  =>    serializer_out_last                
    );

	valid_in <= serializer_out_valid;
	serializer_out_ready <= ready_in;
	data_in(31 downto 24) <= serializer_out_data(7 downto 0);
	data_in(23 downto 16) <= serializer_out_data(15 downto 8);
	data_in(15 downto 8)  <= serializer_out_data(23 downto 16);
	data_in(7 downto 0)   <= serializer_out_data(31 downto 24);

 ResNet18_Top_i: ResNet18_Top
    port map (
      	i_sclk       =>    action_clk,
     	i_rstp       =>    action_rst,
  
      	i_valid   =>    valid_in,
      	o_ready   =>    ready_in,
      	i_tdata   =>    data_in,
	  
	    o_tdata    =>    label_o,
	    o_valid    =>    label_valid,
        i_ready    =>    dma_wr_ready
	);

  -- Tie off signals related to unused functionality
  int_req  <= '0';

end action_example;
