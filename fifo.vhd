-- FIFO RTL
-- head -> points to the memory block/slot that will contain the next data
-- tail -> points to the next element that will be read from the FIFO
-- head == tail (doesn't matter where the index is) -> fifo empty (initial state); 
-- head_index == tail_(index-1) -> fifo full
-- number of elements in the fifo = head - tail

library IEEE;
use IEEE.std_logic_1164.all;

entity fifo is
  generic (
    RAM_WIDTH : natural;  -- indicates the number of bits each memory block will contain (see the FPGA datasheet: 36)
    RAM_DEPTH : natural -- indicates the number of blocks (see the FPGA datasheet: 512)
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- Write port
    wr_en : in std_logic;
    wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0);

    -- Read port
    rd_en : in std_logic;
    rd_valid : out std_logic;
    rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0);

    -- Flags
    empty : out std_logic;
    empty_next : out std_logic;  -- almost empty ('high' one clock cycle before the fifo gets empty)
    full : out std_logic;
    full_next : out std_logic; -- almost full ('high' one clock cycle before the fifo gets full)

    -- Count the number of elements in the FIFO
    count : out integer range RAM_DEPTH - 1 downto 0
  );
end fifo;

architecture rtl of fifo is

  type ram_type is array (0 to RAM_DEPTH - 1) of std_logic_vector(wr_data'range);
  signal ram : ram_type;

  subtype index_type is integer range ram_type'range;
  signal head : index_type;
  signal tail : index_type;

  signal empty_i : std_logic;
  signal full_i : std_logic;
  signal count_i : integer range RAM_DEPTH - 1 downto 0;

  -- Update index
  procedure update(signal index : inout index_type) is
  begin
    if index = index_type'high then
      index <= index_type'low;
    else
      index <= index + 1;
    end if;
  end procedure;

begin

  empty <= empty_i;
  full <= full_i;
  count <= count_i;

  -- Set the flags
  empty_i <= '1' when count_i = 0 else '0';
  empty_next <= '1' when count_i <= 1 else '0';
  full_i <= '1' when count_i >= RAM_DEPTH - 1 else '0';
  full_next <= '1' when count_i >= RAM_DEPTH - 2 else '0';

  -- Update the head pointer 
  UPDATE_HEAD : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        head <= 0;
      else

        if wr_en = '1' and full_i = '0' then
          update(head);
        end if;

      end if;
    end if;
  end process;

  -- Update the tail 
  UPDATE_TAIL : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        tail <= 0;
        rd_valid <= '0';
      else
        rd_valid <= '0';

        if rd_en = '1' and empty_i = '0' then
          update(tail);
          rd_valid <= '1';
        end if;

      end if;
    end if;
  end process;

  -- Write to and read from the RAM
  UPDATE_RAM : process(clk)
  begin
    if rising_edge(clk) then
      ram(head) <= wr_data;
      rd_data <= ram(tail);
    end if;
  end process;

  -- Update the FIFO size
  COUNTER : process(head, tail)
  begin
    if head < tail then
      count_i <= head - tail + RAM_DEPTH;
    else
      count_i <= head - tail;
    end if;
  end process;

end architecture;